package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.StockMovementDtos.StockMovementDto;
import com.fpoly.dto.StockMovementDtos.StockMovementRequest;
import com.fpoly.dto.StockMovementDtos.VariantPickResultDto;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.enums.PermissionType;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.security.RequirePermission;
import com.fpoly.service.StockMovementService;

/** Quản lý nhập hàng / điều chỉnh kho — chỉ admin/nhân viên dùng (xem SecurityConfig: /api/admin/** yêu cầu role ADMIN hoặc 1 trong 6 phòng ban). */
@RestController
@RequestMapping("/api/admin/stock-movements")
public class AdminStockMovementApiController {

    @Autowired private StockMovementService stockMovementService;
    @Autowired private NguoiDungRepository nguoiDungRepo;

    private NguoiDung nguoiHienTai(Authentication auth) {
        return nguoiDungRepo.findByEmail(auth.getName())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản"));
    }

    @GetMapping("/variant-search")
    @RequirePermission(feature = "stock_movement", action = PermissionType.VIEW)
    public List<VariantPickResultDto> timBienThe(@RequestParam(required = false) String keyword) {
        return stockMovementService.timBienThe(keyword);
    }

    @PostMapping
    @RequirePermission(feature = "stock_movement", action = PermissionType.ADD)
    public StockMovementDto create(@RequestBody StockMovementRequest req, Authentication auth) {
        return stockMovementService.taoPhieu(req, nguoiHienTai(auth));
    }

    @GetMapping
    @RequirePermission(feature = "stock_movement", action = PermissionType.VIEW)
    public List<StockMovementDto> recent(@RequestParam(defaultValue = "50") int limit) {
        return stockMovementService.lichSuGanDay(limit);
    }

    @GetMapping("/variant/{variantId}")
    @RequirePermission(feature = "stock_movement", action = PermissionType.VIEW)
    public List<StockMovementDto> byVariant(@PathVariable Integer variantId) {
        return stockMovementService.lichSuTheoBienThe(variantId);
    }
}
