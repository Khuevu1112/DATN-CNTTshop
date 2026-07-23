package com.fpoly.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

import jakarta.persistence.*;

@Entity
@Table(name = "CHECKIN_LOG")
public class CheckinLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private NguoiDung nguoiDung;

    @Column(name = "checkin_date", nullable = false)
    private LocalDate ngayDiemDanh;

    @Column(name = "streak_count", nullable = false)
    private Integer soNgayLienTiep;

    @Column(name = "reward_silver", nullable = false)
    private Integer thuongTokenBac;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public NguoiDung getNguoiDung() { return nguoiDung; }
    public void setNguoiDung(NguoiDung nguoiDung) { this.nguoiDung = nguoiDung; }

    public LocalDate getNgayDiemDanh() { return ngayDiemDanh; }
    public void setNgayDiemDanh(LocalDate ngayDiemDanh) { this.ngayDiemDanh = ngayDiemDanh; }

    public Integer getSoNgayLienTiep() { return soNgayLienTiep; }
    public void setSoNgayLienTiep(Integer soNgayLienTiep) { this.soNgayLienTiep = soNgayLienTiep; }

    public Integer getThuongTokenBac() { return thuongTokenBac; }
    public void setThuongTokenBac(Integer thuongTokenBac) { this.thuongTokenBac = thuongTokenBac; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
