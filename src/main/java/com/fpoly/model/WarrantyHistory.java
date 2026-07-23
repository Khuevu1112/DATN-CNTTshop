package com.fpoly.model;

import java.time.LocalDateTime;

import jakarta.persistence.*;

@Entity
@Table(name = "WARRANTY_HISTORY")
public class WarrantyHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "request_id")
    private WarrantyRequest request;

    private String status;

    private String note;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public WarrantyRequest getRequest() { return request; }
    public void setRequest(WarrantyRequest request) { this.request = request; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
