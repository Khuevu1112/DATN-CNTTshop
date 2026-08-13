// ============================================================
//  PATCH cho Order.java — thêm 3 field, không sửa gì khác
// ============================================================

// Thêm vào class Order, sau field khoangCachGiaoKm:

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

    public String getMaVanDonNgoai() { return maVanDonNgoai; }
    public void setMaVanDonNgoai(String maVanDonNgoai) { this.maVanDonNgoai = maVanDonNgoai; }

    public String getAfterShipTrackingId() { return afterShipTrackingId; }
    public void setAfterShipTrackingId(String afterShipTrackingId) { this.afterShipTrackingId = afterShipTrackingId; }
