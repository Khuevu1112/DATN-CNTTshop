package com.fpoly.model;

import java.math.BigDecimal;

import jakarta.persistence.*;

@Entity
@Table(name = "SHIPPING_HP_TIER")
public class ShippingHpTier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // same_ward, other_ward
    @Column(name = "tier_key", nullable = false, unique = true)
    private String tierKey;

    @Column(name = "label", nullable = false)
    private String label;

    @Column(name = "fee", nullable = false)
    private BigDecimal fee;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getTierKey() { return tierKey; }
    public void setTierKey(String tierKey) { this.tierKey = tierKey; }

    public String getLabel() { return label; }
    public void setLabel(String label) { this.label = label; }

    public BigDecimal getFee() { return fee; }
    public void setFee(BigDecimal fee) { this.fee = fee; }
}
