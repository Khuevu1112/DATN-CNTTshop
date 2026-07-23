package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.dto.MembershipDtos.MembershipStatusDto;
import com.fpoly.dto.MembershipDtos.TierBenefitDto;
import com.fpoly.service.MembershipService;

/** Chương trình thành viên — bậc hiện tại + tiến độ thăng cấp (thanh tiến độ ở trang cá nhân)
 * và bảng ưu đãi đầy đủ 4 bậc (popup "Chi tiết"). */
@RestController
@RequestMapping("/api/membership")
public class MembershipApiController {

    @Autowired private MembershipService membershipService;

    @GetMapping
    public MembershipStatusDto status(Authentication auth) {
        return membershipService.trangThai(auth.getName());
    }

    /** Bảng ưu đãi 4 bậc — công khai, xem được kể cả khi chưa đăng nhập. */
    @GetMapping("/tiers")
    public List<TierBenefitDto> tiers() {
        return membershipService.tatCaBac();
    }
}
