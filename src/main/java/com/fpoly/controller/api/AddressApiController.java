package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.OrderDtos.AddressDto;
import com.fpoly.dto.OrderDtos.SaveAddressRequest;
import com.fpoly.model.UserAddress;
import com.fpoly.service.AddressService;

/** Sổ địa chỉ giao hàng của khách — dùng cho checkout trên cnttshop-vue. */
@RestController
@RequestMapping("/api/addresses")
public class AddressApiController {

    @Autowired private AddressService addressService;

    @GetMapping
    public List<AddressDto> list(Authentication auth) {
        return addressService.layDanhSachTheoEmail(auth.getName()).stream().map(this::toDto).toList();
    }

    @PostMapping
    public AddressDto create(@RequestBody SaveAddressRequest req, Authentication auth) {
        UserAddress a = addressService.themTheoDiaDanh(auth.getName(), req.tenNguoiNhan(), req.soDienThoai(),
                req.diaChiCuThe(), req.provinceId(), req.wardId(),
                Boolean.TRUE.equals(req.isDefault()), req.latitude(), req.longitude());
        return toDto(a);
    }

    @PutMapping("/{id}")
    public AddressDto update(@PathVariable Integer id, @RequestBody SaveAddressRequest req, Authentication auth) {
        UserAddress a = addressService.suaTheoDiaDanh(id, auth.getName(), req.tenNguoiNhan(), req.soDienThoai(),
                req.diaChiCuThe(), req.provinceId(), req.wardId(),
                Boolean.TRUE.equals(req.isDefault()), req.latitude(), req.longitude());
        return toDto(a);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Integer id, Authentication auth) {
        addressService.xoa(id, auth.getName());
    }

    @PutMapping("/{id}/default")
    public void setDefault(@PathVariable Integer id, Authentication auth) {
        addressService.datLamMacDinh(id, auth.getName());
    }

    private AddressDto toDto(UserAddress a) {
        return new AddressDto(a.getId(), a.getTenNguoiNhan(), a.getSoDienThoai(), a.getDiaChiCuThe(),
                a.getProvince() != null ? a.getProvince().getId() : null, a.getTinhThanh(),
                a.getWard() != null ? a.getWard().getId() : null, a.getPhuongXa(),
                a.getDiaChiDayDu(), a.getIsDefault(), a.getLatitude(), a.getLongitude());
    }
}
