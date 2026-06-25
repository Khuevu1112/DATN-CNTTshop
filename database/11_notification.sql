-- ============================================================
-- 11_notification.sql
-- Bảng thông báo cho admin/staff (nút chuông trên admin-vue).
-- Đơn giản hoá: thông báo chung cho mọi admin/staff (không gắn user_id riêng).
-- ============================================================
USE ShopDB;
GO

CREATE TABLE NOTIFICATION (
    id INT IDENTITY(1,1) PRIMARY KEY,

    type VARCHAR(30) NOT NULL,
    title NVARCHAR(255) NOT NULL,
    message NVARCHAR(500) NOT NULL,
    link NVARCHAR(255) NULL,

    is_read BIT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

CREATE INDEX IX_Notification_CreatedAt ON NOTIFICATION(created_at DESC);
GO
