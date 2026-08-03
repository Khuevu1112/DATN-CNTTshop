package com.fpoly.service;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.SupportDtos.ChinhSachBaoHanhDto;
import com.fpoly.dto.SupportDtos.FaqItemDto;
import com.fpoly.dto.SupportDtos.GiaSuaChuaDto;
import com.fpoly.dto.SupportDtos.LuuChinhSachRequest;
import com.fpoly.dto.SupportDtos.LuuFaqRequest;
import com.fpoly.dto.SupportDtos.LuuGiaSuaChuaRequest;
import com.fpoly.dto.SupportDtos.LuuTrungTamRequest;
import com.fpoly.dto.SupportDtos.TrungTamDto;
import com.fpoly.model.FaqCategory;
import com.fpoly.model.FaqItem;
import com.fpoly.model.RepairPrice;
import com.fpoly.model.ServiceCenter;
import com.fpoly.model.WarrantyPolicy;
import com.fpoly.repository.FaqCategoryRepository;
import com.fpoly.repository.FaqItemRepository;
import com.fpoly.repository.ProvinceRepository;
import com.fpoly.repository.RepairPriceRepository;
import com.fpoly.repository.ServiceAppointmentRepository;
import com.fpoly.repository.ServiceCenterRepository;
import com.fpoly.repository.WardRepository;
import com.fpoly.repository.WarrantyPolicyRepository;

/** Biên tập nội dung Trung tâm hỗ trợ phía nhân viên: trung tâm bảo hành, bảng giá sửa chữa,
 * chính sách bảo hành, FAQ. Tách khỏi SupportService (chỉ đọc, công khai) để phần ghi luôn đi
 * qua @RequirePermission ở controller và không lẫn vào đường công khai. */
@Service
public class AdminSupportService {

    @Autowired private ServiceCenterRepository centerRepo;
    @Autowired private ServiceAppointmentRepository appointmentRepo;
    @Autowired private RepairPriceRepository repairRepo;
    @Autowired private WarrantyPolicyRepository policyRepo;
    @Autowired private FaqCategoryRepository faqCategoryRepo;
    @Autowired private FaqItemRepository faqItemRepo;
    @Autowired private ProvinceRepository provinceRepo;
    @Autowired private WardRepository wardRepo;

    // ============================================================
    //  Trung tâm bảo hành
    // ============================================================

    public List<TrungTamDto> danhSachTrungTam() {
        return centerRepo.findAllForAdmin().stream().map(this::toTrungTamDto).toList();
    }

    @Transactional
    public TrungTamDto taoTrungTam(LuuTrungTamRequest req) {
        ServiceCenter c = new ServiceCenter();
        apDung(c, req);
        centerRepo.save(c);
        return toTrungTamDto(c);
    }

    @Transactional
    public TrungTamDto suaTrungTam(Integer id, LuuTrungTamRequest req) {
        ServiceCenter c = centerRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy trung tâm bảo hành"));
        apDung(c, req);
        centerRepo.save(c);
        return toTrungTamDto(c);
    }

    /** Xoá mềm bằng cách tắt hiển thị khi trung tâm đã có lịch hẹn: xoá cứng sẽ làm mọi lịch hẹn
     * cũ mất điểm tiếp nhận, kể cả lịch đã hoàn thành — dữ liệu lịch sử không được biến mất chỉ
     * vì shop đóng một chi nhánh. */
    @Transactional
    public void xoaTrungTam(Integer id) {
        ServiceCenter c = centerRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy trung tâm bảo hành"));
        if (appointmentRepo.existsByCenterId(id)) {
            c.setHienThi(false);
            c.setNhanDatLich(false);
            centerRepo.save(c);
            return;
        }
        centerRepo.delete(c);
    }

    private void apDung(ServiceCenter c, LuuTrungTamRequest req) {
        if (req.ten() == null || req.ten().isBlank()) throw new RuntimeException("Nhập tên trung tâm.");
        if (req.diaChi() == null || req.diaChi().isBlank()) throw new RuntimeException("Nhập địa chỉ.");

        c.setTen(req.ten().trim());
        c.setDiaChi(req.diaChi().trim());
        c.setProvince(req.provinceId() != null ? provinceRepo.findById(req.provinceId()).orElse(null) : null);
        c.setWard(req.wardId() != null ? wardRepo.findById(req.wardId()).orElse(null) : null);
        c.setLat(req.lat());
        c.setLng(req.lng());
        c.setDienThoai(req.dienThoai());
        c.setEmail(req.email());
        c.setGioMoCua(req.gioMoCua());
        c.setDichVu(req.dichVu() != null ? String.join(",", req.dichVu()) : null);
        c.setLoai(req.loai() != null ? req.loai() : "chi_nhanh");
        c.setNhanDatLich(req.nhanDatLich() == null || req.nhanDatLich());
        c.setGhiChu(req.ghiChu());
        c.setHienThi(req.hienThi() == null || req.hienThi());
        c.setSortOrder(req.sortOrder() != null ? req.sortOrder() : 100);
    }

    private TrungTamDto toTrungTamDto(ServiceCenter c) {
        List<String> dv = c.getDichVu() == null || c.getDichVu().isBlank()
                ? List.of()
                : List.of(c.getDichVu().split(",")).stream().map(String::trim).toList();
        return new TrungTamDto(
                c.getId(), c.getTen(), c.getDiaChi(),
                c.getProvince() != null ? c.getProvince().getId() : null,
                c.getProvince() != null ? c.getProvince().getName() : null,
                c.getLat(), c.getLng(),
                c.getDienThoai(), c.getEmail(), c.getGioMoCua(),
                dv, c.getLoai(), c.isNhanDatLich(), c.getGhiChu(),
                c.isHienThi(), c.getSortOrder(), null);
    }

    // ============================================================
    //  Bảng giá sửa chữa
    // ============================================================

    public List<GiaSuaChuaDto> danhSachGia() {
        return repairRepo.findAllByOrderByLoaiThietBiAscSortOrderAsc().stream().map(this::toGiaDto).toList();
    }

    @Transactional
    public GiaSuaChuaDto taoGia(LuuGiaSuaChuaRequest req) {
        RepairPrice r = new RepairPrice();
        apDung(r, req);
        repairRepo.save(r);
        return toGiaDto(r);
    }

    @Transactional
    public GiaSuaChuaDto suaGia(Integer id, LuuGiaSuaChuaRequest req) {
        RepairPrice r = repairRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy hạng mục sửa chữa"));
        apDung(r, req);
        repairRepo.save(r);
        return toGiaDto(r);
    }

    @Transactional
    public void xoaGia(Integer id) {
        repairRepo.deleteById(id);
    }

    private void apDung(RepairPrice r, LuuGiaSuaChuaRequest req) {
        if (req.loaiThietBi() == null || req.loaiThietBi().isBlank())
            throw new RuntimeException("Chọn loại thiết bị.");
        if (req.tenLoi() == null || req.tenLoi().isBlank())
            throw new RuntimeException("Nhập tên hạng mục sửa chữa.");

        BigDecimal lk = req.giaLinhKien() != null ? req.giaLinhKien() : BigDecimal.ZERO;
        BigDecimal tc = req.tienCong() != null ? req.tienCong() : BigDecimal.ZERO;
        if (lk.signum() < 0 || tc.signum() < 0) throw new RuntimeException("Giá không được âm.");
        // Cận trên nhỏ hơn cận dưới sẽ hiện ra khách thành khoảng giá ngược ("5tr – 2tr").
        if (req.giaDen() != null && req.giaDen().compareTo(lk.add(tc)) < 0) {
            throw new RuntimeException("Giá đến phải lớn hơn hoặc bằng tổng giá linh kiện + tiền công.");
        }

        r.setLoaiThietBi(req.loaiThietBi());
        r.setHang(req.hang());
        r.setDongMay(req.dongMay());
        r.setMaLoi(req.maLoi() != null && !req.maLoi().isBlank()
                ? req.maLoi() : SupportService.boDau(req.tenLoi()).replaceAll("[^a-z0-9]+", "_"));
        r.setTenLoi(req.tenLoi().trim());
        r.setGiaLinhKien(lk);
        r.setTienCong(tc);
        r.setGiaDen(req.giaDen());
        r.setThoiGianDuKien(req.thoiGianDuKien());
        r.setBaoHanhThang(req.baoHanhThang() != null ? req.baoHanhThang() : 3);
        r.setGhiChu(req.ghiChu());
        r.setHienThi(req.hienThi() == null || req.hienThi());
        r.setSortOrder(req.sortOrder() != null ? req.sortOrder() : 100);
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
    //  Chính sách bảo hành
    // ============================================================

    public List<ChinhSachBaoHanhDto> danhSachChinhSach() {
        return policyRepo.findAllByOrderBySortOrderAsc().stream()
                .map(p -> new ChinhSachBaoHanhDto(p.getId(), p.getNhomHang(), p.getSoThang(),
                        p.getMoTa(), p.getTinhTu(), p.isHienThi(), p.getSortOrder()))
                .toList();
    }

    @Transactional
    public ChinhSachBaoHanhDto taoChinhSach(LuuChinhSachRequest req) {
        WarrantyPolicy p = new WarrantyPolicy();
        apDung(p, req);
        policyRepo.save(p);
        return new ChinhSachBaoHanhDto(p.getId(), p.getNhomHang(), p.getSoThang(), p.getMoTa(),
                p.getTinhTu(), p.isHienThi(), p.getSortOrder());
    }

    @Transactional
    public ChinhSachBaoHanhDto suaChinhSach(Integer id, LuuChinhSachRequest req) {
        WarrantyPolicy p = policyRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy chính sách bảo hành"));
        apDung(p, req);
        policyRepo.save(p);
        return new ChinhSachBaoHanhDto(p.getId(), p.getNhomHang(), p.getSoThang(), p.getMoTa(),
                p.getTinhTu(), p.isHienThi(), p.getSortOrder());
    }

    @Transactional
    public void xoaChinhSach(Integer id) {
        policyRepo.deleteById(id);
    }

    private void apDung(WarrantyPolicy p, LuuChinhSachRequest req) {
        if (req.nhomHang() == null || req.nhomHang().isBlank())
            throw new RuntimeException("Nhập tên nhóm hàng.");
        if (req.soThang() == null || req.soThang() < 0)
            throw new RuntimeException("Số tháng bảo hành không hợp lệ.");
        p.setNhomHang(req.nhomHang().trim());
        p.setSoThang(req.soThang());
        p.setMoTa(req.moTa());
        p.setTinhTu(req.tinhTu() != null && !req.tinhTu().isBlank() ? req.tinhTu() : "Ngày xuất hoá đơn");
        p.setHienThi(req.hienThi() == null || req.hienThi());
        p.setSortOrder(req.sortOrder() != null ? req.sortOrder() : 100);
    }

    // ============================================================
    //  FAQ
    // ============================================================

    public List<FaqItemDto> danhSachFaq() {
        return faqItemRepo.findAllForAdmin().stream()
                .map(i -> new FaqItemDto(i.getId(), i.getCategory().getId(), i.getCategory().getMa(),
                        i.getCategory().getTen(), i.getCauHoi(), i.getTraLoi(), i.getTuKhoa(),
                        i.isNoiBat(), i.getLuotXem(), i.isHienThi(), i.getSortOrder()))
                .toList();
    }

    public List<FaqCategory> danhSachDanhMucFaq() {
        return faqCategoryRepo.findAllByOrderBySortOrderAsc();
    }

    @Transactional
    public FaqItemDto taoFaq(LuuFaqRequest req) {
        FaqItem i = new FaqItem();
        apDung(i, req);
        faqItemRepo.save(i);
        return new FaqItemDto(i.getId(), i.getCategory().getId(), i.getCategory().getMa(),
                i.getCategory().getTen(), i.getCauHoi(), i.getTraLoi(), i.getTuKhoa(),
                i.isNoiBat(), i.getLuotXem(), i.isHienThi(), i.getSortOrder());
    }

    @Transactional
    public FaqItemDto suaFaq(Integer id, LuuFaqRequest req) {
        FaqItem i = faqItemRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy câu hỏi"));
        apDung(i, req);
        faqItemRepo.save(i);
        return new FaqItemDto(i.getId(), i.getCategory().getId(), i.getCategory().getMa(),
                i.getCategory().getTen(), i.getCauHoi(), i.getTraLoi(), i.getTuKhoa(),
                i.isNoiBat(), i.getLuotXem(), i.isHienThi(), i.getSortOrder());
    }

    @Transactional
    public void xoaFaq(Integer id) {
        faqItemRepo.deleteById(id);
    }

    private void apDung(FaqItem i, LuuFaqRequest req) {
        if (req.categoryId() == null) throw new RuntimeException("Chọn danh mục.");
        if (req.cauHoi() == null || req.cauHoi().isBlank()) throw new RuntimeException("Nhập câu hỏi.");
        if (req.traLoi() == null || req.traLoi().isBlank()) throw new RuntimeException("Nhập câu trả lời.");

        FaqCategory c = faqCategoryRepo.findById(req.categoryId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy danh mục FAQ"));
        i.setCategory(c);
        i.setCauHoi(req.cauHoi().trim());
        i.setTraLoi(req.traLoi().trim());
        i.setTuKhoa(req.tuKhoa());
        i.setNoiBat(req.noiBat() != null && req.noiBat());
        i.setHienThi(req.hienThi() == null || req.hienThi());
        i.setSortOrder(req.sortOrder() != null ? req.sortOrder() : 100);
    }
}
