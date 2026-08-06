package com.fpoly.dto;

import java.math.BigDecimal;

public class CouponDtos {

    public record ApplyCouponRequest(String code, BigDecimal subtotal) {}

    public record ApplyCouponResultDto(
            String code, String discountType, BigDecimal discountValue,
            BigDecimal maxDiscountAmount, BigDecimal discountAmount) {}
}
