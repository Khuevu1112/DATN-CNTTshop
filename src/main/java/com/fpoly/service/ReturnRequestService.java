package com.fpoly.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.ReturnDtos.ReturnDto;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.Order;
import com.fpoly.model.ReturnRequest;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.OrderRepository;
import com.fpoly.repository.ReturnRequestRepository;

/** Đổi trả hàng (1 đổi 1 trong 7 ngày). Chính sách RIÊNG với bảo hành — xem 71_return_request.sql.
 * File tải lên (video/ảnh) do controller lưu đĩa rồi truyền URL vào service. */
@Service
public class ReturnRequestService {

    @Autowired private ReturnRequestRepository repo;
    @Autowired private NguoiDungRepository nguoiDungRepo;
    @Autowired private OrderRepository orderRepo;
    @Autowired private NotificationService notificationService;

    private static final List<String> TRANG_THAI = List.of(
            "cho_xu_ly", "dang_xu_ly", "chap_nhan", "tu_choi", "hoan_tat");

    /** Bước chuyển hợp lệ — cho phép rẽ nhánh chấp nhận/từ chối rồi kết. */
    private static final Map<String, List<String>> LUONG = Map.of(
            "cho_xu_ly", List.of("dang_xu_ly", "tu_choi"),
            "dang_xu_ly", List.of("chap_nhan", "tu_choi"),
            "chap_nhan", List.of("hoan_tat"));

    public static String nhan(String tt) {
        return switch (tt) {
            case "cho_xu_ly" -> "Chờ xử lý";
            case "dang_xu_ly" -> "Đang xử lý";
            case "chap_nhan" -> "Chấp nhận đổi/trả";
            case "tu_choi" -> "Từ chối";
            case "hoan_tat" -> "Hoàn tất";
            default -> tt;
        };
    }

    private static final String BANG = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private final Random random = new Random();

    private String sinhMa() {
        for (int i = 0; i < 10; i++) {
            StringBuilder sb = new StringBuilder("DT")
                    .append(LocalDate.now().format(DateTimeFormatter.ofPattern("yyMMdd")));
            for (int k = 0; k < 4; k++) sb.append(BANG.charAt(random.nextInt(BANG.length())));
            String ma = sb.toString();
            if (repo.findByMaYeuCau(ma).isEmpty()) return ma;
        }
        throw new RuntimeException("Không sinh được mã yêu cầu, vui lòng thử lại.");
    }

    /** Tạo yêu cầu đổi trả. URL file đã được controller lưu và truyền vào. */
    @Transactional
    public ReturnDto taoYeuCau(String email, String maDon, String kenhMua, String lyDo, String noiDung,
                               String videoLoi, String videoMoHang, List<String> anhLoi) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
        if (noiDung == null || noiDung.isBlank()) {
            throw new RuntimeException("Vui lòng mô tả nội dung cần đổi trả.");
        }
        String kenh = "tai_cua_hang".equals(kenhMua) ? "tai_cua_hang" : "online";
        // Đơn online BẮT BUỘC video mở hàng — đây là bằng chứng chống tranh chấp "hàng đã lỗi sẵn".
        if ("online".equals(kenh) && (videoMoHang == null || videoMoHang.isBlank())) {
            throw new RuntimeException("Đơn mua online bắt buộc kèm video tự tay mở hàng.");
        }

        ReturnRequest r = new ReturnRequest();
        r.setMaYeuCau(sinhMa());
        r.setUser(user);
        r.setKenhMua(kenh);
        r.setLyDo(lyDo);
        r.setNoiDung(noiDung.trim());
        r.setVideoLoi(videoLoi);
        r.setVideoMoHang(videoMoHang);
        List<String> anh = anhLoi != null ? anhLoi : List.of();
        if (anh.size() > 0) r.setAnhLoi1(anh.get(0));
        if (anh.size() > 1) r.setAnhLoi2(anh.get(1));
        if (anh.size() > 2) r.setAnhLoi3(anh.get(2));

        // Gắn đơn nếu khách nhập đúng mã đơn của chính mình.
        if (maDon != null && !maDon.isBlank()) {
            orderRepo.findByMaDonHang(maDon.trim()).ifPresent(o -> {
                if (o.getNguoiDung() != null && email.equalsIgnoreCase(o.getNguoiDung().getEmail())) {
                    r.setOrder(o);
                    r.setMaDon(o.getMaDonHang());
                }
            });
            if (r.getMaDon() == null) r.setMaDon(maDon.trim()); // vẫn lưu chuỗi khách khai
        }

        r.setTrangThai("cho_xu_ly");
        repo.save(r);

        notificationService.taoChoUser(user.getId(), "return_request",
                "Đã gửi yêu cầu đổi trả " + r.getMaYeuCau(),
                "CNTTShop đã nhận yêu cầu đổi trả của bạn và sẽ phản hồi trong 24 giờ làm việc.",
                "/ho-tro/doi-tra");
        return toDto(r);
    }

    public List<ReturnDto> cuaToi(String email) {
        return repo.findByUserEmailOrderByCreatedAtDesc(email).stream().map(this::toDto).toList();
    }

    // ===== Phía CSKH =====

    public List<ReturnDto> tatCa(String trangThai) {
        List<ReturnRequest> rows = (trangThai == null || trangThai.isBlank())
                ? repo.findAllForAdmin()
                : repo.findByTrangThaiForAdmin(trangThai);
        return rows.stream().map(this::toDto).toList();
    }

    @Transactional
    public ReturnDto doiTrangThai(Integer id, String trangThaiMoi, String ghiChu) {
        if (!TRANG_THAI.contains(trangThaiMoi)) {
            throw new RuntimeException("Trạng thái không hợp lệ: " + trangThaiMoi);
        }
        ReturnRequest r = repo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy yêu cầu đổi trả"));
        List<String> choPhep = LUONG.get(r.getTrangThai());
        if (choPhep == null || !choPhep.contains(trangThaiMoi)) {
            throw new RuntimeException("Không chuyển được từ \"" + nhan(r.getTrangThai())
                    + "\" sang \"" + nhan(trangThaiMoi) + "\".");
        }
        r.setTrangThai(trangThaiMoi);
        if (ghiChu != null && !ghiChu.isBlank()) r.setGhiChuCskh(ghiChu.trim());
        r.setUpdatedAt(LocalDateTime.now());
        repo.save(r);

        if (r.getUser() != null) {
            notificationService.taoChoUser(r.getUser().getId(), "return_request",
                    "Yêu cầu đổi trả " + r.getMaYeuCau() + ": " + nhan(trangThaiMoi),
                    ghiChu != null && !ghiChu.isBlank() ? ghiChu : "Trạng thái yêu cầu đổi trả của bạn vừa được cập nhật.",
                    "/ho-tro/doi-tra");
        }
        return toDto(r);
    }

    private ReturnDto toDto(ReturnRequest r) {
        List<String> anh = new ArrayList<>();
        if (r.getAnhLoi1() != null) anh.add(r.getAnhLoi1());
        if (r.getAnhLoi2() != null) anh.add(r.getAnhLoi2());
        if (r.getAnhLoi3() != null) anh.add(r.getAnhLoi3());
        NguoiDung u = r.getUser();
        return new ReturnDto(
                r.getId(), r.getMaYeuCau(),
                r.getMaDon(), r.getTenSanPham(), r.getKenhMua(), r.getLyDo(), r.getNoiDung(),
                r.getVideoLoi(), r.getVideoMoHang(), anh,
                r.getTrangThai(), nhan(r.getTrangThai()), r.getGhiChuCskh(),
                u != null ? u.getHoTen() : null,
                u != null ? u.getEmail() : null,
                u != null ? u.getSoDienThoai() : null,
                r.getCreatedAt(), r.getUpdatedAt());
    }
}
