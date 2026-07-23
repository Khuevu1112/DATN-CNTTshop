package com.fpoly.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.TradeInDtos.CreditDto;
import com.fpoly.dto.TradeInDtos.LichSuDto;
import com.fpoly.dto.TradeInDtos.TaoYeuCauRequest;
import com.fpoly.dto.TradeInDtos.YeuCauDto;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.TradeInCredit;
import com.fpoly.model.TradeInHistory;
import com.fpoly.model.TradeInRequest;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.TradeInCreditRepository;
import com.fpoly.repository.TradeInHistoryRepository;
import com.fpoly.repository.TradeInRequestRepository;

/** Thu cũ đổi mới.
 *
 * Nguyên tắc chi phối toàn bộ service này: GIÁ TRỊ MÁY CŨ CHỈ BIẾT CHẮC SAU KHI CẦM MÁY. Nên có
 * hai con số tách bạch — giá tạm tính (báo online theo lời khai của khách) và giá chốt (sau khi
 * kỹ thuật kiểm tra). Tín dụng CHỈ được phát hành theo giá chốt, ở bước da_kiem_tra trở đi.
 * Trước đó khách không cầm được đồng nào, kể cả khi đã đồng ý giá tạm tính.
 *
 * Tín dụng phát ra là bản ghi riêng gắn cứng user_id (xem TradeInCredit), KHÔNG phải coupon —
 * lý do đầy đủ ghi trong database/64_trade_in.sql. */
@Service
public class TradeInService {

    @Autowired private TradeInRequestRepository requestRepo;
    @Autowired private TradeInCreditRepository creditRepo;
    @Autowired private TradeInHistoryRepository historyRepo;
    @Autowired private NguoiDungRepository nguoiDungRepo;
    @Autowired private NotificationService notificationService;

    /** Tín dụng có hạn dùng — không để shop treo nợ vô thời hạn, và thúc khách quay lại mua. */
    private static final int SO_NGAY_HIEU_LUC_TIN_DUNG = 90;

    /** Chuyển trạng thái hợp lệ. Cùng lý do với đơn hàng: không cho nhảy cóc, vì mỗi bước gắn với
     * một sự kiện có thật ngoài đời (đã báo giá, đã nhận máy, đã kiểm tra). */
    private static final Map<String, List<String>> LUONG_HOP_LE = Map.of(
            TradeInRequest.CHO_DINH_GIA, List.of(TradeInRequest.DA_BAO_GIA, TradeInRequest.TU_CHOI_THU, TradeInRequest.HUY_YEU_CAU),
            TradeInRequest.DA_BAO_GIA,   List.of(TradeInRequest.KHACH_DONG_Y, TradeInRequest.KHACH_TU_CHOI, TradeInRequest.HUY_YEU_CAU),
            TradeInRequest.KHACH_DONG_Y, List.of(TradeInRequest.DA_NHAN_MAY, TradeInRequest.HUY_YEU_CAU),
            TradeInRequest.DA_NHAN_MAY,  List.of(TradeInRequest.DA_KIEM_TRA, TradeInRequest.TU_CHOI_THU),
            TradeInRequest.DA_KIEM_TRA,  List.of(TradeInRequest.DA_CAP_TIN_DUNG, TradeInRequest.TU_CHOI_THU)
    );

    public static String nhanTrangThai(String tt) {
        return switch (tt) {
            case TradeInRequest.CHO_DINH_GIA -> "Chờ định giá";
            case TradeInRequest.DA_BAO_GIA -> "Đã báo giá tạm tính";
            case TradeInRequest.KHACH_DONG_Y -> "Khách đồng ý — chờ mang máy tới";
            case TradeInRequest.DA_NHAN_MAY -> "Đã nhận máy — đang kiểm tra";
            case TradeInRequest.DA_KIEM_TRA -> "Đã kiểm tra — chốt giá";
            case TradeInRequest.DA_CAP_TIN_DUNG -> "Đã cấp tín dụng";
            case TradeInRequest.TU_CHOI_THU -> "Shop từ chối thu";
            case TradeInRequest.KHACH_TU_CHOI -> "Khách không đồng ý giá";
            case TradeInRequest.HUY_YEU_CAU -> "Đã huỷ";
            default -> tt;
        };
    }

    // ==================== Phía khách ====================

    @Transactional
    public YeuCauDto taoYeuCau(String email, TaoYeuCauRequest req, List<String> duongDanAnh) {
        NguoiDung user = layUser(email);

        if (req.model() == null || req.model().isBlank()) {
            throw new RuntimeException("Vui lòng nhập tên máy / model");
        }
        if (duongDanAnh == null || duongDanAnh.isEmpty()) {
            throw new RuntimeException("Vui lòng gửi ít nhất 1 ảnh hiện trạng máy");
        }

        TradeInRequest yc = new TradeInRequest();
        yc.setNguoiDung(user);
        yc.setLoaiThietBi(req.loaiThietBi() == null ? "laptop" : req.loaiThietBi());
        yc.setHang(req.hang());
        yc.setModel(req.model().trim());
        yc.setTinhTrangKhai(req.tinhTrangKhai() == null ? "tot" : req.tinhTrangKhai());
        yc.setNamMua(req.namMua());
        yc.setMoTa(req.moTa());
        yc.setSerial(req.serial());
        if (duongDanAnh.size() > 0) yc.setPhoto1(duongDanAnh.get(0));
        if (duongDanAnh.size() > 1) yc.setPhoto2(duongDanAnh.get(1));
        if (duongDanAnh.size() > 2) yc.setPhoto3(duongDanAnh.get(2));
        if (duongDanAnh.size() > 3) yc.setPhoto4(duongDanAnh.get(3));

        TradeInRequest saved = requestRepo.save(yc);
        ghiLichSu(saved, TradeInRequest.CHO_DINH_GIA, "Khách gửi yêu cầu thu cũ", user);

        notificationService.tao("trade_in", "Yêu cầu thu cũ mới",
                user.getHoTen() + " muốn bán lại: " + saved.getModel(), "/trade-in");

        return toDto(saved, false);
    }

    public List<YeuCauDto> yeuCauCuaToi(String email) {
        return requestRepo.findByNguoiDungOrderByCreatedAtDesc(layUser(email))
                .stream().map(y -> toDto(y, false)).toList();
    }

    /** Khách phản hồi giá tạm tính. dongY=false -> kết thúc luồng, không thu máy nữa. */
    @Transactional
    public YeuCauDto khachPhanHoiBaoGia(Integer id, String email, boolean dongY) {
        NguoiDung user = layUser(email);
        TradeInRequest yc = requestRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy yêu cầu"));
        if (!yc.getNguoiDung().getId().equals(user.getId())) {
            throw new RuntimeException("Yêu cầu này không thuộc về bạn");
        }
        if (!TradeInRequest.DA_BAO_GIA.equals(yc.getTrangThai())) {
            throw new RuntimeException("Yêu cầu chưa ở bước chờ bạn xác nhận giá");
        }
        String moi = dongY ? TradeInRequest.KHACH_DONG_Y : TradeInRequest.KHACH_TU_CHOI;
        doiTrangThai(yc, moi, dongY ? "Khách đồng ý giá tạm tính" : "Khách không đồng ý giá", user);
        return toDto(yc, false);
    }

    // ==================== Phía admin ====================

    public List<YeuCauDto> tatCaYeuCau(String trangThai) {
        List<TradeInRequest> ds = (trangThai == null || trangThai.isBlank())
                ? requestRepo.findAllByOrderByCreatedAtDesc()
                : requestRepo.findByTrangThaiOrderByCreatedAtDesc(trangThai);
        return ds.stream().map(y -> toDto(y, true)).toList();
    }

    public YeuCauDto chiTiet(Integer id) {
        return toDto(requestRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy yêu cầu")), true);
    }

    /** Báo giá TẠM TÍNH dựa trên ảnh + lời khai. Chưa cấp tiền, chưa ràng buộc gì. */
    @Transactional
    public YeuCauDto baoGia(Integer id, BigDecimal giaTamTinh, String ghiChu, String emailNhanVien) {
        if (giaTamTinh == null || giaTamTinh.signum() <= 0) {
            throw new RuntimeException("Giá tạm tính phải lớn hơn 0");
        }
        TradeInRequest yc = requestRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy yêu cầu"));
        NguoiDung nv = layUser(emailNhanVien);

        yc.setGiaTamTinh(giaTamTinh);
        yc.setNguoiDinhGia(nv);
        doiTrangThai(yc, TradeInRequest.DA_BAO_GIA,
                "Báo giá tạm tính " + giaTamTinh.longValue() + "đ" + (ghiChu == null ? "" : " — " + ghiChu), nv);

        notificationService.taoChoUser(yc.getNguoiDung().getId(), "trade_in_quote",
                "Đã có giá tạm tính cho " + yc.getModel(),
                "Shop định giá tạm tính " + giaTamTinh.longValue() + "đ. Mức cuối cùng sẽ chốt sau khi kiểm tra máy thật.",
                "/tai-khoan/thu-cu");
        return toDto(yc, true);
    }

    /** Chốt giá SAU KHI kiểm máy thật. Đây là con số cuối cùng dùng để phát hành tín dụng. */
    @Transactional
    public YeuCauDto chotGia(Integer id, BigDecimal giaChot, String ghiChu, String emailNhanVien) {
        if (giaChot == null || giaChot.signum() <= 0) {
            throw new RuntimeException("Giá chốt phải lớn hơn 0");
        }
        TradeInRequest yc = requestRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy yêu cầu"));
        NguoiDung nv = layUser(emailNhanVien);

        yc.setGiaChot(giaChot);
        yc.setGhiChuKtv(ghiChu);
        yc.setNguoiDinhGia(nv);
        doiTrangThai(yc, TradeInRequest.DA_KIEM_TRA,
                "Chốt giá " + giaChot.longValue() + "đ" + (ghiChu == null ? "" : " — " + ghiChu), nv);

        notificationService.taoChoUser(yc.getNguoiDung().getId(), "trade_in_final",
                "Đã chốt giá thu " + yc.getModel(),
                "Mức thu cuối cùng: " + giaChot.longValue() + "đ. Xác nhận để nhận tín dụng mua hàng.",
                "/tai-khoan/thu-cu");
        return toDto(yc, true);
    }

    /** Phát hành tín dụng — bước cuối, biến giá chốt thành tiền khách tiêu được. */
    @Transactional
    public YeuCauDto capTinDung(Integer id, String emailNhanVien) {
        TradeInRequest yc = requestRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy yêu cầu"));
        if (!TradeInRequest.DA_KIEM_TRA.equals(yc.getTrangThai())) {
            throw new RuntimeException("Chỉ cấp tín dụng sau khi đã kiểm tra và chốt giá");
        }
        if (yc.getGiaChot() == null || yc.getGiaChot().signum() <= 0) {
            throw new RuntimeException("Chưa có giá chốt");
        }

        TradeInCredit tc = new TradeInCredit();
        tc.setYeuCau(yc);
        tc.setNguoiDung(yc.getNguoiDung());
        tc.setSoTien(yc.getGiaChot());
        // Đặt đơn tối thiểu BẰNG chính số tiền: tín dụng dùng một lần và không hoàn phần dư, nên
        // ràng buộc này đảm bảo khách không bao giờ mất tiền vì lỡ mua đơn nhỏ hơn.
        tc.setDonToiThieu(yc.getGiaChot());
        tc.setHetHan(LocalDateTime.now().plusDays(SO_NGAY_HIEU_LUC_TIN_DUNG));
        creditRepo.save(tc);

        NguoiDung nv = layUser(emailNhanVien);
        doiTrangThai(yc, TradeInRequest.DA_CAP_TIN_DUNG,
                "Cấp tín dụng " + yc.getGiaChot().longValue() + "đ (hạn " + SO_NGAY_HIEU_LUC_TIN_DUNG + " ngày)", nv);

        notificationService.taoChoUser(yc.getNguoiDung().getId(), "trade_in_credit",
                "Bạn nhận được " + yc.getGiaChot().longValue() + "đ tín dụng thu cũ",
                "Dùng để trừ thẳng vào đơn hàng tiếp theo, hạn dùng " + SO_NGAY_HIEU_LUC_TIN_DUNG + " ngày.",
                "/tai-khoan/thu-cu");
        return toDto(yc, true);
    }

    /** Các bước còn lại chỉ đổi trạng thái: nhận máy, từ chối thu, huỷ. */
    @Transactional
    public YeuCauDto doiTrangThaiAdmin(Integer id, String trangThaiMoi, String ghiChu, String emailNhanVien) {
        TradeInRequest yc = requestRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy yêu cầu"));
        doiTrangThai(yc, trangThaiMoi, ghiChu, layUser(emailNhanVien));
        return toDto(yc, true);
    }

    // ==================== Tín dụng ====================

    public List<CreditDto> tinDungCuaToi(String email) {
        return creditRepo.findByNguoiDungOrderByCreatedAtDesc(layUser(email))
                .stream().map(this::toCreditDto).toList();
    }

    /** Tín dụng dùng được cho một đơn có tiền hàng là tienHang. Trả null nếu không dùng được —
     * người gọi tự quyết định báo lỗi hay bỏ qua.
     *
     * LUÔN kiểm user: đây là điểm mấu chốt khiến tín dụng an toàn hơn coupon. Biết id của người
     * khác cũng không tiêu được. */
    public TradeInCredit layTinDungHopLe(Integer creditId, NguoiDung user, BigDecimal tienHang) {
        if (creditId == null) return null;
        TradeInCredit tc = creditRepo.findById(creditId).orElse(null);
        if (tc == null) return null;

        if (!tc.getNguoiDung().getId().equals(user.getId())) {
            throw new RuntimeException("Tín dụng thu cũ này không thuộc về bạn");
        }
        if (!tc.conDungDuoc()) {
            throw new RuntimeException("Tín dụng thu cũ đã dùng hoặc hết hạn");
        }
        if (tienHang.compareTo(tc.getDonToiThieu()) < 0) {
            throw new RuntimeException("Đơn hàng phải từ " + tc.getDonToiThieu().longValue()
                    + "đ mới dùng được tín dụng này (tín dụng dùng một lần, không hoàn phần dư)");
        }
        return tc;
    }

    /** Đánh dấu đã tiêu — gọi sau khi đơn được lưu thành công. */
    @Transactional
    public void danhDauDaDung(TradeInCredit tc, Integer orderId) {
        tc.setTrangThai(TradeInCredit.DA_DUNG);
        tc.setDonDaDung(orderId);
        tc.setUsedAt(LocalDateTime.now());
        creditRepo.save(tc);
    }

    /** Đơn bị huỷ -> trả lại tín dụng cho khách, không để mất trắng. */
    @Transactional
    public void hoanTinDungNeuDonBiHuy(Integer orderId, Integer creditId) {
        if (creditId == null) return;
        creditRepo.findById(creditId).ifPresent(tc -> {
            if (!TradeInCredit.DA_DUNG.equals(tc.getTrangThai())) return;
            if (tc.getDonDaDung() != null && !tc.getDonDaDung().equals(orderId)) return;
            tc.setTrangThai(TradeInCredit.CON_HIEU_LUC);
            tc.setDonDaDung(null);
            tc.setUsedAt(null);
            creditRepo.save(tc);
        });
    }

    // ==================== Nội bộ ====================

    private void doiTrangThai(TradeInRequest yc, String moi, String ghiChu, NguoiDung nguoi) {
        if (yc.daKetThuc()) {
            throw new RuntimeException("Yêu cầu đã kết thúc, không đổi trạng thái được nữa");
        }
        List<String> choPhep = LUONG_HOP_LE.getOrDefault(yc.getTrangThai(), List.of());
        if (!choPhep.contains(moi)) {
            throw new RuntimeException("Không thể chuyển từ \"" + nhanTrangThai(yc.getTrangThai())
                    + "\" sang \"" + nhanTrangThai(moi) + "\"");
        }
        yc.setTrangThai(moi);
        requestRepo.save(yc);
        ghiLichSu(yc, moi, ghiChu, nguoi);
    }

    private void ghiLichSu(TradeInRequest yc, String trangThai, String ghiChu, NguoiDung nguoi) {
        TradeInHistory h = new TradeInHistory();
        h.setYeuCau(yc);
        h.setTrangThai(trangThai);
        h.setGhiChu(ghiChu);
        h.setNguoiThucHien(nguoi);
        historyRepo.save(h);
    }

    private NguoiDung layUser(String email) {
        if (email == null) return null;
        return nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
    }

    private YeuCauDto toDto(TradeInRequest y, boolean choAdmin) {
        List<String> anh = new ArrayList<>();
        for (String a : new String[] { y.getPhoto1(), y.getPhoto2(), y.getPhoto3(), y.getPhoto4() }) {
            if (a != null && !a.isBlank()) anh.add(a);
        }

        List<LichSuDto> ls = y.getLichSu() == null ? List.of() : y.getLichSu().stream()
                .map(h -> new LichSuDto(h.getTrangThai(), h.getGhiChu(),
                        h.getNguoiThucHien() == null ? null : h.getNguoiThucHien().getHoTen(),
                        h.getThoiGian()))
                .toList();

        // Tín dụng đã phát cho yêu cầu này (nếu có) — hiện để khách biết còn dùng được không.
        TradeInCredit tc = creditRepo.findByNguoiDungOrderByCreatedAtDesc(y.getNguoiDung()).stream()
                .filter(c -> c.getYeuCau().getId().equals(y.getId()))
                .findFirst().orElse(null);

        return new YeuCauDto(
                y.getId(), y.getLoaiThietBi(), y.getHang(), y.getModel(),
                y.getTinhTrangKhai(), y.getNamMua(), y.getMoTa(), y.getSerial(),
                anh, y.getGiaTamTinh(), y.getGiaChot(),
                y.getTrangThai(), nhanTrangThai(y.getTrangThai()), y.getGhiChuKtv(),
                y.getCreatedAt(), y.getUpdatedAt(),
                choAdmin ? y.getNguoiDung().getHoTen() : null,
                choAdmin ? y.getNguoiDung().getSoDienThoai() : null,
                ls,
                tc == null ? null : tc.getId(),
                tc == null ? null : tc.getSoTien(),
                tc == null ? null : tc.getTrangThai()
        );
    }

    private CreditDto toCreditDto(TradeInCredit tc) {
        return new CreditDto(
                tc.getId(), tc.getSoTien(), tc.getDonToiThieu(), tc.getHetHan(), tc.getTrangThai(),
                tc.getYeuCau() == null ? null : tc.getYeuCau().getModel(),
                tc.getDonDaDung(), tc.conDungDuoc()
        );
    }
}
