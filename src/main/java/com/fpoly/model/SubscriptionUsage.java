package com.fpoly.model;

import java.time.LocalDateTime;

import jakarta.persistence.*;

/** Sổ giao dịch tiêu/hoàn lượt quyền lợi CÓ HẠN MỨC của gói (interprovince ship, vệ sinh, bảo
 * hành tận nơi, mượn máy) — mô phỏng đúng WALLET_TRANSACTION: mỗi dòng là 1 sự kiện, delta=+1
 * khi tiêu 1 lượt, delta=-1 khi hoàn. Số lượt CÒN LẠI = hạn mức của gói - SUM(delta). Nhờ ghi
 * sổ (không dùng 1 cột đếm) mà huỷ đơn hoàn lại đúng lượt đã tiêu, y như hoàn xu. */
@Entity
@Table(name = "SUBSCRIPTION_USAGE")
public class SubscriptionUsage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "subscription_id", nullable = false)
    private UserSubscription subscription;

    // interprovince_ship / cleaning / onsite_warranty / loaner
    @Column(name = "benefit_key", nullable = false)
    private String benefitKey;

    @Column(name = "delta", nullable = false)
    private Integer delta;

    // Đơn hàng gắn với lượt tiêu (chỉ có với interprovince_ship) — để hoàn lượt khi đơn bị huỷ.
    @Column(name = "order_id")
    private Integer orderId;

    @Column(name = "note")
    private String note;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public UserSubscription getSubscription() { return subscription; }
    public void setSubscription(UserSubscription subscription) { this.subscription = subscription; }

    public String getBenefitKey() { return benefitKey; }
    public void setBenefitKey(String benefitKey) { this.benefitKey = benefitKey; }

    public Integer getDelta() { return delta; }
    public void setDelta(Integer delta) { this.delta = delta; }

    public Integer getOrderId() { return orderId; }
    public void setOrderId(Integer orderId) { this.orderId = orderId; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
