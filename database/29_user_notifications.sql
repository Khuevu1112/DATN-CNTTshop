-- ============================================================
-- 29_user_notifications.sql
-- Mở rộng NOTIFICATION để hỗ trợ thông báo riêng cho từng khách hàng
-- (đơn hàng đổi trạng thái, yêu cầu bảo hành được xử lý...), bên cạnh
-- thông báo chung cho admin/staff đã có (user_id NULL = thông báo admin).
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('NOTIFICATION') AND name = 'user_id')
BEGIN
    ALTER TABLE NOTIFICATION ADD user_id INT NULL;
    ALTER TABLE NOTIFICATION ADD CONSTRAINT FK_Notification_User FOREIGN KEY (user_id) REFERENCES [USER](id);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Notification_UserId')
    CREATE INDEX IX_Notification_UserId ON NOTIFICATION(user_id, created_at DESC);
GO
