-- ============================================================
-- 41_user_address_province_ward.sql
-- Thêm province_id/ward_id (FK, nullable) vào USER_ADDRESS cho luồng chọn địa chỉ bằng dropdown
-- ở cnttshop-vue (xem AddressApiController/AddressService). CỘT TEXT CŨ (province/district/ward)
-- GIỮ NGUYÊN không đổi — trang Thymeleaf legacy (/account/addresses, order/checkout.html) vẫn
-- dùng nguyên các cột text này, không đụng tới. Địa chỉ tạo qua Vue sẽ ghi đồng thời cả
-- province_id/ward_id (chuẩn) lẫn cột text (để hiển thị/tương thích ngược không cần sửa gì).
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='USER_ADDRESS' AND COLUMN_NAME='province_id')
BEGIN
    ALTER TABLE USER_ADDRESS ADD province_id INT NULL REFERENCES PROVINCE(id);
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='USER_ADDRESS' AND COLUMN_NAME='ward_id')
BEGIN
    ALTER TABLE USER_ADDRESS ADD ward_id INT NULL REFERENCES WARD(id);
END
GO

-- Best-effort khớp dữ liệu địa chỉ cũ (chủ yếu là dữ liệu test) theo tên chính xác — hàng nào
-- không khớp được (viết tắt/không dấu/tên giả lập lúc test) sẽ giữ province_id/ward_id = NULL,
-- vẫn hiển thị bình thường qua cột text cũ, người dùng chỉ cần sửa lại địa chỉ qua dropdown mới.
UPDATE ua
SET ua.ward_id = w.id, ua.province_id = w.province_id
FROM USER_ADDRESS ua
JOIN WARD w ON w.name = ua.ward
JOIN PROVINCE p ON p.id = w.province_id AND p.name = ua.province
WHERE ua.ward_id IS NULL;
GO
