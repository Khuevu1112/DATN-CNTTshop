-- ============================================================
-- 22_bulk_products.sql
-- Bo sung ~100 san pham moi trai deu cac danh muc hien co.
-- File duoc sinh tu dong boi script (xem scratchpad/gen_products.js).
-- ============================================================
USE ShopDB;
GO

-- ===== Thuong hieu bo sung =====
INSERT INTO BRAND (name)
SELECT v.name FROM (VALUES
    (N'Kingston'),
    (N'Crucial'),
    (N'Razer'),
    (N'SteelSeries'),
    (N'HyperX'),
    (N'ViewSonic'),
    (N'AOC'),
    (N'Seagate'),
    (N'NZXT'),
    (N'Lian Li'),
    (N'DeepCool'),
    (N'Anker'),
    (N'TP-Link'),
    (N'BenQ')
) AS v(name)
WHERE NOT EXISTS (SELECT 1 FROM BRAND b WHERE b.name = v.name);
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-acer-nitro-v15-gaming-100')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ACER Nitro V15 Gaming', 'laptop-acer-nitro-v15-gaming-100', N'Laptop gaming ACER Nitro V15, Intel Core i5-13420H, 16GB RAM, 1TB SSD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ACER'), 1, GETDATE());
    DECLARE @p1 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p1, 'LAPTOP-ACER-NITRO-V15-GAMING-100', 53000000, 55000000, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p1, 'https://placehold.co/400x400?text=ACER%20Nitro%20V15', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1, N'CPU', N'Intel Core i5-13420H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p1, N'Card đồ họa', N'Intel Iris Xe', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-acer-aspire-5-van-phong-101')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ACER Aspire 5 Văn phòng', 'laptop-acer-aspire-5-van-phong-101', N'Laptop văn phòng ACER Aspire 5, Intel Core i7-13700H, 32GB RAM, 256GB SSD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ACER'), 1, GETDATE());
    DECLARE @p2 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p2, 'LAPTOP-ACER-ASPIRE-5-VAN-PHONG-101', 54000000, NULL, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p2, 'https://placehold.co/400x400?text=ACER%20Aspire%205', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p2, N'CPU', N'Intel Core i7-13700H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p2, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p2, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p2, N'Card đồ họa', N'NVIDIA RTX 3050', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-dell-inspiron-15-van-phong-102')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Dell Inspiron 15 Văn phòng', 'laptop-dell-inspiron-15-van-phong-102', N'Laptop văn phòng Dell Inspiron 15, AMD Ryzen 5 7535HS, 8GB RAM, 512GB SSD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Dell'), 1, GETDATE());
    DECLARE @p3 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p3, 'LAPTOP-DELL-INSPIRON-15-VAN-PHONG-102', 15000000, NULL, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p3, 'https://placehold.co/400x400?text=Dell%20Inspiron%2015', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p3, N'CPU', N'AMD Ryzen 5 7535HS', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p3, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p3, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p3, N'Card đồ họa', N'NVIDIA RTX 4060', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-dell-xps-13-mong-nhe-103')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Dell XPS 13 Mỏng nhẹ', 'laptop-dell-xps-13-mong-nhe-103', N'Laptop mỏng nhẹ Dell XPS 13, AMD Ryzen 7 7735HS, 16GB RAM, 1TB SSD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Dell'), 1, GETDATE());
    DECLARE @p4 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p4, 'LAPTOP-DELL-XPS-13-MONG-NHE-103', 41000000, 43000000, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p4, 'https://placehold.co/400x400?text=Dell%20XPS%2013', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p4, N'CPU', N'AMD Ryzen 7 7735HS', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p4, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p4, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p4, N'Card đồ họa', N'AMD Radeon 660M', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-hp-pavilion-15-van-phong-104')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop HP Pavilion 15 Văn phòng', 'laptop-hp-pavilion-15-van-phong-104', N'Laptop văn phòng HP Pavilion 15, Apple M2, 32GB RAM, 256GB SSD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'HP'), 1, GETDATE());
    DECLARE @p5 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p5, 'LAPTOP-HP-PAVILION-15-VAN-PHONG-104', 35000000, NULL, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p5, 'https://placehold.co/400x400?text=HP%20Pavilion%2015', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p5, N'CPU', N'Apple M2', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p5, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p5, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p5, N'Card đồ họa', N'Apple GPU 10 nhân', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-hp-omen-16-gaming-105')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop HP Omen 16 Gaming', 'laptop-hp-omen-16-gaming-105', N'Laptop gaming HP Omen 16, Intel Core i5-13420H, 8GB RAM, 512GB SSD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'HP'), 1, GETDATE());
    DECLARE @p6 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p6, 'LAPTOP-HP-OMEN-16-GAMING-105', 46000000, NULL, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p6, 'https://placehold.co/400x400?text=HP%20Omen%2016', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p6, N'CPU', N'Intel Core i5-13420H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p6, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p6, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p6, N'Card đồ họa', N'Intel Iris Xe', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-lenovo-ideapad-slim-5-mong-nhe-106')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Lenovo IdeaPad Slim 5 Mỏng nhẹ', 'laptop-lenovo-ideapad-slim-5-mong-nhe-106', N'Laptop mỏng nhẹ Lenovo IdeaPad Slim 5, Intel Core i7-13700H, 16GB RAM, 1TB SSD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Lenovo'), 1, GETDATE());
    DECLARE @p7 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p7, 'LAPTOP-LENOVO-IDEAPAD-SLIM-5-MONG-NHE-10', 48000000, 50000000, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p7, 'https://placehold.co/400x400?text=Lenovo%20IdeaPad%20Slim%205', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p7, N'CPU', N'Intel Core i7-13700H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p7, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p7, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p7, N'Card đồ họa', N'NVIDIA RTX 3050', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-lenovo-loq-15-gaming-107')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Lenovo LOQ 15 Gaming', 'laptop-lenovo-loq-15-gaming-107', N'Laptop gaming Lenovo LOQ 15, AMD Ryzen 5 7535HS, 32GB RAM, 256GB SSD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Lenovo'), 1, GETDATE());
    DECLARE @p8 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p8, 'LAPTOP-LENOVO-LOQ-15-GAMING-107', 24000000, NULL, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p8, 'https://placehold.co/400x400?text=Lenovo%20LOQ%2015', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p8, N'CPU', N'AMD Ryzen 5 7535HS', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p8, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p8, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p8, N'Card đồ họa', N'NVIDIA RTX 4060', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-vivobook-15-van-phong-108')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS Vivobook 15 Văn phòng', 'laptop-asus-vivobook-15-van-phong-108', N'Laptop văn phòng ASUS Vivobook 15, AMD Ryzen 7 7735HS, 8GB RAM, 512GB SSD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p9 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p9, 'LAPTOP-ASUS-VIVOBOOK-15-VAN-PHONG-108', 39000000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p9, 'https://placehold.co/400x400?text=ASUS%20Vivobook%2015', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p9, N'CPU', N'AMD Ryzen 7 7735HS', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p9, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p9, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p9, N'Card đồ họa', N'AMD Radeon 660M', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-asus-tuf-gaming-a15-gaming-109')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop ASUS TUF Gaming A15 Gaming', 'laptop-asus-tuf-gaming-a15-gaming-109', N'Laptop gaming ASUS TUF Gaming A15, Apple M2, 16GB RAM, 1TB SSD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p10 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p10, 'LAPTOP-ASUS-TUF-GAMING-A15-GAMING-109', 34000000, 36000000, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p10, 'https://placehold.co/400x400?text=ASUS%20TUF%20Gaming%20A15', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p10, N'CPU', N'Apple M2', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p10, N'RAM', N'16GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p10, N'Ổ cứng', N'1TB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p10, N'Card đồ họa', N'Apple GPU 10 nhân', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-msi-modern-14-mong-nhe-110')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop MSI Modern 14 Mỏng nhẹ', 'laptop-msi-modern-14-mong-nhe-110', N'Laptop mỏng nhẹ MSI Modern 14, Intel Core i5-13420H, 32GB RAM, 256GB SSD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p11 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p11, 'LAPTOP-MSI-MODERN-14-MONG-NHE-110', 46000000, NULL, 30, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p11, 'https://placehold.co/400x400?text=MSI%20Modern%2014', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p11, N'CPU', N'Intel Core i5-13420H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p11, N'RAM', N'32GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p11, N'Ổ cứng', N'256GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p11, N'Card đồ họa', N'Intel Iris Xe', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'laptop-apple-macbook-air-m2-mong-nhe-111')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Laptop Apple MacBook Air M2 Mỏng nhẹ', 'laptop-apple-macbook-air-m2-mong-nhe-111', N'Laptop mỏng nhẹ Apple MacBook Air M2, Intel Core i7-13700H, 8GB RAM, 512GB SSD.',
            (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
            (SELECT id FROM BRAND WHERE name = N'Apple'), 1, GETDATE());
    DECLARE @p12 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p12, 'LAPTOP-APPLE-MACBOOK-AIR-M2-MONG-NHE-111', 47000000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p12, 'https://placehold.co/400x400?text=Apple%20MacBook%20Air%20M2', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p12, N'CPU', N'Intel Core i7-13700H', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p12, N'RAM', N'8GB', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p12, N'Ổ cứng', N'512GB SSD', 2);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p12, N'Card đồ họa', N'NVIDIA RTX 3050', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-gaming-1-200')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Gaming 1', 'pc-cntt-gaming-1-200', N'PC dựng sẵn gaming, Intel Core i5-13400F, NVIDIA RTX 4060, 16GB RAM.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p13 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p13, 'PC-CNTT-GAMING-1-200', 45000000, 46500000, 8, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p13, 'https://placehold.co/400x400?text=PC%2BGaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p13, N'CPU', N'Intel Core i5-13400F', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p13, N'Card đồ họa', N'NVIDIA RTX 4060', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p13, N'RAM', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-van-phong-2-201')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Văn phòng 2', 'pc-cntt-van-phong-2-201', N'PC dựng sẵn văn phòng, Intel Core i7-13700F, NVIDIA RTX 4070, 32GB RAM.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p14 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p14, 'PC-CNTT-VAN-PHONG-2-201', 33000000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p14, 'https://placehold.co/400x400?text=PC%2BV%C4%83n%20ph%C3%B2ng', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p14, N'CPU', N'Intel Core i7-13700F', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p14, N'Card đồ họa', N'NVIDIA RTX 4070', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p14, N'RAM', N'32GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-do-hoa-studio-3-202')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Đồ họa - Studio 3', 'pc-cntt-do-hoa-studio-3-202', N'PC dựng sẵn đồ họa - studio, AMD Ryzen 5 7600, AMD Radeon RX 7600, 16GB RAM.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p15 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p15, 'PC-CNTT-DO-HOA-STUDIO-3-202', 26000000, NULL, 4, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p15, 'https://placehold.co/400x400?text=PC%2B%C4%90%E1%BB%93%20h%E1%BB%8Da%20-%20Studio', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p15, N'CPU', N'AMD Ryzen 5 7600', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p15, N'Card đồ họa', N'AMD Radeon RX 7600', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p15, N'RAM', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-workstation-4-203')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Workstation 4', 'pc-cntt-workstation-4-203', N'PC dựng sẵn workstation, AMD Ryzen 7 7700X, Intel UHD Graphics 730, 32GB RAM.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p16 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p16, 'PC-CNTT-WORKSTATION-4-203', 45000000, NULL, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p16, 'https://placehold.co/400x400?text=PC%2BWorkstation', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p16, N'CPU', N'AMD Ryzen 7 7700X', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p16, N'Card đồ họa', N'Intel UHD Graphics 730', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p16, N'RAM', N'32GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-gaming-5-204')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Gaming 5', 'pc-cntt-gaming-5-204', N'PC dựng sẵn gaming, Intel Core i5-13400F, NVIDIA RTX 4060, 16GB RAM.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p17 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p17, 'PC-CNTT-GAMING-5-204', 10000000, 11500000, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p17, 'https://placehold.co/400x400?text=PC%2BGaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p17, N'CPU', N'Intel Core i5-13400F', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p17, N'Card đồ họa', N'NVIDIA RTX 4060', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p17, N'RAM', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-van-phong-6-205')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Văn phòng 6', 'pc-cntt-van-phong-6-205', N'PC dựng sẵn văn phòng, Intel Core i7-13700F, NVIDIA RTX 4070, 32GB RAM.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p18 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p18, 'PC-CNTT-VAN-PHONG-6-205', 11000000, NULL, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p18, 'https://placehold.co/400x400?text=PC%2BV%C4%83n%20ph%C3%B2ng', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p18, N'CPU', N'Intel Core i7-13700F', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p18, N'Card đồ họa', N'NVIDIA RTX 4070', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p18, N'RAM', N'32GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-do-hoa-studio-7-206')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Đồ họa - Studio 7', 'pc-cntt-do-hoa-studio-7-206', N'PC dựng sẵn đồ họa - studio, AMD Ryzen 5 7600, AMD Radeon RX 7600, 16GB RAM.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p19 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p19, 'PC-CNTT-DO-HOA-STUDIO-7-206', 43000000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p19, 'https://placehold.co/400x400?text=PC%2B%C4%90%E1%BB%93%20h%E1%BB%8Da%20-%20Studio', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p19, N'CPU', N'AMD Ryzen 5 7600', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p19, N'Card đồ họa', N'AMD Radeon RX 7600', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p19, N'RAM', N'16GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'pc-cntt-workstation-8-207')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'PC CNTT Workstation 8', 'pc-cntt-workstation-8-207', N'PC dựng sẵn workstation, AMD Ryzen 7 7700X, Intel UHD Graphics 730, 32GB RAM.',
            (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p20 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p20, 'PC-CNTT-WORKSTATION-8-207', 15000000, NULL, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p20, 'https://placehold.co/400x400?text=PC%2BWorkstation', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p20, N'CPU', N'AMD Ryzen 7 7700X', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p20, N'Card đồ họa', N'Intel UHD Graphics 730', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p20, N'RAM', N'32GB', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-lg-24-inch-75hz-300')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình LG 24 inch 75Hz', 'man-hinh-lg-24-inch-75hz-300', N'Màn hình 24 inch, tấm nền IPS, tần số quét 75Hz.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'LG'), 1, GETDATE());
    DECLARE @p21 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p21, 'MAN-HINH-LG-24-INCH-75HZ-300', 11300000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p21, 'https://placehold.co/400x400?text=LG%2BMonitor', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p21, N'Kích thước', N'24 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p21, N'Tấm nền', N'IPS', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p21, N'Tần số quét', N'75Hz', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-samsung-27-inch-144hz-301')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình Samsung 27 inch 144Hz', 'man-hinh-samsung-27-inch-144hz-301', N'Màn hình 27 inch, tấm nền VA, tần số quét 144Hz.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p22 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p22, 'MAN-HINH-SAMSUNG-27-INCH-144HZ-301', 4500000, NULL, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p22, 'https://placehold.co/400x400?text=Samsung%2BMonitor', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p22, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p22, N'Tấm nền', N'VA', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p22, N'Tần số quét', N'144Hz', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-asus-32-inch-165hz-302')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình ASUS 32 inch 165Hz', 'man-hinh-asus-32-inch-165hz-302', N'Màn hình 32 inch, tấm nền OLED, tần số quét 165Hz.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p23 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p23, 'MAN-HINH-ASUS-32-INCH-165HZ-302', 13400000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p23, 'https://placehold.co/400x400?text=ASUS%2BMonitor', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p23, N'Kích thước', N'32 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p23, N'Tấm nền', N'OLED', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p23, N'Tần số quét', N'165Hz', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-dell-34-inch-ultrawide-240hz-303')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình Dell 34 inch Ultrawide 240Hz', 'man-hinh-dell-34-inch-ultrawide-240hz-303', N'Màn hình 34 inch Ultrawide, tấm nền IPS, tần số quét 240Hz.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'Dell'), 1, GETDATE());
    DECLARE @p24 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p24, 'MAN-HINH-DELL-34-INCH-ULTRAWIDE-240HZ-30', 2700000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p24, 'https://placehold.co/400x400?text=Dell%2BMonitor', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p24, N'Kích thước', N'34 inch Ultrawide', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p24, N'Tấm nền', N'IPS', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p24, N'Tần số quét', N'240Hz', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-viewsonic-24-inch-75hz-304')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình ViewSonic 24 inch 75Hz', 'man-hinh-viewsonic-24-inch-75hz-304', N'Màn hình 24 inch, tấm nền VA, tần số quét 75Hz.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'ViewSonic'), 1, GETDATE());
    DECLARE @p25 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p25, 'MAN-HINH-VIEWSONIC-24-INCH-75HZ-304', 11100000, NULL, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p25, 'https://placehold.co/400x400?text=ViewSonic%2BMonitor', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p25, N'Kích thước', N'24 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p25, N'Tấm nền', N'VA', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p25, N'Tần số quét', N'75Hz', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-aoc-27-inch-144hz-305')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình AOC 27 inch 144Hz', 'man-hinh-aoc-27-inch-144hz-305', N'Màn hình 27 inch, tấm nền OLED, tần số quét 144Hz.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'AOC'), 1, GETDATE());
    DECLARE @p26 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p26, 'MAN-HINH-AOC-27-INCH-144HZ-305', 12100000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p26, 'https://placehold.co/400x400?text=AOC%2BMonitor', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p26, N'Kích thước', N'27 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p26, N'Tấm nền', N'OLED', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p26, N'Tần số quét', N'144Hz', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-lg-32-inch-165hz-306')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình LG 32 inch 165Hz', 'man-hinh-lg-32-inch-165hz-306', N'Màn hình 32 inch, tấm nền IPS, tần số quét 165Hz.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'LG'), 1, GETDATE());
    DECLARE @p27 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p27, 'MAN-HINH-LG-32-INCH-165HZ-306', 9400000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p27, 'https://placehold.co/400x400?text=LG%2BMonitor', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p27, N'Kích thước', N'32 inch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p27, N'Tấm nền', N'IPS', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p27, N'Tần số quét', N'165Hz', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'man-hinh-samsung-34-inch-ultrawide-240hz-307')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Màn hình Samsung 34 inch Ultrawide 240Hz', 'man-hinh-samsung-34-inch-ultrawide-240hz-307', N'Màn hình 34 inch Ultrawide, tấm nền VA, tần số quét 240Hz.',
            (SELECT id FROM CATEGORY WHERE slug = 'man-hinh'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p28 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p28, 'MAN-HINH-SAMSUNG-34-INCH-ULTRAWIDE-240HZ', 6600000, NULL, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p28, 'https://placehold.co/400x400?text=Samsung%2BMonitor', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p28, N'Kích thước', N'34 inch Ultrawide', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p28, N'Tấm nền', N'VA', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p28, N'Tần số quét', N'240Hz', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-gaming-logitech-series-1-400')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột gaming Logitech Series 1', 'chuot-gaming-logitech-series-1-400', N'Chuột gaming thương hiệu Logitech, 25.600, Có dây.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p29 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p29, 'CHUOT-GAMING-LOGITECH-SERIES-1-400', 1600000, NULL, 38, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p29, 'https://placehold.co/400x400?text=Logitech%2BChu%E1%BB%99t', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p29, N'DPI', N'25.600', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p29, N'Kết nối', N'Có dây', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-khong-day-logitech-series-2-401')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột không dây Logitech Series 2', 'chuot-khong-day-logitech-series-2-401', N'Chuột không dây thương hiệu Logitech, 4.000, Bluetooth/2.4GHz.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p30 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p30, 'CHUOT-KHONG-DAY-LOGITECH-SERIES-2-401', 2900000, 3000000, 43, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p30, 'https://placehold.co/400x400?text=Logitech%2BChu%E1%BB%99t', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p30, N'DPI', N'4.000', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p30, N'Kết nối', N'Bluetooth/2.4GHz', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'chuot-gaming-razer-series-3-402')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Chuột gaming Razer Series 3', 'chuot-gaming-razer-series-3-402', N'Chuột gaming thương hiệu Razer, 30.000, Có dây.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Razer'), 1, GETDATE());
    DECLARE @p31 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p31, 'CHUOT-GAMING-RAZER-SERIES-3-402', 1200000, NULL, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p31, 'https://placehold.co/400x400?text=Razer%2BChu%E1%BB%99t', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p31, N'DPI', N'30.000', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p31, N'Kết nối', N'Có dây', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-keychron-series-4-403')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ Keychron Series 4', 'ban-phim-co-keychron-series-4-403', N'Bàn phím cơ thương hiệu Keychron, Blue switch, Bluetooth/USB-C.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Keychron'), 1, GETDATE());
    DECLARE @p32 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p32, 'BAN-PHIM-CO-KEYCHRON-SERIES-4-403', 1000000, NULL, 44, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p32, 'https://placehold.co/400x400?text=Keychron%2BB%C3%A0n', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p32, N'Switch', N'Blue switch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p32, N'Kết nối', N'Bluetooth/USB-C', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-gaming-razer-series-5-404')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ gaming Razer Series 5', 'ban-phim-co-gaming-razer-series-5-404', N'Bàn phím cơ gaming thương hiệu Razer, Green switch, Có dây.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Razer'), 1, GETDATE());
    DECLARE @p33 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p33, 'BAN-PHIM-CO-GAMING-RAZER-SERIES-5-404', 2900000, 3000000, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p33, 'https://placehold.co/400x400?text=Razer%2BB%C3%A0n', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p33, N'Switch', N'Green switch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p33, N'Kết nối', N'Có dây', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ban-phim-co-steelseries-series-6-405')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bàn phím cơ SteelSeries Series 6', 'ban-phim-co-steelseries-series-6-405', N'Bàn phím cơ thương hiệu SteelSeries, Red switch, Có dây.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'SteelSeries'), 1, GETDATE());
    DECLARE @p34 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p34, 'BAN-PHIM-CO-STEELSERIES-SERIES-6-405', 800000, NULL, 37, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p34, 'https://placehold.co/400x400?text=SteelSeries%2BB%C3%A0n', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p34, N'Switch', N'Red switch', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p34, N'Kết nối', N'Có dây', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tai-nghe-gaming-hyperx-series-7-406')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tai nghe gaming HyperX Series 7', 'tai-nghe-gaming-hyperx-series-7-406', N'Tai nghe gaming thương hiệu HyperX, 50mm, Có dây 3.5mm.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'HyperX'), 1, GETDATE());
    DECLARE @p35 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p35, 'TAI-NGHE-GAMING-HYPERX-SERIES-7-406', 2000000, NULL, 47, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p35, 'https://placehold.co/400x400?text=HyperX%2BTai', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p35, N'Driver', N'50mm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p35, N'Kết nối', N'Có dây 3.5mm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tai-nghe-chong-on-logitech-series-8-407')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tai nghe chống ồn Logitech Series 8', 'tai-nghe-chong-on-logitech-series-8-407', N'Tai nghe chống ồn thương hiệu Logitech, 40mm, Bluetooth.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p36 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p36, 'TAI-NGHE-CHONG-ON-LOGITECH-SERIES-8-407', 1200000, 1300000, 42, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p36, 'https://placehold.co/400x400?text=Logitech%2BTai', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p36, N'Driver', N'40mm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p36, N'Kết nối', N'Bluetooth', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'webcam-logitech-series-9-408')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Webcam Logitech Series 9', 'webcam-logitech-series-9-408', N'Webcam thương hiệu Logitech, 1080p, 30fps.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p37 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p37, 'WEBCAM-LOGITECH-SERIES-9-408', 700000, NULL, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p37, 'https://placehold.co/400x400?text=Logitech%2BWebcam', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p37, N'Độ phân giải', N'1080p', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p37, N'FPS', N'30fps', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'loa-vi-tinh-logitech-series-10-409')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Loa vi tính Logitech Series 10', 'loa-vi-tinh-logitech-series-10-409', N'Loa vi tính thương hiệu Logitech, 2.1 kênh, USB/3.5mm.',
            (SELECT id FROM CATEGORY WHERE slug = 'ngoai-vi'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p38 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p38, 'LOA-VI-TINH-LOGITECH-SERIES-10-409', 1900000, NULL, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p38, 'https://placehold.co/400x400?text=Logitech%2BLoa', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p38, N'Công suất', N'2.1 kênh', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p38, N'Kết nối', N'USB/3.5mm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'balo-laptop-chong-soc-15-6-500')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Balo laptop chống sốc 15.6"', 'balo-laptop-chong-soc-15-6-500', N'Balo laptop chống sốc 15.6" chính hãng Anker.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p39 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p39, 'BALO-LAPTOP-CHONG-SOC-15-6-500', 1300000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p39, 'https://placehold.co/400x400?text=Anker%2BAccessory', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p39, N'Chất liệu', N'Vải chống nước', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p39, N'Trọng lượng', N'0.8kg', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tui-chong-soc-laptop-14-501')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Túi chống sốc laptop 14"', 'tui-chong-soc-laptop-14-501', N'Túi chống sốc laptop 14" chính hãng Logitech.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Logitech'), 1, GETDATE());
    DECLARE @p40 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p40, 'TUI-CHONG-SOC-LAPTOP-14-501', 900000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p40, 'https://placehold.co/400x400?text=Logitech%2BAccessory', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p40, N'Chất liệu', N'Da PU', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p40, N'Trọng lượng', N'0.4kg', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'hub-usb-c-7-cong-502')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Hub USB-C 7 cổng', 'hub-usb-c-7-cong-502', N'Hub USB-C 7 cổng chính hãng Anker.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p41 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p41, 'HUB-USB-C-7-CONG-502', 1100000, NULL, 54, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p41, 'https://placehold.co/400x400?text=Anker%2BAccessory', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p41, N'Cổng kết nối', N'USB-A/HDMI/SD', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p41, N'Chuẩn', N'USB 3.0', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cap-sac-usb-c-to-usb-c-100w-503')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Cáp sạc USB-C to USB-C 100W', 'cap-sac-usb-c-to-usb-c-100w-503', N'Cáp sạc USB-C to USB-C 100W chính hãng Anker.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p42 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p42, 'CAP-SAC-USB-C-TO-USB-C-100W-503', 300000, NULL, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p42, 'https://placehold.co/400x400?text=Anker%2BAccessory', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p42, N'Công suất', N'100W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p42, N'Chiều dài', N'1.5m', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'gia-do-laptop-tan-nhiet-504')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Giá đỡ laptop tản nhiệt', 'gia-do-laptop-tan-nhiet-504', N'Giá đỡ laptop tản nhiệt chính hãng Cooler Master.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Cooler Master'), 1, GETDATE());
    DECLARE @p43 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p43, 'GIA-DO-LAPTOP-TAN-NHIET-504', 1500000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p43, 'https://placehold.co/400x400?text=Cooler%20Master%2BAccessory', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p43, N'Chất liệu', N'Hợp kim nhôm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p43, N'Tải trọng', N'5kg', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'bo-phat-wifi-usb-505')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Bộ phát WiFi USB', 'bo-phat-wifi-usb-505', N'Bộ phát WiFi USB chính hãng TP-Link.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'TP-Link'), 1, GETDATE());
    DECLARE @p44 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p44, 'BO-PHAT-WIFI-USB-505', 400000, NULL, 40, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p44, 'https://placehold.co/400x400?text=TP-Link%2BAccessory', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p44, N'Chuẩn', N'WiFi 6', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p44, N'Tốc độ', N'1300Mbps', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mieng-lot-chuot-gaming-xl-506')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Miếng lót chuột Gaming XL', 'mieng-lot-chuot-gaming-xl-506', N'Miếng lót chuột Gaming XL chính hãng SteelSeries.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'SteelSeries'), 1, GETDATE());
    DECLARE @p45 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p45, 'MIENG-LOT-CHUOT-GAMING-XL-506', 1500000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p45, 'https://placehold.co/400x400?text=SteelSeries%2BAccessory', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p45, N'Kích thước', N'900x400mm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p45, N'Chất liệu', N'Vải dệt', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'sac-du-phong-20000mah-507')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Sạc dự phòng 20000mAh', 'sac-du-phong-20000mah-507', N'Sạc dự phòng 20000mAh chính hãng Anker.',
            (SELECT id FROM CATEGORY WHERE slug = 'phu-kien'),
            (SELECT id FROM BRAND WHERE name = N'Anker'), 1, GETDATE());
    DECLARE @p46 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p46, 'SAC-DU-PHONG-20000MAH-507', 1000000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p46, 'https://placehold.co/400x400?text=Anker%2BAccessory', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p46, N'Dung lượng', N'20.000mAh', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p46, N'Công suất', N'65W', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i3-13100f-600')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i3-13100F', 'cpu-intel-core-i3-13100f-600', N'Vi xử lý Intel Core i3-13100F, 4 nhân 8 luồng, xung nhịp cơ bản 3.4GHz.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p47 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p47, 'CPU-INTEL-CORE-I3-13100F-600', 11600000, 11900000, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p47, 'https://placehold.co/400x400?text=Intel%2BCore%2Bi3-13100F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p47, N'Số nhân/luồng', N'4 nhân 8 luồng', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p47, N'Xung nhịp', N'3.4GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p47, N'Socket', N'LGA1700', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i5-14400f-601')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i5-14400F', 'cpu-intel-core-i5-14400f-601', N'Vi xử lý Intel Core i5-14400F, 10 nhân 16 luồng, xung nhịp cơ bản 2.5GHz.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p48 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p48, 'CPU-INTEL-CORE-I5-14400F-601', 9500000, NULL, 7, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p48, 'https://placehold.co/400x400?text=Intel%2BCore%2Bi5-14400F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p48, N'Số nhân/luồng', N'10 nhân 16 luồng', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p48, N'Xung nhịp', N'2.5GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p48, N'Socket', N'LGA1700', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i7-14700f-602')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i7-14700F', 'cpu-intel-core-i7-14700f-602', N'Vi xử lý Intel Core i7-14700F, 20 nhân 28 luồng, xung nhịp cơ bản 2.1GHz.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p49 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p49, 'CPU-INTEL-CORE-I7-14700F-602', 11000000, NULL, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p49, 'https://placehold.co/400x400?text=Intel%2BCore%2Bi7-14700F', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p49, N'Số nhân/luồng', N'20 nhân 28 luồng', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p49, N'Xung nhịp', N'2.1GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p49, N'Socket', N'LGA1700', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-intel-core-i9-14900k-603')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU Intel Core i9-14900K', 'cpu-intel-core-i9-14900k-603', N'Vi xử lý Intel Core i9-14900K, 24 nhân 32 luồng, xung nhịp cơ bản 3.2GHz.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'Intel'), 1, GETDATE());
    DECLARE @p50 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p50, 'CPU-INTEL-CORE-I9-14900K-603', 11900000, 12200000, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p50, 'https://placehold.co/400x400?text=Intel%2BCore%2Bi9-14900K', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p50, N'Số nhân/luồng', N'24 nhân 32 luồng', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p50, N'Xung nhịp', N'3.2GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p50, N'Socket', N'LGA1700', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-3-4100-604')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 3 4100', 'cpu-amd-ryzen-3-4100-604', N'Vi xử lý AMD Ryzen 3 4100, 4 nhân 8 luồng, xung nhịp cơ bản 3.8GHz.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p51 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p51, 'CPU-AMD-RYZEN-3-4100-604', 7500000, NULL, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p51, 'https://placehold.co/400x400?text=AMD%2BRyzen%2B3%2B4100', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p51, N'Số nhân/luồng', N'4 nhân 8 luồng', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p51, N'Xung nhịp', N'3.8GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p51, N'Socket', N'AM4', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-5-8500g-605')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 5 8500G', 'cpu-amd-ryzen-5-8500g-605', N'Vi xử lý AMD Ryzen 5 8500G, 6 nhân 12 luồng, xung nhịp cơ bản 3.5GHz.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p52 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p52, 'CPU-AMD-RYZEN-5-8500G-605', 10800000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p52, 'https://placehold.co/400x400?text=AMD%2BRyzen%2B5%2B8500G', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p52, N'Số nhân/luồng', N'6 nhân 12 luồng', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p52, N'Xung nhịp', N'3.5GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p52, N'Socket', N'AM5', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-7-8700g-606')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 7 8700G', 'cpu-amd-ryzen-7-8700g-606', N'Vi xử lý AMD Ryzen 7 8700G, 8 nhân 16 luồng, xung nhịp cơ bản 4.2GHz.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p53 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p53, 'CPU-AMD-RYZEN-7-8700G-606', 7100000, 7400000, 29, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p53, 'https://placehold.co/400x400?text=AMD%2BRyzen%2B7%2B8700G', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p53, N'Số nhân/luồng', N'8 nhân 16 luồng', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p53, N'Xung nhịp', N'4.2GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p53, N'Socket', N'AM5', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'cpu-amd-ryzen-9-7950x-607')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'CPU AMD Ryzen 9 7950X', 'cpu-amd-ryzen-9-7950x-607', N'Vi xử lý AMD Ryzen 9 7950X, 16 nhân 32 luồng, xung nhịp cơ bản 4.5GHz.',
            (SELECT id FROM CATEGORY WHERE slug = 'cpu'),
            (SELECT id FROM BRAND WHERE name = N'AMD'), 1, GETDATE());
    DECLARE @p54 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p54, 'CPU-AMD-RYZEN-9-7950X-607', 8800000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p54, 'https://placehold.co/400x400?text=AMD%2BRyzen%2B9%2B7950X', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p54, N'Số nhân/luồng', N'16 nhân 32 luồng', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p54, N'Xung nhịp', N'4.5GHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p54, N'Socket', N'AM5', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-prime-b760m-k-700')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASUS Prime B760M-K', 'mainboard-asus-prime-b760m-k-700', N'Bo mạch chủ chipset B760, socket LGA1700, hỗ trợ DDR5.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p55 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p55, 'MAINBOARD-ASUS-PRIME-B760M-K-700', 2800000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p55, 'https://placehold.co/400x400?text=ASUS%2BPrime%2BB760M-K', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p55, N'Chipset', N'B760', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p55, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p55, N'RAM hỗ trợ', N'DDR5', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-rog-strix-b650-a-701')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASUS ROG Strix B650-A', 'mainboard-asus-rog-strix-b650-a-701', N'Bo mạch chủ chipset B650, socket AM5, hỗ trợ DDR5.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p56 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p56, 'MAINBOARD-ASUS-ROG-STRIX-B650-A-701', 3900000, NULL, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p56, 'https://placehold.co/400x400?text=ASUS%2BROG%2BStrix%2BB650-A', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p56, N'Chipset', N'B650', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p56, N'Socket', N'AM5', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p56, N'RAM hỗ trợ', N'DDR5', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-msi-pro-b760m-p-702')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard MSI PRO B760M-P', 'mainboard-msi-pro-b760m-p-702', N'Bo mạch chủ chipset B760, socket LGA1700, hỗ trợ DDR5.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p57 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p57, 'MAINBOARD-MSI-PRO-B760M-P-702', 2000000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p57, 'https://placehold.co/400x400?text=MSI%2BPRO%2BB760M-P', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p57, N'Chipset', N'B760', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p57, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p57, N'RAM hỗ trợ', N'DDR5', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-msi-mag-b650-tomahawk-703')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard MSI MAG B650 Tomahawk', 'mainboard-msi-mag-b650-tomahawk-703', N'Bo mạch chủ chipset B650, socket AM5, hỗ trợ DDR5.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p58 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p58, 'MAINBOARD-MSI-MAG-B650-TOMAHAWK-703', 6700000, NULL, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p58, 'https://placehold.co/400x400?text=MSI%2BMAG%2BB650%2BTomahawk', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p58, N'Chipset', N'B650', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p58, N'Socket', N'AM5', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p58, N'RAM hỗ trợ', N'DDR5', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-gigabyte-b760m-ds3h-704')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Gigabyte B760M DS3H', 'mainboard-gigabyte-b760m-ds3h-704', N'Bo mạch chủ chipset B760, socket LGA1700, hỗ trợ DDR4.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p59 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p59, 'MAINBOARD-GIGABYTE-B760M-DS3H-704', 2900000, NULL, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p59, 'https://placehold.co/400x400?text=Gigabyte%2BB760M%2BDS3H', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p59, N'Chipset', N'B760', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p59, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p59, N'RAM hỗ trợ', N'DDR4', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-gigabyte-b650m-aorus-elite-705')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard Gigabyte B650M Aorus Elite', 'mainboard-gigabyte-b650m-aorus-elite-705', N'Bo mạch chủ chipset B650, socket AM5, hỗ trợ DDR5.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p60 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p60, 'MAINBOARD-GIGABYTE-B650M-AORUS-ELITE-705', 3200000, NULL, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p60, 'https://placehold.co/400x400?text=Gigabyte%2BB650M%2BAorus%2BElite', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p60, N'Chipset', N'B650', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p60, N'Socket', N'AM5', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p60, N'RAM hỗ trợ', N'DDR5', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-asus-tuf-gaming-z790-plus-706')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard ASUS TUF Gaming Z790-Plus', 'mainboard-asus-tuf-gaming-z790-plus-706', N'Bo mạch chủ chipset Z790, socket LGA1700, hỗ trợ DDR5.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p61 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p61, 'MAINBOARD-ASUS-TUF-GAMING-Z790-PLUS-706', 4200000, NULL, 9, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p61, 'https://placehold.co/400x400?text=ASUS%2BTUF%2BGaming%2BZ790-Plus', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p61, N'Chipset', N'Z790', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p61, N'Socket', N'LGA1700', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p61, N'RAM hỗ trợ', N'DDR5', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'mainboard-msi-mpg-x670e-carbon-707')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Mainboard MSI MPG X670E Carbon', 'mainboard-msi-mpg-x670e-carbon-707', N'Bo mạch chủ chipset X670E, socket AM5, hỗ trợ DDR5.',
            (SELECT id FROM CATEGORY WHERE slug = 'mainboard'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p62 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p62, 'MAINBOARD-MSI-MPG-X670E-CARBON-707', 3400000, NULL, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p62, 'https://placehold.co/400x400?text=MSI%2BMPG%2BX670E%2BCarbon', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p62, N'Chipset', N'X670E', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p62, N'Socket', N'AM5', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p62, N'RAM hỗ trợ', N'DDR5', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-corsair-vengeance-8gb-ddr4-800')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Corsair Vengeance 8GB DDR4', 'ram-corsair-vengeance-8gb-ddr4-800', N'RAM DDR4 8GB, bus 3200MHz, thương hiệu Corsair.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p63 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p63, 'RAM-CORSAIR-VENGEANCE-8GB-DDR4-800', 2700000, 2800000, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p63, 'https://placehold.co/400x400?text=Corsair%2BRAM', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p63, N'Dung lượng', N'8GB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p63, N'Bus', N'3200MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p63, N'Chuẩn', N'DDR4', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-corsair-vengeance-16gb-ddr4-801')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Corsair Vengeance 16GB DDR4', 'ram-corsair-vengeance-16gb-ddr4-801', N'RAM DDR4 16GB, bus 3600MHz, thương hiệu Corsair.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p64 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p64, 'RAM-CORSAIR-VENGEANCE-16GB-DDR4-801', 600000, NULL, 27, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p64, 'https://placehold.co/400x400?text=Corsair%2BRAM', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p64, N'Dung lượng', N'16GB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p64, N'Bus', N'3600MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p64, N'Chuẩn', N'DDR4', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-kingston-fury-beast-16gb-ddr5-802')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Kingston Fury Beast 16GB DDR5', 'ram-kingston-fury-beast-16gb-ddr5-802', N'RAM DDR5 16GB, bus 5200MHz, thương hiệu Kingston.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p65 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p65, 'RAM-KINGSTON-FURY-BEAST-16GB-DDR5-802', 2100000, 2200000, 24, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p65, 'https://placehold.co/400x400?text=Kingston%2BRAM', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p65, N'Dung lượng', N'16GB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p65, N'Bus', N'5200MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p65, N'Chuẩn', N'DDR5', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-kingston-fury-beast-32gb-ddr5-803')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Kingston Fury Beast 32GB DDR5', 'ram-kingston-fury-beast-32gb-ddr5-803', N'RAM DDR5 32GB, bus 6000MHz, thương hiệu Kingston.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p66 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p66, 'RAM-KINGSTON-FURY-BEAST-32GB-DDR5-803', 1200000, NULL, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p66, 'https://placehold.co/400x400?text=Kingston%2BRAM', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p66, N'Dung lượng', N'32GB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p66, N'Bus', N'6000MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p66, N'Chuẩn', N'DDR5', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-crucial-pro-16gb-ddr4-804')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Crucial Pro 16GB DDR4', 'ram-crucial-pro-16gb-ddr4-804', N'RAM DDR4 16GB, bus 3200MHz, thương hiệu Crucial.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Crucial'), 1, GETDATE());
    DECLARE @p67 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p67, 'RAM-CRUCIAL-PRO-16GB-DDR4-804', 600000, 700000, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p67, 'https://placehold.co/400x400?text=Crucial%2BRAM', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p67, N'Dung lượng', N'16GB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p67, N'Bus', N'3200MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p67, N'Chuẩn', N'DDR4', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-crucial-pro-32gb-ddr5-805')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Crucial Pro 32GB DDR5', 'ram-crucial-pro-32gb-ddr5-805', N'RAM DDR5 32GB, bus 5600MHz, thương hiệu Crucial.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Crucial'), 1, GETDATE());
    DECLARE @p68 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p68, 'RAM-CRUCIAL-PRO-32GB-DDR5-805', 900000, NULL, 34, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p68, 'https://placehold.co/400x400?text=Crucial%2BRAM', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p68, N'Dung lượng', N'32GB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p68, N'Bus', N'5600MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p68, N'Chuẩn', N'DDR5', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-samsung-standard-8gb-ddr4-806')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Samsung Standard 8GB DDR4', 'ram-samsung-standard-8gb-ddr4-806', N'RAM DDR4 8GB, bus 2666MHz, thương hiệu Samsung.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p69 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p69, 'RAM-SAMSUNG-STANDARD-8GB-DDR4-806', 2900000, 3000000, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p69, 'https://placehold.co/400x400?text=Samsung%2BRAM', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p69, N'Dung lượng', N'8GB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p69, N'Bus', N'2666MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p69, N'Chuẩn', N'DDR4', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ram-corsair-dominator-platinum-64gb-2x32gb-ddr5-807')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'RAM Corsair Dominator Platinum 64GB (2x32GB) DDR5', 'ram-corsair-dominator-platinum-64gb-2x32gb-ddr5-807', N'RAM DDR5 64GB (2x32GB), bus 6200MHz, thương hiệu Corsair.',
            (SELECT id FROM CATEGORY WHERE slug = 'ram'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p70 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p70, 'RAM-CORSAIR-DOMINATOR-PLATINUM-64GB-2X32', 4300000, NULL, 31, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p70, 'https://placehold.co/400x400?text=Corsair%2BRAM', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p70, N'Dung lượng', N'64GB (2x32GB)', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p70, N'Bus', N'6200MHz', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p70, N'Chuẩn', N'DDR5', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-asus-dual-rtx-4060-900')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa ASUS Dual RTX 4060', 'card-do-hoa-asus-dual-rtx-4060-900', N'Card đồ họa NVIDIA RTX 4060, VRAM 8GB GDDR6, giao tiếp PCIe 4.0.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p71 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p71, 'CARD-DO-HOA-ASUS-DUAL-RTX-4060-900', 32500000, NULL, 15, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p71, 'https://placehold.co/400x400?text=ASUS%2BDual', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p71, N'VRAM', N'8GB GDDR6', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p71, N'Chip đồ họa', N'NVIDIA RTX 4060', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p71, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-msi-gaming-x-rtx-4070-901')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa MSI Gaming X RTX 4070', 'card-do-hoa-msi-gaming-x-rtx-4070-901', N'Card đồ họa NVIDIA RTX 4070, VRAM 12GB GDDR6X, giao tiếp PCIe 4.0.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p72 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p72, 'CARD-DO-HOA-MSI-GAMING-X-RTX-4070-901', 11800000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p72, 'https://placehold.co/400x400?text=MSI%2BGaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p72, N'VRAM', N'12GB GDDR6X', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p72, N'Chip đồ họa', N'NVIDIA RTX 4070', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p72, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-gigabyte-eagle-rtx-4070-ti-902')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Gigabyte Eagle RTX 4070 Ti', 'card-do-hoa-gigabyte-eagle-rtx-4070-ti-902', N'Card đồ họa NVIDIA RTX 4070 Ti, VRAM 12GB GDDR6X, giao tiếp PCIe 4.0.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p73 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p73, 'CARD-DO-HOA-GIGABYTE-EAGLE-RTX-4070-TI-9', 17400000, NULL, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p73, 'https://placehold.co/400x400?text=Gigabyte%2BEagle', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p73, N'VRAM', N'12GB GDDR6X', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p73, N'Chip đồ họa', N'NVIDIA RTX 4070 Ti', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p73, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-asus-tuf-rtx-4080-903')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa ASUS TUF RTX 4080', 'card-do-hoa-asus-tuf-rtx-4080-903', N'Card đồ họa NVIDIA RTX 4080, VRAM 16GB GDDR6X, giao tiếp PCIe 4.0.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p74 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p74, 'CARD-DO-HOA-ASUS-TUF-RTX-4080-903', 16800000, NULL, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p74, 'https://placehold.co/400x400?text=ASUS%2BTUF', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p74, N'VRAM', N'16GB GDDR6X', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p74, N'Chip đồ họa', N'NVIDIA RTX 4080', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p74, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-msi-ventus-rx-7600-904')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa MSI Ventus RX 7600', 'card-do-hoa-msi-ventus-rx-7600-904', N'Card đồ họa AMD Radeon RX 7600, VRAM 8GB GDDR6, giao tiếp PCIe 4.0.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p75 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p75, 'CARD-DO-HOA-MSI-VENTUS-RX-7600-904', 31100000, NULL, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p75, 'https://placehold.co/400x400?text=MSI%2BVentus', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p75, N'VRAM', N'8GB GDDR6', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p75, N'Chip đồ họa', N'AMD Radeon RX 7600', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p75, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-gigabyte-gaming-rx-7700-xt-905')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa Gigabyte Gaming RX 7700 XT', 'card-do-hoa-gigabyte-gaming-rx-7700-xt-905', N'Card đồ họa AMD Radeon RX 7700 XT, VRAM 12GB GDDR6, giao tiếp PCIe 4.0.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'Gigabyte'), 1, GETDATE());
    DECLARE @p76 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p76, 'CARD-DO-HOA-GIGABYTE-GAMING-RX-7700-XT-9', 29900000, NULL, 4, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p76, 'https://placehold.co/400x400?text=Gigabyte%2BGaming', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p76, N'VRAM', N'12GB GDDR6', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p76, N'Chip đồ họa', N'AMD Radeon RX 7700 XT', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p76, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-asus-dual-rtx-4060-ti-906')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa ASUS Dual RTX 4060 Ti', 'card-do-hoa-asus-dual-rtx-4060-ti-906', N'Card đồ họa NVIDIA RTX 4060 Ti, VRAM 16GB GDDR6, giao tiếp PCIe 4.0.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'ASUS'), 1, GETDATE());
    DECLARE @p77 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p77, 'CARD-DO-HOA-ASUS-DUAL-RTX-4060-TI-906', 28500000, NULL, 5, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p77, 'https://placehold.co/400x400?text=ASUS%2BDual', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p77, N'VRAM', N'16GB GDDR6', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p77, N'Chip đồ họa', N'NVIDIA RTX 4060 Ti', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p77, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'card-do-hoa-msi-suprim-rtx-4090-907')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Card đồ họa MSI Suprim RTX 4090', 'card-do-hoa-msi-suprim-rtx-4090-907', N'Card đồ họa NVIDIA RTX 4090, VRAM 24GB GDDR6X, giao tiếp PCIe 4.0.',
            (SELECT id FROM CATEGORY WHERE slug = 'gpu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p78 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p78, 'CARD-DO-HOA-MSI-SUPRIM-RTX-4090-907', 13400000, NULL, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p78, 'https://placehold.co/400x400?text=MSI%2BSuprim', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p78, N'VRAM', N'24GB GDDR6X', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p78, N'Chip đồ họa', N'NVIDIA RTX 4090', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p78, N'Giao tiếp', N'PCIe 4.0', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-samsung-980-256gb-1000')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Samsung 980 256GB', 'ssd-samsung-980-256gb-1000', N'Ổ cứng SSD 256GB, chuẩn M.2 NVMe PCIe 3.0, tốc độ đọc tối đa 3.100 MB/s.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p79 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p79, 'SSD-SAMSUNG-980-256GB-1000', 900000, NULL, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p79, 'https://placehold.co/400x400?text=Samsung%2BSSD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p79, N'Dung lượng', N'256GB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p79, N'Chuẩn', N'M.2 NVMe PCIe 3.0', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p79, N'Tốc độ đọc', N'3.100 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-samsung-990-pro-1tb-1001')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Samsung 990 Pro 1TB', 'ssd-samsung-990-pro-1tb-1001', N'Ổ cứng SSD 1TB, chuẩn M.2 NVMe PCIe 4.0, tốc độ đọc tối đa 7.450 MB/s.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Samsung'), 1, GETDATE());
    DECLARE @p80 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p80, 'SSD-SAMSUNG-990-PRO-1TB-1001', 1200000, NULL, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p80, 'https://placehold.co/400x400?text=Samsung%2BSSD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p80, N'Dung lượng', N'1TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p80, N'Chuẩn', N'M.2 NVMe PCIe 4.0', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p80, N'Tốc độ đọc', N'7.450 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-wd-blue-sn570-500gb-1002')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD WD Blue SN570 500GB', 'ssd-wd-blue-sn570-500gb-1002', N'Ổ cứng SSD 500GB, chuẩn M.2 NVMe PCIe 3.0, tốc độ đọc tối đa 3.500 MB/s.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'WD'), 1, GETDATE());
    DECLARE @p81 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p81, 'SSD-WD-BLUE-SN570-500GB-1002', 3100000, 3200000, 38, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p81, 'https://placehold.co/400x400?text=WD%2BSSD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p81, N'Dung lượng', N'500GB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p81, N'Chuẩn', N'M.2 NVMe PCIe 3.0', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p81, N'Tốc độ đọc', N'3.500 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-wd-black-sn850x-2tb-1003')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD WD Black SN850X 2TB', 'ssd-wd-black-sn850x-2tb-1003', N'Ổ cứng SSD 2TB, chuẩn M.2 NVMe PCIe 4.0, tốc độ đọc tối đa 7.300 MB/s.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'WD'), 1, GETDATE());
    DECLARE @p82 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p82, 'SSD-WD-BLACK-SN850X-2TB-1003', 3200000, NULL, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p82, 'https://placehold.co/400x400?text=WD%2BSSD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p82, N'Dung lượng', N'2TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p82, N'Chuẩn', N'M.2 NVMe PCIe 4.0', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p82, N'Tốc độ đọc', N'7.300 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-kingston-nv2-500gb-1004')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Kingston NV2 500GB', 'ssd-kingston-nv2-500gb-1004', N'Ổ cứng SSD 500GB, chuẩn M.2 NVMe PCIe 4.0, tốc độ đọc tối đa 3.500 MB/s.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p83 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p83, 'SSD-KINGSTON-NV2-500GB-1004', 2000000, NULL, 16, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p83, 'https://placehold.co/400x400?text=Kingston%2BSSD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p83, N'Dung lượng', N'500GB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p83, N'Chuẩn', N'M.2 NVMe PCIe 4.0', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p83, N'Tốc độ đọc', N'3.500 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-kingston-kc3000-1tb-1005')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Kingston KC3000 1TB', 'ssd-kingston-kc3000-1tb-1005', N'Ổ cứng SSD 1TB, chuẩn M.2 NVMe PCIe 4.0, tốc độ đọc tối đa 7.000 MB/s.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Kingston'), 1, GETDATE());
    DECLARE @p84 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p84, 'SSD-KINGSTON-KC3000-1TB-1005', 1000000, 1100000, 36, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p84, 'https://placehold.co/400x400?text=Kingston%2BSSD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p84, N'Dung lượng', N'1TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p84, N'Chuẩn', N'M.2 NVMe PCIe 4.0', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p84, N'Tốc độ đọc', N'7.000 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-crucial-mx500-1tb-1006')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Crucial MX500 1TB', 'ssd-crucial-mx500-1tb-1006', N'Ổ cứng SSD 1TB, chuẩn SATA III 2.5", tốc độ đọc tối đa 560 MB/s.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Crucial'), 1, GETDATE());
    DECLARE @p85 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p85, 'SSD-CRUCIAL-MX500-1TB-1006', 4400000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p85, 'https://placehold.co/400x400?text=Crucial%2BSSD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p85, N'Dung lượng', N'1TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p85, N'Chuẩn', N'SATA III 2.5"', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p85, N'Tốc độ đọc', N'560 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'ssd-crucial-p5-plus-2tb-1007')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'SSD Crucial P5 Plus 2TB', 'ssd-crucial-p5-plus-2tb-1007', N'Ổ cứng SSD 2TB, chuẩn M.2 NVMe PCIe 4.0, tốc độ đọc tối đa 6.600 MB/s.',
            (SELECT id FROM CATEGORY WHERE slug = 'ssd'),
            (SELECT id FROM BRAND WHERE name = N'Crucial'), 1, GETDATE());
    DECLARE @p86 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p86, 'SSD-CRUCIAL-P5-PLUS-2TB-1007', 800000, NULL, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p86, 'https://placehold.co/400x400?text=Crucial%2BSSD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p86, N'Dung lượng', N'2TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p86, N'Chuẩn', N'M.2 NVMe PCIe 4.0', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p86, N'Tốc độ đọc', N'6.600 MB/s', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-western-digital-blue-1tb-1100')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Western Digital Blue 1TB', 'o-cung-hdd-western-digital-blue-1tb-1100', N'Ổ cứng HDD 3.5" 1TB, tốc độ quay 7200rpm.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p87 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p87, 'O-CUNG-HDD-WESTERN-DIGITAL-BLUE-1TB-1100', 3900000, NULL, 33, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p87, 'https://placehold.co/400x400?text=Western%20Digital%2BHDD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p87, N'Dung lượng', N'1TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p87, N'Tốc độ quay', N'7200rpm', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p87, N'Giao tiếp', N'SATA III', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-western-digital-purple-4tb-1101')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Western Digital Purple 4TB', 'o-cung-hdd-western-digital-purple-4tb-1101', N'Ổ cứng HDD 3.5" 4TB, tốc độ quay 5400rpm.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p88 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p88, 'O-CUNG-HDD-WESTERN-DIGITAL-PURPLE-4TB-11', 1900000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p88, 'https://placehold.co/400x400?text=Western%20Digital%2BHDD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p88, N'Dung lượng', N'4TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p88, N'Tốc độ quay', N'5400rpm', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p88, N'Giao tiếp', N'SATA III', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-barracuda-2tb-1102')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate Barracuda 2TB', 'o-cung-hdd-seagate-barracuda-2tb-1102', N'Ổ cứng HDD 3.5" 2TB, tốc độ quay 7200rpm.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p89 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p89, 'O-CUNG-HDD-SEAGATE-BARRACUDA-2TB-1102', 3700000, NULL, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p89, 'https://placehold.co/400x400?text=Seagate%2BHDD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p89, N'Dung lượng', N'2TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p89, N'Tốc độ quay', N'7200rpm', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p89, N'Giao tiếp', N'SATA III', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-seagate-ironwolf-4tb-1103')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Seagate IronWolf 4TB', 'o-cung-hdd-seagate-ironwolf-4tb-1103', N'Ổ cứng HDD 3.5" 4TB, tốc độ quay 5900rpm.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Seagate'), 1, GETDATE());
    DECLARE @p90 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p90, 'O-CUNG-HDD-SEAGATE-IRONWOLF-4TB-1103', 1600000, NULL, 14, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p90, 'https://placehold.co/400x400?text=Seagate%2BHDD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p90, N'Dung lượng', N'4TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p90, N'Tốc độ quay', N'5900rpm', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p90, N'Giao tiếp', N'SATA III', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'o-cung-hdd-western-digital-black-8tb-1104')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Ổ cứng HDD Western Digital Black 8TB', 'o-cung-hdd-western-digital-black-8tb-1104', N'Ổ cứng HDD 3.5" 8TB, tốc độ quay 7200rpm.',
            (SELECT id FROM CATEGORY WHERE slug = 'hdd'),
            (SELECT id FROM BRAND WHERE name = N'Western Digital'), 1, GETDATE());
    DECLARE @p91 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p91, 'O-CUNG-HDD-WESTERN-DIGITAL-BLACK-8TB-110', 3100000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p91, 'https://placehold.co/400x400?text=Western%20Digital%2BHDD', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p91, N'Dung lượng', N'8TB', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p91, N'Tốc độ quay', N'7200rpm', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p91, N'Giao tiếp', N'SATA III', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-corsair-cv450-450w-1200')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Corsair CV450 450W', 'nguon-corsair-cv450-450w-1200', N'Nguồn máy tính 450W, chuẩn 80 Plus Bronze, non-modular.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p92 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p92, 'NGUON-CORSAIR-CV450-450W-1200', 3900000, NULL, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p92, 'https://placehold.co/400x400?text=Corsair%2BPSU', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p92, N'Công suất', N'450W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p92, N'Chuẩn 80 Plus', N'80 Plus Bronze', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p92, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-corsair-rm850x-850w-1201')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Corsair RM850x 850W', 'nguon-corsair-rm850x-850w-1201', N'Nguồn máy tính 850W, chuẩn 80 Plus Gold, full modular.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p93 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p93, 'NGUON-CORSAIR-RM850X-850W-1201', 2000000, NULL, 26, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p93, 'https://placehold.co/400x400?text=Corsair%2BPSU', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p93, N'Công suất', N'850W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p93, N'Chuẩn 80 Plus', N'80 Plus Gold', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p93, N'Loại nguồn', N'Full modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-cooler-master-mwe-650-650w-1202')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Cooler Master MWE 650 650W', 'nguon-cooler-master-mwe-650-650w-1202', N'Nguồn máy tính 650W, chuẩn 80 Plus Bronze, non-modular.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Cooler Master'), 1, GETDATE());
    DECLARE @p94 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p94, 'NGUON-COOLER-MASTER-MWE-650-650W-1202', 3700000, NULL, 25, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p94, 'https://placehold.co/400x400?text=Cooler%20Master%2BPSU', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p94, N'Công suất', N'650W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p94, N'Chuẩn 80 Plus', N'80 Plus Bronze', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p94, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-cooler-master-v850-sfx-850w-1203')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Cooler Master V850 SFX 850W', 'nguon-cooler-master-v850-sfx-850w-1203', N'Nguồn máy tính 850W, chuẩn 80 Plus Gold, full modular.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Cooler Master'), 1, GETDATE());
    DECLARE @p95 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p95, 'NGUON-COOLER-MASTER-V850-SFX-850W-1203', 2200000, NULL, 18, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p95, 'https://placehold.co/400x400?text=Cooler%20Master%2BPSU', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p95, N'Công suất', N'850W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p95, N'Chuẩn 80 Plus', N'80 Plus Gold', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p95, N'Loại nguồn', N'Full modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-msi-mag-a750bn-750w-1204')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn MSI MAG A750BN 750W', 'nguon-msi-mag-a750bn-750w-1204', N'Nguồn máy tính 750W, chuẩn 80 Plus Bronze, non-modular.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'MSI'), 1, GETDATE());
    DECLARE @p96 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p96, 'NGUON-MSI-MAG-A750BN-750W-1204', 2000000, NULL, 10, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p96, 'https://placehold.co/400x400?text=MSI%2BPSU', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p96, N'Công suất', N'750W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p96, N'Chuẩn 80 Plus', N'80 Plus Bronze', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p96, N'Loại nguồn', N'Non-modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'nguon-corsair-hx1000-1000w-1205')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Nguồn Corsair HX1000 1000W', 'nguon-corsair-hx1000-1000w-1205', N'Nguồn máy tính 1000W, chuẩn 80 Plus Platinum, full modular.',
            (SELECT id FROM CATEGORY WHERE slug = 'psu'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p97 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p97, 'NGUON-CORSAIR-HX1000-1000W-1205', 4000000, NULL, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p97, 'https://placehold.co/400x400?text=Corsair%2BPSU', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p97, N'Công suất', N'1000W', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p97, N'Chuẩn 80 Plus', N'80 Plus Platinum', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p97, N'Loại nguồn', N'Full modular', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-corsair-4000d-airflow-1300')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Corsair 4000D Airflow', 'vo-case-corsair-4000d-airflow-1300', N'Vỏ case hỗ trợ ATX/Micro-ATX, 4 khe quạt trước.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p98 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p98, 'VO-CASE-CORSAIR-4000D-AIRFLOW-1300', 2700000, NULL, 6, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p98, 'https://placehold.co/400x400?text=Corsair%2BCase', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p98, N'Kích thước hỗ trợ', N'ATX/Micro-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p98, N'Đặc điểm', N'4 khe quạt trước', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-cooler-master-masterbox-td500-1301')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Cooler Master MasterBox TD500', 'vo-case-cooler-master-masterbox-td500-1301', N'Vỏ case hỗ trợ ATX/Micro-ATX/ITX, 3 khe quạt kính cường lực.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Cooler Master'), 1, GETDATE());
    DECLARE @p99 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p99, 'VO-CASE-COOLER-MASTER-MASTERBOX-TD500-13', 3400000, NULL, 13, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p99, 'https://placehold.co/400x400?text=Cooler%20Master%2BCase', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p99, N'Kích thước hỗ trợ', N'ATX/Micro-ATX/ITX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p99, N'Đặc điểm', N'3 khe quạt kính cường lực', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-nzxt-h510-flow-1302')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case NZXT H510 Flow', 'vo-case-nzxt-h510-flow-1302', N'Vỏ case hỗ trợ ATX/Micro-ATX/ITX, 2 khe quạt tối ưu khí.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'NZXT'), 1, GETDATE());
    DECLARE @p100 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p100, 'VO-CASE-NZXT-H510-FLOW-1302', 2000000, NULL, 20, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p100, 'https://placehold.co/400x400?text=NZXT%2BCase', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p100, N'Kích thước hỗ trợ', N'ATX/Micro-ATX/ITX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p100, N'Đặc điểm', N'2 khe quạt tối ưu khí', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-lian-li-lancool-216-1303')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Lian Li Lancool 216', 'vo-case-lian-li-lancool-216-1303', N'Vỏ case hỗ trợ ATX/E-ATX, 2 quạt 160mm tặng kèm.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Lian Li'), 1, GETDATE());
    DECLARE @p101 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p101, 'VO-CASE-LIAN-LI-LANCOOL-216-1303', 1500000, NULL, 12, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p101, 'https://placehold.co/400x400?text=Lian%20Li%2BCase', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p101, N'Kích thước hỗ trợ', N'ATX/E-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p101, N'Đặc điểm', N'2 quạt 160mm tặng kèm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-corsair-5000d-airflow-1304')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Corsair 5000D Airflow', 'vo-case-corsair-5000d-airflow-1304', N'Vỏ case hỗ trợ ATX/E-ATX, hỗ trợ tản nước 360mm.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p102 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p102, 'VO-CASE-CORSAIR-5000D-AIRFLOW-1304', 3300000, NULL, 11, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p102, 'https://placehold.co/400x400?text=Corsair%2BCase', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p102, N'Kích thước hỗ trợ', N'ATX/E-ATX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p102, N'Đặc điểm', N'Hỗ trợ tản nước 360mm', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'vo-case-cooler-master-nr200p-1305')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Vỏ case Cooler Master NR200P', 'vo-case-cooler-master-nr200p-1305', N'Vỏ case hỗ trợ Mini-ITX, case nhỏ gọn cho sff.',
            (SELECT id FROM CATEGORY WHERE slug = 'case-may-tinh'),
            (SELECT id FROM BRAND WHERE name = N'Cooler Master'), 1, GETDATE());
    DECLARE @p103 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p103, 'VO-CASE-COOLER-MASTER-NR200P-1305', 1200000, NULL, 23, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p103, 'https://placehold.co/400x400?text=Cooler%20Master%2BCase', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p103, N'Kích thước hỗ trợ', N'Mini-ITX', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p103, N'Đặc điểm', N'Case nhỏ gọn cho SFF', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-cooler-master-hyper-212-halo-1400')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt Cooler Master Hyper 212 Halo', 'tan-nhiet-cooler-master-hyper-212-halo-1400', N'Tản nhiệt CPU loại Khí, quạt 120mm, tương thích Intel/AMD.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'Cooler Master'), 1, GETDATE());
    DECLARE @p104 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p104, 'TAN-NHIET-COOLER-MASTER-HYPER-212-HALO-1', 700000, NULL, 17, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p104, 'https://placehold.co/400x400?text=Cooler%20Master%2BCooler', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p104, N'Loại tản nhiệt', N'Khí', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p104, N'Kích thước quạt', N'120mm', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p104, N'Tương thích socket', N'Intel/AMD', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-deepcool-ak620-1401')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt DeepCool AK620', 'tan-nhiet-deepcool-ak620-1401', N'Tản nhiệt CPU loại Khí Dual-tower, quạt 120mm x2, tương thích Intel/AMD.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'DeepCool'), 1, GETDATE());
    DECLARE @p105 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p105, 'TAN-NHIET-DEEPCOOL-AK620-1401', 2700000, NULL, 19, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p105, 'https://placehold.co/400x400?text=DeepCool%2BCooler', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p105, N'Loại tản nhiệt', N'Khí Dual-tower', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p105, N'Kích thước quạt', N'120mm x2', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p105, N'Tương thích socket', N'Intel/AMD', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-corsair-icue-h100i-elite-1402')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt Corsair iCUE H100i Elite', 'tan-nhiet-corsair-icue-h100i-elite-1402', N'Tản nhiệt CPU loại AIO Nước 240mm, quạt 120mm x2, tương thích Intel/AMD.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p106 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p106, 'TAN-NHIET-CORSAIR-ICUE-H100I-ELITE-1402', 1300000, NULL, 24, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p106, 'https://placehold.co/400x400?text=Corsair%2BCooler', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p106, N'Loại tản nhiệt', N'AIO Nước 240mm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p106, N'Kích thước quạt', N'120mm x2', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p106, N'Tương thích socket', N'Intel/AMD', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-corsair-icue-h150i-elite-1403')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt Corsair iCUE H150i Elite', 'tan-nhiet-corsair-icue-h150i-elite-1403', N'Tản nhiệt CPU loại AIO Nước 360mm, quạt 120mm x3, tương thích Intel/AMD.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'Corsair'), 1, GETDATE());
    DECLARE @p107 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p107, 'TAN-NHIET-CORSAIR-ICUE-H150I-ELITE-1403', 1800000, NULL, 22, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p107, 'https://placehold.co/400x400?text=Corsair%2BCooler', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p107, N'Loại tản nhiệt', N'AIO Nước 360mm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p107, N'Kích thước quạt', N'120mm x3', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p107, N'Tương thích socket', N'Intel/AMD', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT WHERE slug = 'tan-nhiet-deepcool-ls520-1404')
BEGIN
    INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
    VALUES (N'Tản nhiệt DeepCool LS520', 'tan-nhiet-deepcool-ls520-1404', N'Tản nhiệt CPU loại AIO Nước 240mm, quạt 120mm x2, tương thích Intel/AMD.',
            (SELECT id FROM CATEGORY WHERE slug = 'tan-nhiet-cpu'),
            (SELECT id FROM BRAND WHERE name = N'DeepCool'), 1, GETDATE());
    DECLARE @p108 INT = SCOPE_IDENTITY();
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
    VALUES (@p108, 'TAN-NHIET-DEEPCOOL-LS520-1404', 1500000, NULL, 30, 1);
    INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
    VALUES (@p108, 'https://placehold.co/400x400?text=DeepCool%2BCooler', 1, 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p108, N'Loại tản nhiệt', N'AIO Nước 240mm', 0);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p108, N'Kích thước quạt', N'120mm x2', 1);
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    VALUES (@p108, N'Tương thích socket', N'Intel/AMD', 2);
END
GO
