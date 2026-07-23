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
    public String sendOtp(@RequestParam String email, Model model) {
        String error = service.guiOtp(email);
        if (error != null) {
            model.addAttribute("error", error);
            model.addAttribute("email", email);
            return "auth/forgot-password";
        }
        model.addAttribute("email", email);
        return "auth/verify-otp";
    }

    @PostMapping("/DustNovel/verify-otp")
    public String verifyOtp(@RequestParam String email, @RequestParam String otp, Model model) {
        String error = service.xacThucOtp(email, otp);
        if (error != null) {
            model.addAttribute("error", error);
            model.addAttribute("email", email);
            return "auth/verify-otp";
        }
        model.addAttribute("email", email);
        model.addAttribute("otp", otp);
        return "auth/reset-password";
    }

    @PostMapping("/DustNovel/reset-password")
    public String resetPassword(
            @RequestParam String email,
            @RequestParam String otp,
            @RequestParam String matKhauMoi,
            @RequestParam String nhapLaiMatKhau,
            Model model,
            RedirectAttributes redirectAttributes
    ) {
        String error = service.datLaiMatKhau(email, otp, matKhauMoi, nhapLaiMatKhau);
        if (error != null) {
            model.addAttribute("error", error);
            model.addAttribute("email", email);
            model.addAttribute("otp", otp);
            return "auth/reset-password";
        }
        redirectAttributes.addFlashAttribute("success", "Đổi mật khẩu thành công, vui lòng đăng nhập");
        return "redirect:/DustNovel/login";
    }
}
