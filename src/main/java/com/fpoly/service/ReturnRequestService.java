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

import com.fpoly.dto.ReturnDtos.DongSanPhamDto;
import com.fpoly.dto.ReturnDtos.DonChoDoiTraDto;
import com.fpoly.dto.ReturnDtos.ReturnDto;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.Order;
import com.fpoly.model.OrderItem;
import com.fpoly.model.ProductVariant;
import com.fpoly.model.ReturnRequest;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.OrderRepository;
import com.fpoly.repository.ProductVariantRepository;
import com.fpoly.repository.ReturnRequestRepository;

/** Đổi trả hàng (1 đổi 1 trong 7 ngày). Chính sách RIÊNG với bảo hành — xem 71_return_request.sql.
 * File tải lên (video/ảnh) do controller lưu đĩa rồi truyền URL vào service. */
@Service
public class ReturnRequestService {

    @Autowired private ReturnRequestRepository repo;
    @Autowired private NguoiDungRepository nguoiDungRepo;
    @Autowired private OrderRepository orderRepo;
    @Autowired private ProductVariantRepository variantRepo;
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

    /** CSKH tự khởi tạo yêu cầu hộ khách (khách mang máy tới cửa hàng, gọi hotline...).
     * Bắt buộc có mã đơn — đây là căn cứ để biết khách nào, mua gì, và hoàn kho về đâu; không
     * bắt buộc video mở hàng vì nhân viên đang trực tiếp cầm máy trên tay.
     * orderItemId = dòng sản phẩm trong đơn cần đổi/trả (null nếu cả đơn chỉ có 1 dòng). */
    @Transactional
    public ReturnDto taoYeuCauBoiAdmin(String maDon, Integer orderItemId, String lyDo,
                                       String noiDung, Integer soLuong) {
        if (maDon == null || maDon.isBlank()) {
            throw new RuntimeException("Vui lòng nhập mã đơn hàng cần đổi/trả.");
        }
        if (noiDung == null || noiDung.isBlank()) {
            throw new RuntimeException("Vui lòng mô tả nội dung cần đổi trả.");
        }
        Order order = orderRepo.findByMaDonHang(maDon.trim())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng " + maDon.trim()));
        if (order.getNguoiDung() == null) {
            throw new RuntimeException("Đơn hàng này không gắn với tài khoản khách nào.");
        }

        List<OrderItem> chiTiet = order.getChiTiet() == null ? List.of() : order.getChiTiet();
        OrderItem dong = null;
        if (orderItemId != null) {
            dong = chiTiet.stream().filter(i -> orderItemId.equals(i.getId())).findFirst()
                    .orElseThrow(() -> new RuntimeException("Dòng sản phẩm không thuộc đơn " + order.getMaDonHang()));
        } else if (chiTiet.size() == 1) {
            dong = chiTiet.get(0);
        } else if (chiTiet.size() > 1) {
            throw new RuntimeException("Đơn có nhiều sản phẩm, vui lòng chọn sản phẩm cần đổi/trả.");
        }

        ReturnRequest r = new ReturnRequest();
        r.setMaYeuCau(sinhMa());
        r.setUser(order.getNguoiDung());
        r.setOrder(order);
        r.setMaDon(order.getMaDonHang());
        r.setKenhMua("tai_cua_hang");
        r.setTaoBoiAdmin(true);
        r.setLyDo(lyDo);
        r.setNoiDung(noiDung.trim());
        if (dong != null) {
            r.setVariant(dong.getVariant());
            r.setTenSanPham(dong.getTenSanPham());
            int max = dong.getSoLuong() == null ? 1 : dong.getSoLuong();
            int sl = soLuong == null || soLuong <= 0 ? max : soLuong;
            if (sl > max) {
                throw new RuntimeException("Số lượng đổi/trả (" + sl + ") vượt quá số đã mua (" + max + ").");
            }
            r.setSoLuong(sl);
        }
        r.setTrangThai("cho_xu_ly");
        repo.save(r);

        notificationService.taoChoUser(order.getNguoiDung().getId(), "return_request",
                "CNTTShop đã tạo yêu cầu đổi trả " + r.getMaYeuCau(),
                "Nhân viên CSKH vừa khởi tạo yêu cầu đổi trả cho đơn " + order.getMaDonHang()
                        + ". Bạn có thể theo dõi tiến độ tại trang Đổi trả.",
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

        // Hàng chỉ thực sự về kho ở bước cuối (hoan_tat) — "chap_nhan" mới là đồng ý cho đổi/trả,
        // khách chưa gửi máy về nên chưa được cộng kho.
        if ("hoan_tat".equals(trangThaiMoi)) {
            hoanTonKho(r);
        }

        repo.save(r);

        if (r.getUser() != null) {
            notificationService.taoChoUser(r.getUser().getId(), "return_request",
                    "Yêu cầu đổi trả " + r.getMaYeuCau() + ": " + nhan(trangThaiMoi),
                    ghiChu != null && !ghiChu.isBlank() ? ghiChu : "Trạng thái yêu cầu đổi trả của bạn vừa được cập nhật.",
                    "/ho-tro/doi-tra");
        }
        return toDto(r);
    }

    /** Cộng lại tồn kho cho biến thể được trả về. Chỉ chạy khi biết CHÍNH XÁC biến thể — yêu cầu
     * cũ (trước 79_return_restock.sql) hoặc yêu cầu khách khai chay không gắn được dòng sản phẩm
     * nào thì bỏ qua, thà để CSKH chỉnh tay còn hơn cộng bừa làm sai sổ kho. Cờ daHoanKho chống
     * cộng 2 lần. */
    private void hoanTonKho(ReturnRequest r) {
        if (Boolean.TRUE.equals(r.getDaHoanKho())) return;

        ProductVariant v = r.getVariant();
        // Yêu cầu không chỉ rõ biến thể nhưng đơn chỉ có đúng 1 dòng sản phẩm -> suy ra được,
        // không có gì mơ hồ.
        int soLuong = r.getSoLuong() != null && r.getSoLuong() > 0 ? r.getSoLuong() : 1;
        if (v == null && r.getOrder() != null
                && r.getOrder().getChiTiet() != null && r.getOrder().getChiTiet().size() == 1) {
            OrderItem oi = r.getOrder().getChiTiet().get(0);
            v = oi.getVariant();
            if (r.getSoLuong() == null) soLuong = oi.getSoLuong() == null ? 1 : oi.getSoLuong();
        }
        if (v == null) return;

        v.setStock((v.getStock() == null ? 0 : v.getStock()) + soLuong);
        variantRepo.save(v);
        r.setDaHoanKho(true);
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
                r.getCreatedAt(), r.getUpdatedAt(),
                r.getSoLuong(), r.getDaHoanKho(), r.getTaoBoiAdmin());
    }

    /** Tra cứu đơn cho màn tạo yêu cầu bên Admin Console — trả về khách hàng + danh sách dòng
     * sản phẩm để CSKH chọn đúng biến thể cần đổi/trả. */
    public DonChoDoiTraDto traCuuDonChoDoiTra(String maDon) {
        if (maDon == null || maDon.isBlank()) {
            throw new RuntimeException("Vui lòng nhập mã đơn hàng.");
        }
        Order order = orderRepo.findByMaDonHang(maDon.trim())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng " + maDon.trim()));
        NguoiDung u = order.getNguoiDung();
        List<DongSanPhamDto> dong = (order.getChiTiet() == null ? List.<OrderItem>of() : order.getChiTiet())
                .stream()
                .map(i -> new DongSanPhamDto(i.getId(), i.getTenSanPham(),
                        i.getVariant() != null ? i.getVariant().getSku() : null, i.getSoLuong()))
                .toList();
        return new DonChoDoiTraDto(order.getMaDonHang(),
                u != null ? u.getHoTen() : null,
                u != null ? u.getEmail() : null,
                u != null ? u.getSoDienThoai() : null,
                order.getTrangThai(), dong);
    }
}
