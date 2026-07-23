package com.fpoly.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class RedemptionDtos {

    // discountType/discountValue chỉ có giá trị khi type="coupon" (percent/fixed, khớp với
    // COUPON.discount_type); giftPrice/giftImageUrl chỉ có giá trị khi type="gift".
    public record RedemptionItemDto(
            Integer id, String type, String name, Integer silverCost,
            String discountType, BigDecimal discountValue, BigDecimal minOrder,
            BigDecimal giftPrice, String giftImageUrl
    ) {}

    public record RedeemCouponRequest(Integer redemptionItemId) {}
    public record RedeemCouponResultDto(String couponCode) {}

    public record RedeemGiftRequest(Integer redemptionItemId, Integer addressId) {}
    public record RedeemGiftResultDto(Integer orderId, String orderCode) {}

    // "Mã giảm giá của tôi" — coupon đã đổi bằng xu, hiển thị dạng vé xé ở AccountView.
    public record MyCouponDto(
            Integer couponId, String code, String discountType, BigDecimal discountValue,
            BigDecimal minOrder, LocalDateTime expiresAt, boolean used
    ) {}
}
