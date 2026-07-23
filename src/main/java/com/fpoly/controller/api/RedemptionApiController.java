package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.RedemptionDtos.MyCouponDto;
import com.fpoly.dto.RedemptionDtos.RedeemCouponRequest;
import com.fpoly.dto.RedemptionDtos.RedeemCouponResultDto;
import com.fpoly.dto.RedemptionDtos.RedeemGiftRequest;
import com.fpoly.dto.RedemptionDtos.RedeemGiftResultDto;
import com.fpoly.dto.RedemptionDtos.RedemptionItemDto;
import com.fpoly.model.Order;
import com.fpoly.service.RedemptionService;

/** Kho đổi thưởng bằng Xu CT (coupon hoặc quà vật lý) — trang khuyến mãi. */
@RestController
@RequestMapping("/api/redemption")
public class RedemptionApiController {

    @Autowired
    private RedemptionService redemptionService;

    @GetMapping("/catalog")
    public List<RedemptionItemDto> catalog() {
        return redemptionService.layDanhMuc();
    }

    @PostMapping("/redeem-coupon")
    public RedeemCouponResultDto redeemCoupon(@RequestBody RedeemCouponRequest req, Authentication auth) {
        String ma = redemptionService.doiCoupon(auth.getName(), req.redemptionItemId());
        return new RedeemCouponResultDto(ma);
    }

    @PostMapping("/redeem-gift")
    public RedeemGiftResultDto redeemGift(@RequestBody RedeemGiftRequest req, Authentication auth) {
        Order order = redemptionService.doiQua(auth.getName(), req.redemptionItemId(), req.addressId());
        return new RedeemGiftResultDto(order.getId(), order.getMaDonHang());
    }

    @GetMapping("/my-coupons")
    public List<MyCouponDto> myCoupons(Authentication auth) {
        return redemptionService.layCouponDaDoi(auth.getName());
    }
}
