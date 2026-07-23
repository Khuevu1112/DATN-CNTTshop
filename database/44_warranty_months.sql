-- 44_warranty_months.sql
-- Thêm thời hạn bảo hành (tháng) cho sản phẩm — phục vụ tháp xem trước khi hover (giống TTGshop).
-- Mặc định 36 tháng cho mọi sản phẩm hiện có và sản phẩm mới về sau.

ALTER TABLE PRODUCT ADD warranty_months INT NULL;
GO

UPDATE PRODUCT SET warranty_months = 36 WHERE warranty_months IS NULL;
GO

ALTER TABLE PRODUCT ALTER COLUMN warranty_months INT NOT NULL;
GO

ALTER TABLE PRODUCT ADD CONSTRAINT DF_PRODUCT_warranty_months DEFAULT 36 FOR warranty_months;
GO
