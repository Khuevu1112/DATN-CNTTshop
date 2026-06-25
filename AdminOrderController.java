package com.fpoly.controller.admin;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fpoly.model.Order;
import com.fpoly.model.Payment;
import com.fpoly.repository.PaymentRepository;
import com.fpoly.service.OrderService;

@Controller
@RequestMapping("/admin/orders")
public class AdminOrderController {

    @Autowired
    private OrderService orderService;

    @Autowired
    private PaymentRepository paymentRepo;

    private static final List<String> TRANG_THAI_LIST = List.of(
            "pending",
            "confirmed",
            "processing",
            "shipped",
            "delivered",
            "cancelled",
            "refunded"
    );

    // ======================
    // XÁC NHẬN THANH TOÁN COD
    // ======================

    @PostMapping("/{id}/payment-confirm")
    public String confirmPayment(
            @PathVariable Integer id,
            RedirectAttributes ra) {

        try {

            Order order = orderService.layDonById(id);

            Payment payment =
                    paymentRepo.findByOrder(order)
                    .orElseThrow(() ->
                            new RuntimeException(
                                    "Không tìm thấy thanh toán"));

            payment.setStatus("paid");
            payment.setPaidAt(LocalDateTime.now());

            paymentRepo.save(payment);

            ra.addFlashAttribute(
                    "success",
                    "Đã xác nhận thanh toán");

        } catch (Exception e) {

            ra.addFlashAttribute(
                    "error",
                    e.getMessage());
        }

        return "redirect:/admin/orders/" + id;
    }

    // ======================
    // DANH SÁCH ĐƠN
    // ======================

    @GetMapping
    public String danhSach(
            @RequestParam(required = false)
            String trangThai,

            Model model) {

        List<Order> orders =
                (trangThai != null
                        && !trangThai.isBlank())

                        ? orderService
                                .layDonTheoTrangThai(
                                        trangThai)

                        : orderService
                                .layTatCaDon();

        model.addAttribute(
                "orders",
                orders);

        model.addAttribute(
                "trangThaiFilter",
                trangThai);

        model.addAttribute(
                "trangThaiList",
                TRANG_THAI_LIST);

        model.addAttribute(
                "title",
                "Quản lý đơn hàng");

        model.addAttribute(
                "content",
                "admin/order-list");

        return "layout/Base";
    }

    // ======================
    // CHI TIẾT ĐƠN
    // ======================

    @GetMapping("/{id}")
    public String chiTiet(
            @PathVariable Integer id,
            Model model) {

        Order order =
                orderService
                        .layDonById(id);

        Payment payment =
                paymentRepo
                        .findByOrder(order)
                        .orElse(null);

        model.addAttribute(
                "payment",
                payment);

        model.addAttribute(
                "order",
                order);

        model.addAttribute(
                "trangThaiList",
                TRANG_THAI_LIST);

        model.addAttribute(
                "title",
                "Chi tiết đơn "
                        + order.getMaDonHang());

        model.addAttribute(
                "content",
                "admin/order-detail");

        return "layout/Base";
    }

    // ======================
    // CẬP NHẬT TRẠNG THÁI
    // ======================

    @PostMapping("/{id}/status")
    public String capNhatTrangThai(

            @PathVariable Integer id,

            @RequestParam
            String trangThai,

            @RequestParam(
                    required = false)
            String ghiChu,

            RedirectAttributes ra) {

        try {

            orderService
                    .capNhatTrangThai(
                            id,
                            trangThai,
                            ghiChu);

            ra.addFlashAttribute(
                    "success",
                    "Đã cập nhật trạng thái");

        } catch (
                RuntimeException e) {

            ra.addFlashAttribute(
                    "error",
                    e.getMessage());
        }

        return "redirect:/admin/orders/" + id;
    }

    // ======================
    // API JSON DANH SÁCH
    // ======================

    @GetMapping("/api/orders")
    @ResponseBody
    public Map<String, Object>
    apiDanhSach(

            @RequestParam(
                    required = false)
            String status) {

        List<Order> orders =
                (status != null
                        && !status.isBlank())

                        ? orderService
                                .layDonTheoTrangThai(
                                        status)

                        : orderService
                                .layTatCaDon();

        List<Object[]> rows =
                orders.stream()

                        .map(o ->
                                new Object[]{

                                        o.getId(),

                                        o.getMaDonHang(),

                                        o.getNguoiDung()
                                                .getEmail(),

                                        o.getTongTien(),

                                        o.getTrangThai(),

                                        o.getCreatedAt()
                                                .toString()
                                                .substring(
                                                        0,
                                                        16)
                                                .replace(
                                                        "T",
                                                        " ")

                                })

                        .collect(
                                Collectors
                                        .toList());

        return Map.of(
                "success",
                true,

                "data",
                rows);
    }

    // ======================
    // API UPDATE TRẠNG THÁI
    // ======================

    @PostMapping(
            "/api/orders/{id}/status")

    @ResponseBody
    public Map<String, Object>
    apiCapNhatTrangThai(

            @PathVariable
            Integer id,

            @RequestParam
            String status) {

        try {

            orderService
                    .capNhatTrangThai(
                            id,
                            status,
                            null);

            return Map.of(
                    "success",
                    true);

        } catch (
                RuntimeException e) {

            return Map.of(
                    "success",
                    false,

                    "error",
                    e.getMessage());
        }
    }
}