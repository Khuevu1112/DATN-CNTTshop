-- ============================================================
-- 70_coupon_reminder.sql
-- Cot danh dau "da nhac sap het han" cho tung luot doi coupon (moi luot doi = 1 giao dich vi
-- type='redeem' tro toi 1 COUPON). Coupon la ma dung chung nen khong the danh dau tren COUPON;
-- danh dau tren WALLET_TRANSACTION moi la per-(user, coupon). Job chay dinh ky (xem
-- RedemptionService.nhacCouponSapHetHan) doc cot nay de khong gui nhac trung.
--
-- ASCII thuan, chay: sqlcmd -f 65001 -i "D:\...\70_coupon_reminder.sql"
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME='WALLET_TRANSACTION' AND COLUMN_NAME='coupon_reminder_sent')
BEGIN
    ALTER TABLE WALLET_TRANSACTION ADD coupon_reminder_sent BIT NOT NULL DEFAULT 0;
END
GO
