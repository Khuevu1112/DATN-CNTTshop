-- ============================================================
-- 81_order_address_snapshot.sql
-- CHỤP LẠI địa chỉ nhận hàng vào chính đơn hàng.
--
-- Vì sao: ORDER.address_id là FK trỏ tới USER_ADDRESS, nên khách bấm "Xoá địa chỉ" trong sổ
-- địa chỉ mà địa chỉ đó đã từng dùng để đặt đơn thì DB chặn bằng lỗi ràng buộc khoá ngoại —
-- người dùng chỉ thấy "Xoá địa chỉ thất bại" không rõ lý do và vĩnh viễn không xoá được.
-- Ngoài ra khách SỬA địa chỉ cũ cũng làm mọi đơn cũ đổi theo, lịch sử đơn không còn trung thực.
--
-- Cách xử lý: giống cách ORDER_ITEM lưu product_name/unit_price và ORDER lưu
-- shipping_option_label/delivery_lat — chụp lại phần text của địa chỉ tại thời điểm đặt đơn.
-- Từ đó xoá địa chỉ chỉ cần gỡ address_id về NULL (xem AddressService.xoa), đơn cũ vẫn hiển
-- thị đúng nơi đã giao.
--
-- Đơn bán tại quầy (channel='pos') không có địa chỉ giao -> cả 3 cột để NULL.
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='ORDER' AND COLUMN_NAME='receiver_name')
BEGIN
    ALTER TABLE [ORDER] ADD receiver_name NVARCHAR(255) NULL;
END
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='ORDER' AND COLUMN_NAME='receiver_phone')
BEGIN
    ALTER TABLE [ORDER] ADD receiver_phone NVARCHAR(30) NULL;
END
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='ORDER' AND COLUMN_NAME='shipping_address')
BEGIN
    ALTER TABLE [ORDER] ADD shipping_address NVARCHAR(500) NULL;
END
GO

-- Backfill đơn cũ từ địa chỉ đang trỏ tới (ghép chuỗi y hệt UserAddress.getDiaChiDayDu()).
UPDATE o
SET o.receiver_name  = a.receiver_name,
    o.receiver_phone = a.phone,
    o.shipping_address = a.[address]
        + ISNULL(N', ' + a.ward, N'')
        + ISNULL(N', ' + a.district, N'')
        + ISNULL(N', ' + a.province, N'')
FROM [ORDER] o
JOIN USER_ADDRESS a ON a.id = o.address_id
WHERE o.shipping_address IS NULL;
GO
