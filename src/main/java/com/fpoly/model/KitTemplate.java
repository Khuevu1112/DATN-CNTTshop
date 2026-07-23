package com.fpoly.model;

import java.time.LocalDateTime;
import java.util.List;

import jakarta.persistence.*;

/** Mẫu cấu hình PC do admin định nghĩa (case, CPU, GPU... đến chuột, bàn phím) để áp nhanh khi tạo sản phẩm mới. */
@Entity
@Table(name = "KIT_TEMPLATE")
public class KitTemplate {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "name", nullable = false)
    private String ten;

    @Column(name = "description")
    private String moTa;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "kitTemplate", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("thuTu ASC")
    private List<KitTemplateItem> items;

    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getTen() { return ten; }
    public void setTen(String ten) { this.ten = ten; }

    public String getMoTa() { return moTa; }
    public void setMoTa(String moTa) { this.moTa = moTa; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<KitTemplateItem> getItems() { return items; }
    public void setItems(List<KitTemplateItem> items) { this.items = items; }
}
