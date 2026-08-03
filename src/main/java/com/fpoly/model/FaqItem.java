package com.fpoly.model;

import java.time.LocalDateTime;

import jakarta.persistence.*;

/** Một câu hỏi thường gặp. */
@Entity
@Table(name = "FAQ_ITEM")
public class FaqItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private FaqCategory category;

    @Column(name = "cau_hoi", nullable = false)
    private String cauHoi;

    @Column(name = "tra_loi", nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String traLoi;

    /** Từ khoá phụ cho ô tìm kiếm — khách gõ "ship" nhưng câu trả lời viết "vận chuyển". */
    @Column(name = "tu_khoa")
    private String tuKhoa;

    @Column(name = "noi_bat", nullable = false)
    private boolean noiBat = false;

    @Column(name = "luot_xem", nullable = false)
    private Integer luotXem = 0;

    @Column(name = "hien_thi", nullable = false)
    private boolean hienThi = true;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 100;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    public void touch() {
        updatedAt = LocalDateTime.now();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public FaqCategory getCategory() { return category; }
    public void setCategory(FaqCategory category) { this.category = category; }

    public String getCauHoi() { return cauHoi; }
    public void setCauHoi(String cauHoi) { this.cauHoi = cauHoi; }

    public String getTraLoi() { return traLoi; }
    public void setTraLoi(String traLoi) { this.traLoi = traLoi; }

    public String getTuKhoa() { return tuKhoa; }
    public void setTuKhoa(String tuKhoa) { this.tuKhoa = tuKhoa; }

    public boolean isNoiBat() { return noiBat; }
    public void setNoiBat(boolean noiBat) { this.noiBat = noiBat; }

    public Integer getLuotXem() { return luotXem; }
    public void setLuotXem(Integer luotXem) { this.luotXem = luotXem; }

    public boolean isHienThi() { return hienThi; }
    public void setHienThi(boolean hienThi) { this.hienThi = hienThi; }

    public Integer getSortOrder() { return sortOrder; }
    public void setSortOrder(Integer sortOrder) { this.sortOrder = sortOrder; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
