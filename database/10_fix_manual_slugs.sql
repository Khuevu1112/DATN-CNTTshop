-- ============================================================
-- 10_fix_manual_slugs.sql
-- Chuẩn hoá slug cho các sản phẩm được nhập tay trực tiếp (không qua seed script),
-- bị viết hoa + dính khoảng trắng/gạch dưới (không đúng định dạng kebab-case),
-- khiến slug không nhất quán với phần còn lại của catalog.
-- ============================================================
USE ShopDB;
GO

UPDATE PRODUCT SET slug = 'pc-gaming-i5-rtx5060' WHERE id = 1 AND slug = 'PCGaming I5 RTX5060';
UPDATE PRODUCT SET slug = 'pc-gaming'            WHERE id = 4 AND slug = 'PC_GAMING';
UPDATE PRODUCT SET slug = 'msi-thin-13uc'        WHERE id = 5 AND slug = 'LAPTOP_MSI';
GO
