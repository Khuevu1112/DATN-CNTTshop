package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.LocationDtos.ProvinceDto;
import com.fpoly.dto.LocationDtos.WardDto;
import com.fpoly.model.Province;
import com.fpoly.model.Ward;
import com.fpoly.repository.ProvinceRepository;
import com.fpoly.repository.WardRepository;

/** Danh sách Tỉnh/Thành + Phường/Xã hiện hành (sau sáp nhập 1/7/2025) — dùng cho dropdown địa
 * chỉ 2 tầng ở cnttshop-vue (không còn cấp Quận/Huyện). Công khai, không cần đăng nhập. */
@RestController
@RequestMapping("/api/provinces")
public class LocationApiController {

    @Autowired private ProvinceRepository provinceRepo;
    @Autowired private WardRepository wardRepo;

    @GetMapping
    public List<ProvinceDto> provinces() {
        return provinceRepo.findAllByOrderByNameAsc().stream().map(this::toDto).toList();
    }

    @GetMapping("/{id}/wards")
    public List<WardDto> wards(@PathVariable Integer id) {
        return wardRepo.findByProvince_IdOrderByNameAsc(id).stream().map(this::toDto).toList();
    }

    private ProvinceDto toDto(Province p) {
        return new ProvinceDto(p.getId(), p.getName(), p.getRegion());
    }

    private WardDto toDto(Ward w) {
        return new WardDto(w.getId(), w.getName(), w.getProvince().getId());
    }
}
