-- ============================================================
-- 59_address_geo_pin.sql
-- Cắm mốc bản đồ cho địa chỉ giao hàng:
--   - USER_ADDRESS.latitude/longitude: toạ độ khách tự cắm trên bản đồ khi tạo/sửa địa chỉ.
--     NULL với địa chỉ cũ tạo trước tính năng này -> luồng tính phí ship phải có nhánh dự
--     phòng (xem ShippingService.tuyChonHaiPhong).
--   - ORDER.delivery_lat/delivery_lng: CHỤP LẠI toạ độ tại thời điểm đặt đơn. Không đọc ngược
--     qua FK address_id lúc hiển thị vì khách có thể sửa/xoá địa chỉ sau khi đặt, khi đó toạ độ
--     admin nhìn thấy sẽ không còn là nơi thực sự phải giao đơn đó.
--   - ORDER.shipping_distance_km: quãng đường đã dùng để tính phí, lưu lại để admin đối chiếu
--     được vì sao đơn này thu ngần đó tiền ship (xem ShippingService.phiTheoKhoangCach).
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='USER_ADDRESS' AND COLUMN_NAME='latitude')
BEGIN
    ALTER TABLE USER_ADDRESS ADD latitude DECIMAL(10,7) NULL;
END
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='USER_ADDRESS' AND COLUMN_NAME='longitude')
BEGIN
    ALTER TABLE USER_ADDRESS ADD longitude DECIMAL(10,7) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='ORDER' AND COLUMN_NAME='delivery_lat')
BEGIN
    ALTER TABLE [ORDER] ADD delivery_lat DECIMAL(10,7) NULL;
END
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='ORDER' AND COLUMN_NAME='delivery_lng')
BEGIN
    ALTER TABLE [ORDER] ADD delivery_lng DECIMAL(10,7) NULL;
END
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='ORDER' AND COLUMN_NAME='shipping_distance_km')
BEGIN
    ALTER TABLE [ORDER] ADD shipping_distance_km DECIMAL(8,2) NULL;
END
GO
