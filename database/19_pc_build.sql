-- ============================================================
-- 19_pc_build.sql
-- Cấu hình PC tự build: 1 PC_BUILD = 1 cấu hình đã lưu của user,
-- mỗi PC_BUILD_ITEM = 1 linh kiện (theo loại) trong cấu hình đó.
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PC_BUILD')
BEGIN
    CREATE TABLE PC_BUILD (
        id         INT IDENTITY(1,1) PRIMARY KEY,
        user_id    INT NOT NULL REFERENCES [USER](id),
        name       NVARCHAR(150) NOT NULL,
        note       NVARCHAR(MAX) NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    PRINT N'Da tao bang PC_BUILD';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PC_BUILD_ITEM')
BEGIN
    CREATE TABLE PC_BUILD_ITEM (
        id             INT IDENTITY(1,1) PRIMARY KEY,
        build_id       INT NOT NULL REFERENCES PC_BUILD(id) ON DELETE CASCADE,
        variant_id     INT NOT NULL REFERENCES PRODUCT_VARIANT(id),
        component_type VARCHAR(30) NOT NULL,
        quantity       INT NOT NULL DEFAULT 1
    );
    PRINT N'Da tao bang PC_BUILD_ITEM';
END
GO
