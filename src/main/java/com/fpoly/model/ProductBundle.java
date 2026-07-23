package com.fpoly.model;

import jakarta.persistence.*;

/** Gợi ý sản phẩm thường mua kèm (vd: PC gợi ý kèm màn hình, bàn phím). */
@Entity
@Table(name = "PRODUCT_BUNDLE")
public class ProductBundle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "product_id")
    private Product product;

    @ManyToOne
    @JoinColumn(name = "bundle_product_id")
    private Product bundleProduct;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public Product getBundleProduct() { return bundleProduct; }
    public void setBundleProduct(Product bundleProduct) { this.bundleProduct = bundleProduct; }
}
