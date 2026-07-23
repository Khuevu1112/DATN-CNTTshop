-- ============================================================
-- 20_payment.sql
-- Bổ sung cột proof_image cho PAYMENT (chuyển khoản ngân hàng - khách
-- upload ảnh biên lai để admin đối soát), và sửa lỗi encoding tiếng Việt
-- của PAYMENT_METHOD bị hỏng từ migration gốc (01_DATNCNTTSHOP.sql).
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'PAYMENT' AND COLUMN_NAME = 'proof_image'
)
BEGIN
    ALTER TABLE PAYMENT ADD proof_image NVARCHAR(255) NULL;
    PRINT N'Da them cot proof_image vao PAYMENT';
END
GO

UPDATE PAYMENT_METHOD SET name = N'Thanh toán khi nhận hàng (COD)' WHERE code = 'cod';
UPDATE PAYMENT_METHOD SET name = N'Chuyển khoản ngân hàng' WHERE code = 'banking';
GO

-- CHECK constraint gốc (01_DATNCNTTSHOP.sql) thiếu giá trị 'waiting_verify'
-- (trạng thái chờ admin đối soát biên lai chuyển khoản) -> thay bằng constraint có tên rõ ràng.
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name LIKE 'CK__PAYMENT__status%')
BEGIN
    DECLARE @cname NVARCHAR(200) = (SELECT TOP 1 name FROM sys.check_constraints WHERE name LIKE 'CK__PAYMENT__status%');
    EXEC('ALTER TABLE PAYMENT DROP CONSTRAINT [' + @cname + ']');
END
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Payment_Status')
BEGIN
    ALTER TABLE PAYMENT ADD CONSTRAINT CK_Payment_Status
        CHECK (status IN ('pending', 'paid', 'failed', 'refunded', 'waiting_verify'));
END
GO
