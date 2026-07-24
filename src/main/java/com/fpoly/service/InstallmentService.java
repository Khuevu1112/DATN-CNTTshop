package com.fpoly.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.InstallmentDtos.CauHinhDto;
import com.fpoly.dto.InstallmentDtos.DangKyRequest;
import com.fpoly.dto.InstallmentDtos.DonAdminDto;
import com.fpoly.dto.InstallmentDtos.DonCuaToiDto;
import com.fpoly.dto.InstallmentDtos.PlanDto;
import com.fpoly.dto.InstallmentDtos.TinhToanDto;
import com.fpoly.model.InstallmentOrder;
import com.fpoly.model.InstallmentPlan;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.Product;
import com.fpoly.model.ProductVariant;
import com.fpoly.repository.InstallmentOrderRepository;
import com.fpoly.repository.InstallmentPlanRepository;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.ProductVariantRepository;

/** Trả góp — bảng dữ liệu lấy từ nhánh "review+trả-góp" của dev khác, phần nghiệp vụ viết mới.
 *
 * Đơn trả góp là ĐƠN ĐĂNG KÝ tư vấn, không phải đơn hàng: chưa trừ kho, chưa vào doanh thu.
 * Nhân viên thẩm định hồ sơ rồi mới dựng đơn hàng thật. */
@Service
public class InstallmentService {

    @Autowired private InstallmentPlanRepository planRepo;
    @Autowired private InstallmentOrderRepository orderRepo;
    @Autowired private ProductVariantRepository variantRepo;
    @Autowired private NguoiDungRepository nguoiDungRepo;
    @Autowired private NotificationService notificationService;

    /** Trả trước tối thiểu 20% giá trị đơn — chuẩn chung của các chương trình trả góp tiêu dùng,
     * và cũng là mức giảm rủi ro cho shop. */
    private static final BigDecimal TY_LE_TRA_TRUOC_TOI_THIEU = new BigDecimal("0.20");

    public static String nhanTrangThai(String tt) {
        return switch (tt) {
            case InstallmentOrder.PENDING -> "Chờ duyệt hồ sơ";
            case InstallmentOrder.APPROVED -> "Đã duyệt";
            case InstallmentOrder.REJECTED -> "Từ chối";
            case InstallmentOrder.CANCELLED -> "Đã huỷ";
            default -> tt;
        };
    }

    public CauHinhDto cauHinh() {
        List<PlanDto> ds = planRepo.findByActiveTrueOrderBySoThangAsc().stream()
                .map(p -> new PlanDto(p.getId(), p.getSoThang(), p.getLaiSuat()))
                .toList();
        return new CauHinhDto(ds, TY_LE_TRA_TRUOC_TOI_THIEU);
    }

    /** Tính thử bảng trả góp. Công thức LÃI PHẲNG (flat rate) — đúng như bảng lãi suất dev gốc
     * đưa (0% cho 3 tháng, tăng dần tới 7% cho 24 tháng):
     *
     *     số tiền vay   = giá bán × số lượng − trả trước
     *     tổng lãi      = số tiền vay × lãi suất%/tháng × số tháng
     *     tổng phải trả = số tiền vay + tổng lãi
     *     trả hàng tháng= tổng phải trả ÷ số tháng
     *
     * Lãi tính trên dư nợ GỐC BAN ĐẦU suốt kỳ hạn, không giảm dần theo dư nợ còn lại. Đây là
     * cách các chương trình trả góp qua công ty tài chính ở Việt Nam vẫn niêm yết, và cũng là
     * cách duy nhất khớp được với bảng lãi suất phẳng theo tháng trong INSTALLMENT_PLAN. */
    public TinhToanDto tinhToan(BigDecimal giaBan, Integer soLuong, Integer soThang, BigDecimal traTruoc) {
        InstallmentPlan plan = planRepo.findBySoThang(soThang)
                .filter(p -> Boolean.TRUE.equals(p.getActive()))
                .orElseThrow(() -> new RuntimeException("Kỳ hạn " + soThang + " tháng không khả dụng"));

        int sl = soLuong == null || soLuong < 1 ? 1 : soLuong;
        BigDecimal tongGia = giaBan.multiply(BigDecimal.valueOf(sl));
        BigDecimal truoc = traTruoc == null ? BigDecimal.ZERO : traTruoc;

        BigDecimal toiThieu = tongGia.multiply(TY_LE_TRA_TRUOC_TOI_THIEU).setScale(0, RoundingMode.CEILING);
        if (truoc.compareTo(toiThieu) < 0) {
            throw new RuntimeException("Trả trước tối thiểu " + toiThieu.longValue() + "đ (20% giá trị đơn)");
        }
        if (truoc.compareTo(tongGia) >= 0) {
            throw new RuntimeException("Trả trước phải nhỏ hơn giá trị đơn hàng");
        }

        BigDecimal soTienVay = tongGia.subtract(truoc);
        BigDecimal tongLai = soTienVay
                .multiply(plan.getLaiSuat()).divide(BigDecimal.valueOf(100), 10, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(soThang))
                .setScale(0, RoundingMode.HALF_UP);
        BigDecimal tongPhaiTra = soTienVay.add(tongLai);
        BigDecimal moiThang = tongPhaiTra.divide(BigDecimal.valueOf(soThang), 0, RoundingMode.HALF_UP);

        return new TinhToanDto(soThang, plan.getLaiSuat(), tongGia, truoc,
                soTienVay, tongLai, moiThang, tongPhaiTra);
    }

    /** Tính thử theo biến thể sản phẩm — client chỉ gửi variantId, giá lấy từ DB. */
    public TinhToanDto tinhToanTheoVariant(Integer variantId, Integer soLuong, Integer soThang, BigDecimal traTruoc) {
        ProductVariant v = variantRepo.findById(variantId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));
        return tinhToan(v.getPrice(), soLuong, soThang, traTruoc);
    }

    @Transactional
    public DonCuaToiDto dangKy(DangKyRequest req, String email) {
        if (req.variantId() == null) throw new RuntimeException("Vui lòng chọn phiên bản sản phẩm");
        if (req.tenKhach() == null || req.tenKhach().isBlank()) throw new RuntimeException("Vui lòng nhập họ tên");
        if (req.soDienThoai() == null || req.soDienThoai().isBlank()) throw new RuntimeException("Vui lòng nhập số điện thoại");
        if (req.diaChi() == null || req.diaChi().isBlank()) throw new RuntimeException("Vui lòng nhập địa chỉ");
        if (req.soCccd() == null || req.soCccd().isBlank()) throw new RuntimeException("Vui lòng nhập số CCCD/CMND");

        ProductVariant v = variantRepo.findById(req.variantId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));
        Product p = v.getProduct();

        // Giá LẤY TỪ DB, không nhận từ client — nếu tin số client gửi thì khách sửa được giá bán
        // và do đó sửa được cả số tiền vay lẫn khoản trả hàng tháng.
        TinhToanDto tt = tinhToan(v.getPrice(), req.soLuong(), req.soThang(), req.traTruoc());

        InstallmentOrder o = new InstallmentOrder();
        o.setNguoiDung(email == null ? null : nguoiDungRepo.findByEmail(email).orElse(null));
        o.setProduct(p);
        o.setVariant(v);
        o.setTenSanPham(p.getName());
        o.setTuyChon(v.getSku());
        o.setSoLuong(req.soLuong() == null || req.soLuong() < 1 ? 1 : req.soLuong());
        o.setSoThang(tt.soThang());
        o.setLaiSuat(tt.laiSuat());
        o.setGiaBan(v.getPrice());
        o.setTraTruoc(tt.traTruoc());
        o.setSoTienVay(tt.soTienVay());
        o.setTongLai(tt.tongLai());
        o.setTraHangThang(tt.traHangThang());
        o.setTongPhaiTra(tt.tongPhaiTra());
        o.setTenKhach(req.tenKhach().trim());
        o.setSoDienThoai(req.soDienThoai().trim());
        o.setEmail(req.email());
        o.setDiaChi(req.diaChi().trim());
        o.setSoCccd(req.soCccd().trim());

        InstallmentOrder saved = orderRepo.save(o);

        notificationService.tao("installment", "Đăng ký trả góp mới",
                saved.getTenKhach() + " — " + saved.getTenSanPham() + " (" + saved.getSoThang() + " tháng)",
                "/installment");

        return toDonCuaToi(saved);
    }

    public List<DonCuaToiDto> donCuaToi(String email) {
        NguoiDung u = nguoiDungRepo.findByEmail(email).orElse(null);
        if (u == null) return List.of();
        return orderRepo.findByNguoiDungOrderByCreatedAtDesc(u).stream().map(this::toDonCuaToi).toList();
    }

    // ==================== Phía nhân viên ====================

    public List<DonAdminDto> tatCaDon(String trangThai) {
        List<InstallmentOrder> ds = (trangThai == null || trangThai.isBlank())
                ? orderRepo.findAllByOrderByCreatedAtDesc()
                : orderRepo.findByTrangThaiOrderByCreatedAtDesc(trangThai);
        return ds.stream().map(this::toDonAdmin).toList();
    }

    @Transactional
    public DonAdminDto doiTrangThai(Integer id, String trangThaiMoi, String ghiChu) {
        InstallmentOrder o = orderRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn trả góp"));

        if (!List.of(InstallmentOrder.APPROVED, InstallmentOrder.REJECTED, InstallmentOrder.CANCELLED)
                .contains(trangThaiMoi)) {
            throw new RuntimeException("Trạng thái không hợp lệ");
        }
        if (!InstallmentOrder.PENDING.equals(o.getTrangThai())) {
            throw new RuntimeException("Hồ sơ đã được xử lý (" + nhanTrangThai(o.getTrangThai()) + ")");
        }

        o.setTrangThai(trangThaiMoi);
        o.setGhiChuNhanVien(ghiChu);
        orderRepo.save(o);

        if (o.getNguoiDung() != null) {
            boolean duyet = InstallmentOrder.APPROVED.equals(trangThaiMoi);
            notificationService.taoChoUser(o.getNguoiDung().getId(), "installment_result",
                    duyet ? "Hồ sơ trả góp đã được duyệt" : "Hồ sơ trả góp chưa được duyệt",
                    duyet
                        ? "Nhân viên sẽ liên hệ để hoàn tất thủ tục cho " + o.getTenSanPham() + "."
                        : "Rất tiếc, hồ sơ trả góp cho " + o.getTenSanPham() + " chưa được duyệt."
                          + (ghiChu == null ? "" : " Lý do: " + ghiChu),
                    "/tai-khoan");
        }
        return toDonAdmin(o);
    }

    // ==================== Chuyển đổi DTO ====================

    private DonCuaToiDto toDonCuaToi(InstallmentOrder o) {
        return new DonCuaToiDto(
                o.getId(), o.getTenSanPham(), o.getSoLuong(),
                o.getSoThang(), o.getLaiSuat(),
                o.getGiaBan(), o.getTraTruoc(), o.getTraHangThang(), o.getTongPhaiTra(),
                o.getTrangThai(), nhanTrangThai(o.getTrangThai()), o.getGhiChuNhanVien(), o.getCreatedAt()
        );
    }

    private DonAdminDto toDonAdmin(InstallmentOrder o) {
        return new DonAdminDto(
                o.getId(),
                o.getProduct() == null ? null : o.getProduct().getId(),
                o.getVariant() == null ? null : o.getVariant().getId(),
                o.getTenSanPham(), o.getTuyChon(), o.getSoLuong(),
                o.getSoThang(), o.getLaiSuat(),
                o.getGiaBan(), o.getTraTruoc(), o.getSoTienVay(),
                o.getTongLai(), o.getTraHangThang(), o.getTongPhaiTra(),
                o.getTenKhach(), o.getSoDienThoai(), o.getEmail(), o.getDiaChi(), o.getSoCccd(),
                o.getNguoiDung() != null,
                o.getTrangThai(), nhanTrangThai(o.getTrangThai()), o.getGhiChuNhanVien(),
                o.getCreatedAt(), o.getUpdatedAt()
        );
    }
}
