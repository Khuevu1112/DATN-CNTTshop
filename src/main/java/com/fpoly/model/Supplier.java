package com.fpoly.model;

import java.time.LocalDateTime;

import jakarta.persistence.*;

/** Nhà cung cấp hàng hoá — bên bán trên phiếu nhập kho (xem GoodsReceipt). */
@Entity
@Table(name = "SUPPLIER")
public class Supplier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private String ten;

    @Column(name = "ma_so_thue")
    private String maSoThue;

    @Column(name = "dien_thoai")
    private String dienThoai;

    private String email;

    @Column(name = "dia_chi")
    private String diaChi;

    @Column(name = "nguoi_lien_he")
    private String nguoiLienHe;

    @Column(name = "ghi_chu")
    private String ghiChu;

    /** false = ngừng hợp tác — ẩn khỏi ô chọn khi lập phiếu mới, nhưng phiếu cũ vẫn tra được. */
    @Column(name = "hien_thi", nullable = false)
    private Boolean hienThi = true;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getTen() { return ten; }
    public void setTen(String ten) { this.ten = ten; }

    public String getMaSoThue() { return maSoThue; }
    public void setMaSoThue(String maSoThue) { this.maSoThue = maSoThue; }

    public String getDienThoai() { return dienThoai; }
    public void setDienThoai(String dienThoai) { this.dienThoai = dienThoai; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getDiaChi() { return diaChi; }
    public void setDiaChi(String diaChi) { this.diaChi = diaChi; }

    public String getNguoiLienHe() { return nguoiLienHe; }
    public void setNguoiLienHe(String nguoiLienHe) { this.nguoiLienHe = nguoiLienHe; }

    public String getGhiChu() { return ghiChu; }
    public void setGhiChu(String ghiChu) { this.ghiChu = ghiChu; }

    public Boolean getHienThi() { return hienThi; }
    public void setHienThi(Boolean hienThi) { this.hienThi = hienThi; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
