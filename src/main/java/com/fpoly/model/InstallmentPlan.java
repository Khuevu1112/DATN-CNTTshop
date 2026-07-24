package com.fpoly.model;

import java.math.BigDecimal;

import jakarta.persistence.*;

/** Kỳ hạn trả góp + lãi suất. Lãi suất là %/THÁNG tính trên dư nợ gốc ban đầu (lãi phẳng) —
 * xem InstallmentService.tinhToan để biết công thức đầy đủ. */
@Entity
@Table(name = "INSTALLMENT_PLAN")
public class InstallmentPlan {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "months", nullable = false, unique = true)
    private Integer soThang;

    @Column(name = "interest_rate", nullable = false)
    private BigDecimal laiSuat;

    @Column(name = "active", nullable = false)
    private Boolean active = true;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getSoThang() { return soThang; }
    public void setSoThang(Integer soThang) { this.soThang = soThang; }

    public BigDecimal getLaiSuat() { return laiSuat; }
    public void setLaiSuat(BigDecimal laiSuat) { this.laiSuat = laiSuat; }

    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }
}
