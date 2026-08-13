-- ============================================================
-- 80_tracking_ghn_aftership.sql
-- Mo rong tracking cho GHN va Shopee Express (qua AfterShip). Viettel Post/GHTK chua co API
-- tracking rieng nen khong can cot gi them cho 2 hang nay o day.
--
-- ASCII thuan, chay: sqlcmd -f 65001 -i "D:\...\80_tracking_ghn_aftership.sql"
-- ============================================================
USE ShopDB;
GO

-- Ma van don ngoai (order_code GHN / tracking_number Shopee Express) — admin dien tay luc ban
-- giao don cho hang, khong co luc dat hang nen de NULL duoc.
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('[ORDER]') AND name = 'external_tracking_number'
)
BEGIN
    ALTER TABLE [ORDER] ADD external_tracking_number NVARCHAR(100) NULL;
END
GO

-- Id tracking noi bo cua AfterShip (khac external_tracking_number — do la ma khach nhin thay,
-- day la id can de goi lai API get/update/delete/retrack).
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('[ORDER]') AND name = 'aftership_tracking_id'
)
BEGIN
    ALTER TABLE [ORDER] ADD aftership_tracking_id NVARCHAR(100) NULL;
END
GO

PRINT N'80_tracking_ghn_aftership.sql: da bo sung external_tracking_number, aftership_tracking_id cho [ORDER].';
GO
