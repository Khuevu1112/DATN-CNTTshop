-- 50_fix_missing_pc_specs.sql
-- 46 bỏ sót 3 sản phẩm PC dựng sẵn không có CPU gốc để đối chiếu mainboard/case/tản nhiệt
-- tương thích: id 1 "PC Gaming I5 RTX5060", id 4 "PC Gaming", id 10 "PC Gaming MSI Aegis".
-- Bổ sung đủ bộ specs (CPU/Card đồ họa/RAM/Ổ cứng/Nguồn/Mainboard/Vỏ case/Tản nhiệt), cấu hình
-- chọn khớp tên sản phẩm và phân khúc giá; chipset mainboard khớp socket/thế hệ CPU như quy ước
-- ở 46 (K/KS -> Z790, F/non-K -> B760, AM5 -> B650/X670). Chạy lại nhiều lần an toàn (IF NOT EXISTS).
USE ShopDB;
GO

INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
SELECT d.pid, d.k, d.v, d.so
FROM (VALUES
    -- id 1 "PC Gaming I5 RTX5060" (150.000.000đ — cấu hình cao cấp nhất danh mục)
    (1, N'CPU',         N'Intel Core i5-14600K', 0),
    (1, N'Card đồ họa', N'RTX 5060 8GB', 1),
    (1, N'RAM',         N'64GB DDR5', 2),
    (1, N'Ổ cứng',      N'2TB NVMe SSD', 3),
    (1, N'Nguồn',       N'850W 80+ Gold', 4),
    (1, N'Mainboard',   N'ASUS Z790', 90),
    (1, N'Vỏ case',     N'Corsair', 91),
    (1, N'Tản nhiệt',   N'Thermalright Frozen Warframe 240', 92),

    -- id 4 "PC Gaming" (45.000.000đ — phân khúc trung-cao)
    (4, N'CPU',         N'AMD Ryzen 7 7700X', 0),
    (4, N'Card đồ họa', N'RTX 4070 Ti Super 16GB', 1),
    (4, N'RAM',         N'32GB DDR5', 2),
    (4, N'Ổ cứng',      N'2TB NVMe SSD', 3),
    (4, N'Nguồn',       N'750W 80+ Gold', 4),
    (4, N'Mainboard',   N'Gigabyte B650', 90),
    (4, N'Vỏ case',     N'DarkFlash', 91),
    (4, N'Tản nhiệt',   N'DeepCool LS520', 92),

    -- id 10 "PC Gaming MSI Aegis" (35.000.000đ — mainboard MSI khớp thương hiệu Aegis)
    (10, N'CPU',         N'Intel Core i7-13700F', 0),
    (10, N'Card đồ họa', N'RTX 4070 12GB', 1),
    (10, N'RAM',         N'32GB DDR5', 2),
    (10, N'Ổ cứng',      N'1TB NVMe SSD', 3),
    (10, N'Nguồn',       N'650W 80+ Gold', 4),
    (10, N'Mainboard',   N'MSI B760', 90),
    (10, N'Vỏ case',     N'Vitra', 91),
    (10, N'Tản nhiệt',   N'DeepCool AK400', 92)
) AS d(pid, k, v, so)
WHERE NOT EXISTS (SELECT 1 FROM PRODUCT_SPEC s WHERE s.product_id = d.pid AND s.spec_key = d.k);
GO
