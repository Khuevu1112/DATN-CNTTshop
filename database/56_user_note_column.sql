-- 56_user_note_column.sql
-- Thêm cột ghi chú (nội bộ, tuỳ chọn) cho tài khoản — dùng ở form "Thêm tài khoản nhân viên".

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'USER' AND COLUMN_NAME = 'note'
)
BEGIN
    ALTER TABLE [USER] ADD note NVARCHAR(500) NULL;
END
GO
