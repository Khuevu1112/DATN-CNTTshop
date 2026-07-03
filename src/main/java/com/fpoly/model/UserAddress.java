package com.fpoly.model;

import jakarta.persistence.*;

@Entity
@Table(name = "USER_ADDRESS")
public class UserAddress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private NguoiDung nguoiDung;

    @Column(name = "receiver_name", nullable = false)
    private String tenNguoiNhan;

    @Column(name = "phone", nullable = false)
    private String soDienThoai;

    @Column(name = "address", nullable = false)
    private String diaChiCuThe;

    // Tỉnh/Thành phố (chuẩn hành chính 2 cấp áp dụng từ 1/7/2025)
    @Column(name = "province", nullable = false)
    private String tinhThanh;

    // Phường/Xã/Đặc khu - trực thuộc thẳng Tỉnh/Thành phố, không còn qua Quận/Huyện
    @Column(name = "ward", nullable = false)
    private String phuongXa;

    @Column(name = "is_default", nullable = false)
    private Boolean isDefault = false;

    // Toạ độ ghim vị trí trên Google Maps, dùng để hỗ trợ shipper định vị chính xác
    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "longitude")
    private Double longitude;

    public String getDiaChiDayDu() {
        StringBuilder sb = new StringBuilder();
        if (diaChiCuThe != null) sb.append(diaChiCuThe);
        if (phuongXa != null) sb.append(", ").append(phuongXa);
        if (tinhThanh != null) sb.append(", ").append(tinhThanh);
        return sb.toString();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public NguoiDung getNguoiDung() { return nguoiDung; }
    public void setNguoiDung(NguoiDung nguoiDung) { this.nguoiDung = nguoiDung; }

    public String getTenNguoiNhan() { return tenNguoiNhan; }
    public void setTenNguoiNhan(String tenNguoiNhan) { this.tenNguoiNhan = tenNguoiNhan; }

    public String getSoDienThoai() { return soDienThoai; }
    public void setSoDienThoai(String soDienThoai) { this.soDienThoai = soDienThoai; }

    public String getDiaChiCuThe() { return diaChiCuThe; }
    public void setDiaChiCuThe(String diaChiCuThe) { this.diaChiCuThe = diaChiCuThe; }

    public String getTinhThanh() { return tinhThanh; }
    public void setTinhThanh(String tinhThanh) { this.tinhThanh = tinhThanh; }

    public String getPhuongXa() { return phuongXa; }
    public void setPhuongXa(String phuongXa) { this.phuongXa = phuongXa; }

    public Boolean getIsDefault() { return isDefault; }
    public void setIsDefault(Boolean isDefault) { this.isDefault = isDefault; }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
}