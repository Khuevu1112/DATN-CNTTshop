package com.fpoly.model;

import java.time.LocalDateTime;
import java.util.List;

import jakarta.persistence.*;

/** Đợt flash sale — thuộc nhóm Quản lý khuyến mãi. Chỉ tối đa 1 đợt hoạt động cùng lúc
 * (xem FlashSaleService.dangHoatDong).
 *
 * Các cột dưới đây là BẢN NHÁP admin đang sửa; publishedPayload mới là thứ khách nhìn thấy.
 * Nhờ vậy admin sửa dở dang không làm hỏng banner đang chạy ngoài trang chủ. */
@Entity
@Table(name = "FLASH_SALE")
public class FlashSale {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "title", nullable = false)
    private String tieuDe = "FLASH SALE";

    @Column(name = "subtitle")
    private String moTa;

    @Column(name = "color_from", nullable = false)
    private String mauBatDau = "#ff3d24";

    @Column(name = "color_to", nullable = false)
    private String mauKetThuc = "#ff9500";

    @Column(name = "starts_at", nullable = false)
    private LocalDateTime batDauLuc;

    @Column(name = "ends_at", nullable = false)
    private LocalDateTime ketThucLuc;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "published_payload", columnDefinition = "NVARCHAR(MAX)")
    private String noiDungDaPublic;

    @Column(name = "published_at")
    private LocalDateTime publicLuc;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @ManyToOne
    @JoinColumn(name = "updated_by")
    private NguoiDung nguoiSuaCuoi;

    @OneToMany(mappedBy = "flashSale", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("thuTu ASC")
    private List<FlashSaleItem> danhSachSanPham;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    public void preUpdate() {
        updatedAt = LocalDateTime.now();
    }

    /** Đang thực sự chạy với khách: bật + trong khung giờ + đã từng bấm Public.
     * Thiếu bất kỳ điều nào thì trang chủ không hiện banner. */
    public boolean dangChay() {
        LocalDateTime now = LocalDateTime.now();
        return Boolean.TRUE.equals(isActive)
                && noiDungDaPublic != null
                && batDauLuc != null && ketThucLuc != null
                && !now.isBefore(batDauLuc) && now.isBefore(ketThucLuc);
    }

    /** Có bản nháp chưa public — dùng để hiện nhắc "bạn còn thay đổi chưa đăng" cho admin. */
    public boolean coThayDoiChuaPublic() {
        return publicLuc == null || (updatedAt != null && updatedAt.isAfter(publicLuc));
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getTieuDe() { return tieuDe; }
    public void setTieuDe(String tieuDe) { this.tieuDe = tieuDe; }

    public String getMoTa() { return moTa; }
    public void setMoTa(String moTa) { this.moTa = moTa; }

    public String getMauBatDau() { return mauBatDau; }
    public void setMauBatDau(String mauBatDau) { this.mauBatDau = mauBatDau; }

    public String getMauKetThuc() { return mauKetThuc; }
    public void setMauKetThuc(String mauKetThuc) { this.mauKetThuc = mauKetThuc; }

    public LocalDateTime getBatDauLuc() { return batDauLuc; }
    public void setBatDauLuc(LocalDateTime batDauLuc) { this.batDauLuc = batDauLuc; }

    public LocalDateTime getKetThucLuc() { return ketThucLuc; }
    public void setKetThucLuc(LocalDateTime ketThucLuc) { this.ketThucLuc = ketThucLuc; }

    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }

    public String getNoiDungDaPublic() { return noiDungDaPublic; }
    public void setNoiDungDaPublic(String noiDungDaPublic) { this.noiDungDaPublic = noiDungDaPublic; }

    public LocalDateTime getPublicLuc() { return publicLuc; }
    public void setPublicLuc(LocalDateTime publicLuc) { this.publicLuc = publicLuc; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public NguoiDung getNguoiSuaCuoi() { return nguoiSuaCuoi; }
    public void setNguoiSuaCuoi(NguoiDung nguoiSuaCuoi) { this.nguoiSuaCuoi = nguoiSuaCuoi; }

    public List<FlashSaleItem> getDanhSachSanPham() { return danhSachSanPham; }
    public void setDanhSachSanPham(List<FlashSaleItem> danhSachSanPham) { this.danhSachSanPham = danhSachSanPham; }
}
