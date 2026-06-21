package com.fpoly.controller;

import org.springframework.stereotype.Controller;

import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class LoginController {

    @GetMapping("/DustNovel/login")
    public String login() {

        return "auth/login";
    }
}