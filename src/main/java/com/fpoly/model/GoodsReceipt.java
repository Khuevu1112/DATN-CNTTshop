package com.fpoly.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import jakarta.persistence.*;

/**
 * PHIẾU NHẬP KHO — chứng từ nghiệp vụ của một lần nhận hàng từ nhà cung cấp.
 *
 * Đây là thứ đem in ra cho thủ kho và kế toán ký (xem GoodsReceiptService + template
 * admin/goods-receipt-print.html). Mỗi dòng hàng trên phiếu vừa nằm ở GoodsReceiptItem (để in
 * lại đúng chứng từ) vừa sinh một dòng ở STOCK_MOVEMENT (sổ cái tồn kho) — hai vai trò khác
 * nhau nên không gộp làm một: chứng từ thì bất biến, sổ cái thì phải liền mạch theo biến thể.
 */
@Entity
@Table(name = "GOODS_RECEIPT")
public class GoodsReceipt {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "ma_phieu", nullable = false, unique = true)
    private String maPhieu;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "supplier_id")
    private Supplier supplier;

    @Column(name = "so_hoa_don")
    private String soHoaDon;

    @Column(name = "ngay_hoa_don")
    private LocalDate ngayHoaDon;

    @Column(name = "ngay_nhap", nullable = false)
    private LocalDateTime ngayNhap = LocalDateTime.now();

    @Column(name = "vat_percent", nullable = false)
    private BigDecimal vatPercent = BigDecimal.ZERO;

    @Column(name = "tien_hang", nullable = false)
    private BigDecimal tienHang = BigDecimal.ZERO;

    @Column(name = "tien_vat", nullable = false)
    private BigDecimal tienVat = BigDecimal.ZERO;

    @Column(name = "tong_tien", nullable = false)
    private BigDecimal tongTien = BigDecimal.ZERO;

    @Column(name = "ghi_chu")
    private String ghiChu;

    @ManyToOne
    @JoinColumn(name = "created_by")
    private NguoiDung nguoiLap;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @OneToMany(mappedBy = "receipt", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<GoodsReceiptItem> chiTiet;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getMaPhieu() { return maPhieu; }
    public void setMaPhieu(String maPhieu) { this.maPhieu = maPhieu; }

    public Supplier getSupplier() { return supplier; }
    public void setSupplier(Supplier supplier) { this.supplier = supplier; }

    public String getSoHoaDon() { return soHoaDon; }
    public void setSoHoaDon(String soHoaDon) { this.soHoaDon = soHoaDon; }

    public LocalDate getNgayHoaDon() { return ngayHoaDon; }
    public void setNgayHoaDon(LocalDate ngayHoaDon) { this.ngayHoaDon = ngayHoaDon; }

    public LocalDateTime getNgayNhap() { return ngayNhap; }
    public void setNgayNhap(LocalDateTime ngayNhap) { this.ngayNhap = ngayNhap; }

    public BigDecimal getVatPercent() { return vatPercent; }
    public void setVatPercent(BigDecimal vatPercent) { this.vatPercent = vatPercent; }

    public BigDecimal getTienHang() { return tienHang; }
    public void setTienHang(BigDecimal tienHang) { this.tienHang = tienHang; }

    public BigDecimal getTienVat() { return tienVat; }
    public void setTienVat(BigDecimal tienVat) { this.tienVat = tienVat; }

    public BigDecimal getTongTien() { return tongTien; }
    public void setTongTien(BigDecimal tongTien) { this.tongTien = tongTien; }

    public String getGhiChu() { return ghiChu; }
    public void setGhiChu(String ghiChu) { this.ghiChu = ghiChu; }

    public NguoiDung getNguoiLap() { return nguoiLap; }
    public void setNguoiLap(NguoiDung nguoiLap) { this.nguoiLap = nguoiLap; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<GoodsReceiptItem> getChiTiet() { return chiTiet; }
    public void setChiTiet(List<GoodsReceiptItem> chiTiet) { this.chiTiet = chiTiet; }

    /** Tổng số lượng hàng trên phiếu — hiện ở danh sách và trên chứng từ in. */
    public int tongSoLuong() {
        if (chiTiet == null) return 0;
        return chiTiet.stream().mapToInt(i -> i.getSoLuong() == null ? 0 : i.getSoLuong()).sum();
    }
}
