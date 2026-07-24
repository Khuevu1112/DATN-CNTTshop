package com.fpoly.model;

import jakarta.persistence.*;

/** Nhóm câu hỏi thường gặp. */
@Entity
@Table(name = "FAQ_CATEGORY")
public class FaqCategory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, unique = true)
    private String ma;

    @Column(nullable = false)
    private String ten;

    @Column(name = "mo_ta")
    private String moTa;

    private String icon;

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

    public String getMoTa() { return moTa; }
    public void setMoTa(String moTa) { this.moTa = moTa; }

    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }

    public boolean isHienThi() { return hienThi; }
    public void setHienThi(boolean hienThi) { this.hienThi = hienThi; }

    public Integer getSortOrder() { return sortOrder; }
    public void setSortOrder(Integer sortOrder) { this.sortOrder = sortOrder; }
}
