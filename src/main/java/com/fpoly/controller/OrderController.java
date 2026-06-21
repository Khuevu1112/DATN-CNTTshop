package com.fpoly.controller;

import java.security.Principal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fpoly.model.Order;
import com.fpoly.model.UserAddress;
import com.fpoly.service.AddressService;
import com.fpoly.service.CartService;
import com.fpoly.service.OrderService;

@Controller
public class OrderController {

    @Autowired
    private OrderService orderService;

    @Autowired
    private CartService cartService;

    @Autowired
    private AddressService addressService;

    @GetMapping("/orders")
    public String danhSachDon(Model model, Principal principal) {
        List<Order> orders = orderService.layDonHangCuaUser(principal.getName());
        model.addAttribute("orders", orders);
        model.addAttribute("title", "Đơn hàng của tôi");
        model.addAttribute("content", "order/index");
        return "layout/Base";
    }

    @GetMapping("/orders/{id}")
    public String chiTietDon(@PathVariable Integer id,
                              Model model,
                              Principal principal,
                              RedirectAttributes ra) {
        try {
            Order order = orderService.layChiTietDon(id, principal.getName());
            model.addAttribute("order", order);
            model.addAttribute("title", "Chi tiết đơn " + order.getMaDonHang());
            model.addAttribute("content", "order/detail");
            return "layout/Base";
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/orders";
        }
    }

    @GetMapping("/orders/checkout")
    public String checkoutForm(Model model, Principal principal, RedirectAttributes ra) {
        if (cartService.demSoLuongItem(principal.getName()) == 0) {
            ra.addFlashAttribute("error", "Giỏ hàng đang trống");
            return "redirect:/cart";
        }

        List<UserAddress> addresses = addressService.layDanhSachTheoEmail(principal.getName());

        model.addAttribute("items", cartService.layDanhSachItem(principal.getName()));
        model.addAttribute("tongTienHang", cartService.tinhTongTien(principal.getName()));
        model.addAttribute("addresses", addresses);
        model.addAttribute("title", "Xác nhận đặt hàng");
        model.addAttribute("content", "order/checkout");
        return "layout/Base";
    }

    @PostMapping("/orders/place")
    public String datHang(@RequestParam Integer addressId,
                           Principal principal,
                           RedirectAttributes ra) {
        try {
            Order order = orderService.datHangTuGioHang(principal.getName(), addressId);
            ra.addFlashAttribute("success", "Đặt hàng thành công! Mã đơn: " + order.getMaDonHang());
            return "redirect:/orders/" + order.getId();
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/orders/checkout";
        }
    }

    @PostMapping("/orders/{id}/cancel")
    public String huyDon(@PathVariable Integer id,
                          Principal principal,
                          RedirectAttributes ra) {
        try {
            orderService.huyDon(id, principal.getName());
            ra.addFlashAttribute("success", "Đã hủy đơn hàng");
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/orders/" + id;
    }
}