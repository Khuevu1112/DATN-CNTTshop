package com.fpoly.model;

import java.math.BigDecimal;

import jakarta.persistence.*;

/** 1 sản phẩm trong đợt flash sale. */
@Entity
@Table(name = "FLASH_SALE_ITEM")
public class FlashSaleItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "flash_sale_id", nullable = false)
    private FlashSale flashSale;

    @ManyToOne
    @JoinColumn(name = "variant_id", nullable = false)
    private ProductVariant variant;

    /** Giá bán trong đợt sale — lưu số tuyệt đối, KHÔNG tính % từ giá gốc. Giá gốc có thể bị sửa
     * giữa đợt, khi đó số tiền khách nhìn thấy sẽ tự nhảy theo mà không ai chủ động duyệt. */
    @Column(name = "sale_price", nullable = false)
    private BigDecimal giaSale;

    @Column(name = "sort_order", nullable = false)
    private Integer thuTu = 0;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public FlashSale getFlashSale() { return flashSale; }
    public void setFlashSale(FlashSale flashSale) { this.flashSale = flashSale; }

    public ProductVariant getVariant() { return variant; }
    public void setVariant(ProductVariant variant) { this.variant = variant; }

    public BigDecimal getGiaSale() { return giaSale; }
    public void setGiaSale(BigDecimal giaSale) { this.giaSale = giaSale; }

    public Integer getThuTu() { return thuTu; }
    public void setThuTu(Integer thuTu) { this.thuTu = thuTu; }
}
