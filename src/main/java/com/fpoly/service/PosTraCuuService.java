package com.fpoly.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.PosDtos.PosBaoHanhDto;
import com.fpoly.dto.PosDtos.PosBaoHanhYeuCauDto;
import com.fpoly.dto.PosDtos.PosDonHangDto;
import com.fpoly.dto.PosDtos.PosKhachDto;
import com.fpoly.dto.PosDtos.PosTaoYeuCauBaoHanhRequest;
import com.fpoly.dto.PosDtos.PosTraCuuDto;
import com.fpoly.dto.PosDtos.PosViecDangXuLyDto;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.Order;
import com.fpoly.model.OrderItem;
import com.fpoly.model.ReturnRequest;
import com.fpoly.model.ServiceAppointment;
import com.fpoly.model.TradeInRequest;
import com.fpoly.model.Warranty;
import com.fpoly.model.WarrantyRequest;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.OrderRepository;
import com.fpoly.repository.PaymentRepository;
import com.fpoly.repository.ReturnRequestRepository;
import com.fpoly.repository.ServiceAppointmentRepository;
import com.fpoly.repository.TradeInRequestRepository;
import com.fpoly.repository.WarrantyRepository;
import com.fpoly.repository.WarrantyRequestRepository;

/**
 * TRA CỨU TẠI QUẦY cho POS.
 *
 * Vì sao cần: POS trước đây chỉ biết bán. Khách cầm máy tới hỏi "đơn tôi đặt online tới đâu
 * rồi", "máy này còn bảo hành không", "cái máy gửi sửa tuần trước xong chưa" thì nhân viên quầy
 * không tra được gì — phải mở Admin Console bằng tài khoản khác, hoặc gọi điện hỏi. Service này
 * gom mọi thứ liên quan tới MỘT khách vào một lượt gọi, đủ để đọc thẳng cho khách nghe.
 *
 * Định danh khách vẫn là SỐ ĐIỆN THOẠI (giống PosService), nhưng chấp nhận thêm mã đơn hàng /
 * serial máy vì khách hay đưa hoá đơn hoặc chính cái máy chứ không nhớ đăng ký bằng số nào.
 */
@Service
public class PosTraCuuService {

    @Autowired private NguoiDungRepository nguoiDungRepo;
    @Autowired private OrderRepository orderRepo;
    @Autowired private PaymentRepository paymentRepo;
    @Autowired private WarrantyRepository warrantyRepo;
    @Autowired private WarrantyRequestRepository warrantyRequestRepo;
    @Autowired private ServiceAppointmentRepository appointmentRepo;
    @Autowired private ReturnRequestRepository returnRepo;
    @Autowired private TradeInRequestRepository tradeInRepo;
    @Autowired private WalletService walletService;
    @Autowired private MembershipService membershipService;
    @Autowired private WarrantyService warrantyService;
    @Autowired private OrderService orderService;

    /**
     * Tra theo một chuỗi bất kỳ: số điện thoại, mã đơn hàng, hoặc serial máy.
     *
     * Thử lần lượt vì nhân viên chỉ có một ô nhập — bắt họ chọn trước "đang tra theo gì" là thêm
     * một thao tác thừa khi khách đang đứng đợi.
     */
    public PosTraCuuDto traCuu(String tuKhoa) {
        if (tuKhoa == null || tuKhoa.isBlank()) {
            throw new RuntimeException("Nhập số điện thoại, mã đơn hàng hoặc serial để tra cứu");
        }
        String q = tuKhoa.trim();

        NguoiDung user = nguoiDungRepo.findBySoDienThoai(q).orElse(null);
        if (user == null) {
            user = orderRepo.findByMaDonHang(q).map(Order::getNguoiDung).orElse(null);
        }
        if (user == null) {
            user = warrantyRepo.findAll().stream()
                    .filter(w -> q.equalsIgnoreCase(w.getSerialNumber()))
                    .map(Warranty::getNguoiDung)
                    .filter(java.util.Objects::nonNull)
                    .findFirst().orElse(null);
        }
        if (user == null) {
            throw new RuntimeException("Không tìm thấy khách nào khớp \"" + q
                    + "\". Thử số điện thoại, mã đơn hàng (DH...) hoặc serial trên tem máy.");
        }

        return new PosTraCuuDto(toKhachDto(user), donHangCua(user), baoHanhCua(user), viecDangXuLyCua(user));
    }

    private PosKhachDto toKhachDto(NguoiDung u) {
        int xu = walletService.layHoacTaoVi(u).getSoDuBac();
        var bac = membershipService.bacCua(u);
        return new PosKhachDto(u.getId(), u.getHoTen(), u.getSoDienThoai(), false,
                xu, bac.getTenHienThi(), bac.getPhanTramGiamDon());
    }

    // ============================================================
    //  Đơn hàng
    // ============================================================

    private List<PosDonHangDto> donHangCua(NguoiDung u) {
        return orderRepo.findByNguoiDungOrderByCreatedAtDesc(u).stream()
                .limit(20)
                .map(o -> {
                    var payment = paymentRepo.findByOrder(o).orElse(null);
                    List<OrderItem> items = o.getChiTiet() == null ? List.of() : o.getChiTiet();
                    return new PosDonHangDto(
                            o.getId(), o.getMaDonHang(), o.getCreatedAt(),
                            "pos".equals(o.getKenhBan()) ? "Mua tại quầy" : "Đặt online",
                            o.getTongTien(), o.getTrangThai(),
                            nhanTrangThaiDon(o.getTrangThai()),
                            // Mô tả dài của trạng thái — nhân viên đọc nguyên câu này cho khách,
                            // không phải tự diễn giải mỗi người một kiểu.
                            OrderService.MO_TA_TRANG_THAI.getOrDefault(o.getTrangThai(), ""),
                            payment == null ? null : nhanTrangThaiThanhToan(payment.getStatus()),
                            items.size(),
                            items.isEmpty() ? null : items.get(0).getTenSanPham());
                })
                .toList();
    }

    private String nhanTrangThaiDon(String s) {
        return switch (s) {
            case "pending" -> "Chờ xác nhận";
            case "confirmed" -> "Đã xác nhận";
            case "processing" -> "Đang xử lý";
            case "shipped" -> "Đang giao";
            case "delivered" -> "Hoàn tất";
            case "cancelled" -> "Đã huỷ";
            case "returned" -> "Hoàn hàng";
            case "refunded" -> "Đã hoàn tiền";
            default -> s;
        };
    }

    private String nhanTrangThaiThanhToan(String s) {
        return switch (s) {
            case "paid" -> "Đã thanh toán";
            case "pending" -> "Chưa thanh toán";
            case "waiting_verify" -> "Chờ đối soát";
            case "failed" -> "Thanh toán thất bại";
            case "refunded" -> "Đã hoàn tiền";
            default -> s;
        };
    }

    // ============================================================
    //  Bảo hành
    // ============================================================

    private List<PosBaoHanhDto> baoHanhCua(NguoiDung u) {
        return warrantyRepo.findByNguoiDung(u).stream()
                .sorted(Comparator.comparing(Warranty::getEndDate,
                        Comparator.nullsLast(Comparator.reverseOrder())))
                .map(this::toBaoHanhDto)
                .toList();
    }

    private PosBaoHanhDto toBaoHanhDto(Warranty w) {
        // Số ngày còn lại tính tới hết ngày kết thúc; âm nghĩa là đã hết hạn -> kẹp về 0 và để
        // trạng thái nói phần còn lại, tránh hiện "còn -37 ngày".
        Integer conLai = null;
        if (w.getEndDate() != null) {
            long n = ChronoUnit.DAYS.between(LocalDate.now(), w.getEndDate());
            conLai = (int) Math.max(0, n);
        }
        List<PosBaoHanhYeuCauDto> yeuCau = warrantyRequestRepo.findByWarrantyOrderByCreatedAtDesc(w).stream()
                .map(r -> new PosBaoHanhYeuCauDto(
                        r.getId(), r.getIssueDescription(), r.getRequestStatus(),
                        nhanTrangThaiYeuCau(r.getRequestStatus()),
                        r.getNgayHen(),
                        "tan_noi".equals(r.getHinhThuc()) ? "Kỹ thuật tới tận nơi" : "Mang tới cửa hàng",
                        r.getCreatedAt()))
                .toList();

        return new PosBaoHanhDto(
                w.getId(), w.getMaBaoHanh(),
                tenSanPhamCua(w), w.getSerialNumber(),
                w.getStartDate(), w.getEndDate(),
                w.getStatus(), nhanTrangThaiBaoHanh(w.getStatus()), conLai, yeuCau);
    }

    /** Warranty không lưu tên sản phẩm — đọc qua dòng đơn hàng đã sinh ra phiếu bảo hành đó
     * (OrderItem đã chụp sẵn tên tại thời điểm mua, xem OrderItem.tenSanPham). */
    private String tenSanPhamCua(Warranty w) {
        return w.getOrderItem() != null ? w.getOrderItem().getTenSanPham() : null;
    }

    private String nhanTrangThaiBaoHanh(String s) {
        return switch (s) {
            case "active" -> "Còn hạn";
            case "expired" -> "Hết hạn";
            case "void" -> "Vô hiệu";
            default -> s;
        };
    }

    private String nhanTrangThaiYeuCau(String s) {
        return switch (s) {
            case "pending" -> "Chờ tiếp nhận";
            case "accepted" -> "Đã tiếp nhận";
            case "processing" -> "Đang sửa";
            case "resolved" -> "Đã xong — có thể trả máy";
            case "rejected" -> "Từ chối bảo hành";
            default -> s;
        };
    }

    /** Nhân viên lập yêu cầu bảo hành hộ khách ngay tại quầy. */
    @Transactional
    public PosBaoHanhDto taoYeuCauBaoHanh(PosTaoYeuCauBaoHanhRequest req) {
        if (req.warrantyId() == null) {
            throw new RuntimeException("Chưa chọn phiếu bảo hành");
        }
        Warranty w = warrantyRepo.findById(req.warrantyId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy phiếu bảo hành"));
        if (w.getNguoiDung() == null || w.getNguoiDung().getEmail() == null) {
            throw new RuntimeException("Phiếu bảo hành này chưa gắn với tài khoản khách nào");
        }
        // Gọi đúng service khách vẫn dùng -> mọi kiểm tra (còn hạn, phạm vi phục vụ tận nơi,
        // phụ phí) áp dụng y hệt, không có đường tắt riêng cho quầy.
        warrantyService.createRequest(w.getId(), w.getNguoiDung().getEmail(), req.moTaLoi(),
                null, req.hinhThuc(), req.centerId());
        return toBaoHanhDto(w);
    }

    // ============================================================
    //  Việc còn dang dở (lịch hẹn / đổi trả / thu cũ)
    // ============================================================

    private List<PosViecDangXuLyDto> viecDangXuLyCua(NguoiDung u) {
        List<PosViecDangXuLyDto> ra = new ArrayList<>();

        for (ServiceAppointment a : appointmentRepo.findByUserEmailOrderByCreatedAtDesc(u.getEmail())) {
            ra.add(new PosViecDangXuLyDto("Lịch hẹn dịch vụ", a.getMaLich(),
                    a.getModel() != null ? a.getModel() : a.getLoaiThietBi(),
                    a.getTrangThai(), nhanLichHen(a.getTrangThai()), a.getCreatedAt()));
        }
        for (ReturnRequest r : returnRepo.findByUserEmailOrderByCreatedAtDesc(u.getEmail())) {
            ra.add(new PosViecDangXuLyDto("Đổi trả", r.getMaYeuCau(),
                    r.getTenSanPham() != null ? r.getTenSanPham() : r.getMaDon(),
                    r.getTrangThai(), nhanDoiTra(r.getTrangThai()), r.getCreatedAt()));
        }
        for (TradeInRequest t : tradeInRepo.findByNguoiDungOrderByCreatedAtDesc(u)) {
            ra.add(new PosViecDangXuLyDto("Thu cũ đổi mới", "TC" + t.getId(),
                    (t.getHang() == null ? "" : t.getHang() + " ") + t.getModel(),
                    t.getTrangThai(), nhanThuCu(t.getTrangThai()), t.getCreatedAt()));
        }

        ra.sort(Comparator.comparing(PosViecDangXuLyDto::thoiGian,
                Comparator.nullsLast(Comparator.reverseOrder())));
        return ra;
    }

    private String nhanLichHen(String s) {
        return switch (s) {
            case "cho_xac_nhan" -> "Chờ xác nhận";
            case "da_xac_nhan" -> "Đã xác nhận";
            case "dang_xu_ly" -> "Đang xử lý";
            case "hoan_thanh" -> "Hoàn thành";
            case "da_huy" -> "Đã huỷ";
            default -> s;
        };
    }

    private String nhanDoiTra(String s) {
        return switch (s) {
            case "cho_xu_ly" -> "Chờ xử lý";
            case "dang_xu_ly" -> "Đang xử lý";
            case "chap_nhan" -> "Đã chấp nhận";
            case "tu_choi" -> "Từ chối";
            case "hoan_tat" -> "Hoàn tất";
            default -> s;
        };
    }

    private String nhanThuCu(String s) {
        return switch (s) {
            case "cho_dinh_gia" -> "Chờ định giá";
            case "da_bao_gia" -> "Đã báo giá";
            case "khach_dong_y" -> "Khách đồng ý";
            case "da_nhan_may" -> "Đã nhận máy";
            case "da_kiem_tra" -> "Đã kiểm tra";
            case "da_cap_tin_dung" -> "Đã cấp tín dụng";
            case "tu_choi_thu" -> "Từ chối thu";
            case "khach_tu_choi" -> "Khách từ chối";
            case "huy_yeu_cau" -> "Đã huỷ";
            default -> s;
        };
    }

    /** Dùng cho màn hình phụ / in phiếu: mốc thời gian gần nhất của khách. */
    public Optional<LocalDateTime> lanGhePhepGanNhat(NguoiDung u) {
        return orderRepo.findByNguoiDungOrderByCreatedAtDesc(u).stream()
                .map(Order::getCreatedAt).findFirst();
    }
}
