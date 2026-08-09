-- ============================================================
-- 12_chat_message.sql
-- Lưu lịch sử chat của chatbot theo từng user đã đăng nhập.
-- Guest (chưa đăng nhập) vẫn dùng localStorage phía frontend,
-- không ghi vào bảng này.
-- Chạy an toàn nhiều lần.
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CHAT_MESSAGE')
BEGIN
    CREATE TABLE CHAT_MESSAGE (
        id         INT IDENTITY(1,1) PRIMARY KEY,

        user_id    INT NOT NULL
            REFERENCES [USER](id) ON DELETE CASCADE,

        role       VARCHAR(10) NOT NULL
            CHECK (role IN ('user','bot')),

        content    NVARCHAR(MAX) NOT NULL,

        -- Lưu thêm metadata tuỳ chọn (vd: danh sách sản phẩm gợi ý kèm theo tin nhắn bot)
        -- dạng JSON string, có thể NULL nếu tin nhắn thuần text.
        metadata   NVARCHAR(MAX) NULL,

        created_at DATETIME2 NOT NULL DEFAULT GETDATE()
    );

    CREATE INDEX IX_ChatMessage_User_Created ON CHAT_MESSAGE(user_id, created_at ASC);

    PRINT N'✅ Đã tạo bảng CHAT_MESSAGE';
END
ELSE
    PRINT N'⚠ Bảng CHAT_MESSAGE đã tồn tại, bỏ qua';
GO
