-- ============================================================
-- 37_wallet_simplify_xu.sql
-- Bỏ ví nạp tiền thật (token vàng qua Stripe) theo yêu cầu — chỉ giữ 1 loại "Xu CT" duy nhất
-- (kiếm được khi mua hàng, dùng đổi coupon/quà hoặc giảm thẳng vào bill lúc thanh toán).
-- ============================================================
USE ShopDB;
GO

IF EXISTS (SELECT 1 FROM sysobjects WHERE name='WALLET_TOPUP' AND xtype='U')
BEGIN
    DROP TABLE WALLET_TOPUP;
END
GO

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WALLET' AND COLUMN_NAME='gold_balance')
BEGIN
    -- Xoá default constraint (nếu có) trước khi bỏ cột, SQL Server không cho DROP COLUMN
    -- thẳng khi cột đang có ràng buộc DEFAULT gắn kèm.
    DECLARE @cname NVARCHAR(200);
    SELECT @cname = dc.name
    FROM sys.default_constraints dc
    JOIN sys.columns c ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
    WHERE dc.parent_object_id = OBJECT_ID('WALLET') AND c.name = 'gold_balance';

    IF @cname IS NOT NULL
        EXEC('ALTER TABLE WALLET DROP CONSTRAINT [' + @cname + ']');

    ALTER TABLE WALLET DROP COLUMN gold_balance;
END
GO

-- gold_balance đã bỏ nên các giao dịch token_type='gold' cũ (nếu có, từ lúc test nạp ví) chỉ
-- còn giá trị lịch sử — không xoá WALLET_TRANSACTION để giữ nguyên sổ giao dịch, chỉ không còn
-- ai tạo thêm dòng loại 'gold' nữa (xem WalletService).
