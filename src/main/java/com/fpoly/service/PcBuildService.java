package com.fpoly.service;

import com.fpoly.model.*;
import com.fpoly.model.PcBuildItem.LoaiLinhKien;
import com.fpoly.repository.*;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class PcBuildService {

    @Autowired
    private PcBuildRepository pcBuildRepo;

    @Autowired
    private PcBuildItemRepository pcBuildItemRepo;

    @Autowired
    private NguoiDungRepository nguoiDungRepo;

    @Autowired
    private ProductVariantRepository variantRepo;

    // Dùng để flush + clear cache sau @Modifying query
    @PersistenceContext
    private EntityManager entityManager;

    // =========================================================
    //  LẤY / TẠO BUILD
    // =========================================================

    @Transactional
    public PcBuild layHoacTaoBuildNhap(String email) {
        NguoiDung user = layUser(email);
        PcBuild build = new PcBuild();
        build.setNguoiDung(user);
        build.setTenCauHinh("Cấu hình của tôi");
        return pcBuildRepo.save(build);
    }

    public PcBuild layBuildTheoId(Integer buildId, String email) {
        NguoiDung user = layUser(email);
        PcBuild build = pcBuildRepo.findByIdWithItems(buildId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy cấu hình"));
        if (!build.getNguoiDung().getId().equals(user.getId())) {
            throw new RuntimeException("Bạn không có quyền xem cấu hình này");
        }
        return build;
    }

    public List<PcBuild> layDanhSachBuild(String email) {
        NguoiDung user = layUser(email);
        return pcBuildRepo.findByNguoiDungOrderByCreatedAtDesc(user);
    }

    // =========================================================
    //  THÊM / XÓA LINH KIỆN
    // =========================================================

    @Transactional
    public PcBuild themLinhKien(Integer buildId, String email, Integer variantId, String loaiLinhKien) {
        NguoiDung user = layUser(email);
        PcBuild build = pcBuildRepo.findByIdWithItems(buildId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy cấu hình"));
        if (!build.getNguoiDung().getId().equals(user.getId())) {
            throw new RuntimeException("Không có quyền chỉnh sửa cấu hình này");
        }

        ProductVariant variant = variantRepo.findById(variantId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));

        // Xóa slot cũ nếu đã có
        pcBuildItemRepo.deleteByBuildIdAndLoai(buildId, loaiLinhKien);

        // Flush + clear để Hibernate không dùng cache cũ
        entityManager.flush();
        entityManager.clear();

        // Thêm linh kiện mới
        PcBuildItem item = new PcBuildItem();
        // Load lại build sau clear
        PcBuild buildMoi = pcBuildRepo.findById(buildId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy cấu hình"));
        item.setPcBuild(buildMoi);
        item.setProductVariant(variant);
        item.setLoaiLinhKien(loaiLinhKien);
        item.setSoLuong(1);
        pcBuildItemRepo.save(item);

        // Flush lần nữa để đảm bảo insert trước khi reload
        entityManager.flush();
        entityManager.clear();

        return pcBuildRepo.findByIdWithItems(buildId).orElse(buildMoi);
    }

    @Transactional
    public PcBuild xoaLinhKien(Integer buildId, String email, String loaiLinhKien) {
        NguoiDung user = layUser(email);
        PcBuild build = pcBuildRepo.findByIdWithItems(buildId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy cấu hình"));
        if (!build.getNguoiDung().getId().equals(user.getId())) {
            throw new RuntimeException("Không có quyền chỉnh sửa cấu hình này");
        }

        pcBuildItemRepo.deleteByBuildIdAndLoai(buildId, loaiLinhKien);
        entityManager.flush();
        entityManager.clear();

        return pcBuildRepo.findByIdWithItems(buildId).orElse(build);
    }

    // =========================================================
    //  LƯU / XÓA BUILD
    // =========================================================

    @Transactional
    public PcBuild luuCauHinh(Integer buildId, String email, String tenCauHinh, String ghiChu) {
        PcBuild build = layBuildTheoId(buildId, email);
        build.setTenCauHinh(tenCauHinh != null && !tenCauHinh.isBlank() ? tenCauHinh : "Cấu hình của tôi");
        build.setGhiChu(ghiChu);
        return pcBuildRepo.save(build);
    }

    @Transactional
    public void xoaBuild(Integer buildId, String email) {
        PcBuild build = layBuildTheoId(buildId, email);
        pcBuildRepo.delete(build);
    }

    // =========================================================
    //  THÊM VÀO GIỎ HÀNG
    // =========================================================

    @Transactional
    public void themToanBoCauHinhVaoGio(Integer buildId, String email, CartService cartService) {
        PcBuild build = layBuildTheoId(buildId, email);
        if (build.getItems().isEmpty()) {
            throw new RuntimeException("Cấu hình chưa có linh kiện nào");
        }
        for (PcBuildItem item : build.getItems()) {
            try {
                cartService.themVaoGio(email, item.getProductVariant().getId(), item.getSoLuong());
            } catch (Exception e) {
                // Bỏ qua nếu sản phẩm hết hàng
            }
        }
    }

    // =========================================================
    //  DANH SÁCH LOẠI LINH KIỆN
    // =========================================================

    public List<LoaiLinhKien> layDanhSachLoaiLinhKien() {
        return Arrays.asList(LoaiLinhKien.values());
    }

    // =========================================================
    //  KIỂM TRA TƯƠNG THÍCH
    // =========================================================

    public List<String> kiemTraTuongThich(PcBuild build) {
        List<String> canhBao = new java.util.ArrayList<>();
        List<String> slotsDaCo = build.getItems().stream()
                .map(PcBuildItem::getLoaiLinhKien)
                .collect(Collectors.toList());

        if (!slotsDaCo.contains("CPU"))       canhBao.add("Chưa chọn CPU");
        if (!slotsDaCo.contains("MAINBOARD")) canhBao.add("Chưa chọn Bo mạch chủ");
        if (!slotsDaCo.contains("RAM"))       canhBao.add("Chưa chọn RAM");
        if (!slotsDaCo.contains("PSU"))       canhBao.add("Chưa chọn Nguồn (PSU)");
        if (!slotsDaCo.contains("SSD") && !slotsDaCo.contains("HDD"))
            canhBao.add("Chưa chọn ổ cứng (SSD hoặc HDD)");

        return canhBao;
    }

    // =========================================================
    //  HELPER
    // =========================================================

    private NguoiDung layUser(String email) {
        return nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
    }
}