package com.fpoly.model;

import java.time.LocalDateTime;

import jakarta.persistence.*;

/** Một mốc đổi trạng thái của yêu cầu thu cũ — ai đổi, khi nào, vì sao. Cần thiết khi có tranh
 * chấp về mức giá đã định. */
@Entity
@Table(name = "TRADE_IN_HISTORY")
public class TradeInHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "request_id", nullable = false)
    private TradeInRequest yeuCau;

    @Column(name = "trang_thai", nullable = false)
    private String trangThai;

    @Column(name = "ghi_chu")
    private String ghiChu;

    @ManyToOne
    @JoinColumn(name = "nguoi_thuc_hien")
    private NguoiDung nguoiThucHien;

    @Column(name = "thoi_gian", nullable = false)
    private LocalDateTime thoiGian;

    @PrePersist
    public void prePersist() {
        if (thoiGian == null) thoiGian = LocalDateTime.now();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public TradeInRequest getYeuCau() { return yeuCau; }
    public void setYeuCau(TradeInRequest yeuCau) { this.yeuCau = yeuCau; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }

    public String getGhiChu() { return ghiChu; }
    public void setGhiChu(String ghiChu) { this.ghiChu = ghiChu; }

    public NguoiDung getNguoiThucHien() { return nguoiThucHien; }
    public void setNguoiThucHien(NguoiDung nguoiThucHien) { this.nguoiThucHien = nguoiThucHien; }

    public LocalDateTime getThoiGian() { return thoiGian; }
    public void setThoiGian(LocalDateTime thoiGian) { this.thoiGian = thoiGian; }
}
