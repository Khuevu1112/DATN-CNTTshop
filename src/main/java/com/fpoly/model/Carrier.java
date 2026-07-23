package com.fpoly.model;

import java.math.BigDecimal;

import jakarta.persistence.*;

@Entity
@Table(name = "CARRIER")
public class Carrier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "code", nullable = false, unique = true)
    private String code;

    @Column(name = "name", nullable = false)
    private String name;

    // Phí liên tỉnh/liên miền — gộp chung 1 mức (không phân biệt cùng miền/khác miền về giá,
    // chỉ khác thời gian giao dự kiến, xem timeCungMien/timeKhacMien).
    @Column(name = "fee_lien_tinh", nullable = false)
    private BigDecimal feeLienTinh;

    @Column(name = "time_cung_mien", nullable = false)
    private String timeCungMien;

    @Column(name = "time_khac_mien", nullable = false)
    private String timeKhacMien;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "thu_tu", nullable = false)
    private Integer thuTu = 0;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public BigDecimal getFeeLienTinh() { return feeLienTinh; }
    public void setFeeLienTinh(BigDecimal feeLienTinh) { this.feeLienTinh = feeLienTinh; }

    public String getTimeCungMien() { return timeCungMien; }
    public void setTimeCungMien(String timeCungMien) { this.timeCungMien = timeCungMien; }

    public String getTimeKhacMien() { return timeKhacMien; }
    public void setTimeKhacMien(String timeKhacMien) { this.timeKhacMien = timeKhacMien; }

    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }

    public Integer getThuTu() { return thuTu; }
    public void setThuTu(Integer thuTu) { this.thuTu = thuTu; }
}
