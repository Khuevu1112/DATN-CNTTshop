package com.fpoly.controller.cilent;

import java.security.Principal;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.fpoly.model.NguoiDung;
import com.fpoly.service.UserAccountService;

@Controller
@RequestMapping("/account")
public class AccountController {

    @Autowired
    private UserAccountService userAccountService;

    @GetMapping("/profile")
    public String profile(Model model, Principal principal) {

        NguoiDung user = userAccountService.findByEmail(principal.getName());

        model.addAttribute("user", user);

        return "account/profile";
    }

    @PostMapping("/profile")
    public String updateProfile(
            Principal principal,
            @RequestParam String hoTen,
            @RequestParam String soDienThoai
    ) {

        userAccountService.updateProfile(
                principal.getName(),
                hoTen,
                soDienThoai
        );

        return "redirect:/account/profile?success=true";
    }
}