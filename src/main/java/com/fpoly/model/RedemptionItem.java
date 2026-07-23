package com.fpoly.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.persistence.*;

@Entity
@Table(name = "REDEMPTION_ITEM")
public class RedemptionItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // coupon, gift
    @Column(name = "type", nullable = false)
    private String loai;

    @Column(name = "name", nullable = false)
    private String ten;

    @Column(name = "silver_cost", nullable = false)
    private Integer giaTokenBac;

    @Column(name = "discount_percent")
    private Integer phanTramGiam;

    @Column(name = "coupon_min_order")
    private BigDecimal donToiThieu;

    @ManyToOne
    @JoinColumn(name = "variant_id")
    private ProductVariant variant;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "sort_order", nullable = false)
    private Integer thuTu = 0;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getLoai() { return loai; }
    public void setLoai(String loai) { this.loai = loai; }

    public String getTen() { return ten; }
    public void setTen(String ten) { this.ten = ten; }

    public Integer getGiaTokenBac() { return giaTokenBac; }
    public void setGiaTokenBac(Integer giaTokenBac) { this.giaTokenBac = giaTokenBac; }

    public Integer getPhanTramGiam() { return phanTramGiam; }
    public void setPhanTramGiam(Integer phanTramGiam) { this.phanTramGiam = phanTramGiam; }

    public BigDecimal getDonToiThieu() { return donToiThieu; }
    public void setDonToiThieu(BigDecimal donToiThieu) { this.donToiThieu = donToiThieu; }

    public ProductVariant getVariant() { return variant; }
    public void setVariant(ProductVariant variant) { this.variant = variant; }

    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }

    public Integer getThuTu() { return thuTu; }
    public void setThuTu(Integer thuTu) { this.thuTu = thuTu; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
