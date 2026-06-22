-- ============================================================
--  DỮ LIỆU MẪU (tùy chọn) — 1 sản phẩm có NHIỀU PHIÊN BẢN
--  Minh hoạ "variant thật": option "Cấu hình" -> 3 biến thể.
--  Chạy SAU 01 (và nên sau 04). An toàn chạy 1 lần.
-- ============================================================
USE ShopDB;
GO

INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
VALUES (N'Laptop Lenovo LOQ 15', 'laptop-lenovo-loq-15',
        N'Laptop gaming nhiều cấu hình tùy chọn, chọn phiên bản phù hợp nhu cầu.',
        (SELECT id FROM CATEGORY WHERE slug = 'laptop'),
        (SELECT id FROM BRAND WHERE name = 'Lenovo'),
        1, GETDATE());
GO

DECLARE @pid INT = (SELECT id FROM PRODUCT WHERE slug = 'laptop-lenovo-loq-15');

-- Thuộc tính "Cấu hình"
INSERT INTO PRODUCT_OPTION (product_id, option_name) VALUES (@pid, N'Cấu hình');
DECLARE @opt INT = SCOPE_IDENTITY();

INSERT INTO OPTION_VALUE (option_id, value) VALUES
(@opt, N'i5 / 16GB / 512GB'),
(@opt, N'i7 / 16GB / 512GB'),
(@opt, N'i7 / 32GB / 1TB');

-- 3 biến thể tương ứng
INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default) VALUES
(@pid, 'LOQ-I5-16-512', 19990000, 21990000, 10, 1),
(@pid, 'LOQ-I7-16-512', 23990000, NULL,     7,  0),
(@pid, 'LOQ-I7-32-1TB', 28990000, NULL,     4,  0);

-- Ảnh
INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
VALUES (@pid, 'https://placehold.co/400x400?text=Lenovo+LOQ', 1, 0);

-- Liên kết biến thể <-> giá trị option
INSERT INTO VARIANT_OPTION_VALUE (variant_id, option_value_id)
SELECT (SELECT id FROM PRODUCT_VARIANT WHERE sku = 'LOQ-I5-16-512'),
       (SELECT id FROM OPTION_VALUE WHERE option_id = @opt AND value = N'i5 / 16GB / 512GB')
UNION ALL
SELECT (SELECT id FROM PRODUCT_VARIANT WHERE sku = 'LOQ-I7-16-512'),
       (SELECT id FROM OPTION_VALUE WHERE option_id = @opt AND value = N'i7 / 16GB / 512GB')
UNION ALL
SELECT (SELECT id FROM PRODUCT_VARIANT WHERE sku = 'LOQ-I7-32-1TB'),
       (SELECT id FROM OPTION_VALUE WHERE option_id = @opt AND value = N'i7 / 32GB / 1TB');
GO

PRINT N'✅ Đã thêm sản phẩm nhiều phiên bản: Laptop Lenovo LOQ 15.';
GO
