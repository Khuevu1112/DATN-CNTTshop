-- 52_pc_van_phong_real_data.sql
-- 51 đã đổi TOÀN BỘ 69 sản phẩm pc-may-tinh-ban thành tên/cấu hình kiểu "PC Gaming ..." nên
-- segment "PC Văn phòng" (CategoryView.vue lọc theo từ khoá "văn phòng" trong TÊN sản phẩm — xem
-- CATEGORY_SEGMENTS trong products.js) bị rỗng hoàn toàn. File này thay 14 sản phẩm rẻ nhất
-- (id 730,745,759,345,746,346,755,22,57,731,747,61,760,347 — trước đó nhận template gaming
-- ngân sách T0-T3 trong 51) bằng 8 cấu hình PC văn phòng THẬT (dòng "TTG (HOME) OFFICE" của
-- ttgshop.vn), tên có chứa "Văn phòng" để khớp lại segment filter. Cùng cơ chế UPDATE tại chỗ
-- (không xóa) như 51 vì vẫn vướng FK ORDER_ITEM. Chạy lại nhiều lần an toàn.
USE ShopDB;
GO

IF OBJECT_ID('tempdb..#office_templates') IS NOT NULL DROP TABLE #office_templates;
IF OBJECT_ID('tempdb..#office_mapping') IS NOT NULL DROP TABLE #office_mapping;

CREATE TABLE #office_templates (
    template_id INT PRIMARY KEY,
    name NVARCHAR(300), price DECIMAL(18,2), original_price DECIMAL(18,2), image_file NVARCHAR(300),
    cpu NVARCHAR(500), gpu NVARCHAR(500), ram NVARCHAR(500), ssd NVARCHAR(500),
    nguon NVARCHAR(500), mainboard NVARCHAR(500), vocase NVARCHAR(500), tannhiet NVARCHAR(500)
);

INSERT INTO #office_templates (template_id, name, price, original_price, image_file, cpu, gpu, ram, ssd, nguon, mainboard, vocase, tannhiet) VALUES
(0, N'PC Văn phòng Intel Pentium Gold G6405 | RAM 8GB SSD 256GB', 6980000, NULL,
 '38556794-6d01-43af-a41d-e963c026a460_pc-van-phong-pentium-g6405-home.jpg',
 N'Intel Pentium Gold G6405 (4.1GHz, 2 nhân 4 luồng)', N'Intel UHD Graphics 610 (tích hợp)',
 N'SSTC 8GB DDR4 3200MHz', N'SSTC Megamouth 256GB SATA SSD',
 N'SSTC 550F 550W', N'SSTC H510M-HD', N'AIGO Q1721', N'Jonsbo CR-1200'),

(1, N'PC Văn phòng AMD Ryzen 5 3400G | RAM 8GB SSD 256GB', 7280000, 8990000,
 '2a3c010a-b7f5-48e9-8f58-ea131814fac7_pc-van-phong-ryzen5-3400g-home.jpg',
 N'AMD Ryzen 5 3400G (3.7-4.2GHz, 4 nhân 8 luồng)', N'AMD Radeon Vega 11 (tích hợp)',
 N'SSTC 8GB DDR4 3200MHz', N'SSTC Megamouth 256GB SATA SSD',
 N'SSTC 550F 550W', N'SSTC A520MHP AM4 2.0', N'AIGO Q1721', N'Jonsbo CR-1200'),

(2, N'PC Văn phòng Intel Core i3-10105 | RAM 8GB SSD 256GB', 7980000, NULL,
 'e83604bc-ce8b-4a5f-9f22-d64ef69ff4a5_pc-van-phong-i3-10105-home.jpg',
 N'Intel Core i3-10105 (3.7-4.4GHz, 4 nhân 8 luồng)', N'Intel UHD Graphics 630 (tích hợp)',
 N'SSTC 8GB DDR4 3200MHz', N'SSTC Megamouth 256GB SATA SSD',
 N'SSTC 550F 550W', N'SSTC H510M-HD', N'AIGO Q1721', N'Jonsbo CR-1200'),

(3, N'PC Văn phòng Intel Core i5-10400 | RAM 8GB SSD 256GB', 8680000, NULL,
 '6b0a6d64-5742-4267-8a7a-b22db44c672b_pc-van-phong-i5-10400-home.jpg',
 N'Intel Core i5-10400 (2.9-4.3GHz, 6 nhân 12 luồng)', N'Intel UHD Graphics 630 (tích hợp)',
 N'SSTC 8GB DDR4 3200MHz', N'SSTC Megamouth 256GB SATA SSD',
 N'SSTC 550F 550W', N'SSTC H510M-HD', N'AIGO Q1721', N'Jonsbo CR-1200'),

(4, N'PC Văn phòng AMD Ryzen 3 3200G | RAM 8GB SSD 256GB (kèm Windows 11 Pro)', 10280000, NULL,
 'a52c4949-1f4f-4375-9aec-134343620364_pc-van-phong-ryzen3-3200g-office.png',
 N'AMD Ryzen 3 3200G (3.6-4.0GHz, 4 nhân 4 luồng)', N'AMD Radeon Vega 8 (tích hợp)',
 N'SSTC 8GB DDR4 3200MHz', N'SSTC Megamouth 256GB SATA SSD',
 N'SSTC 550F 550W', N'SSTC A520MHP AM4 2.0', N'AIGO Q1721', N'Jonsbo CR-1200'),

(5, N'PC Văn phòng AMD Ryzen 5 3400G | RAM 8GB SSD 256GB (kèm Windows 11 Pro)', 11180000, NULL,
 '9db4db7a-1a1e-4f42-80e5-8aefc9ca8502_pc-van-phong-ryzen5-3400g-office.png',
 N'AMD Ryzen 5 3400G (3.7-4.2GHz, 4 nhân 8 luồng)', N'AMD Radeon Vega 11 (tích hợp)',
 N'SSTC 8GB DDR4 3200MHz', N'SSTC Megamouth 256GB SATA SSD',
 N'SSTC 550F 550W', N'SSTC A520MHP AM4 2.0', N'AIGO Q1721', N'Jonsbo CR-1200'),

(6, N'PC Văn phòng AMD Ryzen 5 5500GT | RAM 8GB SSD 256GB (kèm Windows 11 Pro)', 12980000, 13990000,
 'b0291199-e3c5-4fe5-b90c-313e2e5e14f7_pc-van-phong-ryzen5-5500gt-office.png',
 N'AMD Ryzen 5 5500GT (3.6-4.4GHz, 6 nhân 12 luồng)', N'AMD Radeon Graphics (tích hợp)',
 N'SSTC 8GB DDR4 3200MHz', N'SSTC Megamouth 256GB SATA SSD',
 N'SSTC 550F 550W', N'SSTC A520MHP AM4 2.0', N'AIGO Q1721', N'Jonsbo CR-1200'),

(7, N'PC Văn phòng Intel Core i5-14400 | RAM 8GB SSD 256GB (kèm Windows 11 Pro)', 14280000, 15990000,
 '4d3765fb-b467-4a6a-a814-aa1ac872d78a_pc-van-phong-i5-14400-office.png',
 N'Intel Core i5-14400 (2.5-4.7GHz, 10 nhân 16 luồng)', N'Intel UHD Graphics 730 (tích hợp)',
 N'SSTC 8GB DDR4 3200MHz', N'SSTC Megamouth 256GB SATA SSD',
 N'SSTC 550F 550W', N'SSTC H610M-HDV DDR4', N'AIGO Q1721', N'Jonsbo CR-1200');
GO

-- 14 sản phẩm rẻ nhất trong 69 (trước đó nhận template gaming ngân sách ở 51) -> 8 mẫu văn phòng thật
CREATE TABLE #office_mapping (product_id INT PRIMARY KEY, template_id INT);
INSERT INTO #office_mapping (product_id, template_id) VALUES
(730,0),(745,0),
(759,1),(345,1),
(746,2),(346,2),
(755,3),
(22,4),(57,4),
(731,5),(747,5),
(61,6),(760,6),
(347,7);
GO

UPDATE p SET p.name = t.name
FROM PRODUCT p
JOIN #office_mapping m ON m.product_id = p.id
JOIN #office_templates t ON t.template_id = m.template_id;

UPDATE v SET v.price = t.price, v.original_price = t.original_price
FROM PRODUCT_VARIANT v
JOIN #office_mapping m ON m.product_id = v.product_id
JOIN #office_templates t ON t.template_id = m.template_id
WHERE v.is_default = 1;

DELETE FROM PRODUCT_SPEC WHERE product_id IN (SELECT product_id FROM #office_mapping);

INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
SELECT m.product_id, x.spec_key, x.spec_value, x.sort_order
FROM #office_mapping m
JOIN #office_templates t ON t.template_id = m.template_id
CROSS APPLY (VALUES
    (N'CPU', t.cpu, 0),
    (N'Card đồ họa', t.gpu, 1),
    (N'RAM', t.ram, 2),
    (N'Ổ cứng', t.ssd, 3),
    (N'Nguồn', t.nguon, 4),
    (N'Mainboard', t.mainboard, 90),
    (N'Vỏ case', t.vocase, 91),
    (N'Tản nhiệt', t.tannhiet, 92)
) AS x(spec_key, spec_value, sort_order);

DELETE FROM PRODUCT_IMAGE WHERE product_id IN (SELECT product_id FROM #office_mapping);

INSERT INTO PRODUCT_IMAGE (product_id, variant_id, url, is_primary, sort_order)
SELECT m.product_id, NULL, CONCAT(N'/uploads/products/', t.image_file), 1, 0
FROM #office_mapping m
JOIN #office_templates t ON t.template_id = m.template_id;

DROP TABLE #office_templates;
DROP TABLE #office_mapping;
GO
