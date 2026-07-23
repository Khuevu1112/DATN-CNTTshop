package com.fpoly.dto;

import java.time.LocalDateTime;

public class ReviewDtos {

    /** Đánh giá công khai của 1 sản phẩm — hiển thị dưới mỗi sản phẩm ở trang chi tiết. */
    public record ProductReviewDto(
            Integer id, String reviewerName, Integer rating, String comment,
            String photo1Url, String photo2Url, LocalDateTime createdAt, Boolean isVerified
    ) {}

    /** 1 dòng sản phẩm trong đơn đã giao mà user còn quyền đánh giá (chưa đánh giá + còn hạn 14 ngày). */
    public record ReviewableItemDto(
            Integer orderId, String orderCode, Integer orderItemId,
            Integer productId, String productName, String productSlug,
            LocalDateTime deliveredAt, LocalDateTime reviewDeadline, Boolean deliveryReviewed
    ) {}

    public record DeliveryReviewRequest(Integer orderId, Integer rating, String comment) {}

    /** 1 dòng sản phẩm đã mua (đơn đã giao) — cho tab "Sản phẩm đã mua" trong QLTK, gộp sẵn
     * trạng thái đánh giá + bảo hành để tránh gọi API dò từng cái ở frontend. */
    public record PurchasedItemDto(
            Integer orderId, String orderCode, Integer orderItemId,
            Integer productId, String productName, String productSlug,
            Boolean reviewed, Boolean reviewEligible, java.time.LocalDateTime reviewDeadline,
            Integer warrantyId, String warrantyStatus, java.time.LocalDate warrantyEndDate
    ) {}
}
