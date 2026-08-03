package com.fpoly.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.HashSet;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.SupportDtos.DatLichRequest;
import com.fpoly.dto.SupportDtos.KhungGioDto;
import com.fpoly.dto.SupportDtos.LichHenDto;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.ServiceAppointment;
import com.fpoly.model.ServiceCenter;
import com.fpoly.model.Warranty;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.ServiceAppointmentRepository;
import com.fpoly.repository.ServiceCenterRepository;
import com.fpoly.repository.WarrantyRepository;

/** Đặt lịch mang máy tới trung tâm bảo hành.
 *
 * Mở cho cả khách CHƯA đăng nhập — shop nhận sửa dịch vụ máy mua nơi khác, bắt đăng nhập sẽ
 * chặn đúng nhóm khách mà tính năng này nhắm tới. Đổi lại, khách vãng lai chỉ tra cứu lại lịch
 * của mình bằng mã lịch, nên mã phải khó đoán (xem sinhMaLich). */
@Service
public class ServiceAppointmentService {

    @Autowired private ServiceAppointmentRepository appointmentRepo;
    @Autowired private ServiceCenterRepository centerRepo;
    @Autowired private WarrantyRepository warrantyRepo;
    @Autowired private NguoiDungRepository nguoiDungRepo;
    @Autowired private NotificationService notificationService;

    /** Khung giờ tiếp nhận cố định. Ngắt trưa 12:00-13:00 để kỹ thuật nghỉ — không phát sinh
     * lịch vào khoảng đó. */
    public static final List<String> KHUNG_GIO = List.of(
            "08:00-09:00", "09:00-10:00", "10:00-11:00", "11:00-12:00",
            "13:00-14:00", "14:00-15:00", "15:00-16:00", "16:00-17:00", "17:00-18:00");

    /** Không cho đặt xa quá — lịch kỹ thuật và tồn linh kiện đều không dự báo nổi quá 30 ngày. */
    private static final int SO_NGAY_DAT_TRUOC_TOI_DA = 30;

    private static final Set<String> TRANG_THAI_HOP_LE = Set.of(
            "cho_xac_nhan", "da_xac_nhan", "dang_xu_ly", "hoan_thanh", "khach_khong_den", "da_huy");

    /** Bước chuyển hợp lệ — cùng lý do với đơn hàng: mỗi bước gắn với một sự kiện có thật
     * ngoài đời, không cho nhảy cóc từ "chờ xác nhận" thẳng sang "hoàn thành". */
    private static final Map<String, List<String>> LUONG_HOP_LE = Map.of(
            "cho_xac_nhan", List.of("da_xac_nhan", "da_huy"),
            "da_xac_nhan", List.of("dang_xu_ly", "khach_khong_den", "da_huy"),
            "dang_xu_ly", List.of("hoan_thanh", "da_huy"));

    public static String nhanTrangThai(String tt) {
        return switch (tt) {
            case "cho_xac_nhan" -> "Chờ xác nhận";
            case "da_xac_nhan" -> "Đã xác nhận";
            case "dang_xu_ly" -> "Đang xử lý";
            case "hoan_thanh" -> "Hoàn thành";
            case "khach_khong_den" -> "Khách không đến";
            case "da_huy" -> "Đã huỷ";
            default -> tt;
        };
    }

    // ============================================================
    //  Khung giờ còn trống
    // ============================================================

    /** Khung giờ của một trung tâm trong một ngày, kèm cờ còn trống.
     *
     * Trả về CẢ khung đã kín (conTrong=false) thay vì lọc bỏ: khách cần thấy giờ đó đã có người
     * để chọn giờ khác, chứ không phải thấy một danh sách ngắn dần không hiểu vì sao. */
    public List<KhungGioDto> khungGioTrong(Integer centerId, LocalDate ngay) {
        ServiceCenter center = centerRepo.findById(centerId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy trung tâm bảo hành"));
        if (!center.isNhanDatLich()) {
            throw new RuntimeException("Trung tâm này hiện không nhận đặt lịch.");
        }
        kiemTraNgayHen(ngay);

        Set<String> daDat = new HashSet<>(appointmentRepo.findKhungGioDaDat(centerId, ngay));

        // Đặt trong ngày thì các khung đã trôi qua cũng phải khoá — 14h không thể nhận lịch 9h.
        LocalDateTime bayGio = LocalDateTime.now();
        boolean laHomNay = ngay.isEqual(bayGio.toLocalDate());

        List<KhungGioDto> ketQua = new ArrayList<>();
        for (String kg : KHUNG_GIO) {
            boolean trong = !daDat.contains(kg);
            if (trong && laHomNay) {
                int gioBatDau = Integer.parseInt(kg.substring(0, 2));
                if (gioBatDau <= bayGio.getHour()) trong = false;
            }
            ketQua.add(new KhungGioDto(kg, trong));
        }
        return ketQua;
    }

    private void kiemTraNgayHen(LocalDate ngay) {
        if (ngay == null) throw new RuntimeException("Chọn ngày hẹn.");
        LocalDate homNay = LocalDate.now();
        if (ngay.isBefore(homNay)) {
            throw new RuntimeException("Không đặt được lịch cho ngày đã qua.");
        }
        if (ngay.isAfter(homNay.plusDays(SO_NGAY_DAT_TRUOC_TOI_DA))) {
            throw new RuntimeException("Chỉ đặt lịch trước tối đa " + SO_NGAY_DAT_TRUOC_TOI_DA + " ngày.");
        }
    }

    // ============================================================
    //  Đặt lịch
    // ============================================================

    /** @param email email người đăng nhập, null nếu khách vãng lai. */
    @Transactional
    public LichHenDto datLich(DatLichRequest req, String email) {
        if (req.centerId() == null) throw new RuntimeException("Chọn trung tâm bảo hành.");
        if (rong(req.hoTen())) throw new RuntimeException("Nhập họ và tên.");
        if (rong(req.dienThoai())) throw new RuntimeException("Nhập số điện thoại để kỹ thuật gọi xác nhận.");
        if (rong(req.moTaLoi())) throw new RuntimeException("Mô tả tình trạng máy để kỹ thuật chuẩn bị trước.");
        if (rong(req.loaiThietBi())) throw new RuntimeException("Chọn loại thiết bị.");
        if (rong(req.khungGio()) || !KHUNG_GIO.contains(req.khungGio())) {
            throw new RuntimeException("Khung giờ không hợp lệ.");
        }
        kiemTraNgayHen(req.ngayHen());

        ServiceCenter center = centerRepo.findById(req.centerId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy trung tâm bảo hành"));
        if (!center.isNhanDatLich() || !center.isHienThi()) {
            throw new RuntimeException("Trung tâm này hiện không nhận đặt lịch.");
        }
        // Trung tâm không nhận nhóm thiết bị đó thì chặn ngay, đừng để khách đi tới nơi mới biết.
        if (center.getDichVu() != null && !center.getDichVu().isBlank()) {
            boolean nhan = false;
            for (String ma : center.getDichVu().split(",")) {
                if (ma.trim().equalsIgnoreCase(req.loaiThietBi())) { nhan = true; break; }
            }
            if (!nhan) {
                throw new RuntimeException("Trung tâm này không nhận sửa nhóm thiết bị bạn chọn. "
                        + "Vui lòng chọn trung tâm khác.");
            }
        }

        ServiceAppointment a = new ServiceAppointment();
        a.setCenter(center);
        a.setHoTen(req.hoTen().trim());
        a.setDienThoai(req.dienThoai().trim());
        a.setEmail(rong(req.email()) ? null : req.email().trim());
        a.setLoaiThietBi(req.loaiThietBi());
        a.setModel(rong(req.model()) ? null : req.model().trim());
        a.setMoTaLoi(req.moTaLoi().trim());
        a.setNgayHen(req.ngayHen());
        a.setKhungGio(req.khungGio());
        a.setTrangThai("cho_xac_nhan");
        a.setMaLich(sinhMaLich());

        NguoiDung user = null;
        if (email != null) {
            user = nguoiDungRepo.findByEmail(email).orElse(null);
            a.setUser(user);
        }

        // Gắn phiếu bảo hành nếu khách chỉ định: kỹ thuật biết trước đây là ca miễn phí. Bắt buộc
        // kiểm chủ sở hữu — nếu không, ai cũng gắn được phiếu của người khác vào lịch của mình.
        if (req.warrantyId() != null) {
            Warranty w = warrantyRepo.findById(req.warrantyId())
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy phiếu bảo hành"));
            if (email == null || w.getNguoiDung() == null
                    || !w.getNguoiDung().getEmail().equalsIgnoreCase(email)) {
                throw new RuntimeException("Phiếu bảo hành này không thuộc về bạn.");
            }
            a.setWarranty(w);
        }

        try {
            appointmentRepo.saveAndFlush(a);
        } catch (DataIntegrityViolationException e) {
            // Hai khách bấm cùng lúc vào một khung giờ: kiểm tra ở trên vẫn lọt, chỉ có unique
            // index UX_SERVICE_APPOINTMENT_slot chặn được thật. Dịch lỗi CSDL sang câu khách hiểu.
            throw new RuntimeException("Khung giờ " + req.khungGio() + " vừa có người đặt trước. "
                    + "Vui lòng chọn khung giờ khác.");
        }

        if (user != null) {
            notificationService.taoChoUser(user.getId(), "service_appointment",
                    "Đã đặt lịch dịch vụ " + a.getMaLich(),
                    "Lịch hẹn tại " + center.getTen() + " ngày "
                            + a.getNgayHen().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"))
                            + " lúc " + a.getKhungGio() + ". Kỹ thuật sẽ gọi xác nhận trước giờ hẹn.",
                    "/ho-tro/lich-hen");
        }
        return toDto(a, true);
    }

    /** Mã tra cứu công khai. 4 ký tự ngẫu nhiên ở cuối là thứ duy nhất ngăn người ngoài dò lịch
     * của khách khác bằng cách đếm số — phần ngày tháng ai cũng đoán được. Bỏ các ký tự dễ nhìn
     * nhầm (0/O, 1/I) vì khách đọc mã qua điện thoại cho tổng đài. */
    private static final String BANG_CHU = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private final Random random = new Random();

    private String sinhMaLich() {
        for (int lan = 0; lan < 10; lan++) {
            StringBuilder sb = new StringBuilder("SV");
            sb.append(LocalDate.now().format(DateTimeFormatter.ofPattern("yyMMdd")));
            for (int i = 0; i < 4; i++) {
                sb.append(BANG_CHU.charAt(random.nextInt(BANG_CHU.length())));
            }
            String ma = sb.toString();
            if (appointmentRepo.findByMaLich(ma).isEmpty()) return ma;
        }
        throw new RuntimeException("Không sinh được mã lịch hẹn, vui lòng thử lại.");
    }

    // ============================================================
    //  Tra cứu
    // ============================================================

    /** Tra theo mã lịch — công khai, dành cho khách vãng lai không có tài khoản.
     * Che bớt số điện thoại vì mã lịch có thể lọt ra ngoài (chụp màn hình, chuyển tiếp tin nhắn). */
    public LichHenDto traCuuTheoMa(String maLich) {
        ServiceAppointment a = appointmentRepo.findByMaLich(maLich == null ? "" : maLich.trim().toUpperCase())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lịch hẹn với mã này."));
        return toDto(a, false);
    }

    public List<LichHenDto> lichCuaToi(String email) {
        return appointmentRepo.findByUserEmailOrderByCreatedAtDesc(email).stream()
                .map(a -> toDto(a, true))
                .toList();
    }

    /** Khách tự huỷ lịch của mình. Chỉ huỷ được khi chưa mang máy tới. */
    @Transactional
    public LichHenDto huyLich(Integer id, String email) {
        ServiceAppointment a = appointmentRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lịch hẹn"));
        if (a.getUser() == null || !a.getUser().getEmail().equalsIgnoreCase(email)) {
            throw new RuntimeException("Bạn không có quyền huỷ lịch hẹn này.");
        }
        if (!List.of("cho_xac_nhan", "da_xac_nhan").contains(a.getTrangThai())) {
            throw new RuntimeException("Lịch hẹn đang ở trạng thái \"" + nhanTrangThai(a.getTrangThai())
                    + "\", không huỷ được. Liên hệ hotline nếu cần hỗ trợ.");
        }
        a.setTrangThai("da_huy");
        a.setUpdatedAt(LocalDateTime.now());
        appointmentRepo.save(a);
        return toDto(a, true);
    }

    // ============================================================
    //  Phía nhân viên
    // ============================================================

    public List<LichHenDto> tatCaLich(String trangThai) {
        List<ServiceAppointment> rows = (trangThai == null || trangThai.isBlank())
                ? appointmentRepo.findAllForAdmin()
                : appointmentRepo.findByTrangThaiForAdmin(trangThai);
        return rows.stream().map(a -> toDto(a, true)).toList();
    }

    @Transactional
    public LichHenDto doiTrangThai(Integer id, String trangThaiMoi, String ghiChu, java.math.BigDecimal chiPhi) {
        if (!TRANG_THAI_HOP_LE.contains(trangThaiMoi)) {
            throw new RuntimeException("Trạng thái không hợp lệ: " + trangThaiMoi);
        }
        ServiceAppointment a = appointmentRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lịch hẹn"));

        List<String> choPhep = LUONG_HOP_LE.get(a.getTrangThai());
        if (choPhep == null || !choPhep.contains(trangThaiMoi)) {
            throw new RuntimeException("Không chuyển được từ \"" + nhanTrangThai(a.getTrangThai())
                    + "\" sang \"" + nhanTrangThai(trangThaiMoi) + "\".");
        }

        a.setTrangThai(trangThaiMoi);
        if (ghiChu != null && !ghiChu.isBlank()) a.setGhiChuKtv(ghiChu.trim());
        // Chi phí chỉ ghi khi hoàn thành — đây là con số đi vào lịch sử bảo hành của khách. Bước
        // khác gửi kèm chi phí là vô nghĩa nên bỏ qua, tránh ghi nhầm giá vào ca vừa huỷ.
        if ("hoan_thanh".equals(trangThaiMoi) && chiPhi != null && chiPhi.signum() >= 0) {
            a.setChiPhi(chiPhi);
        }
        a.setUpdatedAt(LocalDateTime.now());
        appointmentRepo.save(a);

        if (a.getUser() != null) {
            notificationService.taoChoUser(a.getUser().getId(), "service_appointment",
                    "Lịch hẹn " + a.getMaLich() + ": " + nhanTrangThai(trangThaiMoi),
                    ghiChu != null && !ghiChu.isBlank() ? ghiChu
                            : "Trạng thái lịch hẹn của bạn vừa được cập nhật.",
                    "/ho-tro/lich-hen");
        }
        return toDto(a, true);
    }

    // ============================================================

    /** @param dayDu true = người xem có quyền thấy số điện thoại đầy đủ (chính chủ hoặc nhân
     *               viên); false = tra cứu bằng mã lịch, che bớt số. */
    private LichHenDto toDto(ServiceAppointment a, boolean dayDu) {
        ServiceCenter c = a.getCenter();
        String sdt = dayDu ? a.getDienThoai() : cheSoDienThoai(a.getDienThoai());
        return new LichHenDto(
                a.getId(), a.getMaLich(),
                c != null ? c.getId() : null,
                c != null ? c.getTen() : null,
                c != null ? c.getDiaChi() : null,
                c != null ? c.getDienThoai() : null,
                a.getHoTen(), sdt, dayDu ? a.getEmail() : null,
                a.getLoaiThietBi(), a.getModel(), a.getMoTaLoi(),
                a.getNgayHen(), a.getKhungGio(),
                a.getTrangThai(), nhanTrangThai(a.getTrangThai()), a.getGhiChuKtv(),
                a.getWarranty() != null ? a.getWarranty().getId() : null, a.getChiPhi(),
                a.getCreatedAt(), a.getUpdatedAt());
    }

    private static String cheSoDienThoai(String sdt) {
        if (sdt == null || sdt.length() < 4) return sdt;
        return sdt.substring(0, sdt.length() - 4).replaceAll("\\d", "*") + sdt.substring(sdt.length() - 4);
    }

    private static boolean rong(String s) {
        return s == null || s.isBlank();
    }
}
