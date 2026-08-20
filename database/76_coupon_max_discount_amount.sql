-- ============================================================
-- 76_coupon_max_discount_amount.sql
-- Bổ sung cấu hình "Giảm tối đa" (max discount amount) cho mã giảm giá.
-- Chỉ có ý nghĩa với coupon discount_type = 'percent': giới hạn số tiền
-- giảm tối đa, tránh đơn hàng lớn bị giảm quá sâu khi giảm theo %.
-- NULL = không giới hạn (giữ nguyên hành vi cũ cho các mã đã có).
-- An toàn chạy 1 lần.
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('COUPON') AND name = 'max_discount_amount'
)
BEGIN
    ALTER TABLE COUPON
    ADD max_discount_amount DECIMAL(18, 2) NULL;
END
GO

PRINT N'✅ Đã thêm cột max_discount_amount cho COUPON.';
GO
