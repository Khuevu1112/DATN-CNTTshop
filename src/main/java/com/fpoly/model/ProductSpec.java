package com.fpoly.model;

import jakarta.persistence.*;

@Entity
@Table(name = "PRODUCT_SPEC")
public class ProductSpec {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "spec_key")
    private String specKey;

    @Column(name = "spec_value")
    private String specValue;

    @Column(name = "sort_order")
    private Integer sortOrder;

    @ManyToOne
    @JoinColumn(name = "product_id")
    private Product product;

    public Integer getId() {
        return id;
    }

    public String getSpecKey() {
        return specKey;
    }

    public String getSpecValue() {
        return specValue;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }

    public Product getProduct() {
        return product;
    }
}