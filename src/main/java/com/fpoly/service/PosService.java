package com.fpoly.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.PosDtos;
import com.fpoly.dto.PosDtos.PosCouponDto;
import com.fpoly.dto.PosDtos.PosDongHangDto;
import com.fpoly.dto.PosDtos.PosDongHangRequest;
import com.fpoly.dto.PosDtos.PosHoaDonDto;
import com.fpoly.dto.PosDtos.PosKhachDto;
import com.fpoly.dto.PosDtos.PosKhuyenMaiDto;
import com.fpoly.dto.PosDtos.PosProductDto;
import com.fpoly.dto.PosDtos.PosTangKemDto;
import com.fpoly.dto.PosDtos.PosUuDaiDto;
import com.fpoly.dto.PosDtos.PosTaoDonRequest;
import com.fpoly.model.MembershipTier;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.Order;
import com.fpoly.model.OrderItem;
import com.fpoly.model.OrderStatusLog;
import com.fpoly.model.Payment;
import com.fpoly.model.PaymentMethod;
import com.fpoly.model.Product;
import com.fpoly.model.ProductVariant;
import com.fpoly.model.enums.VaiTro;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.OrderRepository;
import com.fpoly.repository.OrderStatusLogRepository;
import com.fpoly.repository.PaymentMethodRepository;
import com.fpoly.repository.PaymentRepository;
import com.fpoly.repository.CouponRepository;
import com.fpoly.repository.ProductBundleRepository;
import com.fpoly.repository.ProductPromotionRepository;
import com.fpoly.repository.ProductVariantRepository;

/** Bán hàng tại quầy showroom (POS, app riêng cổng 5175).
 *
 * Khác đơn online ở ba điểm cốt lõi:
 *   1. KHÔNG đi qua giỏ hàng — nhân viên quét/chọn thẳng sản phẩm rồi chốt.
 *   2. KHÔNG có địa chỉ giao (Order.diaChiGiao null, channel="pos") vì khách cầm hàng về ngay.
 *   3. Đơn HOÀN TẤT NGAY khi trả tiền: trừ kho, đánh dấu đã thanh toán, cộng Xu, tạo bảo hành —
 *      không có chuỗi trạng thái pending -> shipped -> delivered như bán online.
 *
 * Khách được định danh bằng SỐ ĐIỆN THOẠI: đã mua online thì gắn đúng tài khoản cũ, chưa có thì
 * tạo tài khoản khách lẻ. Nhờ vậy Xu CT / hạng thành viên / lịch sử mua vẫn đúng theo từng người
 * thay vì dồn hết vào một tài khoản ảo dùng chung. */
@Service
public class PosService {

    @Autowired private ProductVariantRepository variantRepo;
    @Autowired private ProductPromotionRepository promotionRepo;
    @Autowired private ProductBundleRepository bundleRepo;
    @Autowired private CouponRepository couponRepo;
    @Autowired private NguoiDungRepository nguoiDungRepo;
    @Autowired private OrderRepository orderRepo;
    @Autowired private OrderStatusLogRepository statusLogRepo;
    @Autowired private PaymentRepository paymentRepo;
    @Autowired private PaymentMethodRepository paymentMethodRepo;
    @Autowired private WalletService walletService;
    @Autowired private CouponService couponService;
    @Autowired private MembershipService membershipService;
    @Autowired private WarrantyService warrantyService;
    @Autowired private NotificationService notificationService;
    @Autowired private PasswordEncoder passwordEncoder;
    @Autowired private TonKhoService tonKhoService;
    @Autowired private FlashSaleService flashSaleService;
    @Autowired private SubscriptionService subscriptionService;
    @Autowired private com.fpoly.repository.InstallmentPlanRepository installmentPlanRepo;

    /** Địa chỉ gốc dùng để dựng link thanh toán in vào mã QR trên màn hình phụ.
     *
     * QUAN TRỌNG: khách quét QR bằng ĐIỆN THOẠI của họ, nên "localhost" sẽ không mở được — điện
     * thoại hiểu localhost là chính nó. Chạy thật phải đặt app.posPaymentBaseUrl thành IP LAN của
     * máy chủ (VD http://192.168.1.10:8080) hoặc tên miền công khai. Để mặc định localhost cho
     * môi trường dev, khi đó quét QR sẽ không ra gì — dùng tiền mặt để thử luồng. */
    @org.springframework.beans.factory.annotation.Value("${app.posPaymentBaseUrl:http://localhost:8080}")
    private String posPaymentBaseUrl;

    // ==================== Tra cứu phục vụ màn hình bán hàng ====================

    /** Tìm sản phẩm theo tên hoặc SKU. SKU khớp CHÍNH XÁC được ưu tiên lên đầu để thao tác quét
     * mã vạch ra đúng 1 kết quả dùng ngay. */
    public List<PosProductDto> timSanPham(String tuKhoa) {
        if (tuKhoa == null || tuKhoa.isBlank()) return List.of();
        String q = tuKhoa.trim().toLowerCase();

        return variantRepo.findAll().stream()
                .filter(v -> v.getProduct() != null && v.getPrice() != null)
                .filter(v -> (v.getSku() != null && v.getSku().toLowerCase().contains(q))
                        || v.getProduct().getName().toLowerCase().contains(q))
                .sorted((a, b) -> {
                    boolean aExact = a.getSku() != null && a.getSku().equalsIgnoreCase(q);
                    boolean bExact = b.getSku() != null && b.getSku().equalsIgnoreCase(q);
                    return Boolean.compare(bExact, aExact);
                })
                .limit(25)
                .map(this::toProductDto)
                .toList();
    }

    private PosProductDto toProductDto(ProductVariant v) {
        Product p = v.getProduct();
        String img = (p.getImages() != null && !p.getImages().isEmpty()) ? p.getImages().get(0).getUrl() : null;
        return new PosProductDto(v.getId(), p.getId(), p.getName(), v.getSku(), img, v.getPrice(), v.getStock());
    }

    /** Tra khách theo SĐT để nhân viên biết trước khách có ưu đãi gì. Chưa có thì trả moi=true
     * (chưa tạo tài khoản ở bước này — chỉ tạo khi thực sự chốt đơn, tránh rác tài khoản do gõ
     * nhầm số rồi bỏ dở). */
    public PosKhachDto traKhach(String soDienThoai) {
        String sdt = chuanHoaSdt(soDienThoai);
        return nguoiDungRepo.findBySoDienThoai(sdt)
                .map(u -> {
                    MembershipTier bac = membershipService.bacCua(u);
                    return new PosKhachDto(u.getId(), u.getHoTen(), sdt, false,
                            walletService.layHoacTaoVi(u).getSoDuBac(),
                            bac.getTenHienThi(), bac.getPhanTramGiamDon());
                })
                .orElseGet(() -> new PosKhachDto(null, null, sdt, true, 0,
                        MembershipTier.DONG.getTenHienThi(), 0));
    }

    // ==================== Ưu đãi cho thanh bên phải ====================

    /** Khuyến mãi + tặng kèm + coupon còn hiệu lực, gói trong một lượt gọi.
     *
     * variantIds = các sản phẩm ĐANG có trong đơn: khuyến mãi và tặng kèm gắn theo từng sản phẩm
     * nên chỉ có nghĩa khi biết khách đang mua gì. Đơn trống thì hai mục đó rỗng, riêng danh sách
     * coupon vẫn trả về vì nhân viên hay cần đọc cho khách trước khi chọn hàng. */
    public PosUuDaiDto uuDai(List<Integer> variantIds) {
        List<PosKhuyenMaiDto> khuyenMai = new ArrayList<>();
        List<PosTangKemDto> tangKem = new ArrayList<>();

        if (variantIds != null && !variantIds.isEmpty()) {
            // Gom theo productId: nhiều biến thể của cùng một sản phẩm dùng chung khuyến mãi,
            // không lặp lại cùng một dòng nhiều lần trên màn hình.
            List<Integer> daXet = new ArrayList<>();
            for (Integer vid : variantIds) {
                ProductVariant v = variantRepo.findById(vid).orElse(null);
                if (v == null || v.getProduct() == null) continue;
                Product p = v.getProduct();
                if (daXet.contains(p.getId())) continue;
                daXet.add(p.getId());

                promotionRepo.findByProductIdOrderBySortOrderAsc(p.getId()).forEach(pr ->
                        khuyenMai.add(new PosKhuyenMaiDto(p.getId(), p.getName(), pr.getContent())));

                bundleRepo.findByProductId(p.getId()).forEach(b -> {
                    Product qua = b.getBundleProduct();
                    if (qua == null) return;
                    ProductVariant vq = qua.getVariants() == null || qua.getVariants().isEmpty()
                            ? null : qua.getVariants().get(0);
                    String img = (qua.getImages() != null && !qua.getImages().isEmpty())
                            ? qua.getImages().get(0).getUrl() : null;
                    tangKem.add(new PosTangKemDto(p.getId(), p.getName(),
                            vq == null ? null : vq.getId(), qua.getName(), img,
                            vq == null ? null : vq.getPrice()));
                });
            }
        }

        LocalDateTime now = LocalDateTime.now();
        List<PosCouponDto> coupons = couponRepo.findAll().stream()
                .filter(c -> Boolean.TRUE.equals(c.getIsActive()))
                .filter(c -> c.getBatDauTu() == null || !now.isBefore(c.getBatDauTu()))
                .filter(c -> c.getHetHanLuc() == null || now.isBefore(c.getHetHanLuc()))
                .filter(c -> c.getSoLuotToiDa() == null || c.getSoLuotDaDung() < c.getSoLuotToiDa())
                .map(c -> new PosCouponDto(
                        c.getMa(), c.getLoaiGiam(), c.getGiaTriGiam(), c.getDonToiThieu(),
                        c.getSoLuotToiDa() == null ? null : c.getSoLuotToiDa() - c.getSoLuotDaDung(),
                        c.getHetHanLuc()))
                .toList();

        return new PosUuDaiDto(khuyenMai, tangKem, coupons,
                flashSaleDangChay(), hangThanhVien(), goiHoiVien(), traGop());
    }

    // ==================== Chương trình ưu đãi ở tầm CỬA HÀNG ====================
    // Bốn nhóm dưới đây KHÔNG gắn với sản phẩm nào trong giỏ — chúng là chính sách chung mà nhân
    // viên phải đọc được cho khách ngay tại quầy ("mua thêm bao nhiêu thì lên hạng Vàng?", "gói
    // CNTT Care có gì?", "trả góp 12 tháng lãi bao nhiêu?"). Trước đây thanh ưu đãi POS không có
    // gì trong số này nên nhân viên phải đoán hoặc gọi hỏi admin.

    /** Đợt Flash Sale đang chạy, null nếu không có. Đọc lại đúng nguồn khách đang thấy. */
    private PosDtos.PosFlashSaleDto flashSaleDangChay() {
        var dot = flashSaleService.dangChay();
        if (dot == null) return null;
        List<PosDtos.PosFlashSaleItemDto> items = dot.sanPham().stream()
                .map(i -> new PosDtos.PosFlashSaleItemDto(
                        i.variantId(), i.productName(), i.sku(),
                        i.giaGoc(), i.giaSale(), i.phanTramGiam(), i.stock()))
                .toList();
        return new PosDtos.PosFlashSaleDto(dot.tieuDe(), dot.batDauLuc(), dot.ketThucLuc(), items);
    }

    /** Hạng tích luỹ — mốc chi tiêu quy từ mốc xu theo tỉ giá KIẾM (xem MembershipTier). */
    private List<PosDtos.PosHangThanhVienDto> hangThanhVien() {
        List<PosDtos.PosHangThanhVienDto> ra = new ArrayList<>();
        for (MembershipTier t : MembershipTier.values()) {
            // Mốc lên hạng lưu bằng XU, quy ra tiền theo tỉ giá KIẾM (10.000đ = 1 xu) để nhân
            // viên đọc cho khách bằng con số họ hiểu được.
            BigDecimal mucChi = BigDecimal.valueOf(t.getXuToiThieu()).multiply(new BigDecimal("10000"));
            StringBuilder mo = new StringBuilder();
            if (t.getPhanTramGiamDon() > 0) mo.append("Giảm ").append(t.getPhanTramGiamDon()).append("% mọi đơn");
            if (t.isMienPhiNoiThanh()) mo.append(mo.length() > 0 ? " · " : "").append("Miễn phí giao nội thành");
            if (t.getPhanTramGiamPhiLienTinh() > 0) {
                mo.append(mo.length() > 0 ? " · " : "")
                  .append("Giảm ").append(t.getPhanTramGiamPhiLienTinh()).append("% phí liên tỉnh");
            }
            ra.add(new PosDtos.PosHangThanhVienDto(t.getTenHienThi(), mucChi,
                    t.getPhanTramGiamDon(), mo.length() == 0 ? "Hạng khởi đầu" : mo.toString()));
        }
        return ra;
    }

    /** Gói CNTT Care (TRẢ PHÍ) — khác hẳn hạng tích luỹ ở trên, hay bị nhầm nên tách riêng. */
    private List<PosDtos.PosGoiHoiVienDto> goiHoiVien() {
        return subscriptionService.danhSachGoi().stream().map(p -> {
            List<String> ql = new ArrayList<>();
            if (Boolean.TRUE.equals(p.getFreeInnerShipping())) ql.add("Miễn phí giao nội thành");
            if (Boolean.TRUE.equals(p.getFreeExpressInner())) ql.add("Miễn phí giao hoả tốc nội thành");
            if (soNguyen(p.getInterprovinceQuota()) > 0) ql.add(p.getInterprovinceQuota() + " lượt free ship liên tỉnh");
            if (Boolean.TRUE.equals(p.getWarrantyPriority())) ql.add("Ưu tiên bảo hành");
            if (soNguyen(p.getCleaningQuota()) > 0) ql.add(p.getCleaningQuota() + " lượt vệ sinh máy");
            if (Boolean.TRUE.equals(p.getThermalPaste())) ql.add("Tra keo tản nhiệt miễn phí");
            if (soNguyen(p.getOnsiteWarrantyQuota()) > 0) ql.add(p.getOnsiteWarrantyQuota() + " lượt bảo hành tận nơi");
            if (soNguyen(p.getLoanerQuota()) > 0) ql.add(p.getLoanerQuota() + " lượt mượn máy");
            if (Boolean.TRUE.equals(p.getFlashSaleEarly())) ql.add("Vào Flash Sale sớm");
            if (Boolean.TRUE.equals(p.getPcBuildConsult())) ql.add("Tư vấn build PC riêng");
            return new PosDtos.PosGoiHoiVienDto(p.getCode(), p.getName(), p.getPrice(),
                    p.getDurationMonths(), ql);
        }).toList();
    }

    private int soNguyen(Integer n) {
        return n == null ? 0 : n;
    }

    /** Kỳ hạn trả góp đang mở. */
    private List<PosDtos.PosTraGopDto> traGop() {
        return installmentPlanRepo.findByActiveTrueOrderBySoThangAsc().stream()
                .map(p -> new PosDtos.PosTraGopDto(p.getSoThang(), p.getLaiSuat()))
                .toList();
    }

    // ==================== Chốt đơn ====================

    @Transactional
    public PosHoaDonDto taoDon(PosTaoDonRequest req, String emailNhanVien) {
        if (req.dongHang() == null || req.dongHang().isEmpty()) {
            throw new RuntimeException("Chưa có sản phẩm nào trong đơn");
        }
        NguoiDung khach = timHoacTaoKhach(req.soDienThoai(), req.hoTen());

        // Gom dòng hàng + kiểm kho TRƯỚC khi động vào bất cứ thứ gì, để đơn thiếu hàng bị chặn
        // ngay từ đầu thay vì trừ được nửa chừng rồi mới lỗi.
        List<OrderItem> chiTiet = new ArrayList<>();
        BigDecimal tienHang = BigDecimal.ZERO;

        for (PosDongHangRequest d : req.dongHang()) {
            if (d.soLuong() == null || d.soLuong() <= 0) {
                throw new RuntimeException("Số lượng không hợp lệ");
            }
            ProductVariant v = variantRepo.findById(d.variantId())
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm id=" + d.variantId()));
            if (v.getStock() != null && v.getStock() < d.soLuong()) {
                throw new RuntimeException("\"" + v.getProduct().getName() + "\" chỉ còn " + v.getStock() + " sản phẩm");
            }

            OrderItem oi = new OrderItem();
            oi.setVariant(v);
            oi.setTenSanPham(v.getProduct().getName());
            oi.setThongTinPhienBan(v.getSku());
            oi.setDonGia(v.getPrice());
            oi.setSoLuong(d.soLuong());
            chiTiet.add(oi);

            tienHang = tienHang.add(v.getPrice().multiply(BigDecimal.valueOf(d.soLuong())));
        }

        // Ưu đãi giống hệt bán online (hạng thành viên + coupon + Xu CT) — khách mua tại quầy
        // không vì thế mà mất quyền lợi. Chỉ KHÔNG có phí ship vì lấy hàng trực tiếp.
        MembershipTier bac = membershipService.bacCua(khach);
        BigDecimal tienGiamGia = bac.tienGiamTheoBac(tienHang);

        com.fpoly.model.Coupon coupon = null;
        if (req.maCoupon() != null && !req.maCoupon().isBlank()) {
            coupon = couponService.layCouponHopLe(req.maCoupon(), tienHang);
            tienGiamGia = tienGiamGia.add(couponService.tinhGiamGia(coupon, tienHang));
        }
        tienGiamGia = tienGiamGia.min(tienHang);

        int soXuThucDung = 0;
        if (req.soXuMuonDung() != null && req.soXuMuonDung() > 0) {
            if (walletService.layHoacTaoVi(khach).getSoDuBac() < req.soXuMuonDung()) {
                throw new RuntimeException("Khách không đủ Xu CT");
            }
            BigDecimal conLai = tienHang.subtract(tienGiamGia);
            BigDecimal tienXu = walletService.quyDoiXuRaTien(req.soXuMuonDung()).min(conLai);
            soXuThucDung = walletService.soXuDeGiam(tienXu);
            tienGiamGia = tienGiamGia.add(walletService.quyDoiXuRaTien(soXuThucDung));
        }

        BigDecimal tongTien = tienHang.subtract(tienGiamGia);

        Order order = new Order();
        order.setNguoiDung(khach);
        order.setDiaChiGiao(null);       // mua tại quầy, không giao tận nơi
        order.setKenhBan("pos");
        order.setTienHang(tienHang);
        order.setTienGiamGia(tienGiamGia);
        order.setPhiVanChuyen(BigDecimal.ZERO);
        order.setTongTien(tongTien);
        order.setCouponId(coupon != null ? coupon.getId() : null);
        // Khách cầm hàng về ngay tại quầy -> đơn kết thúc luôn, không qua chuỗi giao hàng.
        order.setTrangThai("delivered");

        // Giữ hàng bằng UPDATE có điều kiện (xem TonKhoService): quầy và web bán chung một kho,
        // nhân viên quét món cuối cùng đúng lúc khách online đặt thì phải có một bên trượt.
        for (OrderItem oi : chiTiet) {
            oi.setOrder(order);
            ProductVariant v = oi.getVariant();
            if (!tonKhoService.giuHang(v, oi.getSoLuong())) {
                throw new RuntimeException("Sản phẩm \"" + oi.getTenSanPham()
                        + "\" vừa hết hàng (đơn online khác đã lấy). Kiểm tra lại kho trước khi bán.");
            }
        }
        order.setChiTiet(chiTiet);

        Order saved = orderRepo.save(order);

        if (coupon != null) couponService.danhDauDaDung(coupon);
        if (soXuThucDung > 0) walletService.chiXuTaiThanhToan(khach, soXuThucDung, saved);

        String maPT = req.maPhuongThucThanhToan() == null ? "cash" : req.maPhuongThucThanhToan();
        PaymentMethod pt = paymentMethodRepo.findByCode(maPT)
                .orElseThrow(() -> new RuntimeException("Phương thức thanh toán không hợp lệ: " + maPT));

        Payment payment = new Payment();
        payment.setOrder(saved);
        payment.setPaymentMethod(pt);
        payment.setAmount(tongTien);
        // Tiền mặt: nhân viên thu tại chỗ nên coi như đã thanh toán ngay. Cổng điện tử (VNPay)
        // giữ "pending" tới khi cổng xác nhận — màn hình phụ hiển thị QR để khách quét.
        boolean traNgay = "cash".equals(maPT);
        payment.setStatus(traNgay ? "paid" : "pending");
        if (traNgay) payment.setPaidAt(LocalDateTime.now());
        paymentRepo.save(payment);

        OrderStatusLog log = new OrderStatusLog();
        log.setOrder(saved);
        log.setTrangThai("delivered");
        log.setGhiChu("Bán tại quầy" + (emailNhanVien != null ? " — NV: " + emailNhanVien : ""));
        statusLogRepo.save(log);

        int xuNhanDuoc = 0;
        if (traNgay) {
            // Cộng xu + tạo phiếu bảo hành ngay vì đơn đã hoàn tất. Với thanh toán qua cổng,
            // hai việc này chờ callback xác nhận (xem xacNhanThanhToanPos).
            walletService.congXuTuDon(saved);
            warrantyService.createWarranty(saved);
            xuNhanDuoc = walletService.uocTinhXu(tongTien);
        }

        notificationService.tao("pos_order", "Đơn bán tại quầy",
                "Đơn " + saved.getMaDonHang() + " — " + tongTien.longValue() + "đ", "/orders");

        // Chưa trả tiền mặt -> dựng link cổng thanh toán để màn hình phụ vẽ QR cho khách quét.
        String urlThanhToan = traNgay
                ? null
                : posPaymentBaseUrl + "/payment/vnpay/pay?paymentId=" + payment.getId();

        return toHoaDon(saved, khach, payment, xuNhanDuoc, urlThanhToan);
    }

    /** Trạng thái hiện tại của một đơn tại quầy — để màn hình bán hàng biết khách đã quét QR trả
     * tiền xong chưa. Chỉ VNPay xác nhận mới đổi được trạng thái sang "paid" (xem VNPayController),
     * nên đây là nguồn tin cậy duy nhất; nhân viên không tự đánh dấu đã thu tiền được. */
    public PosHoaDonDto trangThaiDon(Integer orderId) {
        Order o = orderRepo.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));
        if (!o.laDonTaiQuay()) {
            throw new RuntimeException("Đơn này không phải đơn bán tại quầy");
        }
        Payment payment = paymentRepo.findByOrder(o).orElse(null);
        boolean daTra = payment != null && "paid".equals(payment.getStatus());
        return toHoaDon(o, o.getNguoiDung(), payment,
                daTra ? walletService.uocTinhXu(o.getTongTien()) : 0, null);
    }

    /** Gọi khi cổng thanh toán xác nhận thành công cho đơn POS (khách quét QR trên màn hình phụ). */
    @Transactional
    public void xacNhanThanhToanPos(Order order) {
        Payment payment = paymentRepo.findByOrder(order).orElse(null);
        if (payment == null || "paid".equals(payment.getStatus())) return;

        payment.setStatus("paid");
        payment.setPaidAt(LocalDateTime.now());
        paymentRepo.save(payment);

        walletService.congXuTuDon(order);
        warrantyService.createWarranty(order);
    }

    // ==================== Khách tại quầy ====================

    /** SĐT là định danh khách. Đã tồn tại -> dùng lại tài khoản đó (kể cả khách vốn mua online),
     * chưa có -> tạo tài khoản khách lẻ.
     *
     * NguoiDung bắt buộc email (unique) và password_hash, mà khách tại quầy không có cả hai, nên
     * sinh email nội bộ theo SĐT và mật khẩu ngẫu nhiên KHÔNG dùng để đăng nhập được. Khách muốn
     * dùng tài khoản online thì đặt lại mật khẩu qua luồng quên mật khẩu (chặng 2). */
    @Transactional
    public NguoiDung timHoacTaoKhach(String soDienThoai, String hoTen) {
        String sdt = chuanHoaSdt(soDienThoai);
        if (sdt.isBlank()) {
            throw new RuntimeException("Vui lòng nhập số điện thoại của khách");
        }
        return nguoiDungRepo.findBySoDienThoai(sdt).orElseGet(() -> {
            NguoiDung u = new NguoiDung();
            u.setHoTen(hoTen != null && !hoTen.isBlank() ? hoTen.trim() : "Khách " + sdt);
            u.setSoDienThoai(sdt);
            u.setEmail("pos-" + sdt + "@khachle.cnttshop.local");
            u.setMatKhau(passwordEncoder.encode(UUID.randomUUID().toString()));
            u.setVaiTro(VaiTro.customer);
            u.setIsActive(true);
            u.setAuthProvider("pos");
            u.setCreatedAt(LocalDateTime.now());
            return nguoiDungRepo.save(u);
        });
    }

    /** Bỏ khoảng trắng/dấu chấm/gạch để "0912 345 678" và "0912.345.678" là cùng một khách. */
    private String chuanHoaSdt(String sdt) {
        return sdt == null ? "" : sdt.replaceAll("[^0-9+]", "").trim();
    }

    // ==================== Hoá đơn ====================

    public PosHoaDonDto toHoaDon(Order o, NguoiDung khach, Payment payment, int xuNhanDuoc, String urlThanhToan) {
        List<PosDongHangDto> dong = (o.getChiTiet() == null ? List.<OrderItem>of() : o.getChiTiet()).stream()
                .map(oi -> new PosDongHangDto(
                        oi.getTenSanPham(), oi.getThongTinPhienBan(), oi.getDonGia(), oi.getSoLuong(),
                        oi.getDonGia().multiply(BigDecimal.valueOf(oi.getSoLuong()))))
                .toList();

        return new PosHoaDonDto(
                o.getId(), o.getMaDonHang(), o.getCreatedAt(),
                khach.getHoTen(), khach.getSoDienThoai(),
                dong, o.getTienHang(), o.getTienGiamGia(), o.getTongTien(),
                payment == null ? null : payment.getPaymentMethod().getName(),
                payment == null ? null : payment.getStatus(),
                xuNhanDuoc, urlThanhToan
        );
    }
}
