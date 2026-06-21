package com.fpoly.controller.admin;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fpoly.model.Order;
import com.fpoly.service.OrderService;

@Controller
@RequestMapping("/admin/orders")
public class AdminOrderController {

    @Autowired
    private OrderService orderService;

    private static final List<String> TRANG_THAI_LIST = List.of(
            "pending", "confirmed", "processing", "shipped", "delivered", "cancelled", "refunded"
    );

    @GetMapping
    public String danhSach(@RequestParam(required = false) String trangThai, Model model) {
        List<Order> orders = (trangThai != null && !trangThai.isBlank())
                ? orderService.layDonTheoTrangThai(trangThai)
                : orderService.layTatCaDon();

        model.addAttribute("orders", orders);
        model.addAttribute("trangThaiFilter", trangThai);
        model.addAttribute("trangThaiList", TRANG_THAI_LIST);
        model.addAttribute("title", "Quản lý đơn hàng");
        model.addAttribute("content", "admin/order-list");
        return "layout/Base";
    }

    @GetMapping("/{id}")
    public String chiTiet(@PathVariable Integer id, Model model) {
        Order order = orderService.layDonById(id);
        model.addAttribute("order", order);
        model.addAttribute("trangThaiList", TRANG_THAI_LIST);
        model.addAttribute("title", "Chi tiết đơn " + order.getMaDonHang());
        model.addAttribute("content", "admin/order-detail");
        return "layout/Base";
    }

    @PostMapping("/{id}/status")
    public String capNhatTrangThai(@PathVariable Integer id,
                                    @RequestParam String trangThai,
                                    @RequestParam(required = false) String ghiChu,
                                    RedirectAttributes ra) {
        try {
            orderService.capNhatTrangThai(id, trangThai, ghiChu);
            ra.addFlashAttribute("success", "Đã cập nhật trạng thái đơn hàng");
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/orders/" + id;
    }
}