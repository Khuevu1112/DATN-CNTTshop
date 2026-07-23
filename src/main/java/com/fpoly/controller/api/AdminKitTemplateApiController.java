package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.KitTemplateDtos.KitTemplateDetailDto;
import com.fpoly.dto.KitTemplateDtos.KitTemplateSummaryDto;
import com.fpoly.dto.KitTemplateDtos.SaveKitTemplateRequest;
import com.fpoly.dto.KitTemplateDtos.VariantSearchResultDto;
import com.fpoly.model.enums.PermissionType;
import com.fpoly.security.RequirePermission;
import com.fpoly.service.KitTemplateService;

/** Quản lý "Mẫu cấu hình PC" — chỉ admin/nhân viên dùng (xem SecurityConfig: /api/admin/** yêu cầu role ADMIN hoặc 1 trong 6 phòng ban). */
@RestController
@RequestMapping("/api/admin/kit-templates")
public class AdminKitTemplateApiController {

    @Autowired private KitTemplateService kitTemplateService;

    @GetMapping
    @RequirePermission(feature = "kit_templates_view", action = PermissionType.VIEW)
    public List<KitTemplateSummaryDto> list() {
        return kitTemplateService.layDanhSach();
    }

    @GetMapping("/variant-search")
    @RequirePermission(feature = "kit_templates_manage", action = PermissionType.VIEW)
    public List<VariantSearchResultDto> searchVariants(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String componentType) {
        return kitTemplateService.timSanPham(keyword, componentType);
    }

    @GetMapping("/{id}")
    @RequirePermission(feature = "kit_templates_view", action = PermissionType.VIEW)
    public KitTemplateDetailDto detail(@PathVariable Integer id) {
        return kitTemplateService.layChiTiet(id);
    }

    @PostMapping
    @RequirePermission(feature = "kit_templates_manage", action = PermissionType.ADD)
    public KitTemplateDetailDto create(@RequestBody SaveKitTemplateRequest req) {
        return kitTemplateService.tao(req);
    }

    @PutMapping("/{id}")
    @RequirePermission(feature = "kit_templates_manage", action = PermissionType.EDIT)
    public KitTemplateDetailDto update(@PathVariable Integer id, @RequestBody SaveKitTemplateRequest req) {
        return kitTemplateService.capNhat(id, req);
    }

    @DeleteMapping("/{id}")
    @RequirePermission(feature = "kit_templates_manage", action = PermissionType.DELETE)
    public void delete(@PathVariable Integer id) {
        kitTemplateService.xoa(id);
    }
}
