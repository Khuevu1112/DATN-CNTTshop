package com.fpoly.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fpoly.service.ForgotPasswordService;

@Controller
public class ForgotPasswordController {

    @Autowired
    private ForgotPasswordService service;

    @GetMapping("/DustNovel/forgot-password")
    public String forgotPasswordForm() {
        return "auth/forgot-password";
    }

    @PostMapping("/DustNovel/forgot-password")
    public String resetPassword(
            @RequestParam String email,
            @RequestParam String matKhauMoi,
            @RequestParam String nhapLaiMatKhau,
            Model model,
            RedirectAttributes redirectAttributes
    ) {

        String error = service.resetPassword(
                email,
                matKhauMoi,
                nhapLaiMatKhau
        );

        if (error != null) {
            model.addAttribute("error", error);
            model.addAttribute("email", email);
            return "auth/forgot-password";
        }

        redirectAttributes.addFlashAttribute(
                "success",
                "Đổi mật khẩu thành công, vui lòng đăng nhập"
        );

        return "redirect:/DustNovel/login";
    }
}