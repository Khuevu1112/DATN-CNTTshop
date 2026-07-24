package com.fpoly.model;

import jakarta.persistence.*;

/** Thời hạn bảo hành công bố theo NHÓM hàng, phục vụ trang "Thông tin bảo hành".
 *
 * Không thay thế PRODUCT.warranty_months: cột đó mới là nguồn sự thật khi lập phiếu bảo hành cho
 * một máy cụ thể. Bảng này tồn tại để công bố chính sách cho cả nhóm hàng shop chưa từng bán. */
@Entity
@Table(name = "WARRANTY_POLICY")
public class WarrantyPolicy {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "nhom_hang", nullable = false)
    private String nhomHang;

    @Column(name = "so_thang", nullable = false)
    private Integer soThang;

    @Column(name = "mo_ta")
    private String moTa;

    @Column(name = "tinh_tu", nullable = false)
    private String tinhTu = "Ngày xuất hoá đơn";

    @Column(name = "hien_thi", nullable = false)
    private boolean hienThi = true;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 100;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getNhomHang() { return nhomHang; }
    public void setNhomHang(String nhomHang) { this.nhomHang = nhomHang; }

    public Integer getSoThang() { return soThang; }
    public void setSoThang(Integer soThang) { this.soThang = soThang; }

    public String getMoTa() { return moTa; }
    public void setMoTa(String moTa) { this.moTa = moTa; }

    public String getTinhTu() { return tinhTu; }
    public void setTinhTu(String tinhTu) { this.tinhTu = tinhTu; }

    public boolean isHienThi() { return hienThi; }
    public void setHienThi(boolean hienThi) { this.hienThi = hienThi; }

    public Integer getSortOrder() { return sortOrder; }
    public void setSortOrder(Integer sortOrder) { this.sortOrder = sortOrder; }
}
