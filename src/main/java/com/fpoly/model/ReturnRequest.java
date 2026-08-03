package com.fpoly.model;

import java.time.LocalDateTime;

import jakarta.persistence.*;

/** Yêu cầu ĐỔI TRẢ (1 đổi 1 trong 7 ngày) — tách khỏi bảo hành. Khách gửi kèm minh chứng:
 * video lỗi, video tự mở hàng (bắt buộc với đơn online), ảnh lỗi. Xem 71_return_request.sql. */
@Entity
@Table(name = "RETURN_REQUEST")
public class ReturnRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "ma_yeu_cau", nullable = false, unique = true)
    private String maYeuCau;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private NguoiDung user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id")
    private Order order;

    @Column(name = "ma_don")
    private String maDon;

    @Column(name = "ten_san_pham")
    private String tenSanPham;

    /** online | tai_cua_hang — online bắt buộc có video mở hàng. */
    @Column(name = "kenh_mua", nullable = false)
    private String kenhMua = "online";

    @Column(name = "ly_do")
    private String lyDo;

    @Column(name = "noi_dung", nullable = false)
    private String noiDung;

    @Column(name = "video_loi")
    private String videoLoi;

    @Column(name = "video_mo_hang")
    private String videoMoHang;

    @Column(name = "anh_loi1")
    private String anhLoi1;

    @Column(name = "anh_loi2")
    private String anhLoi2;

    @Column(name = "anh_loi3")
    private String anhLoi3;

    /** cho_xu_ly | dang_xu_ly | chap_nhan | tu_choi | hoan_tat */
    @Column(name = "trang_thai", nullable = false)
    private String trangThai = "cho_xu_ly";

    @Column(name = "ghi_chu_cskh")
    private String ghiChuCskh;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        if (trangThai == null) trangThai = "cho_xu_ly";
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getMaYeuCau() { return maYeuCau; }
    public void setMaYeuCau(String maYeuCau) { this.maYeuCau = maYeuCau; }

    public NguoiDung getUser() { return user; }
    public void setUser(NguoiDung user) { this.user = user; }

    public Order getOrder() { return order; }
    public void setOrder(Order order) { this.order = order; }

    public String getMaDon() { return maDon; }
    public void setMaDon(String maDon) { this.maDon = maDon; }

    public String getTenSanPham() { return tenSanPham; }
    public void setTenSanPham(String tenSanPham) { this.tenSanPham = tenSanPham; }

    public String getKenhMua() { return kenhMua; }
    public void setKenhMua(String kenhMua) { this.kenhMua = kenhMua; }

    public String getLyDo() { return lyDo; }
    public void setLyDo(String lyDo) { this.lyDo = lyDo; }

    public String getNoiDung() { return noiDung; }
    public void setNoiDung(String noiDung) { this.noiDung = noiDung; }

    public String getVideoLoi() { return videoLoi; }
    public void setVideoLoi(String videoLoi) { this.videoLoi = videoLoi; }

    public String getVideoMoHang() { return videoMoHang; }
    public void setVideoMoHang(String videoMoHang) { this.videoMoHang = videoMoHang; }

    public String getAnhLoi1() { return anhLoi1; }
    public void setAnhLoi1(String anhLoi1) { this.anhLoi1 = anhLoi1; }

    public String getAnhLoi2() { return anhLoi2; }
    public void setAnhLoi2(String anhLoi2) { this.anhLoi2 = anhLoi2; }

    public String getAnhLoi3() { return anhLoi3; }
    public void setAnhLoi3(String anhLoi3) { this.anhLoi3 = anhLoi3; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }

    public String getGhiChuCskh() { return ghiChuCskh; }
    public void setGhiChuCskh(String ghiChuCskh) { this.ghiChuCskh = ghiChuCskh; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
