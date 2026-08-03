package com.fpoly.model;

import java.time.LocalDateTime;

import jakarta.persistence.*;

/** Sản phẩm yêu thích (kiểu Steam wishlist). discountNotified chống gửi mail giảm giá trùng —
 * xem WishlistService.baoGiamGia / AdminProductService.update. */
@Entity
@Table(name = "WISHLIST")
public class Wishlist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private NguoiDung nguoiDung;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "discount_notified", nullable = false)
    private boolean discountNotified = false;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public NguoiDung getNguoiDung() { return nguoiDung; }
    public void setNguoiDung(NguoiDung nguoiDung) { this.nguoiDung = nguoiDung; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public boolean isDiscountNotified() { return discountNotified; }
    public void setDiscountNotified(boolean discountNotified) { this.discountNotified = discountNotified; }
}
