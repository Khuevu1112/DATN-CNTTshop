package com.fpoly.model;

import java.math.BigDecimal;

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

    @Column(name = "province", nullable = false)
    private String tinhThanh;

    @Column(name = "district")
    private String quanHuyen;

    @Column(name = "ward", nullable = false)
    private String phuongXa;

    // Tỉnh/Phường chuẩn hoá (FK, sau sáp nhập 1/7/2025) — chỉ được set khi tạo/sửa qua dropdown
    // ở cnttshop-vue (xem AddressService); địa chỉ tạo qua trang Thymeleaf cũ (/account/addresses)
    // vẫn chỉ có 2 cột text ở trên, 2 cột này để NULL, không ảnh hưởng gì tới luồng đó.
    @ManyToOne
    @JoinColumn(name = "province_id")
    private Province province;

    @ManyToOne
    @JoinColumn(name = "ward_id")
    private Ward ward;

    @Column(name = "is_default", nullable = false)
    private Boolean isDefault = false;

    // Toạ độ khách tự cắm trên bản đồ (xem MapPicker.vue). NULL với địa chỉ tạo trước khi có
    // tính năng cắm mốc, và với địa chỉ tạo qua trang Thymeleaf cũ — luồng tính phí ship nội
    // thành phải có nhánh dự phòng cho trường hợp này (xem ShippingService).
    @Column(name = "latitude")
    private BigDecimal latitude;

    @Column(name = "longitude")
    private BigDecimal longitude;

    public boolean coToaDo() {
        return latitude != null && longitude != null;
    }

    public String getDiaChiDayDu() {
        StringBuilder sb = new StringBuilder();
        if (diaChiCuThe != null) sb.append(diaChiCuThe);
        if (phuongXa != null) sb.append(", ").append(phuongXa);
        if (quanHuyen != null) sb.append(", ").append(quanHuyen);
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

    public String getQuanHuyen() { return quanHuyen; }
    public void setQuanHuyen(String quanHuyen) { this.quanHuyen = quanHuyen; }

    public String getPhuongXa() { return phuongXa; }
    public void setPhuongXa(String phuongXa) { this.phuongXa = phuongXa; }

    public Province getProvince() { return province; }
    public void setProvince(Province province) { this.province = province; }

    public Ward getWard() { return ward; }
    public void setWard(Ward ward) { this.ward = ward; }

    public Boolean getIsDefault() { return isDefault; }
    public void setIsDefault(Boolean isDefault) { this.isDefault = isDefault; }

    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }

    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }
}