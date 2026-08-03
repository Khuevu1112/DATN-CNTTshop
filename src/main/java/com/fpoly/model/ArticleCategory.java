package com.fpoly.model;

import jakarta.persistence.*;

/** Danh mục bài viết (Công nghệ, Review, Hướng dẫn...). */
@Entity
@Table(name = "ARTICLE_CATEGORY")
public class ArticleCategory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, unique = true)
    private String ma;

    @Column(nullable = false)
    private String ten;

    @Column(name = "hien_thi", nullable = false)
    private boolean hienThi = true;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 100;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getMa() { return ma; }
    public void setMa(String ma) { this.ma = ma; }

    public String getTen() { return ten; }
    public void setTen(String ten) { this.ten = ten; }

    public boolean isHienThi() { return hienThi; }
    public void setHienThi(boolean hienThi) { this.hienThi = hienThi; }

    public Integer getSortOrder() { return sortOrder; }
    public void setSortOrder(Integer sortOrder) { this.sortOrder = sortOrder; }
}
