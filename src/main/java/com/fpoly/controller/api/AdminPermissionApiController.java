package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.PermissionDtos.MyPermissionsDto;
import com.fpoly.dto.PermissionDtos.PermissionMetaDto;
import com.fpoly.dto.PermissionDtos.RoleGrantDto;
import com.fpoly.dto.PermissionDtos.UpdateCellRequest;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.enums.PermissionType;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.security.RequirePermission;
import com.fpoly.service.PermissionAdminService;

/** Trang "Phân quyền" — chỉ admin (feature "permissions" không phòng ban nào có quyền nào cả).
 * Riêng /me KHÔNG gắn @RequirePermission — đây là API để FE tự hỏi "tôi có quyền gì", mọi tài
 * khoản (admin + 6 phòng ban) đều phải gọi được, kể cả khi họ chưa có quyền "permissions". */
@RestController
@RequestMapping("/api/admin/permissions")
public class AdminPermissionApiController {

    @Autowired private PermissionAdminService permissionAdminService;
    @Autowired private NguoiDungRepository nguoiDungRepo;

    @GetMapping("/meta")
    @RequirePermission(feature = "permissions", action = PermissionType.VIEW)
    public PermissionMetaDto meta() {
        return permissionAdminService.getMeta();
    }

    @GetMapping("/matrix")
    @RequirePermission(feature = "permissions", action = PermissionType.VIEW)
    public List<RoleGrantDto> matrix() {
        return permissionAdminService.getMatrix();
    }

    @PutMapping("/matrix/{department}/{featureKey}")
    @RequirePermission(feature = "permissions", action = PermissionType.EDIT)
    public RoleGrantDto updateCell(
            @PathVariable String department,
            @PathVariable String featureKey,
            @RequestBody UpdateCellRequest req) {
        return permissionAdminService.updateCell(department, featureKey, req.permKeys());
    }

    @GetMapping("/me")
    public MyPermissionsDto me(Authentication auth) {
        NguoiDung nguoiDung = nguoiDungRepo.findByEmail(auth.getName())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản"));
        return permissionAdminService.getMyPermissions(nguoiDung);
    }
}
