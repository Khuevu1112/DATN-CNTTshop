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

    @Column(name = "province", nullable = false)
    private String tinhThanh;

    @Column(name = "district", nullable = false)
    private String quanHuyen;

    @Column(name = "ward", nullable = false)
    private String phuongXa;

    @Column(name = "is_default", nullable = false)
    private Boolean isDefault = false;

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

    public Boolean getIsDefault() { return isDefault; }
    public void setIsDefault(Boolean isDefault) { this.isDefault = isDefault; }
}