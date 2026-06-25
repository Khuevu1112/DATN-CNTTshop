-- ============================================================
--  07_sample_catalog.sql
--  (1) Xoá danh mục Điện thoại + Tablet khỏi DB hiện có
--  (2) Bổ sung vài hãng còn thiếu
--  (3) Thêm ~20 sản phẩm mẫu (kèm 1 biến thể giá + 3 thông số/chip)
--  Chạy an toàn nhiều lần.
-- ============================================================
USE ShopDB;
GO

-- ===== (1) Xoá danh mục Điện thoại + Tablet (và sản phẩm thuộc chúng nếu có) =====
DELETE FROM PRODUCT
WHERE category_id IN (SELECT id FROM CATEGORY WHERE slug IN ('dien-thoai', 'tablet'));
DELETE FROM CATEGORY WHERE slug IN ('dien-thoai', 'tablet');
GO

-- ===== (2) Bổ sung hãng còn thiếu =====
INSERT INTO BRAND (name)
SELECT v.name FROM (VALUES (N'Corsair'), (N'LG'), (N'Keychron'), (N'Logitech')) AS v(name)
WHERE NOT EXISTS (SELECT 1 FROM BRAND b WHERE b.name = v.name);
GO

-- ===== (3a) Thêm sản phẩm =====
INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at)
SELECT d.name, d.slug,
       N'Hàng chính hãng, bảo hành 24–36 tháng, hỗ trợ trả góp 0%, giao toàn quốc.',
       (SELECT id FROM CATEGORY WHERE slug = d.cat),
       (SELECT id FROM BRAND WHERE name = d.brand),
       1, GETDATE()
FROM (VALUES
  (N'Laptop Gaming Asus ROG Strix G16','laptop-asus-rog-strix-g16','laptop',N'ASUS'),
  (N'Laptop MSI Katana 15 B13V','laptop-msi-katana-15','laptop',N'MSI'),
  (N'Laptop Acer Nitro V15','laptop-acer-nitro-v15','laptop',N'ACER'),
  (N'Laptop Dell G15 5530','laptop-dell-g15-5530','laptop',N'Dell'),
  (N'PC Gaming CNTT Titan RTX 4070','pc-cntt-titan-rtx4070','pc-may-tinh-ban',N'Gigabyte'),
  (N'PC Gaming CNTT Spark RTX 4060','pc-cntt-spark-rtx4060','pc-may-tinh-ban',N'Gigabyte'),
  (N'PC Văn Phòng CNTT Office Pro','pc-cntt-office-pro','pc-may-tinh-ban',N'Intel'),
  (N'PC Gaming CNTT Apex RTX 4080 Super','pc-cntt-apex-rtx4080s','pc-may-tinh-ban',N'Gigabyte'),
  (N'CPU AMD Ryzen 7 7800X3D','cpu-amd-ryzen7-7800x3d','linh-kien',N'AMD'),
  (N'CPU Intel Core i5-14400F','cpu-intel-core-i5-14400f','linh-kien',N'Intel'),
  (N'VGA NVIDIA RTX 4070 Ti Super','vga-nvidia-rtx4070ti-super','linh-kien',N'NVIDIA'),
  (N'RAM Corsair Vengeance 32GB DDR5','ram-corsair-vengeance-32gb-ddr5','linh-kien',N'Corsair'),
  (N'SSD Samsung 990 Pro 2TB','ssd-samsung-990-pro-2tb','linh-kien',N'Samsung'),
  (N'Màn hình LG UltraGear 27GR75Q','man-hinh-lg-ultragear-27gr75q','man-hinh',N'LG'),
  (N'Màn hình Samsung Odyssey G6','man-hinh-samsung-odyssey-g6','man-hinh',N'Samsung'),
  (N'Màn hình Asus TUF VG27AQ','man-hinh-asus-tuf-vg27aq','man-hinh',N'ASUS'),
  (N'Bàn phím cơ Keychron Q1 Pro','ban-phim-keychron-q1-pro','ngoai-vi',N'Keychron'),
  (N'Chuột Logitech G Pro X Superlight 2','chuot-logitech-g-pro-x-superlight-2','ngoai-vi',N'Logitech'),
  (N'Tai nghe Logitech G733 Lightspeed','tai-nghe-logitech-g733','phu-kien',N'Logitech'),
  (N'Lót chuột Corsair MM300 Extended','lot-chuot-corsair-mm300-extended','phu-kien',N'Corsair')
) AS d(name, slug, cat, brand)
WHERE NOT EXISTS (SELECT 1 FROM PRODUCT p WHERE p.slug = d.slug);
GO

-- ===== (3b) Biến thể mặc định (giá) =====
INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
SELECT p.id, 'SKU-' + CAST(p.id AS VARCHAR(10)), d.price, NULLIF(d.oldp, 0), d.stock, 1
FROM (VALUES
  ('laptop-asus-rog-strix-g16', 32990000, 35990000, 12),
  ('laptop-msi-katana-15',      24490000, 26990000, 9),
  ('laptop-acer-nitro-v15',     19990000, 0,        15),
  ('laptop-dell-g15-5530',      23490000, 25000000, 7),
  ('pc-cntt-titan-rtx4070',     38500000, 41000000, 6),
  ('pc-cntt-spark-rtx4060',     24900000, 0,        10),
  ('pc-cntt-office-pro',        9990000,  0,        20),
  ('pc-cntt-apex-rtx4080s',     62900000, 67000000, 4),
  ('cpu-amd-ryzen7-7800x3d',    9490000,  10490000, 25),
  ('cpu-intel-core-i5-14400f',  4790000,  0,        30),
  ('vga-nvidia-rtx4070ti-super',22990000, 0,        8),
  ('ram-corsair-vengeance-32gb-ddr5', 2690000, 2990000, 40),
  ('ssd-samsung-990-pro-2tb',   4290000,  0,        35),
  ('man-hinh-lg-ultragear-27gr75q', 7990000, 8990000, 14),
  ('man-hinh-samsung-odyssey-g6',   9490000, 0,      11),
  ('man-hinh-asus-tuf-vg27aq',  6490000,  7200000,  18),
  ('ban-phim-keychron-q1-pro',  3490000,  0,        22),
  ('chuot-logitech-g-pro-x-superlight-2', 2890000, 3190000, 27),
  ('tai-nghe-logitech-g733',    2290000,  2690000,  19),
  ('lot-chuot-corsair-mm300-extended', 390000, 0,   50)
) AS d(slug, price, oldp, stock)
JOIN PRODUCT p ON p.slug = d.slug
WHERE NOT EXISTS (SELECT 1 FROM PRODUCT_VARIANT v WHERE v.product_id = p.id);
GO

-- ===== (3c) Thông số kỹ thuật (3 dòng/sản phẩm — dùng làm chip trên card) =====
INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
SELECT p.id, d.k, d.v, d.so
FROM (VALUES
  ('laptop-asus-rog-strix-g16', N'CPU', N'Intel Core i7-13650HX', 0),
  ('laptop-asus-rog-strix-g16', N'Card đồ họa', N'RTX 4060 8GB', 1),
  ('laptop-asus-rog-strix-g16', N'RAM', N'16GB DDR5', 2),
  ('laptop-msi-katana-15', N'CPU', N'Intel Core i5-13420H', 0),
  ('laptop-msi-katana-15', N'Card đồ họa', N'RTX 4050 6GB', 1),
  ('laptop-msi-katana-15', N'RAM', N'16GB DDR5', 2),
  ('laptop-acer-nitro-v15', N'CPU', N'Intel Core i5-13420H', 0),
  ('laptop-acer-nitro-v15', N'Card đồ họa', N'RTX 3050 6GB', 1),
  ('laptop-acer-nitro-v15', N'RAM', N'8GB DDR5', 2),
  ('laptop-dell-g15-5530', N'CPU', N'Intel Core i7-13650HX', 0),
  ('laptop-dell-g15-5530', N'Card đồ họa', N'RTX 4050 6GB', 1),
  ('laptop-dell-g15-5530', N'RAM', N'16GB DDR5', 2),
  ('pc-cntt-titan-rtx4070', N'CPU', N'Intel Core i5-14400F', 0),
  ('pc-cntt-titan-rtx4070', N'Card đồ họa', N'RTX 4070 12GB', 1),
  ('pc-cntt-titan-rtx4070', N'RAM', N'32GB DDR5', 2),
  ('pc-cntt-spark-rtx4060', N'CPU', N'Intel Core i5-12400F', 0),
  ('pc-cntt-spark-rtx4060', N'Card đồ họa', N'RTX 4060 8GB', 1),
  ('pc-cntt-spark-rtx4060', N'RAM', N'16GB DDR5', 2),
  ('pc-cntt-office-pro', N'CPU', N'Intel Core i3-12100', 0),
  ('pc-cntt-office-pro', N'Card đồ họa', N'Intel UHD 730', 1),
  ('pc-cntt-office-pro', N'RAM', N'16GB DDR4', 2),
  ('pc-cntt-apex-rtx4080s', N'CPU', N'Intel Core i7-14700F', 0),
  ('pc-cntt-apex-rtx4080s', N'Card đồ họa', N'RTX 4080 Super 16GB', 1),
  ('pc-cntt-apex-rtx4080s', N'RAM', N'32GB DDR5', 2),
  ('cpu-amd-ryzen7-7800x3d', N'Nhân / Luồng', N'8 nhân / 16 luồng', 0),
  ('cpu-amd-ryzen7-7800x3d', N'Xung nhịp', N'Tối đa 5.0GHz', 1),
  ('cpu-amd-ryzen7-7800x3d', N'Socket', N'AM5', 2),
  ('cpu-intel-core-i5-14400f', N'Nhân / Luồng', N'10 nhân / 16 luồng', 0),
  ('cpu-intel-core-i5-14400f', N'Xung nhịp', N'Tối đa 4.7GHz', 1),
  ('cpu-intel-core-i5-14400f', N'Socket', N'LGA1700', 2),
  ('vga-nvidia-rtx4070ti-super', N'Bộ nhớ', N'16GB GDDR6X', 0),
  ('vga-nvidia-rtx4070ti-super', N'Xung Boost', N'2610 MHz', 1),
  ('vga-nvidia-rtx4070ti-super', N'TDP', N'285W', 2),
  ('ram-corsair-vengeance-32gb-ddr5', N'Dung lượng', N'32GB (2x16GB)', 0),
  ('ram-corsair-vengeance-32gb-ddr5', N'Bus', N'6000 MHz', 1),
  ('ram-corsair-vengeance-32gb-ddr5', N'Chuẩn', N'DDR5', 2),
  ('ssd-samsung-990-pro-2tb', N'Dung lượng', N'2TB', 0),
  ('ssd-samsung-990-pro-2tb', N'Tốc độ đọc', N'7450 MB/s', 1),
  ('ssd-samsung-990-pro-2tb', N'Chuẩn', N'M.2 NVMe PCIe 4.0', 2),
  ('man-hinh-lg-ultragear-27gr75q', N'Kích thước', N'27" QHD', 0),
  ('man-hinh-lg-ultragear-27gr75q', N'Tần số quét', N'165Hz', 1),
  ('man-hinh-lg-ultragear-27gr75q', N'Tấm nền', N'IPS', 2),
  ('man-hinh-samsung-odyssey-g6', N'Kích thước', N'27" QHD', 0),
  ('man-hinh-samsung-odyssey-g6', N'Tần số quét', N'240Hz', 1),
  ('man-hinh-samsung-odyssey-g6', N'Độ cong', N'1000R', 2),
  ('man-hinh-asus-tuf-vg27aq', N'Kích thước', N'27" QHD', 0),
  ('man-hinh-asus-tuf-vg27aq', N'Tần số quét', N'165Hz', 1),
  ('man-hinh-asus-tuf-vg27aq', N'Tấm nền', N'IPS', 2),
  ('ban-phim-keychron-q1-pro', N'Layout', N'75%', 0),
  ('ban-phim-keychron-q1-pro', N'Kết nối', N'Bluetooth / USB-C', 1),
  ('ban-phim-keychron-q1-pro', N'Switch', N'Gateron Pro', 2),
  ('chuot-logitech-g-pro-x-superlight-2', N'Trọng lượng', N'60g', 0),
  ('chuot-logitech-g-pro-x-superlight-2', N'Cảm biến', N'HERO 2', 1),
  ('chuot-logitech-g-pro-x-superlight-2', N'DPI', N'32000', 2),
  ('tai-nghe-logitech-g733', N'Kết nối', N'Không dây Lightspeed', 0),
  ('tai-nghe-logitech-g733', N'Âm thanh', N'7.1 Surround', 1),
  ('tai-nghe-logitech-g733', N'Đèn', N'RGB Lightsync', 2),
  ('lot-chuot-corsair-mm300-extended', N'Kích thước', N'930 x 300 mm', 0),
  ('lot-chuot-corsair-mm300-extended', N'Bề mặt', N'Vải dệt', 1),
  ('lot-chuot-corsair-mm300-extended', N'Viền', N'May chống sờn', 2)
) AS d(slug, k, v, so)
JOIN PRODUCT p ON p.slug = d.slug
WHERE NOT EXISTS (SELECT 1 FROM PRODUCT_SPEC s WHERE s.product_id = p.id AND s.spec_key = d.k);
GO

PRINT N'✅ Đã xoá Điện thoại/Tablet + thêm ~20 sản phẩm mẫu.';
GO
