package com.fpoly.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/** DTO cho gói hội viên trả phí "CNTT Care" (xem SubscriptionService). Tách hẳn MembershipDtos
 * để trên UI người dùng thấy rõ đây là 2 chương trình khác nhau: hạng tích luỹ (miễn phí, theo
 * xu) và gói dịch vụ (trả phí, theo thời hạn). */
public class SubscriptionDtos {

    /** Một gói + toàn bộ quyền lợi để dựng bảng so sánh 3 cấp. */
    public record PlanDto(
            String code,
            String name,
            BigDecimal price,
            int durationMonths,
            boolean freeInnerShipping,
            boolean freeExpressInner,
            int interprovinceQuota,
            boolean warrantyPriority,
            int cleaningQuota,
            boolean thermalPaste,
            int onsiteWarrantyQuota,
            int loanerQuota,
            boolean flashSaleEarly,
            boolean pcBuildConsult,
            BigDecimal activationVoucherAmount,
            BigDecimal activationVoucherMin
    ) {}

    /** Số lượt còn lại của 1 quyền lợi có hạn mức (còn/tổng) — để UI hiện "Free ship liên tỉnh: 3/4". */
    public record QuotaDto(String key, String label, int conLai, int tong) {}

    /** Trạng thái gói của khách đang đăng nhập. active=false => chưa mua/đã hết hạn, các trường
     * còn lại null/rỗng. */
    public record MySubscriptionDto(
            boolean active,
            PlanDto plan,
            LocalDateTime startedAt,
            LocalDateTime expiresAt,
            List<QuotaDto> quotas
    ) {}

    public record BuyRequest(String planCode, String paymentMethodCode) {}

    // ===== Phía admin (Quản lý hội viên) =====

    /** Một dòng trong danh sách hội viên (cột trái). status = trạng thái HIỆU LỰC (đã xét hết
     * hạn: gói active nhưng quá expiresAt sẽ hiển thị 'expired'). */
    public record MemberRowDto(
            Integer userId,
            String fullName,
            String email,
            String phone,
            String planCode,
            String planName,
            String status,
            LocalDateTime startedAt,
            LocalDateTime expiresAt,
            int totalSubscriptions
    ) {}

    /** 1 dòng lịch sử đăng ký của hội viên (mọi lần mua/gia hạn). */
    public record SubHistoryDto(
            Integer id,
            String planName,
            BigDecimal price,
            String status,
            LocalDateTime startedAt,
            LocalDateTime expiresAt,
            LocalDateTime createdAt
    ) {}

    /** Chi tiết hội viên (cột phải khi nhấn vào 1 dòng). currentPlan/quotas null/rỗng nếu hội
     * viên không còn gói hiệu lực. */
    public record MemberDetailDto(
            Integer userId,
            String fullName,
            String email,
            String phone,
            boolean hasActive,
            PlanDto currentPlan,
            LocalDateTime startedAt,
            LocalDateTime expiresAt,
            List<QuotaDto> quotas,
            List<SubHistoryDto> history
    ) {}

    /** Gói cho trình sửa của admin — kèm id (để PUT) + maxAnnualCost (chi phí ưu đãi tối đa/năm,
     * ngưỡng sàn mà giá bán bắt buộc phải vượt qua, xem SubscriptionPlan.chiPhiToiDaMotNam) để
     * admin thấy ngay còn lãi bao nhiêu khi chỉnh số. */
    public record AdminPlanDto(
            Integer id,
            String code,
            String name,
            BigDecimal price,
            int durationMonths,
            boolean freeInnerShipping,
            boolean freeExpressInner,
            int interprovinceQuota,
            boolean warrantyPriority,
            int cleaningQuota,
            boolean thermalPaste,
            int onsiteWarrantyQuota,
            int loanerQuota,
            boolean flashSaleEarly,
            boolean pcBuildConsult,
            BigDecimal activationVoucherAmount,
            BigDecimal activationVoucherMin,
            boolean isActive,
            BigDecimal maxAnnualCost
    ) {}

    /** Admin sửa giá + ưu đãi của 1 gói. Chỉ admin gọi được (xem AdminSubscriptionApiController).
     * Các trường null giữ nguyên giá trị cũ. */
    public record PlanEditRequest(
            String name,
            BigDecimal price,
            Integer durationMonths,
            Boolean freeInnerShipping,
            Boolean freeExpressInner,
            Integer interprovinceQuota,
            Boolean warrantyPriority,
            Integer cleaningQuota,
            Boolean thermalPaste,
            Integer onsiteWarrantyQuota,
            Integer loanerQuota,
            Boolean flashSaleEarly,
            Boolean pcBuildConsult,
            BigDecimal activationVoucherAmount,
            BigDecimal activationVoucherMin,
            Boolean isActive
    ) {}

    /** redirectUrl = URL cổng thanh toán để frontend chuyển hướng toàn trang (giống đặt đơn qua
     * VNPay). paymentId để tra cứu nếu cần. */
    public record BuyResultDto(Integer paymentId, String redirectUrl) {}
}
