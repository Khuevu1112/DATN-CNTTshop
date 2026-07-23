package com.fpoly.model;

import java.time.LocalDateTime;

import jakarta.persistence.*;

/** 1 dòng hoạt động của 1 tài khoản: đăng nhập, hoặc khoá/mở khoá (kèm lý do/hạn khoá/ảnh chứng
 * minh khi khoá) — gộp chung 1 bảng để hiển thị thành 1 timeline duy nhất ở trang chi tiết tài khoản. */
@Entity
@Table(name = "ACCOUNT_LOG")
public class AccountLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private NguoiDung user;

    /** "login" | "lock" | "unlock". */
    @Column(name = "log_type")
    private String logType;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    private String reason;

    @Column(name = "lock_until")
    private LocalDateTime lockUntil;

    @Column(name = "evidence_image")
    private String evidenceImage;

    @ManyToOne
    @JoinColumn(name = "performed_by_id")
    private NguoiDung performedBy;

    @Column(name = "ip_address")
    private String ipAddress;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public NguoiDung getUser() { return user; }
    public void setUser(NguoiDung user) { this.user = user; }

    public String getLogType() { return logType; }
    public void setLogType(String logType) { this.logType = logType; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public LocalDateTime getLockUntil() { return lockUntil; }
    public void setLockUntil(LocalDateTime lockUntil) { this.lockUntil = lockUntil; }

    public String getEvidenceImage() { return evidenceImage; }
    public void setEvidenceImage(String evidenceImage) { this.evidenceImage = evidenceImage; }

    public NguoiDung getPerformedBy() { return performedBy; }
    public void setPerformedBy(NguoiDung performedBy) { this.performedBy = performedBy; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
}
