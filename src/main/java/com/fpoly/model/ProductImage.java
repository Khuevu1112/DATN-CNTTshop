package com.fpoly.model;

import jakarta.persistence.*;

@Entity
@Table(name = "PRODUCT_IMAGE")
public class ProductImage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String url;

    @Column(name = "is_primary")
    private Boolean isPrimary;

    @Column(name = "sort_order")
    private Integer sortOrder;

    @ManyToOne
    @JoinColumn(name = "product_id")
    private Product product;

    public Integer getId() {
        return id;
    }

    public String getUrl() {
        return url;
    }

    public Boolean getIsPrimary() {
        return isPrimary;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }

    public Product getProduct() {
        return product;
    }
}