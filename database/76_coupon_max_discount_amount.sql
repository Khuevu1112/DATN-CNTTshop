-- ============================================================
-- 76_coupon_max_discount_amount.sql
-- B? sung c?u hình "Gi?m t?i ?a" (max discount amount) cho mã gi?m giá.
-- Ch? có ý ngh?a v?i coupon discount_type = 'percent': gi?i h?n s? ti?n
-- gi?m t?i ?a, tránh ??n hàng l?n b? gi?m quá sâu khi gi?m theo %.
-- NULL = không gi?i h?n (gi? nguyên hành vi c? cho các mã ?ã có).
-- An toàn ch?y 1 l?n.
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

PRINT N'? ?ã thêm c?t max_discount_amount cho COUPON.';
GO
