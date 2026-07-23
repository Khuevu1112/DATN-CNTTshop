-- 56_peripheral_real_data.sql
-- Thay tên/giá/thông số/ảnh của 65 sản phẩm ngoại vi (category ngoai-vi: chuột/bàn phím/tai
-- nghe/loa/webcam) bằng model THẬT, khảo sát từ nguyencongpc.vn (chuot-mouse/ban-phim/tai-nghe/
-- loa/webcam) + ttgshop.vn/gaming-gear. Ánh xạ round-robin theo loại (không trộn loại — 1 sản
-- phẩm "Chuột" chỉ nhận template Chuột) vì thứ tự giá không quá lệch trong từng loại.
USE ShopDB;
GO

IF OBJECT_ID('tempdb..#periph_templates') IS NOT NULL DROP TABLE #periph_templates;
IF OBJECT_ID('tempdb..#periph_mapping') IS NOT NULL DROP TABLE #periph_mapping;

CREATE TABLE #periph_templates (
    template_id INT PRIMARY KEY,
    name NVARCHAR(300), price DECIMAL(18,2), image_file NVARCHAR(300),
    spec1_key NVARCHAR(50), spec1_value NVARCHAR(200), spec2_key NVARCHAR(50), spec2_value NVARCHAR(200)
);

INSERT INTO #periph_templates (template_id, name, price, image_file, spec1_key, spec1_value, spec2_key, spec2_value) VALUES
-- Mouse t0-t11
(0, N'Chuột Logitech B100', 150000, '51798e83-c313-464e-a227-4f4432776a23_mouse-logitech-b100.jpg', N'DPI', N'1000', N'Kết nối', N'Có dây USB'),
(1, N'Chuột Fuhlen L102 Optical Black', 160000, '9a3f76d4-82f9-434c-a375-74e24557e698_mouse-fuhlen-l102.jpg', N'DPI', N'1000', N'Kết nối', N'Có dây USB'),
(2, N'Chuột máy tính E-DRA EM606', 180000, 'dfd0e329-8191-4029-9fb9-f14312983179_mouse-edra-em606.jpg', N'DPI', N'1200', N'Kết nối', N'Có dây USB'),
(3, N'Chuột không dây Logitech M275', 290000, '7cbfb705-f429-4eea-9138-9e0f4d34ade6_mouse-logitech-m275.jpg', N'DPI', N'1000', N'Kết nối', N'Không dây 2.4GHz'),
(4, N'Chuột Logitech G102 Gen 2 Lightsync', 390000, 'ba2e4f91-f1e7-427b-88ac-541ab88d5a12_mouse-logitech-g102gen2.jpg', N'DPI', N'8000', N'Kết nối', N'Có dây USB'),
(5, N'Chuột ASUS TUF Gaming M3 Gen II', 490000, 'c4392587-1b1a-477a-a2be-7abbebc6006e_mouse-asus-tuf-m3gen2.jpg', N'DPI', N'8000', N'Kết nối', N'Có dây USB'),
(6, N'Chuột DareU LM106G', 320000, 'a54d3383-931b-4bbe-aaba-18d1ef1fbe87_mouse-dareu-lm106g.jpg', N'DPI', N'6400', N'Kết nối', N'Có dây USB'),
(7, N'Chuột Motospeed F333', 250000, '087855c4-3982-4c8e-a4e2-945101383101_mouse-motospeed-f333.jpg', N'DPI', N'3200', N'Kết nối', N'Có dây USB'),
(8, N'Chuột Logitech G304 LIGHTSPEED Wireless', 590000, 'd43b6fe9-8b67-4b2f-90b1-41a7f6f9b296_mouse-logitech-g304.jpg', N'DPI', N'12000', N'Kết nối', N'Không dây 2.4GHz'),
(9, N'Chuột Darmoshark M3 Wireless', 690000, 'a13dea51-fea6-41a9-a08a-5d43bfd3ed13_mouse-darmoshark-m3.jpg', N'DPI', N'26000', N'Kết nối', N'Không dây'),
(10, N'Chuột không dây ATK Blazing Sky X1 SE', 890000, '768575ea-566b-42b4-ae48-47b95e6a1d6f_mouse-atk-blazingskyx1se.jpg', N'DPI', N'26000', N'Kết nối', N'Tri-Mode (Wired/2.4GHz/Bluetooth)'),
(11, N'Chuột Gaming không dây MCHOSE G3 V2', 750000, '48fe0529-0e30-4926-9b66-8eb0b26b01ba_mouse-mchose-g3v2.jpg', N'DPI', N'26000', N'Kết nối', N'Tri-Mode (Wired/2.4GHz/Bluetooth)'),
-- Keyboard t12-t23
(12, N'Bàn phím Logitech K120', 190000, 'f1d20b9d-3a19-454c-9044-8d0b7c50de84_keyboard-logitech-k120.jpg', N'Kết nối', N'Có dây USB', N'Switch', N'Membrane'),
(13, N'Bàn phím máy tính MIK Shiba', 250000, 'e67883aa-8d24-4006-b85f-84a032f58a7e_keyboard-mik-shiba.jpg', N'Kết nối', N'Có dây USB', N'Switch', N'Membrane'),
(14, N'Bàn phím Fuhlen L411 USB Black', 220000, '9fdd97c6-1c20-4c93-887b-a9359b5ff4cb_keyboard-fuhlen-l411.jpg', N'Kết nối', N'Có dây USB', N'Switch', N'Membrane'),
(15, N'Bàn phím Motospeed K103 Black', 350000, '74ea10f6-4de1-4c8e-8293-1c54eef4801f_keyboard-motospeed-k103.jpg', N'Kết nối', N'Có dây USB', N'Switch', N'Giả cơ'),
(16, N'Bàn phím giả cơ E-DRA EK506', 390000, '36bb004f-8ad8-4209-98ef-1969e2a4ce89_keyboard-edra-ek506.jpg', N'Kết nối', N'Có dây USB', N'Switch', N'Giả cơ'),
(17, N'Bàn phím cơ Newmen GM326', 590000, '8ddd7f96-0edb-4f5f-8126-327930c935fb_keyboard-newmen-gm326.jpg', N'Kết nối', N'Có dây USB', N'Switch', N'Red switch'),
(18, N'Bàn phím cơ DareU EK98L (Dream switch)', 890000, '2ed3e504-7651-4b2c-b2ed-8228306c1d53_keyboard-dareu-ek98l.jpg', N'Kết nối', N'Có dây USB', N'Switch', N'Dream switch'),
(19, N'Bàn Phím Cơ ASUS TUF Gaming K3 Gen II', 990000, '08e7d889-f3a3-498c-b6bb-8c31ce93e150_keyboard-asus-tuf-k3gen2.jpg', N'Kết nối', N'Có dây USB', N'Switch', N'Red switch'),
(20, N'Bàn Phím Cơ Machenike K600-B82W', 1190000, '2e559dff-fb96-459c-a9e0-d76a1e3b7a0e_keyboard-machenike-k600b82w.jpg', N'Kết nối', N'Có dây USB', N'Switch', N'Silver switch'),
(21, N'Bàn phím cơ DareU EK75 (Keycap PBT)', 1290000, '48e6d1b0-e87e-47a7-9d06-ab1cba083c91_keyboard-dareu-ek75.jpg', N'Kết nối', N'Có dây USB', N'Switch', N'Dream switch'),
(22, N'Bàn phím cơ Darmoshark Top98 Trio-mode', 1690000, 'e01b1f17-a1a9-49cd-b122-f8447af87b5d_keyboard-darmoshark-top98.jpg', N'Kết nối', N'Tri-Mode (Wired/2.4GHz/Bluetooth)', N'Switch', N'Hotswap'),
(23, N'Bàn phím cơ Gaming không dây FANTECH MK858', 1890000, '341623ab-a227-4b9c-8fcb-9f7a927b92c1_keyboard-fantech-mk858.jpg', N'Kết nối', N'Không dây', N'Switch', N'Kailh Box White (Hotswap)'),
-- Headset t24-t31
(24, N'Tai Nghe Dareu EH416 RGB Black', 350000, '2bbf2688-2b24-4813-9135-cca36f6cc710_headset-dareu-eh416.jpg', N'Driver', N'40mm', N'Kết nối', N'Có dây 3.5mm'),
(25, N'Tai nghe Motospeed GS700', 390000, '68b2b94c-4eeb-49e9-a4bc-cf5210eb734f_headset-motospeed-gs700.jpg', N'Driver', N'40mm', N'Kết nối', N'Có dây USB'),
(26, N'Tai Nghe XIBERIA W3 Bluetooth 5.0', 450000, 'ae531a11-b080-4618-bacc-5abbd3256a9b_headset-xiberia-w3.jpg', N'Driver', N'40mm', N'Kết nối', N'Bluetooth 5.0'),
(27, N'Tai Nghe ASUS TUF Gaming H3 Gun Metal', 690000, '0de0b651-9d64-483b-8d82-5ee45548e3de_headset-asus-tuf-h3.jpg', N'Driver', N'50mm', N'Kết nối', N'Có dây 3.5mm'),
(28, N'Tai nghe HyperX Cloud Stinger 2 Core', 890000, '31938a72-af1c-4037-be77-f298e4999b6b_headset-hyperx-cloudstinger2core.jpg', N'Driver', N'50mm', N'Kết nối', N'Có dây 3.5mm'),
(29, N'Tai nghe Logitech G321 LightSpeed', 990000, 'df086ee5-fe4f-4c4c-bc25-ebb459c07173_headset-logitech-g321lightspeed.jpg', N'Driver', N'40mm', N'Kết nối', N'Không dây LightSpeed'),
(30, N'Tai Nghe Gaming Asus ROG Cetra II Core', 1190000, 'f195b2e6-924f-4572-9ecd-1748e0b959d5_headset-asus-rog-cetraii-core.jpg', N'Driver', N'40mm', N'Kết nối', N'Có dây USB-C'),
(31, N'Tai nghe Gaming Sony INZONE H3', 2490000, '1e03ff04-a2d3-405e-8873-e86c82a58e8b_headset-sony-inzone-h3.jpg', N'Driver', N'40mm', N'Kết nối', N'Có dây 3.5mm'),
-- Speaker t32-t36
(32, N'Loa Microlab M105 2.1', 350000, 'e303d6c1-0807-44f7-bcd8-ba101c82cb65_speaker-microlab-m105.jpg', N'Công suất', N'2.1 kênh', N'Kết nối', N'3.5mm'),
(33, N'Loa Creative Pebble', 490000, 'ac94a727-2512-47e7-b249-8d957740302a_speaker-creative-pebble.jpg', N'Công suất', N'2.0 kênh', N'Kết nối', N'USB'),
(34, N'Loa Creative Pebble Plus', 690000, 'b6d265c9-2ed3-4588-8d05-2d943fbb65e6_speaker-creative-pebbleplus.jpg', N'Công suất', N'2.0 kênh (2.25W RMS)', N'Kết nối', N'USB'),
(35, N'Loa Kiểm Âm Edifier MR4', 1890000, '925011eb-d43e-43b4-a557-a515c2fca9e0_speaker-edifier-mr4.jpg', N'Công suất', N'2.0 kênh (Studio Monitor)', N'Kết nối', N'3.5mm/RCA'),
(36, N'Loa CREATIVE Sound Blaster Katana V2', 6990000, '129e910c-07a0-4243-8a44-185ccb3e421e_speaker-creative-soundblaster-katanav2.jpg', N'Công suất', N'2.1 kênh (Soundbar + Sub)', N'Kết nối', N'Bluetooth/USB/Optical'),
-- Webcam t37-t42
(37, N'Webcam Logitech HD C270', 390000, '8b3125a5-2825-4356-858d-6f72104e2bdb_webcam-logitech-c270.jpg', N'Độ phân giải', N'720p', N'FPS', N'30fps'),
(38, N'Webcam Rapoo C200 HD 720p', 350000, 'dc677bff-88d5-44ff-afdb-2c1d2c0b81de_webcam-rapoo-c200.jpg', N'Độ phân giải', N'720p', N'FPS', N'30fps'),
(39, N'Webcam HIKVISION DS-U02', 450000, '1ab27d05-1b23-4e8c-b683-c63a3f43c98e_webcam-hikvision-dsu02.jpg', N'Độ phân giải', N'1080p', N'FPS', N'30fps'),
(40, N'Webcam Logitech Brio 100 Full HD', 650000, '21fb6f1b-0130-46bb-83a9-df4c1d6b3390_webcam-logitech-brio100.jpg', N'Độ phân giải', N'1080p', N'FPS', N'30fps'),
(41, N'Webcam Logitech C930e', 1890000, '65aabe3a-180c-4e7a-9725-deab85d50ed0_webcam-logitech-c930e.jpg', N'Độ phân giải', N'1080p', N'FPS', N'30fps'),
(42, N'Webcam Logitech BRIO Ultra HD Pro', 2990000, '9c0c2524-78fe-4b93-a94a-674c0f1560d0_webcam-logitech-brio-ultrahd.jpg', N'Độ phân giải', N'4K (Ultra HD)', N'FPS', N'30fps (90fps ở 1080p)');
GO

CREATE TABLE #periph_mapping (product_id INT PRIMARY KEY, template_id INT);
INSERT INTO #periph_mapping (product_id, template_id) VALUES
-- Mouse (round-robin t0..t11)
(33,0),(72,1),(73,2),(74,3),(280,4),(281,5),(282,6),(283,7),(284,8),(634,9),(635,10),(636,11),
(637,0),(638,1),(639,2),(652,3),(654,4),(655,5),(660,6),
-- Keyboard (round-robin t12..t23)
(14,12),(32,13),(75,14),(76,15),(77,16),(274,17),(275,18),(276,19),(277,20),(278,21),(279,22),(627,23),
(628,12),(629,13),(630,14),(631,15),(632,16),(633,17),(651,18),(653,19),(659,20),
-- Speaker (round-robin t32..t36)
(81,32),(291,33),(648,34),(649,35),(650,36),(658,32),
-- Headset (round-robin t24..t31)
(78,24),(79,25),(285,26),(286,27),(287,28),(288,29),(640,30),(641,31),(642,24),(643,25),(644,26),(656,27),
-- Webcam (round-robin t37..t42)
(80,37),(289,38),(290,39),(645,40),(646,41),(647,42),(657,37);
GO

UPDATE p SET p.name = t.name
FROM PRODUCT p JOIN #periph_mapping m ON m.product_id = p.id JOIN #periph_templates t ON t.template_id = m.template_id;

UPDATE v SET v.price = t.price, v.original_price = NULL
FROM PRODUCT_VARIANT v
JOIN #periph_mapping m ON m.product_id = v.product_id
JOIN #periph_templates t ON t.template_id = m.template_id
WHERE v.is_default = 1;

DELETE FROM PRODUCT_SPEC WHERE product_id IN (SELECT product_id FROM #periph_mapping);

INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
SELECT m.product_id, x.spec_key, x.spec_value, x.sort_order
FROM #periph_mapping m
JOIN #periph_templates t ON t.template_id = m.template_id
CROSS APPLY (VALUES (t.spec1_key, t.spec1_value, 0), (t.spec2_key, t.spec2_value, 1)) AS x(spec_key, spec_value, sort_order);

DELETE FROM PRODUCT_IMAGE WHERE product_id IN (SELECT product_id FROM #periph_mapping);

INSERT INTO PRODUCT_IMAGE (product_id, variant_id, url, is_primary, sort_order)
SELECT m.product_id, NULL, CONCAT(N'/uploads/products/', t.image_file), 1, 0
FROM #periph_mapping m JOIN #periph_templates t ON t.template_id = m.template_id;

DROP TABLE #periph_templates;
DROP TABLE #periph_mapping;
GO
