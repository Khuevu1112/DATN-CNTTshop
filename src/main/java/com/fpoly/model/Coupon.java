package com.fpoly.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.persistence.*;

@Entity
@Table(name = "COUPON")
public class Coupon {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "code", nullable = false, unique = true)
    private String ma;

    // percent, fixed
    @Column(name = "discount_type", nullable = false)
    private String loaiGiam = "percent";

    @Column(name = "discount_value", nullable = false)
    private BigDecimal giaTriGiam;

    @Column(name = "min_order_value", nullable = false)
    private BigDecimal donToiThieu = BigDecimal.ZERO;

    @Column(name = "max_uses")
    private Integer soLuotToiDa;

    @Column(name = "used_count", nullable = false)
    private Integer soLuotDaDung = 0;

    @Column(name = "starts_at")
    private LocalDateTime batDauTu;

    @Column(name = "expires_at")
    private LocalDateTime hetHanLuc;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    // null = coupon thường; có giá trị = giá xu để đổi lấy mã này trên trang khuyến mãi
    @Column(name = "xu_cost")
    private Integer giaXu;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getMa() { return ma; }
    public void setMa(String ma) { this.ma = ma; }

    public String getLoaiGiam() { return loaiGiam; }
    public void setLoaiGiam(String loaiGiam) { this.loaiGiam = loaiGiam; }

    public BigDecimal getGiaTriGiam() { return giaTriGiam; }
    public void setGiaTriGiam(BigDecimal giaTriGiam) { this.giaTriGiam = giaTriGiam; }

    public BigDecimal getDonToiThieu() { return donToiThieu; }
    public void setDonToiThieu(BigDecimal donToiThieu) { this.donToiThieu = donToiThieu; }

    public Integer getSoLuotToiDa() { return soLuotToiDa; }
    public void setSoLuotToiDa(Integer soLuotToiDa) { this.soLuotToiDa = soLuotToiDa; }

    public Integer getSoLuotDaDung() { return soLuotDaDung; }
    public void setSoLuotDaDung(Integer soLuotDaDung) { this.soLuotDaDung = soLuotDaDung; }

    public LocalDateTime getBatDauTu() { return batDauTu; }
    public void setBatDauTu(LocalDateTime batDauTu) { this.batDauTu = batDauTu; }

    public LocalDateTime getHetHanLuc() { return hetHanLuc; }
    public void setHetHanLuc(LocalDateTime hetHanLuc) { this.hetHanLuc = hetHanLuc; }

    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }

    public Integer getGiaXu() { return giaXu; }
    public void setGiaXu(Integer giaXu) { this.giaXu = giaXu; }
}
