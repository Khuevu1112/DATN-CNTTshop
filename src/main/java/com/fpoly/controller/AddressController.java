package com.fpoly.controller;

import java.security.Principal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fpoly.model.UserAddress;
import com.fpoly.service.AddressService;

@Controller
@RequestMapping("/account/addresses")
public class AddressController {

    @Autowired
    private AddressService addressService;

    @GetMapping
    public String danhSach(Model model, Principal principal) {
        List<UserAddress> addresses = addressService.layDanhSachTheoEmail(principal.getName());
        model.addAttribute("addresses", addresses);
        model.addAttribute("title", "Sổ địa chỉ");
        model.addAttribute("content", "account/address-list");
        return "layout/Base";
    }

    @GetMapping("/new")
    public String formThem(@RequestParam(required = false) String returnUrl, Model model) {
        model.addAttribute("address", new UserAddress());
        model.addAttribute("returnUrl", returnUrl);
        model.addAttribute("title", "Thêm địa chỉ mới");
        model.addAttribute("content", "account/address-form");
        return "layout/Base";
    }

    @PostMapping("/new")
    public String xuLyThem(@RequestParam String tenNguoiNhan,
                            @RequestParam String soDienThoai,
                            @RequestParam String diaChiCuThe,
                            @RequestParam String tinhThanh,
                            @RequestParam String quanHuyen,
                            @RequestParam String phuongXa,
                            @RequestParam(required = false, defaultValue = "false") boolean isDefault,
                            @RequestParam(required = false) String returnUrl,
                            Principal principal,
                            RedirectAttributes ra) {
        try {
            addressService.them(principal.getName(), tenNguoiNhan, soDienThoai,
                    diaChiCuThe, tinhThanh, quanHuyen, phuongXa, isDefault);
            ra.addFlashAttribute("success", "Đã thêm địa chỉ mới");
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:" + (returnUrl != null && !returnUrl.isBlank() ? returnUrl : "/account/addresses");
    }

    @GetMapping("/{id}/edit")
    public String formSua(@PathVariable Integer id,
                           @RequestParam(required = false) String returnUrl,
                           Model model, Principal principal,
                           RedirectAttributes ra) {
        try {
            UserAddress address = addressService.layTheoId(id, principal.getName());
            model.addAttribute("address", address);
            model.addAttribute("returnUrl", returnUrl);
            model.addAttribute("title", "Sửa địa chỉ");
            model.addAttribute("content", "account/address-form");
            return "layout/Base";
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/account/addresses";
        }
    }

    @PostMapping("/{id}/edit")
    public String xuLySua(@PathVariable Integer id,
                           @RequestParam String tenNguoiNhan,
                           @RequestParam String soDienThoai,
                           @RequestParam String diaChiCuThe,
                           @RequestParam String tinhThanh,
                           @RequestParam String quanHuyen,
                           @RequestParam String phuongXa,
                           @RequestParam(required = false, defaultValue = "false") boolean isDefault,
                           @RequestParam(required = false) String returnUrl,
                           Principal principal,
                           RedirectAttributes ra) {
        try {
            addressService.sua(id, principal.getName(), tenNguoiNhan, soDienThoai,
                    diaChiCuThe, tinhThanh, quanHuyen, phuongXa, isDefault);
            ra.addFlashAttribute("success", "Đã cập nhật địa chỉ");
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:" + (returnUrl != null && !returnUrl.isBlank() ? returnUrl : "/account/addresses");
    }

    @PostMapping("/{id}/delete")
    public String xoa(@PathVariable Integer id, Principal principal, RedirectAttributes ra) {
        try {
            addressService.xoa(id, principal.getName());
            ra.addFlashAttribute("success", "Đã xóa địa chỉ");
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/account/addresses";
    }

    @PostMapping("/{id}/set-default")
    public String datMacDinh(@PathVariable Integer id, Principal principal, RedirectAttributes ra) {
        try {
            addressService.datLamMacDinh(id, principal.getName());
            ra.addFlashAttribute("success", "Đã đặt làm địa chỉ mặc định");
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/account/addresses";
    }
}