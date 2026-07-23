-- 57_account_lock_log.sql
-- Log hoạt động tài khoản: đăng nhập + khoá/mở khoá (kèm lý do/hạn khoá/ảnh chứng minh khi khoá).
-- Hiển thị dưới dạng 1 timeline duy nhất ở trang chi tiết tài khoản (Quản lý tài khoản).

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ACCOUNT_LOG')
BEGIN
    CREATE TABLE ACCOUNT_LOG (
        id INT IDENTITY PRIMARY KEY,
        user_id INT NOT NULL,
        log_type VARCHAR(20) NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        reason NVARCHAR(500) NULL,
        lock_until DATETIME2 NULL,
        evidence_image NVARCHAR(255) NULL,
        performed_by_id INT NULL,
        ip_address VARCHAR(64) NULL,
        CONSTRAINT CK_ACCOUNT_LOG_TYPE CHECK (log_type IN ('login', 'lock', 'unlock')),
        CONSTRAINT FK_ACCOUNT_LOG_USER FOREIGN KEY (user_id) REFERENCES [USER](id),
        CONSTRAINT FK_ACCOUNT_LOG_PERFORMED_BY FOREIGN KEY (performed_by_id) REFERENCES [USER](id)
    );
    CREATE INDEX IX_ACCOUNT_LOG_USER ON ACCOUNT_LOG(user_id, created_at DESC);
END
GO
