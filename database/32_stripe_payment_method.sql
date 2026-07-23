-- ============================================================
-- 32_stripe_payment_method.sql
-- Bỏ hẳn VNPay (vnpay, vnpay_card) khỏi lựa chọn — không dùng sandbox VNPay nữa theo yêu
-- cầu mới, thay bằng cổng Stripe Checkout thật (test mode). Momo giữ nguyên trạng thái đã
-- tắt từ trước (31_payment_methods_update.sql). Không xoá hẳn các dòng cũ vì đơn hàng lịch
-- sử vẫn còn tham chiếu (FK PAYMENT.payment_method_id).
-- ============================================================
USE ShopDB;
GO

UPDATE PAYMENT_METHOD SET is_active = 0 WHERE code IN ('vnpay', 'vnpay_card');
GO

IF NOT EXISTS (SELECT 1 FROM PAYMENT_METHOD WHERE code = 'stripe_card')
BEGIN
    INSERT INTO PAYMENT_METHOD (name, code, is_active)
    VALUES (N'Thẻ quốc tế Visa/Mastercard (Stripe)', 'stripe_card', 1);
END
GO
