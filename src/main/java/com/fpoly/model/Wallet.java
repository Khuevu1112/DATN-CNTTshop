package com.fpoly.model;

import java.time.LocalDateTime;

import jakarta.persistence.*;

@Entity
@Table(name = "WALLET")
public class Wallet {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private NguoiDung nguoiDung;

    @Column(name = "silver_balance", nullable = false)
    private Integer soDuBac = 0;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    public void chamMoc() {
        updatedAt = LocalDateTime.now();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public NguoiDung getNguoiDung() { return nguoiDung; }
    public void setNguoiDung(NguoiDung nguoiDung) { this.nguoiDung = nguoiDung; }

    public Integer getSoDuBac() { return soDuBac; }
    public void setSoDuBac(Integer soDuBac) { this.soDuBac = soDuBac; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
