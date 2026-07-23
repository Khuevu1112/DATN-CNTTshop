-- ============================================================
-- 24_auth_provider.sql
-- Thêm cột auth_provider để phân biệt tài khoản tự đăng ký (local, có mật khẩu
-- thật) với tài khoản tạo qua OAuth2 (google/facebook, mật khẩu ngẫu nhiên
-- không dùng được) — dùng để ẩn/hiện mục "Đổi mật khẩu" ở trang tài khoản.
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'USER' AND COLUMN_NAME = 'auth_provider'
)
BEGIN
    ALTER TABLE [USER] ADD auth_provider VARCHAR(20) NOT NULL
        CONSTRAINT DF_USER_auth_provider DEFAULT 'local';
END
GO
