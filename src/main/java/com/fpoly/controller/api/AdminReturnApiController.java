package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.ReturnDtos.DoiTrangThaiRequest;
import com.fpoly.dto.ReturnDtos.DonChoDoiTraDto;
import com.fpoly.dto.ReturnDtos.ReturnDto;
import com.fpoly.dto.ReturnDtos.TaoYeuCauAdminRequest;
import com.fpoly.model.enums.PermissionType;
import com.fpoly.security.RequirePermission;
import com.fpoly.service.ReturnRequestService;

/** Đổi trả hàng — phía CSKH. Quyền "return_request" (xem 71_return_request.sql). */
@RestController
@RequestMapping("/api/admin/returns")
public class AdminReturnApiController {

    @Autowired private ReturnRequestService service;

    @GetMapping
    @RequirePermission(feature = "return_request", action = PermissionType.VIEW)
    public List<ReturnDto> danhSach(@RequestParam(required = false) String trangThai) {
        return service.tatCa(trangThai);
    }

    /** Tra cứu đơn để CSKH chọn đúng dòng sản phẩm cần đổi/trả trước khi tạo yêu cầu. */
    @GetMapping("/tra-cuu-don")
    @RequirePermission(feature = "return_request", action = PermissionType.VIEW)
    public DonChoDoiTraDto traCuuDon(@RequestParam String maDon) {
        return service.traCuuDonChoDoiTra(maDon);
    }

    @PostMapping
    @RequirePermission(feature = "return_request", action = PermissionType.ADD)
    public ReturnDto taoYeuCau(@RequestBody TaoYeuCauAdminRequest req) {
        return service.taoYeuCauBoiAdmin(req.maDon(), req.orderItemId(), req.lyDo(),
                req.noiDung(), req.soLuong());
    }

    @PostMapping("/{id}/trang-thai")
    @RequirePermission(feature = "return_request", action = PermissionType.EDIT)
    public ReturnDto doiTrangThai(@PathVariable Integer id, @RequestBody DoiTrangThaiRequest req) {
        return service.doiTrangThai(id, req.trangThai(), req.ghiChu());
    }
}
