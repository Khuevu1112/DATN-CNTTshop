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
import com.fpoly.dto.PosDtos.PosBaoHanhDto;
import com.fpoly.dto.PosDtos.PosTaoYeuCauBaoHanhRequest;
import com.fpoly.dto.PosDtos.PosTraCuuDto;
import com.fpoly.dto.SupportDtos.TrungTamDto;
import com.fpoly.service.PosService;
import com.fpoly.service.PosTraCuuService;
import com.fpoly.service.SupportService;

/** Bán hàng tại quầy showroom — app riêng chạy cổng 5175.
 *
 * Toàn bộ endpoint yêu cầu quyền "pos", tách khỏi "orders" (quản lý đơn) vì đây là hai việc khác
 * nhau: nhân viên bán hàng cần chốt đơn tại quầy nhưng không nhất thiết được sửa đơn online. */
@RestController
@RequestMapping("/api/pos")
public class PosApiController {

    @Autowired private PosService posService;
    @Autowired private PosTraCuuService posTraCuuService;
    @Autowired private SupportService supportService;

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

    // ==================== Tra cứu & bảo hành tại quầy ====================
    // POS không chỉ để thu tiền: khách tới quầy hay hỏi "đơn tôi tới đâu rồi", "máy này còn bảo
    // hành không", "máy gửi sửa xong chưa". Trước đây nhân viên quầy phải mở Admin Console bằng
    // tài khoản khác mới trả lời được.

    /** Tra theo số điện thoại / mã đơn hàng / serial — trả về TẤT CẢ trong một lượt gọi. */
    @GetMapping("/tra-cuu")
    @RequirePermission(feature = "pos", action = PermissionType.VIEW)
    public PosTraCuuDto traCuu(@RequestParam String q) {
        return posTraCuuService.traCuu(q);
    }

    /** Nhân viên lập yêu cầu bảo hành hộ khách ngay tại quầy. */
    @PostMapping("/warranty-requests")
    @RequirePermission(feature = "pos", action = PermissionType.PERFORM)
    public PosBaoHanhDto taoYeuCauBaoHanh(@RequestBody PosTaoYeuCauBaoHanhRequest req) {
        return posTraCuuService.taoYeuCauBaoHanh(req);
    }

    /** Danh sách trung tâm bảo hành để chọn khi khách mang máy tới cửa hàng. */
    @GetMapping("/service-centers")
    @RequirePermission(feature = "pos", action = PermissionType.VIEW)
    public List<TrungTamDto> trungTam() {
        return supportService.timTrungTam(null, null, null, null, null, null);
    }
}
