package com.fpoly.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.persistence.*;

/** Một dòng trong bảng giá sửa chữa tham khảo. Cố ý KHÔNG tham chiếu PRODUCT — shop nhận sửa cả
 * máy mua nơi khác, ràng buộc vào PRODUCT sẽ chặn mất phần lớn nhu cầu thật. */
@Entity
@Table(name = "REPAIR_PRICE")
public class RepairPrice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "loai_thiet_bi", nullable = false)
    private String loaiThietBi;

    /** null = áp cho mọi hãng. */
    private String hang;

    /** null = áp cho mọi dòng máy trong nhóm. */
    @Column(name = "dong_may")
    private String dongMay;

    @Column(name = "ma_loi", nullable = false)
    private String maLoi;

    @Column(name = "ten_loi", nullable = false)
    private String tenLoi;

    @Column(name = "gia_linh_kien", nullable = false)
    private BigDecimal giaLinhKien = BigDecimal.ZERO;

    @Column(name = "tien_cong", nullable = false)
    private BigDecimal tienCong = BigDecimal.ZERO;

    /** Có giá trị = báo khoảng "x – y"; null = báo một con số. */
    @Column(name = "gia_den")
    private BigDecimal giaDen;

    @Column(name = "thoi_gian_du_kien")
    private String thoiGianDuKien;

    @Column(name = "bao_hanh_thang", nullable = false)
    private Integer baoHanhThang = 3;

    @Column(name = "ghi_chu")
    private String ghiChu;

    @Column(name = "hien_thi", nullable = false)
    private boolean hienThi = true;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 100;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    public void touch() {
        updatedAt = LocalDateTime.now();
    }

    /** Giá tối thiểu khách phải trả cho hạng mục này = linh kiện + công. */
    @Transient
    public BigDecimal getGiaTu() {
        BigDecimal lk = giaLinhKien != null ? giaLinhKien : BigDecimal.ZERO;
        BigDecimal tc = tienCong != null ? tienCong : BigDecimal.ZERO;
        return lk.add(tc);
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getLoaiThietBi() { return loaiThietBi; }
    public void setLoaiThietBi(String loaiThietBi) { this.loaiThietBi = loaiThietBi; }

    public String getHang() { return hang; }
    public void setHang(String hang) { this.hang = hang; }

    public String getDongMay() { return dongMay; }
    public void setDongMay(String dongMay) { this.dongMay = dongMay; }

    public String getMaLoi() { return maLoi; }
    public void setMaLoi(String maLoi) { this.maLoi = maLoi; }

    public String getTenLoi() { return tenLoi; }
    public void setTenLoi(String tenLoi) { this.tenLoi = tenLoi; }

    public BigDecimal getGiaLinhKien() { return giaLinhKien; }
    public void setGiaLinhKien(BigDecimal giaLinhKien) { this.giaLinhKien = giaLinhKien; }

    public BigDecimal getTienCong() { return tienCong; }
    public void setTienCong(BigDecimal tienCong) { this.tienCong = tienCong; }

    public BigDecimal getGiaDen() { return giaDen; }
    public void setGiaDen(BigDecimal giaDen) { this.giaDen = giaDen; }

    public String getThoiGianDuKien() { return thoiGianDuKien; }
    public void setThoiGianDuKien(String thoiGianDuKien) { this.thoiGianDuKien = thoiGianDuKien; }

    public Integer getBaoHanhThang() { return baoHanhThang; }
    public void setBaoHanhThang(Integer baoHanhThang) { this.baoHanhThang = baoHanhThang; }

    public String getGhiChu() { return ghiChu; }
    public void setGhiChu(String ghiChu) { this.ghiChu = ghiChu; }

    public boolean isHienThi() { return hienThi; }
    public void setHienThi(boolean hienThi) { this.hienThi = hienThi; }

    public Integer getSortOrder() { return sortOrder; }
    public void setSortOrder(Integer sortOrder) { this.sortOrder = sortOrder; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
