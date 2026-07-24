package com.fpoly.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.persistence.*;

/** Đơn ĐĂNG KÝ trả góp — chưa phải đơn hàng.
 *
 * Cố ý tách rời ORDER (giữ đúng ý đồ của dev thiết kế bảng này): trả góp phải duyệt hồ sơ tín
 * dụng trước, không chốt ngay được. Vì vậy bản ghi này chưa trừ kho, chưa tính vào doanh thu.
 * Nhân viên gọi xác minh, duyệt xong mới dựng đơn hàng thật cho khách. */
@Entity
@Table(name = "INSTALLMENT_ORDER")
public class InstallmentOrder {

    public static final String PENDING = "PENDING";
    public static final String APPROVED = "APPROVED";
    public static final String REJECTED = "REJECTED";
    public static final String CANCELLED = "CANCELLED";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    /** NULL khi khách chưa đăng nhập mà vẫn đăng ký tư vấn. */
    @ManyToOne
    @JoinColumn(name = "user_id")
    private NguoiDung nguoiDung;

    @ManyToOne
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne
    @JoinColumn(name = "variant_id")
    private ProductVariant variant;

    // Chụp lại tại thời điểm đăng ký — hồ sơ kéo dài nhiều tháng, sản phẩm có thể đổi tên/gỡ bán.
    @Column(name = "product_name", nullable = false)
    private String tenSanPham;

    @Column(name = "selected_options")
    private String tuyChon;

    @Column(name = "quantity", nullable = false)
    private Integer soLuong = 1;

    @Column(name = "months", nullable = false)
    private Integer soThang;

    @Column(name = "interest_rate", nullable = false)
    private BigDecimal laiSuat;

    @Column(name = "price", nullable = false)
    private BigDecimal giaBan;

    @Column(name = "down_payment", nullable = false)
    private BigDecimal traTruoc = BigDecimal.ZERO;

    @Column(name = "loan_amount", nullable = false)
    private BigDecimal soTienVay;

    @Column(name = "total_interest", nullable = false)
    private BigDecimal tongLai;

    @Column(name = "monthly_payment", nullable = false)
    private BigDecimal traHangThang;

    @Column(name = "total_payment", nullable = false)
    private BigDecimal tongPhaiTra;

    @Column(name = "customer_name", nullable = false)
    private String tenKhach;

    @Column(name = "customer_phone", nullable = false)
    private String soDienThoai;

    @Column(name = "customer_email")
    private String email;

    @Column(name = "customer_address", nullable = false)
    private String diaChi;

    /** CCCD/CMND — dữ liệu định danh cá nhân, chỉ trả về cho nhân viên có quyền installment. */
    @Column(name = "identity_number", nullable = false)
    private String soCccd;

    @Column(name = "status", nullable = false)
    private String trangThai = PENDING;

    @Column(name = "staff_note")
    private String ghiChuNhanVien;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    @PreUpdate
    public void preUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public NguoiDung getNguoiDung() { return nguoiDung; }
    public void setNguoiDung(NguoiDung nguoiDung) { this.nguoiDung = nguoiDung; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public ProductVariant getVariant() { return variant; }
    public void setVariant(ProductVariant variant) { this.variant = variant; }

    public String getTenSanPham() { return tenSanPham; }
    public void setTenSanPham(String tenSanPham) { this.tenSanPham = tenSanPham; }

    public String getTuyChon() { return tuyChon; }
    public void setTuyChon(String tuyChon) { this.tuyChon = tuyChon; }

    public Integer getSoLuong() { return soLuong; }
    public void setSoLuong(Integer soLuong) { this.soLuong = soLuong; }

    public Integer getSoThang() { return soThang; }
    public void setSoThang(Integer soThang) { this.soThang = soThang; }

    public BigDecimal getLaiSuat() { return laiSuat; }
    public void setLaiSuat(BigDecimal laiSuat) { this.laiSuat = laiSuat; }

    public BigDecimal getGiaBan() { return giaBan; }
    public void setGiaBan(BigDecimal giaBan) { this.giaBan = giaBan; }

    public BigDecimal getTraTruoc() { return traTruoc; }
    public void setTraTruoc(BigDecimal traTruoc) { this.traTruoc = traTruoc; }

    public BigDecimal getSoTienVay() { return soTienVay; }
    public void setSoTienVay(BigDecimal soTienVay) { this.soTienVay = soTienVay; }

    public BigDecimal getTongLai() { return tongLai; }
    public void setTongLai(BigDecimal tongLai) { this.tongLai = tongLai; }

    public BigDecimal getTraHangThang() { return traHangThang; }
    public void setTraHangThang(BigDecimal traHangThang) { this.traHangThang = traHangThang; }

    public BigDecimal getTongPhaiTra() { return tongPhaiTra; }
    public void setTongPhaiTra(BigDecimal tongPhaiTra) { this.tongPhaiTra = tongPhaiTra; }

    public String getTenKhach() { return tenKhach; }
    public void setTenKhach(String tenKhach) { this.tenKhach = tenKhach; }

    public String getSoDienThoai() { return soDienThoai; }
    public void setSoDienThoai(String soDienThoai) { this.soDienThoai = soDienThoai; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getDiaChi() { return diaChi; }
    public void setDiaChi(String diaChi) { this.diaChi = diaChi; }

    public String getSoCccd() { return soCccd; }
    public void setSoCccd(String soCccd) { this.soCccd = soCccd; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }

    public String getGhiChuNhanVien() { return ghiChuNhanVien; }
    public void setGhiChuNhanVien(String ghiChuNhanVien) { this.ghiChuNhanVien = ghiChuNhanVien; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
