-- 55_monitor_real_data.sql
-- Thay tên/giá/thông số/ảnh của 53 sản phẩm màn hình (category man-hinh) bằng 30 model THẬT,
-- khảo sát từ nguyencongpc.vn/man-hinh (phổ thông, 1.57tr-8.4tr) + ttgshop.vn/man-hinh-may-tinh
-- (cao cấp OLED/4K, 7.49tr-45.68tr). Ánh xạ theo thứ hạng giá (mỗi mẫu dùng lại cho ~1-2 sản
-- phẩm). UPDATE tại chỗ (không xóa) để không phá vỡ tham chiếu FK khác (nếu có).
USE ShopDB;
GO

IF OBJECT_ID('tempdb..#mon_templates') IS NOT NULL DROP TABLE #mon_templates;
IF OBJECT_ID('tempdb..#mon_mapping') IS NOT NULL DROP TABLE #mon_mapping;

CREATE TABLE #mon_templates (
    template_id INT PRIMARY KEY,
    name NVARCHAR(300), price DECIMAL(18,2), original_price DECIMAL(18,2), image_file NVARCHAR(300),
    kich_thuoc NVARCHAR(100), tam_nen NVARCHAR(100), do_phan_giai NVARCHAR(100), tan_so_quet NVARCHAR(100), thoi_gian_phan_hoi NVARCHAR(100)
);

INSERT INTO #mon_templates (template_id, name, price, original_price, image_file, kich_thuoc, tam_nen, do_phan_giai, tan_so_quet, thoi_gian_phan_hoi) VALUES
(0, N'Màn hình ViewSonic VA2215-H', 1570000, 1990000, '34e35ace-cf66-43d9-a4be-b993c13ce99c_monitor-viewsonic-va2215h.jpg', N'21.5 inch', N'VA', N'FHD', N'100Hz', N'4ms'),
(1, N'Màn hình VIOX MF2425-V', 1790000, 2590000, 'a42dc902-3ddb-4b8a-9f51-29a88512c304_monitor-viox-mf2425v.jpg', N'23.8 inch', N'IPS', N'FHD', N'100Hz', N'5ms'),
(2, N'Màn hình ViewSonic VA240A-H', 2080000, 2990000, '921a0342-d5de-49ff-984b-f50957117f3b_monitor-viewsonic-va240ah.jpg', N'23.8 inch', N'IPS', N'FHD', N'120Hz', N'1ms'),
(3, N'Màn hình VSP IP2702S', 2090000, 3600000, '5631b135-ddac-4d64-b7c1-735fe21620bc_monitor-vsp-ip2702s.jpg', N'27 inch', N'IPS', N'FHD', N'120Hz', N'1ms'),
(4, N'Màn hình E-DRA EGM27F120S', 2090000, 2690000, '08c363ab-fce5-46ab-9324-bf36c972b873_monitor-edra-egm27f120s.jpg', N'27 inch', N'IPS', N'FHD', N'120Hz', N'1ms'),
(5, N'Màn hình ASUS VA249HG', 2200000, 2990000, '698a5630-88fa-462e-b775-96c88719503d_monitor-asus-va249hg.jpg', N'23.8 inch', N'IPS', N'FHD', N'120Hz', N'1ms'),
(6, N'Màn hình ASUS VA259HGA', 2250000, 3400000, '00f7d153-0025-4e1d-8434-4ef9742fb4f7_monitor-asus-va259hga.jpg', N'24.5 inch', N'IPS', N'FHD', N'120Hz', N'1ms'),
(7, N'Màn hình MSI PRO MP273 E14A', 2680000, 3650000, '29463ad5-d068-4685-b174-6a8aec9761dd_monitor-msi-pro-mp273e14a.jpg', N'27 inch', N'IPS', N'FHD', N'144Hz', N'1ms'),
(8, N'Màn hình Gigabyte GS25F2', 2690000, 4990000, '29dcc5b8-b767-4b33-b432-45fdfe7bc38d_monitor-gigabyte-gs25f2.jpg', N'24.5 inch', N'IPS', N'FHD', N'200Hz', N'1ms'),
(9, N'Màn hình ASUS TUF Gaming VG259Q5A', 2790000, 3999000, 'e3371105-fd60-4ed2-83ef-a660c5be5bce_monitor-asus-tuf-vg259q5a.jpg', N'24.5 inch', N'IPS', N'FHD', N'200Hz', N'0.3ms'),
(10, N'Màn hình Gigabyte GS25F2A', 2850000, 3990000, 'decaedf0-3f7e-47b8-b1f1-9beb0664abb7_monitor-gigabyte-gs25f2a.jpg', N'24.5 inch', N'IPS', N'FHD', N'240Hz', N'1ms'),
(11, N'Màn hình ViewSonic XG2409A', 3250000, 4990000, '5f25c946-a4f4-49e7-ae94-ff2f95fc3aed_monitor-viewsonic-xg2409a.jpg', N'23.8 inch', N'IPS', N'FHD', N'240Hz', N'1ms'),
(12, N'Màn hình ASUS VA27AQ', 3290000, 4990000, '2958e05f-326e-42dc-bc89-a0487b654f79_monitor-asus-va27aq.jpg', N'27 inch', N'IPS', N'2K', N'75Hz', N'1ms'),
(13, N'Màn hình MSI MAG 275CF X24', 3450000, 4800000, '4d8e109d-1268-4c99-a0bb-8b37b9bbd447_monitor-msi-mag275cf-x24.jpg', N'27 inch', N'VA (Cong)', N'FHD', N'240Hz', NULL),
(14, N'Màn hình AOC 27G50Z', 3490000, 4000000, '99dae0e8-6ed8-42d7-802b-904e88f4aa85_monitor-aoc-27g50z.jpg', N'27 inch', N'IPS', N'FHD', N'260Hz', N'0.3ms'),
(15, N'Màn hình LG 27U631A-B', 4380000, 5590000, 'aafeed5f-62d9-4d0f-8548-9096c4590eb7_monitor-lg-27u631ab.jpg', N'27 inch', N'IPS', N'2K', N'100Hz', N'5ms'),
(16, N'Màn hình ViewSonic XG2735-2K', 4750000, 6000000, '1e9e938c-e299-46e4-992f-bbce84f70be3_monitor-viewsonic-xg2735-2k.jpg', N'27 inch', N'IPS', N'2K', N'210Hz', N'1ms'),
(17, N'Màn hình Đồ họa ASUS ProArt PA248QFV', 4990000, 6590000, '74bd76d5-11cd-4c76-a314-356b13ebf1aa_monitor-asus-proart-pa248qfv.jpg', N'24.1 inch', N'IPS', N'WUXGA', N'100Hz', N'5ms'),
(18, N'Màn hình LG UltraGear 27G610A-B', 5190000, 6000000, '7968b049-944b-4ee2-8d36-8e5e51696d66_monitor-lg-ultragear-27g610ab.jpg', N'27 inch', N'IPS', N'QHD', N'200Hz', N'1ms'),
(19, N'Màn hình Dell UltraSharp U2424H', 5200000, 7290000, '0b5b0c9f-a0d7-4736-a870-57bc1b2e900a_monitor-dell-ultrasharp-u2424h.jpg', N'23.8 inch', N'IPS', N'FHD', N'120Hz', N'5ms'),
(20, N'Màn hình MSI MAG 274QF X24', 5350000, 6990000, 'b3e0e332-0ba3-4412-8604-44f3b952ac43_monitor-msi-mag274qf-x24.jpg', N'27 inch', N'Rapid IPS', N'2K (QHD)', N'240Hz', N'0.5ms'),
(21, N'Màn hình AOC Graphic Pro Q27U3CV/74', 5500000, 6890000, '20a17910-edd8-4e49-af4d-1c2db5db22e8_monitor-aoc-graphicpro-q27u3cv.jpg', N'27 inch', N'Nano IPS', N'QHD', N'75Hz', N'4ms'),
(22, N'Màn hình MSI MAG 272URDF E16', 7490000, NULL, '0e387462-7be2-49c1-8812-4c480196d9ff_monitor-msi-mag272urdf-e16.jpg', N'26.5 inch', N'Rapid IPS', N'4K', N'160Hz (FHD 320Hz)', N'0.5ms'),
(23, N'Màn hình Gaming Samsung Odyssey G5 G55C', 7890000, 9490000, '0991e91e-11a9-4dee-a90c-1e1ced4b393e_monitor-samsung-odyssey-g5-g55c.jpg', N'32 inch (Cong)', N'VA', N'2K', N'165Hz', N'1ms'),
(24, N'Màn hình AOC Graphic Pro U27U3CV/74', 7990000, 9500000, 'c0a12224-c8f9-47a1-b875-cc3c3a52ac4d_monitor-aoc-graphicpro-u27u3cv.jpg', N'27 inch', N'Nano IPS', N'4K (UHD)', N'60Hz', N'4ms'),
(25, N'Màn hình Đồ họa ASUS ProArt PA278QGV', 8400000, 10590000, '771c8b3e-eeeb-496b-bd96-67d5d789bb0c_monitor-asus-proart-pa278qgv.jpg', N'27 inch', N'IPS', N'2K', N'120Hz', N'5ms'),
(26, N'Màn hình MSI MAG 272QP QD-OLED X24', 13589000, NULL, 'ce1212b5-196b-4243-9588-4be9fd187dc5_monitor-msi-mag272qp-qdoled.jpg', N'26.5 inch', N'QD-OLED', N'2K (QHD)', N'240Hz', N'0.03ms'),
(27, N'Màn hình Gaming ASUS ROG Strix OLED XG27AQDMG', 14990000, NULL, '54de008a-6086-429a-bbe2-c15bfc4db6ad_monitor-asus-rogstrix-xg27aqdmg.jpg', N'27 inch', N'OLED', N'QHD', N'240Hz', NULL),
(28, N'Màn hình Gaming ASUS ROG Swift OLED PG27UCDM', 33980000, NULL, 'ed0b2fa2-08dc-4e4d-b41f-985ee6f66ae7_monitor-asus-rogswift-pg27ucdm.jpg', N'26.5 inch', N'OLED', N'4K', N'240Hz', N'0.03ms'),
(29, N'Màn hình Cong Gaming ASUS ROG Swift OLED PG39WCDM', 45680000, NULL, 'a87cb308-59fe-476c-930d-5b6e610a30b5_monitor-asus-rogswift-pg39wcdm.jpg', N'39 inch (Cong)', N'OLED', N'WQHD', N'240Hz', N'0.03ms');
GO

CREATE TABLE #mon_mapping (product_id INT PRIMARY KEY, template_id INT);
INSERT INTO #mon_mapping (product_id, template_id) VALUES
(602,0),(603,0),
(259,1),(261,1),
(623,2),(601,2),
(260,3),(68,3),
(624,4),
(64,5),(604,5),
(605,6),(262,6),
(69,7),(263,7),
(265,8),
(264,9),(65,9),
(625,10),(266,10),
(606,11),(267,11),
(609,12),
(616,13),(31,13),
(13,14),(608,14),
(268,15),(607,15),
(610,16),(29,16),
(66,17),
(70,18),(30,18),
(611,19),(269,19),
(612,20),(620,20),
(618,21),
(270,22),(272,22),
(619,23),(271,23),
(621,24),(617,24),
(614,25),
(622,26),(273,26),
(613,27),(626,27),
(67,28),(71,28),
(615,29);
GO

UPDATE p SET p.name = t.name
FROM PRODUCT p JOIN #mon_mapping m ON m.product_id = p.id JOIN #mon_templates t ON t.template_id = m.template_id;

UPDATE v SET v.price = t.price, v.original_price = t.original_price
FROM PRODUCT_VARIANT v
JOIN #mon_mapping m ON m.product_id = v.product_id
JOIN #mon_templates t ON t.template_id = m.template_id
WHERE v.is_default = 1;

DELETE FROM PRODUCT_SPEC WHERE product_id IN (SELECT product_id FROM #mon_mapping);

INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
SELECT m.product_id, x.spec_key, x.spec_value, x.sort_order
FROM #mon_mapping m
JOIN #mon_templates t ON t.template_id = m.template_id
CROSS APPLY (VALUES
    (N'Kích thước', t.kich_thuoc, 0),
    (N'Tấm nền', t.tam_nen, 1),
    (N'Độ phân giải', t.do_phan_giai, 2),
    (N'Tần số quét', t.tan_so_quet, 3),
    (N'Thời gian phản hồi', t.thoi_gian_phan_hoi, 4)
) AS x(spec_key, spec_value, sort_order)
WHERE x.spec_value IS NOT NULL;

DELETE FROM PRODUCT_IMAGE WHERE product_id IN (SELECT product_id FROM #mon_mapping);

INSERT INTO PRODUCT_IMAGE (product_id, variant_id, url, is_primary, sort_order)
SELECT m.product_id, NULL, CONCAT(N'/uploads/products/', t.image_file), 1, 0
FROM #mon_mapping m JOIN #mon_templates t ON t.template_id = m.template_id;

DROP TABLE #mon_templates;
DROP TABLE #mon_mapping;
GO
