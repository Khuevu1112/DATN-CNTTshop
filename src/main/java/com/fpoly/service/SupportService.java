package com.fpoly.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.text.Normalizer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.SupportDtos.ChinhSachBaoHanhDto;
import com.fpoly.dto.SupportDtos.FaqDanhMucDto;
import com.fpoly.dto.SupportDtos.FaqItemDto;
import com.fpoly.dto.SupportDtos.GiaSuaChuaDto;
import com.fpoly.dto.SupportDtos.TongQuanHoTroDto;
import com.fpoly.dto.SupportDtos.TraCuuBaoHanhDto;
import com.fpoly.dto.SupportDtos.TrungTamDto;
import com.fpoly.dto.SupportDtos.UocTinhDto;
import com.fpoly.model.FaqCategory;
import com.fpoly.model.FaqItem;
import com.fpoly.model.RepairPrice;
import com.fpoly.model.ServiceCenter;
import com.fpoly.model.Warranty;
import com.fpoly.model.WarrantyPolicy;
import com.fpoly.repository.FaqCategoryRepository;
import com.fpoly.repository.FaqItemRepository;
import com.fpoly.repository.RepairPriceRepository;
import com.fpoly.repository.ServiceCenterRepository;
import com.fpoly.repository.WarrantyPolicyRepository;
import com.fpoly.repository.WarrantyRepository;

/** Phần ĐỌC công khai của Trung tâm hỗ trợ: tra trung tâm bảo hành, tra bảo hành theo serial,
 * bảng giá sửa chữa, chính sách bảo hành và FAQ. Không endpoint nào ở đây cần đăng nhập —
 * việc ghi (đặt lịch) nằm ở ServiceAppointmentService, việc sửa nội dung ở AdminSupportService. */
@Service
public class SupportService {

    @Autowired private ServiceCenterRepository centerRepo;
    @Autowired private RepairPriceRepository repairRepo;
    @Autowired private WarrantyPolicyRepository policyRepo;
    @Autowired private WarrantyRepository warrantyRepo;
    @Autowired private FaqCategoryRepository faqCategoryRepo;
    @Autowired private FaqItemRepository faqItemRepo;

    /** Khách chỉ được chọn tối đa 2 hạng mục khi ước tính. Nhiều hơn thì con số cộng dồn xa rời
     * thực tế (kỹ thuật gộp công, thay cụm) và biến "tham khảo" thành "báo giá sai". */
    public static final int SO_HANG_MUC_TOI_DA = 2;

    /** Bán kính Trái Đất (km) cho công thức Haversine. */
    private static final double BAN_KINH_TRAI_DAT_KM = 6371.0;

    // ============================================================
    //  1. Trung tâm bảo hành
    // ============================================================

    /** Tìm trung tâm bảo hành.
     *
     * @param provinceId lọc theo tỉnh, null = mọi tỉnh
     * @param dichVu     mã nhóm thiết bị cần sửa, null = không lọc
     * @param tuKhoa     tìm trong tên + địa chỉ, bỏ dấu để "hai phong" khớp "Hải Phòng"
     * @param lat,lng    toạ độ của khách; có thì sắp xếp theo khoảng cách thật
     * @param banKinhKm  chỉ giữ điểm trong bán kính này (chỉ áp dụng khi có lat/lng)
     */
    public List<TrungTamDto> timTrungTam(Integer provinceId, String dichVu, String tuKhoa,
                                         Double lat, Double lng, Double banKinhKm) {
        String khoaTim = boDau(tuKhoa);

        List<TrungTamDto> ketQua = new ArrayList<>();
        for (ServiceCenter c : centerRepo.findPublic()) {
            if (provinceId != null && (c.getProvince() == null || !provinceId.equals(c.getProvince().getId()))) continue;
            if (dichVu != null && !dichVu.isBlank() && !nhanDichVu(c, dichVu)) continue;
            if (!khoaTim.isBlank() && !boDau(c.getTen() + " " + c.getDiaChi()).contains(khoaTim)) continue;

            Double khoangCach = tinhKhoangCach(c, lat, lng);
            // Điểm chưa cắm toạ độ không thể xếp theo khoảng cách -> loại khỏi kết quả "gần tôi"
            // thay vì đẩy xuống cuối, vì khách bật bán kính là đang hỏi "có gì trong 20km",
            // một điểm không biết ở đâu không phải câu trả lời.
            if (banKinhKm != null && lat != null && lng != null) {
                if (khoangCach == null || khoangCach > banKinhKm) continue;
            }
            ketQua.add(toTrungTamDto(c, khoangCach));
        }

        if (lat != null && lng != null) {
            ketQua.sort(Comparator.comparing(
                    TrungTamDto::khoangCachKm, Comparator.nullsLast(Comparator.naturalOrder())));
        }
        return ketQua;
    }

    public TrungTamDto chiTietTrungTam(Integer id) {
        ServiceCenter c = centerRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy trung tâm bảo hành"));
        return toTrungTamDto(c, null);
    }

    private boolean nhanDichVu(ServiceCenter c, String dichVu) {
        if (c.getDichVu() == null || c.getDichVu().isBlank()) return false;
        for (String ma : c.getDichVu().split(",")) {
            if (ma.trim().equalsIgnoreCase(dichVu.trim())) return true;
        }
        return false;
    }

    private Double tinhKhoangCach(ServiceCenter c, Double lat, Double lng) {
        if (lat == null || lng == null || c.getLat() == null || c.getLng() == null) return null;
        return haversineKm(lat, lng, c.getLat().doubleValue(), c.getLng().doubleValue());
    }

    /** Khoảng cách đường chim bay. Đủ dùng để SẮP XẾP điểm gần nhất — không phải quãng đường
     * lái xe thật, nên FE phải ghi rõ là "khoảng cách theo đường chim bay". */
    private static double haversineKm(double lat1, double lng1, double lat2, double lng2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return BAN_KINH_TRAI_DAT_KM * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    private TrungTamDto toTrungTamDto(ServiceCenter c, Double khoangCachKm) {
        List<String> dv = new ArrayList<>();
        if (c.getDichVu() != null) {
            for (String ma : c.getDichVu().split(",")) {
                if (!ma.isBlank()) dv.add(ma.trim());
            }
        }
        return new TrungTamDto(
                c.getId(), c.getTen(), c.getDiaChi(),
                c.getProvince() != null ? c.getProvince().getId() : null,
                c.getProvince() != null ? c.getProvince().getName() : null,
                c.getLat(), c.getLng(),
                c.getDienThoai(), c.getEmail(), c.getGioMoCua(),
                dv, c.getLoai(), c.isNhanDatLich(), c.getGhiChu(),
                c.isHienThi(), c.getSortOrder(),
                khoangCachKm != null ? Math.round(khoangCachKm * 10) / 10.0 : null);
    }

    // ============================================================
    //  2. Thông tin bảo hành
    // ============================================================

    public List<ChinhSachBaoHanhDto> chinhSachBaoHanh() {
        return policyRepo.findByHienThiTrueOrderBySortOrderAsc().stream()
                .map(this::toChinhSachDto)
                .toList();
    }

    private ChinhSachBaoHanhDto toChinhSachDto(WarrantyPolicy p) {
        return new ChinhSachBaoHanhDto(p.getId(), p.getNhomHang(), p.getSoThang(), p.getMoTa(),
                p.getTinhTu(), p.isHienThi(), p.getSortOrder());
    }

    /** Tra cứu bảo hành theo MÃ BẢO HÀNH (BHCNTT****) hoặc serial, KHÔNG cần đăng nhập.
     *
     * Cố ý không trả về họ tên / email / mã đơn của người mua: mã bảo hành và serial đều nằm
     * trên tem/giấy bảo hành nên ai cầm máy cũng tra được. Trả thêm thông tin định danh sẽ biến
     * trang tra cứu thành công cụ dò dữ liệu khách hàng. Khách cần chi tiết đầy đủ thì đăng nhập
     * vào Quản lý bảo hành cá nhân. */
    public TraCuuBaoHanhDto traCuuTheoSerial(String serial) {
        String s = serial == null ? "" : serial.trim();
        if (s.length() < 4) {
            return new TraCuuBaoHanhDto(false, null, s, null, null, null, null, null,
                    "Mã bảo hành / serial phải có ít nhất 4 ký tự.");
        }

        List<Warranty> khop = warrantyRepo.findByMaBaoHanhOrSerial(s);
        Optional<Warranty> tim = khop.isEmpty() ? Optional.empty() : Optional.of(khop.get(0));

        if (tim.isEmpty()) {
            return new TraCuuBaoHanhDto(false, null, s, null, null, null, null, null,
                    "Không tìm thấy phiếu bảo hành nào khớp mã hoặc serial này. "
                    + "Kiểm tra lại (mã có dạng BHCNTT****), hoặc liên hệ hotline 0835 344 974 để được tra thủ công.");
        }

        Warranty w = tim.get();
        LocalDate homNay = LocalDate.now();
        boolean conHan = w.getEndDate() != null && !homNay.isAfter(w.getEndDate());
        Integer soNgayConLai = w.getEndDate() != null
                ? (int) ChronoUnit.DAYS.between(homNay, w.getEndDate())
                : null;

        String trangThai;
        String thongBao;
        if ("void".equalsIgnoreCase(w.getStatus())) {
            trangThai = "void";
            thongBao = "Phiếu bảo hành đã bị vô hiệu. Liên hệ hotline để biết lý do cụ thể.";
        } else if (conHan) {
            trangThai = "active";
            thongBao = "Máy còn trong thời hạn bảo hành. Mang máy kèm hoá đơn tới trung tâm gần nhất, "
                    + "hoặc đặt lịch trước để không phải chờ.";
        } else {
            trangThai = "expired";
            thongBao = "Máy đã hết thời hạn bảo hành. Bạn vẫn có thể sửa dịch vụ theo bảng giá công khai.";
        }

        String tenSanPham = w.getOrderItem() != null ? w.getOrderItem().getTenSanPham() : null;
        return new TraCuuBaoHanhDto(true, w.getMaBaoHanh(), s, tenSanPham,
                w.getStartDate(), w.getEndDate(), trangThai,
                soNgayConLai != null && soNgayConLai > 0 ? soNgayConLai : 0,
                thongBao);
    }

    // ============================================================
    //  3. Bảng giá sửa chữa
    // ============================================================

    public List<GiaSuaChuaDto> bangGia(String loaiThietBi) {
        List<RepairPrice> rows = (loaiThietBi == null || loaiThietBi.isBlank())
                ? repairRepo.findByHienThiTrueOrderBySortOrderAsc()
                : repairRepo.findByHienThiTrueAndLoaiThietBiOrderBySortOrderAsc(loaiThietBi);
        return rows.stream().map(this::toGiaDto).toList();
    }

    /** Ước tính chi phí cho tối đa 2 hạng mục khách chọn.
     *
     * Cộng dồn thẳng thay vì gộp công thợ: gộp công cần biết kỹ thuật có tháo cùng một cụm hay
     * không, thứ chỉ xác định được khi cầm máy. Cộng thẳng luôn ra con số CAO HƠN hoặc bằng
     * thực tế — sai theo hướng an toàn cho khách, không phải hướng phát sinh thêm tiền. */
    public UocTinhDto uocTinh(List<Integer> hangMucIds) {
        if (hangMucIds == null || hangMucIds.isEmpty()) {
            throw new RuntimeException("Chọn ít nhất một hạng mục cần sửa.");
        }
        if (hangMucIds.size() > SO_HANG_MUC_TOI_DA) {
            throw new RuntimeException("Chỉ chọn được tối đa " + SO_HANG_MUC_TOI_DA + " hạng mục một lần.");
        }

        List<GiaSuaChuaDto> hangMuc = new ArrayList<>();
        BigDecimal tongTu = BigDecimal.ZERO;
        BigDecimal tongDen = BigDecimal.ZERO;
        String thoiGian = null;

        for (Integer id : hangMucIds) {
            RepairPrice r = repairRepo.findById(id)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy hạng mục sửa chữa #" + id));
            if (!r.isHienThi()) {
                throw new RuntimeException("Hạng mục \"" + r.getTenLoi() + "\" tạm ngừng nhận.");
            }
            GiaSuaChuaDto dto = toGiaDto(r);
            hangMuc.add(dto);
            tongTu = tongTu.add(dto.giaTu());
            // Hạng mục báo một con số thì cận trên chính là con số đó, nếu không cận trên sẽ
            // nhỏ hơn cận dưới khi trộn hai loại hạng mục với nhau.
            tongDen = tongDen.add(dto.giaDen() != null ? dto.giaDen() : dto.giaTu());
            if (thoiGian == null) thoiGian = r.getThoiGianDuKien();
        }

        return new UocTinhDto(hangMuc, tongTu, tongDen, thoiGian);
    }

    private GiaSuaChuaDto toGiaDto(RepairPrice r) {
        return new GiaSuaChuaDto(
                r.getId(), r.getLoaiThietBi(), r.getHang(), r.getDongMay(),
                r.getMaLoi(), r.getTenLoi(),
                r.getGiaLinhKien(), r.getTienCong(), r.getGiaTu(), r.getGiaDen(),
                r.getThoiGianDuKien(), r.getBaoHanhThang(), r.getGhiChu(),
                r.isHienThi(), r.getSortOrder());
    }

    // ============================================================
    //  4. FAQ
    // ============================================================

    /** FAQ nhóm theo danh mục. tuKhoa rỗng = trả về toàn bộ; có từ khoá thì lọc BỎ DẤU trên cả
     * câu hỏi, câu trả lời và trường từ khoá phụ, rồi loại danh mục không còn câu nào. */
    public List<FaqDanhMucDto> faq(String tuKhoa) {
        String khoa = boDau(tuKhoa);
        Map<Integer, List<FaqItemDto>> theoDanhMuc = new LinkedHashMap<>();

        for (FaqItem i : faqItemRepo.findPublic()) {
            if (!khoa.isBlank() && !khopTuKhoa(i, khoa)) continue;
            theoDanhMuc.computeIfAbsent(i.getCategory().getId(), k -> new ArrayList<>()).add(toFaqItemDto(i));
        }

        List<FaqDanhMucDto> ketQua = new ArrayList<>();
        for (FaqCategory c : faqCategoryRepo.findByHienThiTrueOrderBySortOrderAsc()) {
            List<FaqItemDto> items = theoDanhMuc.get(c.getId());
            if (items == null || items.isEmpty()) continue;
            ketQua.add(new FaqDanhMucDto(c.getId(), c.getMa(), c.getTen(), c.getMoTa(), c.getIcon(), items));
        }
        return ketQua;
    }

    private boolean khopTuKhoa(FaqItem i, String khoa) {
        String noiDung = boDau(i.getCauHoi() + " " + i.getTraLoi() + " "
                + (i.getTuKhoa() != null ? i.getTuKhoa() : "") + " " + i.getCategory().getTen());
        return noiDung.contains(khoa);
    }

    @Transactional
    public void ghiNhanLuotXemFaq(Integer id) {
        faqItemRepo.tangLuotXem(id);
    }

    private FaqItemDto toFaqItemDto(FaqItem i) {
        return new FaqItemDto(
                i.getId(), i.getCategory().getId(), i.getCategory().getMa(), i.getCategory().getTen(),
                i.getCauHoi(), i.getTraLoi(), i.getTuKhoa(), i.isNoiBat(), i.getLuotXem(),
                i.isHienThi(), i.getSortOrder());
    }

    // ============================================================
    //  5. Trang chủ hỗ trợ
    // ============================================================

    public TongQuanHoTroDto tongQuan() {
        List<ServiceCenter> centers = centerRepo.findPublic();
        long soTinh = centers.stream()
                .filter(c -> c.getProvince() != null)
                .map(c -> c.getProvince().getId())
                .distinct().count();

        List<TrungTamDto> noiBat = centers.stream().limit(3).map(c -> toTrungTamDto(c, null)).toList();
        List<FaqItemDto> cauHoiNoiBat = faqItemRepo.findNoiBat().stream().limit(6).map(this::toFaqItemDto).toList();

        return new TongQuanHoTroDto(
                centers.size(), (int) soTinh,
                faqItemRepo.findPublic().size(),
                repairRepo.findByHienThiTrueOrderBySortOrderAsc().size(),
                cauHoiNoiBat, noiBat);
    }

    // ============================================================
    //  Tiện ích
    // ============================================================

    /** Bỏ dấu tiếng Việt + hạ chữ thường, để "hai phong" tìm được "Hải Phòng" và "bao hanh"
     * tìm được "bảo hành". Khách gõ tìm kiếm hiếm khi bỏ công gõ đủ dấu. */
    static String boDau(String s) {
        if (s == null) return "";
        String n = Normalizer.normalize(s, Normalizer.Form.NFD)
                .replaceAll("\\p{InCombiningDiacriticalMarks}+", "")
                .replace('đ', 'd').replace('Đ', 'D');
        return n.toLowerCase(Locale.ROOT).trim();
    }
}
