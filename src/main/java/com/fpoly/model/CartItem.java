package com.fpoly.model;

import java.math.BigDecimal;

import jakarta.persistence.*;

@Entity
@Table(name = "CART_ITEM")
public class CartItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "cart_id", nullable = false)
    private Cart cart;

    @ManyToOne
    @JoinColumn(name = "variant_id", nullable = false)
    private ProductVariant variant;

    @Column(name = "quantity", nullable = false)
    private Integer soLuong;

    public BigDecimal getThanhTien() {
        if (variant == null || variant.getPrice() == null || soLuong == null) {
            return BigDecimal.ZERO;
        }
        return variant.getPrice().multiply(BigDecimal.valueOf(soLuong));
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Cart getCart() { return cart; }
    public void setCart(Cart cart) { this.cart = cart; }

    public ProductVariant getVariant() { return variant; }
    public void setVariant(ProductVariant variant) { this.variant = variant; }

    public Integer getSoLuong() { return soLuong; }
    public void setSoLuong(Integer soLuong) { this.soLuong = soLuong; }
}