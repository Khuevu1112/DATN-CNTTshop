-- ============================================================
-- 16_password_reset_otp.sql
-- Bảng lưu mã OTP quên mật khẩu (REST API, không phụ thuộc HttpSession
-- để hoạt động được với SPA Vue qua nhiều request/thiết bị).
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PASSWORD_RESET_OTP')
BEGIN
    CREATE TABLE PASSWORD_RESET_OTP (
        id          INT IDENTITY(1,1) PRIMARY KEY,
        email       NVARCHAR(255) NOT NULL,
        otp_code    VARCHAR(10) NOT NULL,
        expires_at  DATETIME2 NOT NULL,
        is_used     BIT NOT NULL DEFAULT 0,
        created_at  DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    PRINT N'Da tao bang PASSWORD_RESET_OTP';
END
ELSE
    PRINT N'Bang PASSWORD_RESET_OTP da ton tai, bo qua';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PasswordResetOtp_Email')
    CREATE INDEX IX_PasswordResetOtp_Email ON PASSWORD_RESET_OTP(email);
GO
