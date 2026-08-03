package com.fpoly.controller.api;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.SupportDtos.ChinhSachBaoHanhDto;
import com.fpoly.dto.SupportDtos.DoiTrangThaiLichRequest;
import com.fpoly.dto.SupportDtos.FaqItemDto;
import com.fpoly.dto.SupportDtos.GiaSuaChuaDto;
import com.fpoly.dto.SupportDtos.LichHenDto;
import com.fpoly.dto.SupportDtos.LuuChinhSachRequest;
import com.fpoly.dto.SupportDtos.LuuFaqRequest;
import com.fpoly.dto.SupportDtos.LuuGiaSuaChuaRequest;
import com.fpoly.dto.SupportDtos.LuuTrungTamRequest;
import com.fpoly.dto.SupportDtos.TrungTamDto;
import com.fpoly.model.FaqCategory;
import com.fpoly.model.enums.PermissionType;
import com.fpoly.security.RequirePermission;
import com.fpoly.service.AdminSupportService;
import com.fpoly.service.ServiceAppointmentService;

/** Trung tâm hỗ trợ — phía NHÂN VIÊN.
 *
 * Hai quyền tách bạch (xem 66_support_center.sql):
 *   - support_content     : biên tập FAQ / bảng giá / danh sách trung tâm — việc thi thoảng
 *   - service_appointment : trực lịch hẹn hằng ngày của kỹ thuật
 * Gộp một quyền sẽ buộc phải cho kỹ thuật trực lịch sửa luôn được cả bảng giá. */
@RestController
@RequestMapping("/api/admin/support")
public class AdminSupportApiController {

    @Autowired private AdminSupportService adminSupportService;
    @Autowired private ServiceAppointmentService appointmentService;

    // ===================== Trung tâm bảo hành =====================

    @GetMapping("/trung-tam")
    @RequirePermission(feature = "support_content", action = PermissionType.VIEW)
    public List<TrungTamDto> danhSachTrungTam() {
        return adminSupportService.danhSachTrungTam();
    }

    @PostMapping("/trung-tam")
    @RequirePermission(feature = "support_content", action = PermissionType.ADD)
    public TrungTamDto taoTrungTam(@RequestBody LuuTrungTamRequest req) {
        return adminSupportService.taoTrungTam(req);
    }

    @PutMapping("/trung-tam/{id}")
    @RequirePermission(feature = "support_content", action = PermissionType.EDIT)
    public TrungTamDto suaTrungTam(@PathVariable Integer id, @RequestBody LuuTrungTamRequest req) {
        return adminSupportService.suaTrungTam(id, req);
    }

    @DeleteMapping("/trung-tam/{id}")
    @RequirePermission(feature = "support_content", action = PermissionType.DELETE)
    public void xoaTrungTam(@PathVariable Integer id) {
        adminSupportService.xoaTrungTam(id);
    }

    // ===================== Bảng giá sửa chữa =====================

    @GetMapping("/bang-gia")
    @RequirePermission(feature = "support_content", action = PermissionType.VIEW)
    public List<GiaSuaChuaDto> danhSachGia() {
        return adminSupportService.danhSachGia();
    }

    @PostMapping("/bang-gia")
    @RequirePermission(feature = "support_content", action = PermissionType.ADD)
    public GiaSuaChuaDto taoGia(@RequestBody LuuGiaSuaChuaRequest req) {
        return adminSupportService.taoGia(req);
    }

    @PutMapping("/bang-gia/{id}")
    @RequirePermission(feature = "support_content", action = PermissionType.EDIT)
    public GiaSuaChuaDto suaGia(@PathVariable Integer id, @RequestBody LuuGiaSuaChuaRequest req) {
        return adminSupportService.suaGia(id, req);
    }

    @DeleteMapping("/bang-gia/{id}")
    @RequirePermission(feature = "support_content", action = PermissionType.DELETE)
    public void xoaGia(@PathVariable Integer id) {
        adminSupportService.xoaGia(id);
    }

    // ===================== Chính sách bảo hành =====================

    @GetMapping("/chinh-sach")
    @RequirePermission(feature = "support_content", action = PermissionType.VIEW)
    public List<ChinhSachBaoHanhDto> danhSachChinhSach() {
        return adminSupportService.danhSachChinhSach();
    }

    @PostMapping("/chinh-sach")
    @RequirePermission(feature = "support_content", action = PermissionType.ADD)
    public ChinhSachBaoHanhDto taoChinhSach(@RequestBody LuuChinhSachRequest req) {
        return adminSupportService.taoChinhSach(req);
    }

    @PutMapping("/chinh-sach/{id}")
    @RequirePermission(feature = "support_content", action = PermissionType.EDIT)
    public ChinhSachBaoHanhDto suaChinhSach(@PathVariable Integer id, @RequestBody LuuChinhSachRequest req) {
        return adminSupportService.suaChinhSach(id, req);
    }

    @DeleteMapping("/chinh-sach/{id}")
    @RequirePermission(feature = "support_content", action = PermissionType.DELETE)
    public void xoaChinhSach(@PathVariable Integer id) {
        adminSupportService.xoaChinhSach(id);
    }

    // ===================== FAQ =====================

    @GetMapping("/faq")
    @RequirePermission(feature = "support_content", action = PermissionType.VIEW)
    public List<FaqItemDto> danhSachFaq() {
        return adminSupportService.danhSachFaq();
    }

    @GetMapping("/faq/danh-muc")
    @RequirePermission(feature = "support_content", action = PermissionType.VIEW)
    public List<Map<String, Object>> danhMucFaq() {
        return adminSupportService.danhSachDanhMucFaq().stream()
                .map(c -> Map.<String, Object>of("id", c.getId(), "ma", c.getMa(), "ten", c.getTen()))
                .toList();
    }

    @PostMapping("/faq")
    @RequirePermission(feature = "support_content", action = PermissionType.ADD)
    public FaqItemDto taoFaq(@RequestBody LuuFaqRequest req) {
        return adminSupportService.taoFaq(req);
    }

    @PutMapping("/faq/{id}")
    @RequirePermission(feature = "support_content", action = PermissionType.EDIT)
    public FaqItemDto suaFaq(@PathVariable Integer id, @RequestBody LuuFaqRequest req) {
        return adminSupportService.suaFaq(id, req);
    }

    @DeleteMapping("/faq/{id}")
    @RequirePermission(feature = "support_content", action = PermissionType.DELETE)
    public void xoaFaq(@PathVariable Integer id) {
        adminSupportService.xoaFaq(id);
    }

    // ===================== Lịch hẹn dịch vụ =====================

    @GetMapping("/lich-hen")
    @RequirePermission(feature = "service_appointment", action = PermissionType.VIEW)
    public List<LichHenDto> danhSachLich(@RequestParam(required = false) String trangThai) {
        return appointmentService.tatCaLich(trangThai);
    }

    @PostMapping("/lich-hen/{id}/trang-thai")
    @RequirePermission(feature = "service_appointment", action = PermissionType.EDIT)
    public LichHenDto doiTrangThai(@PathVariable Integer id, @RequestBody DoiTrangThaiLichRequest req) {
        return appointmentService.doiTrangThai(id, req.trangThai(), req.ghiChu(), req.chiPhi());
    }
}
