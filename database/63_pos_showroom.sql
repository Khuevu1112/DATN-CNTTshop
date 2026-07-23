-- ============================================================
-- 63_pos_showroom.sql
-- Chặng 1 của luồng bán tại quầy (POS showroom, app riêng chạy cổng 5175).
--
-- Ba thay đổi, đều xuất phát từ việc bảng ORDER hiện chỉ mô tả được đơn BÁN ONLINE:
--
-- 1. address_id cho phép NULL. Đơn mua tại showroom khách cầm hàng về ngay, không có địa chỉ
--    giao. Trước đây cột này NOT NULL nên không thể lưu đơn tại quầy.
--    LƯU Ý: mọi chỗ đọc order.diaChiGiao phải kiểm null (đã sửa OrderApiController + 3 template
--    Thymeleaf trong cùng thay đổi này).
--
-- 2. Thêm cột channel để phân biệt đơn online / đơn tại quầy. Không suy ra từ address_id IS NULL
--    được, vì đơn online cũ vẫn có thể thiếu địa chỉ do dữ liệu lỗi — cần cột nói rõ ý định.
--
-- 3. Thêm phương thức thanh toán "cash" (tiền mặt tại quầy). Khác COD: COD là thu hộ khi giao
--    hàng tận nơi, cash là trả ngay tại showroom.
--
-- Khách tại quầy: KHÔNG dùng chung một tài khoản ảo. Mỗi số điện thoại là một khách (xem
-- PosService.timHoacTaoKhach) — khách đã mua online thì gắn đúng vào tài khoản cũ, khách mới thì
-- tạo tài khoản khách lẻ. Nhờ vậy Xu CT / hạng thành viên / lịch sử mua vẫn đúng theo từng người.
-- ============================================================
USE ShopDB;
GO

-- 1. Đơn tại quầy không có địa chỉ giao.
IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ORDER' AND COLUMN_NAME = 'address_id' AND IS_NULLABLE = 'NO'
)
BEGIN
    ALTER TABLE [ORDER] ALTER COLUMN address_id INT NULL;
END
GO

-- 2. Kênh bán. Đơn cũ đều là đơn online.
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='ORDER' AND COLUMN_NAME='channel')
BEGIN
    ALTER TABLE [ORDER] ADD channel VARCHAR(10) NOT NULL DEFAULT 'online';
END
GO

-- 3. Tiền mặt tại quầy. sort_order để 0 cho lên đầu danh sách của màn hình bán hàng.
IF NOT EXISTS (SELECT 1 FROM PAYMENT_METHOD WHERE code = 'cash')
BEGIN
    INSERT INTO PAYMENT_METHOD (name, code, is_active)
    VALUES (N'Tiền mặt tại quầy', 'cash', 1);
END
GO

-- Tài khoản khách lẻ tạo từ quầy dùng auth_provider = 'pos' để phân biệt với khách tự đăng ký
-- (local) hay đăng nhập Google/Facebook. Không có mật khẩu dùng được -> không đăng nhập online
-- bằng tài khoản này cho tới khi khách tự đặt lại mật khẩu qua email/SĐT (chặng 2).
GO

-- 4. Khai báo tính năng "pos" trong bảng FEATURE. BẮT BUỘC làm trước bước cấp quyền bên dưới:
-- ROLE_PERMISSION.feature_key có khoá ngoại trỏ tới FEATURE, chèn quyền cho feature chưa khai
-- báo sẽ bị chặn. Đây cũng là bảng cấp dữ liệu cho màn hình phân quyền của admin, nên thiếu
-- dòng này thì admin sẽ không thấy mục POS để tick.
IF NOT EXISTS (SELECT 1 FROM FEATURE WHERE feature_key = 'pos')
BEGIN
    INSERT INTO FEATURE (feature_key, label, group_label, sort_order)
    VALUES ('pos', N'Bán hàng tại quầy (POS)', N'Bán hàng', 75);
END
GO

-- 5. Quyền "pos" — tách khỏi "orders" vì là hai việc khác nhau: nhân viên đứng quầy cần chốt đơn
-- tại chỗ nhưng không nhất thiết được sửa đơn online. Admin luôn bỏ qua kiểm tra quyền
-- (PermissionAspect) nên không cần cấp riêng.
IF NOT EXISTS (SELECT 1 FROM ROLE_PERMISSION WHERE department='kinh_doanh' AND feature_key='pos' AND perm_key='view')
BEGIN
    INSERT INTO ROLE_PERMISSION (department, feature_key, perm_key) VALUES
    ('kinh_doanh','pos','view'),
    ('kinh_doanh','pos','add');
END
GO

