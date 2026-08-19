package com.fpoly.model;

import java.math.BigDecimal;

import jakarta.persistence.*;

/** Một dòng hàng trên phiếu nhập kho. */
@Entity
@Table(name = "GOODS_RECEIPT_ITEM")
public class GoodsReceiptItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "receipt_id", nullable = false)
    private GoodsReceipt receipt;

    @ManyToOne
    @JoinColumn(name = "variant_id", nullable = false)
    private ProductVariant variant;

    // Chụp lại tên/SKU lúc nhập — sản phẩm đổi tên sau này thì phiếu đã lập vẫn phải khớp với
    // bản giấy đã in (cùng lý do với OrderItem.tenSanPham).
    @Column(name = "ten_san_pham", nullable = false)
    private String tenSanPham;

    @Column(name = "sku")
    private String sku;

    @Column(name = "so_luong", nullable = false)
    private Integer soLuong;

    @Column(name = "don_gia", nullable = false)
    private BigDecimal donGia = BigDecimal.ZERO;

    @Column(name = "thanh_tien", nullable = false)
    private BigDecimal thanhTien = BigDecimal.ZERO;

    @Column(name = "ghi_chu")
    private String ghiChu;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public GoodsReceipt getReceipt() { return receipt; }
    public void setReceipt(GoodsReceipt receipt) { this.receipt = receipt; }

    public ProductVariant getVariant() { return variant; }
    public void setVariant(ProductVariant variant) { this.variant = variant; }

    public String getTenSanPham() { return tenSanPham; }
    public void setTenSanPham(String tenSanPham) { this.tenSanPham = tenSanPham; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public Integer getSoLuong() { return soLuong; }
    public void setSoLuong(Integer soLuong) { this.soLuong = soLuong; }

    public BigDecimal getDonGia() { return donGia; }
    public void setDonGia(BigDecimal donGia) { this.donGia = donGia; }

    public BigDecimal getThanhTien() { return thanhTien; }
    public void setThanhTien(BigDecimal thanhTien) { this.thanhTien = thanhTien; }

    public String getGhiChu() { return ghiChu; }
    public void setGhiChu(String ghiChu) { this.ghiChu = ghiChu; }
}
