package com.fpoly.controller.admin;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fpoly.model.Order;
import com.fpoly.repository.OrderRepository;
import com.fpoly.service.OrderService;

@Controller
@RequestMapping("/admin/orders")
public class AdminOrderController {

    @Autowired
    private OrderService orderService;

    @Autowired
    private OrderRepository orderRepository;

    // "returned" (Hoàn hàng — hàng đã về kho, tiền chưa trả) tách khỏi "refunded" (đã chuyển
    // tiền lại). Xem OrderService.MO_TA_TRANG_THAI.
    private static final List<String> TRANG_THAI_LIST = List.of(
            "pending", "confirmed", "processing", "shipped", "delivered",
            "cancelled", "returned", "refunded"
    );

    private static final DateTimeFormatter NGAY_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @GetMapping
    public String danhSach(@RequestParam(required = false) String trangThai,
                            @RequestParam(required = false) String tuNgay,
                            @RequestParam(required = false) String denNgay,
                            @RequestParam(required = false) String tenKhachHang,
                            Model model) {

        boolean coLoc = (tuNgay != null && !tuNgay.isBlank())
                || (denNgay != null && !denNgay.isBlank())
                || (tenKhachHang != null && !tenKhachHang.isBlank());

        List<Order> orders;
        if (coLoc) {
            orders = orderRepository.timDonTheoBoLoc(
                    blankToNull(trangThai),
                    parseTuNgay(tuNgay),
                    parseDenNgay(denNgay),
                    blankToNull(tenKhachHang));
        } else if (trangThai != null && !trangThai.isBlank()) {
            orders = orderService.layDonTheoTrangThai(trangThai);
        } else {
            orders = orderService.layTatCaDon();
        }

        model.addAttribute("orders", orders);
        model.addAttribute("trangThaiFilter", trangThai);
        model.addAttribute("tuNgay", tuNgay);
        model.addAttribute("denNgay", denNgay);
        model.addAttribute("tenKhachHang", tenKhachHang);
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

    // ===== API JSON (Nhat) — phục vụ widget đơn hàng trên dashboard / cập nhật nhanh =====

    @GetMapping("/api/orders")
    @ResponseBody
    public Map<String, Object> apiDanhSach(@RequestParam(required = false) String status,
                                            @RequestParam(required = false) String tuNgay,
                                            @RequestParam(required = false) String denNgay,
                                            @RequestParam(required = false) String tenKhachHang) {

        boolean coLoc = (tuNgay != null && !tuNgay.isBlank())
                || (denNgay != null && !denNgay.isBlank())
                || (tenKhachHang != null && !tenKhachHang.isBlank());

        List<Order> orders;
        if (coLoc) {
            orders = orderRepository.timDonTheoBoLoc(
                    blankToNull(status),
                    parseTuNgay(tuNgay),
                    parseDenNgay(denNgay),
                    blankToNull(tenKhachHang));
        } else if (status != null && !status.isBlank()) {
            orders = orderService.layDonTheoTrangThai(status);
        } else {
            orders = orderService.layTatCaDon();
        }

        List<Object[]> rows = orders.stream()
                .map(o -> new Object[]{
                        o.getId(),
                        o.getMaDonHang(),
                        o.getNguoiDung().getEmail(),
                        o.getTongTien(),
                        o.getTrangThai(),
                        o.getCreatedAt().toString().substring(0, 16).replace("T", " ")
                })
                .collect(Collectors.toList());

        return Map.of("success", true, "data", rows);
    }

    @PostMapping("/api/orders/{id}/status")
    @ResponseBody
    public Map<String, Object> apiCapNhatTrangThai(@PathVariable Integer id,
                                                    @RequestParam String status) {
        try {
            orderService.capNhatTrangThai(id, status, null);
            return Map.of("success", true);
        } catch (RuntimeException e) {
            return Map.of("success", false, "error", e.getMessage());
        }
    }

    // ===== Helpers =====

    private String blankToNull(String s) {
        return (s == null || s.isBlank()) ? null : s;
    }

    /** yyyy-MM-dd -> LocalDateTime lúc 00:00:00 (mốc bắt đầu, inclusive). */
    private LocalDateTime parseTuNgay(String s) {
        if (s == null || s.isBlank()) return null;
        return LocalDate.parse(s, NGAY_FORMAT).atStartOfDay();
    }

    /** yyyy-MM-dd -> LocalDateTime của NGÀY KẾ TIẾP lúc 00:00:00 (mốc kết thúc, exclusive) để bao trọn cả ngày denNgay. */
    private LocalDateTime parseDenNgay(String s) {
        if (s == null || s.isBlank()) return null;
        return LocalDate.parse(s, NGAY_FORMAT).plusDays(1).atStartOfDay();
    }
}
