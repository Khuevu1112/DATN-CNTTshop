package com.fpoly.model;

import java.time.LocalDateTime;

import jakarta.persistence.*;

/** Một lượt đăng ký gói của khách. started_at/expires_at chỉ được điền khi thanh toán thành
 * công (xem SubscriptionService.kichHoatSauThanhToan) — trước đó gói ở trạng thái 'pending',
 * chưa có hiệu lực. Bậc gói KHÔNG lưu vào NguoiDung: gói còn hiệu lực được xác định bằng
 * status='active' AND expires_at > now (query trong repository), nên hết hạn tự mất tác dụng
 * mà không cần job nền. */
@Entity
@Table(name = "USER_SUBSCRIPTION")
public class UserSubscription {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private NguoiDung nguoiDung;

    @ManyToOne
    @JoinColumn(name = "plan_id", nullable = false)
    private SubscriptionPlan plan;

    @Column(name = "started_at")
    private LocalDateTime startedAt;

    @Column(name = "expires_at")
    private LocalDateTime expiresAt;

    // pending, active, expired, cancelled
    @Column(name = "status", nullable = false)
    private String status = "pending";

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public NguoiDung getNguoiDung() { return nguoiDung; }
    public void setNguoiDung(NguoiDung nguoiDung) { this.nguoiDung = nguoiDung; }

    public SubscriptionPlan getPlan() { return plan; }
    public void setPlan(SubscriptionPlan plan) { this.plan = plan; }

    public LocalDateTime getStartedAt() { return startedAt; }
    public void setStartedAt(LocalDateTime startedAt) { this.startedAt = startedAt; }

    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
