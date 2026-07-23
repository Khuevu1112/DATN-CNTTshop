package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.TradeInDtos.BaoGiaRequest;
import com.fpoly.dto.TradeInDtos.ChotGiaRequest;
import com.fpoly.dto.TradeInDtos.DoiTrangThaiRequest;
import com.fpoly.dto.TradeInDtos.YeuCauDto;
import com.fpoly.model.enums.PermissionType;
import com.fpoly.security.RequirePermission;
import com.fpoly.service.TradeInService;

/** Thu cũ đổi mới — phía NHÂN VIÊN. Quyền "trade_in" (Kỹ thuật định giá, Kinh doanh chốt với
 * khách), tách khỏi "orders" vì đây là nghiệp vụ mua vào, không phải bán ra. */
@RestController
@RequestMapping("/api/admin/trade-in")
public class AdminTradeInApiController {

    @Autowired private TradeInService tradeInService;

    /** trangThai rỗng = lấy tất cả. */
    @GetMapping
    @RequirePermission(feature = "trade_in", action = PermissionType.VIEW)
    public List<YeuCauDto> danhSach(@RequestParam(required = false) String trangThai) {
        return tradeInService.tatCaYeuCau(trangThai);
    }

    @GetMapping("/{id}")
    @RequirePermission(feature = "trade_in", action = PermissionType.VIEW)
    public YeuCauDto chiTiet(@PathVariable Integer id) {
        return tradeInService.chiTiet(id);
    }

    /** Báo giá TẠM TÍNH theo ảnh + lời khai. Chưa ràng buộc gì, khách còn quyền từ chối. */
    @PostMapping("/{id}/bao-gia")
    @RequirePermission(feature = "trade_in", action = PermissionType.EDIT)
    public YeuCauDto baoGia(@PathVariable Integer id, @RequestBody BaoGiaRequest req, Authentication auth) {
        return tradeInService.baoGia(id, req.giaTamTinh(), req.ghiChu(), auth.getName());
    }

    /** Chốt giá SAU KHI kiểm máy thật — con số này mới dùng để phát hành tín dụng. */
    @PostMapping("/{id}/chot-gia")
    @RequirePermission(feature = "trade_in", action = PermissionType.EDIT)
    public YeuCauDto chotGia(@PathVariable Integer id, @RequestBody ChotGiaRequest req, Authentication auth) {
        return tradeInService.chotGia(id, req.giaChot(), req.ghiChu(), auth.getName());
    }

    /** Phát hành tín dụng cho khách — bước cuối của luồng. */
    @PostMapping("/{id}/cap-tin-dung")
    @RequirePermission(feature = "trade_in", action = PermissionType.EDIT)
    public YeuCauDto capTinDung(@PathVariable Integer id, Authentication auth) {
        return tradeInService.capTinDung(id, auth.getName());
    }

    /** Các bước chỉ đổi trạng thái: đã nhận máy, từ chối thu, huỷ. Service tự chặn bước không
     * hợp lệ theo luồng. */
    @PostMapping("/{id}/trang-thai/{trangThai}")
    @RequirePermission(feature = "trade_in", action = PermissionType.EDIT)
    public YeuCauDto doiTrangThai(@PathVariable Integer id, @PathVariable String trangThai,
                                  @RequestBody(required = false) DoiTrangThaiRequest req,
                                  Authentication auth) {
        return tradeInService.doiTrangThaiAdmin(id, trangThai,
                req == null ? null : req.ghiChu(), auth.getName());
    }
}
