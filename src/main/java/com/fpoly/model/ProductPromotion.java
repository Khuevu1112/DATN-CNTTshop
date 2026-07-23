package com.fpoly.model;

import jakarta.persistence.*;

/** Một dòng khuyến mãi đi kèm sản phẩm, ví dụ "Tặng chuột không dây". */
@Entity
@Table(name = "PRODUCT_PROMOTION")
public class ProductPromotion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(columnDefinition = "NVARCHAR(1000)")
    private String content;

    @Column(name = "sort_order")
    private Integer sortOrder = 0;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Integer getSortOrder() { return sortOrder; }
    public void setSortOrder(Integer sortOrder) { this.sortOrder = sortOrder; }
}
