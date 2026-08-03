package com.fpoly.model;

import java.math.BigDecimal;
import java.time.LocalDate;
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

    /** Ngày khách hẹn mang máy tới / kỹ thuật tới tận nơi. */
    @Column(name = "ngay_hen")
    private LocalDate ngayHen;

    /** tan_noi = bảo hành tận nơi (có phụ phí) | cua_hang = mang tới cửa hàng gần nhất. */
    @Column(name = "hinh_thuc")
    private String hinhThuc;

    /** Trung tâm khách chọn khi hình thức = cua_hang; null với tận nơi. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "center_id")
    private ServiceCenter center;

    @Column(name = "phu_phi", nullable = false)
    private BigDecimal phuPhi = BigDecimal.ZERO;

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

    public LocalDate getNgayHen() { return ngayHen; }
    public void setNgayHen(LocalDate ngayHen) { this.ngayHen = ngayHen; }

    public String getHinhThuc() { return hinhThuc; }
    public void setHinhThuc(String hinhThuc) { this.hinhThuc = hinhThuc; }

    public ServiceCenter getCenter() { return center; }
    public void setCenter(ServiceCenter center) { this.center = center; }

    public BigDecimal getPhuPhi() { return phuPhi; }
    public void setPhuPhi(BigDecimal phuPhi) { this.phuPhi = phuPhi; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<WarrantyHistory> getHistories() { return histories; }
    public void setHistories(List<WarrantyHistory> histories) { this.histories = histories; }
}
