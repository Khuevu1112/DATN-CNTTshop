-- ============================================================
-- 12_manual_products_snapshot.sql
-- Chốt lại 3 sản phẩm được nhập tay trực tiếp vào DB (id 1,4,5 trên máy đang chạy,
-- không qua script nào) để toàn bộ chain (01 -> 12) tái lập đúng dữ liệu hiện tại
-- khi setup DB mới. (Lenovo LOQ 15 đã có sẵn từ 05_sample_variants.sql, không lặp lại.)
-- Idempotent: bỏ qua nếu sản phẩm đã tồn tại (theo slug).
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-gaming-i5-rtx5060')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, is_active)
    VALUES (N'PC Gaming I5 RTX5060', 'pc-gaming-i5-rtx5060', N'GGG',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'), 1);
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (SCOPE_IDENTITY(), 'SKU-1', 150000000, 1000000, 1, 1);
END

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-gaming')
BEGIN
    INSERT INTO PRODUCT (name, slug, category_id, is_active)
    VALUES (N'PC Gaming', 'pc-gaming',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'), 1);
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (SCOPE_IDENTITY(), 'SKU-4', 45000000, 40000000, 1, 1);
END

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'msi-thin-13uc')
BEGIN
    INSERT INTO PRODUCT (name, slug, category_id, is_active)
    VALUES (N'MSI Thin 13UC', 'msi-thin-13uc',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'), 1);
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (SCOPE_IDENTITY(), 'SKU-5', 23000000, 20000000, 1, 1);
END

GO
