package com.fpoly.service;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.PcBuild;
import com.fpoly.model.PcBuildItem;
import com.fpoly.model.PcBuildItem.LoaiLinhKien;
import com.fpoly.model.Product;
import com.fpoly.model.ProductVariant;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.PcBuildItemRepository;
import com.fpoly.repository.PcBuildRepository;
import com.fpoly.repository.ProductRepository;
import com.fpoly.repository.ProductVariantRepository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

@Service
public class PcBuildService {

    @Autowired private PcBuildRepository pcBuildRepo;
    @Autowired private PcBuildItemRepository pcBuildItemRepo;
    @Autowired private NguoiDungRepository nguoiDungRepo;
    @Autowired private ProductVariantRepository variantRepo;
    @Autowired private ProductRepository productRepo;

    @PersistenceContext
    private EntityManager entityManager;

    private static final Map<String, String> LOAI_TO_SLUG = Map.ofEntries(
            Map.entry("CPU", "cpu"),
            Map.entry("MAINBOARD", "mainboard"),
            Map.entry("RAM", "ram"),
            Map.entry("GPU", "gpu"),
            Map.entry("SSD", "ssd"),
            Map.entry("HDD", "hdd"),
            Map.entry("PSU", "psu"),
            Map.entry("CASE", "case-may-tinh"),
            Map.entry("CPU_COOLER", "tan-nhiet-cpu"),
            Map.entry("MONITOR", "man-hinh")
    );

    public List<LoaiLinhKien> layDanhSachLoaiLinhKien() {
        return Arrays.asList(LoaiLinhKien.values());
    }

    public Page<Product> timSanPhamTheoLoai(String loaiLinhKien, String keyword, Pageable pageable) {
        String slug = LOAI_TO_SLUG.getOrDefault(loaiLinhKien, "linh-kien");
        if (keyword != null && !keyword.isBlank()) {
            return productRepo.findByCategorySlugAndNameContainingIgnoreCaseAndIsActiveTrue(slug, keyword, pageable);
        }
        return productRepo.findByCategorySlugAndIsActiveTrue(slug, pageable);
    }

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

    @Transactional
    public PcBuild themLinhKien(Integer buildId, String email, Integer variantId, String loaiLinhKien) {
        PcBuild build = layBuildTheoId(buildId, email);

        ProductVariant variant = variantRepo.findById(variantId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));

        pcBuildItemRepo.deleteByBuildIdAndLoai(buildId, loaiLinhKien);
        entityManager.flush();
        entityManager.clear();

        PcBuild buildMoi = pcBuildRepo.findById(buildId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy cấu hình"));

        PcBuildItem item = new PcBuildItem();
        item.setPcBuild(buildMoi);
        item.setProductVariant(variant);
        item.setLoaiLinhKien(loaiLinhKien);
        item.setSoLuong(1);
        pcBuildItemRepo.save(item);

        entityManager.flush();
        entityManager.clear();

        return pcBuildRepo.findByIdWithItems(buildId).orElse(buildMoi);
    }

    @Transactional
    public PcBuild xoaLinhKien(Integer buildId, String email, String loaiLinhKien) {
        layBuildTheoId(buildId, email);
        pcBuildItemRepo.deleteByBuildIdAndLoai(buildId, loaiLinhKien);
        entityManager.flush();
        entityManager.clear();
        return pcBuildRepo.findByIdWithItems(buildId).orElseThrow();
    }

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

    @Transactional
    public void themToanBoCauHinhVaoGio(Integer buildId, String email, CartService cartService) {
        PcBuild build = layBuildTheoId(buildId, email);
        if (build.getItems().isEmpty()) {
            throw new RuntimeException("Cấu hình chưa có linh kiện nào");
        }
        for (PcBuildItem item : build.getItems()) {
            try {
                cartService.themVaoGio(email, item.getProductVariant().getId(), item.getSoLuong());
            } catch (Exception ignored) {
                // Bỏ qua linh kiện hết hàng, các linh kiện khác vẫn được thêm
            }
        }
    }

    public List<String> kiemTraTuongThich(PcBuild build) {
        List<String> canhBao = new java.util.ArrayList<>();
        List<String> slotsDaCo = build.getItems().stream()
                .map(PcBuildItem::getLoaiLinhKien)
                .collect(Collectors.toList());

        if (!slotsDaCo.contains("CPU")) canhBao.add("Chưa chọn CPU");
        if (!slotsDaCo.contains("MAINBOARD")) canhBao.add("Chưa chọn Bo mạch chủ");
        if (!slotsDaCo.contains("RAM")) canhBao.add("Chưa chọn RAM");
        if (!slotsDaCo.contains("PSU")) canhBao.add("Chưa chọn Nguồn (PSU)");
        if (!slotsDaCo.contains("SSD") && !slotsDaCo.contains("HDD")) canhBao.add("Chưa chọn ổ cứng (SSD hoặc HDD)");

        return canhBao;
    }

    private NguoiDung layUser(String email) {
        return nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
    }
}
