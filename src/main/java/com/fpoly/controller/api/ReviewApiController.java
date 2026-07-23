package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.fpoly.dto.ReviewDtos.DeliveryReviewRequest;
import com.fpoly.dto.ReviewDtos.ProductReviewDto;
import com.fpoly.dto.ReviewDtos.PurchasedItemDto;
import com.fpoly.dto.ReviewDtos.ReviewableItemDto;
import com.fpoly.service.ReviewService;

/** Đánh giá sản phẩm + đánh giá giao hàng — dùng cho cnttshop-vue.
 * GET /api/products/{slug}/reviews là public (khớp permitAll "/api/products/**" trong SecurityConfig),
 * các endpoint còn lại yêu cầu đăng nhập (mặc định anyRequest().authenticated() của chain /api/**). */
@RestController
@RequestMapping("/api")
public class ReviewApiController {

    @Autowired private ReviewService reviewService;

    @GetMapping("/products/{slug}/reviews")
    public List<ProductReviewDto> productReviews(@PathVariable String slug) {
        return reviewService.getProductReviews(slug);
    }

    @GetMapping("/reviews/reviewable")
    public List<ReviewableItemDto> reviewableItems(Authentication auth) {
        return reviewService.getReviewableItems(auth.getName());
    }

    @GetMapping("/purchases")
    public List<PurchasedItemDto> purchasedItems(Authentication auth) {
        return reviewService.getPurchasedItems(auth.getName());
    }

    @PostMapping("/reviews/product")
    public void submitProductReview(
            @RequestParam Integer orderId,
            @RequestParam Integer productId,
            @RequestParam Integer rating,
            @RequestParam(required = false) String comment,
            @RequestParam(value = "photo1", required = false) MultipartFile photo1,
            @RequestParam(value = "photo2", required = false) MultipartFile photo2,
            Authentication auth) {
        reviewService.submitProductReview(auth.getName(), orderId, productId, rating, comment, photo1, photo2);
    }

    @PostMapping("/reviews/delivery")
    public void submitDeliveryReview(@RequestBody DeliveryReviewRequest req, Authentication auth) {
        reviewService.submitDeliveryReview(auth.getName(), req);
    }
}
