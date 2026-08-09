package com.fpoly.dto;

import java.math.BigDecimal;
import java.util.List;

public class CouponDtos {

    public record ApplyCouponRequest(String code, BigDecimal subtotal) {}

    public record ApplyCouponResultDto(
            String code, String discountType, BigDecimal discountValue,
            BigDecimal maxDiscountAmount, BigDecimal discountAmount) {}

    // ── Áp NHIỀU mã cùng lúc ───────────────────────────────────────────

    public record ApplyCouponsRequest(List<String> codes, BigDecimal subtotal) {}

    /** discountAmount ở đây là phần giảm RIÊNG của từng mã (đã tự giới hạn theo maxDiscountAmount
     * nếu có) — cộng lại các discountAmount trong danh sách có thể chênh lệch nhẹ so với
     * totalDiscountAmount vì tổng còn bị giới hạn không vượt quá tiền hàng. */
    public record AppliedCouponDto(
            String code, String discountType, BigDecimal discountValue,
            BigDecimal maxDiscountAmount, Boolean stackable, BigDecimal discountAmount) {}

    public record ApplyCouponsResultDto(List<AppliedCouponDto> coupons, BigDecimal totalDiscountAmount) {}
}
