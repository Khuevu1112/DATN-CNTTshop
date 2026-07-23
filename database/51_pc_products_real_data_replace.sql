-- 51_pc_products_real_data_replace.sql
-- Thay toàn bộ tên/giá/linh kiện (PRODUCT_SPEC)/ảnh của 69 sản phẩm PC dựng sẵn (category
-- pc-may-tinh-ban) bằng 20 cấu hình THẬT, khảo sát từ ttgshop.vn + nguyencongpc.vn (xem hội thoại
-- 2026-07-05). KHÔNG xóa product/variant vì có 70 ORDER_ITEM tham chiếu (FK NO_ACTION sẽ chặn xóa)
-- — chỉ UPDATE tại chỗ để giữ nguyên id/variant/lịch sử đơn hàng. 69 sản phẩm được ánh xạ tới 20
-- mẫu thật theo thứ hạng giá (mỗi mẫu dùng lại cho ~3-4 sản phẩm, xem #mapping bên dưới).
-- Chạy lại nhiều lần an toàn: mỗi bước tự dọn dữ liệu cũ (UPDATE ghi đè, DELETE+INSERT) trước khi ghi mới.
USE ShopDB;
GO

IF OBJECT_ID('tempdb..#templates') IS NOT NULL DROP TABLE #templates;
IF OBJECT_ID('tempdb..#mapping') IS NOT NULL DROP TABLE #mapping;

CREATE TABLE #templates (
    template_id INT PRIMARY KEY,
    name NVARCHAR(300), price DECIMAL(18,2), original_price DECIMAL(18,2), image_file NVARCHAR(300),
    cpu NVARCHAR(500), gpu NVARCHAR(500), ram NVARCHAR(500), ssd NVARCHAR(500),
    nguon NVARCHAR(500), mainboard NVARCHAR(500), vocase NVARCHAR(500), tannhiet NVARCHAR(500)
);

INSERT INTO #templates (template_id, name, price, original_price, image_file, cpu, gpu, ram, ssd, nguon, mainboard, vocase, tannhiet) VALUES
(0, N'PC Gaming AMD Ryzen 5 5500GT | Radeon Vega 7 Onboard', 9300000, NULL,
 '6be23e3c-ddd3-4481-9280-fb6bfe2fd087_bo-pc-gaming-r5-5500gt-vega7.jpg',
 N'AMD Ryzen 5 5500GT (3.6GHz, 6 nhân 12 luồng)', N'AMD Radeon RX Vega 7 (tích hợp)',
 N'Patriot Signature Premium 16GB DDR4 3200MHz', N'Dahua C800A 256GB SATA III',
 N'MIK E350 300W', N'MSI A520M-A PRO', N'LV12 Flow White (3 Fan RGB)', N'Tản nhiệt zin theo CPU'),

(1, N'PC Gaming AMD Ryzen 5 5500 | Colorful RTX 3050 OC 6GB', 17090000, 19090000,
 '9f1e0b86-ca15-4a13-a8b2-1892df04a3d3_bo-pc-gaming-r5-5500-rtx3050.jpg',
 N'AMD Ryzen 5 5500 (3.6-4.2GHz, 6 nhân 12 luồng)', N'Colorful RTX 3050 OC 6GB',
 N'16GB DDR4 3200MHz', N'512GB NVMe SSD',
 N'Segotep SG D600A U5 500W', N'MSI A520M-A PRO', N'MIK LV12 Mini Flow Black', N'ID-Cooling SE-904-XT ARGB'),

(2, N'PC Gaming Intel Core i5-12400F | MSI RTX 3050 Ventus XS OC 6GB', 17280000, 19990000,
 '8bf31bac-6b68-4f71-b614-8650573d7bb1_pc-gaming-ttg-pro-i5-12400f-rtx3050-6gb.jpg',
 N'Intel Core i5-12400F (up to 4.4GHz, 6 nhân 12 luồng)', N'MSI RTX 3050 Ventus XS OC 6GB',
 N'TeamGroup Elite Plus 16GB DDR4 3200MHz', N'HIKSEMI WAVE 512GB M.2 NVMe Gen3',
 N'MSI MAG A550BNL 550W 80+ Bronze', N'ASUS B760M-F PRIME DDR4', N'XIGMATEK AQUA MS BLACK', N'Jonsbo CR-1200 RGB'),

(3, N'PC Gaming AMD Ryzen 5 7500F | MSI RTX 3050 Ventus XS OC 6GB', 19280000, 20990000,
 'dea681c7-db37-4d14-857d-58b3202ac528_pc-amd-gaming-ttg-r5-7500f-rtx3050-6gb.jpg',
 N'AMD Ryzen 5 7500F (3.7-5.0GHz, 6 nhân 12 luồng)', N'MSI RTX 3050 Ventus XS OC 6GB',
 N'Apacer NOX 16GB DDR5 6000MHz', N'HIKSEMI WAVE 512GB M.2 NVMe Gen3',
 N'MSI MAG A550BNL 550W 80+ Bronze', N'MSI A620M-E PRO DDR5', N'XIGMATEK AQUA MS BLACK', N'JONSBO CR-1000 EVO BLACK'),

(4, N'PC Gaming Intel Core i5-13400F | Gigabyte RTX 5050 WINDFORCE OC 8GB', 21390000, NULL,
 '6a173035-af55-406b-a077-f576f770b75a_bo-pc-gaming-i5-13400f-rtx5050.jpg',
 N'Intel Core i5-13400F (up to 4.6GHz, 10 nhân 16 luồng)', N'Gigabyte RTX 5050 WINDFORCE OC 8GB',
 N'16GB DDR4 3200MHz (2x8GB tản nhiệt)', N'500GB NVMe Gen3',
 N'MIK SPOWER C650B 650W 80+ Bronze', N'ASRock B760M-HDV/M.2 D4', N'Xigmatek BLAST M', N'JONSBO CR-1000 EVO BLACK RGB'),

(5, N'PC Gaming Intel Core i5-14400F | MSI RTX 5060 Ti 8GB Shadow 2X OC+', 23980000, 24990000,
 '0c0da37f-caf9-4551-bd9a-a7c7327c9ce7_pc-gaming-ttg-pro-i5-14400f-rtx5060ti-8gb.jpg',
 N'Intel Core i5-14400F (up to 4.7GHz, 10 nhân 16 luồng)', N'MSI RTX 5060 Ti 8GB Shadow 2X OC Plus',
 N'TeamGroup Elite Plus 16GB DDR4 3200MHz', N'HIKSEMI WAVE 512GB M.2 NVMe Gen3',
 N'MSI MAG A650BNL 650W 80+ Bronze', N'ASUS B760M-F PRIME DDR4', N'XIGMATEK AQUA ML BLACK', N'JONSBO CR-1000 EVO BLACK'),

(6, N'PC Gaming Intel Core i5-14400F | Colorful RTX 5060 Ti 8GB', 26990000, 29990000,
 '1fb22376-fa9c-45c6-8afb-f69a76063541_bo-pc-ncpc-nvidia-colorful-i5-14400f-rtx5060ti.jpg',
 N'Intel Core i5-14400F (up to 4.7GHz, 10 nhân 16 luồng)', N'Colorful RTX 5060 Ti 8GB',
 N'Patriot Signature Premium 16GB DDR4 3200MHz', N'AGI AI298 512GB NVMe PCIe Gen3',
 N'Gamdias AURA GP650 650W', N'Asrock B760M Pro RS/D4 WIFI', N'Ocypus Gamma C52 Black', N'Gamdias BOREAS M2-51D (LCD)'),

(7, N'PC Gaming AMD Ryzen 7 7700 | MSI RTX 5060 8GB Shadow 2X OC', 27280000, 28990000,
 '6dd9be0a-9b7f-4f62-ae43-9119b5eac571_pc-amd-gaming-ttg-r7-7700-rtx5060-8gb.jpg',
 N'AMD Ryzen 7 7700 (3.8-5.3GHz, 8 nhân 16 luồng)', N'MSI RTX 5060 8GB Shadow 2X OC',
 N'Apacer NOX 16GB DDR5 6000MHz', N'HIKSEMI WAVE 512GB M.2 NVMe Gen3',
 N'MSI MAG A650BNL 650W 80+ Bronze', N'ASUS B650M AYW WIFI DDR5', N'XIGMATEK AQUA ML BLACK', N'JONSBO CR-1000 EVO BLACK'),

(8, N'PC Gaming Intel Core i5-12400F | ASUS Dual RTX 5060 Ti 16GB OC', 29680000, 30990000,
 'c7c1227f-5167-4fd3-9547-cf55dc6a58c5_pc-gaming-ttg-pro-i5-12400f-rtx5060ti-16gb.jpg',
 N'Intel Core i5-12400F (up to 4.4GHz, 6 nhân 12 luồng)', N'ASUS Dual RTX 5060 Ti 16GB GDDR7 OC',
 N'TeamGroup Elite Plus 16GB DDR4 3200MHz', N'HIKSEMI WAVE 512GB M.2 NVMe Gen3',
 N'ASUS PRIME 650B 650W 80+ Bronze', N'ASUS B760M-K PRIME DDR4', N'XIGMATEK AQUA ML BLACK', N'JONSBO CR-1000 EVO BLACK'),

(9, N'PC Gaming AMD Ryzen 7 7800X3D | MSI RTX 5060 Ti 8GB Shadow 2X OC+', 31680000, 33990000,
 '5abf12b9-6d4a-4d86-93fb-f20bbe2c28bb_pc-amd-gaming-ttg-pro-r7-7800x3d-rtx5060ti-8gb.jpg',
 N'AMD Ryzen 7 7800X3D (4.2-5.0GHz, 8 nhân 16 luồng, 96MB cache)', N'MSI RTX 5060 Ti 8GB Shadow 2X OC Plus',
 N'Apacer NOX 16GB DDR5 6000MHz', N'HIKSEMI WAVE 512GB M.2 NVMe Gen3',
 N'MSI MAG A650BNL 650W 80+ Bronze', N'ASUS B650M-E TUF GAMING DDR5', N'XIGMATEK AQUA ML BLACK', N'Thermalright Peerless Assassin 120 SE ARGB'),

(10, N'PC Gaming AMD Ryzen 5 7500F | ASUS Dual RTX 5060 Ti 16GB OC', 31680000, 33990000,
 'dad6c2ca-8740-4c6e-8d6f-b94e735c13a2_pc-amd-gaming-ttg-r5-7500f-rtx5060ti-16gb.jpg',
 N'AMD Ryzen 5 7500F (3.7-5.0GHz, 6 nhân 12 luồng)', N'ASUS Dual RTX 5060 Ti 16GB GDDR7 OC',
 N'Apacer NOX 16GB DDR5 6000MHz', N'HIKSEMI WAVE 512GB M.2 NVMe Gen3',
 N'ASUS PRIME 650B 650W 80+ Bronze', N'ASUS PRIME A620M-E DDR5', N'XIGMATEK AQUA ML BLACK', N'JONSBO CR-1000 EVO BLACK'),

(11, N'PC Gaming Intel Core i5-14600KF | PowerColor Reaper RX 9060 XT 16GB', 33290000, 35990000,
 '8f212e0f-811b-4812-a9d4-da7a2ae1b67c_bo-pc-gaming-i5-14600kf-rx9060xt.jpg',
 N'Intel Core i5-14600KF (up to 5.3GHz, 14 nhân 20 luồng)', N'PowerColor Reaper Radeon RX 9060 XT 16GB',
 N'Team Elite Plus 16GB DDR4 3200MHz', N'AGI AI298 512GB NVMe PCIe Gen3',
 N'GIGABYTE GP-P750BS 750W 80+ Bronze', N'Asus Prime B760M-A WIFI DDR4', N'Gamdias GC10M V2 ARGB', N'ID-Cooling FROZN A620 Pro SE ARGB'),

(12, N'PC Gaming Intel Core i5-14600KF | ZOTAC RTX 5070 SOLID 12GB', 35980000, 39990000,
 'd9e4d3d1-be60-4106-b6d0-6f8e7a318a33_pc-gaming-ttg-pro-i5-14600kf-rtx5070-12gb.jpg',
 N'Intel Core i5-14600KF (up to 5.3GHz, 14 nhân 20 luồng, 24MB cache)', N'ZOTAC GAMING SOLID OC RTX 5070 12GB',
 N'TeamGroup Elite Plus 16GB DDR4 3200MHz', N'HIKSEMI WAVE 512GB M.2 NVMe Gen3',
 N'MSI MAG A750BN PCIe5 III 750W 80+ Bronze', N'MSI B760M GAMING PLUS WIFI DDR4', N'XIGMATEK AQUA ML BLACK', N'Thermalright Peerless Assassin 120 ARGB Black'),

(13, N'PC Gaming AMD Ryzen 7 7700 | ZOTAC RTX 5070 SOLID 12GB', 36860000, 38990000,
 'de854bf0-38b1-4914-9728-39c58edd39a9_pc-amd-gaming-ultra-ttg-r7-7700-rtx5070-12gb.jpg',
 N'AMD Ryzen 7 7700 (3.8-5.3GHz, 8 nhân 16 luồng)', N'ZOTAC GAMING RTX 5070 SOLID 12GB',
 N'Apacer NOX 16GB DDR5 6000MHz', N'HIKSEMI WAVE 512GB M.2 NVMe Gen3',
 N'MSI MAG A750BN PCIe5 750W 80+ Bronze', N'ASUS B650M AYW WIFI DDR5', N'XIGMATEK AQUA ML BLACK', N'JONSBO CR-1000 EVO BLACK'),

(14, N'PC Gaming AMD Ryzen 7 7800X3D | ZOTAC RTX 5070 SOLID 12GB', 40280000, 44990000,
 'de1bfe54-6c08-48a6-9b83-e72185e8ed7d_pc-amd-gaming-ttg-pro-r7-7800x3d-rtx5070-12gb.jpg',
 N'AMD Ryzen 7 7800X3D (4.2-5.0GHz, 8 nhân 16 luồng, 96MB cache)', N'ZOTAC GAMING RTX 5070 SOLID 12GB',
 N'Apacer NOX 16GB DDR5 6000MHz', N'HIKSEMI WAVE 512GB M.2 NVMe Gen3',
 N'MSI MAG A750BN PCIe5 750W 80+ Bronze', N'ASUS B650M-E TUF GAMING DDR5', N'XIGMATEK AQUA ML BLACK', N'Thermalright Peerless Assassin 120 SE ARGB'),

(15, N'PC Gaming AMD Ryzen 7 7800X3D | ASUS Dual Radeon RX 9070 XT OC 16GB', 49490000, 56990000,
 '624e3cb9-b5d3-4895-bb1c-1695fd6154f2_bo-pc-ncpc-asus-x-amd-r7-7800x3d-rx9070xt.jpg',
 N'AMD Ryzen 7 7800X3D (4.2-5.0GHz, 8 nhân 16 luồng, 96MB cache, PCIe 5.0)', N'ASUS Dual Radeon RX 9070 XT OC 16GB GDDR6',
 N'Kingston FURY Beast 16GB DDR5 6000MHz', N'Kingston SNV3S 500GB NVMe Gen4',
 N'ANTEC GOLD Plus G850 850W', N'ASUS PRIME X870-P-CSM', N'Gamdias Aura GC2 Elite ARGB', N'ID-Cooling FROZN A620 Pro SE'),

(16, N'PC Gaming Intel Core i7-14700F | ZOTAC RTX 5070 SOLID 12GB', 61650000, 69990000,
 'eb157f89-26b1-4d6b-a4b3-48a69cbed54c_bo-pc-gaming-i7-14700f-rtx5070.jpg',
 N'Intel Core i7-14700F (20 nhân 28 luồng, up to 5.4GHz, 33MB cache)', N'Zotac SOLID OC RTX 5070 12GB GDDR7',
 N'Kingston FURY Beast RGB 32GB (2x16GB) DDR5 5600MHz', N'Patriot P410 1TB NVMe Gen4',
 N'Corsair RM850e 850W 80+ Gold', N'MSI MAG Z790 TOMAHAWK WIFI', N'DarkFlash DY470 Black', N'Jungle Leopard Chill Arc 360 AIO (7 fan ARGB)'),

(17, N'PC Gaming AMD Ryzen 7 9800X3D | Gigabyte RTX 5070 GAMING OC 12GB', 63590000, NULL,
 '05283884-6d58-45ef-a05b-28fd9ef8e4f6_bo-pc-gaming-r7-9800x3d-rtx5070.jpg',
 N'AMD Ryzen 7 9800X3D (5.2GHz, 8 nhân Zen 5, 96MB cache)', N'Gigabyte GeForce RTX 5070 GAMING OC 12GB',
 N'G.Skill Ripjaws M5 RGB 32GB (2x16GB) DDR5 6000MHz', N'Kingston SNV3S 1TB NVMe Gen4',
 N'Corsair RM850e 850W 80+ Gold', N'ASUS TUF Gaming X870-PLUS WIFI', N'Xigmatek Cubi M Black EN42775', N'ASUS PRIME LC 360 LCD ARGB (AIO)'),

(18, N'PC Gaming Intel Core Ultra 9 285K | Colorful RTX 5070 Ti Ultra W OC 16GB', 98190000, 109990000,
 '7c686a74-6c32-47da-b07a-b0914292cce8_bo-pc-core-ultra9-285k-rtx5070ti.jpg',
 N'Intel Core Ultra 9 285K (up to 5.7GHz, 24 nhân 24 luồng, Arrow Lake-S)', N'Colorful iGame RTX 5070 Ti Ultra W OC 16GB',
 N'G.Skill Trident Z5 RGB 64GB (2x32GB) DDR5 6000MHz White', N'Samsung 990 EVO Plus 1TB NVMe Gen4',
 N'FSP Hydro PTM X Pro 1200W 80+ Platinum (ATX 3.0)', N'Asrock Z890 Steel Legend WiFi DDR5', N'Lian Li O11 VISION Compact White', N'Thermaltake MINECUBE 360 Ultra ARGB AIO (Snow Edition)'),

(19, N'PC Gaming AMD Ryzen 7 9800X3D Hatsune Miku Special Edition | ASUS ROG Astral RTX 5080 16GB', 135990000, NULL,
 '3a7f44d2-4510-4ab9-86e6-3229f876adb5_bo-pc-gaming-hatsune-miku-r7-9800x3d-rtx5080.jpg',
 N'AMD Ryzen 7 9800X3D (up to 5.2GHz, 8 nhân 16 luồng, 96MB cache)', N'ASUS ROG Astral RTX 5080 16GB GDDR7 OC (Hatsune Miku Edition)',
 N'G.Skill Trident Z5 RGB 32GB (2x16GB) DDR5 6000MHz Black', N'Lexar NQ780 1TB NVMe Gen4',
 N'ASUS ROG Thor 1200W Platinum III (Hatsune Miku Edition)', N'ASUS ROG STRIX X870E-H Gaming WiFi7 (Hatsune Miku Edition)', N'ASUS ROG Strix Helios II (Hatsune Miku Edition)', N'ASUS ROG RYUO IV 360 ARGB AIO (Hatsune Miku Edition)');
GO

-- 69 sản phẩm PC hiện có -> mẫu thật, ánh xạ theo thứ hạng giá (rẻ nhất -> đắt nhất) để giữ
-- phân bố giá catalog hợp lý. Không đổi id/variant — giữ nguyên FK với ORDER_ITEM.
CREATE TABLE #mapping (product_id INT PRIMARY KEY, template_id INT);
INSERT INTO #mapping (product_id, template_id) VALUES
(730,0),(745,0),(759,0),(345,0),
(746,1),(346,1),(755,1),
(22,2),(57,2),(731,2),(747,2),
(61,3),(760,3),(347,3),
(348,4),(748,4),(335,4),(334,4),
(333,5),(732,5),(332,5),
(756,6),(336,6),(733,6),(56,6),
(734,7),(735,7),(60,7),
(337,8),(736,8),(21,8),(757,8),
(339,9),(749,9),(737,9),
(338,10),(341,10),(62,10),
(349,11),(738,11),(340,11),(761,11),
(58,12),(350,12),(739,12),
(10,13),(758,13),(750,13),(20,13),
(740,14),(63,14),(741,14),
(351,15),(4,15),(751,15),(59,15),
(752,16),(762,16),(342,16),
(742,17),(343,17),(743,17),(764,17),
(344,18),(23,18),(753,18),
(744,19),(754,19),(1,19);
GO

-- 1) Tên sản phẩm
UPDATE p SET p.name = t.name
FROM PRODUCT p
JOIN #mapping m ON m.product_id = p.id
JOIN #templates t ON t.template_id = m.template_id;

-- 2) Giá (biến thể mặc định)
UPDATE v SET v.price = t.price, v.original_price = t.original_price
FROM PRODUCT_VARIANT v
JOIN #mapping m ON m.product_id = v.product_id
JOIN #templates t ON t.template_id = m.template_id
WHERE v.is_default = 1;

-- 3) Linh kiện: xóa spec cũ, chèn spec thật (sort_order theo quy ước: CPU=0, Card đồ họa=1,
--    RAM=2, Ổ cứng=3, Nguồn=4, Mainboard=90, Vỏ case=91, Tản nhiệt=92 — xem 46_pc_case_mainboard_cooler.sql)
DELETE FROM PRODUCT_SPEC WHERE product_id IN (SELECT product_id FROM #mapping);

INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
SELECT m.product_id, x.spec_key, x.spec_value, x.sort_order
FROM #mapping m
JOIN #templates t ON t.template_id = m.template_id
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

-- 4) Ảnh: xóa ảnh cũ (nếu có), chèn ảnh thật đã tải về uploads/products/
DELETE FROM PRODUCT_IMAGE WHERE product_id IN (SELECT product_id FROM #mapping);

INSERT INTO PRODUCT_IMAGE (product_id, variant_id, url, is_primary, sort_order)
SELECT m.product_id, NULL, CONCAT(N'/uploads/products/', t.image_file), 1, 0
FROM #mapping m
JOIN #templates t ON t.template_id = m.template_id;

DROP TABLE #templates;
DROP TABLE #mapping;
GO
