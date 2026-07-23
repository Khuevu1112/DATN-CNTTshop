package com.fpoly.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.persistence.*;

/** Tín dụng thu cũ — số tiền shop nợ khách sau khi đã nhận máy và chốt giá.
 *
 * Khác coupon ở hai điểm quyết định:
 *   1. GẮN CỨNG user_id — người khác biết cũng không tiêu được (CouponService không có ràng
 *      buộc này, mã coupon là toàn cục theo code).
 *   2. Áp SONG SONG với coupon + Xu CT, không tranh chỗ Order.couponId — nên khách đổi máy vẫn
 *      dùng được mã khuyến mãi như thường.
 *
 * Dùng MỘT LẦN, không hoàn phần dư. Để khách không bao giờ mất tiền vì mua đơn nhỏ hơn giá trị
 * tín dụng, donToiThieu được đặt bằng chính soTien lúc phát hành. */
@Entity
@Table(name = "TRADE_IN_CREDIT")
public class TradeInCredit {

    public static final String CON_HIEU_LUC = "con_hieu_luc";
    public static final String DA_DUNG = "da_dung";
    public static final String HET_HAN = "het_han";
    public static final String THU_HOI = "thu_hoi";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "request_id", nullable = false)
    private TradeInRequest yeuCau;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private NguoiDung nguoiDung;

    @Column(name = "so_tien", nullable = false)
    private BigDecimal soTien;

    @Column(name = "don_toi_thieu", nullable = false)
    private BigDecimal donToiThieu = BigDecimal.ZERO;

    @Column(name = "het_han")
    private LocalDateTime hetHan;

    @Column(name = "trang_thai", nullable = false)
    private String trangThai = CON_HIEU_LUC;

    @Column(name = "used_order_id")
    private Integer donDaDung;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "used_at")
    private LocalDateTime usedAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    /** Dùng được ngay bây giờ hay không — gồm cả kiểm tra hết hạn theo thời gian thực, vì job
     * quét đổi trạng thái có thể chưa chạy tới. */
    public boolean conDungDuoc() {
        return CON_HIEU_LUC.equals(trangThai)
                && (hetHan == null || LocalDateTime.now().isBefore(hetHan));
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public TradeInRequest getYeuCau() { return yeuCau; }
    public void setYeuCau(TradeInRequest yeuCau) { this.yeuCau = yeuCau; }

    public NguoiDung getNguoiDung() { return nguoiDung; }
    public void setNguoiDung(NguoiDung nguoiDung) { this.nguoiDung = nguoiDung; }

    public BigDecimal getSoTien() { return soTien; }
    public void setSoTien(BigDecimal soTien) { this.soTien = soTien; }

    public BigDecimal getDonToiThieu() { return donToiThieu; }
    public void setDonToiThieu(BigDecimal donToiThieu) { this.donToiThieu = donToiThieu; }

    public LocalDateTime getHetHan() { return hetHan; }
    public void setHetHan(LocalDateTime hetHan) { this.hetHan = hetHan; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }

    public Integer getDonDaDung() { return donDaDung; }
    public void setDonDaDung(Integer donDaDung) { this.donDaDung = donDaDung; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUsedAt() { return usedAt; }
    public void setUsedAt(LocalDateTime usedAt) { this.usedAt = usedAt; }
}
