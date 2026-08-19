package com.fpoly.controller.api;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.SupportDtos.ChinhSachBaoHanhDto;
import com.fpoly.dto.SupportDtos.DatLichRequest;
import com.fpoly.dto.SupportDtos.FaqDanhMucDto;
import com.fpoly.dto.SupportDtos.GiaSuaChuaDto;
import com.fpoly.dto.SupportDtos.KhungGioDto;
import com.fpoly.dto.SupportDtos.LichHenDto;
import com.fpoly.dto.SupportDtos.PhamViTanNoiDto;
import com.fpoly.dto.SupportDtos.TongQuanHoTroDto;
import com.fpoly.dto.SupportDtos.TraCuuBaoHanhDto;
import com.fpoly.dto.SupportDtos.TrungTamDto;
import com.fpoly.dto.SupportDtos.UocTinhDto;
import com.fpoly.service.AddressService;
import com.fpoly.service.ServiceAppointmentService;
import com.fpoly.service.SupportService;

/**
 * Trung tâm hỗ trợ — API phía khách.
 *
 * PHẦN LỚN LÀ CÔNG KHAI (xem SecurityConfig): khách cần tra được trung tâm bảo hành, giá sửa
 * chữa và FAQ TRƯỚC khi quyết định mua hàng hay lập tài khoản. Bắt đăng nhập ở đây là chặn đúng
 * nhóm người đang cân nhắc. Chỉ hai nhóm việc cần đăng nhập:
 *   - /lich-hen/cua-toi : danh sách lịch của chính mình
 *   - /lich-hen/{id}/huy : huỷ lịch của chính mình
 * Riêng ĐẶT lịch vẫn công khai (shop nhận sửa dịch vụ máy mua nơi khác), nhưng nếu người gọi
 * có token hợp lệ thì lịch được gắn vào tài khoản để họ theo dõi trong mục Tài khoản.
 */
@RestController
@RequestMapping("/api/support")
public class SupportApiController {

    @Autowired private SupportService supportService;
    @Autowired private ServiceAppointmentService appointmentService;
    @Autowired private AddressService addressService;

    // ===================== Trang chủ hỗ trợ =====================

    @GetMapping("/tong-quan")
    public TongQuanHoTroDto tongQuan() {
        return supportService.tongQuan();
    }

    // ===================== Trung tâm bảo hành =====================

    @GetMapping("/trung-tam")
    public List<TrungTamDto> trungTam(
            @RequestParam(required = false) Integer provinceId,
            @RequestParam(required = false) String dichVu,
            @RequestParam(required = false) String q,
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng,
            @RequestParam(required = false) Double banKinhKm) {
        return supportService.timTrungTam(provinceId, dichVu, q, lat, lng, banKinhKm);
    }

    @GetMapping("/trung-tam/{id}")
    public TrungTamDto chiTietTrungTam(@PathVariable Integer id) {
        return supportService.chiTietTrungTam(id);
    }

    /**
     * Phạm vi phục vụ TẬN NƠI (kỹ thuật tới nhà) — dùng để bật/tắt lựa chọn "Bảo hành tận nơi"
     * và nói rõ với khách ngoài vùng là vì sao.
     *
     * Công khai: khách chưa đăng nhập vẫn cần biết shop có phục vụ tỉnh mình không. Có đăng
     * nhập + đã lưu địa chỉ mặc định thì trả thêm kết luận cho chính địa chỉ đó.
     */
    @GetMapping("/pham-vi-tan-noi")
    public PhamViTanNoiDto phamViTanNoi(Authentication auth) {
        return supportService.phamViTanNoi(tinhCuaKhach(auth));
    }

    /** Tỉnh trong địa chỉ mặc định của khách; null nếu chưa đăng nhập / chưa có địa chỉ / địa
     * chỉ cũ chỉ có cột text chưa gắn FK Tỉnh. */
    private Integer tinhCuaKhach(Authentication auth) {
        if (auth == null || auth instanceof AnonymousAuthenticationToken) return null;
        try {
            return addressService.layDanhSachTheoEmail(auth.getName()).stream()
                    .filter(a -> a.getProvince() != null)
                    .sorted((a, b) -> Boolean.compare(
                            !Boolean.TRUE.equals(a.getIsDefault()), !Boolean.TRUE.equals(b.getIsDefault())))
                    .map(a -> a.getProvince().getId())
                    .findFirst().orElse(null);
        } catch (RuntimeException e) {
            return null;
        }
    }

    // ===================== Thông tin bảo hành =====================

    @GetMapping("/chinh-sach-bao-hanh")
    public List<ChinhSachBaoHanhDto> chinhSach() {
        return supportService.chinhSachBaoHanh();
    }

    /** Tra cứu theo serial — không cần đăng nhập, cố tình không trả thông tin định danh khách
     * hàng (xem SupportService.traCuuTheoSerial). */
    @GetMapping("/tra-cuu-bao-hanh")
    public TraCuuBaoHanhDto traCuuBaoHanh(@RequestParam String serial) {
        return supportService.traCuuTheoSerial(serial);
    }

    // ===================== Bảng giá sửa chữa =====================

    @GetMapping("/bang-gia")
    public List<GiaSuaChuaDto> bangGia(@RequestParam(required = false) String loaiThietBi) {
        return supportService.bangGia(loaiThietBi);
    }

    /** Ước tính cho tối đa 2 hạng mục. Dùng POST vì danh sách id là dữ liệu đầu vào có kiểm tra
     * hợp lệ, không phải một tài nguyên để cache theo URL. */
    @PostMapping("/uoc-tinh-sua-chua")
    public UocTinhDto uocTinh(@RequestBody Map<String, List<Integer>> body) {
        return supportService.uocTinh(body.get("hangMucIds"));
    }

    // ===================== FAQ =====================

    @GetMapping("/faq")
    public List<FaqDanhMucDto> faq(@RequestParam(required = false) String q) {
        return supportService.faq(q);
    }

    @PostMapping("/faq/{id}/xem")
    public void ghiNhanLuotXem(@PathVariable Integer id) {
        supportService.ghiNhanLuotXemFaq(id);
    }

    // ===================== Đặt lịch dịch vụ =====================

    @GetMapping("/khung-gio")
    public List<KhungGioDto> khungGio(
            @RequestParam Integer centerId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate ngay) {
        return appointmentService.khungGioTrong(centerId, ngay);
    }

    /** Công khai. Không đăng nhập = khách vãng lai; có token hợp lệ thì lịch được gắn vào tài
     * khoản để khách theo dõi trong mục Tài khoản. */
    @PostMapping("/dat-lich")
    public LichHenDto datLich(@RequestBody DatLichRequest req, Authentication auth) {
        return appointmentService.datLich(req, emailDangNhap(auth));
    }

    /** Endpoint công khai KHÔNG nhận được Authentication null — Spring Security cấp
     * AnonymousAuthenticationToken (getName() = "anonymousUser"). Kiểm null suông sẽ khiến
     * service đi tìm người dùng tên "anonymousUser" và gắn nhầm lịch. */
    private static String emailDangNhap(Authentication auth) {
        if (auth == null || !auth.isAuthenticated()) return null;
        if (auth instanceof AnonymousAuthenticationToken) return null;
        return auth.getName();
    }

    /** Tra cứu bằng mã lịch — dành cho khách vãng lai. Số điện thoại bị che bớt vì mã lịch có
     * thể lọt ra ngoài. */
    @GetMapping("/lich-hen/tra-cuu")
    public LichHenDto traCuuLich(@RequestParam String maLich) {
        return appointmentService.traCuuTheoMa(maLich);
    }

    @GetMapping("/lich-hen/cua-toi")
    public List<LichHenDto> lichCuaToi(Authentication auth) {
        return appointmentService.lichCuaToi(auth.getName());
    }

    @PostMapping("/lich-hen/{id}/huy")
    public LichHenDto huyLich(@PathVariable Integer id, Authentication auth) {
        return appointmentService.huyLich(id, auth.getName());
    }
}
