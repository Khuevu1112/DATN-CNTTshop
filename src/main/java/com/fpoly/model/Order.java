package com.fpoly.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import jakarta.persistence.*;

@Entity
@Table(name = "[ORDER]")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private NguoiDung nguoiDung;

    @ManyToOne
    @JoinColumn(name = "address_id", nullable = false)
    private UserAddress diaChiGiao;

    // Chưa làm module Coupon -> giữ cột thô, cho phép null
    @Column(name = "coupon_id")
    private Integer couponId;

    @Column(name = "order_code", nullable = false, unique = true)
    private String maDonHang;

    @Column(name = "subtotal", nullable = false)
    private BigDecimal tienHang;

    @Column(name = "discount_amount", nullable = false)
    private BigDecimal tienGiamGia = BigDecimal.ZERO;

    @Column(name = "shipping_fee", nullable = false)
    private BigDecimal phiVanChuyen = BigDecimal.ZERO;

    @Column(name = "total_amount", nullable = false)
    private BigDecimal tongTien;

    // pending, confirmed, processing, shipped, delivered, cancelled, refunded
    @Column(name = "status", nullable = false)
    private String trangThai = "pending";

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    private List<OrderItem> chiTiet;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    private List<OrderStatusLog> lichSuTrangThai;

    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
        if (maDonHang == null) {
            maDonHang = "DH" + System.currentTimeMillis();
        }
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public NguoiDung getNguoiDung() { return nguoiDung; }
    public void setNguoiDung(NguoiDung nguoiDung) { this.nguoiDung = nguoiDung; }

    public UserAddress getDiaChiGiao() { return diaChiGiao; }
    public void setDiaChiGiao(UserAddress diaChiGiao) { this.diaChiGiao = diaChiGiao; }

    public Integer getCouponId() { return couponId; }
    public void setCouponId(Integer couponId) { this.couponId = couponId; }

    public String getMaDonHang() { return maDonHang; }
    public void setMaDonHang(String maDonHang) { this.maDonHang = maDonHang; }

    public BigDecimal getTienHang() { return tienHang; }
    public void setTienHang(BigDecimal tienHang) { this.tienHang = tienHang; }

    public BigDecimal getTienGiamGia() { return tienGiamGia; }
    public void setTienGiamGia(BigDecimal tienGiamGia) { this.tienGiamGia = tienGiamGia; }

    public BigDecimal getPhiVanChuyen() { return phiVanChuyen; }
    public void setPhiVanChuyen(BigDecimal phiVanChuyen) { this.phiVanChuyen = phiVanChuyen; }

    public BigDecimal getTongTien() { return tongTien; }
    public void setTongTien(BigDecimal tongTien) { this.tongTien = tongTien; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<OrderItem> getChiTiet() { return chiTiet; }
    public void setChiTiet(List<OrderItem> chiTiet) { this.chiTiet = chiTiet; }

    public List<OrderStatusLog> getLichSuTrangThai() { return lichSuTrangThai; }
    public void setLichSuTrangThai(List<OrderStatusLog> lichSuTrangThai) { this.lichSuTrangThai = lichSuTrangThai; }
}