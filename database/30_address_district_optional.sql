-- ============================================================
-- 30_address_district_optional.sql
-- Bỏ Quận/Huyện khỏi form địa chỉ (checkout + Quản lý tài khoản) — cho phép NULL để
-- không chặn insert/update khi frontend không còn thu thập trường này.
-- ============================================================
USE ShopDB;
GO

ALTER TABLE USER_ADDRESS ALTER COLUMN district NVARCHAR(100) NULL;
GO
