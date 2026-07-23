-- 58_new_pc_builds_workstation_virtualization_monitor.sql
-- Bổ sung 25 sản phẩm PC mới vào category pc-may-tinh-ban: 10 workstation (đồ họa/render/AI,
-- khảo sát từ ttgshop.vn/pc-rendering + pc-machine-learning-ai), 10 giả lập ảo hóa Dual Xeon
-- (ttgshop.vn/pc-gia-lap-ao-hoa), 5 PC kèm màn hình (ttgshop.vn/full-bo-pc-kem-man-hinh).
-- Đây là sản phẩm MỚI (INSERT, không phải UPDATE như các file 51-56 trước) nên không đụng tới
-- 69 sản phẩm cũ. Ảnh thật đã tải về uploads/products/. Mainboard/Nguồn/Vỏ case/Tản nhiệt cho
-- dòng Dual Xeon là build máy chủ 2 CPU đời cũ (LGA2011-3) — không có mainboard 2 socket tương
-- ứng trong catalog linh kiện tiêu dùng nên mô tả bằng text (giống 46/51: thông số nằm trong tên).
USE ShopDB;
GO

IF OBJECT_ID('tempdb..#new_pc') IS NOT NULL DROP TABLE #new_pc;
CREATE TABLE #new_pc (
    slug NVARCHAR(200) PRIMARY KEY, name NVARCHAR(300), price DECIMAL(18,2), original_price DECIMAL(18,2), image_file NVARCHAR(300),
    cpu NVARCHAR(500), gpu NVARCHAR(500), ram NVARCHAR(200), ssd NVARCHAR(200), nguon NVARCHAR(300),
    mainboard NVARCHAR(300), vocase NVARCHAR(200), tannhiet NVARCHAR(300), manhinh NVARCHAR(200)
);

INSERT INTO #new_pc (slug, name, price, original_price, image_file, cpu, gpu, ram, ssd, nguon, mainboard, vocase, tannhiet, manhinh) VALUES
-- Workstation (10)
('ws-i5-12600kf-rtx3060', N'PC Workstation Intel Core i5-12600KF | RTX 3060 12GB', 22680000, NULL, '1a31d346-25b9-4635-8c6e-19dbcba501d8_ws-i5-12600kf-rtx3060.jpg',
 N'Intel Core i5-12600KF (10 nhân 16 luồng, up to 4.9GHz)', N'RTX 3060 12GB', N'16GB DDR4', N'512GB NVMe SSD', N'Corsair CX550 550W', N'ASUS Prime B660M-A', N'NZXT H510 Flow', N'Tản nhiệt khí DeepCool AK400', NULL),
('ws-i7-14700f-rtx5060ti8gb', N'PC Workstation Intel Core i7-14700F | RTX 5060 Ti 8GB', 35980000, 40900000, 'a082bd43-3d12-4eb4-8e2c-7899ec4e7276_ws-i7-14700f-rtx5060ti8gb.jpg',
 N'Intel Core i7-14700F (20 nhân 28 luồng, up to 5.4GHz)', N'RTX 5060 Ti 8GB', N'32GB DDR5', N'512GB NVMe SSD', N'Corsair RM750e 750W 80+ Gold', N'Gigabyte B760M Aorus Elite', N'Corsair 4000D Airflow', N'Tản nhiệt nước DeepCool LS520', NULL),
('ws-i5-14600kf-rtx5060ti16gb', N'PC Workstation Intel Core i5-14600KF | RTX 5060 Ti 16GB', 33680000, NULL, '6275d38a-1f46-4030-b157-3c18e9451b8e_ws-i5-14600kf-rtx5060ti16gb.jpg',
 N'Intel Core i5-14600KF (14 nhân 20 luồng, up to 5.3GHz)', N'RTX 5060 Ti 16GB', N'32GB DDR4', N'512GB NVMe SSD', N'MSI MPG A850G 850W', N'ASUS TUF Gaming Z790-Plus', N'Lian Li Lancool 216', N'Tản nhiệt nước DeepCool LS720', NULL),
('ws-ultra7-265kf-rtx5060ti8gb', N'PC Workstation Intel Core Ultra 7 265KF | RTX 5060 Ti 8GB', 37980000, NULL, 'addd3ad9-cc52-4521-accc-be664f781fb6_ws-ultra7-265kf-rtx5060ti8gb.jpg',
 N'Intel Core Ultra 7 265KF (20 nhân 20 luồng, up to 5.5GHz)', N'RTX 5060 Ti 8GB', N'32GB DDR5', N'512GB NVMe SSD', N'FSP Hydro G Pro 750W', N'MSI PRO B760M-P', N'Fractal Design Focus 2', N'Tản nhiệt khí DeepCool AK620', NULL),
('ws-i7-14700f-rtx5070-12gb', N'PC Workstation Intel Core i7-14700F | RTX 5070 12GB', 39280000, NULL, '00bb7f01-920b-4274-aef9-19bd9d83c52f_ws-i7-14700f-rtx5070-12gb.png',
 N'Intel Core i7-14700F (20 nhân 28 luồng, up to 5.4GHz)', N'RTX 5070 12GB', N'16GB DDR5', N'512GB NVMe SSD', N'Corsair RM850x 850W', N'Gigabyte B760M Aorus Elite', N'NZXT H7 Flow', N'Tản nhiệt nước DeepCool LS520', NULL),
('ws-r7-9800x3d-rtx5070-12gb', N'PC Workstation AMD Ryzen 7 9800X3D | RTX 5070 12GB', 59860000, NULL, '97b0d9ee-2a30-4207-a91d-9cff93a09d80_ws-r7-9800x3d-rtx5070-12gb.png',
 N'AMD Ryzen 7 9800X3D (8 nhân 16 luồng, up to 5.2GHz)', N'RTX 5070 12GB', N'32GB DDR5', N'512GB NVMe SSD', N'Corsair RM1000x 1000W', N'ASUS ROG Strix B650-A', N'Lian Li O11 Dynamic EVO', N'Corsair iCUE H150i Elite LCD', NULL),
('ws-r9-9950x-rtx5070ti-16gb', N'PC Workstation AMD Ryzen 9 9950X | RTX 5070 Ti 16GB', 61180000, NULL, 'c0bcef44-debb-4002-b37a-9d26533a3902_ws-r9-9950x-rtx5070ti-16gb.png',
 N'AMD Ryzen 9 9950X (16 nhân 32 luồng, up to 5.7GHz)', N'RTX 5070 Ti 16GB', N'32GB DDR5', N'512GB NVMe SSD', N'Thermaltake Toughpower GF3 1000W', N'Gigabyte X870E Aorus Master', N'Fractal Design Torrent', N'Tản nhiệt nước NZXT Kraken Elite 360', NULL),
('ws-i9-14900kf-rtx5080-16gb', N'PC Workstation Intel Core i9-14900KF | RTX 5080 16GB', 69680000, 79990000, '92888822-eb3c-4a5d-bfbf-4f4fc3d0feca_ws-i9-14900kf-rtx5080-16gb.jpg',
 N'Intel Core i9-14900KF (24 nhân 32 luồng, up to 6.0GHz)', N'RTX 5080 16GB', N'32GB DDR5', N'512GB NVMe SSD', N'FSP Hydro Ti Pro 1000W', N'MSI MEG Z790 Ace', N'Corsair 5000D Airflow', N'Tản nhiệt nước NZXT Kraken Elite 360', NULL),
('ws-ultra9-285k-rtx5080-16gb', N'PC Workstation Intel Core Ultra 9 285K | RTX 5080 16GB', 74980000, NULL, 'f6796da9-7f71-416d-81ca-fae924b6a49c_ws-ultra9-285k-rtx5080-16gb.jpg',
 N'Intel Core Ultra 9 285K (up to 5.7GHz, 24 nhân 24 luồng)', N'RTX 5080 16GB', N'32GB DDR5', N'512GB NVMe SSD', N'Corsair HX1000 1000W', N'Asrock Z890 Steel Legend WiFi DDR5', N'Thermaltake View 270', N'Tản nhiệt nước Corsair iCUE H150i Elite', NULL),
('ws-r9-9950x-rtx5060ti-16gb', N'PC Workstation AMD Ryzen 9 9950X | RTX 5060 Ti 16GB', 49680000, NULL, '94d56c6a-3bcb-4ce5-a65d-7f503779c7ef_ws-r9-9950x-rtx5060ti-16gb.jpg',
 N'AMD Ryzen 9 9950X (16 nhân 32 luồng, up to 5.7GHz)', N'RTX 5060 Ti 16GB', N'32GB DDR5', N'512GB NVMe SSD', N'MSI MPG A850G 850W', N'Gigabyte X670 Aorus Elite', N'Lian Li Lancool III', N'Tản nhiệt khí DeepCool AK620', NULL),
-- Virtualization / Dual Xeon (10)
('vh-dualxeon-e5-2683v4-gtx1660s', N'PC Giả Lập Ảo Hóa Dual Xeon E5-2683 v4 (32 nhân 64 luồng) | GTX 1660 Super 6GB', 18980000, 21100000, 'e9cc749e-676c-4529-bd68-819f91166450_vh-dualxeon-e5-2683v4-gtx1660s.jpg',
 N'2x Intel Xeon E5-2683 v4 (2.1-3.0GHz, tổng 32 nhân 64 luồng)', N'GTX 1660 Super 6GB', N'64GB DDR4 ECC', N'512GB SSD', N'Nguồn máy chủ 750W', N'Mainboard Dual Socket LGA2011-3 (server)', N'Case Dual CPU Tower/Rack', N'Tản nhiệt khí (2x, kèm CPU)', NULL),
('vh-dualxeon-e5-2686v4-ddr3-gtx1660s', N'PC Giả Lập Ảo Hóa Dual Xeon E5-2686 V4 (36 nhân 72 luồng) | GTX 1660 Super 6GB', 16480000, 20100000, '0bc231ba-875f-47af-b122-36201e3bd2fd_vh-dualxeon-e5-2686v4-ddr3-gtx1660s.jpg',
 N'2x Intel Xeon E5-2686 V4 (2.3GHz, tổng 36 nhân 72 luồng)', N'GTX 1660 Super 6GB', N'64GB DDR3 ECC', N'512GB SSD', N'Nguồn máy chủ 750W', N'Mainboard Dual Socket LGA2011-3 (server)', N'Case Dual CPU Tower/Rack', N'Tản nhiệt khí (2x, kèm CPU)', NULL),
('vh-dualxeon-e5-2686v4-ddr3-rtx3060', N'PC Giả Lập Ảo Hóa Dual Xeon E5-2686 V4 (36 nhân 72 luồng) | RTX 3060 12GB', 22280000, NULL, 'e8908d9d-f1ea-4cca-be30-618148011eab_vh-dualxeon-e5-2686v4-ddr3-rtx3060.jpg',
 N'2x Intel Xeon E5-2686 V4 (2.3GHz, tổng 36 nhân 72 luồng)', N'RTX 3060 12GB', N'64GB DDR3 ECC', N'512GB SSD', N'Nguồn máy chủ 750W', N'Mainboard Dual Socket LGA2011-3 (server)', N'Case Dual CPU Tower/Rack', N'Tản nhiệt khí (2x, kèm CPU)', NULL),
('vh-dualxeon-e5-2696v4-128gbddr3-rtx3060', N'PC Giả Lập Ảo Hóa Dual Xeon E5-2696 V4 (44 nhân 88 luồng) | 128GB DDR3 | RTX 3060 12GB', 29460000, 30060000, '77b96de8-1ff7-4187-8f02-1f6ab2b4eb21_vh-dualxeon-e5-2696v4-128gbddr3-rtx3060.jpg',
 N'2x Intel Xeon E5-2696 V4 (2.2-3.6GHz, tổng 44 nhân 88 luồng)', N'RTX 3060 12GB', N'128GB DDR3 ECC', N'512GB SSD', N'Nguồn máy chủ 850W', N'Mainboard Dual Socket LGA2011-3 (server)', N'Case Dual CPU Tower/Rack', N'Tản nhiệt khí (2x, kèm CPU)', NULL),
('vh-dualxeon-e5-2696v4-ddr3-gtx1660s', N'PC Giả Lập Ảo Hóa Dual Xeon E5-2696 V4 (44 nhân 88 luồng) | 64GB DDR3 | GTX 1660 Super 6GB', 20680000, 22000000, '5cc4440d-6a6d-45cd-a72b-94637fa7ef8f_vh-dualxeon-e5-2696v4-ddr3-gtx1660s.jpg',
 N'2x Intel Xeon E5-2696 V4 (2.2-3.6GHz, tổng 44 nhân 88 luồng)', N'GTX 1660 Super 6GB', N'64GB DDR3 ECC', N'512GB SSD', N'Nguồn máy chủ 750W', N'Mainboard Dual Socket LGA2011-3 (server)', N'Case Dual CPU Tower/Rack', N'Tản nhiệt khí (2x, kèm CPU)', NULL),
('vh-dualxeon-e5-2699v3-gtx1660s', N'PC Giả Lập Ảo Hóa Dual Xeon E5-2699 V3 (36 nhân 72 luồng) | GTX 1660 Super 6GB', 21680000, 22820000, '1f9a6107-ca3b-4376-9439-0b174ec9e125_vh-dualxeon-e5-2699v3-gtx1660s.jpg',
 N'2x Intel Xeon E5-2699 V3 (2.3-3.6GHz, tổng 36 nhân 72 luồng)', N'GTX 1660 Super 6GB', N'64GB DDR4 ECC', N'512GB NVMe SSD', N'Nguồn máy chủ 750W', N'Mainboard Dual Socket LGA2011-3 (server)', N'Case Dual CPU Tower/Rack', N'Tản nhiệt khí (2x, kèm CPU)', NULL),
('vh-dualxeon-e5-2696v3-96gb-rtx3060', N'PC Giả Lập Ảo Hóa Dual Xeon E5-2696 V3 (36 nhân 72 luồng) | 96GB RAM | RTX 3060 12GB', 30280000, NULL, 'c314b6dd-ac4b-4f34-b33d-07afa057b0f2_vh-dualxeon-e5-2696v3-96gb-rtx3060.jpg',
 N'2x Intel Xeon E5-2696 V3 (2.3-3.6GHz, tổng 36 nhân 72 luồng)', N'RTX 3060 12GB', N'96GB DDR4 ECC', N'512GB NVMe SSD', N'Nguồn máy chủ 850W', N'Mainboard Dual Socket LGA2011-3 (server)', N'Case Dual CPU Tower/Rack', N'Tản nhiệt khí (2x, kèm CPU)', NULL),
('vh-dualxeon-e5-2696v4-128gbddr4-rtx3060', N'PC Giả Lập Ảo Hóa Dual Xeon E5-2696 V4 (44 nhân 88 luồng) | 128GB DDR4 | RTX 3060 12GB', 31980000, 37700000, '5cfe4f9e-265c-4fd1-ae22-b77fb630cfa4_vh-dualxeon-e5-2696v4-128gbddr4-rtx3060.jpg',
 N'2x Intel Xeon E5-2696 V4 (2.2-3.6GHz, tổng 44 nhân 88 luồng)', N'RTX 3060 12GB', N'128GB DDR4 ECC', N'512GB NVMe SSD', N'Nguồn máy chủ 850W', N'Mainboard Dual Socket LGA2011-3 (server)', N'Case Dual CPU Tower/Rack', N'Tản nhiệt khí (2x, kèm CPU)', NULL),
('vh-dualxeon-e5-2680v4-rtx3060', N'PC Giả Lập Ảo Hóa Dual Xeon E5-2680 V4 (28 nhân 56 luồng) | RTX 3060 12GB', 27280000, NULL, 'a405a6bb-d8eb-4fe0-999f-a3a547d6bbe1_vh-dualxeon-e5-2680v4-rtx3060.jpg',
 N'2x Intel Xeon E5-2680 V4 (2.4-3.3GHz, tổng 28 nhân 56 luồng)', N'RTX 3060 12GB', N'64GB DDR4 ECC', N'512GB NVMe SSD', N'Nguồn máy chủ 750W', N'Mainboard Dual Socket LGA2011-3 (server)', N'Case Dual CPU Tower/Rack', N'Tản nhiệt khí (2x, kèm CPU)', NULL),
('vh-dualxeon-e5-2680v4-gtx1660s', N'PC Giả Lập Ảo Hóa Dual Xeon E5-2680 V4 (28 nhân 56 luồng) | GTX 1660 Super 6GB', 20980000, 23000000, '6851e93e-1afc-429d-b911-2ca1d88b6265_vh-dualxeon-e5-2680v4-gtx1660s.jpg',
 N'2x Intel Xeon E5-2680 V4 (2.4-3.3GHz, tổng 28 nhân 56 luồng)', N'GTX 1660 Super 6GB', N'64GB DDR4 ECC', N'512GB NVMe SSD', N'Nguồn máy chủ 750W', N'Mainboard Dual Socket LGA2011-3 (server)', N'Case Dual CPU Tower/Rack', N'Tản nhiệt khí (2x, kèm CPU)', NULL),
-- PC kèm màn hình (5)
('pcmon-r5-5500-rtx3050-25inch', N'Full Bộ PC Gaming Kèm Màn Hình AMD Ryzen 5 5500 | RTX 3050 6GB | Màn hình 25 inch', 14980000, 15990000, 'a2f11650-5e03-4b69-9326-e02f70c10580_pcmon-r5-5500-rtx3050-25inch.png',
 N'AMD Ryzen 5 5500 (3.6-4.2GHz, 6 nhân 12 luồng)', N'RTX 3050 6GB', N'16GB DDR4', N'256GB SATA SSD', N'Xigmatek X-Power 450W', N'ASRock A420M-HDV', N'Xigmatek Hermes', N'Tản nhiệt zin theo CPU', N'25 inch FHD 100Hz'),
('pcmon-r5-7500f-rx7600-25inch', N'Full Bộ PC Gaming Kèm Màn Hình AMD Ryzen 5 7500F | RX 7600 8GB | Màn hình 25 inch', 21980000, 24990000, '13b47877-4f0a-41b3-bc17-4f986f00ae1b_pcmon-r5-7500f-rx7600-25inch.png',
 N'AMD Ryzen 5 7500F (3.7-5.0GHz, 6 nhân 12 luồng)', N'RX 7600 8GB', N'16GB DDR5', N'512GB NVMe SSD', N'Xigmatek X-Power II 750W', N'ASRock B650M Pro RS', N'Xigmatek Gengar', N'Tản nhiệt zin theo CPU', N'25 inch FHD 120Hz'),
('pcmon-i5-14400f-rtx5060-25inch', N'Full Bộ PC Gaming Kèm Màn Hình Intel Core i5-14400F | RTX 5060 8GB OC | Màn hình 25 inch', 22980000, 25990000, '953fc1c6-5208-41a8-b9fc-5c34e418da2f_pcmon-i5-14400f-rtx5060-25inch.png',
 N'Intel Core i5-14400F (up to 4.7GHz, 10 nhân 16 luồng)', N'RTX 5060 8GB', N'16GB DDR4', N'512GB NVMe SSD', N'Xigmatek X-Power II 750W', N'ASRock B760M Pro RS', N'Xigmatek Aquarius Plus', N'Tản nhiệt zin theo CPU', N'25 inch FHD 144Hz'),
('pcmon-r7-7800x3d-rtx5060-24inch', N'Full Bộ PC Gaming Kèm Màn Hình AMD Ryzen 7 7800X3D | RTX 5060 8GB OC | Màn hình 24 inch', 30980000, 35990000, '259dfc4e-ea88-419a-be76-c71ff26c33f5_pcmon-r7-7800x3d-rtx5060-24inch.png',
 N'AMD Ryzen 7 7800X3D (4.2-5.0GHz, 8 nhân 16 luồng, 96MB cache)', N'RTX 5060 8GB', N'16GB DDR5', N'512GB NVMe SSD', N'Xigmatek X-Power III 550W', N'Gigabyte B650M Gaming X', N'Xigmatek Aquarius Plus', N'Tản nhiệt zin theo CPU', N'24 inch FHD 165Hz'),
('pcmon-i5-14400f-rtx5070-24inch', N'Full Bộ PC Gaming Kèm Màn Hình Intel Core i5-14400F | RTX 5070 12GB OC | Màn hình 24 inch', 33280000, 35990000, '5e76ed4b-b078-42fe-95df-959524315ca4_pcmon-i5-14400f-rtx5070-24inch.png',
 N'Intel Core i5-14400F (up to 4.7GHz, 10 nhân 16 luồng)', N'RTX 5070 12GB', N'16GB DDR4', N'512GB NVMe SSD', N'Corsair CX650 650W', N'ASRock B760M Pro RS', N'Corsair 4000D Solid', N'Tản nhiệt zin theo CPU', N'24 inch 2K 165Hz');
GO

DECLARE @catId INT = (SELECT id FROM CATEGORY WHERE slug = 'pc-may-tinh-ban');

INSERT INTO PRODUCT (name, slug, category_id, is_active, created_at, warranty_months)
SELECT name, slug, @catId, 1, GETDATE(), 36
FROM #new_pc np
WHERE NOT EXISTS (SELECT 1 FROM PRODUCT p WHERE p.slug COLLATE DATABASE_DEFAULT = np.slug COLLATE DATABASE_DEFAULT);

INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
SELECT p.id, N'SKU-' + UPPER(REPLACE(np.slug, '-', '')), np.price, np.original_price, 10, 1
FROM PRODUCT p
JOIN #new_pc np ON np.slug COLLATE DATABASE_DEFAULT = p.slug COLLATE DATABASE_DEFAULT
WHERE NOT EXISTS (SELECT 1 FROM PRODUCT_VARIANT v WHERE v.product_id = p.id);

INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
SELECT p.id, x.spec_key, x.spec_value, x.sort_order
FROM PRODUCT p
JOIN #new_pc np ON np.slug COLLATE DATABASE_DEFAULT = p.slug COLLATE DATABASE_DEFAULT
CROSS APPLY (VALUES
    (N'CPU', np.cpu, 0),
    (N'Card đồ họa', np.gpu, 1),
    (N'RAM', np.ram, 2),
    (N'Ổ cứng', np.ssd, 3),
    (N'Nguồn', np.nguon, 4),
    (N'Mainboard', np.mainboard, 90),
    (N'Vỏ case', np.vocase, 91),
    (N'Tản nhiệt', np.tannhiet, 92),
    (N'Màn hình', np.manhinh, 95)
) AS x(spec_key, spec_value, sort_order)
WHERE x.spec_value IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM PRODUCT_SPEC sp WHERE sp.product_id = p.id AND sp.spec_key COLLATE DATABASE_DEFAULT = x.spec_key COLLATE DATABASE_DEFAULT);

INSERT INTO PRODUCT_IMAGE (product_id, variant_id, url, is_primary, sort_order)
SELECT p.id, NULL, CONCAT(N'/uploads/products/', np.image_file), 1, 0
FROM PRODUCT p
JOIN #new_pc np ON np.slug COLLATE DATABASE_DEFAULT = p.slug COLLATE DATABASE_DEFAULT
WHERE NOT EXISTS (SELECT 1 FROM PRODUCT_IMAGE pi WHERE pi.product_id = p.id);

DROP TABLE #new_pc;
GO
