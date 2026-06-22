-- ============================================================
--  DỮ LIỆU MẪU (tùy chọn) — 8 sản phẩm + biến thể + ảnh
--  Chạy SAU 01_DATNCNTTSHOP.sql để trang chủ Vue có hàng hiển thị.
--  Ảnh dùng placehold.co (chỉ để demo).
-- ============================================================
USE ShopDB;
GO

INSERT INTO PRODUCT (name, slug, description, category_id, brand_id, is_active, created_at) VALUES
(N'Laptop ASUS TUF Gaming F15', 'laptop-asus-tuf-f15',
 N'Laptop gaming Intel Core i7, RTX 4060, màn 144Hz.',
 (SELECT id FROM CATEGORY WHERE slug='laptop'), (SELECT id FROM BRAND WHERE name='ASUS'), 1, GETDATE()),

(N'Laptop Dell XPS 13', 'laptop-dell-xps-13',
 N'Laptop văn phòng cao cấp, mỏng nhẹ, màn 13.4 inch.',
 (SELECT id FROM CATEGORY WHERE slug='laptop'), (SELECT id FROM BRAND WHERE name='Dell'), 1, GETDATE()),

(N'PC Gaming MSI Aegis', 'pc-gaming-msi-aegis',
 N'PC gaming dựng sẵn, hiệu năng cao cho game thủ.',
 (SELECT id FROM CATEGORY WHERE slug='pc-may-tinh-ban'), (SELECT id FROM BRAND WHERE name='MSI'), 1, GETDATE()),

(N'CPU Intel Core i5-13400F', 'cpu-intel-i5-13400f',
 N'Vi xử lý 10 nhân, hiệu năng tốt trong tầm giá.',
 (SELECT id FROM CATEGORY WHERE slug='linh-kien'), (SELECT id FROM BRAND WHERE name='Intel'), 1, GETDATE()),

(N'Card màn hình NVIDIA RTX 4060', 'vga-nvidia-rtx-4060',
 N'GPU thế hệ mới, chơi game Full HD mượt mà.',
 (SELECT id FROM CATEGORY WHERE slug='linh-kien'), (SELECT id FROM BRAND WHERE name='NVIDIA'), 1, GETDATE()),

(N'Màn hình Samsung Odyssey 27"', 'man-hinh-samsung-odyssey-27',
 N'Màn cong 27 inch, 165Hz, tấm nền VA.',
 (SELECT id FROM CATEGORY WHERE slug='man-hinh'), (SELECT id FROM BRAND WHERE name='Samsung'), 1, GETDATE()),

(N'Bàn phím cơ AKKO 3068', 'ban-phim-co-akko-3068',
 N'Bàn phím cơ không dây, switch êm, layout 68 phím.',
 (SELECT id FROM CATEGORY WHERE slug='ngoai-vi'), NULL, 1, GETDATE()),

(N'iPhone 15 Pro', 'iphone-15-pro',
 N'Điện thoại Apple chip A17 Pro, khung titan.',
 (SELECT id FROM CATEGORY WHERE slug='dien-thoai'), (SELECT id FROM BRAND WHERE name='Apple'), 1, GETDATE());
GO

-- Biến thể mặc định cho từng sản phẩm
INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
SELECT id, 'SKU-ASUS-TUF',  22990000, 25990000, 15, 1 FROM PRODUCT WHERE slug='laptop-asus-tuf-f15'
UNION ALL SELECT id, 'SKU-XPS13',     31490000, NULL,     8,  1 FROM PRODUCT WHERE slug='laptop-dell-xps-13'
UNION ALL SELECT id, 'SKU-AEGIS',     35000000, 37500000, 5,  1 FROM PRODUCT WHERE slug='pc-gaming-msi-aegis'
UNION ALL SELECT id, 'SKU-I5-13400F', 4690000,  5200000,  30, 1 FROM PRODUCT WHERE slug='cpu-intel-i5-13400f'
UNION ALL SELECT id, 'SKU-RTX4060',   8990000,  NULL,     12, 1 FROM PRODUCT WHERE slug='vga-nvidia-rtx-4060'
UNION ALL SELECT id, 'SKU-ODYSSEY27', 6490000,  7200000,  20, 1 FROM PRODUCT WHERE slug='man-hinh-samsung-odyssey-27'
UNION ALL SELECT id, 'SKU-AKKO3068',  1290000,  NULL,     40, 1 FROM PRODUCT WHERE slug='ban-phim-co-akko-3068'
UNION ALL SELECT id, 'SKU-IP15PRO',   27990000, 29990000, 10, 1 FROM PRODUCT WHERE slug='iphone-15-pro';
GO

-- Ảnh chính cho từng sản phẩm (placeholder)
INSERT INTO PRODUCT_IMAGE (product_id, url, is_primary, sort_order)
SELECT id, 'https://placehold.co/400x400?text=ASUS+TUF',   1, 0 FROM PRODUCT WHERE slug='laptop-asus-tuf-f15'
UNION ALL SELECT id, 'https://placehold.co/400x400?text=Dell+XPS+13', 1, 0 FROM PRODUCT WHERE slug='laptop-dell-xps-13'
UNION ALL SELECT id, 'https://placehold.co/400x400?text=MSI+Aegis',   1, 0 FROM PRODUCT WHERE slug='pc-gaming-msi-aegis'
UNION ALL SELECT id, 'https://placehold.co/400x400?text=Core+i5',     1, 0 FROM PRODUCT WHERE slug='cpu-intel-i5-13400f'
UNION ALL SELECT id, 'https://placehold.co/400x400?text=RTX+4060',    1, 0 FROM PRODUCT WHERE slug='vga-nvidia-rtx-4060'
UNION ALL SELECT id, 'https://placehold.co/400x400?text=Odyssey+27',  1, 0 FROM PRODUCT WHERE slug='man-hinh-samsung-odyssey-27'
UNION ALL SELECT id, 'https://placehold.co/400x400?text=AKKO+3068',   1, 0 FROM PRODUCT WHERE slug='ban-phim-co-akko-3068'
UNION ALL SELECT id, 'https://placehold.co/400x400?text=iPhone+15',   1, 0 FROM PRODUCT WHERE slug='iphone-15-pro';
GO

PRINT N'✅ Đã thêm 8 sản phẩm mẫu.';
GO
