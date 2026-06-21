package com.fpoly.controller;

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.stereotype.Controller;

import org.springframework.ui.Model;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.fpoly.model.NguoiDung;
import com.fpoly.service.RegisterService;

@Controller
public class AuthController {

    @Autowired
    private RegisterService registerService;

    /*
        FORM LOGIN
    */
    @GetMapping("/login")
    public String loginPage() {

        return "auth/Login";
    }

    /*
        FORM REGISTER
    */
    @GetMapping("/register")
    public String registerPage(Model model) {

        model.addAttribute(
                "nguoiDung",
                new NguoiDung()
        );

        return "auth/register";
    }

    /*
        XỬ LÝ ĐĂNG KÝ
    */
    @PostMapping("/register")
    public String register(
            @ModelAttribute NguoiDung nguoiDung,
            @RequestParam String reMatKhau,
            Model model
    ) {

        String error =
                registerService.register(
                        nguoiDung,
                        reMatKhau
                );

        /*
            Nếu có lỗi
        */
        if (error != null) {

            model.addAttribute(
                    "error",
                    error
            );

            return "auth/register";
        }

        /*
            Thành công -> về login
        */
        return "redirect:/login";
    }
}