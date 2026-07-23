-- ============================================================
-- 27_bulk_products_3.sql
-- Bo sung ~400 san pham moi nua, gia theo tier rieng cho tung nhom.
-- File duoc sinh tu dong (xem scratchpad/gen_products3.js).
-- ============================================================
USE ShopDB;
GO

-- ===== Thuong hieu bo sung =====
INSERT INTO BRAND (name)
SELECT v.name FROM (VALUES
    (N'ADATA'),
    (N'PNY'),
    (N'Silicon Power'),
    (N'Zotac'),
    (N'Sapphire'),
    (N'Thermaltake'),
    (N'Xigmatek'),
    (N'Rapoo'),
    (N'E-Dra'),
    (N'Fractal Design')
) AS v(name)
WHERE NOT EXISTS (SELECT 1 FROM BRAND b WHERE b.name = v.name);
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i3-10100f-901')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i3-10100F', 'cpu-intel-core-i3-10100f-901', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p901 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p901, 'CPU-INTEL-CORE-I3-10100F-901', 1900000, NULL, 38, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p901, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i3-10100F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p901, N'Socket', N'LGA1200', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p901, N'Xung nhịp', N'3.6GHz - 4.3GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p901, N'Số nhân/luồng', N'4 nhân / 8 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i3-11100f-902')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i3-11100F', 'cpu-intel-core-i3-11100f-902', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p902 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p902, 'CPU-INTEL-CORE-I3-11100F-902', 2100000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p902, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i3-11100F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p902, N'Socket', N'LGA1200', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p902, N'Xung nhịp', N'3.6GHz - 4.3GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p902, N'Số nhân/luồng', N'4 nhân / 8 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-3-3100-903')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 3 3100', 'cpu-amd-ryzen-3-3100-903', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p903 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p903, 'CPU-AMD-RYZEN-3-3100-903', 1800000, NULL, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p903, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%203%203100', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p903, N'Socket', N'AM4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p903, N'Xung nhịp', N'3.6GHz - 3.9GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p903, N'Số nhân/luồng', N'4 nhân / 8 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-5-3600-904')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 5 3600', 'cpu-amd-ryzen-5-3600-904', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p904 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p904, 'CPU-AMD-RYZEN-5-3600-904', 2500000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p904, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%205%203600', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p904, N'Socket', N'AM4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p904, N'Xung nhịp', N'3.6GHz - 4.2GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p904, N'Số nhân/luồng', N'6 nhân / 12 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i5-10400f-905')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i5-10400F', 'cpu-intel-core-i5-10400f-905', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p905 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p905, 'CPU-INTEL-CORE-I5-10400F-905', 2900000, NULL, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p905, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i5-10400F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p905, N'Socket', N'LGA1200', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p905, N'Xung nhịp', N'2.9GHz - 4.3GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p905, N'Số nhân/luồng', N'6 nhân / 12 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i5-11400f-906')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i5-11400F', 'cpu-intel-core-i5-11400f-906', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p906 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p906, 'CPU-INTEL-CORE-I5-11400F-906', 3200000, NULL, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p906, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i5-11400F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p906, N'Socket', N'LGA1200', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p906, N'Xung nhịp', N'2.6GHz - 4.4GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p906, N'Số nhân/luồng', N'6 nhân / 12 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-5-5600x-907')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 5 5600X', 'cpu-amd-ryzen-5-5600x-907', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p907 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p907, 'CPU-AMD-RYZEN-5-5600X-907', 3400000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p907, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%205%205600X', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p907, N'Socket', N'AM4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p907, N'Xung nhịp', N'3.7GHz - 4.6GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p907, N'Số nhân/luồng', N'6 nhân / 12 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i5-12490f-908')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i5-12490F', 'cpu-intel-core-i5-12490f-908', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p908 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p908, 'CPU-INTEL-CORE-I5-12490F-908', 3900000, 4212000, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p908, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i5-12490F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p908, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p908, N'Xung nhịp', N'3.0GHz - 4.6GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p908, N'Số nhân/luồng', N'6 nhân / 12 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-5-7500f-909')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 5 7500F', 'cpu-amd-ryzen-5-7500f-909', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p909 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p909, 'CPU-AMD-RYZEN-5-7500F-909', 4300000, 4945000, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p909, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%205%207500F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p909, N'Socket', N'AM5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p909, N'Xung nhịp', N'3.7GHz - 5.0GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p909, N'Số nhân/luồng', N'6 nhân / 12 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i5-14500-910')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i5-14500', 'cpu-intel-core-i5-14500-910', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p910 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p910, 'CPU-INTEL-CORE-I5-14500-910', 5200000, NULL, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p910, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i5-14500', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p910, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p910, N'Xung nhịp', N'2.6GHz - 5.0GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p910, N'Số nhân/luồng', N'14 nhân / 20 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-7-5800x-911')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 7 5800X', 'cpu-amd-ryzen-7-5800x-911', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p911 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p911, 'CPU-AMD-RYZEN-7-5800X-911', 5800000, 6496000, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p911, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%207%205800X', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p911, N'Socket', N'AM4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p911, N'Xung nhịp', N'3.8GHz - 4.7GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p911, N'Số nhân/luồng', N'8 nhân / 16 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i7-11700f-912')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i7-11700F', 'cpu-intel-core-i7-11700f-912', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p912 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p912, 'CPU-INTEL-CORE-I7-11700F-912', 6000000, 6540000, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p912, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i7-11700F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p912, N'Socket', N'LGA1200', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p912, N'Xung nhịp', N'2.5GHz - 4.9GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p912, N'Số nhân/luồng', N'8 nhân / 16 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-7-5800x3d-913')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 7 5800X3D', 'cpu-amd-ryzen-7-5800x3d-913', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p913 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p913, 'CPU-AMD-RYZEN-7-5800X3D-913', 7500000, NULL, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p913, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%207%205800X3D', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p913, N'Socket', N'AM4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p913, N'Xung nhịp', N'3.4GHz - 4.5GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p913, N'Số nhân/luồng', N'8 nhân / 16 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i7-14700-914')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i7-14700', 'cpu-intel-core-i7-14700-914', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p914 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p914, 'CPU-INTEL-CORE-I7-14700-914', 9200000, 9844000, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p914, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i7-14700', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p914, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p914, N'Xung nhịp', N'2.1GHz - 5.4GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p914, N'Số nhân/luồng', N'20 nhân / 28 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-9-5900x-915')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 9 5900X', 'cpu-amd-ryzen-9-5900x-915', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p915 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p915, 'CPU-AMD-RYZEN-9-5900X-915', 8900000, 9968000, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p915, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%209%205900X', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p915, N'Socket', N'AM4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p915, N'Xung nhịp', N'3.7GHz - 4.8GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p915, N'Số nhân/luồng', N'12 nhân / 24 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-9-5950x-916')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 9 5950X', 'cpu-amd-ryzen-9-5950x-916', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p916 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p916, 'CPU-AMD-RYZEN-9-5950X-916', 11500000, 12535000, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p916, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%209%205950X', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p916, N'Socket', N'AM4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p916, N'Xung nhịp', N'3.4GHz - 4.9GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p916, N'Số nhân/luồng', N'16 nhân / 32 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i9-14900kf-917')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i9-14900KF', 'cpu-intel-core-i9-14900kf-917', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p917 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p917, 'CPU-INTEL-CORE-I9-14900KF-917', 13800000, NULL, 21, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p917, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i9-14900KF', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p917, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p917, N'Xung nhịp', N'3.2GHz - 6.0GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p917, N'Số nhân/luồng', N'24 nhân / 32 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-9-7950x3d-918')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 9 7950X3D', 'cpu-amd-ryzen-9-7950x3d-918', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p918 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p918, 'CPU-AMD-RYZEN-9-7950X3D-918', 15900000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p918, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%209%207950X3D', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p918, N'Socket', N'AM5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p918, N'Xung nhịp', N'4.2GHz - 5.7GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p918, N'Số nhân/luồng', N'16 nhân / 32 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i9-14900ks-919')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i9-14900KS', 'cpu-intel-core-i9-14900ks-919', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p919 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p919, 'CPU-INTEL-CORE-I9-14900KS-919', 17500000, NULL, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p919, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i9-14900KS', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p919, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p919, N'Xung nhịp', N'3.2GHz - 6.2GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p919, N'Số nhân/luồng', N'24 nhân / 32 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i3-13100-920')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i3-13100', 'cpu-intel-core-i3-13100-920', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p920 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p920, 'CPU-INTEL-CORE-I3-13100-920', 2600000, NULL, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p920, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i3-13100', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p920, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p920, N'Xung nhịp', N'3.4GHz - 4.5GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p920, N'Số nhân/luồng', N'4 nhân / 8 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-5-4600g-921')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 5 4600G', 'cpu-amd-ryzen-5-4600g-921', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p921 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p921, 'CPU-AMD-RYZEN-5-4600G-921', 2300000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p921, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%205%204600G', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p921, N'Socket', N'AM4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p921, N'Xung nhịp', N'3.7GHz - 4.2GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p921, N'Số nhân/luồng', N'6 nhân / 12 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i5-11600k-922')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i5-11600K', 'cpu-intel-core-i5-11600k-922', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p922 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p922, 'CPU-INTEL-CORE-I5-11600K-922', 4100000, 4633000, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p922, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i5-11600K', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p922, N'Socket', N'LGA1200', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p922, N'Xung nhịp', N'3.9GHz - 4.9GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p922, N'Số nhân/luồng', N'6 nhân / 12 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-7-7700-923')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 7 7700', 'cpu-amd-ryzen-7-7700-923', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p923 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p923, 'CPU-AMD-RYZEN-7-7700-923', 7300000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p923, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%207%207700', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p923, N'Socket', N'AM5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p923, N'Xung nhịp', N'3.8GHz - 5.3GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p923, N'Số nhân/luồng', N'8 nhân / 16 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i7-12700k-924')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i7-12700K', 'cpu-intel-core-i7-12700k-924', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p924 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p924, 'CPU-INTEL-CORE-I7-12700K-924', 7900000, NULL, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p924, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i7-12700K', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p924, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p924, N'Xung nhịp', N'3.6GHz - 5.0GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p924, N'Số nhân/luồng', N'12 nhân / 20 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i9-12900k-925')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i9-12900K', 'cpu-intel-core-i9-12900k-925', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p925 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p925, 'CPU-INTEL-CORE-I9-12900K-925', 10900000, 11663000, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p925, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i9-12900K', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p925, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p925, N'Xung nhịp', N'3.2GHz - 5.2GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p925, N'Số nhân/luồng', N'16 nhân / 24 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-9-9950x-926')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 9 9950X', 'cpu-amd-ryzen-9-9950x-926', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p926 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p926, 'CPU-AMD-RYZEN-9-9950X-926', 16800000, NULL, 40, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p926, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%209%209950X', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p926, N'Socket', N'AM5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p926, N'Xung nhịp', N'4.3GHz - 5.7GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p926, N'Số nhân/luồng', N'16 nhân / 32 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i5-13600k-927')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i5-13600K', 'cpu-intel-core-i5-13600k-927', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p927 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p927, 'CPU-INTEL-CORE-I5-13600K-927', 7600000, NULL, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p927, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i5-13600K', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p927, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p927, N'Xung nhịp', N'3.5GHz - 5.1GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p927, N'Số nhân/luồng', N'14 nhân / 20 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-5-9600x-928')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 5 9600X', 'cpu-amd-ryzen-5-9600x-928', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p928 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p928, 'CPU-AMD-RYZEN-5-9600X-928', 6100000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p928, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%205%209600X', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p928, N'Socket', N'AM5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p928, N'Xung nhịp', N'3.9GHz - 5.4GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p928, N'Số nhân/luồng', N'6 nhân / 12 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i7-13700-929')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i7-13700', 'cpu-intel-core-i7-13700-929', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p929 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p929, 'CPU-INTEL-CORE-I7-13700-929', 8600000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p929, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i7-13700', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p929, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p929, N'Xung nhịp', N'2.1GHz - 5.2GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p929, N'Số nhân/luồng', N'16 nhân / 24 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-7-9700x-930')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 7 9700X', 'cpu-amd-ryzen-7-9700x-930', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p930 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p930, 'CPU-AMD-RYZEN-7-9700X-930', 8300000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p930, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%207%209700X', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p930, N'Socket', N'AM5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p930, N'Xung nhịp', N'3.8GHz - 5.5GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p930, N'Số nhân/luồng', N'8 nhân / 16 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i3-9100f-931')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i3-9100F', 'cpu-intel-core-i3-9100f-931', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p931 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p931, 'CPU-INTEL-CORE-I3-9100F-931', 1700000, NULL, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p931, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i3-9100F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p931, N'Socket', N'LGA1151', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p931, N'Xung nhịp', N'3.6GHz - 4.2GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p931, N'Số nhân/luồng', N'4 nhân / 4 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-3-3300x-932')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 3 3300X', 'cpu-amd-ryzen-3-3300x-932', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p932 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p932, 'CPU-AMD-RYZEN-3-3300X-932', 2000000, 2120000, 38, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p932, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%203%203300X', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p932, N'Socket', N'AM4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p932, N'Xung nhịp', N'3.8GHz - 4.3GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p932, N'Số nhân/luồng', N'4 nhân / 8 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i5-9400f-933')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i5-9400F', 'cpu-intel-core-i5-9400f-933', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p933 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p933, 'CPU-INTEL-CORE-I5-9400F-933', 2400000, 2664000, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p933, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i5-9400F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p933, N'Socket', N'LGA1151', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p933, N'Xung nhịp', N'2.9GHz - 4.1GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p933, N'Số nhân/luồng', N'6 nhân / 6 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-5-2600-934')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 5 2600', 'cpu-amd-ryzen-5-2600-934', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p934 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p934, 'CPU-AMD-RYZEN-5-2600-934', 1950000, NULL, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p934, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%205%202600', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p934, N'Socket', N'AM4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p934, N'Xung nhịp', N'3.4GHz - 3.9GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p934, N'Số nhân/luồng', N'6 nhân / 12 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i7-9700f-935')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i7-9700F', 'cpu-intel-core-i7-9700f-935', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p935 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p935, 'CPU-INTEL-CORE-I7-9700F-935', 4300000, NULL, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p935, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i7-9700F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p935, N'Socket', N'LGA1151', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p935, N'Xung nhịp', N'3.0GHz - 4.7GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p935, N'Số nhân/luồng', N'8 nhân / 8 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-prime-h610m-e-936')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASUS Prime H610M-E', 'mainboard-asus-prime-h610m-e-936', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p936 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p936, 'MAINBOARD-ASUS-PRIME-H610M-E-936', 1450000, NULL, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p936, 'https://placehold.co/400x400?text=Mainboard%20ASUS%20Prime%20H610M-E', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p936, N'Chipset', N'H610', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p936, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p936, N'RAM hỗ trợ', N'DDR4 tối đa 64GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-msi-pro-h610m-g-937')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard MSI PRO H610M-G', 'mainboard-msi-pro-h610m-g-937', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p937 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p937, 'MAINBOARD-MSI-PRO-H610M-G-937', 1500000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p937, 'https://placehold.co/400x400?text=Mainboard%20MSI%20PRO%20H610M-G', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p937, N'Chipset', N'H610', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p937, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p937, N'RAM hỗ trợ', N'DDR4 tối đa 64GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-gigabyte-a520m-k-938')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Gigabyte A520M K', 'mainboard-gigabyte-a520m-k-938', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p938 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p938, 'MAINBOARD-GIGABYTE-A520M-K-938', 1250000, NULL, 24, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p938, 'https://placehold.co/400x400?text=Mainboard%20Gigabyte%20A520M%20K', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p938, N'Chipset', N'A520', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p938, N'Socket', N'AM4', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p938, N'RAM hỗ trợ', N'DDR4 tối đa 64GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asrock-a320m-hdv-939')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASRock A320M-HDV', 'mainboard-asrock-a320m-hdv-939', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASRock'), 1, GETDATE());
    DECLARE @p939 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p939, 'MAINBOARD-ASROCK-A320M-HDV-939', 1150000, 1242000, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p939, 'https://placehold.co/400x400?text=Mainboard%20ASRock%20A320M-HDV', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p939, N'Chipset', N'A320', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p939, N'Socket', N'AM4', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p939, N'RAM hỗ trợ', N'DDR4 tối đa 32GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-prime-b660m-a-940')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASUS Prime B660M-A', 'mainboard-asus-prime-b660m-a-940', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p940 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p940, 'MAINBOARD-ASUS-PRIME-B660M-A-940', 2900000, 3190000, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p940, 'https://placehold.co/400x400?text=Mainboard%20ASUS%20Prime%20B660M-A', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p940, N'Chipset', N'B660', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p940, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p940, N'RAM hỗ trợ', N'DDR4 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-msi-pro-b660m-a-941')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard MSI PRO B660M-A', 'mainboard-msi-pro-b660m-a-941', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p941 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p941, 'MAINBOARD-MSI-PRO-B660M-A-941', 2850000, 3249000, 21, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p941, 'https://placehold.co/400x400?text=Mainboard%20MSI%20PRO%20B660M-A', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p941, N'Chipset', N'B660', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p941, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p941, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-gigabyte-b660m-ds3h-942')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Gigabyte B660M DS3H', 'mainboard-gigabyte-b660m-ds3h-942', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p942 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p942, 'MAINBOARD-GIGABYTE-B660M-DS3H-942', 2700000, NULL, 14, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p942, 'https://placehold.co/400x400?text=Mainboard%20Gigabyte%20B660M%20DS3H', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p942, N'Chipset', N'B660', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p942, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p942, N'RAM hỗ trợ', N'DDR4 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asrock-b550m-pro4-943')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASRock B550M Pro4', 'mainboard-asrock-b550m-pro4-943', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASRock'), 1, GETDATE());
    DECLARE @p943 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p943, 'MAINBOARD-ASROCK-B550M-PRO4-943', 2100000, 2394000, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p943, 'https://placehold.co/400x400?text=Mainboard%20ASRock%20B550M%20Pro4', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p943, N'Chipset', N'B550', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p943, N'Socket', N'AM4', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p943, N'RAM hỗ trợ', N'DDR4 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-tuf-gaming-b550-plus-944')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASUS TUF Gaming B550-Plus', 'mainboard-asus-tuf-gaming-b550-plus-944', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p944 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p944, 'MAINBOARD-ASUS-TUF-GAMING-B550-PLUS-944', 3200000, 3392000, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p944, 'https://placehold.co/400x400?text=Mainboard%20ASUS%20TUF%20Gaming%20B550', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p944, N'Chipset', N'B550', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p944, N'Socket', N'AM4', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p944, N'RAM hỗ trợ', N'DDR4 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-msi-mag-b550-tomahawk-945')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard MSI MAG B550 Tomahawk', 'mainboard-msi-mag-b550-tomahawk-945', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p945 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p945, 'MAINBOARD-MSI-MAG-B550-TOMAHAWK-945', 3400000, NULL, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p945, 'https://placehold.co/400x400?text=Mainboard%20MSI%20MAG%20B550%20Tomahaw', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p945, N'Chipset', N'B550', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p945, N'Socket', N'AM4', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p945, N'RAM hỗ trợ', N'DDR4 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-gigabyte-b650m-gaming-x-946')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Gigabyte B650M Gaming X', 'mainboard-gigabyte-b650m-gaming-x-946', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p946 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p946, 'MAINBOARD-GIGABYTE-B650M-GAMING-X-946', 3300000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p946, 'https://placehold.co/400x400?text=Mainboard%20Gigabyte%20B650M%20Gamin', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p946, N'Chipset', N'B650', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p946, N'Socket', N'AM5', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p946, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-tuf-gaming-b650-plus-947')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASUS TUF Gaming B650-Plus', 'mainboard-asus-tuf-gaming-b650-plus-947', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p947 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p947, 'MAINBOARD-ASUS-TUF-GAMING-B650-PLUS-947', 4200000, 4746000, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p947, 'https://placehold.co/400x400?text=Mainboard%20ASUS%20TUF%20Gaming%20B650', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p947, N'Chipset', N'B650', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p947, N'Socket', N'AM5', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p947, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-msi-mag-b650-tomahawk-948')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard MSI MAG B650 Tomahawk', 'mainboard-msi-mag-b650-tomahawk-948', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p948 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p948, 'MAINBOARD-MSI-MAG-B650-TOMAHAWK-948', 4500000, NULL, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p948, 'https://placehold.co/400x400?text=Mainboard%20MSI%20MAG%20B650%20Tomahaw', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p948, N'Chipset', N'B650', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p948, N'Socket', N'AM5', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p948, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asrock-b760m-pro-rs-949')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASRock B760M Pro RS', 'mainboard-asrock-b760m-pro-rs-949', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASRock'), 1, GETDATE());
    DECLARE @p949 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p949, 'MAINBOARD-ASROCK-B760M-PRO-RS-949', 2900000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p949, 'https://placehold.co/400x400?text=Mainboard%20ASRock%20B760M%20Pro%20RS', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p949, N'Chipset', N'B760', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p949, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p949, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-gigabyte-b760m-aorus-elite-950')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Gigabyte B760M Aorus Elite', 'mainboard-gigabyte-b760m-aorus-elite-950', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p950 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p950, 'MAINBOARD-GIGABYTE-B760M-AORUS-ELITE-950', 3900000, NULL, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p950, 'https://placehold.co/400x400?text=Mainboard%20Gigabyte%20B760M%20Aorus', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p950, N'Chipset', N'B760', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p950, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p950, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-rog-strix-b760-a-951')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASUS ROG Strix B760-A', 'mainboard-asus-rog-strix-b760-a-951', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p951 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p951, 'MAINBOARD-ASUS-ROG-STRIX-B760-A-951', 5500000, NULL, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p951, 'https://placehold.co/400x400?text=Mainboard%20ASUS%20ROG%20Strix%20B760-', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p951, N'Chipset', N'B760', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p951, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p951, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-msi-mpg-x570-gaming-plus-952')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard MSI MPG X570 Gaming Plus', 'mainboard-msi-mpg-x570-gaming-plus-952', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p952 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p952, 'MAINBOARD-MSI-MPG-X570-GAMING-PLUS-952', 4200000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p952, 'https://placehold.co/400x400?text=Mainboard%20MSI%20MPG%20X570%20Gaming%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p952, N'Chipset', N'X570', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p952, N'Socket', N'AM4', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p952, N'RAM hỗ trợ', N'DDR4 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-gigabyte-x570-aorus-elite-953')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Gigabyte X570 Aorus Elite', 'mainboard-gigabyte-x570-aorus-elite-953', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p953 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p953, 'MAINBOARD-GIGABYTE-X570-AORUS-ELITE-953', 4800000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p953, 'https://placehold.co/400x400?text=Mainboard%20Gigabyte%20X570%20Aorus%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p953, N'Chipset', N'X570', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p953, N'Socket', N'AM4', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p953, N'RAM hỗ trợ', N'DDR4 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-rog-strix-z690-a-954')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASUS ROG Strix Z690-A', 'mainboard-asus-rog-strix-z690-a-954', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p954 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p954, 'MAINBOARD-ASUS-ROG-STRIX-Z690-A-954', 8200000, NULL, 30, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p954, 'https://placehold.co/400x400?text=Mainboard%20ASUS%20ROG%20Strix%20Z690-', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p954, N'Chipset', N'Z690', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p954, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p954, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-msi-mpg-z690-edge-955')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard MSI MPG Z690 Edge', 'mainboard-msi-mpg-z690-edge-955', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p955 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p955, 'MAINBOARD-MSI-MPG-Z690-EDGE-955', 7800000, NULL, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p955, 'https://placehold.co/400x400?text=Mainboard%20MSI%20MPG%20Z690%20Edge', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p955, N'Chipset', N'Z690', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p955, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p955, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-gigabyte-x670-aorus-elite-956')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Gigabyte X670 Aorus Elite', 'mainboard-gigabyte-x670-aorus-elite-956', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p956 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p956, 'MAINBOARD-GIGABYTE-X670-AORUS-ELITE-956', 6900000, NULL, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p956, 'https://placehold.co/400x400?text=Mainboard%20Gigabyte%20X670%20Aorus%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p956, N'Chipset', N'X670', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p956, N'Socket', N'AM5', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p956, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asrock-x670e-pro-rs-957')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASRock X670E Pro RS', 'mainboard-asrock-x670e-pro-rs-957', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASRock'), 1, GETDATE());
    DECLARE @p957 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p957, 'MAINBOARD-ASROCK-X670E-PRO-RS-957', 7200000, 7920000, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p957, 'https://placehold.co/400x400?text=Mainboard%20ASRock%20X670E%20Pro%20RS', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p957, N'Chipset', N'X670E', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p957, N'Socket', N'AM5', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p957, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-rog-strix-z790-e-958')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASUS ROG Strix Z790-E', 'mainboard-asus-rog-strix-z790-e-958', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p958 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p958, 'MAINBOARD-ASUS-ROG-STRIX-Z790-E-958', 11500000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p958, 'https://placehold.co/400x400?text=Mainboard%20ASUS%20ROG%20Strix%20Z790-', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p958, N'Chipset', N'Z790', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p958, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p958, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-msi-meg-z790-ace-959')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard MSI MEG Z790 Ace', 'mainboard-msi-meg-z790-ace-959', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p959 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p959, 'MAINBOARD-MSI-MEG-Z790-ACE-959', 14500000, NULL, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p959, 'https://placehold.co/400x400?text=Mainboard%20MSI%20MEG%20Z790%20Ace', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p959, N'Chipset', N'Z790', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p959, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p959, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-gigabyte-x870e-aorus-master-960')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Gigabyte X870E Aorus Master', 'mainboard-gigabyte-x870e-aorus-master-960', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p960 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p960, 'MAINBOARD-GIGABYTE-X870E-AORUS-MASTER-960', 13800000, NULL, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p960, 'https://placehold.co/400x400?text=Mainboard%20Gigabyte%20X870E%20Aorus', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p960, N'Chipset', N'X870E', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p960, N'Socket', N'AM5', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p960, N'RAM hỗ trợ', N'DDR5 tối đa 256GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-prime-b450m-a-961')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASUS Prime B450M-A', 'mainboard-asus-prime-b450m-a-961', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p961 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p961, 'MAINBOARD-ASUS-PRIME-B450M-A-961', 1550000, NULL, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p961, 'https://placehold.co/400x400?text=Mainboard%20ASUS%20Prime%20B450M-A', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p961, N'Chipset', N'B450', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p961, N'Socket', N'AM4', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p961, N'RAM hỗ trợ', N'DDR4 tối đa 64GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asrock-h510m-hvs-962')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASRock H510M-HVS', 'mainboard-asrock-h510m-hvs-962', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASRock'), 1, GETDATE());
    DECLARE @p962 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p962, 'MAINBOARD-ASROCK-H510M-HVS-962', 1350000, 1499000, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p962, 'https://placehold.co/400x400?text=Mainboard%20ASRock%20H510M-HVS', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p962, N'Chipset', N'H510', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p962, N'Socket', N'LGA1200', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p962, N'RAM hỗ trợ', N'DDR4 tối đa 64GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-gigabyte-h510m-h-963')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Gigabyte H510M H', 'mainboard-gigabyte-h510m-h-963', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p963 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p963, 'MAINBOARD-GIGABYTE-H510M-H-963', 1300000, 1495000, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p963, 'https://placehold.co/400x400?text=Mainboard%20Gigabyte%20H510M%20H', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p963, N'Chipset', N'H510', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p963, N'Socket', N'LGA1200', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p963, N'RAM hỗ trợ', N'DDR4 tối đa 64GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-prime-h310m-e-964')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASUS Prime H310M-E', 'mainboard-asus-prime-h310m-e-964', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p964 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p964, 'MAINBOARD-ASUS-PRIME-H310M-E-964', 1050000, 1176000, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p964, 'https://placehold.co/400x400?text=Mainboard%20ASUS%20Prime%20H310M-E', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p964, N'Chipset', N'H310', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p964, N'Socket', N'LGA1151', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p964, N'RAM hỗ trợ', N'DDR4 tối đa 32GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-gigabyte-b360m-ds3h-965')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Gigabyte B360M DS3H', 'mainboard-gigabyte-b360m-ds3h-965', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p965 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p965, 'MAINBOARD-GIGABYTE-B360M-DS3H-965', 1650000, 1864000, 24, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p965, 'https://placehold.co/400x400?text=Mainboard%20Gigabyte%20B360M%20DS3H', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p965, N'Chipset', N'B360', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p965, N'Socket', N'LGA1151', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p965, N'RAM hỗ trợ', N'DDR4 tối đa 64GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asrock-a420m-hdv-966')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASRock A420M-HDV', 'mainboard-asrock-a420m-hdv-966', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASRock'), 1, GETDATE());
    DECLARE @p966 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p966, 'MAINBOARD-ASROCK-A420M-HDV-966', 1050000, 1113000, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p966, 'https://placehold.co/400x400?text=Mainboard%20ASRock%20A420M-HDV', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p966, N'Chipset', N'A420', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p966, N'Socket', N'AM4', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p966, N'RAM hỗ trợ', N'DDR4 tối đa 32GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-msi-mpg-z590-gaming-edge-967')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard MSI MPG Z590 Gaming Edge', 'mainboard-msi-mpg-z590-gaming-edge-967', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p967 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p967, 'MAINBOARD-MSI-MPG-Z590-GAMING-EDGE-967', 5900000, 6195000, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p967, 'https://placehold.co/400x400?text=Mainboard%20MSI%20MPG%20Z590%20Gaming%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p967, N'Chipset', N'Z590', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p967, N'Socket', N'LGA1200', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p967, N'RAM hỗ trợ', N'DDR4 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-prime-b560m-a-968')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASUS Prime B560M-A', 'mainboard-asus-prime-b560m-a-968', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p968 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p968, 'MAINBOARD-ASUS-PRIME-B560M-A-968', 2400000, NULL, 40, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p968, 'https://placehold.co/400x400?text=Mainboard%20ASUS%20Prime%20B560M-A', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p968, N'Chipset', N'B560', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p968, N'Socket', N'LGA1200', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p968, N'RAM hỗ trợ', N'DDR4 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-gigabyte-b560m-aorus-pro-969')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Gigabyte B560M Aorus Pro', 'mainboard-gigabyte-b560m-aorus-pro-969', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p969 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p969, 'MAINBOARD-GIGABYTE-B560M-AORUS-PRO-969', 2750000, NULL, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p969, 'https://placehold.co/400x400?text=Mainboard%20Gigabyte%20B560M%20Aorus', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p969, N'Chipset', N'B560', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p969, N'Socket', N'LGA1200', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p969, N'RAM hỗ trợ', N'DDR4 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-adata-xpg-gammix-d10-8gb-ddr4-970')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM ADATA XPG Gammix D10 8GB DDR4', 'ram-adata-xpg-gammix-d10-8gb-ddr4-970', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'ADATA'), 1, GETDATE());
    DECLARE @p970 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p970, 'RAM-ADATA-XPG-GAMMIX-D10-8GB-DDR4-970', 480000, 523000, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p970, 'https://placehold.co/400x400?text=RAM%20ADATA%20XPG%20Gammix%20D10%208GB%20D', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p970, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p970, N'Bus', N'3000 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p970, N'Dung lượng', N'8GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-silicon-power-8gb-ddr4-971')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Silicon Power 8GB DDR4', 'ram-silicon-power-8gb-ddr4-971', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Silicon Power'), 1, GETDATE());
    DECLARE @p971 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p971, 'RAM-SILICON-POWER-8GB-DDR4-971', 460000, 524000, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p971, 'https://placehold.co/400x400?text=RAM%20Silicon%20Power%208GB%20DDR4', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p971, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p971, N'Bus', N'2666 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p971, N'Dung lượng', N'8GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-pny-performance-8gb-ddr4-972')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM PNY Performance 8GB DDR4', 'ram-pny-performance-8gb-ddr4-972', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'PNY'), 1, GETDATE());
    DECLARE @p972 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p972, 'RAM-PNY-PERFORMANCE-8GB-DDR4-972', 470000, 517000, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p972, 'https://placehold.co/400x400?text=RAM%20PNY%20Performance%208GB%20DDR4', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p972, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p972, N'Bus', N'3200 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p972, N'Dung lượng', N'8GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-kingston-valueram-16gb-ddr4-973')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Kingston ValueRAM 16GB DDR4', 'ram-kingston-valueram-16gb-ddr4-973', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p973 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p973, 'RAM-KINGSTON-VALUERAM-16GB-DDR4-973', 850000, NULL, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p973, 'https://placehold.co/400x400?text=RAM%20Kingston%20ValueRAM%2016GB%20DDR', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p973, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p973, N'Bus', N'2666 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p973, N'Dung lượng', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-adata-xpg-gammix-d10-16gb-ddr4-974')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM ADATA XPG Gammix D10 16GB DDR4', 'ram-adata-xpg-gammix-d10-16gb-ddr4-974', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'ADATA'), 1, GETDATE());
    DECLARE @p974 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p974, 'RAM-ADATA-XPG-GAMMIX-D10-16GB-DDR4-974', 900000, 1035000, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p974, 'https://placehold.co/400x400?text=RAM%20ADATA%20XPG%20Gammix%20D10%2016GB%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p974, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p974, N'Bus', N'3200 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p974, N'Dung lượng', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-corsair-vengeance-lpx-16gb-ddr4-975')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Corsair Vengeance LPX 16GB DDR4', 'ram-corsair-vengeance-lpx-16gb-ddr4-975', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p975 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p975, 'RAM-CORSAIR-VENGEANCE-LPX-16GB-DDR4-975', 980000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p975, 'https://placehold.co/400x400?text=RAM%20Corsair%20Vengeance%20LPX%2016GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p975, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p975, N'Bus', N'3200 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p975, N'Dung lượng', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-samsung-standard-16gb-ddr4-976')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Samsung Standard 16GB DDR4', 'ram-samsung-standard-16gb-ddr4-976', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p976 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p976, 'RAM-SAMSUNG-STANDARD-16GB-DDR4-976', 870000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p976, 'https://placehold.co/400x400?text=RAM%20Samsung%20Standard%2016GB%20DDR4', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p976, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p976, N'Bus', N'2666 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p976, N'Dung lượng', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-silicon-power-16gb-ddr4-977')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Silicon Power 16GB DDR4', 'ram-silicon-power-16gb-ddr4-977', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Silicon Power'), 1, GETDATE());
    DECLARE @p977 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p977, 'RAM-SILICON-POWER-16GB-DDR4-977', 890000, 952000, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p977, 'https://placehold.co/400x400?text=RAM%20Silicon%20Power%2016GB%20DDR4', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p977, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p977, N'Bus', N'3200 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p977, N'Dung lượng', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-g-skill-aegis-16gb-ddr4-978')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM G.Skill Aegis 16GB DDR4', 'ram-g-skill-aegis-16gb-ddr4-978', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'G.Skill'), 1, GETDATE());
    DECLARE @p978 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p978, 'RAM-G-SKILL-AEGIS-16GB-DDR4-978', 920000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p978, 'https://placehold.co/400x400?text=RAM%20G.Skill%20Aegis%2016GB%20DDR4', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p978, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p978, N'Bus', N'3200 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p978, N'Dung lượng', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-kingston-fury-renegade-32gb-ddr4-979')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Kingston Fury Renegade 32GB DDR4', 'ram-kingston-fury-renegade-32gb-ddr4-979', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p979 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p979, 'RAM-KINGSTON-FURY-RENEGADE-32GB-DDR4-979', 1850000, NULL, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p979, 'https://placehold.co/400x400?text=RAM%20Kingston%20Fury%20Renegade%2032G', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p979, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p979, N'Bus', N'3600 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p979, N'Dung lượng', N'32GB (2x16GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-adata-xpg-lancer-32gb-ddr5-980')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM ADATA XPG Lancer 32GB DDR5', 'ram-adata-xpg-lancer-32gb-ddr5-980', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'ADATA'), 1, GETDATE());
    DECLARE @p980 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p980, 'RAM-ADATA-XPG-LANCER-32GB-DDR5-980', 2300000, NULL, 31, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p980, 'https://placehold.co/400x400?text=RAM%20ADATA%20XPG%20Lancer%2032GB%20DDR5', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p980, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p980, N'Bus', N'6000 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p980, N'Dung lượng', N'32GB (2x16GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-corsair-dominator-platinum-rgb-32gb-ddr5-981')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Corsair Dominator Platinum RGB 32GB DDR5', 'ram-corsair-dominator-platinum-rgb-32gb-ddr5-981', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p981 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p981, 'RAM-CORSAIR-DOMINATOR-PLATINUM-RGB-32GB--981', 3100000, 3255000, 30, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p981, 'https://placehold.co/400x400?text=RAM%20Corsair%20Dominator%20Platinum', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p981, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p981, N'Bus', N'6200 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p981, N'Dung lượng', N'32GB (2x16GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-kingston-fury-beast-rgb-32gb-ddr5-982')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Kingston Fury Beast RGB 32GB DDR5', 'ram-kingston-fury-beast-rgb-32gb-ddr5-982', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p982 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p982, 'RAM-KINGSTON-FURY-BEAST-RGB-32GB-DDR5-982', 2500000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p982, 'https://placehold.co/400x400?text=RAM%20Kingston%20Fury%20Beast%20RGB%2032', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p982, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p982, N'Bus', N'6000 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p982, N'Dung lượng', N'32GB (2x16GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-g-skill-ripjaws-s5-32gb-ddr5-983')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM G.Skill Ripjaws S5 32GB DDR5', 'ram-g-skill-ripjaws-s5-32gb-ddr5-983', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'G.Skill'), 1, GETDATE());
    DECLARE @p983 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p983, 'RAM-G-SKILL-RIPJAWS-S5-32GB-DDR5-983', 2350000, 2585000, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p983, 'https://placehold.co/400x400?text=RAM%20G.Skill%20Ripjaws%20S5%2032GB%20DD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p983, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p983, N'Bus', N'5600 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p983, N'Dung lượng', N'32GB (2x16GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-samsung-32gb-ddr4-984')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Samsung 32GB DDR4', 'ram-samsung-32gb-ddr4-984', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p984 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p984, 'RAM-SAMSUNG-32GB-DDR4-984', 1750000, NULL, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p984, 'https://placehold.co/400x400?text=RAM%20Samsung%2032GB%20DDR4', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p984, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p984, N'Bus', N'3200 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p984, N'Dung lượng', N'32GB (2x16GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-silicon-power-xpower-32gb-ddr4-985')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Silicon Power XPOWER 32GB DDR4', 'ram-silicon-power-xpower-32gb-ddr4-985', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Silicon Power'), 1, GETDATE());
    DECLARE @p985 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p985, 'RAM-SILICON-POWER-XPOWER-32GB-DDR4-985', 1800000, NULL, 14, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p985, 'https://placehold.co/400x400?text=RAM%20Silicon%20Power%20XPOWER%2032GB%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p985, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p985, N'Bus', N'3600 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p985, N'Dung lượng', N'32GB (2x16GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-pny-xlr8-32gb-ddr5-986')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM PNY XLR8 32GB DDR5', 'ram-pny-xlr8-32gb-ddr5-986', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'PNY'), 1, GETDATE());
    DECLARE @p986 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p986, 'RAM-PNY-XLR8-32GB-DDR5-986', 2400000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p986, 'https://placehold.co/400x400?text=RAM%20PNY%20XLR8%2032GB%20DDR5', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p986, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p986, N'Bus', N'6000 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p986, N'Dung lượng', N'32GB (2x16GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-corsair-vengeance-48gb-ddr5-987')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Corsair Vengeance 48GB DDR5', 'ram-corsair-vengeance-48gb-ddr5-987', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p987 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p987, 'RAM-CORSAIR-VENGEANCE-48GB-DDR5-987', 3400000, NULL, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p987, 'https://placehold.co/400x400?text=RAM%20Corsair%20Vengeance%2048GB%20DDR', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p987, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p987, N'Bus', N'6000 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p987, N'Dung lượng', N'48GB (2x24GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-kingston-fury-beast-48gb-ddr5-988')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Kingston Fury Beast 48GB DDR5', 'ram-kingston-fury-beast-48gb-ddr5-988', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p988 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p988, 'RAM-KINGSTON-FURY-BEAST-48GB-DDR5-988', 3300000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p988, 'https://placehold.co/400x400?text=RAM%20Kingston%20Fury%20Beast%2048GB%20D', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p988, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p988, N'Bus', N'5600 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p988, N'Dung lượng', N'48GB (2x24GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-g-skill-trident-z5-neo-64gb-ddr5-989')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM G.Skill Trident Z5 Neo 64GB DDR5', 'ram-g-skill-trident-z5-neo-64gb-ddr5-989', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'G.Skill'), 1, GETDATE());
    DECLARE @p989 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p989, 'RAM-G-SKILL-TRIDENT-Z5-NEO-64GB-DDR5-989', 5300000, 5671000, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p989, 'https://placehold.co/400x400?text=RAM%20G.Skill%20Trident%20Z5%20Neo%2064G', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p989, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p989, N'Bus', N'6000 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p989, N'Dung lượng', N'64GB (2x32GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-corsair-vengeance-rgb-64gb-ddr5-990')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Corsair Vengeance RGB 64GB DDR5', 'ram-corsair-vengeance-rgb-64gb-ddr5-990', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p990 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p990, 'RAM-CORSAIR-VENGEANCE-RGB-64GB-DDR5-990', 5600000, NULL, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p990, 'https://placehold.co/400x400?text=RAM%20Corsair%20Vengeance%20RGB%2064GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p990, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p990, N'Bus', N'6000 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p990, N'Dung lượng', N'64GB (2x32GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-adata-xpg-lancer-64gb-ddr5-991')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM ADATA XPG Lancer 64GB DDR5', 'ram-adata-xpg-lancer-64gb-ddr5-991', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'ADATA'), 1, GETDATE());
    DECLARE @p991 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p991, 'RAM-ADATA-XPG-LANCER-64GB-DDR5-991', 5200000, NULL, 38, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p991, 'https://placehold.co/400x400?text=RAM%20ADATA%20XPG%20Lancer%2064GB%20DDR5', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p991, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p991, N'Bus', N'5600 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p991, N'Dung lượng', N'64GB (2x32GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-kingston-valueram-64gb-ddr4-992')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Kingston ValueRAM 64GB DDR4', 'ram-kingston-valueram-64gb-ddr4-992', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p992 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p992, 'RAM-KINGSTON-VALUERAM-64GB-DDR4-992', 3600000, NULL, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p992, 'https://placehold.co/400x400?text=RAM%20Kingston%20ValueRAM%2064GB%20DDR', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p992, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p992, N'Bus', N'2666 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p992, N'Dung lượng', N'64GB (2x32GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-corsair-dominator-titanium-64gb-ddr5-993')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Corsair Dominator Titanium 64GB DDR5', 'ram-corsair-dominator-titanium-64gb-ddr5-993', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p993 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p993, 'RAM-CORSAIR-DOMINATOR-TITANIUM-64GB-DDR5-993', 7200000, 7632000, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p993, 'https://placehold.co/400x400?text=RAM%20Corsair%20Dominator%20Titanium', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p993, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p993, N'Bus', N'6600 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p993, N'Dung lượng', N'64GB (2x32GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-g-skill-trident-z5-rgb-96gb-ddr5-994')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM G.Skill Trident Z5 RGB 96GB DDR5', 'ram-g-skill-trident-z5-rgb-96gb-ddr5-994', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'G.Skill'), 1, GETDATE());
    DECLARE @p994 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p994, 'RAM-G-SKILL-TRIDENT-Z5-RGB-96GB-DDR5-994', 8300000, 8798000, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p994, 'https://placehold.co/400x400?text=RAM%20G.Skill%20Trident%20Z5%20RGB%2096G', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p994, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p994, N'Bus', N'6000 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p994, N'Dung lượng', N'96GB (2x48GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-kingston-fury-renegade-96gb-ddr5-995')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Kingston Fury Renegade 96GB DDR5', 'ram-kingston-fury-renegade-96gb-ddr5-995', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p995 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p995, 'RAM-KINGSTON-FURY-RENEGADE-96GB-DDR5-995', 8100000, 8991000, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p995, 'https://placehold.co/400x400?text=RAM%20Kingston%20Fury%20Renegade%2096G', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p995, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p995, N'Bus', N'6400 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p995, N'Dung lượng', N'96GB (2x48GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-silicon-power-gaming-8gb-ddr5-996')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Silicon Power Gaming 8GB DDR5', 'ram-silicon-power-gaming-8gb-ddr5-996', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Silicon Power'), 1, GETDATE());
    DECLARE @p996 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p996, 'RAM-SILICON-POWER-GAMING-8GB-DDR5-996', 950000, 998000, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p996, 'https://placehold.co/400x400?text=RAM%20Silicon%20Power%20Gaming%208GB%20D', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p996, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p996, N'Bus', N'4800 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p996, N'Dung lượng', N'8GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-adata-premier-16gb-ddr5-997')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM ADATA Premier 16GB DDR5', 'ram-adata-premier-16gb-ddr5-997', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'ADATA'), 1, GETDATE());
    DECLARE @p997 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p997, 'RAM-ADATA-PREMIER-16GB-DDR5-997', 1250000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p997, 'https://placehold.co/400x400?text=RAM%20ADATA%20Premier%2016GB%20DDR5', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p997, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p997, N'Bus', N'4800 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p997, N'Dung lượng', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-kingston-hyperx-fury-4gb-ddr3-998')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Kingston HyperX Fury 4GB DDR3', 'ram-kingston-hyperx-fury-4gb-ddr3-998', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p998 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p998, 'RAM-KINGSTON-HYPERX-FURY-4GB-DDR3-998', 280000, 322000, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p998, 'https://placehold.co/400x400?text=RAM%20Kingston%20HyperX%20Fury%204GB%20D', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p998, N'Chuẩn', N'DDR3', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p998, N'Bus', N'1600 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p998, N'Dung lượng', N'4GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-corsair-vengeance-8gb-ddr3-999')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Corsair Vengeance 8GB DDR3', 'ram-corsair-vengeance-8gb-ddr3-999', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p999 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p999, 'RAM-CORSAIR-VENGEANCE-8GB-DDR3-999', 320000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p999, 'https://placehold.co/400x400?text=RAM%20Corsair%20Vengeance%208GB%20DDR3', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p999, N'Chuẩn', N'DDR3', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p999, N'Bus', N'1866 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p999, N'Dung lượng', N'8GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-g-skill-aegis-8gb-ddr4-1000')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM G.Skill Aegis 8GB DDR4', 'ram-g-skill-aegis-8gb-ddr4-1000', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'G.Skill'), 1, GETDATE());
    DECLARE @p1000 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1000, 'RAM-G-SKILL-AEGIS-8GB-DDR4-1000', 500000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1000, 'https://placehold.co/400x400?text=RAM%20G.Skill%20Aegis%208GB%20DDR4', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1000, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1000, N'Bus', N'3000 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1000, N'Dung lượng', N'8GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-pny-performance-16gb-ddr4-1001')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM PNY Performance 16GB DDR4', 'ram-pny-performance-16gb-ddr4-1001', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'PNY'), 1, GETDATE());
    DECLARE @p1001 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1001, 'RAM-PNY-PERFORMANCE-16GB-DDR4-1001', 880000, 977000, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1001, 'https://placehold.co/400x400?text=RAM%20PNY%20Performance%2016GB%20DDR4', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1001, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1001, N'Bus', N'3200 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1001, N'Dung lượng', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-silicon-power-gaming-32gb-ddr5-1002')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Silicon Power Gaming 32GB DDR5', 'ram-silicon-power-gaming-32gb-ddr5-1002', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Silicon Power'), 1, GETDATE());
    DECLARE @p1002 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1002, 'RAM-SILICON-POWER-GAMING-32GB-DDR5-1002', 2250000, NULL, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1002, 'https://placehold.co/400x400?text=RAM%20Silicon%20Power%20Gaming%2032GB%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1002, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1002, N'Bus', N'5200 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1002, N'Dung lượng', N'32GB (2x16GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-kingston-fury-impact-16gb-ddr4-sodimm-1003')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Kingston Fury Impact 16GB DDR4 SODIMM', 'ram-kingston-fury-impact-16gb-ddr4-sodimm-1003', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p1003 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1003, 'RAM-KINGSTON-FURY-IMPACT-16GB-DDR4-SODIM-1003', 1050000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1003, 'https://placehold.co/400x400?text=RAM%20Kingston%20Fury%20Impact%2016GB%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1003, N'Chuẩn', N'DDR4 SODIMM', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1003, N'Bus', N'3200 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1003, N'Dung lượng', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-msi-ventus-gt-1030-1004')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa MSI Ventus GT 1030', 'card-do-hoa-msi-ventus-gt-1030-1004', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1004 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1004, 'CARD-H-A-MSI-VENTUS-GT-1030-1004', 2200000, NULL, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1004, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20MSI%20Ventus%20GT%201030', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1004, N'Chip đồ họa', N'NVIDIA GT 1030', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1004, N'VRAM', N'2GB GDDR5', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1004, N'Giao tiếp', N'PCIe 3.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-zotac-twin-edge-gtx-1650-1005')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Zotac Twin Edge GTX 1650', 'card-do-hoa-zotac-twin-edge-gtx-1650-1005', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Zotac'), 1, GETDATE());
    DECLARE @p1005 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1005, 'CARD-H-A-ZOTAC-TWIN-EDGE-GTX-1650-1005', 3900000, NULL, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1005, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Zotac%20Twin%20Edge%20GT', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1005, N'Chip đồ họa', N'NVIDIA GTX 1650', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1005, N'VRAM', N'4GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1005, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-sapphire-pulse-rx-6400-1006')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Sapphire Pulse RX 6400', 'card-do-hoa-sapphire-pulse-rx-6400-1006', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Sapphire'), 1, GETDATE());
    DECLARE @p1006 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1006, 'CARD-H-A-SAPPHIRE-PULSE-RX-6400-1006', 3200000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1006, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Sapphire%20Pulse%20RX%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1006, N'Chip đồ họa', N'AMD RX 6400', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1006, N'VRAM', N'4GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1006, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-sapphire-pulse-rx-6500-xt-1007')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Sapphire Pulse RX 6500 XT', 'card-do-hoa-sapphire-pulse-rx-6500-xt-1007', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Sapphire'), 1, GETDATE());
    DECLARE @p1007 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1007, 'CARD-H-A-SAPPHIRE-PULSE-RX-6500-XT-1007', 3700000, NULL, 39, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1007, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Sapphire%20Pulse%20RX%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1007, N'Chip đồ họa', N'AMD RX 6500 XT', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1007, N'VRAM', N'4GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1007, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-zotac-twin-edge-rtx-3050-1008')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Zotac Twin Edge RTX 3050', 'card-do-hoa-zotac-twin-edge-rtx-3050-1008', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Zotac'), 1, GETDATE());
    DECLARE @p1008 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1008, 'CARD-H-A-ZOTAC-TWIN-EDGE-RTX-3050-1008', 4600000, 5244000, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1008, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Zotac%20Twin%20Edge%20RT', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1008, N'Chip đồ họa', N'NVIDIA RTX 3050', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1008, N'VRAM', N'8GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1008, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-gigabyte-eagle-rx-6600-1009')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Gigabyte Eagle RX 6600', 'card-do-hoa-gigabyte-eagle-rx-6600-1009', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1009 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1009, 'CARD-H-A-GIGABYTE-EAGLE-RX-6600-1009', 5900000, 6608000, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1009, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Gigabyte%20Eagle%20RX%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1009, N'Chip đồ họa', N'AMD RX 6600', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1009, N'VRAM', N'8GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1009, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-asus-dual-rx-6600-xt-1010')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa ASUS Dual RX 6600 XT', 'card-do-hoa-asus-dual-rx-6600-xt-1010', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1010 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1010, 'CARD-H-A-ASUS-DUAL-RX-6600-XT-1010', 6500000, NULL, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1010, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20ASUS%20Dual%20RX%206600%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1010, N'Chip đồ họa', N'AMD RX 6600 XT', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1010, N'VRAM', N'8GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1010, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-msi-ventus-rtx-3060-1011')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa MSI Ventus RTX 3060', 'card-do-hoa-msi-ventus-rtx-3060-1011', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1011 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1011, 'CARD-H-A-MSI-VENTUS-RTX-3060-1011', 7900000, 9006000, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1011, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20MSI%20Ventus%20RTX%20306', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1011, N'Chip đồ họa', N'NVIDIA RTX 3060', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1011, N'VRAM', N'12GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1011, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-sapphire-pulse-rx-6650-xt-1012')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Sapphire Pulse RX 6650 XT', 'card-do-hoa-sapphire-pulse-rx-6650-xt-1012', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Sapphire'), 1, GETDATE());
    DECLARE @p1012 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1012, 'CARD-H-A-SAPPHIRE-PULSE-RX-6650-XT-1012', 7200000, NULL, 35, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1012, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Sapphire%20Pulse%20RX%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1012, N'Chip đồ họa', N'AMD RX 6650 XT', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1012, N'VRAM', N'8GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1012, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-zotac-twin-edge-rtx-3060-ti-1013')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Zotac Twin Edge RTX 3060 Ti', 'card-do-hoa-zotac-twin-edge-rtx-3060-ti-1013', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Zotac'), 1, GETDATE());
    DECLARE @p1013 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1013, 'CARD-H-A-ZOTAC-TWIN-EDGE-RTX-3060-TI-1013', 9200000, NULL, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1013, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Zotac%20Twin%20Edge%20RT', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1013, N'Chip đồ họa', N'NVIDIA RTX 3060 Ti', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1013, N'VRAM', N'8GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1013, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-asus-dual-rx-6700-xt-1014')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa ASUS Dual RX 6700 XT', 'card-do-hoa-asus-dual-rx-6700-xt-1014', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1014 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1014, 'CARD-H-A-ASUS-DUAL-RX-6700-XT-1014', 10800000, 12204000, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1014, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20ASUS%20Dual%20RX%206700%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1014, N'Chip đồ họa', N'AMD RX 6700 XT', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1014, N'VRAM', N'12GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1014, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-gigabyte-windforce-rtx-3070-1015')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Gigabyte Windforce RTX 3070', 'card-do-hoa-gigabyte-windforce-rtx-3070-1015', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1015 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1015, 'CARD-H-A-GIGABYTE-WINDFORCE-RTX-3070-1015', 12500000, 13125000, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1015, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Gigabyte%20Windforce', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1015, N'Chip đồ họa', N'NVIDIA RTX 3070', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1015, N'VRAM', N'8GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1015, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-sapphire-nitro-rx-7700-xt-1016')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Sapphire Nitro+ RX 7700 XT', 'card-do-hoa-sapphire-nitro-rx-7700-xt-1016', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Sapphire'), 1, GETDATE());
    DECLARE @p1016 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1016, 'CARD-H-A-SAPPHIRE-NITRO-RX-7700-XT-1016', 13800000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1016, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Sapphire%20Nitro%2B%20RX', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1016, N'Chip đồ họa', N'AMD RX 7700 XT', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1016, N'VRAM', N'12GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1016, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-msi-gaming-x-rtx-3070-ti-1017')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa MSI Gaming X RTX 3070 Ti', 'card-do-hoa-msi-gaming-x-rtx-3070-ti-1017', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1017 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1017, 'CARD-H-A-MSI-GAMING-X-RTX-3070-TI-1017', 15200000, NULL, 38, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1017, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20MSI%20Gaming%20X%20RTX%203', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1017, N'Chip đồ họa', N'NVIDIA RTX 3070 Ti', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1017, N'VRAM', N'8GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1017, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-sapphire-nitro-rx-7800-xt-1018')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Sapphire Nitro+ RX 7800 XT', 'card-do-hoa-sapphire-nitro-rx-7800-xt-1018', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Sapphire'), 1, GETDATE());
    DECLARE @p1018 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1018, 'CARD-H-A-SAPPHIRE-NITRO-RX-7800-XT-1018', 16500000, NULL, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1018, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Sapphire%20Nitro%2B%20RX', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1018, N'Chip đồ họa', N'AMD RX 7800 XT', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1018, N'VRAM', N'16GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1018, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-zotac-trinity-rtx-3080-1019')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Zotac Trinity RTX 3080', 'card-do-hoa-zotac-trinity-rtx-3080-1019', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Zotac'), 1, GETDATE());
    DECLARE @p1019 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1019, 'CARD-H-A-ZOTAC-TRINITY-RTX-3080-1019', 18500000, NULL, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1019, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Zotac%20Trinity%20RTX%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1019, N'Chip đồ họa', N'NVIDIA RTX 3080', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1019, N'VRAM', N'10GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1019, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-gigabyte-gaming-oc-rtx-4070-super-1020')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Gigabyte Gaming OC RTX 4070 Super', 'card-do-hoa-gigabyte-gaming-oc-rtx-4070-super-1020', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1020 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1020, 'CARD-H-A-GIGABYTE-GAMING-OC-RTX-4070-SUP-1020', 17800000, NULL, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1020, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Gigabyte%20Gaming%20OC', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1020, N'Chip đồ họa', N'NVIDIA RTX 4070 Super', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1020, N'VRAM', N'12GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1020, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-asus-tuf-rtx-4070-super-1021')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa ASUS TUF RTX 4070 Super', 'card-do-hoa-asus-tuf-rtx-4070-super-1021', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1021 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1021, 'CARD-H-A-ASUS-TUF-RTX-4070-SUPER-1021', 18500000, 21090000, 31, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1021, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20ASUS%20TUF%20RTX%204070%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1021, N'Chip đồ họa', N'NVIDIA RTX 4070 Super', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1021, N'VRAM', N'12GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1021, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-sapphire-nitro-rx-7900-xt-1022')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Sapphire Nitro+ RX 7900 XT', 'card-do-hoa-sapphire-nitro-rx-7900-xt-1022', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Sapphire'), 1, GETDATE());
    DECLARE @p1022 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1022, 'CARD-H-A-SAPPHIRE-NITRO-RX-7900-XT-1022', 22500000, NULL, 21, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1022, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Sapphire%20Nitro%2B%20RX', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1022, N'Chip đồ họa', N'AMD RX 7900 XT', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1022, N'VRAM', N'20GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1022, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-msi-suprim-rtx-4070-ti-super-1023')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa MSI Suprim RTX 4070 Ti Super', 'card-do-hoa-msi-suprim-rtx-4070-ti-super-1023', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1023 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1023, 'CARD-H-A-MSI-SUPRIM-RTX-4070-TI-SUPER-1023', 23800000, 26894000, 24, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1023, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20MSI%20Suprim%20RTX%20407', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1023, N'Chip đồ họa', N'NVIDIA RTX 4070 Ti Super', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1023, N'VRAM', N'16GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1023, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-sapphire-nitro-rx-7900-xtx-1024')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Sapphire Nitro+ RX 7900 XTX', 'card-do-hoa-sapphire-nitro-rx-7900-xtx-1024', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Sapphire'), 1, GETDATE());
    DECLARE @p1024 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1024, 'CARD-H-A-SAPPHIRE-NITRO-RX-7900-XTX-1024', 27500000, 29425000, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1024, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Sapphire%20Nitro%2B%20RX', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1024, N'Chip đồ họa', N'AMD RX 7900 XTX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1024, N'VRAM', N'24GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1024, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-gigabyte-aorus-master-rtx-4080-1025')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Gigabyte Aorus Master RTX 4080', 'card-do-hoa-gigabyte-aorus-master-rtx-4080-1025', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1025 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1025, 'CARD-H-A-GIGABYTE-AORUS-MASTER-RTX-4080-1025', 29500000, NULL, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1025, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Gigabyte%20Aorus%20Mas', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1025, N'Chip đồ họa', N'NVIDIA RTX 4080', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1025, N'VRAM', N'16GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1025, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-asus-rog-strix-rtx-4080-1026')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa ASUS ROG Strix RTX 4080', 'card-do-hoa-asus-rog-strix-rtx-4080-1026', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1026 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1026, 'CARD-H-A-ASUS-ROG-STRIX-RTX-4080-1026', 31500000, NULL, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1026, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20ASUS%20ROG%20Strix%20RTX', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1026, N'Chip đồ họa', N'NVIDIA RTX 4080', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1026, N'VRAM', N'16GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1026, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-zotac-amp-extreme-rtx-4080-super-1027')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Zotac AMP Extreme RTX 4080 Super', 'card-do-hoa-zotac-amp-extreme-rtx-4080-super-1027', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Zotac'), 1, GETDATE());
    DECLARE @p1027 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1027, 'CARD-H-A-ZOTAC-AMP-EXTREME-RTX-4080-SUPE-1027', 33500000, NULL, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1027, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Zotac%20AMP%20Extreme%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1027, N'Chip đồ họa', N'NVIDIA RTX 4080 Super', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1027, N'VRAM', N'16GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1027, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-msi-suprim-liquid-x-rtx-4090-1028')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa MSI Suprim Liquid X RTX 4090', 'card-do-hoa-msi-suprim-liquid-x-rtx-4090-1028', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1028 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1028, 'CARD-H-A-MSI-SUPRIM-LIQUID-X-RTX-4090-1028', 49500000, 55935000, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1028, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20MSI%20Suprim%20Liquid%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1028, N'Chip đồ họa', N'NVIDIA RTX 4090', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1028, N'VRAM', N'24GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1028, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-asus-rog-strix-rtx-4090-1029')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa ASUS ROG Strix RTX 4090', 'card-do-hoa-asus-rog-strix-rtx-4090-1029', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1029 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1029, 'CARD-H-A-ASUS-ROG-STRIX-RTX-4090-1029', 51500000, NULL, 30, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1029, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20ASUS%20ROG%20Strix%20RTX', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1029, N'Chip đồ họa', N'NVIDIA RTX 4090', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1029, N'VRAM', N'24GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1029, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-gigabyte-eagle-rtx-4060-1030')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Gigabyte Eagle RTX 4060', 'card-do-hoa-gigabyte-eagle-rtx-4060-1030', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1030 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1030, 'CARD-H-A-GIGABYTE-EAGLE-RTX-4060-1030', 7600000, 8284000, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1030, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Gigabyte%20Eagle%20RTX', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1030, N'Chip đồ họa', N'NVIDIA RTX 4060', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1030, N'VRAM', N'8GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1030, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-asus-dual-rtx-4070-super-1031')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa ASUS Dual RTX 4070 Super', 'card-do-hoa-asus-dual-rtx-4070-super-1031', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1031 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1031, 'CARD-H-A-ASUS-DUAL-RTX-4070-SUPER-1031', 17200000, 19780000, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1031, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20ASUS%20Dual%20RTX%204070', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1031, N'Chip đồ họa', N'NVIDIA RTX 4070 Super', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1031, N'VRAM', N'12GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1031, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-msi-ventus-rx-6500-xt-1032')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa MSI Ventus RX 6500 XT', 'card-do-hoa-msi-ventus-rx-6500-xt-1032', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1032 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1032, 'CARD-H-A-MSI-VENTUS-RX-6500-XT-1032', 3600000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1032, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20MSI%20Ventus%20RX%206500', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1032, N'Chip đồ họa', N'AMD RX 6500 XT', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1032, N'VRAM', N'4GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1032, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-gigabyte-windforce-rx-6600-xt-1033')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Gigabyte Windforce RX 6600 XT', 'card-do-hoa-gigabyte-windforce-rx-6600-xt-1033', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1033 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1033, 'CARD-H-A-GIGABYTE-WINDFORCE-RX-6600-XT-1033', 6400000, 7296000, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1033, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Gigabyte%20Windforce', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1033, N'Chip đồ họa', N'AMD RX 6600 XT', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1033, N'VRAM', N'8GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1033, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-msi-ventus-gtx-1660-super-1034')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa MSI Ventus GTX 1660 Super', 'card-do-hoa-msi-ventus-gtx-1660-super-1034', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1034 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1034, 'CARD-H-A-MSI-VENTUS-GTX-1660-SUPER-1034', 4200000, 4536000, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1034, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20MSI%20Ventus%20GTX%20166', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1034, N'Chip đồ họa', N'NVIDIA GTX 1660 Super', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1034, N'VRAM', N'6GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1034, N'Giao tiếp', N'PCIe 3.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-sapphire-pulse-rx-5600-xt-1035')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Sapphire Pulse RX 5600 XT', 'card-do-hoa-sapphire-pulse-rx-5600-xt-1035', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Sapphire'), 1, GETDATE());
    DECLARE @p1035 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1035, 'CARD-H-A-SAPPHIRE-PULSE-RX-5600-XT-1035', 4700000, NULL, 14, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1035, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Sapphire%20Pulse%20RX%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1035, N'Chip đồ họa', N'AMD RX 5600 XT', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1035, N'VRAM', N'6GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1035, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-zotac-twin-edge-rtx-2060-1036')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Zotac Twin Edge RTX 2060', 'card-do-hoa-zotac-twin-edge-rtx-2060-1036', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Zotac'), 1, GETDATE());
    DECLARE @p1036 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1036, 'CARD-H-A-ZOTAC-TWIN-EDGE-RTX-2060-1036', 5900000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1036, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Zotac%20Twin%20Edge%20RT', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1036, N'Chip đồ họa', N'NVIDIA RTX 2060', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1036, N'VRAM', N'6GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1036, N'Giao tiếp', N'PCIe 3.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-gigabyte-windforce-rtx-2070-super-1037')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Gigabyte Windforce RTX 2070 Super', 'card-do-hoa-gigabyte-windforce-rtx-2070-super-1037', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1037 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1037, 'CARD-H-A-GIGABYTE-WINDFORCE-RTX-2070-SUP-1037', 8900000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1037, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Gigabyte%20Windforce', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1037, N'Chip đồ họa', N'NVIDIA RTX 2070 Super', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1037, N'VRAM', N'8GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1037, N'Giao tiếp', N'PCIe 3.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-sapphire-nitro-rx-5700-xt-1038')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Sapphire Nitro+ RX 5700 XT', 'card-do-hoa-sapphire-nitro-rx-5700-xt-1038', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Sapphire'), 1, GETDATE());
    DECLARE @p1038 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1038, 'CARD-H-A-SAPPHIRE-NITRO-RX-5700-XT-1038', 8200000, 8774000, 31, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1038, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Sapphire%20Nitro%2B%20RX', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1038, N'Chip đồ họa', N'AMD RX 5700 XT', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1038, N'VRAM', N'8GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1038, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-adata-su650-240gb-1039')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD ADATA SU650 240GB', 'ssd-adata-su650-240gb-1039', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'ADATA'), 1, GETDATE());
    DECLARE @p1039 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1039, 'SSD-ADATA-SU650-240GB-1039', 480000, 504000, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1039, 'https://placehold.co/400x400?text=SSD%20ADATA%20SU650%20240GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1039, N'Chuẩn', N'SATA III', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1039, N'Dung lượng', N'240GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1039, N'Tốc độ đọc', N'520 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-silicon-power-a55-256gb-1040')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Silicon Power A55 256GB', 'ssd-silicon-power-a55-256gb-1040', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Silicon Power'), 1, GETDATE());
    DECLARE @p1040 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1040, 'SSD-SILICON-POWER-A55-256GB-1040', 550000, 605000, 35, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1040, 'https://placehold.co/400x400?text=SSD%20Silicon%20Power%20A55%20256GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1040, N'Chuẩn', N'SATA III', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1040, N'Dung lượng', N'256GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1040, N'Tốc độ đọc', N'550 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-pny-cs900-250gb-1041')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD PNY CS900 250GB', 'ssd-pny-cs900-250gb-1041', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'PNY'), 1, GETDATE());
    DECLARE @p1041 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1041, 'SSD-PNY-CS900-250GB-1041', 520000, 582000, 40, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1041, 'https://placehold.co/400x400?text=SSD%20PNY%20CS900%20250GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1041, N'Chuẩn', N'SATA III', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1041, N'Dung lượng', N'250GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1041, N'Tốc độ đọc', N'535 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-adata-su650-480gb-1042')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD ADATA SU650 480GB', 'ssd-adata-su650-480gb-1042', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'ADATA'), 1, GETDATE());
    DECLARE @p1042 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1042, 'SSD-ADATA-SU650-480GB-1042', 850000, 977000, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1042, 'https://placehold.co/400x400?text=SSD%20ADATA%20SU650%20480GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1042, N'Chuẩn', N'SATA III', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1042, N'Dung lượng', N'480GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1042, N'Tốc độ đọc', N'520 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-silicon-power-a55-512gb-1043')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Silicon Power A55 512GB', 'ssd-silicon-power-a55-512gb-1043', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Silicon Power'), 1, GETDATE());
    DECLARE @p1043 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1043, 'SSD-SILICON-POWER-A55-512GB-1043', 980000, NULL, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1043, 'https://placehold.co/400x400?text=SSD%20Silicon%20Power%20A55%20512GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1043, N'Chuẩn', N'SATA III', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1043, N'Dung lượng', N'512GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1043, N'Tốc độ đọc', N'560 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-kingston-a400-1tb-1044')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Kingston A400 1TB', 'ssd-kingston-a400-1tb-1044', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p1044 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1044, 'SSD-KINGSTON-A400-1TB-1044', 1250000, NULL, 39, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1044, 'https://placehold.co/400x400?text=SSD%20Kingston%20A400%201TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1044, N'Chuẩn', N'SATA III', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1044, N'Dung lượng', N'1TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1044, N'Tốc độ đọc', N'500 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-crucial-mx500-1tb-sata-1045')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Crucial MX500 1TB SATA', 'ssd-crucial-mx500-1tb-sata-1045', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Crucial'), 1, GETDATE());
    DECLARE @p1045 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1045, 'SSD-CRUCIAL-MX500-1TB-SATA-1045', 1450000, NULL, 35, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1045, 'https://placehold.co/400x400?text=SSD%20Crucial%20MX500%201TB%20SATA', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1045, N'Chuẩn', N'SATA III', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1045, N'Dung lượng', N'1TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1045, N'Tốc độ đọc', N'560 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-adata-legend-700-256gb-nvme-1046')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD ADATA Legend 700 256GB NVMe', 'ssd-adata-legend-700-256gb-nvme-1046', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'ADATA'), 1, GETDATE());
    DECLARE @p1046 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1046, 'SSD-ADATA-LEGEND-700-256GB-NVME-1046', 700000, NULL, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1046, 'https://placehold.co/400x400?text=SSD%20ADATA%20Legend%20700%20256GB%20NVM', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1046, N'Chuẩn', N'NVMe PCIe 3.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1046, N'Dung lượng', N'256GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1046, N'Tốc độ đọc', N'2000 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-silicon-power-p34a60-256gb-nvme-1047')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Silicon Power P34A60 256GB NVMe', 'ssd-silicon-power-p34a60-256gb-nvme-1047', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Silicon Power'), 1, GETDATE());
    DECLARE @p1047 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1047, 'SSD-SILICON-POWER-P34A60-256GB-NVME-1047', 680000, NULL, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1047, 'https://placehold.co/400x400?text=SSD%20Silicon%20Power%20P34A60%20256GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1047, N'Chuẩn', N'NVMe PCIe 3.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1047, N'Dung lượng', N'256GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1047, N'Tốc độ đọc', N'2200 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-pny-cs2130-500gb-nvme-1048')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD PNY CS2130 500GB NVMe', 'ssd-pny-cs2130-500gb-nvme-1048', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'PNY'), 1, GETDATE());
    DECLARE @p1048 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1048, 'SSD-PNY-CS2130-500GB-NVME-1048', 1100000, NULL, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1048, 'https://placehold.co/400x400?text=SSD%20PNY%20CS2130%20500GB%20NVMe', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1048, N'Chuẩn', N'NVMe PCIe 3.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1048, N'Dung lượng', N'500GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1048, N'Tốc độ đọc', N'3500 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-adata-legend-800-500gb-nvme-1049')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD ADATA Legend 800 500GB NVMe', 'ssd-adata-legend-800-500gb-nvme-1049', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'ADATA'), 1, GETDATE());
    DECLARE @p1049 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1049, 'SSD-ADATA-LEGEND-800-500GB-NVME-1049', 1300000, NULL, 14, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1049, 'https://placehold.co/400x400?text=SSD%20ADATA%20Legend%20800%20500GB%20NVM', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1049, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1049, N'Dung lượng', N'500GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1049, N'Tốc độ đọc', N'3900 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-samsung-970-evo-plus-500gb-1050')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Samsung 970 EVO Plus 500GB', 'ssd-samsung-970-evo-plus-500gb-1050', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p1050 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1050, 'SSD-SAMSUNG-970-EVO-PLUS-500GB-1050', 1500000, NULL, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1050, 'https://placehold.co/400x400?text=SSD%20Samsung%20970%20EVO%20Plus%20500GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1050, N'Chuẩn', N'NVMe PCIe 3.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1050, N'Dung lượng', N'500GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1050, N'Tốc độ đọc', N'3500 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-wd-blue-sn570-1tb-1051')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD WD Blue SN570 1TB', 'ssd-wd-blue-sn570-1tb-1051', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p1051 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1051, 'SSD-WD-BLUE-SN570-1TB-1051', 1750000, NULL, 39, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1051, 'https://placehold.co/400x400?text=SSD%20WD%20Blue%20SN570%201TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1051, N'Chuẩn', N'NVMe PCIe 3.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1051, N'Dung lượng', N'1TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1051, N'Tốc độ đọc', N'3500 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-silicon-power-ud90-1tb-1052')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Silicon Power UD90 1TB', 'ssd-silicon-power-ud90-1tb-1052', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Silicon Power'), 1, GETDATE());
    DECLARE @p1052 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1052, 'SSD-SILICON-POWER-UD90-1TB-1052', 1650000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1052, 'https://placehold.co/400x400?text=SSD%20Silicon%20Power%20UD90%201TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1052, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1052, N'Dung lượng', N'1TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1052, N'Tốc độ đọc', N'4800 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-adata-legend-800-1tb-nvme-1053')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD ADATA Legend 800 1TB NVMe', 'ssd-adata-legend-800-1tb-nvme-1053', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'ADATA'), 1, GETDATE());
    DECLARE @p1053 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1053, 'SSD-ADATA-LEGEND-800-1TB-NVME-1053', 1900000, 2166000, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1053, 'https://placehold.co/400x400?text=SSD%20ADATA%20Legend%20800%201TB%20NVMe', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1053, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1053, N'Dung lượng', N'1TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1053, N'Tốc độ đọc', N'3900 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-kingston-nv3-1tb-1054')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Kingston NV3 1TB', 'ssd-kingston-nv3-1tb-1054', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p1054 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1054, 'SSD-KINGSTON-NV3-1TB-1054', 1700000, NULL, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1054, 'https://placehold.co/400x400?text=SSD%20Kingston%20NV3%201TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1054, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1054, N'Dung lượng', N'1TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1054, N'Tốc độ đọc', N'6000 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-samsung-980-pro-1tb-1055')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Samsung 980 Pro 1TB', 'ssd-samsung-980-pro-1tb-1055', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p1055 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1055, 'SSD-SAMSUNG-980-PRO-1TB-1055', 2500000, NULL, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1055, 'https://placehold.co/400x400?text=SSD%20Samsung%20980%20Pro%201TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1055, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1055, N'Dung lượng', N'1TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1055, N'Tốc độ đọc', N'7000 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-crucial-t700-1tb-1056')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Crucial T700 1TB', 'ssd-crucial-t700-1tb-1056', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Crucial'), 1, GETDATE());
    DECLARE @p1056 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1056, 'SSD-CRUCIAL-T700-1TB-1056', 3400000, NULL, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1056, 'https://placehold.co/400x400?text=SSD%20Crucial%20T700%201TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1056, N'Chuẩn', N'NVMe PCIe 5.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1056, N'Dung lượng', N'1TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1056, N'Tốc độ đọc', N'12400 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-pny-cs3140-2tb-nvme-1057')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD PNY CS3140 2TB NVMe', 'ssd-pny-cs3140-2tb-nvme-1057', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'PNY'), 1, GETDATE());
    DECLARE @p1057 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1057, 'SSD-PNY-CS3140-2TB-NVME-1057', 3300000, NULL, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1057, 'https://placehold.co/400x400?text=SSD%20PNY%20CS3140%202TB%20NVMe', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1057, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1057, N'Dung lượng', N'2TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1057, N'Tốc độ đọc', N'7500 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-adata-legend-800-2tb-nvme-1058')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD ADATA Legend 800 2TB NVMe', 'ssd-adata-legend-800-2tb-nvme-1058', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'ADATA'), 1, GETDATE());
    DECLARE @p1058 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1058, 'SSD-ADATA-LEGEND-800-2TB-NVME-1058', 3500000, NULL, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1058, 'https://placehold.co/400x400?text=SSD%20ADATA%20Legend%20800%202TB%20NVMe', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1058, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1058, N'Dung lượng', N'2TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1058, N'Tốc độ đọc', N'3900 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-samsung-990-pro-2tb-1059')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Samsung 990 Pro 2TB', 'ssd-samsung-990-pro-2tb-1059', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p1059 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1059, 'SSD-SAMSUNG-990-PRO-2TB-1059', 4600000, 4876000, 31, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1059, 'https://placehold.co/400x400?text=SSD%20Samsung%20990%20Pro%202TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1059, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1059, N'Dung lượng', N'2TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1059, N'Tốc độ đọc', N'7450 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-wd-black-sn850x-4tb-1060')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD WD Black SN850X 4TB', 'ssd-wd-black-sn850x-4tb-1060', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p1060 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1060, 'SSD-WD-BLACK-SN850X-4TB-1060', 6800000, NULL, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1060, 'https://placehold.co/400x400?text=SSD%20WD%20Black%20SN850X%204TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1060, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1060, N'Dung lượng', N'4TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1060, N'Tốc độ đọc', N'7300 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-kingston-kc3000-4tb-1061')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Kingston KC3000 4TB', 'ssd-kingston-kc3000-4tb-1061', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p1061 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1061, 'SSD-KINGSTON-KC3000-4TB-1061', 7100000, 7668000, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1061, 'https://placehold.co/400x400?text=SSD%20Kingston%20KC3000%204TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1061, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1061, N'Dung lượng', N'4TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1061, N'Tốc độ đọc', N'7000 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-crucial-t500-4tb-1062')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Crucial T500 4TB', 'ssd-crucial-t500-4tb-1062', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Crucial'), 1, GETDATE());
    DECLARE @p1062 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1062, 'SSD-CRUCIAL-T500-4TB-1062', 7500000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1062, 'https://placehold.co/400x400?text=SSD%20Crucial%20T500%204TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1062, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1062, N'Dung lượng', N'4TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1062, N'Tốc độ đọc', N'7400 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-silicon-power-us75-2tb-1063')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Silicon Power US75 2TB', 'ssd-silicon-power-us75-2tb-1063', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Silicon Power'), 1, GETDATE());
    DECLARE @p1063 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1063, 'SSD-SILICON-POWER-US75-2TB-1063', 3100000, 3503000, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1063, 'https://placehold.co/400x400?text=SSD%20Silicon%20Power%20US75%202TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1063, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1063, N'Dung lượng', N'2TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1063, N'Tốc độ đọc', N'7000 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-adata-su650-120gb-1064')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD ADATA SU650 120GB', 'ssd-adata-su650-120gb-1064', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'ADATA'), 1, GETDATE());
    DECLARE @p1064 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1064, 'SSD-ADATA-SU650-120GB-1064', 320000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1064, 'https://placehold.co/400x400?text=SSD%20ADATA%20SU650%20120GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1064, N'Chuẩn', N'SATA III', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1064, N'Dung lượng', N'120GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1064, N'Tốc độ đọc', N'520 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-kingston-nv3-500gb-1065')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Kingston NV3 500GB', 'ssd-kingston-nv3-500gb-1065', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p1065 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1065, 'SSD-KINGSTON-NV3-500GB-1065', 1050000, 1145000, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1065, 'https://placehold.co/400x400?text=SSD%20Kingston%20NV3%20500GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1065, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1065, N'Dung lượng', N'500GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1065, N'Tốc độ đọc', N'6000 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-crucial-p3-2tb-1066')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Crucial P3 2TB', 'ssd-crucial-p3-2tb-1066', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Crucial'), 1, GETDATE());
    DECLARE @p1066 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1066, 'SSD-CRUCIAL-P3-2TB-1066', 2400000, 2640000, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1066, 'https://placehold.co/400x400?text=SSD%20Crucial%20P3%202TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1066, N'Chuẩn', N'NVMe PCIe 3.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1066, N'Dung lượng', N'2TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1066, N'Tốc độ đọc', N'3500 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-pny-cs900-120gb-1067')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD PNY CS900 120GB', 'ssd-pny-cs900-120gb-1067', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'PNY'), 1, GETDATE());
    DECLARE @p1067 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1067, 'SSD-PNY-CS900-120GB-1067', 300000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1067, 'https://placehold.co/400x400?text=SSD%20PNY%20CS900%20120GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1067, N'Chuẩn', N'SATA III', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1067, N'Dung lượng', N'120GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1067, N'Tốc độ đọc', N'515 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-silicon-power-a55-1tb-1068')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Silicon Power A55 1TB', 'ssd-silicon-power-a55-1tb-1068', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Silicon Power'), 1, GETDATE());
    DECLARE @p1068 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1068, 'SSD-SILICON-POWER-A55-1TB-1068', 1350000, 1418000, 21, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1068, 'https://placehold.co/400x400?text=SSD%20Silicon%20Power%20A55%201TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1068, N'Chuẩn', N'SATA III', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1068, N'Dung lượng', N'1TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1068, N'Tốc độ đọc', N'560 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-samsung-870-qvo-2tb-1069')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Samsung 870 QVO 2TB', 'ssd-samsung-870-qvo-2tb-1069', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p1069 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1069, 'SSD-SAMSUNG-870-QVO-2TB-1069', 2600000, 2730000, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1069, 'https://placehold.co/400x400?text=SSD%20Samsung%20870%20QVO%202TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1069, N'Chuẩn', N'SATA III', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1069, N'Dung lượng', N'2TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1069, N'Tốc độ đọc', N'560 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-adata-legend-960-2tb-nvme-1070')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD ADATA Legend 960 2TB NVMe', 'ssd-adata-legend-960-2tb-nvme-1070', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'ADATA'), 1, GETDATE());
    DECLARE @p1070 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1070, 'SSD-ADATA-LEGEND-960-2TB-NVME-1070', 3800000, NULL, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1070, 'https://placehold.co/400x400?text=SSD%20ADATA%20Legend%20960%202TB%20NVMe', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1070, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1070, N'Dung lượng', N'2TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1070, N'Tốc độ đọc', N'7400 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-wd-blue-sn580-2tb-1071')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD WD Blue SN580 2TB', 'ssd-wd-blue-sn580-2tb-1071', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p1071 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1071, 'SSD-WD-BLUE-SN580-2TB-1071', 2900000, 3219000, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1071, 'https://placehold.co/400x400?text=SSD%20WD%20Blue%20SN580%202TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1071, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1071, N'Dung lượng', N'2TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1071, N'Tốc độ đọc', N'4150 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-kingston-fury-renegade-4tb-1072')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Kingston Fury Renegade 4TB', 'ssd-kingston-fury-renegade-4tb-1072', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p1072 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1072, 'SSD-KINGSTON-FURY-RENEGADE-4TB-1072', 7900000, NULL, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1072, 'https://placehold.co/400x400?text=SSD%20Kingston%20Fury%20Renegade%204TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1072, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1072, N'Dung lượng', N'4TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1072, N'Tốc độ đọc', N'7300 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-toshiba-p300-1tb-1073')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Toshiba P300 1TB', 'o-cung-hdd-toshiba-p300-1tb-1073', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p1073 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1073, 'C-NG-HDD-TOSHIBA-P300-1TB-1073', 1000000, NULL, 30, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1073, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Toshiba%20P300%201TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1073, N'Dung lượng', N'1TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1073, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1073, N'Tốc độ quay', N'7200rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-barracuda-500gb-1074')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate Barracuda 500GB', 'o-cung-hdd-seagate-barracuda-500gb-1074', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p1074 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1074, 'C-NG-HDD-SEAGATE-BARRACUDA-500GB-1074', 750000, 795000, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1074, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Seagate%20Barracuda%205', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1074, N'Dung lượng', N'500GB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1074, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1074, N'Tốc độ quay', N'7200rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-western-digital-blue-500gb-1075')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Western Digital Blue 500GB', 'o-cung-hdd-western-digital-blue-500gb-1075', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p1075 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1075, 'C-NG-HDD-WESTERN-DIGITAL-BLUE-500GB-1075', 780000, NULL, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1075, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Western%20Digital%20Blu', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1075, N'Dung lượng', N'500GB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1075, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1075, N'Tốc độ quay', N'5400rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-ironwolf-1tb-1076')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate IronWolf 1TB', 'o-cung-hdd-seagate-ironwolf-1tb-1076', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p1076 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1076, 'C-NG-HDD-SEAGATE-IRONWOLF-1TB-1076', 1250000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1076, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Seagate%20IronWolf%201T', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1076, N'Dung lượng', N'1TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1076, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1076, N'Tốc độ quay', N'5900rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-western-digital-red-1tb-1077')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Western Digital Red 1TB', 'o-cung-hdd-western-digital-red-1tb-1077', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p1077 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1077, 'C-NG-HDD-WESTERN-DIGITAL-RED-1TB-1077', 1350000, NULL, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1077, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Western%20Digital%20Red', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1077, N'Dung lượng', N'1TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1077, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1077, N'Tốc độ quay', N'5400rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-barracuda-3tb-1078')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate Barracuda 3TB', 'o-cung-hdd-seagate-barracuda-3tb-1078', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p1078 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1078, 'C-NG-HDD-SEAGATE-BARRACUDA-3TB-1078', 1900000, NULL, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1078, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Seagate%20Barracuda%203', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1078, N'Dung lượng', N'3TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1078, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1078, N'Tốc độ quay', N'7200rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-western-digital-blue-3tb-1079')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Western Digital Blue 3TB', 'o-cung-hdd-western-digital-blue-3tb-1079', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p1079 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1079, 'C-NG-HDD-WESTERN-DIGITAL-BLUE-3TB-1079', 1950000, NULL, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1079, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Western%20Digital%20Blu', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1079, N'Dung lượng', N'3TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1079, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1079, N'Tốc độ quay', N'5400rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-ironwolf-pro-4tb-1080')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate IronWolf Pro 4TB', 'o-cung-hdd-seagate-ironwolf-pro-4tb-1080', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p1080 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1080, 'C-NG-HDD-SEAGATE-IRONWOLF-PRO-4TB-1080', 2950000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1080, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Seagate%20IronWolf%20Pr', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1080, N'Dung lượng', N'4TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1080, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1080, N'Tốc độ quay', N'7200rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-western-digital-red-pro-6tb-1081')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Western Digital Red Pro 6TB', 'o-cung-hdd-western-digital-red-pro-6tb-1081', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p1081 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1081, 'C-NG-HDD-WESTERN-DIGITAL-RED-PRO-6TB-1081', 4200000, NULL, 24, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1081, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Western%20Digital%20Red', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1081, N'Dung lượng', N'6TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1081, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1081, N'Tốc độ quay', N'7200rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-exos-8tb-1082')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate Exos 8TB', 'o-cung-hdd-seagate-exos-8tb-1082', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p1082 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1082, 'C-NG-HDD-SEAGATE-EXOS-8TB-1082', 5500000, NULL, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1082, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Seagate%20Exos%208TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1082, N'Dung lượng', N'8TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1082, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1082, N'Tốc độ quay', N'7200rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-western-digital-gold-10tb-1083')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Western Digital Gold 10TB', 'o-cung-hdd-western-digital-gold-10tb-1083', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p1083 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1083, 'C-NG-HDD-WESTERN-DIGITAL-GOLD-10TB-1083', 7800000, 8892000, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1083, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Western%20Digital%20Gol', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1083, N'Dung lượng', N'10TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1083, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1083, N'Tốc độ quay', N'7200rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-skyhawk-ai-6tb-1084')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate Skyhawk AI 6TB', 'o-cung-hdd-seagate-skyhawk-ai-6tb-1084', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p1084 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1084, 'C-NG-HDD-SEAGATE-SKYHAWK-AI-6TB-1084', 4100000, 4510000, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1084, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Seagate%20Skyhawk%20AI%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1084, N'Dung lượng', N'6TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1084, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1084, N'Tốc độ quay', N'7200rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-western-digital-purple-6tb-1085')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Western Digital Purple 6TB', 'o-cung-hdd-western-digital-purple-6tb-1085', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p1085 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1085, 'C-NG-HDD-WESTERN-DIGITAL-PURPLE-6TB-1085', 3900000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1085, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Western%20Digital%20Pur', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1085, N'Dung lượng', N'6TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1085, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1085, N'Tốc độ quay', N'5400rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-firecuda-1tb-1086')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate FireCuda 1TB', 'o-cung-hdd-seagate-firecuda-1tb-1086', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p1086 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1086, 'C-NG-HDD-SEAGATE-FIRECUDA-1TB-1086', 1550000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1086, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Seagate%20FireCuda%201T', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1086, N'Dung lượng', N'1TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1086, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1086, N'Tốc độ quay', N'7200rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-western-digital-elements-2tb-1087')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Western Digital Elements 2TB', 'o-cung-hdd-western-digital-elements-2tb-1087', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p1087 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1087, 'C-NG-HDD-WESTERN-DIGITAL-ELEMENTS-2TB-1087', 1650000, NULL, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1087, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Western%20Digital%20Ele', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1087, N'Dung lượng', N'2TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1087, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1087, N'Tốc độ quay', N'5400rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-backup-plus-5tb-1088')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate Backup Plus 5TB', 'o-cung-hdd-seagate-backup-plus-5tb-1088', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p1088 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1088, 'C-NG-HDD-SEAGATE-BACKUP-PLUS-5TB-1088', 3200000, NULL, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1088, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Seagate%20Backup%20Plus', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1088, N'Dung lượng', N'5TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1088, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1088, N'Tốc độ quay', N'5400rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-barracuda-4tb-1089')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate Barracuda 4TB', 'o-cung-hdd-seagate-barracuda-4tb-1089', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p1089 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1089, 'C-NG-HDD-SEAGATE-BARRACUDA-4TB-1089', 2500000, 2750000, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1089, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Seagate%20Barracuda%204', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1089, N'Dung lượng', N'4TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1089, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1089, N'Tốc độ quay', N'5400rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-western-digital-blue-4tb-1090')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Western Digital Blue 4TB', 'o-cung-hdd-western-digital-blue-4tb-1090', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p1090 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1090, 'C-NG-HDD-WESTERN-DIGITAL-BLUE-4TB-1090', 2450000, NULL, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1090, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Western%20Digital%20Blu', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1090, N'Dung lượng', N'4TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1090, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1090, N'Tốc độ quay', N'5400rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-ironwolf-8tb-1091')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate IronWolf 8TB', 'o-cung-hdd-seagate-ironwolf-8tb-1091', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p1091 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1091, 'C-NG-HDD-SEAGATE-IRONWOLF-8TB-1091', 5200000, 5616000, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1091, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Seagate%20IronWolf%208T', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1091, N'Dung lượng', N'8TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1091, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1091, N'Tốc độ quay', N'7200rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-western-digital-red-plus-8tb-1092')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Western Digital Red Plus 8TB', 'o-cung-hdd-western-digital-red-plus-8tb-1092', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p1092 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1092, 'C-NG-HDD-WESTERN-DIGITAL-RED-PLUS-8TB-1092', 5400000, NULL, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1092, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Western%20Digital%20Red', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1092, N'Dung lượng', N'8TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1092, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1092, N'Tốc độ quay', N'5400rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-xigmatek-x-power-450w-1093')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Xigmatek X-Power 450W', 'nguon-xigmatek-x-power-450w-1093', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Xigmatek'), 1, GETDATE());
    DECLARE @p1093 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1093, 'NGU-N-XIGMATEK-X-POWER-450W-1093', 750000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1093, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Xigmatek%20X-Power%20450W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1093, N'Công suất', N'450W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1093, N'Chuẩn 80 Plus', N'Không chứng nhận', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1093, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-thermaltake-smart-500w-1094')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Thermaltake Smart 500W', 'nguon-thermaltake-smart-500w-1094', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Thermaltake'), 1, GETDATE());
    DECLARE @p1094 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1094, 'NGU-N-THERMALTAKE-SMART-500W-1094', 950000, NULL, 35, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1094, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Thermaltake%20Smart%20500W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1094, N'Công suất', N'500W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1094, N'Chuẩn 80 Plus', N'80 Plus White', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1094, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-xigmatek-x-power-500w-1095')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Xigmatek X-Power 500W', 'nguon-xigmatek-x-power-500w-1095', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Xigmatek'), 1, GETDATE());
    DECLARE @p1095 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1095, 'NGU-N-XIGMATEK-X-POWER-500W-1095', 850000, NULL, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1095, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Xigmatek%20X-Power%20500W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1095, N'Công suất', N'500W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1095, N'Chuẩn 80 Plus', N'Không chứng nhận', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1095, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-corsair-cx550-1096')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Corsair CX550', 'nguon-corsair-cx550-1096', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p1096 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1096, 'NGU-N-CORSAIR-CX550-1096', 1400000, 1526000, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1096, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Corsair%20CX550', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1096, N'Công suất', N'550W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1096, N'Chuẩn 80 Plus', N'80 Plus Bronze', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1096, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-thermaltake-toughpower-gf1-650w-1097')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Thermaltake Toughpower GF1 650W', 'nguon-thermaltake-toughpower-gf1-650w-1097', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Thermaltake'), 1, GETDATE());
    DECLARE @p1097 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1097, 'NGU-N-THERMALTAKE-TOUGHPOWER-GF1-650W-1097', 2100000, 2352000, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1097, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Thermaltake%20Toughpower%20G', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1097, N'Công suất', N'650W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1097, N'Chuẩn 80 Plus', N'80 Plus Gold', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1097, N'Loại nguồn', N'Full-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-fsp-hyper-s-600w-1098')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn FSP Hyper S 600W', 'nguon-fsp-hyper-s-600w-1098', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'FSP'), 1, GETDATE());
    DECLARE @p1098 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1098, 'NGU-N-FSP-HYPER-S-600W-1098', 1350000, NULL, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1098, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20FSP%20Hyper%20S%20600W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1098, N'Công suất', N'600W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1098, N'Chuẩn 80 Plus', N'80 Plus Bronze', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1098, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-msi-mag-a650bn-650w-1099')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn MSI MAG A650BN 650W', 'nguon-msi-mag-a650bn-650w-1099', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1099 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1099, 'NGU-N-MSI-MAG-A650BN-650W-1099', 1850000, NULL, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1099, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20MSI%20MAG%20A650BN%20650W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1099, N'Công suất', N'650W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1099, N'Chuẩn 80 Plus', N'80 Plus Bronze', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1099, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-cooler-master-mwe-650-gold-650w-1100')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Cooler Master MWE 650 Gold 650W', 'nguon-cooler-master-mwe-650-gold-650w-1100', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Cooler Master'), 1, GETDATE());
    DECLARE @p1100 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1100, 'NGU-N-COOLER-MASTER-MWE-650-GOLD-650W-1100', 2050000, NULL, 40, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1100, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Cooler%20Master%20MWE%20650%20Go', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1100, N'Công suất', N'650W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1100, N'Chuẩn 80 Plus', N'80 Plus Gold', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1100, N'Loại nguồn', N'Semi-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-xigmatek-x-power-ii-750w-1101')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Xigmatek X-Power II 750W', 'nguon-xigmatek-x-power-ii-750w-1101', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Xigmatek'), 1, GETDATE());
    DECLARE @p1101 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1101, 'NGU-N-XIGMATEK-X-POWER-II-750W-1101', 1750000, NULL, 35, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1101, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Xigmatek%20X-Power%20II%20750W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1101, N'Công suất', N'750W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1101, N'Chuẩn 80 Plus', N'80 Plus Bronze', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1101, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-thermaltake-toughpower-gf1-750w-1102')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Thermaltake Toughpower GF1 750W', 'nguon-thermaltake-toughpower-gf1-750w-1102', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Thermaltake'), 1, GETDATE());
    DECLARE @p1102 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1102, 'NGU-N-THERMALTAKE-TOUGHPOWER-GF1-750W-1102', 2400000, NULL, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1102, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Thermaltake%20Toughpower%20G', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1102, N'Công suất', N'750W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1102, N'Chuẩn 80 Plus', N'80 Plus Gold', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1102, N'Loại nguồn', N'Full-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-corsair-rm750x-1103')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Corsair RM750x', 'nguon-corsair-rm750x-1103', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p1103 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1103, 'NGU-N-CORSAIR-RM750X-1103', 2600000, NULL, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1103, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Corsair%20RM750x', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1103, N'Công suất', N'750W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1103, N'Chuẩn 80 Plus', N'80 Plus Gold', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1103, N'Loại nguồn', N'Full-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-fsp-hydro-g-pro-750w-1104')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn FSP Hydro G Pro 750W', 'nguon-fsp-hydro-g-pro-750w-1104', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'FSP'), 1, GETDATE());
    DECLARE @p1104 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1104, 'NGU-N-FSP-HYDRO-G-PRO-750W-1104', 2200000, NULL, 14, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1104, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20FSP%20Hydro%20G%20Pro%20750W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1104, N'Công suất', N'750W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1104, N'Chuẩn 80 Plus', N'80 Plus Gold', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1104, N'Loại nguồn', N'Full-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-msi-mpg-a850g-850w-1105')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn MSI MPG A850G 850W', 'nguon-msi-mpg-a850g-850w-1105', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1105 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1105, 'NGU-N-MSI-MPG-A850G-850W-1105', 2900000, NULL, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1105, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20MSI%20MPG%20A850G%20850W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1105, N'Công suất', N'850W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1105, N'Chuẩn 80 Plus', N'80 Plus Gold', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1105, N'Loại nguồn', N'Full-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-cooler-master-mwe-850-gold-850w-1106')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Cooler Master MWE 850 Gold 850W', 'nguon-cooler-master-mwe-850-gold-850w-1106', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Cooler Master'), 1, GETDATE());
    DECLARE @p1106 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1106, 'NGU-N-COOLER-MASTER-MWE-850-GOLD-850W-1106', 2750000, 3107000, 39, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1106, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Cooler%20Master%20MWE%20850%20Go', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1106, N'Công suất', N'850W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1106, N'Chuẩn 80 Plus', N'80 Plus Gold', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1106, N'Loại nguồn', N'Semi-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-thermaltake-toughpower-gf3-850w-1107')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Thermaltake Toughpower GF3 850W', 'nguon-thermaltake-toughpower-gf3-850w-1107', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Thermaltake'), 1, GETDATE());
    DECLARE @p1107 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1107, 'NGU-N-THERMALTAKE-TOUGHPOWER-GF3-850W-1107', 3100000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1107, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Thermaltake%20Toughpower%20G', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1107, N'Công suất', N'850W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1107, N'Chuẩn 80 Plus', N'80 Plus Gold', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1107, N'Loại nguồn', N'Full-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-corsair-hx850-1108')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Corsair HX850', 'nguon-corsair-hx850-1108', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p1108 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1108, 'NGU-N-CORSAIR-HX850-1108', 3800000, NULL, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1108, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Corsair%20HX850', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1108, N'Công suất', N'850W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1108, N'Chuẩn 80 Plus', N'80 Plus Platinum', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1108, N'Loại nguồn', N'Full-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-fsp-hydro-ti-pro-1000w-1109')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn FSP Hydro Ti Pro 1000W', 'nguon-fsp-hydro-ti-pro-1000w-1109', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'FSP'), 1, GETDATE());
    DECLARE @p1109 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1109, 'NGU-N-FSP-HYDRO-TI-PRO-1000W-1109', 4600000, NULL, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1109, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20FSP%20Hydro%20Ti%20Pro%201000W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1109, N'Công suất', N'1000W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1109, N'Chuẩn 80 Plus', N'80 Plus Titanium', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1109, N'Loại nguồn', N'Full-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-thermaltake-toughpower-gf3-1000w-1110')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Thermaltake Toughpower GF3 1000W', 'nguon-thermaltake-toughpower-gf3-1000w-1110', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Thermaltake'), 1, GETDATE());
    DECLARE @p1110 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1110, 'NGU-N-THERMALTAKE-TOUGHPOWER-GF3-1000W-1110', 4200000, NULL, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1110, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Thermaltake%20Toughpower%20G', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1110, N'Công suất', N'1000W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1110, N'Chuẩn 80 Plus', N'80 Plus Gold', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1110, N'Loại nguồn', N'Full-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-corsair-hx1200-1111')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Corsair HX1200', 'nguon-corsair-hx1200-1111', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p1111 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1111, 'NGU-N-CORSAIR-HX1200-1111', 5900000, NULL, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1111, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Corsair%20HX1200', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1111, N'Công suất', N'1200W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1111, N'Chuẩn 80 Plus', N'80 Plus Platinum', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1111, N'Loại nguồn', N'Full-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-msi-meg-ai1300p-1300w-1112')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn MSI MEG Ai1300P 1300W', 'nguon-msi-meg-ai1300p-1300w-1112', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1112 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1112, 'NGU-N-MSI-MEG-AI1300P-1300W-1112', 7500000, NULL, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1112, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20MSI%20MEG%20Ai1300P%201300W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1112, N'Công suất', N'1300W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1112, N'Chuẩn 80 Plus', N'80 Plus Platinum', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1112, N'Loại nguồn', N'Full-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-xigmatek-x-power-iii-550w-1113')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Xigmatek X-Power III 550W', 'nguon-xigmatek-x-power-iii-550w-1113', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Xigmatek'), 1, GETDATE());
    DECLARE @p1113 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1113, 'NGU-N-XIGMATEK-X-POWER-III-550W-1113', 950000, NULL, 39, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1113, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Xigmatek%20X-Power%20III%20550', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1113, N'Công suất', N'550W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1113, N'Chuẩn 80 Plus', N'80 Plus Bronze', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1113, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-thermaltake-smart-rgb-600w-1114')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Thermaltake Smart RGB 600W', 'nguon-thermaltake-smart-rgb-600w-1114', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Thermaltake'), 1, GETDATE());
    DECLARE @p1114 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1114, 'NGU-N-THERMALTAKE-SMART-RGB-600W-1114', 1250000, 1325000, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1114, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Thermaltake%20Smart%20RGB%2060', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1114, N'Công suất', N'600W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1114, N'Chuẩn 80 Plus', N'80 Plus White', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1114, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-corsair-cx650-1115')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Corsair CX650', 'nguon-corsair-cx650-1115', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p1115 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1115, 'NGU-N-CORSAIR-CX650-1115', 1650000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1115, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Corsair%20CX650', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1115, N'Công suất', N'650W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1115, N'Chuẩn 80 Plus', N'80 Plus Bronze', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1115, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-fsp-hyper-k-750w-1116')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn FSP Hyper K 750W', 'nguon-fsp-hyper-k-750w-1116', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'FSP'), 1, GETDATE());
    DECLARE @p1116 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1116, 'NGU-N-FSP-HYPER-K-750W-1116', 1650000, 1766000, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1116, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20FSP%20Hyper%20K%20750W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1116, N'Công suất', N'750W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1116, N'Chuẩn 80 Plus', N'Không chứng nhận', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1116, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-cooler-master-v750-sfx-750w-1117')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Cooler Master V750 SFX 750W', 'nguon-cooler-master-v750-sfx-750w-1117', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Cooler Master'), 1, GETDATE());
    DECLARE @p1117 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1117, 'NGU-N-COOLER-MASTER-V750-SFX-750W-1117', 3300000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1117, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Cooler%20Master%20V750%20SFX%207', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1117, N'Công suất', N'750W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1117, N'Chuẩn 80 Plus', N'80 Plus Gold', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1117, N'Loại nguồn', N'Full-modular SFX', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-xigmatek-aquarius-plus-1118')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Xigmatek Aquarius Plus', 'vo-case-xigmatek-aquarius-plus-1118', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Xigmatek'), 1, GETDATE());
    DECLARE @p1118 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1118, 'V-CASE-XIGMATEK-AQUARIUS-PLUS-1118', 700000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1118, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Xigmatek%20Aquarius%20Plus', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1118, N'Kích thước hỗ trợ', N'Micro-ATX / Mini-ITX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1118, N'Đặc điểm', N'Kính cường lực', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-thermaltake-versa-h18-1119')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Thermaltake Versa H18', 'vo-case-thermaltake-versa-h18-1119', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Thermaltake'), 1, GETDATE());
    DECLARE @p1119 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1119, 'V-CASE-THERMALTAKE-VERSA-H18-1119', 650000, NULL, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1119, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Thermaltake%20Versa%20H18', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1119, N'Kích thước hỗ trợ', N'Micro-ATX / Mini-ITX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1119, N'Đặc điểm', N'Nhỏ gọn', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-e-dra-eg7000-1120')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case E-Dra EG7000', 'vo-case-e-dra-eg7000-1120', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'E-Dra'), 1, GETDATE());
    DECLARE @p1120 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1120, 'V-CASE-E-DRA-EG7000-1120', 800000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1120, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20E-Dra%20EG7000', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1120, N'Kích thước hỗ trợ', N'ATX / Micro-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1120, N'Đặc điểm', N'Kính cường lực, quạt RGB', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-xigmatek-gengar-1121')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Xigmatek Gengar', 'vo-case-xigmatek-gengar-1121', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Xigmatek'), 1, GETDATE());
    DECLARE @p1121 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1121, 'V-CASE-XIGMATEK-GENGAR-1121', 850000, NULL, 24, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1121, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Xigmatek%20Gengar', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1121, N'Kích thước hỗ trợ', N'ATX / Micro-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1121, N'Đặc điểm', N'Mặt lưới tản nhiệt', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-fractal-design-focus-2-1122')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Fractal Design Focus 2', 'vo-case-fractal-design-focus-2-1122', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Fractal Design'), 1, GETDATE());
    DECLARE @p1122 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1122, 'V-CASE-FRACTAL-DESIGN-FOCUS-2-1122', 1300000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1122, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Fractal%20Design%20Focus%202', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1122, N'Kích thước hỗ trợ', N'ATX / Micro-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1122, N'Đặc điểm', N'Luồng khí tối ưu', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-thermaltake-h200-1123')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Thermaltake H200', 'vo-case-thermaltake-h200-1123', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Thermaltake'), 1, GETDATE());
    DECLARE @p1123 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1123, 'V-CASE-THERMALTAKE-H200-1123', 1200000, 1320000, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1123, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Thermaltake%20H200', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1123, N'Kích thước hỗ trợ', N'ATX / Micro-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1123, N'Đặc điểm', N'Kính cường lực', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-e-dra-eg7500-1124')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case E-Dra EG7500', 'vo-case-e-dra-eg7500-1124', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'E-Dra'), 1, GETDATE());
    DECLARE @p1124 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1124, 'V-CASE-E-DRA-EG7500-1124', 1400000, 1554000, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1124, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20E-Dra%20EG7500', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1124, N'Kích thước hỗ trợ', N'ATX / Micro-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1124, N'Đặc điểm', N'Kính cường lực, 4 quạt RGB', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-xigmatek-master-x-1125')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Xigmatek Master X', 'vo-case-xigmatek-master-x-1125', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Xigmatek'), 1, GETDATE());
    DECLARE @p1125 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1125, 'V-CASE-XIGMATEK-MASTER-X-1125', 1550000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1125, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Xigmatek%20Master%20X', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1125, N'Kích thước hỗ trợ', N'ATX / E-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1125, N'Đặc điểm', N'Mặt lưới tản nhiệt', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-fractal-design-meshify-2-1126')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Fractal Design Meshify 2', 'vo-case-fractal-design-meshify-2-1126', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Fractal Design'), 1, GETDATE());
    DECLARE @p1126 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1126, 'V-CASE-FRACTAL-DESIGN-MESHIFY-2-1126', 2400000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1126, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Fractal%20Design%20Meshify', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1126, N'Kích thước hỗ trợ', N'ATX / E-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1126, N'Đặc điểm', N'Mặt lưới tản nhiệt cao cấp', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-thermaltake-view-270-1127')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Thermaltake View 270', 'vo-case-thermaltake-view-270-1127', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Thermaltake'), 1, GETDATE());
    DECLARE @p1127 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1127, 'V-CASE-THERMALTAKE-VIEW-270-1127', 2200000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1127, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Thermaltake%20View%20270', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1127, N'Kích thước hỗ trợ', N'ATX / Micro-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1127, N'Đặc điểm', N'Kính cường lực 3 mặt', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-corsair-icue-4000x-1128')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Corsair iCUE 4000X', 'vo-case-corsair-icue-4000x-1128', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p1128 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1128, 'V-CASE-CORSAIR-ICUE-4000X-1128', 2600000, 2938000, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1128, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Corsair%20iCUE%204000X', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1128, N'Kích thước hỗ trợ', N'ATX / Micro-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1128, N'Đặc điểm', N'Kính cường lực, RGB', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-lian-li-lancool-iii-1129')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Lian Li Lancool III', 'vo-case-lian-li-lancool-iii-1129', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Lian Li'), 1, GETDATE());
    DECLARE @p1129 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1129, 'V-CASE-LIAN-LI-LANCOOL-III-1129', 3000000, NULL, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1129, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Lian%20Li%20Lancool%20III', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1129, N'Kích thước hỗ trợ', N'ATX / E-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1129, N'Đặc điểm', N'Luồng khí tối ưu, modular', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-fractal-design-torrent-1130')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Fractal Design Torrent', 'vo-case-fractal-design-torrent-1130', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Fractal Design'), 1, GETDATE());
    DECLARE @p1130 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1130, 'V-CASE-FRACTAL-DESIGN-TORRENT-1130', 4200000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1130, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Fractal%20Design%20Torrent', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1130, N'Kích thước hỗ trợ', N'ATX / E-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1130, N'Đặc điểm', N'Luồng khí cực mạnh, 2 quạt 180mm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-nzxt-h7-flow-1131')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case NZXT H7 Flow', 'vo-case-nzxt-h7-flow-1131', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'NZXT'), 1, GETDATE());
    DECLARE @p1131 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1131, 'V-CASE-NZXT-H7-FLOW-1131', 2900000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1131, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20NZXT%20H7%20Flow', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1131, N'Kích thước hỗ trợ', N'ATX / E-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1131, N'Đặc điểm', N'Luồng khí tối ưu', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-corsair-5000d-1132')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Corsair 5000D', 'vo-case-corsair-5000d-1132', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p1132 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1132, 'V-CASE-CORSAIR-5000D-1132', 3600000, NULL, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1132, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Corsair%205000D', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1132, N'Kích thước hỗ trợ', N'ATX / E-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1132, N'Đặc điểm', N'Kính cường lực cao cấp', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-lian-li-o11-dynamic-evo-1133')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Lian Li O11 Dynamic EVO', 'vo-case-lian-li-o11-dynamic-evo-1133', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Lian Li'), 1, GETDATE());
    DECLARE @p1133 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1133, 'V-CASE-LIAN-LI-O11-DYNAMIC-EVO-1133', 4500000, 4815000, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1133, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Lian%20Li%20O11%20Dynamic%20EV', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1133, N'Kích thước hỗ trợ', N'ATX / E-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1133, N'Đặc điểm', N'Kính cường lực 3 mặt, modular', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-xigmatek-hermes-1134')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Xigmatek Hermes', 'vo-case-xigmatek-hermes-1134', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Xigmatek'), 1, GETDATE());
    DECLARE @p1134 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1134, 'V-CASE-XIGMATEK-HERMES-1134', 620000, 676000, 30, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1134, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Xigmatek%20Hermes', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1134, N'Kích thước hỗ trợ', N'Micro-ATX / Mini-ITX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1134, N'Đặc điểm', N'Nhỏ gọn', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-e-dra-eg7600-1135')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case E-Dra EG7600', 'vo-case-e-dra-eg7600-1135', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'E-Dra'), 1, GETDATE());
    DECLARE @p1135 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1135, 'V-CASE-E-DRA-EG7600-1135', 1050000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1135, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20E-Dra%20EG7600', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1135, N'Kích thước hỗ trợ', N'ATX / Micro-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1135, N'Đặc điểm', N'Kính cường lực, 3 quạt RGB', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-thermaltake-core-p3-1136')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Thermaltake Core P3', 'vo-case-thermaltake-core-p3-1136', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Thermaltake'), 1, GETDATE());
    DECLARE @p1136 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1136, 'V-CASE-THERMALTAKE-CORE-P3-1136', 3200000, NULL, 21, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1136, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Thermaltake%20Core%20P3', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1136, N'Kích thước hỗ trợ', N'ATX / E-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1136, N'Đặc điểm', N'Open-frame, kính cường lực', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-deepcool-ch560-1137')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case DeepCool CH560', 'vo-case-deepcool-ch560-1137', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'DeepCool'), 1, GETDATE());
    DECLARE @p1137 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1137, 'V-CASE-DEEPCOOL-CH560-1137', 1850000, NULL, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1137, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20DeepCool%20CH560', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1137, N'Kích thước hỗ trợ', N'ATX / E-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1137, N'Đặc điểm', N'Mặt lưới tản nhiệt, 4 quạt sẵn', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-khi-xigmatek-windpower-ii-1138')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt khí Xigmatek Windpower II', 'tan-nhiet-khi-xigmatek-windpower-ii-1138', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'Xigmatek'), 1, GETDATE());
    DECLARE @p1138 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1138, 'T-N-NHI-T-KH-XIGMATEK-WINDPOWER-II-1138', 380000, NULL, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1138, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20kh%C3%AD%20Xigmatek%20Windpow', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1138, N'Loại tản nhiệt', N'Khí', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1138, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1138, N'Kích thước quạt', N'90mm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-khi-thermaltake-ux100-1139')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt khí Thermaltake UX100', 'tan-nhiet-khi-thermaltake-ux100-1139', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'Thermaltake'), 1, GETDATE());
    DECLARE @p1139 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1139, 'T-N-NHI-T-KH-THERMALTAKE-UX100-1139', 420000, NULL, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1139, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20kh%C3%AD%20Thermaltake%20UX10', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1139, N'Loại tản nhiệt', N'Khí', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1139, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1139, N'Kích thước quạt', N'120mm ARGB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-khi-xigmatek-scylla-ii-240mm-1140')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt khí Xigmatek Scylla II 240mm', 'tan-nhiet-khi-xigmatek-scylla-ii-240mm-1140', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'Xigmatek'), 1, GETDATE());
    DECLARE @p1140 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1140, 'T-N-NHI-T-KH-XIGMATEK-SCYLLA-II-240MM-1140', 650000, NULL, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1140, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20kh%C3%AD%20Xigmatek%20Scylla%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1140, N'Loại tản nhiệt', N'Khí', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1140, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1140, N'Kích thước quạt', N'120mm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-khi-deepcool-ak500-1141')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt khí DeepCool AK500', 'tan-nhiet-khi-deepcool-ak500-1141', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'DeepCool'), 1, GETDATE());
    DECLARE @p1141 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1141, 'T-N-NHI-T-KH-DEEPCOOL-AK500-1141', 850000, NULL, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1141, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20kh%C3%AD%20DeepCool%20AK500', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1141, N'Loại tản nhiệt', N'Khí', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1141, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1141, N'Kích thước quạt', N'120mm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-khi-thermaltake-toughair-510-1142')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt khí Thermaltake Toughair 510', 'tan-nhiet-khi-thermaltake-toughair-510-1142', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'Thermaltake'), 1, GETDATE());
    DECLARE @p1142 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1142, 'T-N-NHI-T-KH-THERMALTAKE-TOUGHAIR-510-1142', 1050000, NULL, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1142, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20kh%C3%AD%20Thermaltake%20Toug', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1142, N'Loại tản nhiệt', N'Khí', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1142, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1142, N'Kích thước quạt', N'2x140mm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-nuoc-thermaltake-th240-argb-1143')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt nước Thermaltake TH240 ARGB', 'tan-nhiet-nuoc-thermaltake-th240-argb-1143', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'Thermaltake'), 1, GETDATE());
    DECLARE @p1143 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1143, 'T-N-NHI-T-N-C-THERMALTAKE-TH240-ARGB-1143', 1900000, NULL, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1143, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20n%C6%B0%E1%BB%9Bc%20Thermaltake%20TH2', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1143, N'Loại tản nhiệt', N'Nước AIO', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1143, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1143, N'Kích thước quạt', N'2x120mm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-nuoc-deepcool-ls720-1144')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt nước DeepCool LS720', 'tan-nhiet-nuoc-deepcool-ls720-1144', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'DeepCool'), 1, GETDATE());
    DECLARE @p1144 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1144, 'T-N-NHI-T-N-C-DEEPCOOL-LS720-1144', 2800000, NULL, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1144, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20n%C6%B0%E1%BB%9Bc%20DeepCool%20LS720', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1144, N'Loại tản nhiệt', N'Nước AIO', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1144, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1144, N'Kích thước quạt', N'3x120mm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-nuoc-corsair-icue-h150i-elite-lcd-1145')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt nước Corsair iCUE H150i Elite LCD', 'tan-nhiet-nuoc-corsair-icue-h150i-elite-lcd-1145', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p1145 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1145, 'T-N-NHI-T-N-C-CORSAIR-ICUE-H150I-ELITE-L-1145', 5200000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1145, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20n%C6%B0%E1%BB%9Bc%20Corsair%20iCUE%20H1', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1145, N'Loại tản nhiệt', N'Nước AIO', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1145, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1145, N'Kích thước quạt', N'3x120mm, màn LCD', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-nuoc-nzxt-kraken-elite-360-1146')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt nước NZXT Kraken Elite 360', 'tan-nhiet-nuoc-nzxt-kraken-elite-360-1146', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'NZXT'), 1, GETDATE());
    DECLARE @p1146 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1146, 'T-N-NHI-T-N-C-NZXT-KRAKEN-ELITE-360-1146', 4800000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1146, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20n%C6%B0%E1%BB%9Bc%20NZXT%20Kraken%20Eli', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1146, N'Loại tản nhiệt', N'Nước AIO', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1146, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1146, N'Kích thước quạt', N'3x120mm, màn LCD', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-khi-xigmatek-voyager-1147')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt khí Xigmatek Voyager', 'tan-nhiet-khi-xigmatek-voyager-1147', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'Xigmatek'), 1, GETDATE());
    DECLARE @p1147 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1147, 'T-N-NHI-T-KH-XIGMATEK-VOYAGER-1147', 320000, NULL, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1147, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20kh%C3%AD%20Xigmatek%20Voyager', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1147, N'Loại tản nhiệt', N'Khí', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1147, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1147, N'Kích thước quạt', N'92mm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-khi-thermaltake-contac-silent-12-1148')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt khí Thermaltake Contac Silent 12', 'tan-nhiet-khi-thermaltake-contac-silent-12-1148', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'Thermaltake'), 1, GETDATE());
    DECLARE @p1148 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1148, 'T-N-NHI-T-KH-THERMALTAKE-CONTAC-SILENT-1-1148', 480000, 547000, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1148, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20kh%C3%AD%20Thermaltake%20Cont', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1148, N'Loại tản nhiệt', N'Khí', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1148, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1148, N'Kích thước quạt', N'120mm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-nuoc-thermaltake-th360-argb-1149')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt nước Thermaltake TH360 ARGB', 'tan-nhiet-nuoc-thermaltake-th360-argb-1149', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'Thermaltake'), 1, GETDATE());
    DECLARE @p1149 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1149, 'T-N-NHI-T-N-C-THERMALTAKE-TH360-ARGB-1149', 2400000, 2616000, 35, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1149, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20n%C6%B0%E1%BB%9Bc%20Thermaltake%20TH3', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1149, N'Loại tản nhiệt', N'Nước AIO', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1149, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1149, N'Kích thước quạt', N'3x120mm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-xiaomi-24-inch-100hz-1150')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình Xiaomi 24 inch 100Hz', 'man-hinh-xiaomi-24-inch-100hz-1150', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'Xiaomi'), 1, GETDATE());
    DECLARE @p1150 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1150, 'M-N-H-NH-XIAOMI-24-INCH-100HZ-1150', 2500000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1150, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20Xiaomi%2024%20inch%20100Hz', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1150, N'Kích thước', N'24 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1150, N'Tần số quét', N'100Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1150, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-aoc-22-inch-75hz-1151')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình AOC 22 inch 75Hz', 'man-hinh-aoc-22-inch-75hz-1151', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'AOC'), 1, GETDATE());
    DECLARE @p1151 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1151, 'M-N-H-NH-AOC-22-INCH-75HZ-1151', 2100000, 2415000, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1151, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20AOC%2022%20inch%2075Hz', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1151, N'Kích thước', N'22 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1151, N'Tần số quét', N'75Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1151, N'Tấm nền', N'VA', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-viewsonic-22-inch-75hz-1152')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình ViewSonic 22 inch 75Hz', 'man-hinh-viewsonic-22-inch-75hz-1152', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'ViewSonic'), 1, GETDATE());
    DECLARE @p1152 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1152, 'M-N-H-NH-VIEWSONIC-22-INCH-75HZ-1152', 2200000, 2530000, 40, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1152, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20ViewSonic%2022%20inch%2075H', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1152, N'Kích thước', N'22 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1152, N'Tần số quét', N'75Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1152, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-samsung-27-inch-75hz-1153')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình Samsung 27 inch 75Hz', 'man-hinh-samsung-27-inch-75hz-1153', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p1153 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1153, 'M-N-H-NH-SAMSUNG-27-INCH-75HZ-1153', 3100000, 3565000, 24, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1153, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20Samsung%2027%20inch%2075Hz', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1153, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1153, N'Tần số quét', N'75Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1153, N'Tấm nền', N'VA', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-lg-27-inch-75hz-1154')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình LG 27 inch 75Hz', 'man-hinh-lg-27-inch-75hz-1154', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'LG'), 1, GETDATE());
    DECLARE @p1154 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1154, 'M-N-H-NH-LG-27-INCH-75HZ-1154', 3200000, NULL, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1154, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20LG%2027%20inch%2075Hz', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1154, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1154, N'Tần số quét', N'75Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1154, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-xiaomi-27-inch-165hz-1155')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình Xiaomi 27 inch 165Hz', 'man-hinh-xiaomi-27-inch-165hz-1155', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'Xiaomi'), 1, GETDATE());
    DECLARE @p1155 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1155, 'M-N-H-NH-XIAOMI-27-INCH-165HZ-1155', 5400000, NULL, 21, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1155, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20Xiaomi%2027%20inch%20165Hz', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1155, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1155, N'Tần số quét', N'165Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1155, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-samsung-odyssey-g4-27-inch-165hz-1156')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình Samsung Odyssey G4 27 inch 165Hz', 'man-hinh-samsung-odyssey-g4-27-inch-165hz-1156', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p1156 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1156, 'M-N-H-NH-SAMSUNG-ODYSSEY-G4-27-INCH-165H-1156', 6800000, NULL, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1156, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20Samsung%20Odyssey%20G4%2027', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1156, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1156, N'Tần số quét', N'165Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1156, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-lg-ultragear-27-inch-165hz-1157')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình LG UltraGear 27 inch 165Hz', 'man-hinh-lg-ultragear-27-inch-165hz-1157', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'LG'), 1, GETDATE());
    DECLARE @p1157 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1157, 'M-N-H-NH-LG-ULTRAGEAR-27-INCH-165HZ-1157', 6500000, NULL, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1157, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20LG%20UltraGear%2027%20inch%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1157, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1157, N'Tần số quét', N'165Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1157, N'Tấm nền', N'Nano IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-aoc-gaming-27-inch-165hz-1158')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình AOC Gaming 27 inch 165Hz', 'man-hinh-aoc-gaming-27-inch-165hz-1158', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'AOC'), 1, GETDATE());
    DECLARE @p1158 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1158, 'M-N-H-NH-AOC-GAMING-27-INCH-165HZ-1158', 6000000, 6720000, 35, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1158, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20AOC%20Gaming%2027%20inch%2016', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1158, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1158, N'Tần số quét', N'165Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1158, N'Tấm nền', N'VA', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-asus-tuf-27-inch-180hz-1159')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình ASUS TUF 27 inch 180Hz', 'man-hinh-asus-tuf-27-inch-180hz-1159', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1159 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1159, 'M-N-H-NH-ASUS-TUF-27-INCH-180HZ-1159', 6900000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1159, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20ASUS%20TUF%2027%20inch%20180H', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1159, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1159, N'Tần số quét', N'180Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1159, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-benq-zowie-24-inch-240hz-1160')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình BenQ Zowie 24 inch 240Hz', 'man-hinh-benq-zowie-24-inch-240hz-1160', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'BenQ'), 1, GETDATE());
    DECLARE @p1160 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1160, 'M-N-H-NH-BENQ-ZOWIE-24-INCH-240HZ-1160', 9500000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1160, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20BenQ%20Zowie%2024%20inch%2024', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1160, N'Kích thước', N'24 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1160, N'Tần số quét', N'240Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1160, N'Tấm nền', N'TN', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-viewsonic-elite-27-inch-240hz-1161')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình ViewSonic Elite 27 inch 240Hz', 'man-hinh-viewsonic-elite-27-inch-240hz-1161', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'ViewSonic'), 1, GETDATE());
    DECLARE @p1161 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1161, 'M-N-H-NH-VIEWSONIC-ELITE-27-INCH-240HZ-1161', 10500000, 11760000, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1161, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20ViewSonic%20Elite%2027%20in', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1161, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1161, N'Tần số quét', N'240Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1161, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-asus-rog-swift-27-inch-360hz-1162')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình ASUS ROG Swift 27 inch 360Hz', 'man-hinh-asus-rog-swift-27-inch-360hz-1162', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1162 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1162, 'M-N-H-NH-ASUS-ROG-SWIFT-27-INCH-360HZ-1162', 16500000, NULL, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1162, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20ASUS%20ROG%20Swift%2027%20inc', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1162, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1162, N'Tần số quét', N'360Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1162, N'Tấm nền', N'TN', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-lg-ultragear-32-inch-240hz-1163')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình LG UltraGear 32 inch 240Hz', 'man-hinh-lg-ultragear-32-inch-240hz-1163', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'LG'), 1, GETDATE());
    DECLARE @p1163 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1163, 'M-N-H-NH-LG-ULTRAGEAR-32-INCH-240HZ-1163', 14800000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1163, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20LG%20UltraGear%2032%20inch%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1163, N'Kích thước', N'32 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1163, N'Tần số quét', N'240Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1163, N'Tấm nền', N'Nano IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-samsung-odyssey-oled-g8-32-inch-240hz-1164')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình Samsung Odyssey OLED G8 32 inch 240Hz', 'man-hinh-samsung-odyssey-oled-g8-32-inch-240hz-1164', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p1164 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1164, 'M-N-H-NH-SAMSUNG-ODYSSEY-OLED-G8-32-INCH-1164', 21500000, 24080000, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1164, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20Samsung%20Odyssey%20OLED%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1164, N'Kích thước', N'32 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1164, N'Tần số quét', N'240Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1164, N'Tấm nền', N'QD-OLED', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-lg-ultrawide-29-inch-100hz-1165')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình LG UltraWide 29 inch 100Hz', 'man-hinh-lg-ultrawide-29-inch-100hz-1165', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'LG'), 1, GETDATE());
    DECLARE @p1165 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1165, 'M-N-H-NH-LG-ULTRAWIDE-29-INCH-100HZ-1165', 6200000, NULL, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1165, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20LG%20UltraWide%2029%20inch%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1165, N'Kích thước', N'29 inch Ultrawide', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1165, N'Tần số quét', N'100Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1165, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-samsung-ultrawide-34-inch-165hz-1166')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình Samsung UltraWide 34 inch 165Hz', 'man-hinh-samsung-ultrawide-34-inch-165hz-1166', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p1166 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1166, 'M-N-H-NH-SAMSUNG-ULTRAWIDE-34-INCH-165HZ-1166', 13500000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1166, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20Samsung%20UltraWide%2034%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1166, N'Kích thước', N'34 inch Ultrawide', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1166, N'Tần số quét', N'165Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1166, N'Tấm nền', N'VA', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-aoc-ultrawide-34-inch-144hz-1167')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình AOC Ultrawide 34 inch 144Hz', 'man-hinh-aoc-ultrawide-34-inch-144hz-1167', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'AOC'), 1, GETDATE());
    DECLARE @p1167 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1167, 'M-N-H-NH-AOC-ULTRAWIDE-34-INCH-144HZ-1167', 11200000, NULL, 40, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1167, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20AOC%20Ultrawide%2034%20inch', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1167, N'Kích thước', N'34 inch Ultrawide', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1167, N'Tần số quét', N'144Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1167, N'Tấm nền', N'VA', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-dell-ultrasharp-27-inch-4k-1168')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình Dell UltraSharp 27 inch 4K', 'man-hinh-dell-ultrasharp-27-inch-4k-1168', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'Dell'), 1, GETDATE());
    DECLARE @p1168 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1168, 'M-N-H-NH-DELL-ULTRASHARP-27-INCH-4K-1168', 12500000, NULL, 31, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1168, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20Dell%20UltraSharp%2027%20in', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1168, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1168, N'Tần số quét', N'60Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1168, N'Tấm nền', N'IPS', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1168, N'Độ phân giải', N'4K UHD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-lg-27-inch-4k-uhd-1169')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình LG 27 inch 4K UHD', 'man-hinh-lg-27-inch-4k-uhd-1169', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'LG'), 1, GETDATE());
    DECLARE @p1169 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1169, 'M-N-H-NH-LG-27-INCH-4K-UHD-1169', 10800000, 11448000, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1169, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20LG%2027%20inch%204K%20UHD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1169, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1169, N'Tần số quét', N'60Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1169, N'Tấm nền', N'IPS', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1169, N'Độ phân giải', N'4K UHD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-samsung-viewfinity-32-inch-4k-1170')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình Samsung ViewFinity 32 inch 4K', 'man-hinh-samsung-viewfinity-32-inch-4k-1170', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p1170 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1170, 'M-N-H-NH-SAMSUNG-VIEWFINITY-32-INCH-4K-1170', 13200000, 14916000, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1170, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20Samsung%20ViewFinity%2032', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1170, N'Kích thước', N'32 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1170, N'Tần số quét', N'60Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1170, N'Tấm nền', N'IPS', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1170, N'Độ phân giải', N'4K UHD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-asus-proart-27-inch-4k-1171')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình ASUS ProArt 27 inch 4K', 'man-hinh-asus-proart-27-inch-4k-1171', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1171 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1171, 'M-N-H-NH-ASUS-PROART-27-INCH-4K-1171', 15900000, NULL, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1171, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20ASUS%20ProArt%2027%20inch%204', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1171, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1171, N'Tần số quét', N'60Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1171, N'Tấm nền', N'IPS', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1171, N'Độ phân giải', N'4K UHD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-xiaomi-24-inch-75hz-1172')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình Xiaomi 24 inch 75Hz', 'man-hinh-xiaomi-24-inch-75hz-1172', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'Xiaomi'), 1, GETDATE());
    DECLARE @p1172 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1172, 'M-N-H-NH-XIAOMI-24-INCH-75HZ-1172', 2400000, NULL, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1172, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20Xiaomi%2024%20inch%2075Hz', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1172, N'Kích thước', N'24 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1172, N'Tần số quét', N'75Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1172, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-benq-24-inch-75hz-1173')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình BenQ 24 inch 75Hz', 'man-hinh-benq-24-inch-75hz-1173', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'BenQ'), 1, GETDATE());
    DECLARE @p1173 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1173, 'M-N-H-NH-BENQ-24-INCH-75HZ-1173', 2900000, 3277000, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1173, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20BenQ%2024%20inch%2075Hz', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1173, N'Kích thước', N'24 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1173, N'Tần số quét', N'75Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1173, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-asus-tuf-24-inch-165hz-1174')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình ASUS TUF 24 inch 165Hz', 'man-hinh-asus-tuf-24-inch-165hz-1174', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1174 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1174, 'M-N-H-NH-ASUS-TUF-24-INCH-165HZ-1174', 5100000, NULL, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1174, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20ASUS%20TUF%2024%20inch%20165H', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1174, N'Kích thước', N'24 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1174, N'Tần số quét', N'165Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1174, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-dell-ultrasharp-32-inch-4k-1175')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình Dell UltraSharp 32 inch 4K', 'man-hinh-dell-ultrasharp-32-inch-4k-1175', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'Dell'), 1, GETDATE());
    DECLARE @p1175 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1175, 'M-N-H-NH-DELL-ULTRASHARP-32-INCH-4K-1175', 16800000, NULL, 30, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1175, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20Dell%20UltraSharp%2032%20in', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1175, N'Kích thước', N'32 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1175, N'Tần số quét', N'60Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1175, N'Tấm nền', N'IPS', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1175, N'Độ phân giải', N'4K UHD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-rapoo-v500-1176')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ Rapoo V500', 'ban-phim-co-rapoo-v500-1176', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Rapoo'), 1, GETDATE());
    DECLARE @p1176 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1176, 'B-N-PH-M-C-RAPOO-V500-1176', 550000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1176, 'https://placehold.co/400x400?text=B%C3%A0n%20ph%C3%ADm%20c%C6%A1%20Rapoo%20V500', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1176, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1176, N'Switch', N'Blue switch', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-e-dra-ek387w-1177')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ E-Dra EK387W', 'ban-phim-co-e-dra-ek387w-1177', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'E-Dra'), 1, GETDATE());
    DECLARE @p1177 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1177, 'B-N-PH-M-C-E-DRA-EK387W-1177', 700000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1177, 'https://placehold.co/400x400?text=B%C3%A0n%20ph%C3%ADm%20c%C6%A1%20E-Dra%20EK387W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1177, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1177, N'Switch', N'Blue switch', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-rapoo-v500-pro-1178')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ Rapoo V500 Pro', 'ban-phim-co-rapoo-v500-pro-1178', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Rapoo'), 1, GETDATE());
    DECLARE @p1178 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1178, 'B-N-PH-M-C-RAPOO-V500-PRO-1178', 850000, NULL, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1178, 'https://placehold.co/400x400?text=B%C3%A0n%20ph%C3%ADm%20c%C6%A1%20Rapoo%20V500%20Pro', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1178, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1178, N'Switch', N'Red switch', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-e-dra-ek3104-1179')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ E-Dra EK3104', 'ban-phim-co-e-dra-ek3104-1179', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'E-Dra'), 1, GETDATE());
    DECLARE @p1179 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1179, 'B-N-PH-M-C-E-DRA-EK3104-1179', 950000, NULL, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1179, 'https://placehold.co/400x400?text=B%C3%A0n%20ph%C3%ADm%20c%C6%A1%20E-Dra%20EK3104', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1179, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1179, N'Switch', N'Brown switch', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-keychron-k10-1180')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ Keychron K10', 'ban-phim-co-keychron-k10-1180', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Keychron'), 1, GETDATE());
    DECLARE @p1180 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1180, 'B-N-PH-M-C-KEYCHRON-K10-1180', 2200000, NULL, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1180, 'https://placehold.co/400x400?text=B%C3%A0n%20ph%C3%ADm%20c%C6%A1%20Keychron%20K10', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1180, N'Kết nối', N'Bluetooth / USB-C', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1180, N'Switch', N'Gateron Brown', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-keychron-q3-1181')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ Keychron Q3', 'ban-phim-co-keychron-q3-1181', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Keychron'), 1, GETDATE());
    DECLARE @p1181 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1181, 'B-N-PH-M-C-KEYCHRON-Q3-1181', 3200000, NULL, 14, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1181, 'https://placehold.co/400x400?text=B%C3%A0n%20ph%C3%ADm%20c%C6%A1%20Keychron%20Q3', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1181, N'Kết nối', N'Có dây USB-C', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1181, N'Switch', N'Gateron Pro hot-swap', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-razer-huntsman-v3-pro-1182')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ Razer Huntsman V3 Pro', 'ban-phim-co-razer-huntsman-v3-pro-1182', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Razer'), 1, GETDATE());
    DECLARE @p1182 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1182, 'B-N-PH-M-C-RAZER-HUNTSMAN-V3-PRO-1182', 4500000, 4725000, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1182, 'https://placehold.co/400x400?text=B%C3%A0n%20ph%C3%ADm%20c%C6%A1%20Razer%20Huntsman%20V3%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1182, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1182, N'Switch', N'Optical Analog', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-rapoo-vt9-1183')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột Rapoo VT9', 'chuot-rapoo-vt9-1183', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Rapoo'), 1, GETDATE());
    DECLARE @p1183 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1183, 'CHU-T-RAPOO-VT9-1183', 480000, 538000, 21, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1183, 'https://placehold.co/400x400?text=Chu%E1%BB%99t%20Rapoo%20VT9', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1183, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1183, N'DPI', N'16000 DPI', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-e-dra-em620-1184')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột E-Dra EM620', 'chuot-e-dra-em620-1184', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'E-Dra'), 1, GETDATE());
    DECLARE @p1184 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1184, 'CHU-T-E-DRA-EM620-1184', 350000, NULL, 21, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1184, 'https://placehold.co/400x400?text=Chu%E1%BB%99t%20E-Dra%20EM620', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1184, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1184, N'DPI', N'6400 DPI', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-logitech-m331-silent-1185')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột Logitech M331 Silent', 'chuot-logitech-m331-silent-1185', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p1185 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1185, 'CHU-T-LOGITECH-M331-SILENT-1185', 380000, NULL, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1185, 'https://placehold.co/400x400?text=Chu%E1%BB%99t%20Logitech%20M331%20Silent', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1185, N'Kết nối', N'Không dây 2.4GHz', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1185, N'DPI', N'1000 DPI', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-logitech-mx-master-3s-1186')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột Logitech MX Master 3S', 'chuot-logitech-mx-master-3s-1186', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p1186 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1186, 'CHU-T-LOGITECH-MX-MASTER-3S-1186', 2400000, 2592000, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1186, 'https://placehold.co/400x400?text=Chu%E1%BB%99t%20Logitech%20MX%20Master%203S', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1186, N'Kết nối', N'Bluetooth / 2.4GHz', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1186, N'DPI', N'8000 DPI', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-razer-basilisk-v3-1187')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột Razer Basilisk V3', 'chuot-razer-basilisk-v3-1187', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Razer'), 1, GETDATE());
    DECLARE @p1187 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1187, 'CHU-T-RAZER-BASILISK-V3-1187', 1400000, 1484000, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1187, 'https://placehold.co/400x400?text=Chu%E1%BB%99t%20Razer%20Basilisk%20V3', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1187, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1187, N'DPI', N'26000 DPI', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-steelseries-aerox-5-1188')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột SteelSeries Aerox 5', 'chuot-steelseries-aerox-5-1188', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'SteelSeries'), 1, GETDATE());
    DECLARE @p1188 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1188, 'CHU-T-STEELSERIES-AEROX-5-1188', 1900000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1188, 'https://placehold.co/400x400?text=Chu%E1%BB%99t%20SteelSeries%20Aerox%205', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1188, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1188, N'DPI', N'18000 DPI', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tai-nghe-rapoo-vh500-1189')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tai nghe Rapoo VH500', 'tai-nghe-rapoo-vh500-1189', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Rapoo'), 1, GETDATE());
    DECLARE @p1189 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1189, 'TAI-NGHE-RAPOO-VH500-1189', 550000, NULL, 35, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1189, 'https://placehold.co/400x400?text=Tai%20nghe%20Rapoo%20VH500', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1189, N'Kết nối', N'Có dây 3.5mm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1189, N'Driver', N'50mm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tai-nghe-e-dra-eh250-1190')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tai nghe E-Dra EH250', 'tai-nghe-e-dra-eh250-1190', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'E-Dra'), 1, GETDATE());
    DECLARE @p1190 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1190, 'TAI-NGHE-E-DRA-EH250-1190', 480000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1190, 'https://placehold.co/400x400?text=Tai%20nghe%20E-Dra%20EH250', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1190, N'Kết nối', N'Có dây 3.5mm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1190, N'Driver', N'40mm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tai-nghe-logitech-g335-wireless-1191')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tai nghe Logitech G335 Wireless', 'tai-nghe-logitech-g335-wireless-1191', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p1191 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1191, 'TAI-NGHE-LOGITECH-G335-WIRELESS-1191', 1500000, 1680000, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1191, 'https://placehold.co/400x400?text=Tai%20nghe%20Logitech%20G335%20Wireles', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1191, N'Kết nối', N'Không dây 2.4GHz', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1191, N'Driver', N'40mm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tai-nghe-steelseries-arctis-nova-5-1192')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tai nghe SteelSeries Arctis Nova 5', 'tai-nghe-steelseries-arctis-nova-5-1192', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'SteelSeries'), 1, GETDATE());
    DECLARE @p1192 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1192, 'TAI-NGHE-STEELSERIES-ARCTIS-NOVA-5-1192', 2900000, NULL, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1192, 'https://placehold.co/400x400?text=Tai%20nghe%20SteelSeries%20Arctis%20No', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1192, N'Kết nối', N'Không dây 2.4GHz', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1192, N'Driver', N'40mm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tai-nghe-hyperx-cloud-alpha-1193')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tai nghe HyperX Cloud Alpha', 'tai-nghe-hyperx-cloud-alpha-1193', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'HyperX'), 1, GETDATE());
    DECLARE @p1193 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1193, 'TAI-NGHE-HYPERX-CLOUD-ALPHA-1193', 1700000, NULL, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1193, 'https://placehold.co/400x400?text=Tai%20nghe%20HyperX%20Cloud%20Alpha', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1193, N'Kết nối', N'Có dây 3.5mm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1193, N'Driver', N'50mm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'webcam-rapoo-c260-1194')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Webcam Rapoo C260', 'webcam-rapoo-c260-1194', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Rapoo'), 1, GETDATE());
    DECLARE @p1194 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1194, 'WEBCAM-RAPOO-C260-1194', 550000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1194, 'https://placehold.co/400x400?text=Webcam%20Rapoo%20C260', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1194, N'Kết nối', N'USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1194, N'Độ phân giải', N'1080p 30fps', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'webcam-logitech-streamcam-1195')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Webcam Logitech StreamCam', 'webcam-logitech-streamcam-1195', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p1195 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1195, 'WEBCAM-LOGITECH-STREAMCAM-1195', 2400000, 2592000, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1195, 'https://placehold.co/400x400?text=Webcam%20Logitech%20StreamCam', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1195, N'Kết nối', N'USB-C', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1195, N'Độ phân giải', N'1080p 60fps', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'webcam-logitech-c922-pro-1196')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Webcam Logitech C922 Pro', 'webcam-logitech-c922-pro-1196', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p1196 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1196, 'WEBCAM-LOGITECH-C922-PRO-1196', 1900000, NULL, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1196, 'https://placehold.co/400x400?text=Webcam%20Logitech%20C922%20Pro', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1196, N'Kết nối', N'USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1196, N'Độ phân giải', N'1080p 30fps', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'loa-vi-tinh-rapoo-a100-1197')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Loa vi tính Rapoo A100', 'loa-vi-tinh-rapoo-a100-1197', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Rapoo'), 1, GETDATE());
    DECLARE @p1197 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1197, 'LOA-VI-T-NH-RAPOO-A100-1197', 350000, NULL, 39, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1197, 'https://placehold.co/400x400?text=Loa%20vi%20t%C3%ADnh%20Rapoo%20A100', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1197, N'Kết nối', N'3.5mm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1197, N'Công suất', N'2.0 kênh', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'loa-vi-tinh-logitech-z313-1198')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Loa vi tính Logitech Z313', 'loa-vi-tinh-logitech-z313-1198', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p1198 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1198, 'LOA-VI-T-NH-LOGITECH-Z313-1198', 950000, NULL, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1198, 'https://placehold.co/400x400?text=Loa%20vi%20t%C3%ADnh%20Logitech%20Z313', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1198, N'Kết nối', N'3.5mm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1198, N'Công suất', N'2.1 kênh', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'loa-vi-tinh-logitech-g560-1199')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Loa vi tính Logitech G560', 'loa-vi-tinh-logitech-g560-1199', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p1199 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1199, 'LOA-VI-T-NH-LOGITECH-G560-1199', 3500000, 3710000, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1199, 'https://placehold.co/400x400?text=Loa%20vi%20t%C3%ADnh%20Logitech%20G560', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1199, N'Kết nối', N'USB / Bluetooth', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1199, N'Công suất', N'2.1 kênh RGB', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-steelseries-apex-pro-1200')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ SteelSeries Apex Pro', 'ban-phim-co-steelseries-apex-pro-1200', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'SteelSeries'), 1, GETDATE());
    DECLARE @p1200 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1200, 'B-N-PH-M-C-STEELSERIES-APEX-PRO-1200', 4900000, 5586000, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1200, 'https://placehold.co/400x400?text=B%C3%A0n%20ph%C3%ADm%20c%C6%A1%20SteelSeries%20Apex%20P', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1200, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1200, N'Switch', N'OmniPoint Adjustable', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-keychron-m3-1201')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột Keychron M3', 'chuot-keychron-m3-1201', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Keychron'), 1, GETDATE());
    DECLARE @p1201 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1201, 'CHU-T-KEYCHRON-M3-1201', 1100000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1201, 'https://placehold.co/400x400?text=Chu%E1%BB%99t%20Keychron%20M3', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1201, N'Kết nối', N'Bluetooth / 2.4GHz / USB-C', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1201, N'DPI', N'26000 DPI', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-rapoo-v700-1202')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ Rapoo V700', 'ban-phim-co-rapoo-v700-1202', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Rapoo'), 1, GETDATE());
    DECLARE @p1202 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1202, 'B-N-PH-M-C-RAPOO-V700-1202', 780000, NULL, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1202, 'https://placehold.co/400x400?text=B%C3%A0n%20ph%C3%ADm%20c%C6%A1%20Rapoo%20V700', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1202, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1202, N'Switch', N'Brown switch', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-razer-cobra-1203')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột Razer Cobra', 'chuot-razer-cobra-1203', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Razer'), 1, GETDATE());
    DECLARE @p1203 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1203, 'CHU-T-RAZER-COBRA-1203', 650000, NULL, 21, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1203, 'https://placehold.co/400x400?text=Chu%E1%BB%99t%20Razer%20Cobra', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1203, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1203, N'DPI', N'8500 DPI', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-steelseries-prime-mini-1204')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột SteelSeries Prime Mini', 'chuot-steelseries-prime-mini-1204', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'SteelSeries'), 1, GETDATE());
    DECLARE @p1204 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1204, 'CHU-T-STEELSERIES-PRIME-MINI-1204', 1200000, NULL, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1204, 'https://placehold.co/400x400?text=Chu%E1%BB%99t%20SteelSeries%20Prime%20Mini', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1204, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1204, N'DPI', N'18000 DPI', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tai-nghe-razer-kraken-v3-1205')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tai nghe Razer Kraken V3', 'tai-nghe-razer-kraken-v3-1205', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Razer'), 1, GETDATE());
    DECLARE @p1205 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1205, 'TAI-NGHE-RAZER-KRAKEN-V3-1205', 1600000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1205, 'https://placehold.co/400x400?text=Tai%20nghe%20Razer%20Kraken%20V3', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1205, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1205, N'Driver', N'50mm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'webcam-rapoo-c270-1206')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Webcam Rapoo C270', 'webcam-rapoo-c270-1206', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Rapoo'), 1, GETDATE());
    DECLARE @p1206 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1206, 'WEBCAM-RAPOO-C270-1206', 720000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1206, 'https://placehold.co/400x400?text=Webcam%20Rapoo%20C270', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1206, N'Kết nối', N'USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1206, N'Độ phân giải', N'1080p 30fps', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'loa-vi-tinh-steelseries-arena-3-1207')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Loa vi tính SteelSeries Arena 3', 'loa-vi-tinh-steelseries-arena-3-1207', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'SteelSeries'), 1, GETDATE());
    DECLARE @p1207 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1207, 'LOA-VI-T-NH-STEELSERIES-ARENA-3-1207', 1800000, 1908000, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1207, 'https://placehold.co/400x400?text=Loa%20vi%20t%C3%ADnh%20SteelSeries%20Arena%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1207, N'Kết nối', N'Bluetooth / 3.5mm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1207, N'Công suất', N'2.0 kênh', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-logitech-g715-1208')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ Logitech G715', 'ban-phim-co-logitech-g715-1208', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p1208 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1208, 'B-N-PH-M-C-LOGITECH-G715-1208', 3900000, NULL, 31, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1208, 'https://placehold.co/400x400?text=B%C3%A0n%20ph%C3%ADm%20c%C6%A1%20Logitech%20G715', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1208, N'Kết nối', N'Bluetooth / 2.4GHz', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1208, N'Switch', N'GX Brown', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-logitech-g304-1209')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột Logitech G304', 'chuot-logitech-g304-1209', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p1209 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1209, 'CHU-T-LOGITECH-G304-1209', 550000, NULL, 24, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1209, 'https://placehold.co/400x400?text=Chu%E1%BB%99t%20Logitech%20G304', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1209, N'Kết nối', N'Không dây 2.4GHz', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1209, N'DPI', N'12000 DPI', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'balo-laptop-rapoo-b200-1210')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Balo laptop Rapoo B200', 'balo-laptop-rapoo-b200-1210', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p1210 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1210, 'BALO-LAPTOP-RAPOO-B200-1210', 480000, NULL, 30, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1210, 'https://placehold.co/400x400?text=Balo%20laptop%20Rapoo%20B200', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1210, N'Chất liệu', N'Vải chống nước', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1210, N'Kích thước', N'15.6 inch', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tui-chong-soc-e-dra-13-inch-1211')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Túi chống sốc E-Dra 13 inch', 'tui-chong-soc-e-dra-13-inch-1211', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Ugreen'), 1, GETDATE());
    DECLARE @p1211 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1211, 'T-I-CH-NG-S-C-E-DRA-13-INCH-1211', 280000, NULL, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1211, 'https://placehold.co/400x400?text=T%C3%BAi%20ch%E1%BB%91ng%20s%E1%BB%91c%20E-Dra%2013%20inch', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1211, N'Chất liệu', N'Neoprene', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1211, N'Kích thước', N'13 inch', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'gia-do-man-hinh-ugreen-1212')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Giá đỡ màn hình Ugreen', 'gia-do-man-hinh-ugreen-1212', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Ugreen'), 1, GETDATE());
    DECLARE @p1212 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1212, 'GI-M-N-H-NH-UGREEN-1212', 650000, NULL, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1212, 'https://placehold.co/400x400?text=Gi%C3%A1%20%C4%91%E1%BB%A1%20m%C3%A0n%20h%C3%ACnh%20Ugreen', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1212, N'Chất liệu', N'Hợp kim nhôm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1212, N'Tải trọng', N'Tối đa 9kg', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'hub-usb-c-8-trong-1-ugreen-1213')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Hub USB-C 8 trong 1 Ugreen', 'hub-usb-c-8-trong-1-ugreen-1213', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Ugreen'), 1, GETDATE());
    DECLARE @p1213 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1213, 'HUB-USB-C-8-TRONG-1-UGREEN-1213', 750000, 825000, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1213, 'https://placehold.co/400x400?text=Hub%20USB-C%208%20trong%201%20Ugreen', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1213, N'Cổng kết nối', N'HDMI, USB 3.0, USB-C PD, SD/TF', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1213, N'Chuẩn', N'USB-C', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cap-hdmi-2-1-ugreen-2m-1214')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Cáp HDMI 2.1 Ugreen 2m', 'cap-hdmi-2-1-ugreen-2m-1214', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Ugreen'), 1, GETDATE());
    DECLARE @p1214 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1214, 'C-P-HDMI-2-1-UGREEN-2M-1214', 320000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1214, 'https://placehold.co/400x400?text=C%C3%A1p%20HDMI%202.1%20Ugreen%202m', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1214, N'Chiều dài', N'2m', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1214, N'Chuẩn', N'HDMI 2.1 8K', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cap-sac-usb-c-to-usb-c-anker-2m-1215')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Cáp sạc USB-C to USB-C Anker 2m', 'cap-sac-usb-c-to-usb-c-anker-2m-1215', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p1215 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1215, 'C-P-S-C-USB-C-TO-USB-C-ANKER-2M-1215', 350000, NULL, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1215, 'https://placehold.co/400x400?text=C%C3%A1p%20s%E1%BA%A1c%20USB-C%20to%20USB-C%20Anker%202', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1215, N'Chiều dài', N'2m', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1215, N'Công suất', N'100W', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'sac-nhanh-100w-anker-gan-1216')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Sạc nhanh 100W Anker GaN', 'sac-nhanh-100w-anker-gan-1216', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p1216 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1216, 'S-C-NHANH-100W-ANKER-GAN-1216', 1200000, NULL, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1216, 'https://placehold.co/400x400?text=S%E1%BA%A1c%20nhanh%20100W%20Anker%20GaN', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1216, N'Công suất', N'100W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1216, N'Chuẩn', N'GaN, USB-C PD', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'bo-phat-wifi-6e-tp-link-1217')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bộ phát WiFi 6E TP-Link', 'bo-phat-wifi-6e-tp-link-1217', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'TP-Link'), 1, GETDATE());
    DECLARE @p1217 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1217, 'B-PH-T-WIFI-6E-TP-LINK-1217', 1500000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1217, 'https://placehold.co/400x400?text=B%E1%BB%99%20ph%C3%A1t%20WiFi%206E%20TP-Link', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1217, N'Chuẩn', N'WiFi 6E', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1217, N'Tốc độ', N'Tối đa 5.4Gbps', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'router-wifi-tp-link-archer-ax55-1218')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Router WiFi TP-Link Archer AX55', 'router-wifi-tp-link-archer-ax55-1218', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'TP-Link'), 1, GETDATE());
    DECLARE @p1218 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1218, 'ROUTER-WIFI-TP-LINK-ARCHER-AX55-1218', 1350000, NULL, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1218, 'https://placehold.co/400x400?text=Router%20WiFi%20TP-Link%20Archer%20AX5', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1218, N'Chuẩn', N'WiFi 6 AX3000', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1218, N'Cổng kết nối', N'4x LAN Gigabit', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'sac-du-phong-anker-20000mah-1219')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Sạc dự phòng Anker 20000mAh', 'sac-du-phong-anker-20000mah-1219', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p1219 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1219, 'S-C-D-PH-NG-ANKER-20000MAH-1219', 950000, NULL, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1219, 'https://placehold.co/400x400?text=S%E1%BA%A1c%20d%E1%BB%B1%20ph%C3%B2ng%20Anker%2020000mAh', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1219, N'Dung lượng', N'20000mAh', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1219, N'Công suất', N'30W', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'sac-du-phong-anker-magsafe-10000mah-1220')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Sạc dự phòng Anker MagSafe 10000mAh', 'sac-du-phong-anker-magsafe-10000mah-1220', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p1220 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1220, 'S-C-D-PH-NG-ANKER-MAGSAFE-10000MAH-1220', 1100000, NULL, 21, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1220, 'https://placehold.co/400x400?text=S%E1%BA%A1c%20d%E1%BB%B1%20ph%C3%B2ng%20Anker%20MagSafe%20100', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1220, N'Dung lượng', N'10000mAh', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1220, N'Công suất', N'15W MagSafe', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tai-nghe-bluetooth-jbl-tune-510bt-1221')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tai nghe Bluetooth JBL Tune 510BT', 'tai-nghe-bluetooth-jbl-tune-510bt-1221', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'JBL'), 1, GETDATE());
    DECLARE @p1221 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1221, 'TAI-NGHE-BLUETOOTH-JBL-TUNE-510BT-1221', 850000, NULL, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1221, 'https://placehold.co/400x400?text=Tai%20nghe%20Bluetooth%20JBL%20Tune%2051', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1221, N'Kết nối', N'Bluetooth 5.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1221, N'Âm thanh', N'Bass mạnh', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'loa-bluetooth-jbl-go-3-1222')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Loa Bluetooth JBL Go 3', 'loa-bluetooth-jbl-go-3-1222', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'JBL'), 1, GETDATE());
    DECLARE @p1222 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1222, 'LOA-BLUETOOTH-JBL-GO-3-1222', 650000, NULL, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1222, 'https://placehold.co/400x400?text=Loa%20Bluetooth%20JBL%20Go%203', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1222, N'Kết nối', N'Bluetooth 5.1', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1222, N'Âm thanh', N'Chống nước IP67', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'loa-bluetooth-jbl-flip-6-1223')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Loa Bluetooth JBL Flip 6', 'loa-bluetooth-jbl-flip-6-1223', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'JBL'), 1, GETDATE());
    DECLARE @p1223 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1223, 'LOA-BLUETOOTH-JBL-FLIP-6-1223', 2500000, NULL, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1223, 'https://placehold.co/400x400?text=Loa%20Bluetooth%20JBL%20Flip%206', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1223, N'Kết nối', N'Bluetooth 5.1', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1223, N'Âm thanh', N'Chống nước IP67', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'lot-chuot-ugreen-size-m-1224')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Lót chuột Ugreen size M', 'lot-chuot-ugreen-size-m-1224', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Ugreen'), 1, GETDATE());
    DECLARE @p1224 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1224, 'L-T-CHU-T-UGREEN-SIZE-M-1224', 100000, NULL, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1224, 'https://placehold.co/400x400?text=L%C3%B3t%20chu%E1%BB%99t%20Ugreen%20size%20M', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1224, N'Chất liệu', N'Vải + cao su', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1224, N'Kích thước', N'40x30cm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'lot-chuot-rgb-anker-size-xl-1225')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Lót chuột RGB Anker size XL', 'lot-chuot-rgb-anker-size-xl-1225', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p1225 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1225, 'L-T-CHU-T-RGB-ANKER-SIZE-XL-1225', 750000, NULL, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1225, 'https://placehold.co/400x400?text=L%C3%B3t%20chu%E1%BB%99t%20RGB%20Anker%20size%20XL', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1225, N'Chất liệu', N'Vải + viền RGB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1225, N'Kích thước', N'90x30cm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tai-nghe-nhet-tai-jbl-tune-230nc-1226')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tai nghe nhét tai JBL Tune 230NC', 'tai-nghe-nhet-tai-jbl-tune-230nc-1226', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'JBL'), 1, GETDATE());
    DECLARE @p1226 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1226, 'TAI-NGHE-NH-T-TAI-JBL-TUNE-230NC-1226', 1500000, NULL, 24, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1226, 'https://placehold.co/400x400?text=Tai%20nghe%20nh%C3%A9t%20tai%20JBL%20Tune%20230', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1226, N'Kết nối', N'Bluetooth 5.2', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1226, N'Âm thanh', N'Chống ồn chủ động', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'balo-gaming-ugreen-15-6-inch-1227')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Balo gaming Ugreen 15.6 inch', 'balo-gaming-ugreen-15-6-inch-1227', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Ugreen'), 1, GETDATE());
    DECLARE @p1227 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1227, 'BALO-GAMING-UGREEN-15-6-INCH-1227', 550000, 621000, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1227, 'https://placehold.co/400x400?text=Balo%20gaming%20Ugreen%2015.6%20inch', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1227, N'Chất liệu', N'Vải chống nước', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1227, N'Kích thước', N'15.6 inch', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'gia-do-laptop-da-nang-anker-1228')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Giá đỡ laptop đa năng Anker', 'gia-do-laptop-da-nang-anker-1228', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p1228 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1228, 'GI-LAPTOP-A-N-NG-ANKER-1228', 480000, NULL, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1228, 'https://placehold.co/400x400?text=Gi%C3%A1%20%C4%91%E1%BB%A1%20laptop%20%C4%91a%20n%C4%83ng%20Anker', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1228, N'Chất liệu', N'Hợp kim nhôm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1228, N'Tải trọng', N'Tối đa 5kg', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cap-sac-lightning-anker-1m-1229')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Cáp sạc Lightning Anker 1m', 'cap-sac-lightning-anker-1m-1229', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p1229 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1229, 'C-P-S-C-LIGHTNING-ANKER-1M-1229', 220000, NULL, 24, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1229, 'https://placehold.co/400x400?text=C%C3%A1p%20s%E1%BA%A1c%20Lightning%20Anker%201m', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1229, N'Chiều dài', N'1m', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1229, N'Công suất', N'20W', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'balo-laptop-ugreen-16-inch-1230')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Balo laptop Ugreen 16 inch', 'balo-laptop-ugreen-16-inch-1230', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Ugreen'), 1, GETDATE());
    DECLARE @p1230 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1230, 'BALO-LAPTOP-UGREEN-16-INCH-1230', 720000, 821000, 35, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1230, 'https://placehold.co/400x400?text=Balo%20laptop%20Ugreen%2016%20inch', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1230, N'Chất liệu', N'Vải chống nước', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1230, N'Kích thước', N'16 inch', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'hub-usb-c-4-trong-1-anker-1231')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Hub USB-C 4 trong 1 Anker', 'hub-usb-c-4-trong-1-anker-1231', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p1231 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1231, 'HUB-USB-C-4-TRONG-1-ANKER-1231', 450000, NULL, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1231, 'https://placehold.co/400x400?text=Hub%20USB-C%204%20trong%201%20Anker', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1231, N'Cổng kết nối', N'HDMI, USB 3.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1231, N'Chuẩn', N'USB-C', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cap-displayport-ugreen-2m-1232')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Cáp DisplayPort Ugreen 2m', 'cap-displayport-ugreen-2m-1232', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Ugreen'), 1, GETDATE());
    DECLARE @p1232 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1232, 'C-P-DISPLAYPORT-UGREEN-2M-1232', 280000, 308000, 31, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1232, 'https://placehold.co/400x400?text=C%C3%A1p%20DisplayPort%20Ugreen%202m', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1232, N'Chiều dài', N'2m', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1232, N'Chuẩn', N'DisplayPort 1.4 8K', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'sac-du-phong-jbl-10000mah-1233')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Sạc dự phòng JBL 10000mAh', 'sac-du-phong-jbl-10000mah-1233', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'JBL'), 1, GETDATE());
    DECLARE @p1233 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1233, 'S-C-D-PH-NG-JBL-10000MAH-1233', 850000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1233, 'https://placehold.co/400x400?text=S%E1%BA%A1c%20d%E1%BB%B1%20ph%C3%B2ng%20JBL%2010000mAh', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1233, N'Dung lượng', N'10000mAh', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1233, N'Công suất', N'18W', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tui-dung-laptop-anker-chong-soc-15-6-inch-1234')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Túi đựng laptop Anker chống sốc 15.6 inch', 'tui-dung-laptop-anker-chong-soc-15-6-inch-1234', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p1234 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1234, 'T-I-NG-LAPTOP-ANKER-CH-NG-S-C-15-6-INCH-1234', 380000, NULL, 24, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1234, 'https://placehold.co/400x400?text=T%C3%BAi%20%C4%91%E1%BB%B1ng%20laptop%20Anker%20ch%E1%BB%91ng%20s%E1%BB%91', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1234, N'Chất liệu', N'Neoprene', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1234, N'Kích thước', N'15.6 inch', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'bo-phat-wifi-4g-tp-link-1235')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bộ phát WiFi 4G TP-Link', 'bo-phat-wifi-4g-tp-link-1235', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'TP-Link'), 1, GETDATE());
    DECLARE @p1235 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1235, 'B-PH-T-WIFI-4G-TP-LINK-1235', 1100000, 1199000, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1235, 'https://placehold.co/400x400?text=B%E1%BB%99%20ph%C3%A1t%20WiFi%204G%20TP-Link', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1235, N'Chuẩn', N'4G LTE', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1235, N'Tốc độ', N'Tối đa 150Mbps', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'loa-bluetooth-anker-soundcore-motion-1236')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Loa Bluetooth Anker Soundcore Motion+', 'loa-bluetooth-anker-soundcore-motion-1236', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p1236 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1236, 'LOA-BLUETOOTH-ANKER-SOUNDCORE-MOTION-1236', 1900000, 2166000, 39, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1236, 'https://placehold.co/400x400?text=Loa%20Bluetooth%20Anker%20Soundcore%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1236, N'Kết nối', N'Bluetooth 5.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1236, N'Âm thanh', N'Hi-Res, chống nước IPX7', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cap-sac-micro-usb-anker-1m-1237')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Cáp sạc Micro USB Anker 1m', 'cap-sac-micro-usb-anker-1m-1237', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p1237 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1237, 'C-P-S-C-MICRO-USB-ANKER-1M-1237', 150000, NULL, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1237, 'https://placehold.co/400x400?text=C%C3%A1p%20s%E1%BA%A1c%20Micro%20USB%20Anker%201m', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1237, N'Chiều dài', N'1m', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1237, N'Công suất', N'12W', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-tuf-gaming-a15-fa506-gaming-1238')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS TUF Gaming A15 FA506 Gaming', 'laptop-asus-tuf-gaming-a15-fa506-gaming-1238', N'AMD Ryzen 5 5600H, 8GB RAM, 512GB SSD, RTX 3050 4GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1238 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1238, 'LAPTOP-ASUS-TUF-GAMING-A15-FA506-GAMING-1238', 15900000, 17808000, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1238, 'https://placehold.co/400x400?text=Laptop%20ASUS%20TUF%20Gaming%20A15%20FA5', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1238, N'CPU', N'AMD Ryzen 5 5600H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1238, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1238, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1238, N'Card đồ họa', N'RTX 3050 4GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-acer-nitro-v16-gaming-1239')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Acer Nitro V16 Gaming', 'laptop-acer-nitro-v16-gaming-1239', N'Intel Core i5-13420H, 16GB RAM, 512GB SSD, RTX 4050 6GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ACER'), 1, GETDATE());
    DECLARE @p1239 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1239, 'LAPTOP-ACER-NITRO-V16-GAMING-1239', 20500000, NULL, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1239, 'https://placehold.co/400x400?text=Laptop%20Acer%20Nitro%20V16%20Gaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1239, N'CPU', N'Intel Core i5-13420H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1239, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1239, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1239, N'Card đồ họa', N'RTX 4050 6GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-msi-cyborg-15-gaming-1240')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop MSI Cyborg 15 Gaming', 'laptop-msi-cyborg-15-gaming-1240', N'Intel Core i5-13420H, 16GB RAM, 512GB SSD, RTX 4050 6GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1240 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1240, 'LAPTOP-MSI-CYBORG-15-GAMING-1240', 18900000, 21168000, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1240, 'https://placehold.co/400x400?text=Laptop%20MSI%20Cyborg%2015%20Gaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1240, N'CPU', N'Intel Core i5-13420H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1240, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1240, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1240, N'Card đồ họa', N'RTX 4050 6GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-lenovo-ideapad-gaming-3-gaming-1241')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Lenovo IdeaPad Gaming 3 Gaming', 'laptop-lenovo-ideapad-gaming-3-gaming-1241', N'AMD Ryzen 5 7535HS, 16GB RAM, 512GB SSD, RTX 3050 6GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Lenovo'), 1, GETDATE());
    DECLARE @p1241 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1241, 'LAPTOP-LENOVO-IDEAPAD-GAMING-3-GAMING-1241', 17900000, NULL, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1241, 'https://placehold.co/400x400?text=Laptop%20Lenovo%20IdeaPad%20Gaming%203', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1241, N'CPU', N'AMD Ryzen 5 7535HS', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1241, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1241, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1241, N'Card đồ họa', N'RTX 3050 6GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-hp-victus-15-gaming-1242')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop HP Victus 15 Gaming', 'laptop-hp-victus-15-gaming-1242', N'Intel Core i5-12500H, 16GB RAM, 512GB SSD, RTX 3050 4GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'HP'), 1, GETDATE());
    DECLARE @p1242 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1242, 'LAPTOP-HP-VICTUS-15-GAMING-1242', 17500000, NULL, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1242, 'https://placehold.co/400x400?text=Laptop%20HP%20Victus%2015%20Gaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1242, N'CPU', N'Intel Core i5-12500H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1242, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1242, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1242, N'Card đồ họa', N'RTX 3050 4GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-dell-g15-5530-gaming-1243')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Dell G15 5530 Gaming', 'laptop-dell-g15-5530-gaming-1243', N'Intel Core i7-13650HX, 16GB RAM, 512GB SSD, RTX 4050 6GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Dell'), 1, GETDATE());
    DECLARE @p1243 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1243, 'LAPTOP-DELL-G15-5530-GAMING-1243', 21500000, 23220000, 40, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1243, 'https://placehold.co/400x400?text=Laptop%20Dell%20G15%205530%20Gaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1243, N'CPU', N'Intel Core i7-13650HX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1243, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1243, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1243, N'Card đồ họa', N'RTX 4050 6GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-rog-strix-g16-g614-gaming-1244')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS ROG Strix G16 G614 Gaming', 'laptop-asus-rog-strix-g16-g614-gaming-1244', N'Intel Core i7-13650HX, 16GB RAM, 512GB SSD, RTX 4060 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1244 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1244, 'LAPTOP-ASUS-ROG-STRIX-G16-G614-GAMING-1244', 27900000, 30132000, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1244, 'https://placehold.co/400x400?text=Laptop%20ASUS%20ROG%20Strix%20G16%20G614', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1244, N'CPU', N'Intel Core i7-13650HX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1244, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1244, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1244, N'Card đồ họa', N'RTX 4060 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-acer-predator-triton-14-gaming-1245')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Acer Predator Triton 14 Gaming', 'laptop-acer-predator-triton-14-gaming-1245', N'Intel Core Ultra 7 155H, 16GB RAM, 1TB SSD, RTX 4060 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ACER'), 1, GETDATE());
    DECLARE @p1245 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1245, 'LAPTOP-ACER-PREDATOR-TRITON-14-GAMING-1245', 34500000, NULL, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1245, 'https://placehold.co/400x400?text=Laptop%20Acer%20Predator%20Triton%2014', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1245, N'CPU', N'Intel Core Ultra 7 155H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1245, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1245, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1245, N'Card đồ họa', N'RTX 4060 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-msi-stealth-16-gaming-1246')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop MSI Stealth 16 Gaming', 'laptop-msi-stealth-16-gaming-1246', N'Intel Core Ultra 9 185H, 32GB RAM, 1TB SSD, RTX 4070 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1246 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1246, 'LAPTOP-MSI-STEALTH-16-GAMING-1246', 36500000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1246, 'https://placehold.co/400x400?text=Laptop%20MSI%20Stealth%2016%20Gaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1246, N'CPU', N'Intel Core Ultra 9 185H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1246, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1246, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1246, N'Card đồ họa', N'RTX 4070 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-lenovo-legion-slim-5-gaming-1247')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Lenovo Legion Slim 5 Gaming', 'laptop-lenovo-legion-slim-5-gaming-1247', N'AMD Ryzen 7 7840HS, 16GB RAM, 1TB SSD, RTX 4060 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Lenovo'), 1, GETDATE());
    DECLARE @p1247 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1247, 'LAPTOP-LENOVO-LEGION-SLIM-5-GAMING-1247', 29500000, NULL, 35, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1247, 'https://placehold.co/400x400?text=Laptop%20Lenovo%20Legion%20Slim%205%20Ga', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1247, N'CPU', N'AMD Ryzen 7 7840HS', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1247, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1247, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1247, N'Card đồ họa', N'RTX 4060 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-hp-omen-16-2024-gaming-1248')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop HP Omen 16 2024 Gaming', 'laptop-hp-omen-16-2024-gaming-1248', N'Intel Core i7-14700HX, 16GB RAM, 1TB SSD, RTX 4070 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'HP'), 1, GETDATE());
    DECLARE @p1248 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1248, 'LAPTOP-HP-OMEN-16-2024-GAMING-1248', 33500000, NULL, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1248, 'https://placehold.co/400x400?text=Laptop%20HP%20Omen%2016%202024%20Gaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1248, N'CPU', N'Intel Core i7-14700HX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1248, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1248, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1248, N'Card đồ họa', N'RTX 4070 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-dell-alienware-m18-gaming-1249')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Dell Alienware m18 Gaming', 'laptop-dell-alienware-m18-gaming-1249', N'Intel Core i9-13980HX, 32GB RAM, 1TB SSD, RTX 4080 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Dell'), 1, GETDATE());
    DECLARE @p1249 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1249, 'LAPTOP-DELL-ALIENWARE-M18-GAMING-1249', 45500000, 47775000, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1249, 'https://placehold.co/400x400?text=Laptop%20Dell%20Alienware%20m18%20Gami', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1249, N'CPU', N'Intel Core i9-13980HX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1249, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1249, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1249, N'Card đồ họa', N'RTX 4080 12GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-rog-strix-g18-gaming-1250')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS ROG Strix G18 Gaming', 'laptop-asus-rog-strix-g18-gaming-1250', N'Intel Core i9-13980HX, 16GB RAM, 1TB SSD, RTX 4070 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1250 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1250, 'LAPTOP-ASUS-ROG-STRIX-G18-GAMING-1250', 43500000, NULL, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1250, 'https://placehold.co/400x400?text=Laptop%20ASUS%20ROG%20Strix%20G18%20Gami', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1250, N'CPU', N'Intel Core i9-13980HX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1250, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1250, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1250, N'Card đồ họa', N'RTX 4070 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-acer-predator-helios-18-gaming-1251')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Acer Predator Helios 18 Gaming', 'laptop-acer-predator-helios-18-gaming-1251', N'Intel Core i9-14900HX, 32GB RAM, 1TB SSD, RTX 4080 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ACER'), 1, GETDATE());
    DECLARE @p1251 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1251, 'LAPTOP-ACER-PREDATOR-HELIOS-18-GAMING-1251', 49500000, NULL, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1251, 'https://placehold.co/400x400?text=Laptop%20Acer%20Predator%20Helios%2018', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1251, N'CPU', N'Intel Core i9-14900HX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1251, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1251, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1251, N'Card đồ họa', N'RTX 4080 12GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-lenovo-legion-9i-gaming-1252')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Lenovo Legion 9i Gaming', 'laptop-lenovo-legion-9i-gaming-1252', N'Intel Core i9-14900HX, 32GB RAM, 2TB SSD, RTX 4090 16GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Lenovo'), 1, GETDATE());
    DECLARE @p1252 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1252, 'LAPTOP-LENOVO-LEGION-9I-GAMING-1252', 68500000, NULL, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1252, 'https://placehold.co/400x400?text=Laptop%20Lenovo%20Legion%209i%20Gaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1252, N'CPU', N'Intel Core i9-14900HX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1252, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1252, N'Ổ cứng', N'2TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1252, N'Card đồ họa', N'RTX 4090 16GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-acer-swift-go-14-van-phong-1253')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Acer Swift Go 14 Văn phòng', 'laptop-acer-swift-go-14-van-phong-1253', N'Intel Core i5-1335U, 16GB RAM, 512GB SSD, Intel Iris Xe.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ACER'), 1, GETDATE());
    DECLARE @p1253 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1253, 'LAPTOP-ACER-SWIFT-GO-14-V-N-PH-NG-1253', 15900000, NULL, 40, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1253, 'https://placehold.co/400x400?text=Laptop%20Acer%20Swift%20Go%2014%20V%C4%83n%20ph', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1253, N'CPU', N'Intel Core i5-1335U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1253, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1253, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1253, N'Card đồ họa', N'Intel Iris Xe', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-vivobook-16-van-phong-1254')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS Vivobook 16 Văn phòng', 'laptop-asus-vivobook-16-van-phong-1254', N'Intel Core i3-1315U, 8GB RAM, 512GB SSD, Intel UHD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1254 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1254, 'LAPTOP-ASUS-VIVOBOOK-16-V-N-PH-NG-1254', 13500000, NULL, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1254, 'https://placehold.co/400x400?text=Laptop%20ASUS%20Vivobook%2016%20V%C4%83n%20ph', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1254, N'CPU', N'Intel Core i3-1315U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1254, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1254, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1254, N'Card đồ họa', N'Intel UHD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-hp-pavilion-14-van-phong-1255')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop HP Pavilion 14 Văn phòng', 'laptop-hp-pavilion-14-van-phong-1255', N'Intel Core i5-1335U, 16GB RAM, 512GB SSD, Intel Iris Xe.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'HP'), 1, GETDATE());
    DECLARE @p1255 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1255, 'LAPTOP-HP-PAVILION-14-V-N-PH-NG-1255', 16900000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1255, 'https://placehold.co/400x400?text=Laptop%20HP%20Pavilion%2014%20V%C4%83n%20ph%C3%B2n', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1255, N'CPU', N'Intel Core i5-1335U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1255, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1255, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1255, N'Card đồ họa', N'Intel Iris Xe', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-lenovo-thinkbook-14-van-phong-1256')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Lenovo ThinkBook 14 Văn phòng', 'laptop-lenovo-thinkbook-14-van-phong-1256', N'Intel Core i5-1335U, 16GB RAM, 512GB SSD, Intel Iris Xe.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Lenovo'), 1, GETDATE());
    DECLARE @p1256 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1256, 'LAPTOP-LENOVO-THINKBOOK-14-V-N-PH-NG-1256', 18500000, 19610000, 21, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1256, 'https://placehold.co/400x400?text=Laptop%20Lenovo%20ThinkBook%2014%20V%C4%83n', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1256, N'CPU', N'Intel Core i5-1335U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1256, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1256, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1256, N'Card đồ họa', N'Intel Iris Xe', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-dell-latitude-3420-van-phong-1257')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Dell Latitude 3420 Văn phòng', 'laptop-dell-latitude-3420-van-phong-1257', N'Intel Core i5-1135G7, 8GB RAM, 256GB SSD, Intel Iris Xe.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Dell'), 1, GETDATE());
    DECLARE @p1257 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1257, 'LAPTOP-DELL-LATITUDE-3420-V-N-PH-NG-1257', 15500000, NULL, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1257, 'https://placehold.co/400x400?text=Laptop%20Dell%20Latitude%203420%20V%C4%83n%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1257, N'CPU', N'Intel Core i5-1135G7', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1257, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1257, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1257, N'Card đồ họa', N'Intel Iris Xe', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-expertbook-b3-van-phong-1258')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS ExpertBook B3 Văn phòng', 'laptop-asus-expertbook-b3-van-phong-1258', N'Intel Core i5-1235U, 8GB RAM, 512GB SSD, Intel UHD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1258 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1258, 'LAPTOP-ASUS-EXPERTBOOK-B3-V-N-PH-NG-1258', 16200000, NULL, 39, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1258, 'https://placehold.co/400x400?text=Laptop%20ASUS%20ExpertBook%20B3%20V%C4%83n%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1258, N'CPU', N'Intel Core i5-1235U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1258, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1258, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1258, N'Card đồ họa', N'Intel UHD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-hp-elitebook-640-van-phong-1259')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop HP EliteBook 640 Văn phòng', 'laptop-hp-elitebook-640-van-phong-1259', N'Intel Core i7-1355U, 16GB RAM, 512GB SSD, Intel Iris Xe.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'HP'), 1, GETDATE());
    DECLARE @p1259 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1259, 'LAPTOP-HP-ELITEBOOK-640-V-N-PH-NG-1259', 24500000, NULL, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1259, 'https://placehold.co/400x400?text=Laptop%20HP%20EliteBook%20640%20V%C4%83n%20ph', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1259, N'CPU', N'Intel Core i7-1355U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1259, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1259, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1259, N'Card đồ họa', N'Intel Iris Xe', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-dell-vostro-3420-van-phong-1260')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Dell Vostro 3420 Văn phòng', 'laptop-dell-vostro-3420-van-phong-1260', N'Intel Core i3-1215U, 8GB RAM, 256GB SSD, Intel UHD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Dell'), 1, GETDATE());
    DECLARE @p1260 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1260, 'LAPTOP-DELL-VOSTRO-3420-V-N-PH-NG-1260', 13900000, NULL, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1260, 'https://placehold.co/400x400?text=Laptop%20Dell%20Vostro%203420%20V%C4%83n%20ph', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1260, N'CPU', N'Intel Core i3-1215U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1260, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1260, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1260, N'Card đồ họa', N'Intel UHD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-lenovo-thinkpad-e14-van-phong-1261')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Lenovo ThinkPad E14 Văn phòng', 'laptop-lenovo-thinkpad-e14-van-phong-1261', N'Intel Core i5-1335U, 16GB RAM, 512GB SSD, Intel Iris Xe.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Lenovo'), 1, GETDATE());
    DECLARE @p1261 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1261, 'LAPTOP-LENOVO-THINKPAD-E14-V-N-PH-NG-1261', 20500000, 21730000, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1261, 'https://placehold.co/400x400?text=Laptop%20Lenovo%20ThinkPad%20E14%20V%C4%83n', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1261, N'CPU', N'Intel Core i5-1335U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1261, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1261, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1261, N'Card đồ họa', N'Intel Iris Xe', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-zenbook-13-oled-mong-nhe-1262')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS Zenbook 13 OLED Mỏng nhẹ', 'laptop-asus-zenbook-13-oled-mong-nhe-1262', N'Intel Core i5-1335U, 16GB RAM, 512GB SSD, Intel Iris Xe.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1262 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1262, 'LAPTOP-ASUS-ZENBOOK-13-OLED-M-NG-NH-1262', 22900000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1262, 'https://placehold.co/400x400?text=Laptop%20ASUS%20Zenbook%2013%20OLED%20M%E1%BB%8F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1262, N'CPU', N'Intel Core i5-1335U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1262, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1262, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1262, N'Card đồ họa', N'Intel Iris Xe', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-lenovo-yoga-9i-mong-nhe-1263')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Lenovo Yoga 9i Mỏng nhẹ', 'laptop-lenovo-yoga-9i-mong-nhe-1263', N'Intel Core Ultra 7 155H, 16GB RAM, 1TB SSD, Intel Arc.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Lenovo'), 1, GETDATE());
    DECLARE @p1263 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1263, 'LAPTOP-LENOVO-YOGA-9I-M-NG-NH-1263', 34500000, NULL, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1263, 'https://placehold.co/400x400?text=Laptop%20Lenovo%20Yoga%209i%20M%E1%BB%8Fng%20nh%E1%BA%B9', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1263, N'CPU', N'Intel Core Ultra 7 155H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1263, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1263, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1263, N'Card đồ họa', N'Intel Arc', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-dell-xps-14-mong-nhe-1264')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Dell XPS 14 Mỏng nhẹ', 'laptop-dell-xps-14-mong-nhe-1264', N'Intel Core Ultra 7 155H, 32GB RAM, 1TB SSD, Intel Arc.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Dell'), 1, GETDATE());
    DECLARE @p1264 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1264, 'LAPTOP-DELL-XPS-14-M-NG-NH-1264', 42500000, 45475000, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1264, 'https://placehold.co/400x400?text=Laptop%20Dell%20XPS%2014%20M%E1%BB%8Fng%20nh%E1%BA%B9', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1264, N'CPU', N'Intel Core Ultra 7 155H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1264, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1264, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1264, N'Card đồ họa', N'Intel Arc', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-hp-spectre-x360-14-mong-nhe-1265')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop HP Spectre x360 14 Mỏng nhẹ', 'laptop-hp-spectre-x360-14-mong-nhe-1265', N'Intel Core Ultra 7 155H, 16GB RAM, 1TB SSD, Intel Arc.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'HP'), 1, GETDATE());
    DECLARE @p1265 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1265, 'LAPTOP-HP-SPECTRE-X360-14-M-NG-NH-1265', 38500000, 40810000, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1265, 'https://placehold.co/400x400?text=Laptop%20HP%20Spectre%20x360%2014%20M%E1%BB%8Fng', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1265, N'CPU', N'Intel Core Ultra 7 155H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1265, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1265, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1265, N'Card đồ họa', N'Intel Arc', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-zenbook-s13-oled-mong-nhe-1266')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS Zenbook S13 OLED Mỏng nhẹ', 'laptop-asus-zenbook-s13-oled-mong-nhe-1266', N'Intel Core Ultra 7 155H, 16GB RAM, 1TB SSD, Intel Arc.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1266 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1266, 'LAPTOP-ASUS-ZENBOOK-S13-OLED-M-NG-NH-1266', 29900000, NULL, 21, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1266, 'https://placehold.co/400x400?text=Laptop%20ASUS%20Zenbook%20S13%20OLED%20M', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1266, N'CPU', N'Intel Core Ultra 7 155H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1266, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1266, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1266, N'Card đồ họa', N'Intel Arc', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-apple-macbook-pro-14-m3-mong-nhe-1267')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Apple MacBook Pro 14 M3 Mỏng nhẹ', 'laptop-apple-macbook-pro-14-m3-mong-nhe-1267', N'Apple M3, 16GB RAM, 512GB SSD, Apple GPU 10 nhân.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Apple'), 1, GETDATE());
    DECLARE @p1267 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1267, 'LAPTOP-APPLE-MACBOOK-PRO-14-M3-M-NG-NH-1267', 48500000, 54805000, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1267, 'https://placehold.co/400x400?text=Laptop%20Apple%20MacBook%20Pro%2014%20M3', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1267, N'CPU', N'Apple M3', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1267, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1267, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1267, N'Card đồ họa', N'Apple GPU 10 nhân', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-apple-macbook-air-15-m3-mong-nhe-1268')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Apple MacBook Air 15 M3 Mỏng nhẹ', 'laptop-apple-macbook-air-15-m3-mong-nhe-1268', N'Apple M3, 16GB RAM, 512GB SSD, Apple GPU 10 nhân.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Apple'), 1, GETDATE());
    DECLARE @p1268 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1268, 'LAPTOP-APPLE-MACBOOK-AIR-15-M3-M-NG-NH-1268', 34500000, NULL, 30, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1268, 'https://placehold.co/400x400?text=Laptop%20Apple%20MacBook%20Air%2015%20M3', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1268, N'CPU', N'Apple M3', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1268, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1268, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1268, N'Card đồ họa', N'Apple GPU 10 nhân', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-lenovo-yoga-slim-6-mong-nhe-1269')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Lenovo Yoga Slim 6 Mỏng nhẹ', 'laptop-lenovo-yoga-slim-6-mong-nhe-1269', N'Intel Core Ultra 5 125H, 16GB RAM, 512GB SSD, Intel Arc.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Lenovo'), 1, GETDATE());
    DECLARE @p1269 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1269, 'LAPTOP-LENOVO-YOGA-SLIM-6-M-NG-NH-1269', 21500000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1269, 'https://placehold.co/400x400?text=Laptop%20Lenovo%20Yoga%20Slim%206%20M%E1%BB%8Fng', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1269, N'CPU', N'Intel Core Ultra 5 125H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1269, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1269, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1269, N'Card đồ họa', N'Intel Arc', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-msi-prestige-13-evo-mong-nhe-1270')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop MSI Prestige 13 Evo Mỏng nhẹ', 'laptop-msi-prestige-13-evo-mong-nhe-1270', N'Intel Core i7-1360P, 16GB RAM, 1TB SSD, Intel Iris Xe.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1270 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1270, 'LAPTOP-MSI-PRESTIGE-13-EVO-M-NG-NH-1270', 27500000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1270, 'https://placehold.co/400x400?text=Laptop%20MSI%20Prestige%2013%20Evo%20M%E1%BB%8Fn', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1270, N'CPU', N'Intel Core i7-1360P', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1270, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1270, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1270, N'Card đồ họa', N'Intel Iris Xe', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-tuf-gaming-f15-fx507vv-gaming-1271')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS TUF Gaming F15 FX507VV Gaming', 'laptop-asus-tuf-gaming-f15-fx507vv-gaming-1271', N'Intel Core i7-13620H, 16GB RAM, 512GB SSD, RTX 4060 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1271 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1271, 'LAPTOP-ASUS-TUF-GAMING-F15-FX507VV-GAMIN-1271', 24500000, NULL, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1271, 'https://placehold.co/400x400?text=Laptop%20ASUS%20TUF%20Gaming%20F15%20FX5', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1271, N'CPU', N'Intel Core i7-13620H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1271, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1271, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1271, N'Card đồ họa', N'RTX 4060 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-gigabyte-g5-gaming-1272')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Gigabyte G5 Gaming', 'laptop-gigabyte-g5-gaming-1272', N'Intel Core i5-13500H, 16GB RAM, 512GB SSD, RTX 4060 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1272 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1272, 'LAPTOP-GIGABYTE-G5-GAMING-1272', 21500000, 23435000, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1272, 'https://placehold.co/400x400?text=Laptop%20Gigabyte%20G5%20Gaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1272, N'CPU', N'Intel Core i5-13500H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1272, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1272, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1272, N'Card đồ họa', N'RTX 4060 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-gigabyte-aorus-15-gaming-1273')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Gigabyte Aorus 15 Gaming', 'laptop-gigabyte-aorus-15-gaming-1273', N'Intel Core i7-13700HX, 16GB RAM, 1TB SSD, RTX 4070 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1273 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1273, 'LAPTOP-GIGABYTE-AORUS-15-GAMING-1273', 32500000, 37050000, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1273, 'https://placehold.co/400x400?text=Laptop%20Gigabyte%20Aorus%2015%20Gamin', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1273, N'CPU', N'Intel Core i7-13700HX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1273, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1273, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1273, N'Card đồ họa', N'RTX 4070 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-hp-pavilion-gaming-15-gaming-1274')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop HP Pavilion Gaming 15 Gaming', 'laptop-hp-pavilion-gaming-15-gaming-1274', N'AMD Ryzen 5 5600H, 8GB RAM, 512GB SSD, GTX 1650 4GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'HP'), 1, GETDATE());
    DECLARE @p1274 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1274, 'LAPTOP-HP-PAVILION-GAMING-15-GAMING-1274', 15900000, NULL, 14, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1274, 'https://placehold.co/400x400?text=Laptop%20HP%20Pavilion%20Gaming%2015%20G', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1274, N'CPU', N'AMD Ryzen 5 5600H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1274, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1274, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1274, N'Card đồ họa', N'GTX 1650 4GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-acer-aspire-5-slim-van-phong-1275')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Acer Aspire 5 Slim Văn phòng', 'laptop-acer-aspire-5-slim-van-phong-1275', N'Intel Core i3-1215U, 8GB RAM, 512GB SSD, Intel UHD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ACER'), 1, GETDATE());
    DECLARE @p1275 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1275, 'LAPTOP-ACER-ASPIRE-5-SLIM-V-N-PH-NG-1275', 12900000, 13674000, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1275, 'https://placehold.co/400x400?text=Laptop%20Acer%20Aspire%205%20Slim%20V%C4%83n%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1275, N'CPU', N'Intel Core i3-1215U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1275, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1275, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1275, N'Card đồ họa', N'Intel UHD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-vivobook-14-van-phong-1276')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS Vivobook 14 Văn phòng', 'laptop-asus-vivobook-14-van-phong-1276', N'Intel Core i3-1215U, 8GB RAM, 256GB SSD, Intel UHD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1276 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1276, 'LAPTOP-ASUS-VIVOBOOK-14-V-N-PH-NG-1276', 11900000, NULL, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1276, 'https://placehold.co/400x400?text=Laptop%20ASUS%20Vivobook%2014%20V%C4%83n%20ph', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1276, N'CPU', N'Intel Core i3-1215U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1276, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1276, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1276, N'Card đồ họa', N'Intel UHD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-lenovo-thinkbook-15-van-phong-1277')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Lenovo ThinkBook 15 Văn phòng', 'laptop-lenovo-thinkbook-15-van-phong-1277', N'Intel Core i5-1235U, 16GB RAM, 512GB SSD, Intel Iris Xe.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Lenovo'), 1, GETDATE());
    DECLARE @p1277 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1277, 'LAPTOP-LENOVO-THINKBOOK-15-V-N-PH-NG-1277', 17500000, 20125000, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1277, 'https://placehold.co/400x400?text=Laptop%20Lenovo%20ThinkBook%2015%20V%C4%83n', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1277, N'CPU', N'Intel Core i5-1235U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1277, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1277, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1277, N'Card đồ họa', N'Intel Iris Xe', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-dell-inspiron-15-3520-van-phong-1278')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Dell Inspiron 15 3520 Văn phòng', 'laptop-dell-inspiron-15-3520-van-phong-1278', N'Intel Core i5-1235U, 8GB RAM, 512GB SSD, Intel UHD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Dell'), 1, GETDATE());
    DECLARE @p1278 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1278, 'LAPTOP-DELL-INSPIRON-15-3520-V-N-PH-NG-1278', 14500000, NULL, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1278, 'https://placehold.co/400x400?text=Laptop%20Dell%20Inspiron%2015%203520%20V', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1278, N'CPU', N'Intel Core i5-1235U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1278, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1278, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1278, N'Card đồ họa', N'Intel UHD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-origin-r3-4100-gt1030-1279')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Origin R3-4100 GT1030', 'pc-cntt-origin-r3-4100-gt1030-1279', N'AMD Ryzen 3 4100, 8GB RAM, 256GB SSD, GT 1030 2GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1279 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1279, 'PC-CNTT-ORIGIN-R3-4100-GT1030-1279', 8500000, NULL, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1279, 'https://placehold.co/400x400?text=PC%20CNTT%20Origin%20R3-4100%20GT1030', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1279, N'CPU', N'AMD Ryzen 3 4100', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1279, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1279, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1279, N'Card đồ họa', N'GT 1030 2GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-starter-i3-10100f-gtx1650-1280')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Starter i3-10100F GTX1650', 'pc-cntt-starter-i3-10100f-gtx1650-1280', N'Intel Core i3-10100F, 8GB RAM, 256GB SSD, GTX 1650 4GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1280 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1280, 'PC-CNTT-STARTER-I3-10100F-GTX1650-1280', 10900000, NULL, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1280, 'https://placehold.co/400x400?text=PC%20CNTT%20Starter%20i3-10100F%20GTX1', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1280, N'CPU', N'Intel Core i3-10100F', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1280, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1280, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1280, N'Card đồ họa', N'GTX 1650 4GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-rookie-r5-3600-rx6600-1281')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Rookie R5-3600 RX6600', 'pc-cntt-rookie-r5-3600-rx6600-1281', N'AMD Ryzen 5 3600, 16GB RAM, 512GB SSD, RX 6600 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1281 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1281, 'PC-CNTT-ROOKIE-R5-3600-RX6600-1281', 15900000, NULL, 14, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1281, 'https://placehold.co/400x400?text=PC%20CNTT%20Rookie%20R5-3600%20RX6600', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1281, N'CPU', N'AMD Ryzen 5 3600', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1281, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1281, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1281, N'Card đồ họa', N'RX 6600 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-momentum-i5-11400f-rtx3060-1282')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Momentum i5-11400F RTX3060', 'pc-cntt-momentum-i5-11400f-rtx3060-1282', N'Intel Core i5-11400F, 16GB RAM, 512GB SSD, RTX 3060 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1282 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1282, 'PC-CNTT-MOMENTUM-I5-11400F-RTX3060-1282', 17900000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1282, 'https://placehold.co/400x400?text=PC%20CNTT%20Momentum%20i5-11400F%20RTX', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1282, N'CPU', N'Intel Core i5-11400F', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1282, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1282, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1282, N'Card đồ họa', N'RTX 3060 12GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-cyclone-r5-5600x-rtx3060ti-1283')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Cyclone R5-5600X RTX3060Ti', 'pc-cntt-cyclone-r5-5600x-rtx3060ti-1283', N'AMD Ryzen 5 5600X, 16GB RAM, 512GB SSD, RTX 3060 Ti 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1283 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1283, 'PC-CNTT-CYCLONE-R5-5600X-RTX3060TI-1283', 20900000, NULL, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1283, 'https://placehold.co/400x400?text=PC%20CNTT%20Cyclone%20R5-5600X%20RTX30', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1283, N'CPU', N'AMD Ryzen 5 5600X', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1283, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1283, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1283, N'Card đồ họa', N'RTX 3060 Ti 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-hunter-i5-12490f-rtx4060-1284')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Hunter i5-12490F RTX4060', 'pc-cntt-hunter-i5-12490f-rtx4060-1284', N'Intel Core i5-12490F, 16GB RAM, 512GB SSD, RTX 4060 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1284 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1284, 'PC-CNTT-HUNTER-I5-12490F-RTX4060-1284', 22500000, 23850000, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1284, 'https://placehold.co/400x400?text=PC%20CNTT%20Hunter%20i5-12490F%20RTX40', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1284, N'CPU', N'Intel Core i5-12490F', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1284, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1284, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1284, N'Card đồ họa', N'RTX 4060 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-falcon-r5-7500f-rtx4060-1285')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Falcon R5-7500F RTX4060', 'pc-cntt-falcon-r5-7500f-rtx4060-1285', N'AMD Ryzen 5 7500F, 32GB RAM, 1TB SSD, RTX 4060 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1285 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1285, 'PC-CNTT-FALCON-R5-7500F-RTX4060-1285', 24500000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1285, 'https://placehold.co/400x400?text=PC%20CNTT%20Falcon%20R5-7500F%20RTX406', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1285, N'CPU', N'AMD Ryzen 5 7500F', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1285, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1285, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1285, N'Card đồ họa', N'RTX 4060 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-blitz-i5-13600k-rtx4060ti-1286')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Blitz i5-13600K RTX4060Ti', 'pc-cntt-blitz-i5-13600k-rtx4060ti-1286', N'Intel Core i5-13600K, 32GB RAM, 1TB SSD, RTX 4060 Ti 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1286 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1286, 'PC-CNTT-BLITZ-I5-13600K-RTX4060TI-1286', 27500000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1286, 'https://placehold.co/400x400?text=PC%20CNTT%20Blitz%20i5-13600K%20RTX406', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1286, N'CPU', N'Intel Core i5-13600K', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1286, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1286, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1286, N'Card đồ họa', N'RTX 4060 Ti 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-rider-r7-5800x-rtx4070-1287')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Rider R7-5800X RTX4070', 'pc-cntt-rider-r7-5800x-rtx4070-1287', N'AMD Ryzen 7 5800X, 32GB RAM, 1TB SSD, RTX 4070 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1287 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1287, 'PC-CNTT-RIDER-R7-5800X-RTX4070-1287', 30900000, NULL, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1287, 'https://placehold.co/400x400?text=PC%20CNTT%20Rider%20R7-5800X%20RTX4070', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1287, N'CPU', N'AMD Ryzen 7 5800X', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1287, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1287, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1287, N'Card đồ họa', N'RTX 4070 12GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-ranger-i7-12700k-rtx4070super-1288')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Ranger i7-12700K RTX4070Super', 'pc-cntt-ranger-i7-12700k-rtx4070super-1288', N'Intel Core i7-12700K, 32GB RAM, 1TB SSD, RTX 4070 Super 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1288 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1288, 'PC-CNTT-RANGER-I7-12700K-RTX4070SUPER-1288', 34500000, 36225000, 21, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1288, 'https://placehold.co/400x400?text=PC%20CNTT%20Ranger%20i7-12700K%20RTX40', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1288, N'CPU', N'Intel Core i7-12700K', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1288, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1288, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1288, N'Card đồ họa', N'RTX 4070 Super 12GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-rampage-r7-7700-rtx4070ti-1289')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Rampage R7-7700 RTX4070Ti', 'pc-cntt-rampage-r7-7700-rtx4070ti-1289', N'AMD Ryzen 7 7700, 32GB RAM, 1TB SSD, RTX 4070 Ti 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1289 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1289, 'PC-CNTT-RAMPAGE-R7-7700-RTX4070TI-1289', 38500000, NULL, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1289, 'https://placehold.co/400x400?text=PC%20CNTT%20Rampage%20R7-7700%20RTX407', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1289, N'CPU', N'AMD Ryzen 7 7700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1289, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1289, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1289, N'Card đồ họa', N'RTX 4070 Ti 12GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-nitro-i7-13700k-rtx4070tisuper-1290')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Nitro i7-13700K RTX4070TiSuper', 'pc-cntt-nitro-i7-13700k-rtx4070tisuper-1290', N'Intel Core i7-13700K, 32GB RAM, 2TB SSD, RTX 4070 Ti Super 16GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1290 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1290, 'PC-CNTT-NITRO-I7-13700K-RTX4070TISUPER-1290', 42500000, 48450000, 14, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1290, 'https://placehold.co/400x400?text=PC%20CNTT%20Nitro%20i7-13700K%20RTX407', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1290, N'CPU', N'Intel Core i7-13700K', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1290, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1290, N'Ổ cứng', N'2TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1290, N'Card đồ họa', N'RTX 4070 Ti Super 16GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-fury-r9-7900x-rtx4080-1291')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Fury R9-7900X RTX4080', 'pc-cntt-fury-r9-7900x-rtx4080-1291', N'AMD Ryzen 9 7900X, 32GB RAM, 2TB SSD, RTX 4080 16GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1291 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1291, 'PC-CNTT-FURY-R9-7900X-RTX4080-1291', 55900000, NULL, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1291, 'https://placehold.co/400x400?text=PC%20CNTT%20Fury%20R9-7900X%20RTX4080', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1291, N'CPU', N'AMD Ryzen 9 7900X', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1291, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1291, N'Ổ cứng', N'2TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1291, N'Card đồ họa', N'RTX 4080 16GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-havoc-i9-14900k-rtx4080super-1292')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Havoc i9-14900K RTX4080Super', 'pc-cntt-havoc-i9-14900k-rtx4080super-1292', N'Intel Core i9-14900K, 32GB RAM, 2TB SSD, RTX 4080 Super 16GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1292 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1292, 'PC-CNTT-HAVOC-I9-14900K-RTX4080SUPER-1292', 59900000, NULL, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1292, 'https://placehold.co/400x400?text=PC%20CNTT%20Havoc%20i9-14900K%20RTX408', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1292, N'CPU', N'Intel Core i9-14900K', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1292, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1292, N'Ổ cứng', N'2TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1292, N'Card đồ họa', N'RTX 4080 Super 16GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-omega-r9-7950x3d-rtx4090-1293')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Omega R9-7950X3D RTX4090', 'pc-cntt-omega-r9-7950x3d-rtx4090-1293', N'AMD Ryzen 9 7950X3D, 64GB RAM, 2TB SSD, RTX 4090 24GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1293 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1293, 'PC-CNTT-OMEGA-R9-7950X3D-RTX4090-1293', 69900000, NULL, 35, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1293, 'https://placehold.co/400x400?text=PC%20CNTT%20Omega%20R9-7950X3D%20RTX40', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1293, N'CPU', N'AMD Ryzen 9 7950X3D', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1293, N'RAM', N'64GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1293, N'Ổ cứng', N'2TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1293, N'Card đồ họa', N'RTX 4090 24GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-van-phong-cntt-compact-mini-1294')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC Văn Phòng CNTT Compact Mini', 'pc-van-phong-cntt-compact-mini-1294', N'Intel Core i3-10100, 8GB RAM, 256GB SSD, Intel UHD 630.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1294 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1294, 'PC-V-N-PH-NG-CNTT-COMPACT-MINI-1294', 8900000, NULL, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1294, 'https://placehold.co/400x400?text=PC%20V%C4%83n%20Ph%C3%B2ng%20CNTT%20Compact%20Mini', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1294, N'CPU', N'Intel Core i3-10100', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1294, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1294, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1294, N'Card đồ họa', N'Intel UHD 630', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-van-phong-cntt-slim-desk-1295')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC Văn Phòng CNTT Slim Desk', 'pc-van-phong-cntt-slim-desk-1295', N'AMD Ryzen 3 4300G, 8GB RAM, 256GB SSD, AMD Radeon.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1295 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1295, 'PC-V-N-PH-NG-CNTT-SLIM-DESK-1295', 9800000, NULL, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1295, 'https://placehold.co/400x400?text=PC%20V%C4%83n%20Ph%C3%B2ng%20CNTT%20Slim%20Desk', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1295, N'CPU', N'AMD Ryzen 3 4300G', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1295, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1295, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1295, N'Card đồ họa', N'AMD Radeon', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-van-phong-cntt-business-pro-1296')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC Văn Phòng CNTT Business Pro', 'pc-van-phong-cntt-business-pro-1296', N'Intel Core i3-12100, 16GB RAM, 512GB SSD, Intel UHD 730.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1296 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1296, 'PC-V-N-PH-NG-CNTT-BUSINESS-PRO-1296', 10900000, 12208000, 39, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1296, 'https://placehold.co/400x400?text=PC%20V%C4%83n%20Ph%C3%B2ng%20CNTT%20Business%20Pro', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1296, N'CPU', N'Intel Core i3-12100', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1296, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1296, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1296, N'Card đồ họa', N'Intel UHD 730', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-van-phong-cntt-silent-work-1297')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC Văn Phòng CNTT Silent Work', 'pc-van-phong-cntt-silent-work-1297', N'Intel Core i5-12400, 16GB RAM, 512GB SSD, Intel UHD 730.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1297 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1297, 'PC-V-N-PH-NG-CNTT-SILENT-WORK-1297', 13500000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1297, 'https://placehold.co/400x400?text=PC%20V%C4%83n%20Ph%C3%B2ng%20CNTT%20Silent%20Work', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1297, N'CPU', N'Intel Core i5-12400', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1297, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1297, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1297, N'Card đồ họa', N'Intel UHD 730', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-do-hoa-design-station-12-1298')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Đồ họa - Design Station 12', 'pc-cntt-do-hoa-design-station-12-1298', N'Intel Core i5-13600K, 32GB RAM, 1TB SSD, RTX 4060 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1298 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1298, 'PC-CNTT-H-A-DESIGN-STATION-12-1298', 26900000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1298, 'https://placehold.co/400x400?text=PC%20CNTT%20%C4%90%E1%BB%93%20h%E1%BB%8Da%20-%20Design%20Statio', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1298, N'CPU', N'Intel Core i5-13600K', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1298, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1298, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1298, N'Card đồ họa', N'RTX 4060 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-do-hoa-motion-studio-13-1299')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Đồ họa - Motion Studio 13', 'pc-cntt-do-hoa-motion-studio-13-1299', N'AMD Ryzen 7 7800X3D, 32GB RAM, 1TB SSD, RTX 4070 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1299 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1299, 'PC-CNTT-H-A-MOTION-STUDIO-13-1299', 37500000, NULL, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1299, 'https://placehold.co/400x400?text=PC%20CNTT%20%C4%90%E1%BB%93%20h%E1%BB%8Da%20-%20Motion%20Studio', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1299, N'CPU', N'AMD Ryzen 7 7800X3D', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1299, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1299, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1299, N'Card đồ họa', N'RTX 4070 12GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-do-hoa-pixel-studio-14-1300')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Đồ họa - Pixel Studio 14', 'pc-cntt-do-hoa-pixel-studio-14-1300', N'Intel Core i7-14700K, 32GB RAM, 2TB SSD, RTX 4070 Ti 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1300 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1300, 'PC-CNTT-H-A-PIXEL-STUDIO-14-1300', 45900000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1300, 'https://placehold.co/400x400?text=PC%20CNTT%20%C4%90%E1%BB%93%20h%E1%BB%8Da%20-%20Pixel%20Studio%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1300, N'CPU', N'Intel Core i7-14700K', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1300, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1300, N'Ổ cứng', N'2TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1300, N'Card đồ họa', N'RTX 4070 Ti 12GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-workstation-ultra-15-1301')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Workstation Ultra 15', 'pc-cntt-workstation-ultra-15-1301', N'Intel Core i9-13900K, 64GB RAM, 2TB SSD, RTX 4070 Ti Super 16GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1301 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1301, 'PC-CNTT-WORKSTATION-ULTRA-15-1301', 48500000, NULL, 40, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1301, 'https://placehold.co/400x400?text=PC%20CNTT%20Workstation%20Ultra%2015', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1301, N'CPU', N'Intel Core i9-13900K', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1301, N'RAM', N'64GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1301, N'Ổ cứng', N'2TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1301, N'Card đồ họa', N'RTX 4070 Ti Super 16GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-workstation-extreme-16-1302')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Workstation Extreme 16', 'pc-cntt-workstation-extreme-16-1302', N'AMD Ryzen 9 7950X, 64GB RAM, 2TB SSD, RTX 4080 16GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1302 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1302, 'PC-CNTT-WORKSTATION-EXTREME-16-1302', 65900000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1302, 'https://placehold.co/400x400?text=PC%20CNTT%20Workstation%20Extreme%2016', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1302, N'CPU', N'AMD Ryzen 9 7950X', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1302, N'RAM', N'64GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1302, N'Ổ cứng', N'2TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1302, N'Card đồ họa', N'RTX 4080 16GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-workstation-titan-17-1303')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Workstation Titan 17', 'pc-cntt-workstation-titan-17-1303', N'Intel Core i9-14900KS, 128GB RAM, 4TB SSD, RTX 4090 24GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1303 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1303, 'PC-CNTT-WORKSTATION-TITAN-17-1303', 72500000, NULL, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1303, 'https://placehold.co/400x400?text=PC%20CNTT%20Workstation%20Titan%2017', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1303, N'CPU', N'Intel Core i9-14900KS', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1303, N'RAM', N'128GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1303, N'Ổ cứng', N'4TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1303, N'Card đồ họa', N'RTX 4090 24GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-pioneer-i3-12100-gt1030-1304')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Pioneer i3-12100 GT1030', 'pc-cntt-pioneer-i3-12100-gt1030-1304', N'Intel Core i3-12100, 8GB RAM, 256GB SSD, GT 1030 2GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1304 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1304, 'PC-CNTT-PIONEER-I3-12100-GT1030-1304', 9900000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1304, 'https://placehold.co/400x400?text=PC%20CNTT%20Pioneer%20i3-12100%20GT103', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1304, N'CPU', N'Intel Core i3-12100', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1304, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1304, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1304, N'Card đồ họa', N'GT 1030 2GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-zephyr-r5-4500-rx6600-1305')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Zephyr R5-4500 RX6600', 'pc-cntt-zephyr-r5-4500-rx6600-1305', N'AMD Ryzen 5 4500, 16GB RAM, 512GB SSD, RX 6600 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1305 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1305, 'PC-CNTT-ZEPHYR-R5-4500-RX6600-1305', 16900000, NULL, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1305, 'https://placehold.co/400x400?text=PC%20CNTT%20Zephyr%20R5-4500%20RX6600', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1305, N'CPU', N'AMD Ryzen 5 4500', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1305, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1305, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1305, N'Card đồ họa', N'RX 6600 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-comet-i5-12400f-rtx4060ti-1306')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Comet i5-12400F RTX4060Ti', 'pc-cntt-comet-i5-12400f-rtx4060ti-1306', N'Intel Core i5-12400F, 32GB RAM, 1TB SSD, RTX 4060 Ti 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1306 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1306, 'PC-CNTT-COMET-I5-12400F-RTX4060TI-1306', 25500000, NULL, 38, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1306, 'https://placehold.co/400x400?text=PC%20CNTT%20Comet%20i5-12400F%20RTX406', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1306, N'CPU', N'Intel Core i5-12400F', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1306, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1306, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1306, N'Card đồ họa', N'RTX 4060 Ti 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-meteor-r7-7700x-rtx4070super-1307')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Meteor R7-7700X RTX4070Super', 'pc-cntt-meteor-r7-7700x-rtx4070super-1307', N'AMD Ryzen 7 7700X, 32GB RAM, 1TB SSD, RTX 4070 Super 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1307 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1307, 'PC-CNTT-METEOR-R7-7700X-RTX4070SUPER-1307', 36500000, NULL, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1307, 'https://placehold.co/400x400?text=PC%20CNTT%20Meteor%20R7-7700X%20RTX407', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1307, N'CPU', N'AMD Ryzen 7 7700X', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1307, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1307, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1307, N'Card đồ họa', N'RTX 4070 Super 12GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-van-phong-cntt-micro-office-1308')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC Văn Phòng CNTT Micro Office', 'pc-van-phong-cntt-micro-office-1308', N'AMD Ryzen 3 4100, 8GB RAM, 256GB SSD, AMD Radeon.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1308 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1308, 'PC-V-N-PH-NG-CNTT-MICRO-OFFICE-1308', 8900000, NULL, 40, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1308, 'https://placehold.co/400x400?text=PC%20V%C4%83n%20Ph%C3%B2ng%20CNTT%20Micro%20Office', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1308, N'CPU', N'AMD Ryzen 3 4100', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1308, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1308, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1308, N'Card đồ họa', N'AMD Radeon', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-van-phong-cntt-standard-desk-1309')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC Văn Phòng CNTT Standard Desk', 'pc-van-phong-cntt-standard-desk-1309', N'Intel Core i3-13100, 8GB RAM, 512GB SSD, Intel UHD 730.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p1309 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1309, 'PC-V-N-PH-NG-CNTT-STANDARD-DESK-1309', 11500000, 12880000, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1309, 'https://placehold.co/400x400?text=PC%20V%C4%83n%20Ph%C3%B2ng%20CNTT%20Standard%20Des', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1309, N'CPU', N'Intel Core i3-13100', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1309, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1309, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1309, N'Card đồ họa', N'Intel UHD 730', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-do-hoa-content-creator-18-1310')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Đồ họa - Content Creator 18', 'pc-cntt-do-hoa-content-creator-18-1310', N'AMD Ryzen 7 7700, 32GB RAM, 1TB SSD, RTX 4060 Ti 16GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p1310 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1310, 'PC-CNTT-H-A-CONTENT-CREATOR-18-1310', 32500000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1310, 'https://placehold.co/400x400?text=PC%20CNTT%20%C4%90%E1%BB%93%20h%E1%BB%8Da%20-%20Content%20Creat', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1310, N'CPU', N'AMD Ryzen 7 7700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1310, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1310, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1310, N'Card đồ họa', N'RTX 4060 Ti 16GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-workstation-prime-19-1311')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Workstation Prime 19', 'pc-cntt-workstation-prime-19-1311', N'Intel Core i9-13900K, 64GB RAM, 2TB SSD, RTX 4070 Ti 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p1311 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1311, 'PC-CNTT-WORKSTATION-PRIME-19-1311', 51500000, NULL, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1311, 'https://placehold.co/400x400?text=PC%20CNTT%20Workstation%20Prime%2019', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1311, N'CPU', N'Intel Core i9-13900K', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1311, N'RAM', N'64GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1311, N'Ổ cứng', N'2TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1311, N'Card đồ họa', N'RTX 4070 Ti 12GB', 3);
END
GO
