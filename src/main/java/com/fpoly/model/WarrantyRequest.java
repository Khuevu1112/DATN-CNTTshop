package com.fpoly.model;

import java.time.LocalDateTime;
import java.util.List;

import jakarta.persistence.*;

@Entity
@Table(name = "WARRANTY_REQUEST")
public class WarrantyRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "warranty_id")
    private Warranty warranty;

    @Column(name = "issue_description")
    private String issueDescription;

    @Column(name = "request_status")
    private String requestStatus;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "request", cascade = CascadeType.ALL)
    private List<WarrantyHistory> histories;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Warranty getWarranty() { return warranty; }
    public void setWarranty(Warranty warranty) { this.warranty = warranty; }

    public String getIssueDescription() { return issueDescription; }
    public void setIssueDescription(String issueDescription) { this.issueDescription = issueDescription; }

    public String getRequestStatus() { return requestStatus; }
    public void setRequestStatus(String requestStatus) { this.requestStatus = requestStatus; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<WarrantyHistory> getHistories() { return histories; }
    public void setHistories(List<WarrantyHistory> histories) { this.histories = histories; }
}
