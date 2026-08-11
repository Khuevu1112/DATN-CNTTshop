-- ============================================================
--  MIGRATION: thêm c?t version cho PRODUCT_VARIANT
--  (ph?c v? @Version trong entity ProductVariant.java — ch?ng 2
--  admin ghi ?è d? li?u c?a nhau khi cùng s?a 1 s?n ph?m)
--
--  L?U Ý: KHÔNG c?n thêm UNIQUE cho c?t sku — database ShopDB
--  hi?n t?i ?ã có s?n:
--    - UNIQUE constraint (UQ__PRODUCT___...) trên PRODUCT_VARIANT.sku
--    - Index IX_Variant_SKU trên PRODUCT_VARIANT.sku
--  Vi?c thêm @Column(unique = true) trong entity Java là an toàn
--  (Hibernate ? ch? ?? validate không ki?m tra l?i constraint này).
--
--  An toàn ch?y 1 l?n.
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('PRODUCT_VARIANT') AND name = 'version'
)
BEGIN
    ALTER TABLE PRODUCT_VARIANT
    ADD version INT NOT NULL DEFAULT 0;
END
GO

PRINT N'? ?ã thêm c?t version cho PRODUCT_VARIANT.';
GO