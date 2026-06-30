package com.fpoly.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "PC_BUILD")
public class PcBuild {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private NguoiDung nguoiDung;

    @Column(name = "name", nullable = false)
    private String tenCauHinh;

    @Column(name = "note", columnDefinition = "NVARCHAR(MAX)")
    private String ghiChu;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "pcBuild", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PcBuildItem> items = new ArrayList<>();

    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
    }

    // Tính tổng giá từ tất cả items
    public java.math.BigDecimal getTongGia() {
        return items.stream()
            .map(item -> {
                if (item.getProductVariant() != null && item.getProductVariant().getPrice() != null) {
                    return item.getProductVariant().getPrice()
                        .multiply(java.math.BigDecimal.valueOf(item.getSoLuong()));
                }
                return java.math.BigDecimal.ZERO;
            })
            .reduce(java.math.BigDecimal.ZERO, java.math.BigDecimal::add);
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public NguoiDung getNguoiDung() { return nguoiDung; }
    public void setNguoiDung(NguoiDung nguoiDung) { this.nguoiDung = nguoiDung; }

    public String getTenCauHinh() { return tenCauHinh; }
    public void setTenCauHinh(String tenCauHinh) { this.tenCauHinh = tenCauHinh; }

    public String getGhiChu() { return ghiChu; }
    public void setGhiChu(String ghiChu) { this.ghiChu = ghiChu; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<PcBuildItem> getItems() { return items; }
    public void setItems(List<PcBuildItem> items) { this.items = items; }
}