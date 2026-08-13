package com.fpoly.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import jakarta.persistence.*;

@Entity
@Table(name = "[ORDER]")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private NguoiDung nguoiDung;

    // NULL với đơn bán tại quầy (channel = "pos") — khách cầm hàng về ngay, không giao tận nơi.
    // Mọi chỗ đọc phải kiểm null (xem OrderApiController.toDetail + template admin/order-*.html).
    @ManyToOne
    @JoinColumn(name = "address_id")
    private UserAddress diaChiGiao;

    /** "online" = đặt qua web, "pos" = bán tại showroom. Không suy ra từ address_id IS NULL vì
     * đơn online lỗi dữ liệu cũng có thể thiếu địa chỉ — cột này nói rõ ý định. */
    @Column(name = "channel", nullable = false)
    private String kenhBan = "online";

    // Chưa làm module Coupon -> giữ cột thô, cho phép null
    @Column(name = "coupon_id")
    private Integer couponId;

    @Column(name = "order_code", nullable = false, unique = true)
    private String maDonHang;

    @Column(name = "subtotal", nullable = false)
    private BigDecimal tienHang;

    @Column(name = "discount_amount", nullable = false)
    private BigDecimal tienGiamGia = BigDecimal.ZERO;

    @Column(name = "shipping_fee", nullable = false)
    private BigDecimal phiVanChuyen = BigDecimal.ZERO;

    // Lưu lại nhãn/thời gian giao tại thời điểm đặt hàng (không tham chiếu sống tới
    // SHIPPING_HP_TIER/CARRIER) — giống cách OrderItem lưu tenSanPham/donGia — để lịch sử đơn
    // không đổi theo nếu sau này admin sửa bảng giá/hãng vận chuyển.
    @Column(name = "shipping_option_code")
    private String maTuyChonGiaoHang;

    @Column(name = "shipping_option_label")
    private String nhanTuyChonGiaoHang;

    @Column(name = "shipping_eta")
    private String thoiGianGiaoDuKien;

    // Thu cũ đổi mới: ghi RIÊNG, không gộp vào tienGiamGia — kế toán cần tách bạch "giảm giá
    // khuyến mãi" với "trừ vào tiền thu mua máy cũ", bản chất hai khoản khác hẳn nhau.
    @Column(name = "trade_in_credit_id")
    private Integer tradeInCreditId;

    @Column(name = "trade_in_amount", nullable = false)
    private BigDecimal tienThuCu = BigDecimal.ZERO;

    // Toạ độ điểm giao CHỤP LẠI lúc đặt đơn — cùng lý do với 3 cột trên: khách sửa/xoá địa chỉ
    // sau khi đặt thì admin vẫn phải thấy đúng nơi cần giao đơn này. shipping_distance_km là
    // quãng đường đã dùng để ra phí ship, lưu để admin đối chiếu (xem ShippingService).
    @Column(name = "delivery_lat")
    private BigDecimal viDoGiao;

    @Column(name = "delivery_lng")
    private BigDecimal kinhDoGiao;

    @Column(name = "shipping_distance_km")
    private BigDecimal khoangCachGiaoKm;

    // Mã vận đơn bên ngoài — admin điền tay khi bàn giao đơn cho hãng vận chuyển (bàn giao xong
    // mới có mã, không có lúc đặt hàng). Dùng để tra tracking GHN (order_code) hoặc tạo tracking
    // AfterShip cho Shopee Express (tracking_number). NULL nếu đơn giao bằng xe của shop (nội
    // thành Hải Phòng) hoặc chưa bàn giao.
    @Column(name = "external_tracking_number")
    private String maVanDonNgoai;

    // ID tracking AfterShip trả về lúc taoTracking() thành công — dùng để gọi các API sau này
    // (get/update/delete/retrack), KHÁC với maVanDonNgoai (đó là tracking_number khách nhìn thấy,
    // đây là id nội bộ AfterShip cần để gọi API).
    @Column(name = "aftership_tracking_id")
    private String afterShipTrackingId;

    @Column(name = "total_amount", nullable = false)
    private BigDecimal tongTien;

    // pending, confirmed, processing, shipped, delivered, cancelled, refunded
    @Column(name = "status", nullable = false)
    private String trangThai = "pending";

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    private List<OrderItem> chiTiet;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    private List<OrderStatusLog> lichSuTrangThai;

    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
        if (maDonHang == null) {
            maDonHang = "DH" + System.currentTimeMillis();
        }
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public NguoiDung getNguoiDung() { return nguoiDung; }
    public void setNguoiDung(NguoiDung nguoiDung) { this.nguoiDung = nguoiDung; }

    public String getKenhBan() { return kenhBan; }
    public void setKenhBan(String kenhBan) { this.kenhBan = kenhBan; }

    /** Đơn bán tại showroom — dùng để bỏ qua phần địa chỉ/vận chuyển ở mọi nơi hiển thị. */
    public boolean laDonTaiQuay() { return "pos".equals(kenhBan); }

    public UserAddress getDiaChiGiao() { return diaChiGiao; }
    public void setDiaChiGiao(UserAddress diaChiGiao) { this.diaChiGiao = diaChiGiao; }

    public Integer getCouponId() { return couponId; }
    public void setCouponId(Integer couponId) { this.couponId = couponId; }

    public String getMaDonHang() { return maDonHang; }
    public void setMaDonHang(String maDonHang) { this.maDonHang = maDonHang; }

    public BigDecimal getTienHang() { return tienHang; }
    public void setTienHang(BigDecimal tienHang) { this.tienHang = tienHang; }

    public BigDecimal getTienGiamGia() { return tienGiamGia; }
    public void setTienGiamGia(BigDecimal tienGiamGia) { this.tienGiamGia = tienGiamGia; }

    public BigDecimal getPhiVanChuyen() { return phiVanChuyen; }
    public void setPhiVanChuyen(BigDecimal phiVanChuyen) { this.phiVanChuyen = phiVanChuyen; }

    public String getMaTuyChonGiaoHang() { return maTuyChonGiaoHang; }
    public void setMaTuyChonGiaoHang(String maTuyChonGiaoHang) { this.maTuyChonGiaoHang = maTuyChonGiaoHang; }

    public String getNhanTuyChonGiaoHang() { return nhanTuyChonGiaoHang; }
    public void setNhanTuyChonGiaoHang(String nhanTuyChonGiaoHang) { this.nhanTuyChonGiaoHang = nhanTuyChonGiaoHang; }

    public String getThoiGianGiaoDuKien() { return thoiGianGiaoDuKien; }
    public void setThoiGianGiaoDuKien(String thoiGianGiaoDuKien) { this.thoiGianGiaoDuKien = thoiGianGiaoDuKien; }

    // Đơn đặt qua trang Thymeleaf cũ (/orders/place) hoặc địa chỉ chưa có Phường chuẩn hoá thì
    // không có tuỳ chọn giao hàng nào được chọn -> 3 cột trên để NULL. Mọi chỗ ghép câu cho
    // khách đọc (thông báo, mail) phải dùng 2 getter dưới đây, nếu không sẽ in ra chuỗi "null"
    // giữa câu: "đã bàn giao cho null, dự kiến giao null".
    public String getNhanTuyChonGiaoHangHienThi() {
        return nhanTuyChonGiaoHang == null || nhanTuyChonGiaoHang.isBlank()
                ? "đơn vị vận chuyển của CNTTShop"
                : nhanTuyChonGiaoHang;
    }

    public String getThoiGianGiaoDuKienHienThi() {
        return thoiGianGiaoDuKien == null || thoiGianGiaoDuKien.isBlank()
                ? "trong 3-5 ngày tới"
                : thoiGianGiaoDuKien;
    }

    public BigDecimal getViDoGiao() { return viDoGiao; }
    public void setViDoGiao(BigDecimal viDoGiao) { this.viDoGiao = viDoGiao; }

    public BigDecimal getKinhDoGiao() { return kinhDoGiao; }
    public void setKinhDoGiao(BigDecimal kinhDoGiao) { this.kinhDoGiao = kinhDoGiao; }

    public BigDecimal getKhoangCachGiaoKm() { return khoangCachGiaoKm; }
    public void setKhoangCachGiaoKm(BigDecimal khoangCachGiaoKm) { this.khoangCachGiaoKm = khoangCachGiaoKm; }

    public String getMaVanDonNgoai() { return maVanDonNgoai; }
    public void setMaVanDonNgoai(String maVanDonNgoai) { this.maVanDonNgoai = maVanDonNgoai; }

    public String getAfterShipTrackingId() { return afterShipTrackingId; }
    public void setAfterShipTrackingId(String afterShipTrackingId) { this.afterShipTrackingId = afterShipTrackingId; }

    public Integer getTradeInCreditId() { return tradeInCreditId; }
    public void setTradeInCreditId(Integer tradeInCreditId) { this.tradeInCreditId = tradeInCreditId; }

    public BigDecimal getTienThuCu() { return tienThuCu; }
    public void setTienThuCu(BigDecimal tienThuCu) { this.tienThuCu = tienThuCu; }

    public BigDecimal getTongTien() { return tongTien; }
    public void setTongTien(BigDecimal tongTien) { this.tongTien = tongTien; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<OrderItem> getChiTiet() { return chiTiet; }
    public void setChiTiet(List<OrderItem> chiTiet) { this.chiTiet = chiTiet; }

    public List<OrderStatusLog> getLichSuTrangThai() { return lichSuTrangThai; }
    public void setLichSuTrangThai(List<OrderStatusLog> lichSuTrangThai) { this.lichSuTrangThai = lichSuTrangThai; }
}