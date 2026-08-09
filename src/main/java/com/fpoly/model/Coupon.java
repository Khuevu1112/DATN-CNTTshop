package com.fpoly.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.persistence.*;

@Entity
@Table(name = "COUPON")
public class Coupon {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "code", nullable = false, unique = true)
    private String ma;

    // percent, fixed
    @Column(name = "discount_type", nullable = false)
    private String loaiGiam = "percent";

    @Column(name = "discount_value", nullable = false)
    private BigDecimal giaTriGiam;

    /** Số tiền giảm tối đa — chỉ có ý nghĩa khi loaiGiam = "percent", dùng để chặn đơn hàng lớn
     * bị giảm quá sâu (vd: giảm 20% nhưng tối đa 500.000đ). NULL = không giới hạn. Với
     * loaiGiam = "fixed" trường này không có tác dụng vì giá trị giảm đã là số tiền cố định. */
    @Column(name = "max_discount_amount")
    private BigDecimal giamToiDa;

    @Column(name = "min_order_value", nullable = false)
    private BigDecimal donToiThieu = BigDecimal.ZERO;

    @Column(name = "max_uses")
    private Integer soLuotToiDa;

    @Column(name = "used_count", nullable = false)
    private Integer soLuotDaDung = 0;

    @Column(name = "starts_at")
    private LocalDateTime batDauTu;

    @Column(name = "expires_at")
    private LocalDateTime hetHanLuc;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    // null = coupon thường; có giá trị = giá xu để đổi lấy mã này trên trang khuyến mãi
    @Column(name = "xu_cost")
    private Integer giaXu;

    /** Cho phép dùng CHUNG với mã khác trong cùng 1 đơn hàng hay không. Mặc định false = mã
     * phải đi một mình (giữ đúng hành vi cũ). true = có thể cộng dồn, trừ khi rơi vào cùng
     * exclusiveGroup với 1 mã khác cũng đang chọn. */
    @Column(name = "stackable", nullable = false)
    private Boolean stackable = false;

    /** Các mã CÙNG giá trị (khác NULL) ở trường này LOẠI TRỪ NHAU dù cả 2 đều stackable = true —
     * dùng khi 2 mã đều "cộng dồn được" nhưng không muốn dùng chung (vd cùng 1 đợt sale). */
    @Column(name = "exclusive_group")
    private String nhomLoaiTru;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getMa() { return ma; }
    public void setMa(String ma) { this.ma = ma; }

    public String getLoaiGiam() { return loaiGiam; }
    public void setLoaiGiam(String loaiGiam) { this.loaiGiam = loaiGiam; }

    public BigDecimal getGiaTriGiam() { return giaTriGiam; }
    public void setGiaTriGiam(BigDecimal giaTriGiam) { this.giaTriGiam = giaTriGiam; }

    public BigDecimal getGiamToiDa() { return giamToiDa; }
    public void setGiamToiDa(BigDecimal giamToiDa) { this.giamToiDa = giamToiDa; }

    public BigDecimal getDonToiThieu() { return donToiThieu; }
    public void setDonToiThieu(BigDecimal donToiThieu) { this.donToiThieu = donToiThieu; }

    public Integer getSoLuotToiDa() { return soLuotToiDa; }
    public void setSoLuotToiDa(Integer soLuotToiDa) { this.soLuotToiDa = soLuotToiDa; }

    public Integer getSoLuotDaDung() { return soLuotDaDung; }
    public void setSoLuotDaDung(Integer soLuotDaDung) { this.soLuotDaDung = soLuotDaDung; }

    public LocalDateTime getBatDauTu() { return batDauTu; }
    public void setBatDauTu(LocalDateTime batDauTu) { this.batDauTu = batDauTu; }

    public LocalDateTime getHetHanLuc() { return hetHanLuc; }
    public void setHetHanLuc(LocalDateTime hetHanLuc) { this.hetHanLuc = hetHanLuc; }

    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }

    public Integer getGiaXu() { return giaXu; }
    public void setGiaXu(Integer giaXu) { this.giaXu = giaXu; }
    public Boolean getStackable() { return stackable; }
    public void setStackable(Boolean stackable) { this.stackable = stackable; }
    public String getNhomLoaiTru() { return nhomLoaiTru; }
    public void setNhomLoaiTru(String nhomLoaiTru) { this.nhomLoaiTru = nhomLoaiTru; }
}
