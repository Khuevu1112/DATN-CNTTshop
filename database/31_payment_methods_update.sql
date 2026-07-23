-- ============================================================
-- 31_payment_methods_update.sql
-- Bỏ MoMo (chưa tích hợp cổng thật, chỉ ẩn khỏi lựa chọn — không xoá hẳn vì đã có đơn
-- hàng cũ tham chiếu tới), bổ sung Visa/Thẻ quốc tế — dùng chung cổng VNPay (VNPay đã hỗ
-- trợ sẵn Visa/Master/JCB ngay trên trang thanh toán của họ), code bắt đầu bằng "vnpay"
-- để backend tự nhận diện và xử lý giống hệt luồng VNPay hiện có (xem OrderService.laCongVnpay).
-- ============================================================
USE ShopDB;
GO

UPDATE PAYMENT_METHOD SET is_active = 0 WHERE code = 'momo';
GO

IF NOT EXISTS (SELECT 1 FROM PAYMENT_METHOD WHERE code = 'vnpay_card')
BEGIN
    INSERT INTO PAYMENT_METHOD (name, code, is_active)
    VALUES (N'Thẻ quốc tế Visa/Mastercard/JCB', 'vnpay_card', 1);
END
GO
