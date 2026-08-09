package com.fpoly.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
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

    // Chỉ dùng khi địa chỉ chưa có Phường chuẩn hoá (tạo qua trang Thymeleaf cũ) hoặc không có
    // mã tuỳ chọn giao hàng — xem ShippingService cho luồng tính phí thật theo Phường.
    private static final BigDecimal PHI_VAN_CHUYEN_MAC_DINH = new BigDecimal("30000");

    /** Số giờ giữ hàng chờ thanh toán trước khi tự động huỷ (chuyển khoản / thẻ Stripe chưa
     * thanh toán) — không áp dụng cho COD vì COD vốn chỉ thu tiền khi giao, không phải "chưa
     * thanh toán" theo nghĩa cần giữ hàng chờ. Xem huyDonHetHanThanhToan(). */
    private static final long GIO_GIU_HANG_CHO_THANH_TOAN = 24;

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
     * null = fallback phí cố định (địa chỉ Thymeleaf cũ chưa có Phường chuẩn hoá). */
    @Transactional
    public Order datHangTuGioHang(String email, Integer addressId, String paymentMethodCode, List<Integer> cartItemIds,
                                   String maCoupon, Integer soXuMuonDung, String maTuyChonGiaoHang) {
        return datHangTuGioHang(email, addressId, paymentMethodCode, cartItemIds, maCoupon,
                soXuMuonDung, maTuyChonGiaoHang, null);
    }

    /** tradeInCreditId = tín dụng thu cũ dùng cho đơn này. Trừ SAU coupon/hạng/xu và ghi vào cột
     * riêng (Order.tienThuCu), không gộp vào tienGiamGia — kế toán cần tách bạch giảm giá khuyến
     * mãi với tiền shop trả khách để mua lại máy cũ. */
    @Transactional
    public Order datHangTuGioHang(String email, Integer addressId, String paymentMethodCode, List<Integer> cartItemIds,
                                   String maCoupon, Integer soXuMuonDung, String maTuyChonGiaoHang,
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

        com.fpoly.model.Coupon coupon = null;
        if (maCoupon != null && !maCoupon.isBlank()) {
            coupon = couponService.layCouponHopLe(maCoupon, tienHang);
            tienGiamGia = tienGiamGia.add(couponService.tinhGiamGia(coupon, tienHang));
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
        order.setDiaChiGiao(address);
        order.setTienHang(tienHang);
        order.setTienGiamGia(tienGiamGia);
        order.setPhiVanChuyen(phiVanChuyen);
        order.setTongTien(tongTien);
        order.setTienThuCu(tienThuCu);
        order.setTradeInCreditId(tinDung == null ? null : tinDung.getId());
        order.setTrangThai("pending");
        order.setCouponId(coupon != null ? coupon.getId() : null);
        if (tuyChonGiaoHang != null) {
            order.setMaTuyChonGiaoHang(tuyChonGiaoHang.code());
            order.setNhanTuyChonGiaoHang(tuyChonGiaoHang.label());
            order.setThoiGianGiaoDuKien(tuyChonGiaoHang.eta());
        }
        // Chụp lại toạ độ điểm giao + quãng đường đã dùng để tính phí — khách sửa/xoá địa chỉ
        // sau khi đặt thì admin vẫn thấy đúng nơi phải giao và đối chiếu được phí ship của đơn.
        order.setViDoGiao(address.getLatitude());
        order.setKinhDoGiao(address.getLongitude());
        order.setKhoangCachGiaoKm(khoangCachGiao);

        // Đơn qua cổng redirect (Stripe) chỉ thực sự "chốt" khi thanh toán thành công (callback
        // /payment/stripe/return hoặc webhook) — trừ kho + xoá giỏ ngay bây giờ là sai nếu khách
        // huỷ/đóng trang giữa chừng. COD/chuyển khoản thì chốt ngay vì không có bước redirect.
        boolean choTraSauKhiThanhToan = laCongThanhToanRedirect(paymentMethodCode);

        List<OrderItem> chiTiet = new ArrayList<>();
        for (CartItem ci : items) {
            ProductVariant v = ci.getVariant();

            OrderItem oi = new OrderItem();
            oi.setOrder(order);
            oi.setVariant(v);
            oi.setTenSanPham(v.getProduct().getName());
            oi.setThongTinPhienBan(v.getSku());
            oi.setDonGia(v.getPrice());
            oi.setSoLuong(ci.getSoLuong());

            chiTiet.add(oi);

            if (!choTraSauKhiThanhToan) {
                v.setStock(v.getStock() - ci.getSoLuong());
            }
        }
        order.setChiTiet(chiTiet);

        Order saved = orderRepo.save(order);

        if (coupon != null) {
            couponService.danhDauDaDung(coupon);
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
            notificationService.taoChoUser(
                    user.getId(), "order_awaiting_payment", "Đơn hàng đang chờ thanh toán",
                    "Đơn hàng " + saved.getMaDonHang() + " đã được ghi nhận nhưng CHƯA hoàn tất thanh toán. Vui lòng thanh toán trong vòng "
                            + GIO_GIU_HANG_CHO_THANH_TOAN + " giờ, nếu không đơn sẽ tự động bị huỷ và hàng được giải phóng.",
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

    /** Gọi khi cổng thanh toán redirect (Stripe) báo thành công (return hoặc webhook, xem
     * StripeController) — lúc này mới thật sự trừ kho + xoá các dòng giỏ hàng tương ứng (đã cố
     * tình chưa làm ở lúc tạo đơn, xem datHangTuGioHang) để khách không mất hàng trong giỏ nếu
     * huỷ/đóng trang giữa chừng, đồng thời gửi thông báo/mail xác nhận đã thanh toán. */
    @Transactional
    public void xacNhanThanhToanGatewayThanhCong(Order order) {
        if (order.getChiTiet() == null) return;

        for (OrderItem oi : order.getChiTiet()) {
            ProductVariant v = oi.getVariant();
            v.setStock(v.getStock() - oi.getSoLuong());
        }

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

        if (!"pending".equals(order.getTrangThai()) && !"confirmed".equals(order.getTrangThai())) {
            throw new RuntimeException("Đơn hàng đang ở trạng thái không thể hủy");
        }

        String ghiChu = (lyDoKhach == null || lyDoKhach.isBlank())
                ? "Khách hàng hủy đơn"
                : "Khách hàng hủy đơn: " + lyDoKhach.trim();
        huyDonNoiBo(order, ghiChu);
    }

    /** Logic huỷ đơn dùng chung cho khách tự huỷ (huyDon) và tự động huỷ khi hết hạn giữ hàng
     * 24h (huyDonHetHanThanhToan) — tách riêng để không lặp lại phần hoàn kho. */
    private void huyDonNoiBo(Order order, String ghiChu) {
        Payment payment = layPaymentCuaDon(order);

        // Đơn qua cổng redirect (Stripe) chưa thanh toán (payment khác "paid" — đơn "paid" đã
        // bị chặn hủy trước khi gọi tới đây) thì chưa từng bị trừ kho lúc tạo đơn (xem
        // datHangTuGioHang), nên không được cộng lại ở đây kẻo dư kho ảo.
        boolean tungTruKho = payment == null || !laCongThanhToanRedirect(payment.getPaymentMethod().getCode());
        if (tungTruKho) {
            for (OrderItem oi : order.getChiTiet()) {
                ProductVariant v = oi.getVariant();
                v.setStock(v.getStock() + oi.getSoLuong());
            }
        }

        order.setTrangThai("cancelled");
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

        if ("cancelled".equals(order.getTrangThai()) || "delivered".equals(order.getTrangThai())) {
            throw new RuntimeException("Không thể thay đổi trạng thái của đơn hàng này");
        }

        kiemTraChuyenTrangThaiHopLe(order.getTrangThai(), trangThaiMoi);

        if ("cancelled".equals(trangThaiMoi)) {
            // Đơn qua cổng redirect (Stripe) chưa thanh toán thì chưa từng bị trừ kho lúc tạo
            // đơn (xem datHangTuGioHang) — không được cộng lại kẻo dư kho ảo. Cùng logic với
            // huyDonNoiBo, tách riêng vì hàm này không đi qua huyDonNoiBo (admin có thể set thẳng
            // trạng thái "cancelled" từ bất kỳ trạng thái hợp lệ nào, không chỉ pending/confirmed).
            Payment paymentHienTai = layPaymentCuaDon(order);
            boolean tungTruKho = paymentHienTai == null
                    || !laCongThanhToanRedirect(paymentHienTai.getPaymentMethod().getCode())
                    || "paid".equals(paymentHienTai.getStatus());
            if (tungTruKho) {
                for (OrderItem oi : order.getChiTiet()) {
                    ProductVariant v = oi.getVariant();
                    v.setStock(v.getStock() + oi.getSoLuong());
                }
            }

            // Đơn có trừ xu (đổi quà, xem RedemptionService.doiQua — hoặc dùng xu giảm giá
            // ngay lúc thanh toán, xem datHangTuGioHang) mà bị huỷ -> hoàn lại xu đã trừ,
            // không để khách mất xu mà không nhận được gì. Không làm gì nếu đơn chưa từng
            // trừ xu nào (kiểm tra bên trong hoanXuNeuDonBiHuy).
            walletService.hoanXuNeuDonBiHuy(order);
            // Hoàn lượt free ship liên tỉnh của gói hội viên nếu đơn đã tiêu.
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

        OrderStatusLog log = new OrderStatusLog();
        log.setOrder(order);
        log.setTrangThai(trangThaiMoi);
        log.setGhiChu(ghiChu);
        statusLogRepo.save(log);

        guiThongBaoVaMailTheoTrangThai(order, trangThaiMoi);
    }

    /** Trạng thái kế tiếp hợp lệ cho từng trạng thái hiện tại. Trước đây admin set thẳng được
     * pending -> delivered, bỏ qua cả shipped: đơn tự nhận là đã giao trong khi chưa từng rời
     * kho, đồng thời tạo phiếu bảo hành + tự đánh dấu COD đã thu tiền. Huỷ thì cho phép từ bất
     * kỳ trạng thái chưa kết thúc nào (hàng có thể hỏng/khách đổi ý ở mọi khâu). */
    private static final Map<String, List<String>> CHUYEN_TRANG_THAI_HOP_LE = Map.of(
            "pending",    List.of("confirmed", "cancelled"),
            "confirmed",  List.of("processing", "cancelled"),
            "processing", List.of("shipped", "cancelled"),
            "shipped",    List.of("delivered", "cancelled", "refunded")
    );

    private void kiemTraChuyenTrangThaiHopLe(String hienTai, String moi) {
        if (hienTai.equals(moi)) {
            throw new RuntimeException("Đơn hàng đã ở trạng thái " + nhanTrangThaiDon(moi));
        }
        List<String> choPhep = CHUYEN_TRANG_THAI_HOP_LE.getOrDefault(hienTai, List.of());
        if (!choPhep.contains(moi)) {
            throw new RuntimeException("Không thể chuyển đơn từ \"" + nhanTrangThaiDon(hienTai)
                    + "\" sang \"" + nhanTrangThaiDon(moi) + "\". Vui lòng đi theo đúng thứ tự xử lý đơn.");
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
            case "delivered" -> "Đã giao";
            case "cancelled" -> "Đã hủy";
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
}