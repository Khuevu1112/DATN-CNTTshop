-- 57_missing_pc_components.sql
-- 69 sản phẩm PC (51/52) dùng nhiều linh kiện (CPU/GPU/Mainboard/RAM/SSD/Nguồn/Vỏ case/Tản
-- nhiệt) hoàn toàn chưa có trong catalog linh kiện rời (cpu/gpu/mainboard/ram/ssd/psu/
-- case-may-tinh/tan-nhiet-cpu) — chủ yếu RTX 50-series/RX 9000-series, chipset X870/Z890, và
-- brand SSTC (dùng trong build văn phòng) hoàn toàn vắng mặt. File này bổ sung 86 sản phẩm còn
-- thiếu (đối chiếu tên chính xác từ PRODUCT_SPEC của 69 PC), theo đúng convention hiện có
-- (không có PRODUCT_SPEC riêng — thông số nằm trong tên; ảnh placehold.co như toàn bộ linh kiện
-- khác). Giá tham khảo mức thị trường thực tế theo từng model.
USE ShopDB;
GO

IF OBJECT_ID('tempdb..#new_components') IS NOT NULL DROP TABLE #new_components;
CREATE TABLE #new_components (
    category_slug NVARCHAR(50), name NVARCHAR(300), slug NVARCHAR(300), price DECIMAL(18,2), image_text NVARCHAR(100)
);

INSERT INTO #new_components (category_slug, name, slug, price, image_text) VALUES
-- CPU (10)
('cpu', N'CPU AMD Ryzen 3 3200G', 'cpu-amd-ryzen-3-3200g', 2190000, 'AMD+Ryzen+3+3200G'),
('cpu', N'CPU AMD Ryzen 5 3400G', 'cpu-amd-ryzen-5-3400g', 2890000, 'AMD+Ryzen+5+3400G'),
('cpu', N'CPU AMD Ryzen 5 5500GT', 'cpu-amd-ryzen-5-5500gt', 2690000, 'AMD+Ryzen+5+5500GT'),
('cpu', N'CPU AMD Ryzen 7 9800X3D', 'cpu-amd-ryzen-7-9800x3d', 11990000, 'AMD+Ryzen+7+9800X3D'),
('cpu', N'CPU Intel Core i3-10105', 'cpu-intel-i3-10105', 1890000, 'Intel+Core+i3-10105'),
('cpu', N'CPU Intel Core i5-10400', 'cpu-intel-i5-10400', 2690000, 'Intel+Core+i5-10400'),
('cpu', N'CPU Intel Core i5-14400', 'cpu-intel-i5-14400', 4590000, 'Intel+Core+i5-14400'),
('cpu', N'CPU Intel Core i5-14600KF', 'cpu-intel-i5-14600kf', 7490000, 'Intel+Core+i5-14600KF'),
('cpu', N'CPU Intel Core Ultra 9 285K', 'cpu-intel-ultra9-285k', 16990000, 'Intel+Core+Ultra+9+285K'),
('cpu', N'CPU Intel Pentium Gold G6405', 'cpu-intel-pentium-gold-g6405', 1390000, 'Pentium+Gold+G6405'),
-- GPU (13)
('gpu', N'Card đồ họa ASUS Dual Radeon RX 9070 XT OC 16GB', 'gpu-asus-dual-rx9070xt-oc-16gb', 16990000, 'RX+9070+XT'),
('gpu', N'Card đồ họa ASUS Dual RTX 5060 Ti 16GB GDDR7 OC', 'gpu-asus-dual-rtx5060ti-16gb-oc', 11990000, 'RTX+5060+Ti+16GB'),
('gpu', N'Card đồ họa ASUS ROG Astral RTX 5080 16GB GDDR7 OC', 'gpu-asus-rog-astral-rtx5080-16gb', 38990000, 'RTX+5080'),
('gpu', N'Card đồ họa Colorful iGame RTX 5070 Ti Ultra W OC 16GB', 'gpu-colorful-igame-rtx5070ti-ultraw-16gb', 22990000, 'RTX+5070+Ti'),
('gpu', N'Card đồ họa Colorful RTX 5060 Ti 8GB', 'gpu-colorful-rtx5060ti-8gb', 9990000, 'RTX+5060+Ti+8GB'),
('gpu', N'Card đồ họa Gigabyte RTX 5070 GAMING OC 12GB', 'gpu-gigabyte-rtx5070-gaming-oc-12gb', 15990000, 'RTX+5070'),
('gpu', N'Card đồ họa Gigabyte RTX 5050 WINDFORCE OC 8GB', 'gpu-gigabyte-rtx5050-windforce-oc-8gb', 6990000, 'RTX+5050'),
('gpu', N'Card đồ họa MSI RTX 5060 8GB Shadow 2X OC', 'gpu-msi-rtx5060-8gb-shadow2x-oc', 8290000, 'RTX+5060+8GB'),
('gpu', N'Card đồ họa MSI RTX 5060 Ti 8GB Shadow 2X OC Plus', 'gpu-msi-rtx5060ti-8gb-shadow2x-ocplus', 10290000, 'RTX+5060+Ti+8GB'),
('gpu', N'Card đồ họa PowerColor Reaper Radeon RX 9060 XT 16GB', 'gpu-powercolor-reaper-rx9060xt-16gb', 9690000, 'RX+9060+XT'),
('gpu', N'Card đồ họa ZOTAC GAMING RTX 5070 SOLID 12GB', 'gpu-zotac-gaming-rtx5070-solid-12gb', 14990000, 'RTX+5070+SOLID'),
('gpu', N'Card đồ họa ZOTAC GAMING SOLID OC RTX 5070 12GB', 'gpu-zotac-gaming-solidoc-rtx5070-12gb', 15290000, 'RTX+5070+SOLID+OC'),
('gpu', N'Card đồ họa Zotac SOLID OC RTX 5070 12GB GDDR7', 'gpu-zotac-solidoc-rtx5070-gddr7', 14890000, 'RTX+5070+GDDR7'),
-- Mainboard (16)
('mainboard', N'Mainboard Asrock B760M Pro RS/D4 WIFI', 'mainboard-asrock-b760m-pro-rs-d4-wifi', 2890000, 'ASRock+B760M+Pro+RS'),
('mainboard', N'Mainboard ASRock B760M-HDV/M.2 D4', 'mainboard-asrock-b760m-hdv-m2-d4', 2190000, 'ASRock+B760M-HDV'),
('mainboard', N'Mainboard Asrock Z890 Steel Legend WiFi DDR5', 'mainboard-asrock-z890-steel-legend-wifi', 6990000, 'ASRock+Z890+Steel+Legend'),
('mainboard', N'Mainboard ASUS B650M AYW WIFI DDR5', 'mainboard-asus-b650m-ayw-wifi', 3290000, 'ASUS+B650M+AYW'),
('mainboard', N'Mainboard ASUS B650M-E TUF GAMING DDR5', 'mainboard-asus-b650m-e-tuf-gaming', 3990000, 'ASUS+B650M-E+TUF'),
('mainboard', N'Mainboard ASUS B760M-F PRIME DDR4', 'mainboard-asus-b760m-f-prime-ddr4', 2690000, 'ASUS+B760M-F+PRIME'),
('mainboard', N'Mainboard ASUS PRIME A620M-E DDR5', 'mainboard-asus-prime-a620m-e-ddr5', 2490000, 'ASUS+PRIME+A620M-E'),
('mainboard', N'Mainboard Asus Prime B760M-A WIFI DDR4', 'mainboard-asus-prime-b760m-a-wifi', 2890000, 'ASUS+PRIME+B760M-A'),
('mainboard', N'Mainboard ASUS PRIME X870-P-CSM', 'mainboard-asus-prime-x870-p-csm', 5990000, 'ASUS+PRIME+X870-P'),
('mainboard', N'Mainboard ASUS ROG STRIX X870E-H Gaming WiFi7', 'mainboard-asus-rog-strix-x870e-h-wifi7', 9990000, 'ROG+STRIX+X870E-H'),
('mainboard', N'Mainboard ASUS TUF Gaming X870-PLUS WIFI', 'mainboard-asus-tuf-gaming-x870-plus-wifi', 6490000, 'TUF+GAMING+X870-PLUS'),
('mainboard', N'Mainboard MSI B760M GAMING PLUS WIFI DDR4', 'mainboard-msi-b760m-gaming-plus-wifi', 2990000, 'MSI+B760M+GAMING+PLUS'),
('mainboard', N'Mainboard MSI MAG Z790 TOMAHAWK WIFI', 'mainboard-msi-mag-z790-tomahawk-wifi', 6990000, 'MSI+Z790+TOMAHAWK'),
('mainboard', N'Mainboard SSTC A520MHP AM4 2.0', 'mainboard-sstc-a520mhp-am4-2', 990000, 'SSTC+A520MHP'),
('mainboard', N'Mainboard SSTC H510M-HD', 'mainboard-sstc-h510m-hd', 1090000, 'SSTC+H510M-HD'),
('mainboard', N'Mainboard SSTC H610M-HDV DDR4', 'mainboard-sstc-h610m-hdv-ddr4', 1290000, 'SSTC+H610M-HDV'),
-- RAM (6)
('ram', N'RAM Apacer NOX 16GB DDR5 6000MHz', 'ram-apacer-nox-16gb-ddr5-6000mhz', 1290000, 'Apacer+NOX+16GB'),
('ram', N'RAM G.Skill Ripjaws M5 RGB 32GB DDR5 6000MHz', 'ram-gskill-ripjaws-m5-rgb-32gb-ddr5', 2890000, 'GSkill+Ripjaws+M5'),
('ram', N'RAM G.Skill Trident Z5 RGB 64GB DDR5 White', 'ram-gskill-tridentz5-rgb-64gb-white', 6990000, 'Trident+Z5+64GB'),
('ram', N'RAM Patriot Signature Premium 16GB DDR4 3200MHz', 'ram-patriot-signature-premium-16gb-ddr4', 690000, 'Patriot+Signature+16GB'),
('ram', N'RAM SSTC 8GB DDR4 3200MHz', 'ram-sstc-8gb-ddr4-3200mhz', 390000, 'SSTC+8GB+DDR4'),
('ram', N'RAM TeamGroup Elite Plus 16GB DDR4 3200MHz', 'ram-teamgroup-elite-plus-16gb-ddr4', 690000, 'TeamGroup+Elite+Plus'),
-- SSD (8)
('ssd', N'SSD AGI AI298 512GB NVMe PCIe Gen3', 'ssd-agi-ai298-512gb-nvme-gen3', 690000, 'AGI+AI298+512GB'),
('ssd', N'SSD HIKSEMI WAVE 512GB M.2 NVMe Gen3', 'ssd-hiksemi-wave-512gb-nvme-gen3', 750000, 'HIKSEMI+WAVE+512GB'),
('ssd', N'SSD Kingston SNV3S 1TB NVMe Gen4', 'ssd-kingston-snv3s-1tb-gen4', 1290000, 'Kingston+SNV3S+1TB'),
('ssd', N'SSD Kingston SNV3S 500GB NVMe Gen4', 'ssd-kingston-snv3s-500gb-gen4', 790000, 'Kingston+SNV3S+500GB'),
('ssd', N'SSD Lexar NQ780 1TB NVMe Gen4', 'ssd-lexar-nq780-1tb-gen4', 1390000, 'Lexar+NQ780+1TB'),
('ssd', N'SSD Patriot P410 1TB NVMe Gen4', 'ssd-patriot-p410-1tb-gen4', 1290000, 'Patriot+P410+1TB'),
('ssd', N'SSD Samsung 990 EVO Plus 1TB NVMe Gen4', 'ssd-samsung-990-evo-plus-1tb', 2190000, 'Samsung+990+EVO+Plus'),
('ssd', N'SSD SSTC Megamouth 256GB SATA', 'ssd-sstc-megamouth-256gb-sata', 350000, 'SSTC+Megamouth+256GB'),
-- PSU (11)
('psu', N'Nguồn ANTEC GOLD Plus G850 850W', 'psu-antec-gold-plus-g850-850w', 2690000, 'ANTEC+G850+850W'),
('psu', N'Nguồn ASUS PRIME 650B 650W 80+ Bronze', 'psu-asus-prime-650b-650w', 1290000, 'ASUS+PRIME+650B'),
('psu', N'Nguồn ASUS ROG Thor 1200W Platinum III', 'psu-asus-rog-thor-1200w-platinum3', 8990000, 'ROG+Thor+1200W'),
('psu', N'Nguồn Corsair RM850e 850W 80+ Gold', 'psu-corsair-rm850e-850w', 3290000, 'Corsair+RM850e'),
('psu', N'Nguồn FSP Hydro PTM X Pro 1200W 80+ Platinum', 'psu-fsp-hydro-ptmx-pro-1200w', 6990000, 'FSP+Hydro+PTM+X+Pro'),
('psu', N'Nguồn Gamdias AURA GP650 650W', 'psu-gamdias-aura-gp650-650w', 990000, 'Gamdias+AURA+GP650'),
('psu', N'Nguồn GIGABYTE GP-P750BS 750W 80+ Bronze', 'psu-gigabyte-gp-p750bs-750w', 1690000, 'GIGABYTE+GP-P750BS'),
('psu', N'Nguồn MIK SPOWER C650B 650W 80+ Bronze', 'psu-mik-spower-c650b-650w', 890000, 'MIK+SPOWER+C650B'),
('psu', N'Nguồn MSI MAG A650BNL 650W 80+ Bronze', 'psu-msi-mag-a650bnl-650w', 1390000, 'MSI+A650BNL'),
('psu', N'Nguồn MSI MAG A750BN PCIe5 750W 80+ Bronze', 'psu-msi-mag-a750bn-pcie5-750w', 1890000, 'MSI+A750BN+PCIe5'),
('psu', N'Nguồn SSTC 550F 550W', 'psu-sstc-550f-550w', 650000, 'SSTC+550F'),
-- Case (10)
('case-may-tinh', N'Vỏ case AIGO Q1721', 'case-aigo-q1721', 490000, 'AIGO+Q1721'),
('case-may-tinh', N'Vỏ case ASUS ROG Strix Helios II', 'case-asus-rog-strix-helios-2', 8990000, 'ROG+Strix+Helios+II'),
('case-may-tinh', N'Vỏ case DarkFlash DY470 Black', 'case-darkflash-dy470-black', 1290000, 'DarkFlash+DY470'),
('case-may-tinh', N'Vỏ case Gamdias Aura GC2 Elite ARGB', 'case-gamdias-aura-gc2-elite-argb', 1590000, 'Gamdias+GC2+Elite'),
('case-may-tinh', N'Vỏ case Gamdias GC10M V2 ARGB', 'case-gamdias-gc10m-v2-argb', 990000, 'Gamdias+GC10M+V2'),
('case-may-tinh', N'Vỏ case Lian Li O11 VISION Compact White', 'case-lianli-o11-vision-compact-white', 4990000, 'Lian+Li+O11+VISION'),
('case-may-tinh', N'Vỏ case Ocypus Gamma C52 Black', 'case-ocypus-gamma-c52-black', 690000, 'Ocypus+Gamma+C52'),
('case-may-tinh', N'Vỏ case XIGMATEK AQUA ML BLACK', 'case-xigmatek-aqua-ml-black', 890000, 'XIGMATEK+AQUA+ML'),
('case-may-tinh', N'Vỏ case Xigmatek BLAST M', 'case-xigmatek-blast-m', 790000, 'Xigmatek+BLAST+M'),
('case-may-tinh', N'Vỏ case Xigmatek Cubi M Black EN42775', 'case-xigmatek-cubi-m-black', 1190000, 'Xigmatek+Cubi+M'),
-- Cooler (12)
('tan-nhiet-cpu', N'Tản nhiệt ASUS PRIME LC 360 LCD ARGB', 'cooler-asus-prime-lc360-lcd-argb', 3290000, 'ASUS+PRIME+LC360'),
('tan-nhiet-cpu', N'Tản nhiệt ASUS ROG RYUO IV 360 ARGB', 'cooler-asus-rog-ryuo4-360-argb', 5990000, 'ROG+RYUO+IV+360'),
('tan-nhiet-cpu', N'Tản nhiệt Gamdias BOREAS M2-51D', 'cooler-gamdias-boreas-m2-51d', 890000, 'Gamdias+BOREAS+M2-51D'),
('tan-nhiet-cpu', N'Tản nhiệt ID-Cooling FROZN A620 Pro SE', 'cooler-idcooling-frozn-a620-pro-se', 990000, 'ID-COOLING+FROZN+A620'),
('tan-nhiet-cpu', N'Tản nhiệt ID-Cooling FROZN A620 Pro SE ARGB', 'cooler-idcooling-frozn-a620-pro-se-argb', 1190000, 'ID-COOLING+FROZN+A620+ARGB'),
('tan-nhiet-cpu', N'Tản nhiệt JONSBO CR-1000 EVO BLACK', 'cooler-jonsbo-cr1000-evo-black', 590000, 'JONSBO+CR-1000+EVO'),
('tan-nhiet-cpu', N'Tản nhiệt JONSBO CR-1000 EVO BLACK RGB', 'cooler-jonsbo-cr1000-evo-black-rgb', 690000, 'JONSBO+CR-1000+RGB'),
('tan-nhiet-cpu', N'Tản nhiệt Jonsbo CR-1200', 'cooler-jonsbo-cr1200', 350000, 'Jonsbo+CR-1200'),
('tan-nhiet-cpu', N'Tản nhiệt Jungle Leopard Chill Arc 360 AIO', 'cooler-jungle-leopard-chillarc-360', 1890000, 'Chill+Arc+360'),
('tan-nhiet-cpu', N'Tản nhiệt Thermalright Peerless Assassin 120 ARGB Black', 'cooler-thermalright-peerless-assassin120-argb', 690000, 'Peerless+Assassin+120'),
('tan-nhiet-cpu', N'Tản nhiệt Thermalright Peerless Assassin 120 SE ARGB', 'cooler-thermalright-peerless-assassin120-se-argb', 590000, 'Peerless+Assassin+120+SE'),
('tan-nhiet-cpu', N'Tản nhiệt Thermaltake MINECUBE 360 Ultra ARGB', 'cooler-thermaltake-minecube-360-ultra-argb', 3990000, 'MINECUBE+360+Ultra');
GO

INSERT INTO PRODUCT (name, slug, category_id, is_active, created_at, warranty_months)
SELECT nc.name, nc.slug, c.id, 1, GETDATE(), 36
FROM #new_components nc
JOIN CATEGORY c ON c.slug COLLATE DATABASE_DEFAULT = nc.category_slug COLLATE DATABASE_DEFAULT
WHERE NOT EXISTS (SELECT 1 FROM PRODUCT p WHERE p.slug COLLATE DATABASE_DEFAULT = nc.slug COLLATE DATABASE_DEFAULT);

INSERT INTO PRODUCT_VARIANT (product_id, sku, price, stock, is_default)
SELECT p.id, N'SKU-' + UPPER(REPLACE(nc.slug, '-', '')), nc.price, 20, 1
FROM PRODUCT p
JOIN #new_components nc ON nc.slug COLLATE DATABASE_DEFAULT = p.slug COLLATE DATABASE_DEFAULT
WHERE NOT EXISTS (SELECT 1 FROM PRODUCT_VARIANT v WHERE v.product_id = p.id);

INSERT INTO PRODUCT_IMAGE (product_id, variant_id, url, is_primary, sort_order)
SELECT p.id, NULL, N'https://placehold.co/400x400?text=' + nc.image_text, 1, 0
FROM PRODUCT p
JOIN #new_components nc ON nc.slug COLLATE DATABASE_DEFAULT = p.slug COLLATE DATABASE_DEFAULT
WHERE NOT EXISTS (SELECT 1 FROM PRODUCT_IMAGE pi WHERE pi.product_id = p.id);

DROP TABLE #new_components;
GO
