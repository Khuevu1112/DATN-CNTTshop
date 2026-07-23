package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.PosDtos.PosHoaDonDto;
import com.fpoly.dto.PosDtos.PosKhachDto;
import com.fpoly.dto.PosDtos.PosProductDto;
import com.fpoly.dto.PosDtos.PosTaoDonRequest;
import com.fpoly.dto.PosDtos.PosUuDaiDto;
import com.fpoly.model.enums.PermissionType;
import com.fpoly.security.RequirePermission;
import com.fpoly.service.PosService;

/** Bán hàng tại quầy showroom — app riêng chạy cổng 5175.
 *
 * Toàn bộ endpoint yêu cầu quyền "pos", tách khỏi "orders" (quản lý đơn) vì đây là hai việc khác
 * nhau: nhân viên bán hàng cần chốt đơn tại quầy nhưng không nhất thiết được sửa đơn online. */
@RestController
@RequestMapping("/api/pos")
public class PosApiController {

    @Autowired private PosService posService;

    @GetMapping("/products")
    @RequirePermission(feature = "pos", action = PermissionType.VIEW)
    public List<PosProductDto> timSanPham(@RequestParam String q) {
        return posService.timSanPham(q);
    }

    /** Tra khách theo SĐT trước khi chốt đơn — để nhân viên biết khách có Xu/hạng gì. */
    @GetMapping("/customer")
    @RequirePermission(feature = "pos", action = PermissionType.VIEW)
    public PosKhachDto traKhach(@RequestParam String phone) {
        return posService.traKhach(phone);
    }

    /** Dữ liệu cho thanh bên phải: khuyến mãi + tặng kèm theo sản phẩm đang có trong đơn, kèm
     * danh sách coupon còn hiệu lực. variantIds rỗng vẫn gọi được (chỉ trả về coupon). */
    @GetMapping("/offers")
    @RequirePermission(feature = "pos", action = PermissionType.VIEW)
    public PosUuDaiDto uuDai(@RequestParam(required = false) List<Integer> variantIds) {
        return posService.uuDai(variantIds);
    }

    @PostMapping("/orders")
    @RequirePermission(feature = "pos", action = PermissionType.ADD)
    public PosHoaDonDto taoDon(@RequestBody PosTaoDonRequest req, Authentication auth) {
        return posService.taoDon(req, auth == null ? null : auth.getName());
    }

    /** Kiểm tra khách đã quét QR trả tiền xong chưa — màn hình bán hàng gọi trước khi đóng đơn
     * VNPay. Trạng thái chỉ đổi khi cổng thanh toán xác nhận, nhân viên không tự đặt được. */
    @GetMapping("/orders/{id}")
    @RequirePermission(feature = "pos", action = PermissionType.VIEW)
    public PosHoaDonDto trangThaiDon(@PathVariable Integer id) {
        return posService.trangThaiDon(id);
    }
}
