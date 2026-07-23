package com.fpoly.controller.api;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.dto.CouponDtos.ApplyCouponRequest;
import com.fpoly.dto.CouponDtos.ApplyCouponResultDto;
import com.fpoly.model.Coupon;
import com.fpoly.service.CouponService;

/** Xem trước mã giảm giá ở trang thanh toán trước khi đặt hàng — không tăng lượt dùng, việc đó
 * chỉ xảy ra khi đơn thực sự được tạo (xem OrderService.datHangTuGioHang). */
@RestController
@RequestMapping("/api/coupons")
public class CouponApiController {

    @Autowired
    private CouponService couponService;

    @PostMapping("/apply")
    public ApplyCouponResultDto apply(@RequestBody ApplyCouponRequest req) {
        Coupon coupon = couponService.layCouponHopLe(req.code(), req.subtotal());
        return new ApplyCouponResultDto(
                coupon.getMa(), coupon.getLoaiGiam(), coupon.getGiaTriGiam(),
                couponService.tinhGiamGia(coupon, req.subtotal())
        );
    }
}
