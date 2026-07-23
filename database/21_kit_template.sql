-- ============================================================
-- 21_kit_template.sql
-- "Mẫu cấu hình" (Kit Template) — admin tự định nghĩa 1 bộ PC hoàn chỉnh
-- (case, CPU, GPU, RAM... đến chuột, bàn phím) để áp dụng nhanh khi tạo
-- sản phẩm mới (copy/duplicate vào PRODUCT_SPEC, không giữ liên kết ngược).
-- Khác PC_BUILD (khách tự ráp linh kiện rời) — đây CHỈ admin dùng.
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'KIT_TEMPLATE')
BEGIN
    CREATE TABLE KIT_TEMPLATE (
        id           INT IDENTITY(1,1) PRIMARY KEY,
        name         NVARCHAR(200) NOT NULL,
        description  NVARCHAR(1000) NULL,
        created_at   DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    PRINT N'Da tao bang KIT_TEMPLATE';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'KIT_TEMPLATE_ITEM')
BEGIN
    CREATE TABLE KIT_TEMPLATE_ITEM (
        id               INT IDENTITY(1,1) PRIMARY KEY,
        kit_template_id  INT NOT NULL REFERENCES KIT_TEMPLATE(id) ON DELETE CASCADE,
        component_type   NVARCHAR(50) NOT NULL,
        source           VARCHAR(20) NOT NULL DEFAULT 'stock',
        variant_id       INT NULL REFERENCES PRODUCT_VARIANT(id),
        manual_name      NVARCHAR(255) NULL,
        extra_price      DECIMAL(12,2) NULL,
        sort_order       INT NOT NULL DEFAULT 0,
        CONSTRAINT CK_KitTemplateItem_Source CHECK (source IN ('stock', 'external'))
    );
    PRINT N'Da tao bang KIT_TEMPLATE_ITEM';
END
GO
