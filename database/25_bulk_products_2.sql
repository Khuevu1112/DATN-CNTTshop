-- ============================================================
-- 25_bulk_products_2.sql
-- Bo sung ~200 san pham moi, gia theo tier rieng cho tung nhom.
-- File duoc sinh tu dong (xem scratchpad/gen_products2.js).
-- ============================================================
USE ShopDB;
GO

-- ===== Thuong hieu bo sung =====
INSERT INTO BRAND (name)
SELECT v.name FROM (VALUES
    (N'ASRock'),
    (N'G.Skill'),
    (N'FSP'),
    (N'JBL'),
    (N'Xiaomi'),
    (N'Ugreen')
) AS v(name)
WHERE NOT EXISTS (SELECT 1 FROM BRAND b WHERE b.name = v.name);
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i3-12100f-301')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i3-12100F', 'cpu-intel-core-i3-12100f-301', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p301 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p301, 'CPU-INTEL-CORE-I3-12100F-301', 2300000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p301, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i3-12100F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p301, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p301, N'Xung nhịp', N'3.3GHz - 4.3GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p301, N'Số nhân/luồng', N'4 nhân / 8 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i3-14100f-302')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i3-14100F', 'cpu-intel-core-i3-14100f-302', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p302 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p302, 'CPU-INTEL-CORE-I3-14100F-302', 2700000, NULL, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p302, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i3-14100F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p302, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p302, N'Xung nhịp', N'3.5GHz - 4.7GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p302, N'Số nhân/luồng', N'4 nhân / 8 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-5-4500-303')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 5 4500', 'cpu-amd-ryzen-5-4500-303', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p303 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p303, 'CPU-AMD-RYZEN-5-4500-303', 2100000, NULL, 38, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p303, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%205%204500', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p303, N'Socket', N'AM4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p303, N'Xung nhịp', N'3.6GHz - 4.1GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p303, N'Số nhân/luồng', N'6 nhân / 12 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-5-5500-304')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 5 5500', 'cpu-amd-ryzen-5-5500-304', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p304 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p304, 'CPU-AMD-RYZEN-5-5500-304', 2400000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p304, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%205%205500', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p304, N'Socket', N'AM4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p304, N'Xung nhịp', N'3.6GHz - 4.2GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p304, N'Số nhân/luồng', N'6 nhân / 12 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i5-12400f-305')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i5-12400F', 'cpu-intel-core-i5-12400f-305', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p305 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p305, 'CPU-INTEL-CORE-I5-12400F-305', 3600000, NULL, 38, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p305, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i5-12400F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p305, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p305, N'Xung nhịp', N'2.5GHz - 4.4GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p305, N'Số nhân/luồng', N'6 nhân / 12 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i5-13500-306')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i5-13500', 'cpu-intel-core-i5-13500-306', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p306 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p306, 'CPU-INTEL-CORE-I5-13500-306', 4600000, NULL, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p306, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i5-13500', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p306, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p306, N'Xung nhịp', N'2.5GHz - 4.8GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p306, N'Số nhân/luồng', N'14 nhân / 20 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-5-5600-307')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 5 5600', 'cpu-amd-ryzen-5-5600-307', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p307 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p307, 'CPU-AMD-RYZEN-5-5600-307', 3100000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p307, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%205%205600', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p307, N'Socket', N'AM4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p307, N'Xung nhịp', N'3.5GHz - 4.4GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p307, N'Số nhân/luồng', N'6 nhân / 12 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-5-7500f-308')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 5 7500F', 'cpu-amd-ryzen-5-7500f-308', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p308 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p308, 'CPU-AMD-RYZEN-5-7500F-308', 4400000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p308, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%205%207500F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p308, N'Socket', N'AM5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p308, N'Xung nhịp', N'3.7GHz - 5.0GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p308, N'Số nhân/luồng', N'6 nhân / 12 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-5-7600-309')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 5 7600', 'cpu-amd-ryzen-5-7600-309', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p309 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p309, 'CPU-AMD-RYZEN-5-7600-309', 5000000, NULL, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p309, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%205%207600', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p309, N'Socket', N'AM5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p309, N'Xung nhịp', N'3.8GHz - 5.1GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p309, N'Số nhân/luồng', N'6 nhân / 12 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i7-12700f-310')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i7-12700F', 'cpu-intel-core-i7-12700f-310', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p310 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p310, 'CPU-INTEL-CORE-I7-12700F-310', 6200000, 6758000, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p310, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i7-12700F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p310, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p310, N'Xung nhịp', N'2.1GHz - 4.9GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p310, N'Số nhân/luồng', N'12 nhân / 20 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-7-5700x3d-311')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 7 5700X3D', 'cpu-amd-ryzen-7-5700x3d-311', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p311 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p311, 'CPU-AMD-RYZEN-7-5700X3D-311', 6800000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p311, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%207%205700X3D', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p311, N'Socket', N'AM4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p311, N'Xung nhịp', N'3.0GHz - 4.1GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p311, N'Số nhân/luồng', N'8 nhân / 16 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-7-7700x-312')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 7 7700X', 'cpu-amd-ryzen-7-7700x-312', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p312 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p312, 'CPU-AMD-RYZEN-7-7700X-312', 8700000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p312, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%207%207700X', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p312, N'Socket', N'AM5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p312, N'Xung nhịp', N'4.5GHz - 5.4GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p312, N'Số nhân/luồng', N'8 nhân / 16 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i7-13700k-313')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i7-13700K', 'cpu-intel-core-i7-13700k-313', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p313 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p313, 'CPU-INTEL-CORE-I7-13700K-313', 9900000, NULL, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p313, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i7-13700K', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p313, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p313, N'Xung nhịp', N'3.4GHz - 5.4GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p313, N'Số nhân/luồng', N'16 nhân / 24 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-9-7900x-314')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 9 7900X', 'cpu-amd-ryzen-9-7900x-314', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p314 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p314, 'CPU-AMD-RYZEN-9-7900X-314', 12800000, NULL, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p314, 'https://placehold.co/400x400?text=CPU%20AMD%20Ryzen%209%207900X', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p314, N'Socket', N'AM5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p314, N'Xung nhịp', N'4.7GHz - 5.6GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p314, N'Số nhân/luồng', N'12 nhân / 24 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i9-13900k-315')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i9-13900K', 'cpu-intel-core-i9-13900k-315', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p315 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p315, 'CPU-INTEL-CORE-I9-13900K-315', 14500000, 15660000, 14, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p315, 'https://placehold.co/400x400?text=CPU%20Intel%20Core%20i9-13900K', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p315, N'Socket', N'LGA1700', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p315, N'Xung nhịp', N'3.0GHz - 5.8GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p315, N'Số nhân/luồng', N'24 nhân / 32 luồng', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asrock-h610m-hdv-316')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASRock H610M-HDV', 'mainboard-asrock-h610m-hdv-316', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASRock'), 1, GETDATE());
    DECLARE @p316 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p316, 'MAINBOARD-ASROCK-H610M-HDV-316', 1500000, 1680000, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p316, 'https://placehold.co/400x400?text=Mainboard%20ASRock%20H610M-HDV', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p316, N'Chipset', N'H610', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p316, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p316, N'RAM hỗ trợ', N'DDR4 tối đa 64GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-gigabyte-h610m-h-317')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Gigabyte H610M H', 'mainboard-gigabyte-h610m-h-317', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p317 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p317, 'MAINBOARD-GIGABYTE-H610M-H-317', 1400000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p317, 'https://placehold.co/400x400?text=Mainboard%20Gigabyte%20H610M%20H', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p317, N'Chipset', N'H610', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p317, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p317, N'RAM hỗ trợ', N'DDR4 tối đa 64GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-prime-a520m-k-318')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASUS Prime A520M-K', 'mainboard-asus-prime-a520m-k-318', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p318 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p318, 'MAINBOARD-ASUS-PRIME-A520M-K-318', 1300000, 1495000, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p318, 'https://placehold.co/400x400?text=Mainboard%20ASUS%20Prime%20A520M-K', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p318, N'Chipset', N'A520', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p318, N'Socket', N'AM4', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p318, N'RAM hỗ trợ', N'DDR4 tối đa 64GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asrock-b450m-pro4-319')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASRock B450M Pro4', 'mainboard-asrock-b450m-pro4-319', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASRock'), 1, GETDATE());
    DECLARE @p319 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p319, 'MAINBOARD-ASROCK-B450M-PRO4-319', 1700000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p319, 'https://placehold.co/400x400?text=Mainboard%20ASRock%20B450M%20Pro4', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p319, N'Chipset', N'B450', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p319, N'Socket', N'AM4', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p319, N'RAM hỗ trợ', N'DDR4 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-msi-pro-b550m-a-320')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard MSI PRO B550M-A', 'mainboard-msi-pro-b550m-a-320', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p320 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p320, 'MAINBOARD-MSI-PRO-B550M-A-320', 2200000, NULL, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p320, 'https://placehold.co/400x400?text=Mainboard%20MSI%20PRO%20B550M-A', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p320, N'Chipset', N'B550', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p320, N'Socket', N'AM4', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p320, N'RAM hỗ trợ', N'DDR4 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-gigabyte-b550-aorus-elite-321')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Gigabyte B550 Aorus Elite', 'mainboard-gigabyte-b550-aorus-elite-321', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p321 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p321, 'MAINBOARD-GIGABYTE-B550-AORUS-ELITE-321', 3000000, NULL, 38, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p321, 'https://placehold.co/400x400?text=Mainboard%20Gigabyte%20B550%20Aorus%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p321, N'Chipset', N'B550', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p321, N'Socket', N'AM4', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p321, N'RAM hỗ trợ', N'DDR4 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-tuf-gaming-a620m-plus-322')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASUS TUF Gaming A620M-Plus', 'mainboard-asus-tuf-gaming-a620m-plus-322', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p322 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p322, 'MAINBOARD-ASUS-TUF-GAMING-A620M-PLUS-322', 2600000, 2912000, 35, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p322, 'https://placehold.co/400x400?text=Mainboard%20ASUS%20TUF%20Gaming%20A620', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p322, N'Chipset', N'A620', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p322, N'Socket', N'AM5', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p322, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asrock-b650m-pro-rs-323')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASRock B650M Pro RS', 'mainboard-asrock-b650m-pro-rs-323', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASRock'), 1, GETDATE());
    DECLARE @p323 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p323, 'MAINBOARD-ASROCK-B650M-PRO-RS-323', 2900000, NULL, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p323, 'https://placehold.co/400x400?text=Mainboard%20ASRock%20B650M%20Pro%20RS', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p323, N'Chipset', N'B650', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p323, N'Socket', N'AM5', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p323, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asrock-b650-pro-rs-324')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASRock B650 Pro RS', 'mainboard-asrock-b650-pro-rs-324', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASRock'), 1, GETDATE());
    DECLARE @p324 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p324, 'MAINBOARD-ASROCK-B650-PRO-RS-324', 3500000, NULL, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p324, 'https://placehold.co/400x400?text=Mainboard%20ASRock%20B650%20Pro%20RS', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p324, N'Chipset', N'B650', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p324, N'Socket', N'AM5', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p324, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-gigabyte-b760-gaming-x-325')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Gigabyte B760 Gaming X', 'mainboard-gigabyte-b760-gaming-x-325', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p325 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p325, 'MAINBOARD-GIGABYTE-B760-GAMING-X-325', 3800000, NULL, 31, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p325, 'https://placehold.co/400x400?text=Mainboard%20Gigabyte%20B760%20Gaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p325, N'Chipset', N'B760', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p325, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p325, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-msi-pro-x670-p-326')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard MSI PRO X670-P', 'mainboard-msi-pro-x670-p-326', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p326 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p326, 'MAINBOARD-MSI-PRO-X670-P-326', 5800000, 6612000, 31, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p326, 'https://placehold.co/400x400?text=Mainboard%20MSI%20PRO%20X670-P', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p326, N'Chipset', N'X670', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p326, N'Socket', N'AM5', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p326, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asrock-z790-pro-rs-327')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASRock Z790 Pro RS', 'mainboard-asrock-z790-pro-rs-327', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASRock'), 1, GETDATE());
    DECLARE @p327 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p327, 'MAINBOARD-ASROCK-Z790-PRO-RS-327', 6000000, NULL, 14, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p327, 'https://placehold.co/400x400?text=Mainboard%20ASRock%20Z790%20Pro%20RS', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p327, N'Chipset', N'Z790', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p327, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p327, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-gigabyte-z790-aorus-elite-328')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Gigabyte Z790 Aorus Elite', 'mainboard-gigabyte-z790-aorus-elite-328', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p328 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p328, 'MAINBOARD-GIGABYTE-Z790-AORUS-ELITE-328', 7200000, NULL, 24, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p328, 'https://placehold.co/400x400?text=Mainboard%20Gigabyte%20Z790%20Aorus%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p328, N'Chipset', N'Z790', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p328, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p328, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-rog-strix-x670e-e-329')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASUS ROG Strix X670E-E', 'mainboard-asus-rog-strix-x670e-e-329', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p329 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p329, 'MAINBOARD-ASUS-ROG-STRIX-X670E-E-329', 9500000, NULL, 38, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p329, 'https://placehold.co/400x400?text=Mainboard%20ASUS%20ROG%20Strix%20X670E', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p329, N'Chipset', N'X670E', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p329, N'Socket', N'AM5', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p329, N'RAM hỗ trợ', N'DDR5 tối đa 128GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-kingston-fury-beast-8gb-ddr4-330')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Kingston Fury Beast 8GB DDR4', 'ram-kingston-fury-beast-8gb-ddr4-330', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p330 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p330, 'RAM-KINGSTON-FURY-BEAST-8GB-DDR4-330', 550000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p330, 'https://placehold.co/400x400?text=RAM%20Kingston%20Fury%20Beast%208GB%20DD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p330, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p330, N'Bus', N'3200 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p330, N'Dung lượng', N'8GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-corsair-vengeance-lpx-8gb-ddr4-331')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Corsair Vengeance LPX 8GB DDR4', 'ram-corsair-vengeance-lpx-8gb-ddr4-331', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p331 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p331, 'RAM-CORSAIR-VENGEANCE-LPX-8GB-DDR4-331', 580000, NULL, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p331, 'https://placehold.co/400x400?text=RAM%20Corsair%20Vengeance%20LPX%208GB%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p331, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p331, N'Bus', N'3200 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p331, N'Dung lượng', N'8GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-g-skill-ripjaws-v-16gb-ddr4-332')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM G.Skill Ripjaws V 16GB DDR4', 'ram-g-skill-ripjaws-v-16gb-ddr4-332', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'G.Skill'), 1, GETDATE());
    DECLARE @p332 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p332, 'RAM-G-SKILL-RIPJAWS-V-16GB-DDR4-332', 1050000, 1187000, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p332, 'https://placehold.co/400x400?text=RAM%20G.Skill%20Ripjaws%20V%2016GB%20DDR', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p332, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p332, N'Bus', N'3200 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p332, N'Dung lượng', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-kingston-fury-beast-16gb-ddr4-333')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Kingston Fury Beast 16GB DDR4', 'ram-kingston-fury-beast-16gb-ddr4-333', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p333 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p333, 'RAM-KINGSTON-FURY-BEAST-16GB-DDR4-333', 1000000, NULL, 40, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p333, 'https://placehold.co/400x400?text=RAM%20Kingston%20Fury%20Beast%2016GB%20D', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p333, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p333, N'Bus', N'3200 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p333, N'Dung lượng', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-crucial-basics-16gb-ddr4-334')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Crucial Basics 16GB DDR4', 'ram-crucial-basics-16gb-ddr4-334', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Crucial'), 1, GETDATE());
    DECLARE @p334 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p334, 'RAM-CRUCIAL-BASICS-16GB-DDR4-334', 950000, 1036000, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p334, 'https://placehold.co/400x400?text=RAM%20Crucial%20Basics%2016GB%20DDR4', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p334, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p334, N'Bus', N'2666 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p334, N'Dung lượng', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-corsair-vengeance-16gb-ddr5-335')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Corsair Vengeance 16GB DDR5', 'ram-corsair-vengeance-16gb-ddr5-335', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p335 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p335, 'RAM-CORSAIR-VENGEANCE-16GB-DDR5-335', 1500000, 1620000, 31, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p335, 'https://placehold.co/400x400?text=RAM%20Corsair%20Vengeance%2016GB%20DDR', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p335, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p335, N'Bus', N'5600 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p335, N'Dung lượng', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-kingston-fury-renegade-16gb-ddr5-336')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Kingston Fury Renegade 16GB DDR5', 'ram-kingston-fury-renegade-16gb-ddr5-336', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p336 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p336, 'RAM-KINGSTON-FURY-RENEGADE-16GB-DDR5-336', 1700000, 1802000, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p336, 'https://placehold.co/400x400?text=RAM%20Kingston%20Fury%20Renegade%2016G', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p336, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p336, N'Bus', N'6000 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p336, N'Dung lượng', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-g-skill-flare-x5-16gb-ddr5-337')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM G.Skill Flare X5 16GB DDR5', 'ram-g-skill-flare-x5-16gb-ddr5-337', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'G.Skill'), 1, GETDATE());
    DECLARE @p337 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p337, 'RAM-G-SKILL-FLARE-X5-16GB-DDR5-337', 1600000, NULL, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p337, 'https://placehold.co/400x400?text=RAM%20G.Skill%20Flare%20X5%2016GB%20DDR5', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p337, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p337, N'Bus', N'5600 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p337, N'Dung lượng', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-crucial-pro-32gb-ddr4-338')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Crucial Pro 32GB DDR4', 'ram-crucial-pro-32gb-ddr4-338', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Crucial'), 1, GETDATE());
    DECLARE @p338 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p338, 'RAM-CRUCIAL-PRO-32GB-DDR4-338', 1900000, 2090000, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p338, 'https://placehold.co/400x400?text=RAM%20Crucial%20Pro%2032GB%20DDR4', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p338, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p338, N'Bus', N'3200 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p338, N'Dung lượng', N'32GB (2x16GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-corsair-vengeance-rgb-32gb-ddr4-339')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Corsair Vengeance RGB 32GB DDR4', 'ram-corsair-vengeance-rgb-32gb-ddr4-339', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p339 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p339, 'RAM-CORSAIR-VENGEANCE-RGB-32GB-DDR4-339', 2100000, 2331000, 40, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p339, 'https://placehold.co/400x400?text=RAM%20Corsair%20Vengeance%20RGB%2032GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p339, N'Chuẩn', N'DDR4', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p339, N'Bus', N'3600 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p339, N'Dung lượng', N'32GB (2x16GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-g-skill-trident-z5-32gb-ddr5-340')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM G.Skill Trident Z5 32GB DDR5', 'ram-g-skill-trident-z5-32gb-ddr5-340', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'G.Skill'), 1, GETDATE());
    DECLARE @p340 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p340, 'RAM-G-SKILL-TRIDENT-Z5-32GB-DDR5-340', 2400000, NULL, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p340, 'https://placehold.co/400x400?text=RAM%20G.Skill%20Trident%20Z5%2032GB%20DD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p340, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p340, N'Bus', N'6000 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p340, N'Dung lượng', N'32GB (2x16GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-g-skill-trident-z5-rgb-32gb-ddr5-341')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM G.Skill Trident Z5 RGB 32GB DDR5', 'ram-g-skill-trident-z5-rgb-32gb-ddr5-341', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'G.Skill'), 1, GETDATE());
    DECLARE @p341 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p341, 'RAM-G-SKILL-TRIDENT-Z5-RGB-32GB-DDR5-341', 3200000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p341, 'https://placehold.co/400x400?text=RAM%20G.Skill%20Trident%20Z5%20RGB%2032G', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p341, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p341, N'Bus', N'6400 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p341, N'Dung lượng', N'32GB (2x16GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-corsair-dominator-titanium-32gb-ddr5-342')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Corsair Dominator Titanium 32GB DDR5', 'ram-corsair-dominator-titanium-32gb-ddr5-342', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p342 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p342, 'RAM-CORSAIR-DOMINATOR-TITANIUM-32GB-DDR5-342', 3600000, NULL, 35, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p342, 'https://placehold.co/400x400?text=RAM%20Corsair%20Dominator%20Titanium', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p342, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p342, N'Bus', N'7200 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p342, N'Dung lượng', N'32GB (2x16GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-kingston-fury-beast-64gb-ddr5-343')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Kingston Fury Beast 64GB DDR5', 'ram-kingston-fury-beast-64gb-ddr5-343', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p343 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p343, 'RAM-KINGSTON-FURY-BEAST-64GB-DDR5-343', 5500000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p343, 'https://placehold.co/400x400?text=RAM%20Kingston%20Fury%20Beast%2064GB%20D', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p343, N'Chuẩn', N'DDR5', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p343, N'Bus', N'5600 MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p343, N'Dung lượng', N'64GB (2x32GB)', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-msi-ventus-gtx-1650-344')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa MSI Ventus GTX 1650', 'card-do-hoa-msi-ventus-gtx-1650-344', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p344 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p344, 'CARD-H-A-MSI-VENTUS-GTX-1650-344', 3800000, NULL, 39, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p344, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20MSI%20Ventus%20GTX%20165', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p344, N'Chip đồ họa', N'NVIDIA GTX 1650', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p344, N'VRAM', N'4GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p344, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-asus-dual-rx-6500-xt-345')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa ASUS Dual RX 6500 XT', 'card-do-hoa-asus-dual-rx-6500-xt-345', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p345 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p345, 'CARD-H-A-ASUS-DUAL-RX-6500-XT-345', 3600000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p345, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20ASUS%20Dual%20RX%206500%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p345, N'Chip đồ họa', N'AMD RX 6500 XT', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p345, N'VRAM', N'4GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p345, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-gigabyte-eagle-rtx-3050-346')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Gigabyte Eagle RTX 3050', 'card-do-hoa-gigabyte-eagle-rtx-3050-346', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p346 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p346, 'CARD-H-A-GIGABYTE-EAGLE-RTX-3050-346', 4500000, 4770000, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p346, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Gigabyte%20Eagle%20RTX', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p346, N'Chip đồ họa', N'NVIDIA RTX 3050', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p346, N'VRAM', N'8GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p346, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-asus-phoenix-rtx-3050-347')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa ASUS Phoenix RTX 3050', 'card-do-hoa-asus-phoenix-rtx-3050-347', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p347 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p347, 'CARD-H-A-ASUS-PHOENIX-RTX-3050-347', 4300000, NULL, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p347, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20ASUS%20Phoenix%20RTX%203', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p347, N'Chip đồ họa', N'NVIDIA RTX 3050', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p347, N'VRAM', N'8GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p347, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-gigabyte-windforce-rtx-4060-348')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Gigabyte Windforce RTX 4060', 'card-do-hoa-gigabyte-windforce-rtx-4060-348', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p348 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p348, 'CARD-H-A-GIGABYTE-WINDFORCE-RTX-4060-348', 8000000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p348, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Gigabyte%20Windforce', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p348, N'Chip đồ họa', N'NVIDIA RTX 4060', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p348, N'VRAM', N'8GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p348, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-msi-gaming-rx-7600-xt-349')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa MSI Gaming RX 7600 XT', 'card-do-hoa-msi-gaming-rx-7600-xt-349', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p349 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p349, 'CARD-H-A-MSI-GAMING-RX-7600-XT-349', 8500000, NULL, 24, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p349, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20MSI%20Gaming%20RX%207600', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p349, N'Chip đồ họa', N'AMD RX 7600 XT', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p349, N'VRAM', N'16GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p349, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-asus-dual-rx-7600-350')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa ASUS Dual RX 7600', 'card-do-hoa-asus-dual-rx-7600-350', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p350 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p350, 'CARD-H-A-ASUS-DUAL-RX-7600-350', 7800000, NULL, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p350, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20ASUS%20Dual%20RX%207600', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p350, N'Chip đồ họa', N'AMD RX 7600', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p350, N'VRAM', N'8GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p350, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-gigabyte-gaming-oc-rtx-4060-ti-351')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Gigabyte Gaming OC RTX 4060 Ti', 'card-do-hoa-gigabyte-gaming-oc-rtx-4060-ti-351', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p351 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p351, 'CARD-H-A-GIGABYTE-GAMING-OC-RTX-4060-TI-351', 10500000, NULL, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p351, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Gigabyte%20Gaming%20OC', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p351, N'Chip đồ họa', N'NVIDIA RTX 4060 Ti', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p351, N'VRAM', N'8GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p351, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-msi-ventus-rtx-4060-ti-352')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa MSI Ventus RTX 4060 Ti', 'card-do-hoa-msi-ventus-rtx-4060-ti-352', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p352 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p352, 'CARD-H-A-MSI-VENTUS-RTX-4060-TI-352', 9800000, NULL, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p352, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20MSI%20Ventus%20RTX%20406', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p352, N'Chip đồ họa', N'NVIDIA RTX 4060 Ti', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p352, N'VRAM', N'8GB GDDR6', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p352, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-gigabyte-windforce-rtx-4070-353')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Gigabyte Windforce RTX 4070', 'card-do-hoa-gigabyte-windforce-rtx-4070-353', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p353 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p353, 'CARD-H-A-GIGABYTE-WINDFORCE-RTX-4070-353', 15500000, NULL, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p353, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Gigabyte%20Windforce', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p353, N'Chip đồ họa', N'NVIDIA RTX 4070', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p353, N'VRAM', N'12GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p353, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-asus-dual-rtx-4070-354')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa ASUS Dual RTX 4070', 'card-do-hoa-asus-dual-rtx-4070-354', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p354 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p354, 'CARD-H-A-ASUS-DUAL-RTX-4070-354', 16200000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p354, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20ASUS%20Dual%20RTX%204070', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p354, N'Chip đồ họa', N'NVIDIA RTX 4070', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p354, N'VRAM', N'12GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p354, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-gigabyte-aorus-rtx-4070-ti-355')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Gigabyte Aorus RTX 4070 Ti', 'card-do-hoa-gigabyte-aorus-rtx-4070-ti-355', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p355 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p355, 'CARD-H-A-GIGABYTE-AORUS-RTX-4070-TI-355', 19800000, NULL, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p355, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Gigabyte%20Aorus%20RTX', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p355, N'Chip đồ họa', N'NVIDIA RTX 4070 Ti', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p355, N'VRAM', N'12GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p355, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-msi-gaming-x-rtx-4070-ti-super-356')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa MSI Gaming X RTX 4070 Ti Super', 'card-do-hoa-msi-gaming-x-rtx-4070-ti-super-356', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p356 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p356, 'CARD-H-A-MSI-GAMING-X-RTX-4070-TI-SUPER-356', 21500000, NULL, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p356, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20MSI%20Gaming%20X%20RTX%204', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p356, N'Chip đồ họa', N'NVIDIA RTX 4070 Ti Super', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p356, N'VRAM', N'16GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p356, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-asus-rog-strix-rtx-4080-super-357')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa ASUS ROG Strix RTX 4080 Super', 'card-do-hoa-asus-rog-strix-rtx-4080-super-357', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p357 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p357, 'CARD-H-A-ASUS-ROG-STRIX-RTX-4080-SUPER-357', 30500000, 34770000, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p357, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20ASUS%20ROG%20Strix%20RTX', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p357, N'Chip đồ họa', N'NVIDIA RTX 4080 Super', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p357, N'VRAM', N'16GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p357, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-gigabyte-aorus-rtx-4090-master-358')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Gigabyte Aorus RTX 4090 Master', 'card-do-hoa-gigabyte-aorus-rtx-4090-master-358', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p358 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p358, 'CARD-H-A-GIGABYTE-AORUS-RTX-4090-MASTER-358', 47500000, NULL, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p358, 'https://placehold.co/400x400?text=Card%20%C4%91%E1%BB%93%20h%E1%BB%8Da%20Gigabyte%20Aorus%20RTX', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p358, N'Chip đồ họa', N'NVIDIA RTX 4090', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p358, N'VRAM', N'24GB GDDR6X', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p358, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-kingston-a400-256gb-359')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Kingston A400 256GB', 'ssd-kingston-a400-256gb-359', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p359 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p359, 'SSD-KINGSTON-A400-256GB-359', 620000, NULL, 31, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p359, 'https://placehold.co/400x400?text=SSD%20Kingston%20A400%20256GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p359, N'Chuẩn', N'SATA III', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p359, N'Dung lượng', N'256GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p359, N'Tốc độ đọc', N'500 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-crucial-bx500-256gb-360')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Crucial BX500 256GB', 'ssd-crucial-bx500-256gb-360', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Crucial'), 1, GETDATE());
    DECLARE @p360 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p360, 'SSD-CRUCIAL-BX500-256GB-360', 600000, NULL, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p360, 'https://placehold.co/400x400?text=SSD%20Crucial%20BX500%20256GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p360, N'Chuẩn', N'SATA III', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p360, N'Dung lượng', N'256GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p360, N'Tốc độ đọc', N'540 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-wd-green-256gb-361')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD WD Green 256GB', 'ssd-wd-green-256gb-361', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p361 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p361, 'SSD-WD-GREEN-256GB-361', 580000, NULL, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p361, 'https://placehold.co/400x400?text=SSD%20WD%20Green%20256GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p361, N'Chuẩn', N'SATA III', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p361, N'Dung lượng', N'256GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p361, N'Tốc độ đọc', N'545 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-samsung-870-evo-512gb-362')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Samsung 870 EVO 512GB', 'ssd-samsung-870-evo-512gb-362', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p362 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p362, 'SSD-SAMSUNG-870-EVO-512GB-362', 1050000, NULL, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p362, 'https://placehold.co/400x400?text=SSD%20Samsung%20870%20EVO%20512GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p362, N'Chuẩn', N'SATA III', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p362, N'Dung lượng', N'512GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p362, N'Tốc độ đọc', N'560 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-kingston-a400-512gb-363')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Kingston A400 512GB', 'ssd-kingston-a400-512gb-363', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p363 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p363, 'SSD-KINGSTON-A400-512GB-363', 950000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p363, 'https://placehold.co/400x400?text=SSD%20Kingston%20A400%20512GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p363, N'Chuẩn', N'SATA III', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p363, N'Dung lượng', N'512GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p363, N'Tốc độ đọc', N'500 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-wd-blue-sn580-500gb-364')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD WD Blue SN580 500GB', 'ssd-wd-blue-sn580-500gb-364', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p364 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p364, 'SSD-WD-BLUE-SN580-500GB-364', 1200000, NULL, 30, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p364, 'https://placehold.co/400x400?text=SSD%20WD%20Blue%20SN580%20500GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p364, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p364, N'Dung lượng', N'500GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p364, N'Tốc độ đọc', N'4150 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-crucial-p3-500gb-365')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Crucial P3 500GB', 'ssd-crucial-p3-500gb-365', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Crucial'), 1, GETDATE());
    DECLARE @p365 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p365, 'SSD-CRUCIAL-P3-500GB-365', 1150000, NULL, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p365, 'https://placehold.co/400x400?text=SSD%20Crucial%20P3%20500GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p365, N'Chuẩn', N'NVMe PCIe 3.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p365, N'Dung lượng', N'500GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p365, N'Tốc độ đọc', N'3500 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-samsung-980-500gb-366')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Samsung 980 500GB', 'ssd-samsung-980-500gb-366', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p366 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p366, 'SSD-SAMSUNG-980-500GB-366', 1400000, NULL, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p366, 'https://placehold.co/400x400?text=SSD%20Samsung%20980%20500GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p366, N'Chuẩn', N'NVMe PCIe 3.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p366, N'Dung lượng', N'500GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p366, N'Tốc độ đọc', N'3100 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-kingston-kc3000-512gb-367')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Kingston KC3000 512GB', 'ssd-kingston-kc3000-512gb-367', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p367 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p367, 'SSD-KINGSTON-KC3000-512GB-367', 1500000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p367, 'https://placehold.co/400x400?text=SSD%20Kingston%20KC3000%20512GB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p367, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p367, N'Dung lượng', N'512GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p367, N'Tốc độ đọc', N'7000 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-wd-black-sn770-1tb-368')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD WD Black SN770 1TB', 'ssd-wd-black-sn770-1tb-368', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p368 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p368, 'SSD-WD-BLACK-SN770-1TB-368', 1900000, 2109000, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p368, 'https://placehold.co/400x400?text=SSD%20WD%20Black%20SN770%201TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p368, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p368, N'Dung lượng', N'1TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p368, N'Tốc độ đọc', N'5150 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-crucial-p5-plus-1tb-369')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Crucial P5 Plus 1TB', 'ssd-crucial-p5-plus-1tb-369', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Crucial'), 1, GETDATE());
    DECLARE @p369 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p369, 'SSD-CRUCIAL-P5-PLUS-1TB-369', 2000000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p369, 'https://placehold.co/400x400?text=SSD%20Crucial%20P5%20Plus%201TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p369, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p369, N'Dung lượng', N'1TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p369, N'Tốc độ đọc', N'6600 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-kingston-fury-renegade-1tb-370')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Kingston Fury Renegade 1TB', 'ssd-kingston-fury-renegade-1tb-370', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p370 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p370, 'SSD-KINGSTON-FURY-RENEGADE-1TB-370', 2300000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p370, 'https://placehold.co/400x400?text=SSD%20Kingston%20Fury%20Renegade%201TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p370, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p370, N'Dung lượng', N'1TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p370, N'Tốc độ đọc', N'7300 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-kingston-kc3000-2tb-371')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Kingston KC3000 2TB', 'ssd-kingston-kc3000-2tb-371', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p371 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p371, 'SSD-KINGSTON-KC3000-2TB-371', 3600000, 4104000, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p371, 'https://placehold.co/400x400?text=SSD%20Kingston%20KC3000%202TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p371, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p371, N'Dung lượng', N'2TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p371, N'Tốc độ đọc', N'7000 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-crucial-t500-2tb-372')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Crucial T500 2TB', 'ssd-crucial-t500-2tb-372', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Crucial'), 1, GETDATE());
    DECLARE @p372 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p372, 'SSD-CRUCIAL-T500-2TB-372', 4200000, 4578000, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p372, 'https://placehold.co/400x400?text=SSD%20Crucial%20T500%202TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p372, N'Chuẩn', N'NVMe PCIe 4.0', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p372, N'Dung lượng', N'2TB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p372, N'Tốc độ đọc', N'7300 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-barracuda-1tb-373')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate Barracuda 1TB', 'o-cung-hdd-seagate-barracuda-1tb-373', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p373 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p373, 'C-NG-HDD-SEAGATE-BARRACUDA-1TB-373', 1050000, NULL, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p373, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Seagate%20Barracuda%201', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p373, N'Dung lượng', N'1TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p373, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p373, N'Tốc độ quay', N'7200rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-skyhawk-1tb-374')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate Skyhawk 1TB', 'o-cung-hdd-seagate-skyhawk-1tb-374', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p374 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p374, 'C-NG-HDD-SEAGATE-SKYHAWK-1TB-374', 1150000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p374, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Seagate%20Skyhawk%201TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p374, N'Dung lượng', N'1TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p374, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p374, N'Tốc độ quay', N'5900rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-western-digital-purple-1tb-375')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Western Digital Purple 1TB', 'o-cung-hdd-western-digital-purple-1tb-375', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p375 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p375, 'C-NG-HDD-WESTERN-DIGITAL-PURPLE-1TB-375', 1200000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p375, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Western%20Digital%20Pur', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p375, N'Dung lượng', N'1TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p375, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p375, N'Tốc độ quay', N'5400rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-skyhawk-2tb-376')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate Skyhawk 2TB', 'o-cung-hdd-seagate-skyhawk-2tb-376', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p376 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p376, 'C-NG-HDD-SEAGATE-SKYHAWK-2TB-376', 1500000, NULL, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p376, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Seagate%20Skyhawk%202TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p376, N'Dung lượng', N'2TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p376, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p376, N'Tốc độ quay', N'5900rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-western-digital-black-2tb-377')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Western Digital Black 2TB', 'o-cung-hdd-western-digital-black-2tb-377', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p377 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p377, 'C-NG-HDD-WESTERN-DIGITAL-BLACK-2TB-377', 1700000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p377, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Western%20Digital%20Bla', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p377, N'Dung lượng', N'2TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p377, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p377, N'Tốc độ quay', N'7200rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-firecuda-2tb-378')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate FireCuda 2TB', 'o-cung-hdd-seagate-firecuda-2tb-378', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p378 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p378, 'C-NG-HDD-SEAGATE-FIRECUDA-2TB-378', 2100000, NULL, 39, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p378, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Seagate%20FireCuda%202T', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p378, N'Dung lượng', N'2TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p378, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p378, N'Tốc độ quay', N'7200rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-skyhawk-4tb-379')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate Skyhawk 4TB', 'o-cung-hdd-seagate-skyhawk-4tb-379', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p379 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p379, 'C-NG-HDD-SEAGATE-SKYHAWK-4TB-379', 2600000, NULL, 14, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p379, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Seagate%20Skyhawk%204TB', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p379, N'Dung lượng', N'4TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p379, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p379, N'Tốc độ quay', N'5900rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-western-digital-red-plus-4tb-380')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Western Digital Red Plus 4TB', 'o-cung-hdd-western-digital-red-plus-4tb-380', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p380 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p380, 'C-NG-HDD-WESTERN-DIGITAL-RED-PLUS-4TB-380', 2900000, 3074000, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p380, 'https://placehold.co/400x400?text=%E1%BB%94%20c%E1%BB%A9ng%20HDD%20Western%20Digital%20Red', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p380, N'Dung lượng', N'4TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p380, N'Giao tiếp', N'SATA III', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p380, N'Tốc độ quay', N'5400rpm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-fsp-hyper-k-450w-381')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn FSP Hyper K 450W', 'nguon-fsp-hyper-k-450w-381', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'FSP'), 1, GETDATE());
    DECLARE @p381 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p381, 'NGU-N-FSP-HYPER-K-450W-381', 1050000, 1103000, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p381, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20FSP%20Hyper%20K%20450W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p381, N'Công suất', N'450W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p381, N'Chuẩn 80 Plus', N'Không chứng nhận', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p381, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-corsair-cv550-550w-382')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Corsair CV550 550W', 'nguon-corsair-cv550-550w-382', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p382 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p382, 'NGU-N-CORSAIR-CV550-550W-382', 1300000, NULL, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p382, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Corsair%20CV550%20550W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p382, N'Công suất', N'550W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p382, N'Chuẩn 80 Plus', N'80 Plus Bronze', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p382, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-cooler-master-mwe-550-550w-383')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Cooler Master MWE 550 550W', 'nguon-cooler-master-mwe-550-550w-383', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Cooler Master'), 1, GETDATE());
    DECLARE @p383 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p383, 'NGU-N-COOLER-MASTER-MWE-550-550W-383', 1200000, NULL, 24, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p383, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Cooler%20Master%20MWE%20550%2055', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p383, N'Công suất', N'550W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p383, N'Chuẩn 80 Plus', N'80 Plus White', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p383, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-fsp-hyper-k-550w-384')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn FSP Hyper K 550W', 'nguon-fsp-hyper-k-550w-384', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'FSP'), 1, GETDATE());
    DECLARE @p384 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p384, 'NGU-N-FSP-HYPER-K-550W-384', 1250000, NULL, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p384, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20FSP%20Hyper%20K%20550W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p384, N'Công suất', N'550W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p384, N'Chuẩn 80 Plus', N'Không chứng nhận', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p384, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-corsair-rm650-650w-385')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Corsair RM650 650W', 'nguon-corsair-rm650-650w-385', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p385 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p385, 'NGU-N-CORSAIR-RM650-650W-385', 1900000, NULL, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p385, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Corsair%20RM650%20650W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p385, N'Công suất', N'650W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p385, N'Chuẩn 80 Plus', N'80 Plus Gold', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p385, N'Loại nguồn', N'Full-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-fsp-hydro-g-pro-650w-386')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn FSP Hydro G Pro 650W', 'nguon-fsp-hydro-g-pro-650w-386', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'FSP'), 1, GETDATE());
    DECLARE @p386 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p386, 'NGU-N-FSP-HYDRO-G-PRO-650W-386', 2000000, NULL, 32, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p386, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20FSP%20Hydro%20G%20Pro%20650W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p386, N'Công suất', N'650W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p386, N'Chuẩn 80 Plus', N'80 Plus Gold', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p386, N'Loại nguồn', N'Full-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-msi-mag-a650bn-650w-387')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn MSI MAG A650BN 650W', 'nguon-msi-mag-a650bn-650w-387', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p387 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p387, 'NGU-N-MSI-MAG-A650BN-650W-387', 1800000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p387, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20MSI%20MAG%20A650BN%20650W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p387, N'Công suất', N'650W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p387, N'Chuẩn 80 Plus', N'80 Plus Bronze', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p387, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-cooler-master-mwe-750-750w-388')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Cooler Master MWE 750 750W', 'nguon-cooler-master-mwe-750-750w-388', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Cooler Master'), 1, GETDATE());
    DECLARE @p388 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p388, 'NGU-N-COOLER-MASTER-MWE-750-750W-388', 2200000, NULL, 40, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p388, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Cooler%20Master%20MWE%20750%2075', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p388, N'Công suất', N'750W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p388, N'Chuẩn 80 Plus', N'80 Plus Gold', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p388, N'Loại nguồn', N'Semi-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-corsair-rm1000x-1000w-389')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Corsair RM1000x 1000W', 'nguon-corsair-rm1000x-1000w-389', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p389 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p389, 'NGU-N-CORSAIR-RM1000X-1000W-389', 3800000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p389, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20Corsair%20RM1000x%201000W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p389, N'Công suất', N'1000W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p389, N'Chuẩn 80 Plus', N'80 Plus Gold', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p389, N'Loại nguồn', N'Full-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-fsp-hydro-ti-pro-850w-390')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn FSP Hydro Ti Pro 850W', 'nguon-fsp-hydro-ti-pro-850w-390', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'FSP'), 1, GETDATE());
    DECLARE @p390 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p390, 'NGU-N-FSP-HYDRO-TI-PRO-850W-390', 4300000, NULL, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p390, 'https://placehold.co/400x400?text=Ngu%E1%BB%93n%20FSP%20Hydro%20Ti%20Pro%20850W', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p390, N'Công suất', N'850W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p390, N'Chuẩn 80 Plus', N'80 Plus Titanium', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p390, N'Loại nguồn', N'Full-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-deepcool-cc560-391')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case DeepCool CC560', 'vo-case-deepcool-cc560-391', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'DeepCool'), 1, GETDATE());
    DECLARE @p391 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p391, 'V-CASE-DEEPCOOL-CC560-391', 750000, NULL, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p391, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20DeepCool%20CC560', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p391, N'Kích thước hỗ trợ', N'ATX / Micro-ATX / Mini-ITX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p391, N'Đặc điểm', N'Mặt lưới tản nhiệt', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-cooler-master-masterbox-q300l-392')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Cooler Master MasterBox Q300L', 'vo-case-cooler-master-masterbox-q300l-392', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Cooler Master'), 1, GETDATE());
    DECLARE @p392 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p392, 'V-CASE-COOLER-MASTER-MASTERBOX-Q300L-392', 650000, NULL, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p392, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Cooler%20Master%20MasterBo', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p392, N'Kích thước hỗ trợ', N'Micro-ATX / Mini-ITX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p392, N'Đặc điểm', N'Nhỏ gọn', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-nzxt-h210-393')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case NZXT H210', 'vo-case-nzxt-h210-393', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'NZXT'), 1, GETDATE());
    DECLARE @p393 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p393, 'V-CASE-NZXT-H210-393', 900000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p393, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20NZXT%20H210', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p393, N'Kích thước hỗ trợ', N'Mini-ITX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p393, N'Đặc điểm', N'Kính cường lực', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-lian-li-lancool-205-394')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Lian Li Lancool 205', 'vo-case-lian-li-lancool-205-394', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Lian Li'), 1, GETDATE());
    DECLARE @p394 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p394, 'V-CASE-LIAN-LI-LANCOOL-205-394', 950000, NULL, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p394, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Lian%20Li%20Lancool%20205', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p394, N'Kích thước hỗ trợ', N'ATX / Micro-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p394, N'Đặc điểm', N'Luồng khí tối ưu', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-deepcool-ch370-395')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case DeepCool CH370', 'vo-case-deepcool-ch370-395', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'DeepCool'), 1, GETDATE());
    DECLARE @p395 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p395, 'V-CASE-DEEPCOOL-CH370-395', 1050000, NULL, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p395, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20DeepCool%20CH370', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p395, N'Kích thước hỗ trợ', N'Micro-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p395, N'Đặc điểm', N'Kính cường lực', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-nzxt-h5-flow-396')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case NZXT H5 Flow', 'vo-case-nzxt-h5-flow-396', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'NZXT'), 1, GETDATE());
    DECLARE @p396 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p396, 'V-CASE-NZXT-H5-FLOW-396', 1600000, NULL, 30, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p396, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20NZXT%20H5%20Flow', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p396, N'Kích thước hỗ trợ', N'ATX / Micro-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p396, N'Đặc điểm', N'Luồng khí tối ưu', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-lian-li-lancool-ii-mesh-397')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Lian Li Lancool II Mesh', 'vo-case-lian-li-lancool-ii-mesh-397', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Lian Li'), 1, GETDATE());
    DECLARE @p397 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p397, 'V-CASE-LIAN-LI-LANCOOL-II-MESH-397', 1900000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p397, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Lian%20Li%20Lancool%20II%20Mes', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p397, N'Kích thước hỗ trợ', N'ATX / E-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p397, N'Đặc điểm', N'Mặt lưới tản nhiệt, 4 quạt sẵn', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-corsair-4000d-solid-398')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Corsair 4000D Solid', 'vo-case-corsair-4000d-solid-398', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p398 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p398, 'V-CASE-CORSAIR-4000D-SOLID-398', 2000000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p398, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Corsair%204000D%20Solid', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p398, N'Kích thước hỗ trợ', N'ATX / Micro-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p398, N'Đặc điểm', N'Kính cường lực', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-lian-li-o11-dynamic-399')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Lian Li O11 Dynamic', 'vo-case-lian-li-o11-dynamic-399', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Lian Li'), 1, GETDATE());
    DECLARE @p399 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p399, 'V-CASE-LIAN-LI-O11-DYNAMIC-399', 3400000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p399, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20Lian%20Li%20O11%20Dynamic', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p399, N'Kích thước hỗ trợ', N'ATX / E-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p399, N'Đặc điểm', N'Kính cường lực 3 mặt', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-nzxt-h9-flow-400')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case NZXT H9 Flow', 'vo-case-nzxt-h9-flow-400', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'NZXT'), 1, GETDATE());
    DECLARE @p400 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p400, 'V-CASE-NZXT-H9-FLOW-400', 3900000, NULL, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p400, 'https://placehold.co/400x400?text=V%E1%BB%8F%20case%20NZXT%20H9%20Flow', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p400, N'Kích thước hỗ trợ', N'ATX / E-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p400, N'Đặc điểm', N'Dual-chamber, kính cường lực', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-khi-cooler-master-hyper-212-black-edition-401')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt khí Cooler Master Hyper 212 Black Edition', 'tan-nhiet-khi-cooler-master-hyper-212-black-edition-401', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'Cooler Master'), 1, GETDATE());
    DECLARE @p401 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p401, 'T-N-NHI-T-KH-COOLER-MASTER-HYPER-212-BLA-401', 550000, NULL, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p401, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20kh%C3%AD%20Cooler%20Master%20Hy', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p401, N'Loại tản nhiệt', N'Khí', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p401, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p401, N'Kích thước quạt', N'120mm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-khi-deepcool-gammaxx-400-402')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt khí DeepCool Gammaxx 400', 'tan-nhiet-khi-deepcool-gammaxx-400-402', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'DeepCool'), 1, GETDATE());
    DECLARE @p402 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p402, 'T-N-NHI-T-KH-DEEPCOOL-GAMMAXX-400-402', 500000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p402, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20kh%C3%AD%20DeepCool%20Gammaxx', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p402, N'Loại tản nhiệt', N'Khí', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p402, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p402, N'Kích thước quạt', N'120mm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-khi-deepcool-ag400-403')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt khí DeepCool AG400', 'tan-nhiet-khi-deepcool-ag400-403', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'DeepCool'), 1, GETDATE());
    DECLARE @p403 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p403, 'T-N-NHI-T-KH-DEEPCOOL-AG400-403', 450000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p403, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20kh%C3%AD%20DeepCool%20AG400', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p403, N'Loại tản nhiệt', N'Khí', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p403, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p403, N'Kích thước quạt', N'120mm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-khi-deepcool-ak400-404')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt khí DeepCool AK400', 'tan-nhiet-khi-deepcool-ak400-404', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'DeepCool'), 1, GETDATE());
    DECLARE @p404 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p404, 'T-N-NHI-T-KH-DEEPCOOL-AK400-404', 750000, NULL, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p404, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20kh%C3%AD%20DeepCool%20AK400', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p404, N'Loại tản nhiệt', N'Khí', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p404, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p404, N'Kích thước quạt', N'120mm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-khi-cooler-master-ma410p-405')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt khí Cooler Master MA410P', 'tan-nhiet-khi-cooler-master-ma410p-405', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'Cooler Master'), 1, GETDATE());
    DECLARE @p405 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p405, 'T-N-NHI-T-KH-COOLER-MASTER-MA410P-405', 950000, NULL, 35, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p405, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20kh%C3%AD%20Cooler%20Master%20MA', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p405, N'Loại tản nhiệt', N'Khí', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p405, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p405, N'Kích thước quạt', N'120mm ARGB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-nuoc-nzxt-kraken-240-406')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt nước NZXT Kraken 240', 'tan-nhiet-nuoc-nzxt-kraken-240-406', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'NZXT'), 1, GETDATE());
    DECLARE @p406 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p406, 'T-N-NHI-T-N-C-NZXT-KRAKEN-240-406', 2400000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p406, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20n%C6%B0%E1%BB%9Bc%20NZXT%20Kraken%20240', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p406, N'Loại tản nhiệt', N'Nước AIO', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p406, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p406, N'Kích thước quạt', N'2x120mm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-nuoc-cooler-master-masterliquid-360-407')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt nước Cooler Master MasterLiquid 360', 'tan-nhiet-nuoc-cooler-master-masterliquid-360-407', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'Cooler Master'), 1, GETDATE());
    DECLARE @p407 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p407, 'T-N-NHI-T-N-C-COOLER-MASTER-MASTERLIQUID-407', 3200000, 3616000, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p407, 'https://placehold.co/400x400?text=T%E1%BA%A3n%20nhi%E1%BB%87t%20n%C6%B0%E1%BB%9Bc%20Cooler%20Master%20M', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p407, N'Loại tản nhiệt', N'Nước AIO', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p407, N'Tương thích socket', N'Intel & AMD đa nền tảng', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p407, N'Kích thước quạt', N'3x120mm', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-lg-22-inch-75hz-408')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình LG 22 inch 75Hz', 'man-hinh-lg-22-inch-75hz-408', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'LG'), 1, GETDATE());
    DECLARE @p408 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p408, 'M-N-H-NH-LG-22-INCH-75HZ-408', 2300000, NULL, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p408, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20LG%2022%20inch%2075Hz', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p408, N'Kích thước', N'22 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p408, N'Tần số quét', N'75Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p408, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-samsung-24-inch-75hz-409')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình Samsung 24 inch 75Hz', 'man-hinh-samsung-24-inch-75hz-409', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p409 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p409, 'M-N-H-NH-SAMSUNG-24-INCH-75HZ-409', 2600000, NULL, 21, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p409, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20Samsung%2024%20inch%2075Hz', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p409, N'Kích thước', N'24 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p409, N'Tần số quét', N'75Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p409, N'Tấm nền', N'VA', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-aoc-24-inch-75hz-410')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình AOC 24 inch 75Hz', 'man-hinh-aoc-24-inch-75hz-410', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'AOC'), 1, GETDATE());
    DECLARE @p410 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p410, 'M-N-H-NH-AOC-24-INCH-75HZ-410', 2400000, NULL, 39, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p410, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20AOC%2024%20inch%2075Hz', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p410, N'Kích thước', N'24 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p410, N'Tần số quét', N'75Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p410, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-benq-27-inch-75hz-411')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình BenQ 27 inch 75Hz', 'man-hinh-benq-27-inch-75hz-411', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'BenQ'), 1, GETDATE());
    DECLARE @p411 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p411, 'M-N-H-NH-BENQ-27-INCH-75HZ-411', 3300000, 3531000, 39, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p411, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20BenQ%2027%20inch%2075Hz', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p411, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p411, N'Tần số quét', N'75Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p411, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-lg-ultragear-24-inch-144hz-412')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình LG UltraGear 24 inch 144Hz', 'man-hinh-lg-ultragear-24-inch-144hz-412', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'LG'), 1, GETDATE());
    DECLARE @p412 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p412, 'M-N-H-NH-LG-ULTRAGEAR-24-INCH-144HZ-412', 4600000, NULL, 40, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p412, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20LG%20UltraGear%2024%20inch%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p412, N'Kích thước', N'24 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p412, N'Tần số quét', N'144Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p412, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-samsung-odyssey-24-inch-144hz-413')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình Samsung Odyssey 24 inch 144Hz', 'man-hinh-samsung-odyssey-24-inch-144hz-413', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p413 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p413, 'M-N-H-NH-SAMSUNG-ODYSSEY-24-INCH-144HZ-413', 4900000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p413, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20Samsung%20Odyssey%2024%20in', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p413, N'Kích thước', N'24 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p413, N'Tần số quét', N'144Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p413, N'Tấm nền', N'VA', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-asus-tuf-24-inch-144hz-414')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình ASUS TUF 24 inch 144Hz', 'man-hinh-asus-tuf-24-inch-144hz-414', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p414 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p414, 'M-N-H-NH-ASUS-TUF-24-INCH-144HZ-414', 4700000, NULL, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p414, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20ASUS%20TUF%2024%20inch%20144H', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p414, N'Kích thước', N'24 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p414, N'Tần số quét', N'144Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p414, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-aoc-24-inch-144hz-cong-415')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình AOC 24 inch 144Hz Cong', 'man-hinh-aoc-24-inch-144hz-cong-415', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'AOC'), 1, GETDATE());
    DECLARE @p415 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p415, 'M-N-H-NH-AOC-24-INCH-144HZ-CONG-415', 5200000, NULL, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p415, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20AOC%2024%20inch%20144Hz%20Con', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p415, N'Kích thước', N'24 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p415, N'Tần số quét', N'144Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p415, N'Tấm nền', N'VA', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p415, N'Độ cong', N'1500R', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-viewsonic-27-inch-144hz-416')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình ViewSonic 27 inch 144Hz', 'man-hinh-viewsonic-27-inch-144hz-416', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'ViewSonic'), 1, GETDATE());
    DECLARE @p416 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p416, 'M-N-H-NH-VIEWSONIC-27-INCH-144HZ-416', 5900000, NULL, 28, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p416, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20ViewSonic%2027%20inch%20144', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p416, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p416, N'Tần số quét', N'144Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p416, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-benq-mobiuz-27-inch-144hz-417')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình BenQ Mobiuz 27 inch 144Hz', 'man-hinh-benq-mobiuz-27-inch-144hz-417', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'BenQ'), 1, GETDATE());
    DECLARE @p417 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p417, 'M-N-H-NH-BENQ-MOBIUZ-27-INCH-144HZ-417', 6800000, NULL, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p417, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20BenQ%20Mobiuz%2027%20inch%201', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p417, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p417, N'Tần số quét', N'144Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p417, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-asus-rog-strix-27-inch-165hz-418')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình ASUS ROG Strix 27 inch 165Hz', 'man-hinh-asus-rog-strix-27-inch-165hz-418', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p418 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p418, 'M-N-H-NH-ASUS-ROG-STRIX-27-INCH-165HZ-418', 9500000, NULL, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p418, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20ASUS%20ROG%20Strix%2027%20inc', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p418, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p418, N'Tần số quét', N'165Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p418, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-lg-ultragear-27-inch-240hz-419')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình LG UltraGear 27 inch 240Hz', 'man-hinh-lg-ultragear-27-inch-240hz-419', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'LG'), 1, GETDATE());
    DECLARE @p419 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p419, 'M-N-H-NH-LG-ULTRAGEAR-27-INCH-240HZ-419', 11800000, NULL, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p419, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20LG%20UltraGear%2027%20inch%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p419, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p419, N'Tần số quét', N'240Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p419, N'Tấm nền', N'Nano IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-samsung-odyssey-g7-32-inch-240hz-420')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình Samsung Odyssey G7 32 inch 240Hz', 'man-hinh-samsung-odyssey-g7-32-inch-240hz-420', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p420 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p420, 'M-N-H-NH-SAMSUNG-ODYSSEY-G7-32-INCH-240H-420', 12900000, 13545000, 35, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p420, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20Samsung%20Odyssey%20G7%2032', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p420, N'Kích thước', N'32 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p420, N'Tần số quét', N'240Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p420, N'Tấm nền', N'VA', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p420, N'Độ cong', N'1000R', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-lg-ultrawide-34-inch-144hz-421')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình LG UltraWide 34 inch 144Hz', 'man-hinh-lg-ultrawide-34-inch-144hz-421', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'LG'), 1, GETDATE());
    DECLARE @p421 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p421, 'M-N-H-NH-LG-ULTRAWIDE-34-INCH-144HZ-421', 12500000, NULL, 38, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p421, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20LG%20UltraWide%2034%20inch%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p421, N'Kích thước', N'34 inch Ultrawide', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p421, N'Tần số quét', N'144Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p421, N'Tấm nền', N'IPS', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-asus-rog-strix-xg49-49-inch-144hz-422')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình ASUS ROG Strix XG49 49 inch 144Hz', 'man-hinh-asus-rog-strix-xg49-49-inch-144hz-422', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p422 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p422, 'M-N-H-NH-ASUS-ROG-STRIX-XG49-49-INCH-144-422', 15900000, NULL, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p422, 'https://placehold.co/400x400?text=M%C3%A0n%20h%C3%ACnh%20ASUS%20ROG%20Strix%20XG49%204', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p422, N'Kích thước', N'49 inch Ultrawide', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p422, N'Tần số quét', N'144Hz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p422, N'Tấm nền', N'VA', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-logitech-k835-423')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ Logitech K835', 'ban-phim-co-logitech-k835-423', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p423 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p423, 'B-N-PH-M-C-LOGITECH-K835-423', 650000, NULL, 39, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p423, 'https://placehold.co/400x400?text=B%C3%A0n%20ph%C3%ADm%20c%C6%A1%20Logitech%20K835', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p423, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p423, N'Switch', N'Blue switch', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-razer-cynosa-lite-424')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ Razer Cynosa Lite', 'ban-phim-co-razer-cynosa-lite-424', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Razer'), 1, GETDATE());
    DECLARE @p424 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p424, 'B-N-PH-M-C-RAZER-CYNOSA-LITE-424', 750000, 818000, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p424, 'https://placehold.co/400x400?text=B%C3%A0n%20ph%C3%ADm%20c%C6%A1%20Razer%20Cynosa%20Lite', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p424, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p424, N'Switch', N'Membrane', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-steelseries-apex-3-425')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ SteelSeries Apex 3', 'ban-phim-co-steelseries-apex-3-425', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'SteelSeries'), 1, GETDATE());
    DECLARE @p425 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p425, 'B-N-PH-M-C-STEELSERIES-APEX-3-425', 950000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p425, 'https://placehold.co/400x400?text=B%C3%A0n%20ph%C3%ADm%20c%C6%A1%20SteelSeries%20Apex%203', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p425, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p425, N'Switch', N'Whisper-quiet', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-keychron-k8-pro-426')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ Keychron K8 Pro', 'ban-phim-co-keychron-k8-pro-426', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Keychron'), 1, GETDATE());
    DECLARE @p426 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p426, 'B-N-PH-M-C-KEYCHRON-K8-PRO-426', 1800000, NULL, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p426, 'https://placehold.co/400x400?text=B%C3%A0n%20ph%C3%ADm%20c%C6%A1%20Keychron%20K8%20Pro', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p426, N'Kết nối', N'Bluetooth / USB-C', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p426, N'Switch', N'Gateron Pro', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-razer-blackwidow-v4-427')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ Razer BlackWidow V4', 'ban-phim-co-razer-blackwidow-v4-427', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Razer'), 1, GETDATE());
    DECLARE @p427 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p427, 'B-N-PH-M-C-RAZER-BLACKWIDOW-V4-427', 2600000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p427, 'https://placehold.co/400x400?text=B%C3%A0n%20ph%C3%ADm%20c%C6%A1%20Razer%20BlackWidow%20V', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p427, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p427, N'Switch', N'Green switch', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-logitech-g-pro-x-428')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ Logitech G Pro X', 'ban-phim-co-logitech-g-pro-x-428', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p428 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p428, 'B-N-PH-M-C-LOGITECH-G-PRO-X-428', 2900000, NULL, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p428, 'https://placehold.co/400x400?text=B%C3%A0n%20ph%C3%ADm%20c%C6%A1%20Logitech%20G%20Pro%20X', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p428, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p428, N'Switch', N'GX Blue hot-swap', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-logitech-g102-429')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột Logitech G102', 'chuot-logitech-g102-429', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p429 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p429, 'CHU-T-LOGITECH-G102-429', 420000, 475000, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p429, 'https://placehold.co/400x400?text=Chu%E1%BB%99t%20Logitech%20G102', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p429, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p429, N'DPI', N'8000 DPI', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-razer-deathadder-v2-430')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột Razer DeathAdder V2', 'chuot-razer-deathadder-v2-430', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Razer'), 1, GETDATE());
    DECLARE @p430 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p430, 'CHU-T-RAZER-DEATHADDER-V2-430', 750000, 818000, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p430, 'https://placehold.co/400x400?text=Chu%E1%BB%99t%20Razer%20DeathAdder%20V2', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p430, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p430, N'DPI', N'20000 DPI', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-steelseries-rival-3-431')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột SteelSeries Rival 3', 'chuot-steelseries-rival-3-431', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'SteelSeries'), 1, GETDATE());
    DECLARE @p431 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p431, 'CHU-T-STEELSERIES-RIVAL-3-431', 680000, NULL, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p431, 'https://placehold.co/400x400?text=Chu%E1%BB%99t%20SteelSeries%20Rival%203', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p431, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p431, N'DPI', N'8500 DPI', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-logitech-g502-hero-432')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột Logitech G502 Hero', 'chuot-logitech-g502-hero-432', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p432 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p432, 'CHU-T-LOGITECH-G502-HERO-432', 1600000, NULL, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p432, 'https://placehold.co/400x400?text=Chu%E1%BB%99t%20Logitech%20G502%20Hero', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p432, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p432, N'DPI', N'25600 DPI', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-razer-viper-v2-pro-433')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột Razer Viper V2 Pro', 'chuot-razer-viper-v2-pro-433', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Razer'), 1, GETDATE());
    DECLARE @p433 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p433, 'CHU-T-RAZER-VIPER-V2-PRO-433', 2700000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p433, 'https://placehold.co/400x400?text=Chu%E1%BB%99t%20Razer%20Viper%20V2%20Pro', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p433, N'Kết nối', N'Không dây 2.4GHz', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p433, N'DPI', N'30000 DPI', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tai-nghe-logitech-g335-434')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tai nghe Logitech G335', 'tai-nghe-logitech-g335-434', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p434 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p434, 'TAI-NGHE-LOGITECH-G335-434', 680000, NULL, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p434, 'https://placehold.co/400x400?text=Tai%20nghe%20Logitech%20G335', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p434, N'Kết nối', N'Có dây 3.5mm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p434, N'Driver', N'40mm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tai-nghe-steelseries-arctis-1-435')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tai nghe SteelSeries Arctis 1', 'tai-nghe-steelseries-arctis-1-435', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'SteelSeries'), 1, GETDATE());
    DECLARE @p435 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p435, 'TAI-NGHE-STEELSERIES-ARCTIS-1-435', 1100000, NULL, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p435, 'https://placehold.co/400x400?text=Tai%20nghe%20SteelSeries%20Arctis%201', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p435, N'Kết nối', N'Có dây 3.5mm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p435, N'Driver', N'40mm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tai-nghe-hyperx-cloud-stinger-2-436')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tai nghe HyperX Cloud Stinger 2', 'tai-nghe-hyperx-cloud-stinger-2-436', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'HyperX'), 1, GETDATE());
    DECLARE @p436 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p436, 'TAI-NGHE-HYPERX-CLOUD-STINGER-2-436', 1900000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p436, 'https://placehold.co/400x400?text=Tai%20nghe%20HyperX%20Cloud%20Stinger%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p436, N'Kết nối', N'Có dây USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p436, N'Driver', N'50mm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tai-nghe-razer-blackshark-v2-pro-437')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tai nghe Razer BlackShark V2 Pro', 'tai-nghe-razer-blackshark-v2-pro-437', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Razer'), 1, GETDATE());
    DECLARE @p437 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p437, 'TAI-NGHE-RAZER-BLACKSHARK-V2-PRO-437', 3200000, 3424000, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p437, 'https://placehold.co/400x400?text=Tai%20nghe%20Razer%20BlackShark%20V2%20P', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p437, N'Kết nối', N'Không dây 2.4GHz', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p437, N'Driver', N'50mm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'webcam-logitech-c920-438')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Webcam Logitech C920', 'webcam-logitech-c920-438', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p438 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p438, 'WEBCAM-LOGITECH-C920-438', 1300000, NULL, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p438, 'https://placehold.co/400x400?text=Webcam%20Logitech%20C920', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p438, N'Kết nối', N'USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p438, N'Độ phân giải', N'1080p 30fps', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'webcam-logitech-brio-100-439')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Webcam Logitech Brio 100', 'webcam-logitech-brio-100-439', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p439 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p439, 'WEBCAM-LOGITECH-BRIO-100-439', 750000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p439, 'https://placehold.co/400x400?text=Webcam%20Logitech%20Brio%20100', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p439, N'Kết nối', N'USB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p439, N'Độ phân giải', N'1080p 30fps', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'loa-vi-tinh-logitech-z407-440')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Loa vi tính Logitech Z407', 'loa-vi-tinh-logitech-z407-440', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p440 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p440, 'LOA-VI-T-NH-LOGITECH-Z407-440', 1500000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p440, 'https://placehold.co/400x400?text=Loa%20vi%20t%C3%ADnh%20Logitech%20Z407', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p440, N'Kết nối', N'Bluetooth / 3.5mm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p440, N'Công suất', N'2.1 kênh', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'balo-laptop-anker-chong-soc-15-6-inch-441')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Balo laptop Anker chống sốc 15.6 inch', 'balo-laptop-anker-chong-soc-15-6-inch-441', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p441 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p441, 'BALO-LAPTOP-ANKER-CH-NG-S-C-15-6-INCH-441', 650000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p441, 'https://placehold.co/400x400?text=Balo%20laptop%20Anker%20ch%E1%BB%91ng%20s%E1%BB%91c%2015', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p441, N'Chất liệu', N'Vải chống nước', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p441, N'Kích thước', N'15.6 inch', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tui-chong-soc-ugreen-14-inch-442')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Túi chống sốc Ugreen 14 inch', 'tui-chong-soc-ugreen-14-inch-442', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Ugreen'), 1, GETDATE());
    DECLARE @p442 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p442, 'T-I-CH-NG-S-C-UGREEN-14-INCH-442', 350000, NULL, 21, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p442, 'https://placehold.co/400x400?text=T%C3%BAi%20ch%E1%BB%91ng%20s%E1%BB%91c%20Ugreen%2014%20inch', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p442, N'Chất liệu', N'Neoprene', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p442, N'Kích thước', N'14 inch', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'gia-do-laptop-nhom-ugreen-443')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Giá đỡ laptop nhôm Ugreen', 'gia-do-laptop-nhom-ugreen-443', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Ugreen'), 1, GETDATE());
    DECLARE @p443 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p443, 'GI-LAPTOP-NH-M-UGREEN-443', 420000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p443, 'https://placehold.co/400x400?text=Gi%C3%A1%20%C4%91%E1%BB%A1%20laptop%20nh%C3%B4m%20Ugreen', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p443, N'Chất liệu', N'Hợp kim nhôm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p443, N'Tải trọng', N'Tối đa 5kg', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'balo-gaming-anker-17-inch-444')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Balo gaming Anker 17 inch', 'balo-gaming-anker-17-inch-444', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p444 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p444, 'BALO-GAMING-ANKER-17-INCH-444', 850000, 910000, 14, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p444, 'https://placehold.co/400x400?text=Balo%20gaming%20Anker%2017%20inch', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p444, N'Chất liệu', N'Vải chống nước', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p444, N'Kích thước', N'17 inch', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tui-dung-phu-kien-ugreen-445')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Túi đựng phụ kiện Ugreen', 'tui-dung-phu-kien-ugreen-445', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Ugreen'), 1, GETDATE());
    DECLARE @p445 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p445, 'T-I-NG-PH-KI-N-UGREEN-445', 250000, 275000, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p445, 'https://placehold.co/400x400?text=T%C3%BAi%20%C4%91%E1%BB%B1ng%20ph%E1%BB%A5%20ki%E1%BB%87n%20Ugreen', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p445, N'Chất liệu', N'Vải polyester', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p445, N'Kích thước', N'Nhỏ gọn', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'hub-usb-c-6-trong-1-ugreen-446')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Hub USB-C 6 trong 1 Ugreen', 'hub-usb-c-6-trong-1-ugreen-446', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Ugreen'), 1, GETDATE());
    DECLARE @p446 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p446, 'HUB-USB-C-6-TRONG-1-UGREEN-446', 550000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p446, 'https://placehold.co/400x400?text=Hub%20USB-C%206%20trong%201%20Ugreen', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p446, N'Cổng kết nối', N'HDMI, USB 3.0, USB-C PD', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p446, N'Chuẩn', N'USB-C', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cap-sac-usb-c-to-lightning-anker-447')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Cáp sạc USB-C to Lightning Anker', 'cap-sac-usb-c-to-lightning-anker-447', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p447 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p447, 'C-P-S-C-USB-C-TO-LIGHTNING-ANKER-447', 280000, 302000, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p447, 'https://placehold.co/400x400?text=C%C3%A1p%20s%E1%BA%A1c%20USB-C%20to%20Lightning%20Ank', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p447, N'Chiều dài', N'1.8m', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p447, N'Công suất', N'20W', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'sac-nhanh-65w-anker-gan-448')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Sạc nhanh 65W Anker GaN', 'sac-nhanh-65w-anker-gan-448', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p448 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p448, 'S-C-NHANH-65W-ANKER-GAN-448', 750000, 803000, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p448, 'https://placehold.co/400x400?text=S%E1%BA%A1c%20nhanh%2065W%20Anker%20GaN', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p448, N'Công suất', N'65W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p448, N'Chuẩn', N'GaN, USB-C PD', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'bo-phat-wifi-6-tp-link-449')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bộ phát WiFi 6 TP-Link', 'bo-phat-wifi-6-tp-link-449', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'TP-Link'), 1, GETDATE());
    DECLARE @p449 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p449, 'B-PH-T-WIFI-6-TP-LINK-449', 950000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p449, 'https://placehold.co/400x400?text=B%E1%BB%99%20ph%C3%A1t%20WiFi%206%20TP-Link', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p449, N'Chuẩn', N'WiFi 6', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p449, N'Tốc độ', N'Tối đa 1.5Gbps', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'router-wifi-tp-link-archer-c6-450')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Router WiFi TP-Link Archer C6', 'router-wifi-tp-link-archer-c6-450', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'TP-Link'), 1, GETDATE());
    DECLARE @p450 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p450, 'ROUTER-WIFI-TP-LINK-ARCHER-C6-450', 650000, NULL, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p450, 'https://placehold.co/400x400?text=Router%20WiFi%20TP-Link%20Archer%20C6', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p450, N'Chuẩn', N'WiFi 5 AC1200', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p450, N'Cổng kết nối', N'4x LAN Gigabit', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'sac-du-phong-anker-10000mah-451')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Sạc dự phòng Anker 10000mAh', 'sac-du-phong-anker-10000mah-451', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p451 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p451, 'S-C-D-PH-NG-ANKER-10000MAH-451', 550000, 611000, 30, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p451, 'https://placehold.co/400x400?text=S%E1%BA%A1c%20d%E1%BB%B1%20ph%C3%B2ng%20Anker%2010000mAh', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p451, N'Dung lượng', N'10000mAh', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p451, N'Công suất', N'20W', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tai-nghe-bluetooth-anker-soundcore-452')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tai nghe Bluetooth Anker Soundcore', 'tai-nghe-bluetooth-anker-soundcore-452', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p452 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p452, 'TAI-NGHE-BLUETOOTH-ANKER-SOUNDCORE-452', 650000, NULL, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p452, 'https://placehold.co/400x400?text=Tai%20nghe%20Bluetooth%20Anker%20Sound', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p452, N'Kết nối', N'Bluetooth 5.3', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p452, N'Âm thanh', N'Chống ồn chủ động', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'lot-chuot-ugreen-gaming-size-l-453')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Lót chuột Ugreen Gaming size L', 'lot-chuot-ugreen-gaming-size-l-453', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Ugreen'), 1, GETDATE());
    DECLARE @p453 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p453, 'L-T-CHU-T-UGREEN-GAMING-SIZE-L-453', 150000, 162000, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p453, 'https://placehold.co/400x400?text=L%C3%B3t%20chu%E1%BB%99t%20Ugreen%20Gaming%20size%20L', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p453, N'Chất liệu', N'Vải + cao su', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p453, N'Kích thước', N'80x30cm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'lot-chuot-rgb-corsair-mm700-454')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Lót chuột RGB Corsair MM700', 'lot-chuot-rgb-corsair-mm700-454', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p454 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p454, 'L-T-CHU-T-RGB-CORSAIR-MM700-454', 850000, NULL, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p454, 'https://placehold.co/400x400?text=L%C3%B3t%20chu%E1%BB%99t%20RGB%20Corsair%20MM700', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p454, N'Chất liệu', N'Vải + viền RGB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p454, N'Kích thước', N'93x30cm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tai-nghe-nhet-tai-anker-soundcore-p20i-455')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tai nghe nhét tai Anker Soundcore P20i', 'tai-nghe-nhet-tai-anker-soundcore-p20i-455', N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p455 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p455, 'TAI-NGHE-NH-T-TAI-ANKER-SOUNDCORE-P20I-455', 450000, NULL, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p455, 'https://placehold.co/400x400?text=Tai%20nghe%20nh%C3%A9t%20tai%20Anker%20Soundc', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p455, N'Kết nối', N'Bluetooth 5.3', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p455, N'Âm thanh', N'Chống ồn thụ động', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-acer-nitro-5-an515-gaming-456')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Acer Nitro 5 AN515 Gaming', 'laptop-acer-nitro-5-an515-gaming-456', N'Intel Core i5-12450H, 16GB RAM, 512GB SSD, RTX 3050 4GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ACER'), 1, GETDATE());
    DECLARE @p456 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p456, 'LAPTOP-ACER-NITRO-5-AN515-GAMING-456', 17500000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p456, 'https://placehold.co/400x400?text=Laptop%20Acer%20Nitro%205%20AN515%20Gami', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p456, N'CPU', N'Intel Core i5-12450H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p456, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p456, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p456, N'Card đồ họa', N'RTX 3050 4GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-tuf-gaming-f15-fx507-gaming-457')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS TUF Gaming F15 FX507 Gaming', 'laptop-asus-tuf-gaming-f15-fx507-gaming-457', N'Intel Core i5-13500H, 16GB RAM, 512GB SSD, RTX 4050 6GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p457 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p457, 'LAPTOP-ASUS-TUF-GAMING-F15-FX507-GAMING-457', 18500000, NULL, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p457, 'https://placehold.co/400x400?text=Laptop%20ASUS%20TUF%20Gaming%20F15%20FX5', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p457, N'CPU', N'Intel Core i5-13500H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p457, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p457, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p457, N'Card đồ họa', N'RTX 4050 6GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-msi-bravo-15-gaming-458')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop MSI Bravo 15 Gaming', 'laptop-msi-bravo-15-gaming-458', N'AMD Ryzen 5 7535HS, 16GB RAM, 512GB SSD, RX 6550M 4GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p458 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p458, 'LAPTOP-MSI-BRAVO-15-GAMING-458', 16900000, 18421000, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p458, 'https://placehold.co/400x400?text=Laptop%20MSI%20Bravo%2015%20Gaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p458, N'CPU', N'AMD Ryzen 5 7535HS', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p458, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p458, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p458, N'Card đồ họa', N'RX 6550M 4GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-lenovo-loq-15-irh9-gaming-459')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Lenovo LOQ 15 IRH9 Gaming', 'laptop-lenovo-loq-15-irh9-gaming-459', N'Intel Core i5-13450HX, 16GB RAM, 512GB SSD, RTX 4050 6GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Lenovo'), 1, GETDATE());
    DECLARE @p459 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p459, 'LAPTOP-LENOVO-LOQ-15-IRH9-GAMING-459', 19900000, NULL, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p459, 'https://placehold.co/400x400?text=Laptop%20Lenovo%20LOQ%2015%20IRH9%20Gami', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p459, N'CPU', N'Intel Core i5-13450HX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p459, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p459, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p459, N'Card đồ họa', N'RTX 4050 6GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-hp-victus-16-gaming-460')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop HP Victus 16 Gaming', 'laptop-hp-victus-16-gaming-460', N'AMD Ryzen 5 7640HS, 16GB RAM, 512GB SSD, RTX 4050 6GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'HP'), 1, GETDATE());
    DECLARE @p460 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p460, 'LAPTOP-HP-VICTUS-16-GAMING-460', 19900000, NULL, 38, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p460, 'https://placehold.co/400x400?text=Laptop%20HP%20Victus%2016%20Gaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p460, N'CPU', N'AMD Ryzen 5 7640HS', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p460, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p460, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p460, N'Card đồ họa', N'RTX 4050 6GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-dell-g15-5535-gaming-461')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Dell G15 5535 Gaming', 'laptop-dell-g15-5535-gaming-461', N'AMD Ryzen 5 7535HS, 16GB RAM, 512GB SSD, RTX 3050 6GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Dell'), 1, GETDATE());
    DECLARE @p461 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p461, 'LAPTOP-DELL-G15-5535-GAMING-461', 18900000, NULL, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p461, 'https://placehold.co/400x400?text=Laptop%20Dell%20G15%205535%20Gaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p461, N'CPU', N'AMD Ryzen 5 7535HS', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p461, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p461, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p461, N'Card đồ họa', N'RTX 3050 6GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-acer-aspire-7-gaming-462')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Acer Aspire 7 Gaming', 'laptop-acer-aspire-7-gaming-462', N'AMD Ryzen 5 5600H, 16GB RAM, 512GB SSD, RTX 3050 4GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ACER'), 1, GETDATE());
    DECLARE @p462 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p462, 'LAPTOP-ACER-ASPIRE-7-GAMING-462', 17200000, NULL, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p462, 'https://placehold.co/400x400?text=Laptop%20Acer%20Aspire%207%20Gaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p462, N'CPU', N'AMD Ryzen 5 5600H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p462, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p462, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p462, N'Card đồ họa', N'RTX 3050 4GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-vivobook-gaming-k3605-463')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS Vivobook Gaming K3605', 'laptop-asus-vivobook-gaming-k3605-463', N'Intel Core i5-13500H, 16GB RAM, 512GB SSD, RTX 3050 6GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p463 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p463, 'LAPTOP-ASUS-VIVOBOOK-GAMING-K3605-463', 16500000, 17655000, 38, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p463, 'https://placehold.co/400x400?text=Laptop%20ASUS%20Vivobook%20Gaming%20K3', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p463, N'CPU', N'Intel Core i5-13500H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p463, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p463, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p463, N'Card đồ họa', N'RTX 3050 6GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-rog-zephyrus-g14-gaming-464')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS ROG Zephyrus G14 Gaming', 'laptop-asus-rog-zephyrus-g14-gaming-464', N'AMD Ryzen 9 7940HS, 16GB RAM, 1TB SSD, RTX 4060 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p464 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p464, 'LAPTOP-ASUS-ROG-ZEPHYRUS-G14-GAMING-464', 29500000, NULL, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p464, 'https://placehold.co/400x400?text=Laptop%20ASUS%20ROG%20Zephyrus%20G14%20G', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p464, N'CPU', N'AMD Ryzen 9 7940HS', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p464, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p464, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p464, N'Card đồ họa', N'RTX 4060 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-msi-katana-15-b14v-gaming-465')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop MSI Katana 15 B14V Gaming', 'laptop-msi-katana-15-b14v-gaming-465', N'Intel Core i7-14650HX, 16GB RAM, 1TB SSD, RTX 4060 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p465 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p465, 'LAPTOP-MSI-KATANA-15-B14V-GAMING-465', 26500000, NULL, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p465, 'https://placehold.co/400x400?text=Laptop%20MSI%20Katana%2015%20B14V%20Gami', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p465, N'CPU', N'Intel Core i7-14650HX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p465, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p465, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p465, N'Card đồ họa', N'RTX 4060 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-acer-predator-helios-neo-16-gaming-466')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Acer Predator Helios Neo 16 Gaming', 'laptop-acer-predator-helios-neo-16-gaming-466', N'Intel Core i7-13700HX, 16GB RAM, 1TB SSD, RTX 4060 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ACER'), 1, GETDATE());
    DECLARE @p466 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p466, 'LAPTOP-ACER-PREDATOR-HELIOS-NEO-16-GAMIN-466', 31500000, NULL, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p466, 'https://placehold.co/400x400?text=Laptop%20Acer%20Predator%20Helios%20Ne', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p466, N'CPU', N'Intel Core i7-13700HX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p466, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p466, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p466, N'Card đồ họa', N'RTX 4060 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-lenovo-legion-5-gaming-467')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Lenovo Legion 5 Gaming', 'laptop-lenovo-legion-5-gaming-467', N'AMD Ryzen 7 7745HX, 16GB RAM, 1TB SSD, RTX 4060 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Lenovo'), 1, GETDATE());
    DECLARE @p467 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p467, 'LAPTOP-LENOVO-LEGION-5-GAMING-467', 27900000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p467, 'https://placehold.co/400x400?text=Laptop%20Lenovo%20Legion%205%20Gaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p467, N'CPU', N'AMD Ryzen 7 7745HX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p467, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p467, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p467, N'Card đồ họa', N'RTX 4060 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-hp-omen-transcend-14-gaming-468')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop HP Omen Transcend 14 Gaming', 'laptop-hp-omen-transcend-14-gaming-468', N'Intel Core Ultra 7 155H, 32GB RAM, 1TB SSD, RTX 4060 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'HP'), 1, GETDATE());
    DECLARE @p468 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p468, 'LAPTOP-HP-OMEN-TRANSCEND-14-GAMING-468', 30900000, NULL, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p468, 'https://placehold.co/400x400?text=Laptop%20HP%20Omen%20Transcend%2014%20Ga', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p468, N'CPU', N'Intel Core Ultra 7 155H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p468, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p468, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p468, N'Card đồ họa', N'RTX 4060 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-dell-alienware-m16-gaming-469')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Dell Alienware m16 Gaming', 'laptop-dell-alienware-m16-gaming-469', N'Intel Core i7-13700HX, 16GB RAM, 1TB SSD, RTX 4070 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Dell'), 1, GETDATE());
    DECLARE @p469 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p469, 'LAPTOP-DELL-ALIENWARE-M16-GAMING-469', 32000000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p469, 'https://placehold.co/400x400?text=Laptop%20Dell%20Alienware%20m16%20Gami', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p469, N'CPU', N'Intel Core i7-13700HX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p469, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p469, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p469, N'Card đồ họa', N'RTX 4070 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-rog-strix-scar-18-gaming-470')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS ROG Strix SCAR 18 Gaming', 'laptop-asus-rog-strix-scar-18-gaming-470', N'Intel Core i9-13980HX, 32GB RAM, 1TB SSD, RTX 4080 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p470 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p470, 'LAPTOP-ASUS-ROG-STRIX-SCAR-18-GAMING-470', 46500000, NULL, 40, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p470, 'https://placehold.co/400x400?text=Laptop%20ASUS%20ROG%20Strix%20SCAR%2018%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p470, N'CPU', N'Intel Core i9-13980HX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p470, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p470, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p470, N'Card đồ họa', N'RTX 4080 12GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-msi-titan-gt77-gaming-471')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop MSI Titan GT77 Gaming', 'laptop-msi-titan-gt77-gaming-471', N'Intel Core i9-13980HX, 32GB RAM, 2TB SSD, RTX 4090 16GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p471 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p471, 'LAPTOP-MSI-TITAN-GT77-GAMING-471', 48000000, NULL, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p471, 'https://placehold.co/400x400?text=Laptop%20MSI%20Titan%20GT77%20Gaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p471, N'CPU', N'Intel Core i9-13980HX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p471, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p471, N'Ổ cứng', N'2TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p471, N'Card đồ họa', N'RTX 4090 16GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-lenovo-legion-pro-7-gaming-472')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Lenovo Legion Pro 7 Gaming', 'laptop-lenovo-legion-pro-7-gaming-472', N'AMD Ryzen 9 7945HX, 32GB RAM, 1TB SSD, RTX 4080 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Lenovo'), 1, GETDATE());
    DECLARE @p472 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p472, 'LAPTOP-LENOVO-LEGION-PRO-7-GAMING-472', 42500000, 46750000, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p472, 'https://placehold.co/400x400?text=Laptop%20Lenovo%20Legion%20Pro%207%20Gam', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p472, N'CPU', N'AMD Ryzen 9 7945HX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p472, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p472, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p472, N'Card đồ họa', N'RTX 4080 12GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-acer-aspire-3-van-phong-473')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Acer Aspire 3 Văn phòng', 'laptop-acer-aspire-3-van-phong-473', N'Intel Core i3-1215U, 8GB RAM, 256GB SSD, Intel UHD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ACER'), 1, GETDATE());
    DECLARE @p473 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p473, 'LAPTOP-ACER-ASPIRE-3-V-N-PH-NG-473', 11500000, NULL, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p473, 'https://placehold.co/400x400?text=Laptop%20Acer%20Aspire%203%20V%C4%83n%20ph%C3%B2ng', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p473, N'CPU', N'Intel Core i3-1215U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p473, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p473, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p473, N'Card đồ họa', N'Intel UHD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-hp-15s-van-phong-474')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop HP 15s Văn phòng', 'laptop-hp-15s-van-phong-474', N'Intel Core i3-1315U, 8GB RAM, 256GB SSD, Intel UHD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'HP'), 1, GETDATE());
    DECLARE @p474 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p474, 'LAPTOP-HP-15S-V-N-PH-NG-474', 12200000, NULL, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p474, 'https://placehold.co/400x400?text=Laptop%20HP%2015s%20V%C4%83n%20ph%C3%B2ng', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p474, N'CPU', N'Intel Core i3-1315U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p474, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p474, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p474, N'Card đồ họa', N'Intel UHD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-lenovo-ideapad-1-van-phong-475')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Lenovo IdeaPad 1 Văn phòng', 'laptop-lenovo-ideapad-1-van-phong-475', N'AMD Ryzen 3 7320U, 8GB RAM, 256GB SSD, AMD Radeon.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Lenovo'), 1, GETDATE());
    DECLARE @p475 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p475, 'LAPTOP-LENOVO-IDEAPAD-1-V-N-PH-NG-475', 11900000, NULL, 31, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p475, 'https://placehold.co/400x400?text=Laptop%20Lenovo%20IdeaPad%201%20V%C4%83n%20ph', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p475, N'CPU', N'AMD Ryzen 3 7320U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p475, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p475, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p475, N'Card đồ họa', N'AMD Radeon', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-expertbook-b1-van-phong-476')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS ExpertBook B1 Văn phòng', 'laptop-asus-expertbook-b1-van-phong-476', N'Intel Core i5-1235U, 8GB RAM, 512GB SSD, Intel UHD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p476 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p476, 'LAPTOP-ASUS-EXPERTBOOK-B1-V-N-PH-NG-476', 14500000, 16385000, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p476, 'https://placehold.co/400x400?text=Laptop%20ASUS%20ExpertBook%20B1%20V%C4%83n%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p476, N'CPU', N'Intel Core i5-1235U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p476, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p476, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p476, N'Card đồ họa', N'Intel UHD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-dell-vostro-15-van-phong-477')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Dell Vostro 15 Văn phòng', 'laptop-dell-vostro-15-van-phong-477', N'Intel Core i5-1335U, 16GB RAM, 512GB SSD, Intel Iris Xe.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Dell'), 1, GETDATE());
    DECLARE @p477 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p477, 'LAPTOP-DELL-VOSTRO-15-V-N-PH-NG-477', 17900000, 19690000, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p477, 'https://placehold.co/400x400?text=Laptop%20Dell%20Vostro%2015%20V%C4%83n%20ph%C3%B2n', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p477, N'CPU', N'Intel Core i5-1335U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p477, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p477, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p477, N'Card đồ họa', N'Intel Iris Xe', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-hp-probook-450-van-phong-478')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop HP ProBook 450 Văn phòng', 'laptop-hp-probook-450-van-phong-478', N'Intel Core i5-1335U, 16GB RAM, 512GB SSD, Intel Iris Xe.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'HP'), 1, GETDATE());
    DECLARE @p478 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p478, 'LAPTOP-HP-PROBOOK-450-V-N-PH-NG-478', 19500000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p478, 'https://placehold.co/400x400?text=Laptop%20HP%20ProBook%20450%20V%C4%83n%20ph%C3%B2n', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p478, N'CPU', N'Intel Core i5-1335U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p478, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p478, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p478, N'Card đồ họa', N'Intel Iris Xe', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-zenbook-14-oled-mong-nhe-479')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS Zenbook 14 OLED Mỏng nhẹ', 'laptop-asus-zenbook-14-oled-mong-nhe-479', N'Intel Core i7-1355U, 16GB RAM, 512GB SSD, Intel Iris Xe.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p479 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p479, 'LAPTOP-ASUS-ZENBOOK-14-OLED-M-NG-NH-479', 26900000, NULL, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p479, 'https://placehold.co/400x400?text=Laptop%20ASUS%20Zenbook%2014%20OLED%20M%E1%BB%8F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p479, N'CPU', N'Intel Core i7-1355U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p479, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p479, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p479, N'Card đồ họa', N'Intel Iris Xe', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-lenovo-yoga-slim-7-mong-nhe-480')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Lenovo Yoga Slim 7 Mỏng nhẹ', 'laptop-lenovo-yoga-slim-7-mong-nhe-480', N'AMD Ryzen 7 7840U, 16GB RAM, 1TB SSD, AMD Radeon 780M.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Lenovo'), 1, GETDATE());
    DECLARE @p480 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p480, 'LAPTOP-LENOVO-YOGA-SLIM-7-M-NG-NH-480', 28500000, 32775000, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p480, 'https://placehold.co/400x400?text=Laptop%20Lenovo%20Yoga%20Slim%207%20M%E1%BB%8Fng', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p480, N'CPU', N'AMD Ryzen 7 7840U', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p480, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p480, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p480, N'Card đồ họa', N'AMD Radeon 780M', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-ryzen-blaze-r5-5600-rtx4060-481')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Ryzen Blaze R5-5600 RTX4060', 'pc-cntt-ryzen-blaze-r5-5600-rtx4060-481', N'AMD Ryzen 5 5600, 16GB RAM, 512GB SSD, RTX 4060 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p481 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p481, 'PC-CNTT-RYZEN-BLAZE-R5-5600-RTX4060-481', 16500000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p481, 'https://placehold.co/400x400?text=PC%20CNTT%20Ryzen%20Blaze%20R5-5600%20RT', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p481, N'CPU', N'AMD Ryzen 5 5600', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p481, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p481, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p481, N'Card đồ họa', N'RTX 4060 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-core-ignite-i5-12400f-rtx3060-482')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Core Ignite i5-12400F RTX3060', 'pc-cntt-core-ignite-i5-12400f-rtx3060-482', N'Intel Core i5-12400F, 16GB RAM, 512GB SSD, RTX 3060 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p482 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p482, 'PC-CNTT-CORE-IGNITE-I5-12400F-RTX3060-482', 15800000, NULL, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p482, 'https://placehold.co/400x400?text=PC%20CNTT%20Core%20Ignite%20i5-12400F%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p482, N'CPU', N'Intel Core i5-12400F', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p482, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p482, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p482, N'Card đồ họa', N'RTX 3060 12GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-swift-r5-4500-rtx3050-483')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Swift R5-4500 RTX3050', 'pc-cntt-swift-r5-4500-rtx3050-483', N'AMD Ryzen 5 4500, 16GB RAM, 512GB SSD, RTX 3050 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p483 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p483, 'PC-CNTT-SWIFT-R5-4500-RTX3050-483', 14500000, NULL, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p483, 'https://placehold.co/400x400?text=PC%20CNTT%20Swift%20R5-4500%20RTX3050', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p483, N'CPU', N'AMD Ryzen 5 4500', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p483, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p483, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p483, N'Card đồ họa', N'RTX 3050 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-nova-i3-13100f-rtx3050-484')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Nova i3-13100F RTX3050', 'pc-cntt-nova-i3-13100f-rtx3050-484', N'Intel Core i3-13100F, 16GB RAM, 512GB SSD, RTX 3050 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p484 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p484, 'PC-CNTT-NOVA-I3-13100F-RTX3050-484', 13900000, 15846000, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p484, 'https://placehold.co/400x400?text=PC%20CNTT%20Nova%20i3-13100F%20RTX3050', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p484, N'CPU', N'Intel Core i3-13100F', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p484, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p484, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p484, N'Card đồ họa', N'RTX 3050 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-bolt-r5-5500-rtx4060-485')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Bolt R5-5500 RTX4060', 'pc-cntt-bolt-r5-5500-rtx4060-485', N'AMD Ryzen 5 5500, 16GB RAM, 512GB SSD, RTX 4060 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p485 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p485, 'PC-CNTT-BOLT-R5-5500-RTX4060-485', 17200000, NULL, 35, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p485, 'https://placehold.co/400x400?text=PC%20CNTT%20Bolt%20R5-5500%20RTX4060', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p485, N'CPU', N'AMD Ryzen 5 5500', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p485, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p485, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p485, N'Card đồ họa', N'RTX 4060 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-vortex-i5-13400f-rtx4060ti-486')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Vortex i5-13400F RTX4060Ti', 'pc-cntt-vortex-i5-13400f-rtx4060ti-486', N'Intel Core i5-13400F, 32GB RAM, 1TB SSD, RTX 4060 Ti 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p486 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p486, 'PC-CNTT-VORTEX-I5-13400F-RTX4060TI-486', 23500000, NULL, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p486, 'https://placehold.co/400x400?text=PC%20CNTT%20Vortex%20i5-13400F%20RTX40', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p486, N'CPU', N'Intel Core i5-13400F', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p486, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p486, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p486, N'Card đồ họa', N'RTX 4060 Ti 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-storm-r5-7600-rtx4070-487')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Storm R5-7600 RTX4070', 'pc-cntt-storm-r5-7600-rtx4070-487', N'AMD Ryzen 5 7600, 32GB RAM, 1TB SSD, RTX 4070 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p487 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p487, 'PC-CNTT-STORM-R5-7600-RTX4070-487', 28900000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p487, 'https://placehold.co/400x400?text=PC%20CNTT%20Storm%20R5-7600%20RTX4070', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p487, N'CPU', N'AMD Ryzen 5 7600', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p487, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p487, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p487, N'Card đồ họa', N'RTX 4070 12GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-phantom-i7-12700f-rtx4060ti-488')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Phantom i7-12700F RTX4060Ti', 'pc-cntt-phantom-i7-12700f-rtx4060ti-488', N'Intel Core i7-12700F, 32GB RAM, 1TB SSD, RTX 4060 Ti 8GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p488 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p488, 'PC-CNTT-PHANTOM-I7-12700F-RTX4060TI-488', 26500000, 30475000, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p488, 'https://placehold.co/400x400?text=PC%20CNTT%20Phantom%20i7-12700F%20RTX4', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p488, N'CPU', N'Intel Core i7-12700F', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p488, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p488, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p488, N'Card đồ họa', N'RTX 4060 Ti 8GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-raptor-r7-7700x-rtx4070-489')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Raptor R7-7700X RTX4070', 'pc-cntt-raptor-r7-7700x-rtx4070-489', N'AMD Ryzen 7 7700X, 32GB RAM, 1TB SSD, RTX 4070 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p489 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p489, 'PC-CNTT-RAPTOR-R7-7700X-RTX4070-489', 31500000, 36225000, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p489, 'https://placehold.co/400x400?text=PC%20CNTT%20Raptor%20R7-7700X%20RTX407', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p489, N'CPU', N'AMD Ryzen 7 7700X', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p489, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p489, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p489, N'Card đồ họa', N'RTX 4070 12GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-eclipse-i5-14400f-rtx4070-490')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Eclipse i5-14400F RTX4070', 'pc-cntt-eclipse-i5-14400f-rtx4070-490', N'Intel Core i5-14400F, 32GB RAM, 1TB SSD, RTX 4070 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p490 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p490, 'PC-CNTT-ECLIPSE-I5-14400F-RTX4070-490', 29500000, 31565000, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p490, 'https://placehold.co/400x400?text=PC%20CNTT%20Eclipse%20i5-14400F%20RTX4', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p490, N'CPU', N'Intel Core i5-14400F', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p490, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p490, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p490, N'Card đồ họa', N'RTX 4070 12GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-titan-ultra-i7-14700f-rtx4080-super-491')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Titan Ultra i7-14700F RTX4080 Super', 'pc-cntt-titan-ultra-i7-14700f-rtx4080-super-491', N'Intel Core i7-14700F, 32GB RAM, 2TB SSD, RTX 4080 Super 16GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p491 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p491, 'PC-CNTT-TITAN-ULTRA-I7-14700F-RTX4080-SU-491', 52900000, NULL, 31, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p491, 'https://placehold.co/400x400?text=PC%20CNTT%20Titan%20Ultra%20i7-14700F%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p491, N'CPU', N'Intel Core i7-14700F', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p491, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p491, N'Ổ cứng', N'2TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p491, N'Card đồ họa', N'RTX 4080 Super 16GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-apex-prime-r7-7800x3d-rtx4070ti-super-492')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Apex Prime R7-7800X3D RTX4070Ti Super', 'pc-cntt-apex-prime-r7-7800x3d-rtx4070ti-super-492', N'AMD Ryzen 7 7800X3D, 32GB RAM, 2TB SSD, RTX 4070 Ti Super 16GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p492 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p492, 'PC-CNTT-APEX-PRIME-R7-7800X3D-RTX4070TI--492', 58500000, NULL, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p492, 'https://placehold.co/400x400?text=PC%20CNTT%20Apex%20Prime%20R7-7800X3D%20', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p492, N'CPU', N'AMD Ryzen 7 7800X3D', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p492, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p492, N'Ổ cứng', N'2TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p492, N'Card đồ họa', N'RTX 4070 Ti Super 16GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-vanguard-i9-13900k-rtx4090-493')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Vanguard i9-13900K RTX4090', 'pc-cntt-vanguard-i9-13900k-rtx4090-493', N'Intel Core i9-13900K, 64GB RAM, 2TB SSD, RTX 4090 24GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p493 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p493, 'PC-CNTT-VANGUARD-I9-13900K-RTX4090-493', 62900000, NULL, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p493, 'https://placehold.co/400x400?text=PC%20CNTT%20Vanguard%20i9-13900K%20RTX', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p493, N'CPU', N'Intel Core i9-13900K', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p493, N'RAM', N'64GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p493, N'Ổ cứng', N'2TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p493, N'Card đồ họa', N'RTX 4090 24GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-van-phong-cntt-office-lite-494')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC Văn Phòng CNTT Office Lite', 'pc-van-phong-cntt-office-lite-494', N'Intel Core i3-12100, 8GB RAM, 256GB SSD, Intel UHD 730.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p494 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p494, 'PC-V-N-PH-NG-CNTT-OFFICE-LITE-494', 9500000, NULL, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p494, 'https://placehold.co/400x400?text=PC%20V%C4%83n%20Ph%C3%B2ng%20CNTT%20Office%20Lite', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p494, N'CPU', N'Intel Core i3-12100', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p494, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p494, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p494, N'Card đồ họa', N'Intel UHD 730', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-van-phong-cntt-office-basic-495')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC Văn Phòng CNTT Office Basic', 'pc-van-phong-cntt-office-basic-495', N'AMD Ryzen 3 4100, 8GB RAM, 256GB SSD, AMD Radeon.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p495 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p495, 'PC-V-N-PH-NG-CNTT-OFFICE-BASIC-495', 9900000, NULL, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p495, 'https://placehold.co/400x400?text=PC%20V%C4%83n%20Ph%C3%B2ng%20CNTT%20Office%20Basic', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p495, N'CPU', N'AMD Ryzen 3 4100', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p495, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p495, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p495, N'Card đồ họa', N'AMD Radeon', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-van-phong-cntt-office-plus-496')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC Văn Phòng CNTT Office Plus', 'pc-van-phong-cntt-office-plus-496', N'Intel Core i5-12400, 16GB RAM, 512GB SSD, Intel UHD 730.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p496 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p496, 'PC-V-N-PH-NG-CNTT-OFFICE-PLUS-496', 11900000, NULL, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p496, 'https://placehold.co/400x400?text=PC%20V%C4%83n%20Ph%C3%B2ng%20CNTT%20Office%20Plus', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p496, N'CPU', N'Intel Core i5-12400', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p496, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p496, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p496, N'Card đồ họa', N'Intel UHD 730', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-van-phong-cntt-office-elite-497')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC Văn Phòng CNTT Office Elite', 'pc-van-phong-cntt-office-elite-497', N'AMD Ryzen 5 5600G, 16GB RAM, 512GB SSD, AMD Radeon Vega 7.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p497 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p497, 'PC-V-N-PH-NG-CNTT-OFFICE-ELITE-497', 12900000, NULL, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p497, 'https://placehold.co/400x400?text=PC%20V%C4%83n%20Ph%C3%B2ng%20CNTT%20Office%20Elite', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p497, N'CPU', N'AMD Ryzen 5 5600G', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p497, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p497, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p497, N'Card đồ họa', N'AMD Radeon Vega 7', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-do-hoa-creator-studio-9-498')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Đồ họa - Creator Studio 9', 'pc-cntt-do-hoa-creator-studio-9-498', N'AMD Ryzen 7 7700X, 32GB RAM, 1TB SSD, RTX 4060 Ti 16GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p498 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p498, 'PC-CNTT-H-A-CREATOR-STUDIO-9-498', 30500000, NULL, 30, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p498, 'https://placehold.co/400x400?text=PC%20CNTT%20%C4%90%E1%BB%93%20h%E1%BB%8Da%20-%20Creator%20Studi', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p498, N'CPU', N'AMD Ryzen 7 7700X', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p498, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p498, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p498, N'Card đồ họa', N'RTX 4060 Ti 16GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-do-hoa-render-studio-10-499')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Đồ họa - Render Studio 10', 'pc-cntt-do-hoa-render-studio-10-499', N'Intel Core i7-13700F, 32GB RAM, 1TB SSD, RTX 4070 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p499 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p499, 'PC-CNTT-H-A-RENDER-STUDIO-10-499', 33900000, NULL, 14, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p499, 'https://placehold.co/400x400?text=PC%20CNTT%20%C4%90%E1%BB%93%20h%E1%BB%8Da%20-%20Render%20Studio', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p499, N'CPU', N'Intel Core i7-13700F', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p499, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p499, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p499, N'Card đồ họa', N'RTX 4070 12GB', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-workstation-pro-11-500')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Workstation Pro 11', 'pc-cntt-workstation-pro-11-500', N'AMD Ryzen 9 7900X, 64GB RAM, 2TB SSD, RTX 4070 Ti 12GB.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p500 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p500, 'PC-CNTT-WORKSTATION-PRO-11-500', 43500000, NULL, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p500, 'https://placehold.co/400x400?text=PC%20CNTT%20Workstation%20Pro%2011', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p500, N'CPU', N'AMD Ryzen 9 7900X', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p500, N'RAM', N'64GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p500, N'Ổ cứng', N'2TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p500, N'Card đồ họa', N'RTX 4070 Ti 12GB', 3);
END
GO
