package com.fpoly.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ReturnPolicyController {

    @GetMapping("/doi-tra")
    public String chinhSachDoiTra(Model model) {
        model.addAttribute("title", "Chính sách đổi trả");
        model.addAttribute("content", "return/policy");
        return "layout/Base";
    }
}
