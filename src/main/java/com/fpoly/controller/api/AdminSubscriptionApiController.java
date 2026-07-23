package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.dto.SubscriptionDtos.AdminPlanDto;
import com.fpoly.dto.SubscriptionDtos.MemberDetailDto;
import com.fpoly.dto.SubscriptionDtos.MemberRowDto;
import com.fpoly.dto.SubscriptionDtos.PlanEditRequest;
import com.fpoly.model.enums.PermissionType;
import com.fpoly.security.RequirePermission;
import com.fpoly.service.SubscriptionService;

/** Quản lý hội viên (gói trả phí) phía admin — dùng cho admin-vue.
 *
 * CHỈ ADMIN vào được: feature "membership_admin" CỐ Ý không được cấp cho phòng ban nào trong
 * ROLE_PERMISSION, nên PermissionAspect chỉ cho qua với vai trò admin (admin luôn bỏ qua kiểm
 * tra), mọi phòng ban khác nhận 422. Đây là cách "admin-only" nhất quán với hệ RBAC hiện có,
 * không phải thêm quyền mới vào ma trận 8-quyền cố định. */
@RestController
@RequestMapping("/api/admin/membership")
public class AdminSubscriptionApiController {

    @Autowired private SubscriptionService subscriptionService;

    /** Danh sách hội viên (cột trái). */
    @GetMapping("/members")
    @RequirePermission(feature = "membership_admin", action = PermissionType.VIEW)
    public List<MemberRowDto> members() {
        return subscriptionService.danhSachHoiVien();
    }

    /** Chi tiết 1 hội viên (cột phải). */
    @GetMapping("/members/{userId}")
    @RequirePermission(feature = "membership_admin", action = PermissionType.VIEW)
    public MemberDetailDto memberDetail(@PathVariable Integer userId) {
        return subscriptionService.chiTietHoiVien(userId);
    }

    /** Toàn bộ gói (kể cả đã tắt) cho trình sửa giá + ưu đãi. */
    @GetMapping("/plans")
    @RequirePermission(feature = "membership_admin", action = PermissionType.VIEW)
    public List<AdminPlanDto> plans() {
        return subscriptionService.danhSachGoiTatCa();
    }

    /** Sửa giá + ưu đãi 1 gói. Bị chặn nếu đặt giá thấp hơn chi phí ưu đãi tối đa/năm (xem
     * SubscriptionService.capNhatGoi) — enforce ngay ở API, không chỉ trong test. */
    @PutMapping("/plans/{id}")
    @RequirePermission(feature = "membership_admin", action = PermissionType.EDIT)
    public AdminPlanDto updatePlan(@PathVariable Integer id, @RequestBody PlanEditRequest req) {
        return subscriptionService.capNhatGoi(id, req);
    }
}
