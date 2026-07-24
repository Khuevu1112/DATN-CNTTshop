package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.InstallmentDtos.DonAdminDto;
import com.fpoly.dto.InstallmentDtos.DuyetRequest;
import com.fpoly.model.enums.PermissionType;
import com.fpoly.security.RequirePermission;
import com.fpoly.service.InstallmentService;

/** Trả góp — phía nhân viên: thẩm định hồ sơ, duyệt hoặc từ chối.
 *
 * Bản trả về ở đây CÓ số CCCD của khách (cần để thẩm định), nên toàn bộ endpoint đứng sau quyền
 * "installment" — khác với API khách hàng vốn không bao giờ trả trường đó. */
@RestController
@RequestMapping("/api/admin/installment")
public class AdminInstallmentApiController {

    @Autowired private InstallmentService installmentService;

    @GetMapping
    @RequirePermission(feature = "installment", action = PermissionType.VIEW)
    public List<DonAdminDto> danhSach(@RequestParam(required = false) String trangThai) {
        return installmentService.tatCaDon(trangThai);
    }

    @PostMapping("/{id}/duyet")
    @RequirePermission(feature = "installment", action = PermissionType.EDIT)
    public DonAdminDto duyet(@PathVariable Integer id, @RequestBody(required = false) DuyetRequest req) {
        return installmentService.doiTrangThai(id, "APPROVED", req == null ? null : req.ghiChu());
    }

    @PostMapping("/{id}/tu-choi")
    @RequirePermission(feature = "installment", action = PermissionType.EDIT)
    public DonAdminDto tuChoi(@PathVariable Integer id, @RequestBody(required = false) DuyetRequest req) {
        return installmentService.doiTrangThai(id, "REJECTED", req == null ? null : req.ghiChu());
    }

    @PostMapping("/{id}/huy")
    @RequirePermission(feature = "installment", action = PermissionType.EDIT)
    public DonAdminDto huy(@PathVariable Integer id, @RequestBody(required = false) DuyetRequest req) {
        return installmentService.doiTrangThai(id, "CANCELLED", req == null ? null : req.ghiChu());
    }
}
