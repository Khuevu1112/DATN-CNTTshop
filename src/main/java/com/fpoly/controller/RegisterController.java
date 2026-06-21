package com.fpoly.controller;

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.stereotype.Controller;

import org.springframework.ui.Model;

import org.springframework.web.bind.annotation.*;

import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fpoly.model.NguoiDung;
import com.fpoly.service.RegisterService;

@Controller
public class RegisterController {

    @Autowired
    private RegisterService service;

    @GetMapping("/DustNovel/register")
    public String registerForm(Model model) {

        model.addAttribute(
                "nguoiDung",
                new NguoiDung()
        );

        return "auth/register";
    }

    @PostMapping("/DustNovel/register")
    public String register(

            @ModelAttribute NguoiDung nguoiDung,

            @RequestParam String reMatKhau,

            Model model,

            RedirectAttributes redirectAttributes
    ) {

        String error =
                service.register(
                        nguoiDung,
                        reMatKhau
                );

        if (error != null) {

            model.addAttribute(
                    "error",
                    error
            );

            return "auth/register";
        }

        redirectAttributes.addFlashAttribute(
                "success",
                "Đăng ký thành công"
        );

        return "redirect:/DustNovel/login";
    }
}