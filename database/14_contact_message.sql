-- ============================================================
-- 14_contact_message.sql
-- Bảng lưu liên hệ/yêu cầu hỗ trợ gửi từ trang "Liên hệ" (User)
-- để Admin theo dõi và phản hồi trong trang "Quản lý liên hệ".
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'CONTACT_MESSAGE')
BEGIN
    CREATE TABLE CONTACT_MESSAGE (
        id          INT IDENTITY(1,1) PRIMARY KEY,

        full_name   NVARCHAR(150) NOT NULL,
        email       NVARCHAR(255) NOT NULL,
        phone       VARCHAR(20)   NULL,
        subject     NVARCHAR(255) NULL,
        message     NVARCHAR(2000) NOT NULL,

        status      VARCHAR(20) NOT NULL DEFAULT 'new'
                    CHECK (status IN ('new','processing','resolved')),

        admin_reply NVARCHAR(2000) NULL,
        replied_at  DATETIME2 NULL,

        user_id     INT NULL,
        created_at  DATETIME2 NOT NULL DEFAULT GETDATE(),

        FOREIGN KEY (user_id) REFERENCES [USER](id)
    );

    PRINT N'✅ Đã tạo bảng CONTACT_MESSAGE';
END
ELSE
    PRINT N'⚠ Bảng CONTACT_MESSAGE đã tồn tại, bỏ qua';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ContactMessage_CreatedAt')
    CREATE INDEX IX_ContactMessage_CreatedAt ON CONTACT_MESSAGE(created_at DESC);
GO
