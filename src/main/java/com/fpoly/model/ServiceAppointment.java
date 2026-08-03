package com.fpoly.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

import jakarta.persistence.*;

/** Lịch hẹn mang máy tới trung tâm. Cho phép cả khách chưa đăng nhập (user_id NULL) vì shop
 * nhận sửa dịch vụ cho máy mua nơi khác — xem 66_support_center.sql. */
@Entity
@Table(name = "SERVICE_APPOINTMENT")
public class ServiceAppointment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    /** Mã tra cứu công khai — khách vãng lai không có tài khoản nên đây là thứ duy nhất họ
     * dùng để xem lại lịch của mình. */
    @Column(name = "ma_lich", nullable = false, unique = true)
    private String maLich;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "center_id", nullable = false)
    private ServiceCenter center;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private NguoiDung user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warranty_id")
    private Warranty warranty;

    @Column(name = "ho_ten", nullable = false)
    private String hoTen;

    @Column(name = "dien_thoai", nullable = false)
    private String dienThoai;

    private String email;

    @Column(name = "loai_thiet_bi", nullable = false)
    private String loaiThietBi;

    private String model;

    @Column(name = "mo_ta_loi", nullable = false)
    private String moTaLoi;

    @Column(name = "ngay_hen", nullable = false)
    private LocalDate ngayHen;

    @Column(name = "khung_gio", nullable = false)
    private String khungGio;

    /** cho_xac_nhan | da_xac_nhan | dang_xu_ly | hoan_thanh | khach_khong_den | da_huy */
    @Column(name = "trang_thai", nullable = false)
    private String trangThai = "cho_xac_nhan";

    @Column(name = "ghi_chu_ktv")
    private String ghiChuKtv;

    /** Chi phí thực của lần sửa, kỹ thuật ghi lại khi hoàn thành. Là dữ liệu cho bảng "Lịch sử
     * bảo hành" phía khách — null khi lịch chưa xong hoặc là ca bảo hành miễn phí. */
    @Column(name = "chi_phi")
    private java.math.BigDecimal chiPhi;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        if (trangThai == null) trangThai = "cho_xac_nhan";
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getMaLich() { return maLich; }
    public void setMaLich(String maLich) { this.maLich = maLich; }

    public ServiceCenter getCenter() { return center; }
    public void setCenter(ServiceCenter center) { this.center = center; }

    public NguoiDung getUser() { return user; }
    public void setUser(NguoiDung user) { this.user = user; }

    public Warranty getWarranty() { return warranty; }
    public void setWarranty(Warranty warranty) { this.warranty = warranty; }

    public String getHoTen() { return hoTen; }
    public void setHoTen(String hoTen) { this.hoTen = hoTen; }

    public String getDienThoai() { return dienThoai; }
    public void setDienThoai(String dienThoai) { this.dienThoai = dienThoai; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getLoaiThietBi() { return loaiThietBi; }
    public void setLoaiThietBi(String loaiThietBi) { this.loaiThietBi = loaiThietBi; }

    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }

    public String getMoTaLoi() { return moTaLoi; }
    public void setMoTaLoi(String moTaLoi) { this.moTaLoi = moTaLoi; }

    public LocalDate getNgayHen() { return ngayHen; }
    public void setNgayHen(LocalDate ngayHen) { this.ngayHen = ngayHen; }

    public String getKhungGio() { return khungGio; }
    public void setKhungGio(String khungGio) { this.khungGio = khungGio; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }

    public String getGhiChuKtv() { return ghiChuKtv; }
    public void setGhiChuKtv(String ghiChuKtv) { this.ghiChuKtv = ghiChuKtv; }

    public java.math.BigDecimal getChiPhi() { return chiPhi; }
    public void setChiPhi(java.math.BigDecimal chiPhi) { this.chiPhi = chiPhi; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
