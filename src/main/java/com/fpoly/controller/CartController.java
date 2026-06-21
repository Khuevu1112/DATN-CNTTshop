package com.fpoly.controller;

import java.security.Principal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fpoly.model.CartItem;
import com.fpoly.service.CartService;

@Controller
public class CartController {

    @Autowired
    private CartService cartService;

    @GetMapping("/cart")
    public String xemGioHang(Model model, Principal principal) {
        List<CartItem> items = cartService.layDanhSachItem(principal.getName());
        model.addAttribute("items", items);
        model.addAttribute("tongTien", cartService.tinhTongTien(principal.getName()));
        model.addAttribute("title", "Giỏ hàng");
        model.addAttribute("content", "cart/index");
        return "layout/Base";
    }

@PostMapping("/cart/add")
public String themVaoGio(@RequestParam Integer variantId,
                          @RequestParam Integer quantity,
                          @RequestParam(required = false) String redirect,
                          Principal principal,
                          RedirectAttributes ra) {
    try {
        cartService.themVaoGio(principal.getName(), variantId, quantity);
        ra.addFlashAttribute("success", "Đã thêm sản phẩm vào giỏ hàng");
    } catch (RuntimeException e) {
        ra.addFlashAttribute("error", e.getMessage());
        return "redirect:/cart";
    }

    if ("checkout".equals(redirect)) {
        return "redirect:/orders/checkout";
    }
    return "redirect:/cart";
}

    @PostMapping("/cart/update")
    public String capNhatSoLuong(@RequestParam Integer itemId,
                                  @RequestParam Integer quantity,
                                  Principal principal,
                                  RedirectAttributes ra) {
        try {
            cartService.capNhatSoLuong(principal.getName(), itemId, quantity);
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/cart";
    }

    @PostMapping("/cart/remove")
    public String xoaItem(@RequestParam Integer itemId,
                           Principal principal,
                           RedirectAttributes ra) {
        try {
            cartService.xoaItem(principal.getName(), itemId);
            ra.addFlashAttribute("success", "Đã xóa sản phẩm khỏi giỏ hàng");
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/cart";
    }
}