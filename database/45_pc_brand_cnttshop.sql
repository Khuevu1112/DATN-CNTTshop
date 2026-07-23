-- 45_pc_brand_cnttshop.sql
-- PC & Máy tính bàn là hàng CNTTshop tự lắp ráp — thương hiệu hiện đang lấy theo linh kiện
-- nổi bật (Gigabyte/ASUS/MSI...) gây hiểu nhầm đây là PC hãng. Chuyển hết về brand CNTTshop
-- để khớp thực tế và để bộ lọc "Thương hiệu" không còn vô nghĩa cho danh mục này.

IF NOT EXISTS (SELECT 1 FROM BRAND WHERE name = N'CNTTshop')
    INSERT INTO BRAND (name, logo_url) VALUES (N'CNTTshop', NULL);
GO

DECLARE @brandId INT = (SELECT id FROM BRAND WHERE name = N'CNTTshop');

UPDATE p
SET p.brand_id = @brandId
FROM PRODUCT p
JOIN CATEGORY c ON p.category_id = c.id
WHERE c.slug = 'pc-may-tinh-ban';
GO
