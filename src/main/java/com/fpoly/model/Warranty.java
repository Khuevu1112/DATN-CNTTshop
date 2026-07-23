package com.fpoly.model;

import java.time.LocalDate;
import java.util.List;

import jakarta.persistence.*;

@Entity
@Table(name = "WARRANTY")
public class Warranty {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @OneToOne
    @JoinColumn(name = "order_item_id")
    private OrderItem orderItem;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private NguoiDung nguoiDung;

    @Column(name = "serial_number")
    private String serialNumber;

    @Column(name = "start_date")
    private LocalDate startDate;

    @Column(name = "end_date")
    private LocalDate endDate;

    private String status;

    @OneToMany(mappedBy = "warranty", cascade = CascadeType.ALL)
    private List<WarrantyRequest> requests;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public OrderItem getOrderItem() { return orderItem; }
    public void setOrderItem(OrderItem orderItem) { this.orderItem = orderItem; }

    public NguoiDung getNguoiDung() { return nguoiDung; }
    public void setNguoiDung(NguoiDung nguoiDung) { this.nguoiDung = nguoiDung; }

    public String getSerialNumber() { return serialNumber; }
    public void setSerialNumber(String serialNumber) { this.serialNumber = serialNumber; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public List<WarrantyRequest> getRequests() { return requests; }
    public void setRequests(List<WarrantyRequest> requests) { this.requests = requests; }
}
