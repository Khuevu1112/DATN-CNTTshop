package com.fpoly.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.RedemptionDtos.MyCouponDto;
import com.fpoly.dto.RedemptionDtos.RedemptionItemDto;
import com.fpoly.model.Coupon;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.Order;
import com.fpoly.model.OrderItem;
import com.fpoly.model.OrderStatusLog;
import com.fpoly.model.Payment;
import com.fpoly.model.PaymentMethod;
import com.fpoly.model.Product;
import com.fpoly.model.ProductImage;
import com.fpoly.model.ProductVariant;
import com.fpoly.model.RedemptionItem;
import com.fpoly.model.UserAddress;
import com.fpoly.model.WalletTransaction;
import com.fpoly.repository.CouponRepository;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.OrderRepository;
import com.fpoly.repository.OrderStatusLogRepository;
import com.fpoly.repository.PaymentMethodRepository;
import com.fpoly.repository.PaymentRepository;
import com.fpoly.repository.RedemptionItemRepository;
import com.fpoly.repository.UserAddressRepository;

/** Đổi Xu CT lấy coupon (dùng thẳng mã coupon do admin tạo ở trang Quản lý mã giảm giá, không
 * random) hoặc quà vật lý (tái dùng hệ Đơn hàng — đơn 0đ, cần địa chỉ giao, admin xử lý như đơn
 * thường). */
@Service
public class RedemptionService {

    @Autowired private RedemptionItemRepository itemRepo;
    @Autowired private CouponRepository couponRepo;
    @Autowired private NguoiDungRepository nguoiDungRepo;
    @Autowired private UserAddressRepository addressRepo;
    @Autowired private TonKhoService tonKhoService;
    @Autowired private OrderRepository orderRepo;
    @Autowired private OrderStatusLogRepository statusLogRepo;
    @Autowired private PaymentRepository paymentRepo;
    @Autowired private PaymentMethodRepository paymentMethodRepo;
    @Autowired private NotificationService notificationService;
    @Autowired private WalletService walletService;
    @Autowired private MailService mailService;
    @Autowired private com.fpoly.repository.WalletTransactionRepository walletTransactionRepo;

    /** Nhắc "coupon sắp hết hạn" trước khi mã hết hạn (email + thông báo trong app).
     *
     * Nhắc khi còn ≤ 3 ngày. Chạy mỗi 6 giờ để không phụ thuộc đúng một mốc trong ngày (lỡ server
     * tắt đúng lúc thì lần chạy sau vẫn bắt được). Chống nhắc trùng bằng cờ coupon_reminder_sent
     * trên chính lượt đổi. Mã đã dùng rồi thì bỏ qua (vẫn set cờ để không xét lại mỗi lần chạy). */
    private static final int SO_NGAY_NHAC_TRUOC = 3;

    @Scheduled(fixedRate = 6 * 60 * 60 * 1000)
    @Transactional
    public void nhacCouponSapHetHan() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime soon = now.plusDays(SO_NGAY_NHAC_TRUOC);
        for (WalletTransaction t : walletTransactionRepo.findCouponRemindersDue(now, soon)) {
            Coupon coupon = t.getCouponLienQuan();
            NguoiDung user = t.getWallet().getNguoiDung();
            try {
                boolean daDung = orderRepo.findByNguoiDungOrderByCreatedAtDesc(user).stream()
                        .anyMatch(o -> coupon.getId().equals(o.getCouponId()) && !"cancelled".equals(o.getTrangThai()));
                if (!daDung) {
                    String han = coupon.getHetHanLuc()
                            .format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
                    notificationService.taoChoUser(user.getId(), "coupon_expiring",
                            "Mã giảm giá sắp hết hạn",
                            "Mã " + coupon.getMa() + " của bạn sẽ hết hạn ngày " + han
                                    + ". Dùng ngay trước khi hết hiệu lực nhé!",
                            "/tai-khoan");
                    try {
                        mailService.sendCouponExpiringEmail(user.getEmail(), user.getHoTen(), coupon.getMa(), han);
                    } catch (Exception mailEx) {
                        // Gửi mail hỏng không được chặn việc set cờ — nếu không sẽ nhắc lại vô hạn.
                    }
                }
                t.setCouponReminderSent(true);
                walletTransactionRepo.save(t);
            } catch (Exception e) {
                // Một bản ghi lỗi không được làm hỏng cả lượt quét.
            }
        }
    }

    /** Kho đổi thưởng hiển thị ở trang khuyến mãi — gộp quà vật lý (REDEMPTION_ITEM) với mã
     * giảm giá do admin bật đổi bằng xu (COUPON.xu_cost khác null, xem CouponRepository). */
    public List<RedemptionItemDto> layDanhMuc() {
        List<RedemptionItemDto> out = new ArrayList<>();
        for (RedemptionItem item : itemRepo.findByIsActiveTrueOrderByThuTuAsc()) {
            out.add(toGiftDto(item));
        }
        for (Coupon c : couponRepo.timCouponDoiDuocBangXu(LocalDateTime.now())) {
            out.add(toCouponDto(c));
        }
        return out;
    }

    private RedemptionItemDto toGiftDto(RedemptionItem item) {
        ProductVariant variant = item.getVariant();
        String img = null;
        BigDecimal giftPrice = null;
        if (variant != null) {
            giftPrice = variant.getPrice();
            Product p = variant.getProduct();
            if (p.getImages() != null && !p.getImages().isEmpty()) {
                img = p.getImages().stream().filter(i -> Boolean.TRUE.equals(i.getIsPrimary()))
                        .map(ProductImage::getUrl).findFirst().orElse(p.getImages().get(0).getUrl());
            }
        }
        return new RedemptionItemDto(
                item.getId(), item.getLoai(), item.getTen(), item.getGiaTokenBac(),
                null, null, item.getDonToiThieu(), giftPrice, img
        );
    }

    private RedemptionItemDto toCouponDto(Coupon c) {
        return new RedemptionItemDto(
                c.getId(), "coupon", tenHienThi(c), c.getGiaXu(),
                c.getLoaiGiam(), c.getGiaTriGiam(), c.getDonToiThieu(), null, null
        );
    }

    private String tenHienThi(Coupon c) {
        return "percent".equals(c.getLoaiGiam())
                ? "Giảm " + c.getGiaTriGiam().stripTrailingZeros().toPlainString() + "%"
                : "Giảm " + c.getGiaTriGiam().stripTrailingZeros().toPlainString() + "đ";
    }

    private RedemptionItem layItem(Integer id, String loaiMongMuon) {
        RedemptionItem item = itemRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy mục đổi thưởng"));
        if (!Boolean.TRUE.equals(item.getIsActive())) {
            throw new RuntimeException("Mục đổi thưởng này hiện không khả dụng");
        }
        if (!loaiMongMuon.equals(item.getLoai())) {
            throw new RuntimeException("Mục đổi thưởng không đúng loại");
        }
        return item;
    }

    /** Đổi Xu CT lấy 1 mã coupon do admin tạo sẵn — nhiều người có thể cùng đổi 1 mã, dùng
     * chung mã đó (giới hạn lượt dùng thật ở CouponService.layCouponHopLe lúc áp mã khi thanh
     * toán, không phải ở bước đổi thưởng này). Không cho đổi lại mã đã từng đổi để tránh tốn
     * xu vô ích cho đúng 1 mã. */
    @Transactional
    public String doiCoupon(String email, Integer couponId) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
        Coupon coupon = couponRepo.findById(couponId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy mã giảm giá"));

        if (coupon.getGiaXu() == null) {
            throw new RuntimeException("Mã này không đổi được bằng xu");
        }
        if (!Boolean.TRUE.equals(coupon.getIsActive())) {
            throw new RuntimeException("Mã giảm giá này hiện không khả dụng");
        }
        if (coupon.getHetHanLuc() != null && coupon.getHetHanLuc().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Mã giảm giá đã hết hạn");
        }
        if (coupon.getSoLuotToiDa() != null && coupon.getSoLuotDaDung() >= coupon.getSoLuotToiDa()) {
            throw new RuntimeException("Mã giảm giá đã hết lượt sử dụng");
        }

        boolean daDoi = walletService.layLichSuGiaoDich(walletService.layHoacTaoVi(user)).stream()
                .anyMatch(t -> "redeem".equals(t.getLoaiGiaoDich()) && t.getCouponLienQuan() != null
                        && t.getCouponLienQuan().getId().equals(coupon.getId()));
        if (daDoi) {
            throw new RuntimeException("Bạn đã đổi mã này rồi, xem trong Quản lý tài khoản");
        }

        walletService.truXuDoiCoupon(user, coupon.getGiaXu(), "Đổi mã giảm giá: " + coupon.getMa(), coupon);

        notificationService.taoChoUser(
                user.getId(), "redemption_coupon", "Đổi thưởng thành công",
                "Bạn đã đổi mã giảm giá: " + coupon.getMa(),
                "/tai-khoan"
        );
        try {
            mailService.sendCouponRedeemedEmail(user.getEmail(), user.getHoTen(), tenHienThi(coupon), coupon.getMa());
        } catch (Exception e) {
            // Không chặn luồng đổi thưởng nếu gửi mail thất bại
        }

        return coupon.getMa();
    }

    /** "Mã giảm giá của tôi" ở AccountView — các mã đã đổi bằng xu, kèm trạng thái đã áp dụng
     * vào đơn hàng thật hay chưa (dựa vào Order.couponId, xem OrderService.datHangTuGioHang). */
    public List<MyCouponDto> layCouponDaDoi(String email) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        List<Integer> couponIdDaDung = orderRepo.findByNguoiDungOrderByCreatedAtDesc(user).stream()
                .filter(o -> o.getCouponId() != null && !"cancelled".equals(o.getTrangThai()))
                .map(Order::getCouponId)
                .toList();

        java.util.LinkedHashMap<Integer, Coupon> daDoi = new java.util.LinkedHashMap<>();
        for (WalletTransaction t : walletService.layLichSuGiaoDich(walletService.layHoacTaoVi(user))) {
            if ("redeem".equals(t.getLoaiGiaoDich()) && t.getCouponLienQuan() != null) {
                Coupon c = t.getCouponLienQuan();
                daDoi.putIfAbsent(c.getId(), c);
            }
        }

        return daDoi.values().stream()
                .map(c -> new MyCouponDto(
                        c.getId(), c.getMa(), c.getLoaiGiam(), c.getGiaTriGiam(), c.getDonToiThieu(),
                        c.getHetHanLuc(), couponIdDaDung.contains(c.getId())
                ))
                .toList();
    }

    /** Đổi Xu CT lấy quà vật lý — tạo 1 đơn hàng 0đ (đã "thanh toán" bằng xu) cần giao tới địa
     * chỉ đã chọn, admin xử lý y hệt đơn thường qua trang Quản lý đơn hàng. */
    @Transactional
    public Order doiQua(String email, Integer redemptionItemId, Integer addressId) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
        RedemptionItem item = layItem(redemptionItemId, "gift");

        UserAddress address = addressRepo.findById(addressId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy địa chỉ giao hàng"));
        if (!address.getNguoiDung().getEmail().equals(email)) {
            throw new RuntimeException("Địa chỉ giao hàng không hợp lệ");
        }

        ProductVariant variant = item.getVariant();
        if (variant == null) {
            throw new RuntimeException("Quà tặng này chưa được cấu hình đầy đủ");
        }
        if (variant.getStock() == null || variant.getStock() < 1) {
            throw new RuntimeException("Quà tặng \"" + item.getTen() + "\" tạm hết hàng");
        }

        // Kiểm tra đủ xu trước khi tạo đơn — trừ thật sự làm sau khi đơn đã có id (để gắn
        // ref_order_id, cho phép hoàn xu nếu đơn bị huỷ sau này).
        var wallet = walletService.layHoacTaoVi(user);
        if (wallet.getSoDuBac() < item.getGiaTokenBac()) {
            throw new RuntimeException("Không đủ Xu CT");
        }

        Order order = new Order();
        order.setNguoiDung(user);
        order.chupLaiDiaChi(address);
        order.setTienHang(BigDecimal.ZERO);
        order.setTienGiamGia(BigDecimal.ZERO);
        order.setPhiVanChuyen(BigDecimal.ZERO);
        order.setTongTien(BigDecimal.ZERO);
        order.setTrangThai("pending");

        OrderItem oi = new OrderItem();
        oi.setOrder(order);
        oi.setVariant(variant);
        oi.setTenSanPham(variant.getProduct().getName());
        oi.setThongTinPhienBan(variant.getSku());
        oi.setDonGia(BigDecimal.ZERO);
        oi.setSoLuong(1);
        order.setChiTiet(List.of(oi));

        // Giữ hàng bằng UPDATE có điều kiện (xem TonKhoService) thay vì đọc-rồi-ghi: hai khách
        // cùng đổi món quà cuối cùng thì chỉ một người thành công.
        if (!tonKhoService.giuHang(variant, 1)) {
            throw new RuntimeException("Quà tặng \"" + item.getTen() + "\" vừa hết, bạn chọn phần quà khác nhé.");
        }

        Order saved = orderRepo.save(order);

        PaymentMethod redemptionMethod = paymentMethodRepo.findByCode("redemption")
                .orElseThrow(() -> new RuntimeException("Chưa cấu hình phương thức đổi quà"));
        Payment payment = new Payment();
        payment.setOrder(saved);
        payment.setPaymentMethod(redemptionMethod);
        payment.setAmount(BigDecimal.ZERO);
        payment.setStatus("paid");
        payment.setPaidAt(LocalDateTime.now());
        paymentRepo.save(payment);

        OrderStatusLog log = new OrderStatusLog();
        log.setOrder(saved);
        log.setTrangThai("pending");
        log.setGhiChu("Đơn đổi quà bằng Xu CT: " + item.getTen());
        statusLogRepo.save(log);

        walletService.truXuDoiThuong(user, item.getGiaTokenBac(), "Đổi: " + item.getTen(), saved);

        notificationService.taoChoUser(
                user.getId(), "redemption_gift", "Đổi quà thành công",
                "Bạn đã đổi \"" + item.getTen() + "\", đơn " + saved.getMaDonHang() + " sẽ được giao tới địa chỉ đã chọn.",
                "/tai-khoan/don-hang"
        );

        return saved;
    }
}
