package com.fpoly.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.SubscriptionDtos.AdminPlanDto;
import com.fpoly.dto.SubscriptionDtos.MemberDetailDto;
import com.fpoly.dto.SubscriptionDtos.MemberRowDto;
import com.fpoly.dto.SubscriptionDtos.PlanDto;
import com.fpoly.dto.SubscriptionDtos.PlanEditRequest;
import com.fpoly.dto.SubscriptionDtos.QuotaDto;
import com.fpoly.dto.SubscriptionDtos.SubHistoryDto;
import com.fpoly.model.Coupon;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.Order;
import com.fpoly.model.Payment;
import com.fpoly.model.PaymentMethod;
import com.fpoly.model.SubscriptionPlan;
import com.fpoly.model.SubscriptionUsage;
import com.fpoly.model.UserSubscription;
import com.fpoly.repository.CouponRepository;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.PaymentMethodRepository;
import com.fpoly.repository.PaymentRepository;
import com.fpoly.repository.SubscriptionPlanRepository;
import com.fpoly.repository.SubscriptionUsageRepository;
import com.fpoly.repository.UserSubscriptionRepository;

/** Gói hội viên trả phí "CNTT Care" — bán dịch vụ có trần chi phí, TÁCH RỜI hạng tích luỹ
 * (MembershipTier). Nguyên tắc bất di bất dịch: gói KHÔNG bao giờ tặng xu (tặng xu là gián tiếp
 * bán hạng tích luỹ, phá mốc 60/100/200 triệu — xem MembershipTier + XuEconomyTest); quyền lợi
 * chỉ là dịch vụ + ship + voucher mệnh giá cố định. Quyền lợi có hạn mức được ghi sổ ở
 * SUBSCRIPTION_USAGE (ledger) nên huỷ đơn hoàn lại lượt đã tiêu, giống hoàn xu bên WalletService. */
@Service
public class SubscriptionService {

    // Khoá quyền lợi có hạn mức trong SUBSCRIPTION_USAGE. Hiện chỉ interprovince_ship được tiêu
    // tự động lúc đặt đơn; các key còn lại dành cho quyền lợi offline (admin xác nhận) — đã có
    // chỗ trong sổ + hiển thị số còn lại, nhưng luồng tiêu offline để pha sau.
    public static final String KEY_SHIP_LIEN_TINH = "interprovince_ship";
    public static final String KEY_VE_SINH        = "cleaning";
    public static final String KEY_TAN_NOI        = "onsite_warranty";
    public static final String KEY_MAY_MUON       = "loaner";

    // Mã tuỳ chọn giao NỘI THÀNH Hải Phòng (xem ShippingService) — mọi mã khác là hãng liên tỉnh.
    private static final List<String> MA_GIAO_NOI_THANH = List.of("hoa_toc", "thuong");

    @Autowired private SubscriptionPlanRepository planRepo;
    @Autowired private UserSubscriptionRepository subRepo;
    @Autowired private SubscriptionUsageRepository usageRepo;
    @Autowired private NguoiDungRepository nguoiDungRepo;
    @Autowired private PaymentRepository paymentRepo;
    @Autowired private PaymentMethodRepository paymentMethodRepo;
    @Autowired private CouponRepository couponRepo;
    @Autowired private NotificationService notificationService;

    // ---------- Tra cứu ----------

    public List<SubscriptionPlan> danhSachGoi() {
        return planRepo.findByIsActiveTrueOrderBySortOrderAsc();
    }

    /** Gói còn hiệu lực của khách (đã kích hoạt + chưa hết hạn), null nếu không có. */
    public UserSubscription goiConHieuLuc(String email) {
        if (email == null || "anonymousUser".equals(email)) return null;
        return nguoiDungRepo.findByEmail(email)
                .flatMap(u -> subRepo.goiConHieuLuc(u, LocalDateTime.now()))
                .orElse(null);
    }

    public List<UserSubscription> lichSuGoi(String email) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
        return subRepo.findByNguoiDungOrderByCreatedAtDesc(user);
    }

    // ---------- Mua gói ----------

    /** Tạo bản đăng ký 'pending' + bản ghi Payment chờ thanh toán, trả về Payment để controller
     * dựng URL chuyển hướng cổng thanh toán. Gói chỉ thực sự có hiệu lực khi cổng báo thành công
     * (xem kichHoatSauThanhToan) — giống đơn hàng qua cổng redirect, chưa trả tiền thì chưa chốt. */
    @Transactional
    public Payment muaGoi(String email, String planCode, String paymentMethodCode) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        SubscriptionPlan plan = planRepo.findByCode(planCode)
                .filter(p -> Boolean.TRUE.equals(p.getIsActive()))
                .orElseThrow(() -> new RuntimeException("Gói hội viên không tồn tại hoặc đã ngừng bán"));

        PaymentMethod method = paymentMethodRepo.findByCode(paymentMethodCode)
                .orElseThrow(() -> new RuntimeException("Phương thức thanh toán không hợp lệ"));

        UserSubscription sub = new UserSubscription();
        sub.setNguoiDung(user);
        sub.setPlan(plan);
        sub.setStatus("pending");
        UserSubscription saved = subRepo.save(sub);

        Payment payment = new Payment();
        payment.setSubscription(saved);
        payment.setPaymentMethod(method);
        payment.setAmount(plan.getPrice());
        payment.setStatus("pending");
        return paymentRepo.save(payment);
    }

    /** Cổng thanh toán báo mua gói thành công (xem VNPayController) — kích hoạt gói: điền hạn sử
     * dụng, phát voucher kích hoạt (nếu gói có), báo cho khách. Có chốt chặn gọi 2 lần (VNPay có
     * thể callback nhiều lần) để không kích hoạt/tặng voucher trùng. */
    @Transactional
    public void kichHoatSauThanhToan(Payment payment) {
        UserSubscription sub = payment.getSubscription();
        if (sub == null || "active".equals(sub.getStatus())) return;

        SubscriptionPlan plan = sub.getPlan();
        LocalDateTime now = LocalDateTime.now();
        sub.setStartedAt(now);
        sub.setExpiresAt(now.plusMonths(plan.getDurationMonths()));
        sub.setStatus("active");
        subRepo.save(sub);

        String voucherCode = null;
        if (plan.getActivationVoucherAmount() != null) {
            voucherCode = phatVoucherKichHoat(sub);
        }

        String noiDung = "Gói " + plan.getName() + " của bạn đã kích hoạt, hiệu lực tới "
                + sub.getExpiresAt().toLocalDate() + ".";
        if (voucherCode != null) {
            noiDung += " Tặng bạn mã giảm giá " + voucherCode + " ("
                    + plan.getActivationVoucherAmount().longValue() + "đ) dùng cho đơn tiếp theo.";
        }
        notificationService.taoChoUser(
                sub.getNguoiDung().getId(), "subscription_activated",
                "Kích hoạt gói hội viên thành công", noiDung, "/tai-khoan");
    }

    /** Voucher mệnh giá CỐ ĐỊNH (không phải % tiền hàng) — cố ý dùng fixed để chi phí có trần,
     * đúng tinh thần gói dịch vụ. Hạn dùng bằng hạn gói, dùng được 1 lần. */
    private String phatVoucherKichHoat(UserSubscription sub) {
        SubscriptionPlan plan = sub.getPlan();
        String code;
        do {
            code = "CARE" + sub.getId() + "-" + Integer.toString((int) (Math.random() * 46656), 36).toUpperCase();
        } while (couponRepo.existsByMa(code));

        Coupon c = new Coupon();
        c.setMa(code);
        c.setLoaiGiam("fixed");
        c.setGiaTriGiam(plan.getActivationVoucherAmount());
        c.setDonToiThieu(plan.getActivationVoucherMin() != null ? plan.getActivationVoucherMin() : BigDecimal.ZERO);
        c.setSoLuotToiDa(1);
        c.setSoLuotDaDung(0);
        c.setBatDauTu(sub.getStartedAt());
        c.setHetHanLuc(sub.getExpiresAt());
        c.setIsActive(true);
        couponRepo.save(c);
        return code;
    }

    // ---------- Quyền lợi giao hàng ----------

    /** Ưu đãi giao hàng gói mang lại — tra ĐÚNG MỘT LẦN rồi truyền xuống ShippingService để khỏi
     * lặp truy vấn cho từng tuỳ chọn/hãng. NONE khi khách không có gói còn hiệu lực. */
    public record UuDaiGiaoHangGoi(boolean freeNoiThanh, boolean freeHoaToc, boolean conLuotLienTinh) {
        public static final UuDaiGiaoHangGoi NONE = new UuDaiGiaoHangGoi(false, false, false);
    }

    public UuDaiGiaoHangGoi uuDaiGiaoHang(String email) {
        UserSubscription sub = goiConHieuLuc(email);
        if (sub == null) return UuDaiGiaoHangGoi.NONE;
        SubscriptionPlan plan = sub.getPlan();
        return new UuDaiGiaoHangGoi(
                Boolean.TRUE.equals(plan.getFreeInnerShipping()),
                Boolean.TRUE.equals(plan.getFreeExpressInner()),
                soLuotConLai(sub, KEY_SHIP_LIEN_TINH) > 0);
    }

    /** Số lượt còn lại của 1 quyền lợi có hạn mức = hạn mức gói - tổng đã tiêu (ledger). */
    public int soLuotConLai(UserSubscription sub, String benefitKey) {
        return hanMuc(sub.getPlan(), benefitKey) - usageRepo.daTieu(sub, benefitKey);
    }

    private int hanMuc(SubscriptionPlan plan, String benefitKey) {
        return switch (benefitKey) {
            case KEY_SHIP_LIEN_TINH -> plan.getInterprovinceQuota();
            case KEY_VE_SINH        -> plan.getCleaningQuota();
            case KEY_TAN_NOI        -> plan.getOnsiteWarrantyQuota();
            case KEY_MAY_MUON       -> plan.getLoanerQuota();
            default -> 0;
        };
    }

    /** Gọi từ OrderService ngay sau khi tạo đơn: nếu đơn dùng ship LIÊN TỈNH và phí đã về 0 nhờ
     * gói (membership chỉ giảm %, không bao giờ về 0 — nên feeFinal==0 trên hãng liên tỉnh chắc
     * chắn là do gói), thì ghi sổ tiêu 1 lượt, gắn với đơn để hoàn khi đơn bị huỷ. Không làm gì
     * với đơn nội thành hoặc đơn không được gói làm free. */
    @Transactional
    public void ghiNhanGiaoHangLienTinh(Order order, String email, String maTuyChon,
                                        BigDecimal feeGoc, BigDecimal feeFinal) {
        if (maTuyChon == null || MA_GIAO_NOI_THANH.contains(maTuyChon)) return;
        if (feeGoc == null || feeGoc.signum() <= 0) return;
        if (feeFinal == null || feeFinal.signum() != 0) return;

        UserSubscription sub = goiConHieuLuc(email);
        if (sub == null || soLuotConLai(sub, KEY_SHIP_LIEN_TINH) <= 0) return;

        ghiSo(sub, KEY_SHIP_LIEN_TINH, 1, order.getId(),
                "Free ship liên tỉnh cho đơn " + order.getMaDonHang());
    }

    /** Đơn bị huỷ/hết hạn -> hoàn lại lượt giao hàng liên tỉnh đã tiêu (nếu có), giống hoàn xu.
     * Không làm gì nếu đơn chưa từng tiêu lượt nào, hoặc đã hoàn rồi (chống hoàn trùng). */
    @Transactional
    public void hoanLuotTheoDon(Order order) {
        List<SubscriptionUsage> daTieu = usageRepo.findByOrderIdAndDeltaGreaterThan(order.getId(), 0);
        if (daTieu.isEmpty()) return;
        if (!usageRepo.findByOrderIdAndDeltaLessThan(order.getId(), 0).isEmpty()) return; // đã hoàn

        for (SubscriptionUsage u : daTieu) {
            ghiSo(u.getSubscription(), u.getBenefitKey(), -u.getDelta(), order.getId(),
                    "Hoàn lượt do đơn " + order.getMaDonHang() + " bị huỷ");
        }
    }

    private void ghiSo(UserSubscription sub, String benefitKey, int delta, Integer orderId, String note) {
        SubscriptionUsage u = new SubscriptionUsage();
        u.setSubscription(sub);
        u.setBenefitKey(benefitKey);
        u.setDelta(delta);
        u.setOrderId(orderId);
        u.setNote(note);
        usageRepo.save(u);
    }

    // ============================================================
    //  Quản lý hội viên (ADMIN) — xem AdminSubscriptionApiController
    // ============================================================

    /** Trạng thái HIỆU LỰC: gói 'active' nhưng đã quá hạn thì coi như 'expired' (không có job
     * nền hạ trạng thái, nên phải xét hết hạn ngay lúc đọc). */
    private String trangThaiHieuLuc(UserSubscription sub) {
        if ("active".equals(sub.getStatus())
                && sub.getExpiresAt() != null && sub.getExpiresAt().isBefore(LocalDateTime.now())) {
            return "expired";
        }
        return sub.getStatus();
    }

    /** Danh sách hội viên (cột trái) — gom mọi lượt đăng ký theo NGƯỜI, mỗi người 1 dòng lấy gói
     * "tiêu biểu nhất": ưu tiên gói đang còn hiệu lực, không có thì lấy lượt mua gần nhất. Bỏ qua
     * các lượt mới tạo chưa thanh toán ('pending') để danh sách chỉ gồm hội viên thật. */
    public List<MemberRowDto> danhSachHoiVien() {
        Map<Integer, List<UserSubscription>> theoNguoi = new LinkedHashMap<>();
        for (UserSubscription s : subRepo.findAllByOrderByCreatedAtDesc()) {
            if ("pending".equals(s.getStatus())) continue;
            theoNguoi.computeIfAbsent(s.getNguoiDung().getId(), k -> new ArrayList<>()).add(s);
        }

        List<MemberRowDto> rows = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();
        for (List<UserSubscription> cuaNguoi : theoNguoi.values()) {
            UserSubscription tieuBieu = cuaNguoi.stream()
                    .filter(s -> "active".equals(s.getStatus()) && s.getExpiresAt() != null && s.getExpiresAt().isAfter(now))
                    .findFirst()
                    .orElse(cuaNguoi.get(0)); // findAll đã sắp mới nhất trước
            NguoiDung u = tieuBieu.getNguoiDung();
            rows.add(new MemberRowDto(
                    u.getId(), u.getHoTen(), u.getEmail(), u.getSoDienThoai(),
                    tieuBieu.getPlan().getCode(), tieuBieu.getPlan().getName(),
                    trangThaiHieuLuc(tieuBieu), tieuBieu.getStartedAt(), tieuBieu.getExpiresAt(),
                    cuaNguoi.size()));
        }
        return rows;
    }

    /** Chi tiết hội viên (cột phải). */
    public MemberDetailDto chiTietHoiVien(Integer userId) {
        NguoiDung user = nguoiDungRepo.findById(userId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        List<UserSubscription> tatCa = subRepo.findByNguoiDungOrderByCreatedAtDesc(user);
        UserSubscription active = subRepo.goiConHieuLuc(user, LocalDateTime.now()).orElse(null);

        List<SubHistoryDto> history = tatCa.stream()
                .filter(s -> !"pending".equals(s.getStatus()))
                .map(s -> new SubHistoryDto(
                        s.getId(), s.getPlan().getName(), s.getPlan().getPrice(),
                        trangThaiHieuLuc(s), s.getStartedAt(), s.getExpiresAt(), s.getCreatedAt()))
                .toList();

        List<QuotaDto> quotas = active == null ? List.of() : quotasCuaGoi(active);

        return new MemberDetailDto(
                user.getId(), user.getHoTen(), user.getEmail(), user.getSoDienThoai(),
                active != null, active == null ? null : toPlanDto(active.getPlan()),
                active == null ? null : active.getStartedAt(),
                active == null ? null : active.getExpiresAt(),
                quotas, history);
    }

    /** Số lượt còn lại của mọi quyền lợi có hạn mức trên 1 gói còn hiệu lực (bỏ quyền lợi có hạn
     * mức = 0 vì gói đó không bán quyền lợi này). */
    public List<QuotaDto> quotasCuaGoi(UserSubscription sub) {
        List<QuotaDto> list = new ArrayList<>();
        themQuota(list, sub, KEY_SHIP_LIEN_TINH, "Free ship liên tỉnh", sub.getPlan().getInterprovinceQuota());
        themQuota(list, sub, KEY_VE_SINH, "Vệ sinh máy", sub.getPlan().getCleaningQuota());
        themQuota(list, sub, KEY_TAN_NOI, "Bảo hành tận nơi", sub.getPlan().getOnsiteWarrantyQuota());
        themQuota(list, sub, KEY_MAY_MUON, "Mượn máy", sub.getPlan().getLoanerQuota());
        return list;
    }

    private void themQuota(List<QuotaDto> list, UserSubscription sub, String key, String label, int tong) {
        if (tong > 0) list.add(new QuotaDto(key, label, soLuotConLai(sub, key), tong));
    }

    /** Mọi gói (kể cả đã tắt) cho trình sửa của admin, kèm chi phí tối đa/năm. */
    public List<AdminPlanDto> danhSachGoiTatCa() {
        return planRepo.findAll().stream()
                .sorted((a, b) -> Integer.compare(a.getSortOrder(), b.getSortOrder()))
                .map(SubscriptionService::toAdminPlanDto)
                .toList();
    }

    /** Admin sửa giá + ưu đãi gói. Chặn cứng bất biến kinh tế: giá bán PHẢI lớn hơn chi phí quyền
     * lợi tối đa/năm (xem SubscriptionPlan.chiPhiToiDaMotNam) — đây chính là bài học "đừng bán
     * quyền lợi vô hạn/quá tay bằng khoản thu hữu hạn". Vi phạm là ném lỗi, không lưu. */
    @Transactional
    public AdminPlanDto capNhatGoi(Integer planId, PlanEditRequest req) {
        SubscriptionPlan p = planRepo.findById(planId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy gói"));

        if (req.name() != null) p.setName(req.name());
        if (req.price() != null) p.setPrice(req.price());
        if (req.durationMonths() != null) p.setDurationMonths(req.durationMonths());
        if (req.freeInnerShipping() != null) p.setFreeInnerShipping(req.freeInnerShipping());
        if (req.freeExpressInner() != null) p.setFreeExpressInner(req.freeExpressInner());
        if (req.interprovinceQuota() != null) p.setInterprovinceQuota(req.interprovinceQuota());
        if (req.warrantyPriority() != null) p.setWarrantyPriority(req.warrantyPriority());
        if (req.cleaningQuota() != null) p.setCleaningQuota(req.cleaningQuota());
        if (req.thermalPaste() != null) p.setThermalPaste(req.thermalPaste());
        if (req.onsiteWarrantyQuota() != null) p.setOnsiteWarrantyQuota(req.onsiteWarrantyQuota());
        if (req.loanerQuota() != null) p.setLoanerQuota(req.loanerQuota());
        if (req.flashSaleEarly() != null) p.setFlashSaleEarly(req.flashSaleEarly());
        if (req.pcBuildConsult() != null) p.setPcBuildConsult(req.pcBuildConsult());
        // Voucher: cho phép xoá (đặt về null) khi client gửi số 0/âm — coi như không tặng voucher.
        if (req.activationVoucherAmount() != null) {
            p.setActivationVoucherAmount(req.activationVoucherAmount().signum() > 0 ? req.activationVoucherAmount() : null);
        }
        if (req.activationVoucherMin() != null) {
            p.setActivationVoucherMin(req.activationVoucherMin().signum() > 0 ? req.activationVoucherMin() : null);
        }
        if (req.isActive() != null) p.setIsActive(req.isActive());

        BigDecimal chiPhiToiDa = p.chiPhiToiDaMotNam();
        if (p.getPrice() == null || p.getPrice().compareTo(chiPhiToiDa) <= 0) {
            throw new RuntimeException("Giá gói (" + (p.getPrice() == null ? 0 : p.getPrice().longValue())
                    + "đ) phải lớn hơn chi phí ưu đãi tối đa/năm (" + chiPhiToiDa.longValue()
                    + "đ) — nếu không gói sẽ lỗ khi khách dùng hết hạn mức. Hãy tăng giá hoặc giảm bớt hạn mức ưu đãi.");
        }

        planRepo.save(p);
        return toAdminPlanDto(p);
    }

    /** Mapper gói -> DTO admin (kèm id + chi phí tối đa/năm). */
    public static AdminPlanDto toAdminPlanDto(SubscriptionPlan p) {
        return new AdminPlanDto(
                p.getId(), p.getCode(), p.getName(), p.getPrice(), p.getDurationMonths(),
                Boolean.TRUE.equals(p.getFreeInnerShipping()),
                Boolean.TRUE.equals(p.getFreeExpressInner()),
                p.getInterprovinceQuota(),
                Boolean.TRUE.equals(p.getWarrantyPriority()),
                p.getCleaningQuota(),
                Boolean.TRUE.equals(p.getThermalPaste()),
                p.getOnsiteWarrantyQuota(),
                p.getLoanerQuota(),
                Boolean.TRUE.equals(p.getFlashSaleEarly()),
                Boolean.TRUE.equals(p.getPcBuildConsult()),
                p.getActivationVoucherAmount(),
                p.getActivationVoucherMin(),
                Boolean.TRUE.equals(p.getIsActive()),
                p.chiPhiToiDaMotNam());
    }

    /** Mapper gói -> DTO, dùng chung cho cả API khách lẫn admin. */
    public static PlanDto toPlanDto(SubscriptionPlan p) {
        return new PlanDto(
                p.getCode(), p.getName(), p.getPrice(), p.getDurationMonths(),
                Boolean.TRUE.equals(p.getFreeInnerShipping()),
                Boolean.TRUE.equals(p.getFreeExpressInner()),
                p.getInterprovinceQuota(),
                Boolean.TRUE.equals(p.getWarrantyPriority()),
                p.getCleaningQuota(),
                Boolean.TRUE.equals(p.getThermalPaste()),
                p.getOnsiteWarrantyQuota(),
                p.getLoanerQuota(),
                Boolean.TRUE.equals(p.getFlashSaleEarly()),
                Boolean.TRUE.equals(p.getPcBuildConsult()),
                p.getActivationVoucherAmount(),
                p.getActivationVoucherMin());
    }
}
