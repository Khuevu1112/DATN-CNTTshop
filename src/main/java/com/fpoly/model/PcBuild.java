package com.fpoly.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import jakarta.persistence.*;

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
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    public BigDecimal getTongGia() {
        return items.stream()
                .map(item -> item.getProductVariant() != null && item.getProductVariant().getPrice() != null
                        ? item.getProductVariant().getPrice().multiply(BigDecimal.valueOf(item.getSoLuong()))
                        : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
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
