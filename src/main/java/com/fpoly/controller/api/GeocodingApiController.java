package com.fpoly.controller.api;

import java.math.BigDecimal;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.service.GeocodingService;
import com.fpoly.service.GeocodingService.KetQuaTraNguoc;

/** Tra ngược toạ độ -> địa chỉ chữ + Tỉnh/Phường, cho chế độ "chỉ cắm mốc" ở form địa chỉ.
 * Công khai vì khách chưa đăng nhập cũng có thể đang điền form ở bước thanh toán. */
@RestController
@RequestMapping("/api/geocoding")
public class GeocodingApiController {

    @Autowired private GeocodingService geocodingService;

    @GetMapping("/reverse")
    public KetQuaTraNguoc reverse(@RequestParam BigDecimal lat, @RequestParam BigDecimal lng) {
        return geocodingService.traNguoc(lat, lng);
    }
}
