package com.fpoly.controller.api;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import com.fpoly.dto.FlashSaleDtos.FlashSaleAdminDto;
import com.fpoly.dto.FlashSaleDtos.FlashSaleCongKhaiDto;
import com.fpoly.dto.FlashSaleDtos.FlashSaleItemDto;
import com.fpoly.dto.FlashSaleDtos.LuuFlashSaleRequest;
import com.fpoly.model.enums.PermissionType;
import com.fpoly.security.RequirePermission;
import com.fpoly.service.FlashSaleService;

/** Flash sale. Endpoint /api/flash-sale là công khai (trang chủ + trang khuyến mãi của khách gọi),
 * các endpoint /api/flash-sale/admin/** đi qua quyền "coupons" vì flash sale nằm trong nhóm
 * Quản lý khuyến mãi. */
@RestController
@RequestMapping("/api/flash-sale")
public class FlashSaleApiController {

    @Autowired private FlashSaleService flashSaleService;

    /** Bản khách xem — null nếu không có đợt nào đang chạy, client tự ẩn banner. */
    @GetMapping
    public FlashSaleCongKhaiDto dangChay() {
        return flashSaleService.dangChay();
    }

    /** Bản nháp admin đang soạn + cờ cho biết có được tạo mới hay không. */
    @GetMapping("/admin")
    @RequirePermission(feature = "coupons", action = PermissionType.VIEW)
    public AdminStateDto adminState() {
        return new AdminStateDto(flashSaleService.dotDangSoan(), flashSaleService.dangCoDotConHieuLuc());
    }

    /** coTheTaoMoi=false -> UI phải ẩn nút tạo mới; service vẫn chặn lần nữa ở phía sau, không
     * tin mỗi UI. */
    public record AdminStateDto(FlashSaleAdminDto dot, boolean dangCoDotConHieuLuc) {}

    @PostMapping("/admin")
    @RequirePermission(feature = "coupons", action = PermissionType.ADD)
    public FlashSaleAdminDto taoMoi(@RequestBody LuuFlashSaleRequest req, Authentication auth) {
        return flashSaleService.taoMoi(req, auth.getName());
    }

    /** Lưu bản nháp — KHÔNG đẩy ra cho khách, phải bấm publish mới ra. */
    @PutMapping("/admin/{id}")
    @RequirePermission(feature = "coupons", action = PermissionType.EDIT)
    public FlashSaleAdminDto capNhat(@PathVariable Integer id,
                                     @RequestBody LuuFlashSaleRequest req,
                                     Authentication auth) {
        return flashSaleService.capNhat(id, req, auth.getName());
    }

    @PostMapping("/admin/{id}/publish")
    @RequirePermission(feature = "coupons", action = PermissionType.EDIT)
    public FlashSaleAdminDto publish(@PathVariable Integer id, Authentication auth) {
        return flashSaleService.publish(id, auth.getName());
    }

    @PostMapping("/admin/{id}/unpublish")
    @RequirePermission(feature = "coupons", action = PermissionType.EDIT)
    public FlashSaleAdminDto gongoai(@PathVariable Integer id) {
        return flashSaleService.gongoai(id);
    }

    /** Tìm biến thể sản phẩm để thêm vào đợt sale. Trả thẳng dạng FlashSaleItemDto (giaSale=0,
     * phanTramGiam=0) để client thêm vào danh sách mà không phải nắn dữ liệu. */
    @GetMapping("/admin/products")
    @RequirePermission(feature = "coupons", action = PermissionType.VIEW)
    public List<FlashSaleItemDto> timSanPham(@RequestParam String q) {
        return flashSaleService.timBienTheDeThem(q);
    }
}
