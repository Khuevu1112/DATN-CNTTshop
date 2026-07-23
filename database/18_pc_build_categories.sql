-- ============================================================
-- 18_pc_build_categories.sql
-- Thêm danh mục linh kiện chi tiết (CPU/Mainboard/RAM/GPU/SSD/HDD/PSU/Case/Tản nhiệt)
-- để tính năng "Xây dựng cấu hình PC" có dữ liệu thật theo từng loại.
-- Phân loại lại các sản phẩm linh kiện hiện có + bổ sung vài sản phẩm còn thiếu loại.
-- ============================================================
USE ShopDB;
GO

-- ===== 1. Danh mục linh kiện chi tiết =====
INSERT INTO CATEGORY (name, slug, sort_order)
SELECT v.name, v.slug, v.sort_order
FROM (VALUES
    (N'CPU - Vi xử lý',      'cpu',           9),
    (N'Mainboard',           'mainboard',     10),
    (N'RAM',                 'ram',           11),
    (N'Card đồ họa (GPU)',   'gpu',           12),
    (N'Ổ cứng SSD',          'ssd',           13),
    (N'Ổ cứng HDD',          'hdd',           14),
    (N'Nguồn máy tính (PSU)', 'psu',          15),
    (N'Vỏ case',             'case-may-tinh', 16),
    (N'Tản nhiệt CPU',       'tan-nhiet-cpu', 17)
) AS v(name, slug, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM CATEGORY c WHERE c.slug = v.slug);
GO

-- ===== 2. Phân loại lại sản phẩm linh kiện hiện có (khớp theo tên, không phụ thuộc slug) =====
UPDATE PRODUCT SET category_id = (SELECT id FROM CATEGORY WHERE slug = 'cpu')
WHERE name LIKE N'CPU %';

UPDATE PRODUCT SET category_id = (SELECT id FROM CATEGORY WHERE slug = 'gpu')
WHERE name LIKE N'Card màn hình %' OR name LIKE N'VGA %';

UPDATE PRODUCT SET category_id = (SELECT id FROM CATEGORY WHERE slug = 'ram')
WHERE name LIKE N'RAM %';

UPDATE PRODUCT SET category_id = (SELECT id FROM CATEGORY WHERE slug = 'ssd')
WHERE name LIKE N'SSD %';
GO

-- ===== 3. Thương hiệu bổ sung (HDD / case / nguồn) =====
INSERT INTO BRAND (name)
SELECT v.name FROM (VALUES (N'Western Digital'), (N'Cooler Master')) AS v(name)
WHERE NOT EXISTS (SELECT 1 FROM BRAND b WHERE b.name = v.name);
GO

-- ===== 4. Bổ sung sản phẩm cho các loại linh kiện còn thiếu =====
IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-tuf-b760m')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Asus TUF Gaming B760M-PLUS', 'mainboard-asus-tuf-b760m',
            N'Bo mạch chủ chipset B760, socket LGA1700, hỗ trợ DDR5.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = 'ASUS'), 1, GETDATE());
    DECLARE @p1 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, stock, is_default)
    VALUES (@p1, 'MB-ASUS-B760M', 3290000, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1, 'https://placehold.co/400x400?text=Mainboard+ASUS', 1, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-msi-pro-b650m')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard MSI PRO B650M-A', 'mainboard-msi-pro-b650m',
            N'Bo mạch chủ chipset B650, socket AM5, hỗ trợ DDR5.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = 'MSI'), 1, GETDATE());
    DECLARE @p2 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, stock, is_default)
    VALUES (@p2, 'MB-MSI-B650M', 3590000, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p2, 'https://placehold.co/400x400?text=Mainboard+MSI', 1, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'hdd-wd-blue-2tb')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD WD Blue 2TB', 'hdd-wd-blue-2tb',
            N'Ổ cứng HDD 3.5" 2TB, 7200rpm, lưu trữ dung lượng lớn.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = 'Western Digital'), 1, GETDATE());
    DECLARE @p3 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, stock, is_default)
    VALUES (@p3, 'HDD-WD-2TB', 1390000, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p3, 'https://placehold.co/400x400?text=HDD+WD', 1, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'psu-corsair-rm750')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Corsair RM750e 750W', 'psu-corsair-rm750',
            N'Nguồn máy tính 750W, chuẩn 80 Plus Gold, full modular.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = 'Corsair'), 1, GETDATE());
    DECLARE @p4 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, stock, is_default)
    VALUES (@p4, 'PSU-CORSAIR-750', 2190000, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p4, 'https://placehold.co/400x400?text=PSU+Corsair', 1, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'case-corsair-4000d')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Corsair 4000D Airflow', 'case-corsair-4000d',
            N'Case mid-tower, tối ưu luồng khí, hỗ trợ nhiều kích thước mainboard.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = 'Corsair'), 1, GETDATE());
    DECLARE @p5 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, stock, is_default)
    VALUES (@p5, 'CASE-CORSAIR-4000D', 2090000, 14, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p5, 'https://placehold.co/400x400?text=Case+Corsair', 1, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-coolermaster-212')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt khí Cooler Master Hyper 212', 'tan-nhiet-coolermaster-212',
            N'Tản nhiệt khí phổ thông, tương thích đa nền tảng Intel/AMD.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = 'Cooler Master'), 1, GETDATE());
    DECLARE @p6 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, stock, is_default)
    VALUES (@p6, 'COOLER-CM212', 690000, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p6, 'https://placehold.co/400x400?text=Cooler+CM212', 1, 0);
END
GO
