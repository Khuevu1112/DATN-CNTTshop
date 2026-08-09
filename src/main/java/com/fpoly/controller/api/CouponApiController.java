package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.dto.CouponDtos.AppliedCouponDto;
import com.fpoly.dto.CouponDtos.ApplyCouponRequest;
import com.fpoly.dto.CouponDtos.ApplyCouponResultDto;
import com.fpoly.dto.CouponDtos.ApplyCouponsRequest;
import com.fpoly.dto.CouponDtos.ApplyCouponsResultDto;
import com.fpoly.model.Coupon;
import com.fpoly.service.CouponService;

/** Xem trước mã giảm giá ở trang thanh toán trước khi đặt hàng — không tăng lượt dùng, việc đó
 * chỉ xảy ra khi đơn thực sự được tạo (xem OrderService.datHangTuGioHang). */
@RestController
@RequestMapping("/api/coupons")
public class CouponApiController {

    @Autowired
    private CouponService couponService;

    /** Áp 1 mã — GIỮ NGUYÊN cho POS (Sales.vue) và các nơi khác đang dùng luồng 1-mã-1-lượt,
     * không đổi hành vi để tránh phá vỡ những chỗ chưa cần cộng dồn nhiều mã. */
    @PostMapping("/apply")
    public ApplyCouponResultDto apply(@RequestBody ApplyCouponRequest req) {
        Coupon coupon = couponService.layCouponHopLe(req.code(), req.subtotal());
        return new ApplyCouponResultDto(
                coupon.getMa(), coupon.getLoaiGiam(), coupon.getGiaTriGiam(),
                coupon.getGiamToiDa(),
                couponService.tinhGiamGia(coupon, req.subtotal())
        );
    }

    /** Áp NHIỀU mã cùng lúc (trang thanh toán cnttshop-vue) — kiểm tra từng mã hợp lệ + kiểm
     * tra tương thích (cộng dồn được hay loại trừ nhau) trước khi trả kết quả. Nếu có mã không
     * hợp lệ hoặc không tương thích, ném lỗi rõ ràng (RestApiExceptionHandler trả về message
     * này cho client hiển thị) — KHÔNG áp phần nào cả, tránh áp nửa chừng gây nhầm lẫn. */
    @PostMapping("/apply-multi")
    public ApplyCouponsResultDto applyMulti(@RequestBody ApplyCouponsRequest req) {
        List<Coupon> coupons = couponService.layDanhSachCouponHopLe(req.codes(), req.subtotal());

        List<AppliedCouponDto> danhSach = coupons.stream()
                .map(c -> new AppliedCouponDto(
                        c.getMa(), c.getLoaiGiam(), c.getGiaTriGiam(),
                        c.getGiamToiDa(), c.getStackable(),
                        couponService.tinhGiamGia(c, req.subtotal())))
                .toList();

        java.math.BigDecimal tongGiam = couponService.tinhTongGiamGia(coupons, req.subtotal());
        return new ApplyCouponsResultDto(danhSach, tongGiam);
    }
}
