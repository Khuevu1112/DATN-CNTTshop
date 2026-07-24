package com.fpoly.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.persistence.*;

/** Trung tâm bảo hành / điểm dịch vụ của shop — công khai, không gắn với tài khoản nào.
 * Xem 66_support_center.sql để biết vì sao tách khỏi USER_ADDRESS. */
@Entity
@Table(name = "SERVICE_CENTER")
public class ServiceCenter {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private String ten;

    @Column(name = "dia_chi", nullable = false)
    private String diaChi;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "province_id")
    private Province province;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ward_id")
    private Ward ward;

    private BigDecimal lat;

    private BigDecimal lng;

    @Column(name = "dien_thoai")
    private String dienThoai;

    private String email;

    @Column(name = "gio_mo_cua")
    private String gioMoCua;

    /** CSV mã nhóm thiết bị nhận sửa, vd "laptop,pc,man_hinh". */
    @Column(name = "dich_vu")
    private String dichVu;

    /** chi_nhanh | uy_quyen */
    @Column(nullable = false)
    private String loai = "chi_nhanh";

    @Column(name = "nhan_dat_lich", nullable = false)
    private boolean nhanDatLich = true;

    @Column(name = "ghi_chu")
    private String ghiChu;

    @Column(name = "hien_thi", nullable = false)
    private boolean hienThi = true;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 100;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getTen() { return ten; }
    public void setTen(String ten) { this.ten = ten; }

    public String getDiaChi() { return diaChi; }
    public void setDiaChi(String diaChi) { this.diaChi = diaChi; }

    public Province getProvince() { return province; }
    public void setProvince(Province province) { this.province = province; }

    public Ward getWard() { return ward; }
    public void setWard(Ward ward) { this.ward = ward; }

    public BigDecimal getLat() { return lat; }
    public void setLat(BigDecimal lat) { this.lat = lat; }

    public BigDecimal getLng() { return lng; }
    public void setLng(BigDecimal lng) { this.lng = lng; }

    public String getDienThoai() { return dienThoai; }
    public void setDienThoai(String dienThoai) { this.dienThoai = dienThoai; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getGioMoCua() { return gioMoCua; }
    public void setGioMoCua(String gioMoCua) { this.gioMoCua = gioMoCua; }

    public String getDichVu() { return dichVu; }
    public void setDichVu(String dichVu) { this.dichVu = dichVu; }

    public String getLoai() { return loai; }
    public void setLoai(String loai) { this.loai = loai; }

    public boolean isNhanDatLich() { return nhanDatLich; }
    public void setNhanDatLich(boolean nhanDatLich) { this.nhanDatLich = nhanDatLich; }

    public String getGhiChu() { return ghiChu; }
    public void setGhiChu(String ghiChu) { this.ghiChu = ghiChu; }

    public boolean isHienThi() { return hienThi; }
    public void setHienThi(boolean hienThi) { this.hienThi = hienThi; }

    public Integer getSortOrder() { return sortOrder; }
    public void setSortOrder(Integer sortOrder) { this.sortOrder = sortOrder; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
