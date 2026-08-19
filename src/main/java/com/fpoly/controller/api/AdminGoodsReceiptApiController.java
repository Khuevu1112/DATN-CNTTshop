package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.GoodsReceiptDtos.LuuPhieuNhapRequest;
import com.fpoly.dto.GoodsReceiptDtos.LuuSupplierRequest;
import com.fpoly.dto.GoodsReceiptDtos.PhieuNhapDto;
import com.fpoly.dto.GoodsReceiptDtos.SupplierDto;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.enums.PermissionType;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.security.RequirePermission;
import com.fpoly.service.GoodsReceiptService;

/**
 * Nhập kho theo chứng từ: nhà cung cấp + phiếu nhập nhiều dòng.
 *
 * Dùng chung quyền "products_manage" với việc sửa sản phẩm — ai được sửa kho/giá thì cũng là
 * người lập phiếu nhập, không cần dựng thêm một feature quyền riêng chỉ có đúng một màn hình.
 */
@RestController
@RequestMapping("/api/admin")
public class AdminGoodsReceiptApiController {

    @Autowired private GoodsReceiptService goodsReceiptService;
    @Autowired private NguoiDungRepository nguoiDungRepo;

    private NguoiDung currentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return nguoiDungRepo.findByEmail(email).orElse(null);
    }

    // ===== Nhà cung cấp =====

    @GetMapping("/suppliers")
    @RequirePermission(feature = "products_view", action = PermissionType.VIEW)
    public List<SupplierDto> suppliers(@RequestParam(required = false) Boolean tatCa) {
        return goodsReceiptService.danhSachNhaCungCap(!Boolean.TRUE.equals(tatCa));
    }

    @PostMapping("/suppliers")
    @RequirePermission(feature = "products_manage", action = PermissionType.ADD)
    public SupplierDto createSupplier(@RequestBody LuuSupplierRequest req) {
        return goodsReceiptService.luuNhaCungCap(null, req);
    }

    @PutMapping("/suppliers/{id}")
    @RequirePermission(feature = "products_manage", action = PermissionType.EDIT)
    public SupplierDto updateSupplier(@PathVariable Integer id, @RequestBody LuuSupplierRequest req) {
        return goodsReceiptService.luuNhaCungCap(id, req);
    }

    // ===== Phiếu nhập kho =====

    @GetMapping("/goods-receipts")
    @RequirePermission(feature = "products_view", action = PermissionType.VIEW)
    public List<PhieuNhapDto> receipts() {
        return goodsReceiptService.danhSachPhieu();
    }

    @GetMapping("/goods-receipts/{id}")
    @RequirePermission(feature = "products_view", action = PermissionType.VIEW)
    public PhieuNhapDto receiptDetail(@PathVariable Integer id) {
        return goodsReceiptService.chiTietPhieu(id);
    }

    @PostMapping("/goods-receipts")
    @RequirePermission(feature = "products_manage", action = PermissionType.EDIT)
    public PhieuNhapDto createReceipt(@RequestBody LuuPhieuNhapRequest req) {
        return goodsReceiptService.lapPhieu(req, currentUser());
    }
}
