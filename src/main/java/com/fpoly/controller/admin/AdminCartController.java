package com.fpoly.controller.admin;

import java.util.Comparator;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.fpoly.model.OrderItem;
import com.fpoly.repository.OrderItemRepository;

/**
 * Quản lý giỏ hàng (Admin): bảng thống kê các sản phẩm khách đã đặt trong đơn.
 * Khách đặt thế nào hiển thị y vậy (lấy từ ORDER_ITEM).
 */
@Controller
@RequestMapping("/admin/gio-hang")
public class AdminCartController {

    @Autowired
    private OrderItemRepository orderItemRepo;

    @GetMapping
    @Transactional(readOnly = true)
    public String index(Model model) {
        List<OrderItem> items = orderItemRepo.findAll();
        // gom các sản phẩm cùng một đơn lại gần nhau
        items.sort(Comparator.comparing((OrderItem i) -> i.getOrder().getId()));

        model.addAttribute("items", items);
        model.addAttribute("title", "Quản lý giỏ hàng");
        model.addAttribute("content", "admin/cart-management");
        return "layout/Base";
    }
}
