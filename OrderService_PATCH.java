// ============================================================
//  PATCH cho OrderService.java
// ============================================================

// BƯỚC 1: Thêm @Autowired ở đầu class (cùng chỗ các @Autowired hiện có)
// ---------------------------------------------------------------
@Autowired private AfterShipApiService afterShipApiService;

// BƯỚC 2: Thêm method mới — GỌI TỪ ADMIN CONTROLLER khi admin điền mã vận đơn
//          và bấm "Bàn giao cho hãng vận chuyển"
// ---------------------------------------------------------------
// Đặt method này cạnh datCapNhatTrangThaiDon() hiện có. KHÔNG thay đổi
// datCapNhatTrangThaiDon() — tách riêng vì "bàn giao mã vận đơn" và "đổi trạng thái đơn"
// là 2 hành động khác nhau về mặt nghiệp vụ (admin có thể đổi trạng thái mà không qua hãng
// ngoài, VD đơn nội thành Hải Phòng do xe shop tự giao).

    /**
     * Admin nhập mã vận đơn (order_code GHN, hoặc tracking_number Shopee Express) sau khi đã
     * bàn giao hàng vật lý cho hãng — gọi ở trang admin/orders khi bấm "Bàn giao vận chuyển".
     *
     * Với Shopee Express: tự động tạo tracking trên AfterShip ngay lúc này, lưu lại
     * afterShipTrackingId để các lần gọi API sau (get/update/delete) dùng đúng id nội bộ.
     *
     * Với GHN: chỉ cần lưu order_code, KHÔNG cần gọi API tạo gì thêm — API "lấy chi tiết đơn"
     * dùng thẳng order_code này (xem GhnApiService.layChiTietDon).
     *
     * Với GHTK/Viettel Post: docs bạn gửi không có API tracking, nên chỉ lưu mã để admin xem
     * thủ công trên trang quản lý của hãng đó — không tạo tracking tự động gì ở bước này.
     */
    public void banGiaoVanChuyen(Integer orderId, String maVanDonNgoai) {
        Order order = orderRepo.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));

        if (order.laDonTaiQuay()) {
            throw new RuntimeException("Đơn bán tại quầy không có bước bàn giao vận chuyển");
        }
        if (maVanDonNgoai == null || maVanDonNgoai.isBlank()) {
            throw new RuntimeException("Vui lòng nhập mã vận đơn");
        }

        order.setMaVanDonNgoai(maVanDonNgoai.trim());

        String carrierCode = order.getMaTuyChonGiaoHang();
        if ("spx".equalsIgnoreCase(carrierCode) || "shopee_express".equalsIgnoreCase(carrierCode)) {
            afterShipApiService.taoTracking(maVanDonNgoai.trim(), order.getMaDonHang())
                    .ifPresentOrElse(
                            tracking -> order.setAfterShipTrackingId(tracking.id()),
                            () -> {
                                // Không throw — mã vận đơn vẫn lưu được, chỉ là chưa tạo tracking
                                // tự động. Admin có thể thử lại sau (AfterShip có thể đang lỗi tạm thời).
                                // Log đã có sẵn trong AfterShipApiService.taoTracking().
                            }
                    );
        }

        orderRepo.save(order);
    }

// GHI CHÚ: nếu OrderService của bạn có sẵn 1 method tương tự đổi trạng thái sang "shipped",
// có thể gọi banGiaoVanChuyen() ngay trong đó thay vì tạo endpoint admin riêng — tuỳ luồng
// UI admin hiện tại của bạn (mình không có đủ context OrderStatusLog / admin controller để
// quyết định thay bạn).
