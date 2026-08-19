package com.fpoly.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.ShippingDtos.ShippingOptionDto;
import com.fpoly.model.Cart;
import com.fpoly.model.CartItem;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.Order;
import com.fpoly.model.OrderItem;
import com.fpoly.model.OrderStatusLog;
import com.fpoly.model.Payment;
import com.fpoly.model.PaymentMethod;
import com.fpoly.model.ProductVariant;
import com.fpoly.model.UserAddress;
import com.fpoly.repository.CartItemRepository;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.OrderRepository;
import com.fpoly.repository.OrderStatusLogRepository;
import com.fpoly.repository.PaymentMethodRepository;
import com.fpoly.repository.PaymentRepository;
import com.fpoly.repository.UserAddressRepository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepo;

    @Autowired
    private WarrantyService warrantyService;

    @Autowired
    private OrderStatusLogRepository statusLogRepo;

    @Autowired
    private NguoiDungRepository nguoiDungRepo;

    @Autowired
    private UserAddressRepository addressRepo;

    @Autowired
    private CartService cartService;

    @Autowired
    private CartItemRepository cartItemRepo;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private PaymentRepository paymentRepo;

    @Autowired
    private PaymentMethodRepository paymentMethodRepo;

    @Autowired
    private MailService mailService;

    @Autowired
    private WalletService walletService;

    @Autowired
    private CouponService couponService;

    @Autowired
    private ShippingService shippingService;

    @Autowired
    private MembershipService membershipService;

    @Autowired
    private TradeInService tradeInService;

    @Autowired
    private SubscriptionService subscriptionService;

    @Autowired
    private AfterShipApiService afterShipApiService;

    @Autowired
    private TonKhoService tonKhoService;

    @Autowired
    private com.fpoly.repository.ReturnRequestRepository returnRequestRepo;

    @PersistenceContext
    private EntityManager em;

    // Chỉ dùng khi địa chỉ chưa có Phường chuẩn hoá (tạo qua trang Thymeleaf cũ) hoặc không có
    // mã tuỳ chọn giao hàng — xem ShippingService cho luồng tính phí thật theo Phường.
    private static final BigDecimal PHI_VAN_CHUYEN_MAC_DINH = new BigDecimal("30000");

    /** Số giờ giữ hàng chờ thanh toán trước khi tự động huỷ (chuyển khoản / thẻ Stripe chưa
     * thanh toán) — không áp dụng cho COD vì COD vốn chỉ thu tiền khi giao, không phải "chưa
     * thanh toán" theo nghĩa cần giữ hàng chờ. Xem huyDonHetHanThanhToan(). */
    private static final long GIO_GIU_HANG_CHO_THANH_TOAN = 24;

    /** Đơn qua cổng redirect (Stripe/VNPay) chỉ được GIỮ HÀNG bấy nhiêu phút.
     *
     * Hàng bị trừ kho ngay khi tạo đơn để 2 khách không cùng mua được món cuối cùng — nhưng
     * chính vì thế không thể giữ lâu: mỗi phút giữ là một phút món hàng hiện "tạm hết hàng"
     * với mọi người khác dù có thể khách kia đã bỏ đi. 5 phút đủ để thao tác xong một lượt
     * thanh toán thẻ/QR, và ngắn để hàng quay lại kệ nhanh nếu khách bỏ dở.
     *
     * KHÁC với GIO_GIU_HANG_CHO_THANH_TOAN (24h) ở trên — mốc đó dành cho chuyển khoản, nơi
     * admin phải đối soát bằng tay nên không thể ép 5 phút. */
    private static final long PHUT_GIU_HANG_THANH_TOAN = 5;

    /** Đặt hàng từ giao diện Thymeleaf cũ — mặc định thanh toán COD. */
    @Transactional
    public Order datHangTuGioHang(String email, Integer addressId) {
        return datHangTuGioHang(email, addressId, "cod");
    }

    @Transactional
    public Order datHangTuGioHang(String email, Integer addressId, String paymentMethodCode) {
        return datHangTuGioHang(email, addressId, paymentMethodCode, null);
    }

    @Transactional
    public Order datHangTuGioHang(String email, Integer addressId, String paymentMethodCode, List<Integer> cartItemIds) {
        return datHangTuGioHang(email, addressId, paymentMethodCode, cartItemIds, null, null);
    }

    @Transactional
    public Order datHangTuGioHang(String email, Integer addressId, String paymentMethodCode, List<Integer> cartItemIds, String maCoupon) {
        return datHangTuGioHang(email, addressId, paymentMethodCode, cartItemIds, maCoupon, null);
    }

    @Transactional
    public Order datHangTuGioHang(String email, Integer addressId, String paymentMethodCode, List<Integer> cartItemIds,
                                   String maCoupon, Integer soXuMuonDung) {
        return datHangTuGioHang(email, addressId, paymentMethodCode, cartItemIds, maCoupon, soXuMuonDung, null);
    }

    /** cartItemIds null/rỗng = thanh toán toàn bộ giỏ; có giá trị = chỉ các dòng được chọn
     * (VD tick chọn ở CartView) — các dòng còn lại trong giỏ không bị đụng tới. maCoupon
     * null/rỗng = không áp mã. soXuMuonDung null/0 = không dùng Xu CT giảm giá trực tiếp —
     * có giá trị thì giảm thêm (1 xu = 1.000đ khi tiêu, xem WalletService), cộng dồn với coupon,
     * tổng giảm không bao giờ vượt quá tiền hàng. maTuyChonGiaoHang = mã tuỳ chọn giao hàng
     * (hoa_toc/thuong trong Hải Phòng, hoặc mã hãng ngoài Hải Phòng — xem ShippingService);
     * null = fallback phí cố định (địa chỉ Thymeleaf cũ chưa có Phường chuẩn hoá).
     * GIỮ NGUYÊN cho tương thích ngược (Thymeleaf cũ, các overload phía trên) — bọc 1 mã thành
     * danh sách 1 phần tử rồi gọi bản nhiều mã bên dưới. */
    @Transactional
    public Order datHangTuGioHang(String email, Integer addressId, String paymentMethodCode, List<Integer> cartItemIds,
                                   String maCoupon, Integer soXuMuonDung, String maTuyChonGiaoHang) {
        List<String> danhSachMaCoupon = (maCoupon == null || maCoupon.isBlank())
                ? List.of() : List.of(maCoupon);
        return datHangTuGioHang(email, addressId, paymentMethodCode, cartItemIds, danhSachMaCoupon,
                soXuMuonDung, maTuyChonGiaoHang, null);
    }

    /** tradeInCreditId = tín dụng thu cũ dùng cho đơn này. Trừ SAU coupon/hạng/xu và ghi vào cột
     * riêng (Order.tienThuCu), không gộp vào tienGiamGia — kế toán cần tách bạch giảm giá khuyến
     * mãi với tiền shop trả khách để mua lại máy cũ.
     * GIỮ NGUYÊN cho tương thích ngược — bọc 1 mã thành danh sách 1 phần tử. */
    @Transactional
    public Order datHangTuGioHang(String email, Integer addressId, String paymentMethodCode, List<Integer> cartItemIds,
                                   String maCoupon, Integer soXuMuonDung, String maTuyChonGiaoHang,
                                   Integer tradeInCreditId) {
        List<String> danhSachMaCoupon = (maCoupon == null || maCoupon.isBlank())
                ? List.of() : List.of(maCoupon);
        return datHangTuGioHang(email, addressId, paymentMethodCode, cartItemIds, danhSachMaCoupon,
                soXuMuonDung, maTuyChonGiaoHang, tradeInCreditId);
    }

    /** Bản ÁP NHIỀU MÃ CÙNG LÚC (cộng dồn/loại trừ — xem CouponService.kiemTraTuongThich).
     * danhSachMaCoupon null/rỗng = không áp mã nào. Toàn bộ tham số khác giống các overload
     * phía trên. Đây là nơi chứa TOÀN BỘ logic tạo đơn thật sự — mọi overload khác đều gọi vào
     * đây. */
    @Transactional
    public Order datHangTuGioHang(String email, Integer addressId, String paymentMethodCode, List<Integer> cartItemIds,
                                   List<String> danhSachMaCoupon, Integer soXuMuonDung, String maTuyChonGiaoHang,
                                   Integer tradeInCreditId) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        UserAddress address = addressRepo.findById(addressId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy địa chỉ giao hàng"));

        if (!address.getNguoiDung().getEmail().equals(email)) {
            throw new RuntimeException("Địa chỉ giao hàng không hợp lệ");
        }

        Cart cart = cartService.layHoacTaoCart(email);
        List<CartItem> items = cartItemRepo.findByCart(cart);
        if (cartItemIds != null && !cartItemIds.isEmpty()) {
            items = items.stream().filter(ci -> cartItemIds.contains(ci.getId())).toList();
        }

        if (items.isEmpty()) {
            throw new RuntimeException("Giỏ hàng đang trống");
        }

        // Kiểm tra sớm cho THÔNG BÁO ĐẸP (báo ngay trước khi tính tiền, tính ship, trừ xu...).
        // Đây KHÔNG phải chốt chặn chống bán quá kho — hai khách song song đều có thể qua được
        // bước này; chốt chặn thật là lệnh giữ hàng có điều kiện ở phía dưới (TonKhoService).
        for (CartItem ci : items) {
            ProductVariant v = ci.getVariant();
            if (v.getStock() != null && v.getStock() < ci.getSoLuong()) {
                throw new RuntimeException("Sản phẩm \"" + v.getProduct().getName() + "\" không đủ hàng trong kho");
            }
        }

        BigDecimal tienHang = items.stream()
                .map(CartItem::getThanhTien)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // Ưu đãi bậc thành viên (Bạc 2% / Vàng 5% / Kim cương 15% mọi đơn) — áp tự động, cộng
        // dồn với coupon và xu. Tính trên tiền hàng gốc để % luôn đúng như quảng cáo, không phụ
        // thuộc thứ tự áp các loại giảm giá khác.
        com.fpoly.model.MembershipTier bacThanhVien = membershipService.bacCua(user);
        BigDecimal tienGiamGia = bacThanhVien.tienGiamTheoBac(tienHang);

        // Áp NHIỀU mã cùng lúc: kiểm tra hợp lệ + tương thích (cộng dồn/loại trừ) trước, ném lỗi
        // ngay nếu có vấn đề — không áp nửa chừng. Danh sách rỗng = không áp mã nào (giữ nguyên
        // hành vi cũ).
        List<com.fpoly.model.Coupon> danhSachCoupon = new ArrayList<>();
        if (danhSachMaCoupon != null && !danhSachMaCoupon.isEmpty()) {
            danhSachCoupon = couponService.layDanhSachCouponHopLe(danhSachMaCoupon, tienHang);
            tienGiamGia = tienGiamGia.add(couponService.tinhTongGiamGia(danhSachCoupon, tienHang));
        }
        // Tổng giảm từ bậc + coupon vẫn không được vượt quá tiền hàng.
        tienGiamGia = tienGiamGia.min(tienHang);

        // Dùng Xu CT giảm thêm trực tiếp vào bill — cộng dồn với giảm giá từ coupon (nếu có),
        // nhưng không bao giờ vượt quá tiền hàng còn lại sau khi trừ coupon. Số xu THẬT SỰ bị
        // trừ được tính lại theo đúng số tiền còn giảm được (soXuThucDung), tránh trừ dư xu nếu
        // khách yêu cầu nhiều hơn mức có thể áp dụng.
        int soXuThucDung = 0;
        if (soXuMuonDung != null && soXuMuonDung > 0) {
            if (walletService.layHoacTaoVi(user).getSoDuBac() < soXuMuonDung) {
                throw new RuntimeException("Không đủ Xu CT");
            }
            BigDecimal conLaiCoTheGiam = tienHang.subtract(tienGiamGia);
            BigDecimal tienXuMuonDung = walletService.quyDoiXuRaTien(soXuMuonDung).min(conLaiCoTheGiam);
            // soXuDeGiam (chiều TIÊU), không phải uocTinhXu (chiều KIẾM) — hai tỉ giá khác nhau.
            soXuThucDung = walletService.soXuDeGiam(tienXuMuonDung);
            tienGiamGia = tienGiamGia.add(walletService.quyDoiXuRaTien(soXuThucDung));
        }

        BigDecimal phiVanChuyen = PHI_VAN_CHUYEN_MAC_DINH;
        ShippingOptionDto tuyChonGiaoHang = null;
        BigDecimal khoangCachGiao = null;
        if (address.getWard() != null && maTuyChonGiaoHang != null && !maTuyChonGiaoHang.isBlank()) {
            var ketQua = shippingService.layPhiTheoOption(address, maTuyChonGiaoHang, email);
            tuyChonGiaoHang = ketQua.option();
            khoangCachGiao = ketQua.khoangCachKm();
            phiVanChuyen = tuyChonGiaoHang.fee();
        }
        // Tín dụng thu cũ: trừ vào phần CÒN LẠI phải trả (đã gồm phí ship), vì đây là tiền shop
        // nợ khách chứ không phải khuyến mãi trên tiền hàng. Không bao giờ để tổng âm.
        BigDecimal conPhaiTra = tienHang.add(phiVanChuyen).subtract(tienGiamGia);
        com.fpoly.model.TradeInCredit tinDung = tradeInService.layTinDungHopLe(tradeInCreditId, user, tienHang);
        BigDecimal tienThuCu = tinDung == null ? BigDecimal.ZERO : tinDung.getSoTien().min(conPhaiTra);

        BigDecimal tongTien = conPhaiTra.subtract(tienThuCu);

        Order order = new Order();
        order.setNguoiDung(user);
        // Chụp lại địa chỉ (tên/SĐT/địa chỉ đầy đủ + toạ độ) thay vì chỉ giữ FK — khách sửa hoặc
        // xoá địa chỉ trong sổ sau khi đặt thì đơn này vẫn hiển thị đúng nơi đã giao.
        order.chupLaiDiaChi(address);
        order.setTienHang(tienHang);
        order.setTienGiamGia(tienGiamGia);
        order.setPhiVanChuyen(phiVanChuyen);
        order.setTongTien(tongTien);
        order.setTienThuCu(tienThuCu);
        order.setTradeInCreditId(tinDung == null ? null : tinDung.getId());
        order.setTrangThai("pending");
        order.setCouponId(danhSachCoupon.isEmpty() ? null : danhSachCoupon.get(0).getId());
        if (tuyChonGiaoHang != null) {
            order.setMaTuyChonGiaoHang(tuyChonGiaoHang.code());
            order.setNhanTuyChonGiaoHang(tuyChonGiaoHang.label());
            order.setThoiGianGiaoDuKien(tuyChonGiaoHang.eta());
        }
        // Quãng đường đã dùng để tính phí, lưu để admin đối chiếu được phí ship của đơn.
        // (Toạ độ điểm giao đã được chụp cùng địa chỉ ở chupLaiDiaChi phía trên.)
        order.setKhoangCachGiaoKm(khoangCachGiao);

        // Đơn qua cổng redirect (Stripe/VNPay) chỉ thực sự "chốt" khi thanh toán thành công
        // (callback /payment/stripe/return hoặc webhook) — giỏ hàng vì thế chưa bị xoá ngay bây
        // giờ, để khách huỷ/đóng trang giữa chừng thì hàng vẫn còn nguyên trong giỏ.
        boolean choTraSauKhiThanhToan = laCongThanhToanRedirect(paymentMethodCode);

        // KHO thì ngược lại: trừ NGAY cho mọi hình thức thanh toán. Trước đây đơn redirect
        // không trừ kho tới lúc trả tiền xong, nên còn đúng 1 máy mà 2 khách cùng bấm mua thì
        // cả hai đều đặt được và người trả sau mua phải món không còn tồn tại. Giữ hàng ngay
        // lúc tạo đơn khiến sản phẩm lập tức hiện "tạm hết hàng" với người khác; đổi lại đơn
        // redirect chỉ được giữ PHUT_GIU_HANG_THANH_TOAN phút rồi tự nhả (xem
        // giaiPhongDonHetHanGiuHang) để hàng không bị treo vì một khách bỏ dở.
        List<OrderItem> chiTiet = new ArrayList<>();
        for (CartItem ci : items) {
            ProductVariant v = ci.getVariant();

            if (!tonKhoService.giuHang(v, ci.getSoLuong())) {
                // Người khác vừa lấy mất trong lúc khách này đang ở trang thanh toán. Ném lỗi
                // -> cả transaction rollback, những dòng đã giữ trước đó trong cùng đơn cũng
                // được trả lại kho, không để lại hàng bị treo.
                throw new RuntimeException("Sản phẩm \"" + v.getProduct().getName()
                        + "\" vừa được người khác đặt hết. Vui lòng bỏ khỏi giỏ hoặc giảm số lượng rồi thử lại.");
            }

            OrderItem oi = new OrderItem();
            oi.setOrder(order);
            oi.setVariant(v);
            oi.setTenSanPham(v.getProduct().getName());
            oi.setThongTinPhienBan(v.getSku());
            oi.setDonGia(v.getPrice());
            oi.setSoLuong(ci.getSoLuong());

            chiTiet.add(oi);
        }
        order.setChiTiet(chiTiet);
        if (choTraSauKhiThanhToan) {
            order.setHanGiuHang(LocalDateTime.now().plusMinutes(PHUT_GIU_HANG_THANH_TOAN));
        }

        Order saved = orderRepo.save(order);

        if (!danhSachCoupon.isEmpty()) {
            couponService.danhDauDaDungNhieu(danhSachCoupon);
            // Ghi lại TỪNG mã đã áp + số tiền giảm riêng của mã đó vào ORDER_COUPON — cột
            // ORDER.coupon_id ở trên chỉ giữ mã ĐẦU TIÊN để tương thích ngược với code/báo cáo cũ,
            // danh sách đầy đủ (khi áp nhiều mã cộng dồn) nằm ở bảng này.
            for (com.fpoly.model.Coupon c : danhSachCoupon) {
                BigDecimal giamRieng = couponService.tinhGiamGia(c, tienHang);
                em.createNativeQuery(
                        "INSERT INTO ORDER_COUPON (order_id, coupon_id, discount_amount) VALUES (:orderId, :couponId, :amount)")
                        .setParameter("orderId", saved.getId())
                        .setParameter("couponId", c.getId())
                        .setParameter("amount", giamRieng)
                        .executeUpdate();
            }
        }
        if (soXuThucDung > 0) {
            walletService.chiXuTaiThanhToan(user, soXuThucDung, saved);
        }
        if (tinDung != null) {
            tradeInService.danhDauDaDung(tinDung, saved.getId());
        }

        // Nếu đơn giao LIÊN TỈNH và phí đã về 0 nhờ gói hội viên (không phải hạng tích luỹ — hạng
        // chỉ giảm %) thì trừ 1 lượt free ship liên tỉnh của gói, gắn với đơn để hoàn khi huỷ.
        if (tuyChonGiaoHang != null) {
            subscriptionService.ghiNhanGiaoHangLienTinh(saved, email, tuyChonGiaoHang.code(),
                    tuyChonGiaoHang.feeGoc(), tuyChonGiaoHang.fee());
        }

        PaymentMethod paymentMethod = paymentMethodRepo.findByCode(paymentMethodCode)
                .orElseThrow(() -> new RuntimeException("Phương thức thanh toán không hợp lệ"));

        Payment payment = new Payment();
        payment.setOrder(saved);
        payment.setPaymentMethod(paymentMethod);
        payment.setAmount(tongTien);
        payment.setStatus("pending");
        paymentRepo.save(payment);

        OrderStatusLog log = new OrderStatusLog();
        log.setOrder(saved);
        log.setTrangThai("pending");
        log.setGhiChu("Đơn hàng được tạo");
        statusLogRepo.save(log);

        if (!choTraSauKhiThanhToan) {
            cartItemRepo.deleteAll(items);
        }

        notificationService.tao(
                "new_order",
                "Đơn hàng mới",
                "Đơn " + saved.getMaDonHang() + " từ " + user.getHoTen() + " - " + tongTien.longValue() + "đ",
                "/orders"
        );

        // COD: không có khái niệm "chưa thanh toán cần giữ hàng" (thu tiền khi giao), nên chỉ
        // báo đặt hàng thành công bình thường. Chuyển khoản/Stripe: tại đúng thời điểm này chưa
        // hề thanh toán (Stripe thì khách còn chưa kịp redirect sang trang Stripe), nên báo rõ
        // hạn hoàn tất thanh toán 24h — nếu sau đó thanh toán thành công sẽ có thông báo/mail
        // riêng (xem xacNhanThanhToanGatewayThanhCong / xacNhanThanhToan).
        if ("cod".equals(paymentMethodCode)) {
            notificationService.taoChoUser(
                    user.getId(), "order_placed", "Đặt hàng thành công",
                    "Đơn hàng " + saved.getMaDonHang() + " của bạn đã được tiếp nhận, tổng tiền "
                            + tongTien.longValue() + "đ. Thanh toán khi nhận hàng (COD).",
                    "/tai-khoan/don-hang"
            );
            try {
                mailService.sendOrderPlacedCodEmail(saved);
            } catch (Exception e) {
                // Không chặn luồng đặt hàng nếu gửi mail thất bại
            }
        } else {
            // Hai hạn giữ hàng KHÁC NHAU: cổng redirect (Stripe/VNPay) trả tiền ngay tại chỗ
            // nên chỉ giữ 5 phút; chuyển khoản phải chờ admin đối soát nên giữ 24h.
            String hanGiu = choTraSauKhiThanhToan
                    ? PHUT_GIU_HANG_THANH_TOAN + " phút"
                    : GIO_GIU_HANG_CHO_THANH_TOAN + " giờ";
            notificationService.taoChoUser(
                    user.getId(), "order_awaiting_payment", "Đơn hàng đang chờ thanh toán",
                    "Đơn hàng " + saved.getMaDonHang() + " đã được ghi nhận nhưng CHƯA hoàn tất thanh toán. "
                            + "Shop đang giữ hàng cho bạn, vui lòng thanh toán trong vòng " + hanGiu
                            + ", nếu không đơn sẽ tự động bị huỷ và hàng được trả lại kho.",
                    "/tai-khoan/don-hang"
            );
            try {
                mailService.sendOrderAwaitingPaymentEmail(saved, paymentMethodCode);
            } catch (Exception e) {
                // Không chặn luồng đặt hàng nếu gửi mail thất bại
            }
        }

        try {
            mailService.sendNewOrderAdminNotification(saved);
        } catch (Exception e) {
            // Không chặn luồng đặt hàng nếu gửi mail admin thất bại
        }

        return saved;
    }

    /** Các cổng thanh toán cần redirect ra ngoài (Stripe, VNPay) chỉ thực sự "chốt" đơn khi có
     * xác nhận thanh toán thành công gọi ngược lại (StripeController/VNPayController) — khác
     * COD/chuyển khoản xử lý ngay tại chỗ. Public để OrderApiController dùng chung khi quyết
     * định có trả redirectUrl cho frontend hay không, và trả về gateway nào (dựa vào code). */
    public boolean laCongThanhToanRedirect(String paymentMethodCode) {
        return "stripe_card".equals(paymentMethodCode)
                || (paymentMethodCode != null && paymentMethodCode.startsWith("vnpay"));
    }

    /** Gọi khi cổng thanh toán redirect (Stripe/VNPay) báo thành công (return hoặc webhook, xem
     * StripeController) — chốt đơn: gỡ hạn giữ hàng (hàng đã là của khách này, không còn đếm
     * ngược) + xoá các dòng giỏ hàng tương ứng (cố tình chưa xoá lúc tạo đơn để khách không mất
     * hàng trong giỏ nếu huỷ/đóng trang giữa chừng) + gửi thông báo/mail xác nhận.
     *
     * KHÔNG trừ kho ở đây nữa: kho đã bị trừ ngay lúc tạo đơn cho MỌI hình thức thanh toán
     * (xem datHangTuGioHang) để hai khách không cùng mua được món cuối cùng. */
    /**
     * Chốt đơn sau khi cổng thanh toán (Stripe/VNPay) báo thành công.
     *
     * Xử lý cả trường hợp TIỀN VỀ MUỘN: đơn chỉ được giữ hàng 5 phút, khách trả tiền ở phút thứ
     * 6 thì tác vụ quét đã huỷ đơn và trả hàng lại kho từ trước. Trước đây hai controller cổng
     * thanh toán đều gán thẳng trạng thái "confirmed" bất kể đơn đang ở đâu — đơn đã huỷ sẽ
     * sống lại trong khi hàng của nó có thể đã bán cho người khác.
     *
     * Nay: thử GIỮ LẠI hàng.
     *   - Giữ được  -> đơn hồi sinh về "confirmed", khách không mất gì.
     *   - Không còn -> đơn ở nguyên "cancelled", báo cho khách và tạo việc hoàn tiền cho admin.
     *     Thà hoàn tiền một khách còn hơn hứa giao món hàng không tồn tại.
     *
     * @param ghiChuLog nội dung ghi vào lịch sử, do controller truyền vào để nói rõ cổng nào.
     * @return true nếu đơn được chốt thành công.
     */
    @Transactional
    public boolean chotDonSauThanhToanGateway(Order order, String ghiChuLog) {
        if ("cancelled".equals(order.getTrangThai())) {
            if (!giuLaiHangChoDonDaHuy(order)) {
                OrderStatusLog logHong = new OrderStatusLog();
                logHong.setOrder(order);
                logHong.setTrangThai("cancelled");
                logHong.setGhiChu(ghiChuLog + " NHƯNG đơn đã hết hạn giữ hàng và hàng đã bán hết"
                        + " — cần hoàn tiền cho khách.");
                statusLogRepo.save(logHong);

                notificationService.taoChoUser(
                        order.getNguoiDung().getId(), "order_expired",
                        "Đơn " + order.getMaDonHang() + " không thể hoàn tất",
                        "Thanh toán của bạn về sau khi hết thời gian giữ hàng và sản phẩm đã hết. "
                                + "Shop sẽ hoàn lại toàn bộ số tiền này, bộ phận CSKH sẽ liên hệ với bạn.",
                        "/tai-khoan/don-hang");
                notificationService.tao("refund_needed", "Cần hoàn tiền đơn " + order.getMaDonHang(),
                        "Khách đã thanh toán sau khi đơn tự huỷ do hết hạn giữ hàng, hàng không còn."
                                + " Vui lòng hoàn tiền.", "/orders");
                return false;
            }
            OrderStatusLog logHoiSinh = new OrderStatusLog();
            logHoiSinh.setOrder(order);
            logHoiSinh.setTrangThai("confirmed");
            logHoiSinh.setGhiChu(ghiChuLog + " (về sau hạn giữ hàng nhưng vẫn còn hàng — đơn được khôi phục)");
            statusLogRepo.save(logHoiSinh);
        } else {
            OrderStatusLog log = new OrderStatusLog();
            log.setOrder(order);
            log.setTrangThai("confirmed");
            log.setGhiChu(ghiChuLog);
            statusLogRepo.save(log);
        }

        order.setTrangThai("confirmed");
        xacNhanThanhToanGatewayThanhCong(order);
        return true;
    }

    /** Giữ lại toàn bộ hàng của một đơn đã bị huỷ. Trả false nếu bất kỳ dòng nào không còn đủ —
     * khi đó những dòng vừa giữ được sẽ được nhả ra ngay, không để hàng treo lơ lửng. */
    private boolean giuLaiHangChoDonDaHuy(Order order) {
        List<OrderItem> daGiu = new ArrayList<>();
        for (OrderItem oi : order.getChiTiet()) {
            if (tonKhoService.giuHang(oi.getVariant(), oi.getSoLuong())) {
                daGiu.add(oi);
            } else {
                for (OrderItem tra : daGiu) {
                    tonKhoService.traHang(tra.getVariant(), tra.getSoLuong());
                }
                return false;
            }
        }
        return true;
    }

    @Transactional
    public void xacNhanThanhToanGatewayThanhCong(Order order) {
        if (order.getChiTiet() == null) return;

        order.setHanGiuHang(null);
        orderRepo.save(order);

        Cart cart = cartService.layHoacTaoCart(order.getNguoiDung().getEmail());
        List<Integer> variantIds = order.getChiTiet().stream()
                .map(oi -> oi.getVariant().getId())
                .toList();
        List<CartItem> conTrongGio = cartItemRepo.findByCart(cart).stream()
                .filter(ci -> variantIds.contains(ci.getVariant().getId()))
                .toList();
        if (!conTrongGio.isEmpty()) {
            cartItemRepo.deleteAll(conTrongGio);
        }

        thongBaoDaThanhToan(order);
    }

    /** Dùng chung cho cả xác nhận tự động (Stripe) lẫn admin xác nhận thủ công (chuyển khoản,
     * xem xacNhanThanhToan) — báo "đã thanh toán" trong web + gửi mail + cộng Xu CT. */
    private void thongBaoDaThanhToan(Order order) {
        OrderStatusLog log = new OrderStatusLog();
        log.setOrder(order);
        log.setTrangThai("paid");
        log.setGhiChu("Đã xác nhận thanh toán");
        statusLogRepo.save(log);

        notificationService.taoChoUser(
                order.getNguoiDung().getId(), "payment_confirmed", "Thanh toán thành công",
                "Đơn hàng " + order.getMaDonHang() + " đã được xác nhận thanh toán thành công.",
                "/tai-khoan/don-hang"
        );
        try {
            mailService.sendPaymentConfirmedEmail(order);
        } catch (Exception e) {
            // Không chặn luồng xác nhận thanh toán nếu gửi mail thất bại
        }
        walletService.congXuTuDon(order);
    }

    public List<Order> layDonHangCuaUser(String email) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
        return orderRepo.findByNguoiDungOrderByCreatedAtDesc(user);
    }

    public Order layChiTietDon(Integer orderId, String email) {
        Order order = orderRepo.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));

        if (!order.getNguoiDung().getEmail().equals(email)) {
            throw new RuntimeException("Bạn không có quyền xem đơn hàng này");
        }
        return order;
    }

    public Payment layPaymentCuaDon(Order order) {
        return paymentRepo.findByOrder(order).orElse(null);
    }

    @Transactional
    public void huyDon(Integer orderId, String email) {
        huyDon(orderId, email, null);
    }

    /** lyDoKhach: lý do khách tự nhập khi hủy — không bắt buộc, null/rỗng thì chỉ ghi "Khách hàng
     * hủy đơn" như cũ. Được nối vào ghi chú của OrderStatusLog nên hiển thị luôn ở timeline đơn
     * hàng hiện có (OrderApiController#detail / admin Orders.vue), không cần thêm chỗ hiển thị mới. */
    @Transactional
    public void huyDon(Integer orderId, String email, String lyDoKhach) {
        Order order = layChiTietDon(orderId, email);

        Payment payment = layPaymentCuaDon(order);
        if (payment != null && "paid".equals(payment.getStatus())) {
            throw new RuntimeException("Đơn hàng đã thanh toán, không thể tự hủy. Vui lòng liên hệ hỗ trợ.");
        }

        // Khoá huỷ từ lúc hàng bắt đầu rời kho. "shipped" trở đi thì hàng đã ở ngoài đường,
        // bấm huỷ không làm nó quay lại được — đường đi đúng là từ chối nhận, hàng về kho rồi
        // admin chuyển sang "Hoàn hàng" (xem capNhatTrangThai).
        if (!"pending".equals(order.getTrangThai()) && !"confirmed".equals(order.getTrangThai())) {
            if ("shipped".equals(order.getTrangThai())) {
                throw new RuntimeException("Đơn đang trên đường giao nên không huỷ được. Bạn có thể "
                        + "từ chối nhận hàng khi shipper tới, hoặc gọi 0835 344 974 để được hỗ trợ.");
            }
            throw new RuntimeException("Đơn hàng đang ở trạng thái \""
                    + nhanTrangThaiDon(order.getTrangThai()) + "\", không thể huỷ.");
        }

        String ghiChu = (lyDoKhach == null || lyDoKhach.isBlank())
                ? "Khách hàng hủy đơn"
                : "Khách hàng hủy đơn: " + lyDoKhach.trim();
        huyDonNoiBo(order, ghiChu);
    }

    /** Logic huỷ đơn dùng chung cho khách tự huỷ (huyDon) và tự động huỷ khi hết hạn giữ hàng
     * 24h (huyDonHetHanThanhToan) — tách riêng để không lặp lại phần hoàn kho. */
    private void huyDonNoiBo(Order order, String ghiChu) {
        // Trả hàng về kho vô điều kiện: từ nay MỌI đơn đều đã trừ kho ngay lúc tạo (kể cả đơn
        // qua cổng redirect chưa trả tiền — xem datHangTuGioHang), nên không còn trường hợp
        // "chưa từng trừ kho" để phải phân biệt.
        for (OrderItem oi : order.getChiTiet()) {
            tonKhoService.traHang(oi.getVariant(), oi.getSoLuong());
        }

        order.setTrangThai("cancelled");
        order.setHanGiuHang(null);
        orderRepo.save(order);

        OrderStatusLog log = new OrderStatusLog();
        log.setOrder(order);
        log.setTrangThai("cancelled");
        log.setGhiChu(ghiChu);
        statusLogRepo.save(log);

        // Đơn có trừ xu (đổi quà, hoặc dùng xu giảm giá lúc thanh toán) mà bị huỷ -> hoàn lại,
        // không làm gì nếu đơn chưa từng trừ xu nào.
        walletService.hoanXuNeuDonBiHuy(order);
        // Tín dụng thu cũ cũng phải trả lại — đây là tiền shop nợ khách, huỷ đơn không được nuốt.
        tradeInService.hoanTinDungNeuDonBiHuy(order.getId(), order.getTradeInCreditId());
        // Tương tự: hoàn lại lượt free ship liên tỉnh của gói hội viên nếu đơn đã tiêu.
        subscriptionService.hoanLuotTheoDon(order);
    }

    /**
     * Quét mỗi phút: đơn qua cổng redirect đã hết hạn GIỮ HÀNG (PHUT_GIU_HANG_THANH_TOAN phút)
     * mà vẫn chưa thanh toán -> huỷ đơn, TRẢ HÀNG VỀ KHO để người khác mua được.
     *
     * Đây là vế thứ hai của việc trừ kho ngay lúc tạo đơn (xem datHangTuGioHang): giữ hàng cho
     * người đang thanh toán là đúng, nhưng giữ mãi thì một khách bỏ dở đủ để món hàng "tạm hết
     * hàng" vĩnh viễn. Nhịp 1 phút để hàng quay lại kệ gần như ngay khi hết hạn — khác hẳn
     * huyDonHetHanThanhToan bên dưới (mốc 24h cho chuyển khoản, quét 30 phút/lần là đủ).
     */
    @Scheduled(fixedRate = 60 * 1000)
    @Transactional
    public void giaiPhongDonHetHanGiuHang() {
        List<Order> ungVien = orderRepo.findByTrangThaiAndHanGiuHangNotNullAndHanGiuHangBefore(
                "pending", LocalDateTime.now());

        for (Order order : ungVien) {
            Payment payment = layPaymentCuaDon(order);
            // Đã trả tiền xong nhưng callback về muộn hơn lúc quét -> chỉ gỡ đồng hồ, giữ đơn.
            if (payment != null && "paid".equals(payment.getStatus())) {
                order.setHanGiuHang(null);
                orderRepo.save(order);
                continue;
            }

            huyDonNoiBo(order, "Tự động huỷ do quá " + PHUT_GIU_HANG_THANH_TOAN
                    + " phút chưa hoàn tất thanh toán — hàng đã được trả lại kho");

            if (payment != null) {
                payment.setStatus("failed");
                paymentRepo.save(payment);
            }

            notificationService.taoChoUser(
                    order.getNguoiDung().getId(), "order_expired",
                    "Đơn hàng " + order.getMaDonHang() + " đã hết hạn giữ hàng",
                    "Đơn của bạn bị huỷ do chưa thanh toán trong " + PHUT_GIU_HANG_THANH_TOAN
                            + " phút. Hàng đã được trả lại kho, bạn có thể đặt lại nếu vẫn còn hàng.",
                    "/tai-khoan/don-hang"
            );
        }
    }

    /** Quét định kỳ mỗi 30 phút: đơn "pending" quá GIO_GIU_HANG_CHO_THANH_TOAN giờ mà vẫn chưa
     * thanh toán (chuyển khoản chưa được admin đối soát, hoặc Stripe bị bỏ dở giữa chừng) thì tự
     * động huỷ, hoàn kho, báo cho khách. COD không nằm trong diện này (xem
     * GIO_GIU_HANG_CHO_THANH_TOAN javadoc) vì luôn được lọc ra ở vòng lặp bên dưới. */
    @Scheduled(fixedRate = 30 * 60 * 1000)
    @Transactional
    public void huyDonHetHanThanhToan() {
        LocalDateTime cutoff = LocalDateTime.now().minusHours(GIO_GIU_HANG_CHO_THANH_TOAN);
        List<Order> ungVien = orderRepo.findByTrangThaiAndCreatedAtBefore("pending", cutoff);

        for (Order order : ungVien) {
            Payment payment = layPaymentCuaDon(order);
            if (payment == null || "cod".equals(payment.getPaymentMethod().getCode())) continue;
            if ("paid".equals(payment.getStatus())) continue;

            huyDonNoiBo(order, "Tự động hủy do quá " + GIO_GIU_HANG_CHO_THANH_TOAN + " giờ chưa hoàn tất thanh toán");

            payment.setStatus("failed");
            paymentRepo.save(payment);

            notificationService.taoChoUser(
                    order.getNguoiDung().getId(), "order_expired",
                    "Đơn hàng " + order.getMaDonHang() + " đã hết hạn",
                    "Đơn hàng của bạn đã bị hủy do chưa hoàn tất thanh toán trong vòng "
                            + GIO_GIU_HANG_CHO_THANH_TOAN + " giờ.",
                    "/tai-khoan/don-hang"
            );
            try {
                mailService.sendOrderExpiredEmail(order);
            } catch (Exception e) {
                // Không chặn tác vụ quét nếu gửi mail thất bại
            }
        }
    }

    public List<Order> layTatCaDon() {
        return orderRepo.findAllByOrderByCreatedAtDesc();
    }

    public List<Order> layDonTheoTrangThai(String trangThai) {
        return orderRepo.findByTrangThaiOrderByCreatedAtDesc(trangThai);
    }

    public Order layDonById(Integer id) {
        return orderRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng #" + id));
    }

    @Transactional
    public void capNhatTrangThai(Integer orderId, String trangThaiMoi, String ghiChu) {
        Order order = layDonById(orderId);
        String trangThaiCu = order.getTrangThai();

        // "delivered" KHÔNG còn nằm trong danh sách khoá: khách vẫn có thể trả hàng sau khi đã
        // nhận (đổi trả 7 ngày), lúc đó đơn phải đi tiếp sang "returned". Chỉ hai trạng thái
        // thật sự đóng sổ mới cấm sửa.
        if (TRANG_THAI_KET_THUC.contains(trangThaiCu)) {
            throw new RuntimeException("Đơn đã " + nhanTrangThaiDon(trangThaiCu).toLowerCase()
                    + ", không thể đổi trạng thái nữa.");
        }

        kiemTraChuyenTrangThaiHopLe(trangThaiCu, trangThaiMoi);

        if ("cancelled".equals(trangThaiMoi)) {
            // Trả hàng về kho vô điều kiện — mọi đơn đều đã trừ kho ngay lúc tạo (xem
            // datHangTuGioHang), không còn trường hợp "chưa từng trừ kho" để phải phân biệt.
            // Hàm này không đi qua huyDonNoiBo vì admin có thể set thẳng trạng thái "cancelled"
            // từ bất kỳ trạng thái hợp lệ nào, không chỉ pending/confirmed.
            for (OrderItem oi : order.getChiTiet()) {
                tonKhoService.traHang(oi.getVariant(), oi.getSoLuong());
            }
            order.setHanGiuHang(null);

            // Đơn có trừ xu (đổi quà, xem RedemptionService.doiQua — hoặc dùng xu giảm giá
            // ngay lúc thanh toán, xem datHangTuGioHang) mà bị huỷ -> hoàn lại xu đã trừ,
            // không để khách mất xu mà không nhận được gì. Không làm gì nếu đơn chưa từng
            // trừ xu nào (kiểm tra bên trong hoanXuNeuDonBiHuy).
            walletService.hoanXuNeuDonBiHuy(order);
            // Hoàn lượt free ship liên tỉnh của gói hội viên nếu đơn đã tiêu.
            subscriptionService.hoanLuotTheoDon(order);
        }

        // HOÀN HÀNG = hàng vật lý đã quay về kho -> cộng lại tồn ở ĐÂY, không phải ở "refunded".
        // Trước đây chỉ có "refunded" nên hai việc khác hẳn nhau (hàng về kho / tiền về túi
        // khách) bị gộp làm một; giờ tách ra thì mỗi việc phải nằm đúng chỗ của nó, và cộng kho
        // hai lần cho cùng một đơn (returned rồi refunded) là dư hàng ảo.
        if ("returned".equals(trangThaiMoi)) {
            // Có thể khách đã gửi yêu cầu đổi trả riêng cho đúng món này và CSKH đã duyệt —
            // luồng đó tự cộng kho rồi (ReturnRequestService.hoanTonKho). Cộng thêm lần nữa ở
            // đây là dư hàng ảo, nên trừ ra phần đã được cộng.
            Map<Integer, Integer> daCong = new HashMap<>();
            for (com.fpoly.model.ReturnRequest r : returnRequestRepo.findDaHoanKhoTheoDon(order.getId())) {
                if (r.getVariant() == null) continue;
                int sl = r.getSoLuong() != null && r.getSoLuong() > 0 ? r.getSoLuong() : 1;
                daCong.merge(r.getVariant().getId(), sl, Integer::sum);
            }
            for (OrderItem oi : order.getChiTiet()) {
                int conPhaiCong = oi.getSoLuong() - daCong.getOrDefault(oi.getVariant().getId(), 0);
                if (conPhaiCong > 0) tonKhoService.traHang(oi.getVariant(), conPhaiCong);
            }
            // Khách trả hàng thì các ưu đãi đã tiêu cho đơn cũng phải trả lại.
            walletService.hoanXuNeuDonBiHuy(order);
            tradeInService.hoanTinDungNeuDonBiHuy(order.getId(), order.getTradeInCreditId());
            subscriptionService.hoanLuotTheoDon(order);
        }

        order.setTrangThai(trangThaiMoi);
        orderRepo.save(order);

        if ("delivered".equals(trangThaiMoi)) {
            warrantyService.createWarranty(order);

            Payment payment = layPaymentCuaDon(order);
            if (payment != null && "pending".equals(payment.getStatus())
                    && "cod".equals(payment.getPaymentMethod().getCode())) {
                payment.setStatus("paid");
                payment.setPaidAt(LocalDateTime.now());
                paymentRepo.save(payment);
                // COD trả tiền khi giao nên không đi qua thongBaoDaThanhToan (tránh trùng với
                // thông báo "order_status" gửi ngay bên dưới) — nhưng vẫn phải cộng xu.
                walletService.congXuTuDon(order);
            }
        }

        // Nhảy cọc: ghi bù các mốc bị bỏ qua TRƯỚC dòng mốc đích, để timeline vẫn đúng thứ tự.
        ghiNhatKyCacMocBoQua(order, trangThaiCu, trangThaiMoi);

        OrderStatusLog log = new OrderStatusLog();
        log.setOrder(order);
        log.setTrangThai(trangThaiMoi);
        log.setGhiChu(ghiChu);
        statusLogRepo.save(log);

        guiThongBaoVaMailTheoTrangThai(order, trangThaiMoi);
    }

    /**
     * CHUỖI XỬ LÝ CHÍNH của một đơn, theo đúng thứ tự thực tế hàng đi qua.
     *
     * Ý nghĩa từng mốc (xem thêm MO_TA_TRANG_THAI — nội dung này được trả cho admin-vue để
     * hiện ngay cạnh ô chọn trạng thái, tránh mỗi người hiểu một kiểu):
     *   pending    Đơn vừa tạo, chưa ai xác nhận.
     *   confirmed  Shop đã nhận đơn, cam kết có hàng.
     *   processing Đang soạn/đóng gói, HÀNG VẪN CÒN TRONG KHO.
     *   shipped    Đã bàn giao vận chuyển — hàng đang trên đường, không còn nằm trong tay shop.
     *   delivered  Khách đã nhận, đơn kết thúc bình thường.
     */
    private static final List<String> CHUOI_XU_LY =
            List.of("pending", "confirmed", "processing", "shipped", "delivered");

    /** Chỉ số của trạng thái trong chuỗi chính; -1 nếu là trạng thái kết thúc bất thường. */
    private static int viTriTrongChuoi(String trangThai) {
        return CHUOI_XU_LY.indexOf(trangThai);
    }

    /**
     * Các nhánh RỜI khỏi chuỗi chính, khai riêng vì chúng không đi theo thứ tự tiến dần:
     *   cancelled  Huỷ đơn — CHỈ khi hàng còn trong kho (pending/confirmed/processing). Từ
     *              "shipped" trở đi hàng đã ở ngoài, "huỷ" là vô nghĩa: hàng vẫn đang đi, phải
     *              đợi kết quả giao rồi mới xử lý tiếp bằng "returned".
     *   returned   Hàng đã QUAY VỀ kho shop (khách từ chối nhận, hoặc trả lại sau khi nhận).
     *              Tiền chưa trả. Chỉ có nghĩa khi hàng từng rời kho.
     *   refunded   Đã chuyển tiền lại cho khách. Chỉ tới được SAU khi hàng đã về (returned) —
     *              không ai hoàn tiền khi hàng còn ở đâu đó ngoài đường.
     */
    private static final Map<String, List<String>> NHANH_NGOAI_CHUOI = Map.of(
            "pending",    List.of("cancelled"),
            "confirmed",  List.of("cancelled"),
            "processing", List.of("cancelled"),
            "shipped",    List.of("returned"),
            "delivered",  List.of("returned"),
            "returned",   List.of("refunded")
    );

    /** Trạng thái đã đóng sổ — không đổi đi đâu được nữa. */
    private static final List<String> TRANG_THAI_KET_THUC = List.of("cancelled", "refunded");

    /** Mô tả ngắn gọn từng trạng thái, trả cho admin-vue hiển thị cạnh ô chọn. */
    public static final Map<String, String> MO_TA_TRANG_THAI = Map.of(
            "pending",    "Đơn vừa tạo, chưa ai xác nhận. Khách vẫn tự huỷ được.",
            "confirmed",  "Shop đã nhận đơn và cam kết có hàng. Chưa đóng gói.",
            "processing", "Đang soạn/đóng gói. Hàng vẫn còn trong kho, vẫn huỷ được.",
            "shipped",    "Đã bàn giao vận chuyển, hàng đang trên đường. TỪ ĐÂY KHÔNG HUỶ ĐƯỢC — nếu khách từ chối nhận thì chuyển sang Hoàn hàng.",
            "delivered",  "Khách đã nhận hàng. Đơn kết thúc bình thường, phiếu bảo hành được tạo.",
            "cancelled",  "Huỷ trước khi hàng rời kho. Hàng đã trả lại kho, xu/tín dụng đã hoàn.",
            "returned",   "Hàng đã quay về kho shop. TIỀN CHƯA TRẢ — chuyển sang Hoàn tiền sau khi đã chuyển khoản cho khách.",
            "refunded",   "Đã chuyển tiền lại cho khách. Đơn đóng sổ."
    );

    /**
     * Kiểm tra một bước chuyển trạng thái, cho phép NHẢY CỌC tiến về phía trước.
     *
     * Trước đây bắt đi từng bước một: đơn giao ngay trong ngày vẫn phải bấm lần lượt
     * confirmed -> processing -> shipped -> delivered, bốn lần bấm cho một việc. Nay admin
     * nhảy thẳng tới mốc thật sự đang đúng cũng được — nhưng LỊCH SỬ VẪN GHI ĐỦ các mốc bị
     * bỏ qua (xem ghiNhatKyCacMocBoQua), nên timeline đơn hàng khách nhìn thấy không có lỗ hổng.
     *
     * Vẫn cấm ĐI LÙI (delivered -> processing) vì lịch sử đơn phải là một chiều: hàng đã giao
     * rồi thì không thể "đang đóng gói" trở lại.
     */
    private void kiemTraChuyenTrangThaiHopLe(String hienTai, String moi) {
        if (hienTai.equals(moi)) {
            throw new RuntimeException("Đơn hàng đã ở trạng thái " + nhanTrangThaiDon(moi));
        }
        if (!MO_TA_TRANG_THAI.containsKey(moi)) {
            throw new RuntimeException("Trạng thái không hợp lệ: " + moi);
        }
        if (NHANH_NGOAI_CHUOI.getOrDefault(hienTai, List.of()).contains(moi)) {
            return;
        }

        int tu = viTriTrongChuoi(hienTai);
        int den = viTriTrongChuoi(moi);
        if (tu >= 0 && den > tu) {
            return; // tiến tới bất kỳ mốc nào phía sau trong chuỗi chính
        }

        if (tu >= 0 && den >= 0) {
            throw new RuntimeException("Không thể lùi đơn từ \"" + nhanTrangThaiDon(hienTai)
                    + "\" về \"" + nhanTrangThaiDon(moi) + "\". Trạng thái đơn chỉ đi một chiều.");
        }
        if ("cancelled".equals(moi)) {
            throw new RuntimeException("Đơn đã bàn giao vận chuyển thì không huỷ được nữa. "
                    + "Nếu khách từ chối nhận, chuyển sang \"Hoàn hàng\" khi hàng đã về kho.");
        }
        throw new RuntimeException("Không thể chuyển đơn từ \"" + nhanTrangThaiDon(hienTai)
                + "\" sang \"" + nhanTrangThaiDon(moi) + "\".");
    }

    /**
     * Các trạng thái admin ĐƯỢC PHÉP chuyển sang từ trạng thái hiện tại, kèm mô tả — admin-vue
     * dùng để chỉ hiện đúng những lựa chọn hợp lệ thay vì liệt kê hết rồi để backend từ chối.
     * Trả về danh sách rỗng nếu đơn đã đóng sổ.
     */
    public List<Map<String, String>> trangThaiChoPhep(String hienTai) {
        if (TRANG_THAI_KET_THUC.contains(hienTai)) return List.of();
        List<String> ma = new ArrayList<>();
        int tu = viTriTrongChuoi(hienTai);
        if (tu >= 0) {
            for (int i = tu + 1; i < CHUOI_XU_LY.size(); i++) ma.add(CHUOI_XU_LY.get(i));
        }
        ma.addAll(NHANH_NGOAI_CHUOI.getOrDefault(hienTai, List.of()));

        List<Map<String, String>> ra = new ArrayList<>();
        for (String m : ma) {
            ra.add(Map.of("value", m, "label", nhanTrangThaiDon(m),
                    "hint", MO_TA_TRANG_THAI.getOrDefault(m, "")));
        }
        return ra;
    }

    /** Nhãn + mô tả của trạng thái hiện tại, để admin-vue giải thích ngay đơn đang ở đâu. */
    public Map<String, String> moTaTrangThai(String trangThai) {
        return Map.of("value", trangThai, "label", nhanTrangThaiDon(trangThai),
                "hint", MO_TA_TRANG_THAI.getOrDefault(trangThai, ""));
    }

    /**
     * Ghi vào lịch sử các mốc bị NHẢY CỌC bỏ qua, để timeline đơn hàng không mất mắt xích.
     *
     * VD admin đang ở "confirmed" nhảy thẳng tới "delivered": lịch sử vẫn có dòng "Đang xử lý"
     * và "Đang giao", kèm ghi chú nói rõ đây là mốc suy ra chứ không phải admin bấm từng bước —
     * khách xem timeline thấy đủ hành trình, còn shop truy lại vẫn biết sự thật.
     */
    private void ghiNhatKyCacMocBoQua(Order order, String tuTrangThai, String denTrangThai) {
        int tu = viTriTrongChuoi(tuTrangThai);
        int den = viTriTrongChuoi(denTrangThai);
        if (tu < 0 || den < 0) return;
        for (int i = tu + 1; i < den; i++) {
            OrderStatusLog log = new OrderStatusLog();
            log.setOrder(order);
            log.setTrangThai(CHUOI_XU_LY.get(i));
            log.setGhiChu("Tự ghi nhận khi đơn được cập nhật thẳng sang \""
                    + nhanTrangThaiDon(denTrangThai) + "\"");
            statusLogRepo.save(log);
        }
    }

    // Mã tuỳ chọn giao nội thành Hải Phòng (ShippingService) — còn lại là mã hãng vận chuyển
    // liên tỉnh (CARRIER) — dùng để đổi nội dung thông báo cho phù hợp (mail xem MailService).
    private static final List<String> MA_TUY_CHON_NOI_THANH = List.of("hoa_toc", "thuong");

    /** Mail + thông báo riêng cho từng mốc trạng thái (pending đã gửi lúc đặt hàng, xem
     * datHangTuGioHang) — cancelled/refunded giữ thông báo chung như trước, không có mail riêng. */
    private void guiThongBaoVaMailTheoTrangThai(Order order, String trangThai) {
        String tieuDe;
        String noiDung;

        switch (trangThai) {
            case "confirmed" -> {
                tieuDe = "Đơn hàng " + order.getMaDonHang() + " đã được xác nhận";
                noiDung = "Đơn hàng của bạn đã được xác nhận và đang được chuẩn bị.";
                try {
                    mailService.sendOrderConfirmedEmail(order);
                } catch (Exception e) {
                    // Không chặn luồng cập nhật trạng thái nếu gửi mail thất bại
                }
            }
            case "processing" -> {
                tieuDe = "Đơn hàng " + order.getMaDonHang() + " đang được đóng gói";
                noiDung = "Đơn hàng của bạn đang được đóng gói để chuẩn bị giao đi.";
                try {
                    mailService.sendOrderProcessingEmail(order);
                } catch (Exception e) {
                    // Không chặn luồng cập nhật trạng thái nếu gửi mail thất bại
                }
            }
            case "shipped" -> {
                boolean noiThanh = order.getMaTuyChonGiaoHang() != null
                        && MA_TUY_CHON_NOI_THANH.contains(order.getMaTuyChonGiaoHang());
                tieuDe = "Đơn hàng " + order.getMaDonHang() + " đang được giao";
                noiDung = noiThanh
                        ? "Đơn hàng của bạn đang được giao đi, dự kiến " + order.getThoiGianGiaoDuKienHienThi() + "."
                        : "Đơn hàng của bạn đã bàn giao cho " + order.getNhanTuyChonGiaoHangHienThi()
                                + ", dự kiến giao " + order.getThoiGianGiaoDuKienHienThi() + ".";
                try {
                    mailService.sendOrderShippedEmail(order);
                } catch (Exception e) {
                    // Không chặn luồng cập nhật trạng thái nếu gửi mail thất bại
                }
            }
            case "delivered" -> {
                tieuDe = "Đơn hàng " + order.getMaDonHang() + " đã giao thành công";
                noiDung = "Đơn hàng đã giao thành công. Đánh giá ngay để chia sẻ trải nghiệm của bạn (còn 14 ngày).";
                try {
                    mailService.sendOrderDeliveredEmail(order);
                } catch (Exception e) {
                    // Không chặn luồng cập nhật trạng thái nếu gửi mail thất bại
                }
            }
            // Hai mốc mới sau khi tách "hoàn hàng" khỏi "hoàn tiền" — phải nói rõ đang ở khâu
            // nào, vì trước đây khách nhận thông báo "đã hoàn tiền" ngay lúc mới trả hàng.
            case "returned" -> {
                tieuDe = "Đơn hàng " + order.getMaDonHang() + " đã được hoàn về shop";
                noiDung = "Shop đã nhận lại hàng của đơn này và đang kiểm tra. Tiền sẽ được hoàn "
                        + "sau khi kiểm hàng xong, bạn sẽ nhận thông báo riêng khi tiền được chuyển.";
            }
            case "refunded" -> {
                tieuDe = "Đơn hàng " + order.getMaDonHang() + " đã được hoàn tiền";
                noiDung = "Shop đã hoàn tiền cho đơn này. Tuỳ ngân hàng, tiền có thể về tài khoản "
                        + "của bạn sau 1–3 ngày làm việc.";
            }
            default -> {
                tieuDe = "Đơn hàng " + order.getMaDonHang() + " cập nhật trạng thái";
                noiDung = "Đơn hàng của bạn hiện: " + nhanTrangThaiDon(trangThai);
            }
        }

        notificationService.taoChoUser(
                order.getNguoiDung().getId(),
                "delivered".equals(trangThai) ? "order_delivered_review" : "order_status",
                tieuDe, noiDung,
                "delivered".equals(trangThai)
                        ? "/tai-khoan/don-hang/" + order.getId() + "/danh-gia"
                        : "/tai-khoan/don-hang"
        );
    }

    private String nhanTrangThaiDon(String status) {
        return switch (status) {
            case "pending" -> "Chờ xác nhận";
            case "confirmed" -> "Đã xác nhận";
            case "processing" -> "Đang xử lý";
            case "shipped" -> "Đang giao";
            case "delivered" -> "Hoàn tất";
            case "cancelled" -> "Đã hủy";
            case "returned" -> "Hoàn hàng";
            case "refunded" -> "Đã hoàn tiền";
            default -> status;
        };
    }

    /** Admin xác nhận đã nhận được tiền (COD thu hộ / chuyển khoản đã đối soát). */
    @Transactional
    public void xacNhanThanhToan(Integer orderId) {
        Order order = layDonById(orderId);
        Payment payment = layPaymentCuaDon(order);
        if (payment == null) {
            throw new RuntimeException("Đơn hàng chưa có thông tin thanh toán");
        }
        payment.setStatus("paid");
        payment.setPaidAt(LocalDateTime.now());
        paymentRepo.save(payment);

        thongBaoDaThanhToan(order);
    }

    /**
     * Admin nhập mã vận đơn (order_code GHN, hoặc tracking_number Shopee Express) sau khi đã
     * bàn giao hàng vật lý cho hãng — gọi ở trang admin/orders khi bấm "Bàn giao vận chuyển".
     *
     * Với Shopee Express: tự động tạo tracking trên AfterShip ngay lúc này, lưu lại
     * afterShipTrackingId để các lần gọi API sau (get/update/delete) dùng đúng id nội bộ.
     *
     * Với GHN: chỉ cần lưu order_code, KHÔNG cần gọi API tạo gì thêm — API "lấy chi tiết đơn"
     * dùng thẳng order_code này (xem GhnApiService.layChiTietDon).
     *
     * Với GHTK/Viettel Post: chưa có API tracking, chỉ lưu mã để admin xem thủ công trên trang
     * quản lý của hãng đó — không tạo tracking tự động gì ở bước này.
     */
    @Transactional
    public void banGiaoVanChuyen(Integer orderId, String maVanDonNgoai) {
        Order order = layDonById(orderId);

        if (order.laDonTaiQuay()) {
            throw new RuntimeException("Đơn bán tại quầy không có bước bàn giao vận chuyển");
        }
        if (maVanDonNgoai == null || maVanDonNgoai.isBlank()) {
            throw new RuntimeException("Vui lòng nhập mã vận đơn");
        }

        order.setMaVanDonNgoai(maVanDonNgoai.trim());

        String carrierCode = order.getMaTuyChonGiaoHang();
        if ("spx".equalsIgnoreCase(carrierCode) || "shopee_express".equalsIgnoreCase(carrierCode)) {
            afterShipApiService.taoTracking(maVanDonNgoai.trim(), order.getMaDonHang())
                    .ifPresentOrElse(
                            tracking -> order.setAfterShipTrackingId(tracking.id()),
                            () -> {
                                // Không throw — mã vận đơn vẫn lưu được, chỉ là chưa tạo tracking
                                // tự động. Admin có thể thử lại sau (AfterShip có thể đang lỗi tạm thời).
                            }
                    );
        }

        orderRepo.save(order);
    }
}