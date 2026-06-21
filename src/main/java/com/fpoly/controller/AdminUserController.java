package com.fpoly.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fpoly.model.enums.VaiTro;
import com.fpoly.service.AdminUserService;

@Controller
@RequestMapping("/admin/users")
public class AdminUserController {

    @Autowired
    private AdminUserService adminUserService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("users", adminUserService.findAll());
        return "admin/user-list";
    }

    @GetMapping("/edit/{id}")
    public String edit(@PathVariable Integer id, Model model) {
        model.addAttribute("user", adminUserService.findById(id));
        model.addAttribute("roles", VaiTro.values());
        return "admin/user-edit";
    }

    @PostMapping("/update")
    public String update(
            @RequestParam Integer id,
            @RequestParam String hoTen,
            @RequestParam String soDienThoai,
            @RequestParam VaiTro vaiTro,
            @RequestParam(required = false, defaultValue = "false") Boolean isActive,
            RedirectAttributes ra
    ) {
        adminUserService.updateUser(id, hoTen, soDienThoai, vaiTro, isActive);
        ra.addFlashAttribute("success", "Cập nhật tài khoản thành công");
        return "redirect:/admin/users";
    }
    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Integer id, RedirectAttributes ra) {
        String error = adminUserService.deleteUser(id);

        if (error != null) {
            ra.addFlashAttribute("error", error);
        } else {
            ra.addFlashAttribute("success", "Xóa tài khoản thành công");
        }

        return "redirect:/admin/users";
    }
}