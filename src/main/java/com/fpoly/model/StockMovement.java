package com.fpoly.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.persistence.*;

/** 1 lần nhập hàng hoặc điều chỉnh kho cho 1 biến thể sản phẩm — giữ lịch sử thay vì chỉ ghi
 * đè trực tiếp PRODUCT_VARIANT.stock, để biết ai/khi nào/bao nhiêu/vì sao. */
@Entity
@Table(name = "STOCK_MOVEMENT")
public class StockMovement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "variant_id")
    private ProductVariant variant;

    /** Số dương = nhập thêm; số âm chỉ hợp lệ với reason "dieu_chinh" (hao hụt/hư hỏng...). */
    @Column(name = "change_qty")
    private Integer changeQty;

    /** "nhap_hang" (nhập hàng bình thường, luôn dương) hoặc "dieu_chinh" (điều chỉnh kiểm kê, có thể âm). */
    private String reason;

    @Column(name = "unit_cost")
    private BigDecimal unitCost;

    private String note;

    @ManyToOne
    @JoinColumn(name = "created_by")
    private NguoiDung createdBy;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public ProductVariant getVariant() { return variant; }
    public void setVariant(ProductVariant variant) { this.variant = variant; }

    public Integer getChangeQty() { return changeQty; }
    public void setChangeQty(Integer changeQty) { this.changeQty = changeQty; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public BigDecimal getUnitCost() { return unitCost; }
    public void setUnitCost(BigDecimal unitCost) { this.unitCost = unitCost; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public NguoiDung getCreatedBy() { return createdBy; }
    public void setCreatedBy(NguoiDung createdBy) { this.createdBy = createdBy; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
