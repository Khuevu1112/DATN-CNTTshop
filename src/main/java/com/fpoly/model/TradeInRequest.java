package com.fpoly.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import jakarta.persistence.*;

/** Một yêu cầu thu cũ đổi mới.
 *
 * Hai con số giá cố ý tách rời: giaTamTinh là mức báo online dựa trên lời khai của khách,
 * giaChot là mức thật sau khi kỹ thuật cầm máy kiểm tra. Khách chỉ được cấp tín dụng theo
 * giaChot — không bao giờ theo giaTamTinh, vì máy khai "còn 95%" thực tế có thể phồng pin,
 * thay main, mất nguồn. */
@Entity
@Table(name = "TRADE_IN_REQUEST")
public class TradeInRequest {

    /** Toàn bộ trạng thái hợp lệ. Ba trạng thái KẾT THÚC (không đi tiếp được): da_cap_tin_dung,
     * tu_choi_thu, khach_tu_choi, huy_yeu_cau. */
    public static final String CHO_DINH_GIA = "cho_dinh_gia";
    public static final String DA_BAO_GIA = "da_bao_gia";
    public static final String KHACH_DONG_Y = "khach_dong_y";
    public static final String DA_NHAN_MAY = "da_nhan_may";
    public static final String DA_KIEM_TRA = "da_kiem_tra";
    public static final String DA_CAP_TIN_DUNG = "da_cap_tin_dung";
    public static final String TU_CHOI_THU = "tu_choi_thu";
    public static final String KHACH_TU_CHOI = "khach_tu_choi";
    public static final String HUY_YEU_CAU = "huy_yeu_cau";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private NguoiDung nguoiDung;

    @Column(name = "loai_thiet_bi", nullable = false)
    private String loaiThietBi;

    @Column(name = "hang")
    private String hang;

    @Column(name = "model", nullable = false)
    private String model;

    @Column(name = "tinh_trang_khai", nullable = false)
    private String tinhTrangKhai;

    @Column(name = "nam_mua")
    private Integer namMua;

    @Column(name = "mo_ta")
    private String moTa;

    @Column(name = "serial")
    private String serial;

    @Column(name = "photo1") private String photo1;
    @Column(name = "photo2") private String photo2;
    @Column(name = "photo3") private String photo3;
    @Column(name = "photo4") private String photo4;

    @Column(name = "gia_tam_tinh")
    private BigDecimal giaTamTinh;

    @Column(name = "gia_chot")
    private BigDecimal giaChot;

    @Column(name = "trang_thai", nullable = false)
    private String trangThai = CHO_DINH_GIA;

    @Column(name = "ghi_chu_ktv")
    private String ghiChuKtv;

    @ManyToOne
    @JoinColumn(name = "appraised_by")
    private NguoiDung nguoiDinhGia;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "yeuCau", cascade = CascadeType.ALL)
    @OrderBy("thoiGian ASC")
    private List<TradeInHistory> lichSu;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    public void preUpdate() {
        updatedAt = LocalDateTime.now();
    }

    /** Đã tới hồi kết, không chuyển trạng thái được nữa. */
    public boolean daKetThuc() {
        return DA_CAP_TIN_DUNG.equals(trangThai) || TU_CHOI_THU.equals(trangThai)
                || KHACH_TU_CHOI.equals(trangThai) || HUY_YEU_CAU.equals(trangThai);
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public NguoiDung getNguoiDung() { return nguoiDung; }
    public void setNguoiDung(NguoiDung nguoiDung) { this.nguoiDung = nguoiDung; }

    public String getLoaiThietBi() { return loaiThietBi; }
    public void setLoaiThietBi(String loaiThietBi) { this.loaiThietBi = loaiThietBi; }

    public String getHang() { return hang; }
    public void setHang(String hang) { this.hang = hang; }

    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }

    public String getTinhTrangKhai() { return tinhTrangKhai; }
    public void setTinhTrangKhai(String tinhTrangKhai) { this.tinhTrangKhai = tinhTrangKhai; }

    public Integer getNamMua() { return namMua; }
    public void setNamMua(Integer namMua) { this.namMua = namMua; }

    public String getMoTa() { return moTa; }
    public void setMoTa(String moTa) { this.moTa = moTa; }

    public String getSerial() { return serial; }
    public void setSerial(String serial) { this.serial = serial; }

    public String getPhoto1() { return photo1; }
    public void setPhoto1(String photo1) { this.photo1 = photo1; }
    public String getPhoto2() { return photo2; }
    public void setPhoto2(String photo2) { this.photo2 = photo2; }
    public String getPhoto3() { return photo3; }
    public void setPhoto3(String photo3) { this.photo3 = photo3; }
    public String getPhoto4() { return photo4; }
    public void setPhoto4(String photo4) { this.photo4 = photo4; }

    public BigDecimal getGiaTamTinh() { return giaTamTinh; }
    public void setGiaTamTinh(BigDecimal giaTamTinh) { this.giaTamTinh = giaTamTinh; }

    public BigDecimal getGiaChot() { return giaChot; }
    public void setGiaChot(BigDecimal giaChot) { this.giaChot = giaChot; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }

    public String getGhiChuKtv() { return ghiChuKtv; }
    public void setGhiChuKtv(String ghiChuKtv) { this.ghiChuKtv = ghiChuKtv; }

    public NguoiDung getNguoiDinhGia() { return nguoiDinhGia; }
    public void setNguoiDinhGia(NguoiDung nguoiDinhGia) { this.nguoiDinhGia = nguoiDinhGia; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public List<TradeInHistory> getLichSu() { return lichSu; }
    public void setLichSu(List<TradeInHistory> lichSu) { this.lichSu = lichSu; }
}
