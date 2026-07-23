-- ============================================================
-- 35_restore_vnpay.sql
-- Khôi phục VNPay làm phương thức thanh toán song song với Stripe (theo yêu cầu) — chỉ bật
-- lại mã 'vnpay' gốc, giữ 'vnpay_card' tắt vì Stripe đã đảm nhiệm Visa/Mastercard rồi, bật lại
-- cả 2 sẽ trùng lặp lựa chọn "thẻ quốc tế" một cách khó hiểu cho khách.
-- ============================================================
USE ShopDB;
GO

UPDATE PAYMENT_METHOD SET is_active = 1 WHERE code = 'vnpay';
GO
