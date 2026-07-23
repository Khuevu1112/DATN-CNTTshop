-- 53_laptop_real_images.sql
-- Thay ảnh placeholder (placehold.co) của 64/86 sản phẩm Laptop bằng ảnh thật, khớp theo TÊN
-- sản phẩm hiện có (tên/specs Laptop giữ nguyên — chỉ đổi ảnh), lấy từ cellphones.com.vn (đã tải
-- về uploads/products/). 22 sản phẩm không có mẫu thật đủ tin cậy trong catalog hiện tại của
-- cellphones.com.vn/ttgshop.vn (VD Dell XPS, Alienware, ROG Strix, MSI Titan, ThinkBook,
-- ExpertBook, ProBook, EliteBook — dòng đã ngừng bán hoặc chưa tìm thấy ảnh khớp đủ tin cậy) vẫn
-- giữ ảnh cũ, không đụng tới. Nhiều sản phẩm dùng chung 1 ảnh thật (cùng dòng/model) vì nhiều
-- SKU trong 86 sản phẩm cũ chỉ khác cấu hình chứ không khác dáng máy.
USE ShopDB;
GO

IF OBJECT_ID('tempdb..#laptop_images') IS NOT NULL DROP TABLE #laptop_images;
CREATE TABLE #laptop_images (product_id INT PRIMARY KEY, image_file NVARCHAR(300));

INSERT INTO #laptop_images (product_id, image_file) VALUES
(727, '5d8ef2f4-80ba-4b37-9695-71b03b2cec5b_laptop-asus-vivobook14-x1404va.png'),
(705, '123cfa95-e406-4c03-9a13-5f51972b1f76_laptop-asus-vivobook16-x1607ca.png'),
(711, 'bf389f97-00f7-4848-8d16-f6b9d9cd6244_laptop-dell-vostro-3530.png'),
(328, 'bf389f97-00f7-4848-8d16-f6b9d9cd6244_laptop-dell-vostro-3530.png'),
(729, '70de3ba5-ac0e-4915-bdaf-25056d31e806_laptop-dell-inspiron15-3530.png'),
(46,  '70de3ba5-ac0e-4915-bdaf-25056d31e806_laptop-dell-inspiron15-3530.png'),
(708, 'd5855f5f-67f0-4a34-bafc-0a68a30b92b7_laptop-dell-latitude-3450.png'),
(704, '777b0174-855c-4516-a405-fe86fb96f002_laptop-acer-swift14-ai.png'),
(689, 'aee747e9-cf6a-4998-baa0-6942dbb6ceff_laptop-asus-tufgaming-a15-fa506.png'),
(53,  'aee747e9-cf6a-4998-baa0-6942dbb6ceff_laptop-asus-tufgaming-a15-fa506.png'),
(693, '8ba66c22-8501-4d1b-8aa9-46f126c02fb7_laptop-hp-victus15-fa2451tx.png'),
(311, '8ba66c22-8501-4d1b-8aa9-46f126c02fb7_laptop-hp-victus15-fa2451tx.png'),
(725, '57227916-d4aa-47f1-8a60-38fe497c2216_laptop-hp-victus15-fa2731tx.png'),
(54,  '6d1ce9b8-c1ff-4dac-a1ee-5d09610d20ce_laptop-msi-modern14-f13mg.png'),
(314, '8c3a3bd0-7527-42ed-97ea-44b55c1c67ff_laptop-asus-vivobook16x-k3605vc.png'),
(706, '6fc7a062-db26-42bd-9f8c-7b690ff8706e_laptop-hp-omnibook7-14.png'),
(48,  'a48f3ecb-04bc-424d-9c3b-1fc03e0967b3_laptop-hp-250-g9.png'),
(313, '19331953-81c1-4d33-a98f-bf41c6170466_laptop-acer-aspire7-a715.png'),
(307, '72bff9d8-fb15-4e89-8116-eec53679297d_laptop-acer-nitrov15-r1jy.png'),
(44,  '72bff9d8-fb15-4e89-8116-eec53679297d_laptop-acer-nitrov15-r1jy.png'),
(692, 'd0fdf546-27f7-4c00-9d92-e4e85990fa2b_laptop-lenovo-loq15-83s0007a.png'),
(50,  '32cf8e72-51fa-4528-a20a-bcad4e13d61b_laptop-lenovo-ideapadslim5-14imh10.png'),
(308, 'b2108278-a025-4e3a-9b0b-1c4c7acffa6a_laptop-asus-tufgaming-f16-fx607vj.png'),
(691, '1237346e-ee65-4bbd-bc91-38efc8955b22_laptop-msi-cyborg15-a13uc.png'),
(310, '289d9545-3588-415b-9ece-4777e3e4a299_laptop-lenovo-loq15-83s000de.png'),
(6,   'c43f9916-c391-4790-9a23-a5174566f914_laptop-lenovo-loq15-83tn0040.png'),
(18,  '64298df8-26f1-4a5e-8f31-cb6c07236466_laptop-acer-nitrov15-r732.png'),
(690, '9fb66ee8-f5a9-42aa-832b-e1cbe8c34c23_laptop-acer-nitrolite16-nl16.png'),
(712, '6640d007-9be5-472a-901a-cf5dcb8dc078_laptop-lenovo-thinkpad-e14-gen7.png'),
(723, '5bd4d07b-4030-4692-aa00-8056170ba22d_laptop-gigabyte-g6-kf.png'),
(720, '2bf6c126-e57c-4ebb-be1f-b8b509571a32_laptop-lenovo-yogapro7-15iph11.png'),
(331, '2bf6c126-e57c-4ebb-be1f-b8b509571a32_laptop-lenovo-yogapro7-15iph11.png'),
(714, '2bf6c126-e57c-4ebb-be1f-b8b509571a32_laptop-lenovo-yogapro7-15iph11.png'),
(51,  'bb5f7272-1601-47d0-a139-57ba730b52bc_laptop-lenovo-loq15-83sl000l.png'),
(713, '7f2d0d46-75ea-4cfc-9f1a-ce6f7590e003_laptop-asus-zenbook14-ux3405ca.png'),
(330, '7f2d0d46-75ea-4cfc-9f1a-ce6f7590e003_laptop-asus-zenbook14-ux3405ca.png'),
(8,   'c291d16a-f46f-473a-8b5c-c4687f1f3619_laptop-asus-tufgaming-f16-fx607vu.png'),
(5,   '21eece42-5695-4453-9f38-7b01bf7879c7_laptop-msi-thin15-b13uc.png'),
(17,  'f4d02669-74c1-433a-8dc3-4b1d120522d9_laptop-msi-katana15-b13vek.png'),
(722, '2a3c9d94-4606-42a2-9f56-7f323a135501_laptop-asus-tufgaming-f16-fx608jhi.png'),
(316, '643bfec0-c167-4538-a1e1-5a10c5dadfd5_laptop-msi-katana15-b14wek.png'),
(55,  'f5942cd3-b53b-49b1-8708-a612b5a7e369_laptop-apple-macbookair-m4-13.png'),
(721, '24b705a5-40c2-4ecb-bd8d-c15214c78562_laptop-msi-prestige13-ukiyoe.png'),
(318, 'a4f530f3-5449-480e-b1d5-73ad4f192f55_laptop-lenovo-legion5-83q7001j.png'),
(695, '4f38e882-871e-473e-b414-4dda3f1f7176_laptop-asus-rogzephyrus-g14-ga403.png'),
(49,  '4cbe8cc3-65dc-46af-88d6-76ded9249cd6_laptop-hp-omen16-am0176tx.png'),
(319, '4cbe8cc3-65dc-46af-88d6-76ded9249cd6_laptop-hp-omen16-am0176tx.png'),
(699, '4cbe8cc3-65dc-46af-88d6-76ded9249cd6_laptop-hp-omen16-am0176tx.png'),
(315, 'bc713d6c-9f89-469e-b82a-e0be61e4ce58_laptop-asus-rogzephyrus-g14-gu405.png'),
(16,  'bc713d6c-9f89-469e-b82a-e0be61e4ce58_laptop-asus-rogzephyrus-g14-gu405.png'),
(698, 'ca3a8ee9-40f6-4a14-8d40-5b7e1673e187_laptop-lenovo-legion5-83ly00hr.png'),
(717, 'c1d1c5da-ef6b-4b63-bc00-a8018618b9f6_laptop-asus-zenbook-a14-ux3407qa.png'),
(317, 'b6e18192-73b6-40e8-ae3b-44658155d6d8_laptop-acer-predatorheliosneo16-72xe.png'),
(696, '6bea1a9d-9b96-4498-b744-554d7e6113ee_laptop-acer-predatorheliosneo16s-98cx.png'),
(719, '73fa16c0-bc0c-406e-b03c-476fff7c0650_laptop-apple-macbookair-m4-15.png'),
(697, '6947e3d9-697b-42c3-b4d8-04c0a4e9130a_laptop-msi-stealth16-b3wg.png'),
(716, '8e7e6578-47ba-40ab-8b89-f3f725c96c1f_laptop-hp-omnibookxflip14-fk0092.png'),
(323, '59b05e67-c218-4167-bbe1-d8170c766941_laptop-lenovo-legion7-83ky001u.png'),
(718, '902c8dc1-7d0d-48cc-9b88-7653adf3e417_laptop-apple-macbookpro14-m5.png'),
(325, 'dc8518d7-2bf2-4e86-a666-bac29f1856ac_laptop-hp-250-g10-b73tqat.png'),
(726, '81fe4fe8-c9a3-44be-bd55-e66f5c2f6e25_laptop-acer-aspirelite15-r8e6.png'),
(52,  '082ffbdd-1ecf-4d14-96db-c01c94eb567a_laptop-asus-vivobook14-x1404va-eb509.png'),
(45,  'a608a5d0-30d1-4ba0-a318-e182cd1f3567_laptop-acer-aspirelite16-76du.png'),
(326, '273e5f8e-5fc7-4ef4-b50a-83694683286a_laptop-lenovo-ideapadslim3-14arp10.png');
GO

DELETE FROM PRODUCT_IMAGE WHERE product_id IN (SELECT product_id FROM #laptop_images);

INSERT INTO PRODUCT_IMAGE (product_id, variant_id, url, is_primary, sort_order)
SELECT product_id, NULL, CONCAT(N'/uploads/products/', image_file), 1, 0
FROM #laptop_images;

DROP TABLE #laptop_images;
GO
