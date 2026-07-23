-- ============================================================
-- 39_coupon_xu_redeem.sql
-- Đổi thưởng bằng xu lấy coupon giờ dùng THẲNG coupon admin tự tạo ở trang Quản lý mã giảm
-- giá (không random mã nữa) — xem RedemptionService. Nhiều người cùng đổi 1 coupon thì dùng
-- chung mã, giới hạn theo max_uses admin đặt (đã có sẵn).
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='COUPON' AND COLUMN_NAME='xu_cost')
BEGIN
    -- NULL = coupon thường (không đổi được bằng xu); có giá trị = giá xu để "mở khoá" mã này
    -- trên trang khuyến mãi.
    ALTER TABLE COUPON ADD xu_cost INT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WALLET_TRANSACTION' AND COLUMN_NAME='ref_coupon_id')
BEGIN
    ALTER TABLE WALLET_TRANSACTION ADD ref_coupon_id INT NULL REFERENCES COUPON(id);
END
GO

-- 8 mức "đổi mã giảm giá cố định %" cũ (đã tắt is_active=0 ở migration 38) không còn dùng nữa
-- vì catalog coupon giờ lấy thẳng từ bảng COUPON — xoá hẳn (không có giao dịch/đơn hàng nào
-- tham chiếu tới các dòng này nên xoá an toàn, không phải chỉ ẩn).
DELETE FROM REDEMPTION_ITEM WHERE type = 'coupon';
GO
