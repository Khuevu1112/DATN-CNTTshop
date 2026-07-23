package com.fpoly.model;

import java.time.LocalDateTime;

import jakarta.persistence.*;

@Entity
@Table(name = "WALLET_TRANSACTION")
public class WalletTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "wallet_id", nullable = false)
    private Wallet wallet;

    // gold, silver
    @Column(name = "token_type", nullable = false)
    private String loaiToken;

    // deposit, earn, redeem, spend, adjust
    @Column(name = "type", nullable = false)
    private String loaiGiaoDich;

    // Số dương = cộng, số âm = trừ
    @Column(name = "amount", nullable = false)
    private Integer soLuong;

    @Column(name = "note")
    private String ghiChu;

    @ManyToOne
    @JoinColumn(name = "ref_order_id")
    private Order donHangLienQuan;

    @ManyToOne
    @JoinColumn(name = "ref_coupon_id")
    private Coupon couponLienQuan;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Wallet getWallet() { return wallet; }
    public void setWallet(Wallet wallet) { this.wallet = wallet; }

    public String getLoaiToken() { return loaiToken; }
    public void setLoaiToken(String loaiToken) { this.loaiToken = loaiToken; }

    public String getLoaiGiaoDich() { return loaiGiaoDich; }
    public void setLoaiGiaoDich(String loaiGiaoDich) { this.loaiGiaoDich = loaiGiaoDich; }

    public Integer getSoLuong() { return soLuong; }
    public void setSoLuong(Integer soLuong) { this.soLuong = soLuong; }

    public String getGhiChu() { return ghiChu; }
    public void setGhiChu(String ghiChu) { this.ghiChu = ghiChu; }

    public Order getDonHangLienQuan() { return donHangLienQuan; }
    public void setDonHangLienQuan(Order donHangLienQuan) { this.donHangLienQuan = donHangLienQuan; }

    public Coupon getCouponLienQuan() { return couponLienQuan; }
    public void setCouponLienQuan(Coupon couponLienQuan) { this.couponLienQuan = couponLienQuan; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
