package com.fpoly.model;

import jakarta.persistence.*;

@Entity
@Table(name = "PC_BUILD_ITEM")
public class PcBuildItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "build_id", nullable = false)
    private PcBuild pcBuild;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "variant_id", nullable = false)
    private ProductVariant productVariant;

    @Column(name = "component_type", nullable = false)
    private String loaiLinhKien;

    @Column(name = "quantity", nullable = false)
    private Integer soLuong = 1;

    /** Loại linh kiện — khớp với slug danh mục con trong CATEGORY (xem PcBuildService). */
    public enum LoaiLinhKien {
        CPU("Vi xử lý (CPU)", "bi-cpu"),
        MAINBOARD("Bo mạch chủ", "bi-motherboard"),
        RAM("Bộ nhớ RAM", "bi-memory"),
        GPU("Card đồ họa (GPU)", "bi-gpu-card"),
        SSD("Ổ cứng SSD", "bi-device-ssd"),
        HDD("Ổ cứng HDD", "bi-hdd"),
        PSU("Nguồn (PSU)", "bi-lightning-charge"),
        CASE("Vỏ máy tính", "bi-pc-display"),
        CPU_COOLER("Tản nhiệt CPU", "bi-wind"),
        MONITOR("Màn hình", "bi-display");

        private final String tenHienThi;
        private final String icon;

        LoaiLinhKien(String tenHienThi, String icon) {
            this.tenHienThi = tenHienThi;
            this.icon = icon;
        }

        public String getTenHienThi() { return tenHienThi; }
        public String getIcon() { return icon; }
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public PcBuild getPcBuild() { return pcBuild; }
    public void setPcBuild(PcBuild pcBuild) { this.pcBuild = pcBuild; }

    public ProductVariant getProductVariant() { return productVariant; }
    public void setProductVariant(ProductVariant productVariant) { this.productVariant = productVariant; }

    public String getLoaiLinhKien() { return loaiLinhKien; }
    public void setLoaiLinhKien(String loaiLinhKien) { this.loaiLinhKien = loaiLinhKien; }

    public Integer getSoLuong() { return soLuong; }
    public void setSoLuong(Integer soLuong) { this.soLuong = soLuong; }

    public String getTenLoai() {
        try {
            return LoaiLinhKien.valueOf(loaiLinhKien).getTenHienThi();
        } catch (Exception e) {
            return loaiLinhKien;
        }
    }

    public String getIconLoai() {
        try {
            return LoaiLinhKien.valueOf(loaiLinhKien).getIcon();
        } catch (Exception e) {
            return "bi-box";
        }
    }
}
