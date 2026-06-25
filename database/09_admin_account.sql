-- ============================================================
-- 09_admin_account.sql
-- Tạo / cập nhật tài khoản ADMIN có mật khẩu biết trước để đăng nhập trang admin-vue.
--   Email   : admin@shopdb.vn
--   Mật khẩu: admin123
-- (Hash BCrypt $2b$10$ tương thích với BCryptPasswordEncoder của Spring Security)
-- Chạy SAU 01_DATNCNTTSHOP.sql.
-- ============================================================
USE ShopDB;
GO

IF EXISTS (SELECT 1 FROM [USER] WHERE email = 'admin@shopdb.vn')
    UPDATE [USER]
       SET password_hash = '$2b$10$DuZScRENmipapZZ.jLGYPuYE/P.hqv0WaPubJl5A1KrQzlLSv2Pwq',
           role          = 'admin',
           is_active     = 1
     WHERE email = 'admin@shopdb.vn';
ELSE
    INSERT INTO [USER] (full_name, email, phone, password_hash, role, is_active)
    VALUES (N'Quản Trị Viên', 'admin@shopdb.vn', '0900000000',
            '$2b$10$DuZScRENmipapZZ.jLGYPuYE/P.hqv0WaPubJl5A1KrQzlLSv2Pwq', 'admin', 1);
GO

PRINT N'>> Tài khoản admin sẵn sàng: admin@shopdb.vn / admin123';
GO
