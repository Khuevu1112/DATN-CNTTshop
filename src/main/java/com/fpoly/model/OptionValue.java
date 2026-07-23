package com.fpoly.model;

import java.math.BigDecimal;

import jakarta.persistence.*;

@Entity
@Table(name = "OPTION_VALUE")
public class OptionValue {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "option_id")
    private ProductOption option;

    private String value;

    /** Phụ phí cộng thêm vào giá biến thể khi chọn giá trị này. */
    @Column(name = "price_extra")
    private BigDecimal priceExtra = BigDecimal.ZERO;

    @Column(name = "is_default")
    private Boolean isDefault = false;

    @Column(name = "is_active")
    private Boolean active = true;

    @Column(name = "sort_order")
    private Integer sortOrder = 0;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public ProductOption getOption() { return option; }
    public void setOption(ProductOption option) { this.option = option; }

    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }

    public BigDecimal getPriceExtra() { return priceExtra; }
    public void setPriceExtra(BigDecimal priceExtra) { this.priceExtra = priceExtra; }

    public Boolean getIsDefault() { return isDefault; }
    public void setIsDefault(Boolean isDefault) { this.isDefault = isDefault; }

    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }

    public Integer getSortOrder() { return sortOrder; }
    public void setSortOrder(Integer sortOrder) { this.sortOrder = sortOrder; }
}
