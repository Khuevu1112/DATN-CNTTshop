package com.fpoly.controller.api;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.dto.CheckinDtos.CheckinResultDto;
import com.fpoly.dto.CheckinDtos.CheckinStatusDto;
import com.fpoly.service.CheckinService;

/** Điểm danh định kỳ — trang khuyến mãi. */
@RestController
@RequestMapping("/api/checkin")
public class CheckinApiController {

    @Autowired
    private CheckinService checkinService;

    @GetMapping
    public CheckinStatusDto status(Authentication auth) {
        return checkinService.trangThaiHomNay(auth.getName());
    }

    @PostMapping
    public CheckinResultDto checkin(Authentication auth) {
        return checkinService.diemDanh(auth.getName());
    }
}
