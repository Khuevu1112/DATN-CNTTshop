package com.fpoly.controller.api;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.TrackingDtos.TrackingStatusDto;
import com.fpoly.model.Order;
import com.fpoly.repository.OrderRepository;
import com.fpoly.service.TrackingService;

/**
 * Tracking vận chuyển cho đơn đã bàn giao GHN hoặc Shopee Express.
 * Yêu cầu đăng nhập — chỉ chủ đơn hoặc staff mới xem được (kiểm tra ownership bên dưới).
 */
@RestController
@RequestMapping("/api/orders")
public class TrackingApiController {

    @Autowired private OrderRepository orderRepo;
    @Autowired private TrackingService trackingService;

    @GetMapping("/{orderId}/tracking")
    public TrackingStatusDto tracking(@PathVariable Integer orderId, Authentication auth) {
        Order order = orderRepo.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));

        boolean laStaff = auth.getAuthorities().stream()
                .anyMatch(a -> !a.getAuthority().equals("ROLE_CUSTOMER"));
        boolean laChuDon = order.getNguoiDung().getEmail().equals(auth.getName());

        if (!laStaff && !laChuDon) {
            throw new RuntimeException("Không có quyền xem đơn hàng này");
        }

        return trackingService.layTrangThai(order)
                .orElseThrow(() -> new RuntimeException(
                        "Đơn hàng chưa có thông tin vận chuyển (chưa bàn giao hãng, hoặc hãng không hỗ trợ tra cứu)"));
    }
}
