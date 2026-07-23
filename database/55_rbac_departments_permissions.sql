-- RBAC: thay "staff" chung chung bằng 6 phòng ban, mỗi phòng ban có 1 tập quyền riêng theo
-- từng trang (feature), admin toàn quyền và không cần dòng trong ROLE_PERMISSION (bỏ qua bảng
-- này ở code). Dữ liệu seed lấy từ "Phân quyền CNTTshop.xlsx" đã thống nhất với người dùng.

-- 1) Đổi CHECK constraint trên [USER].role — tra tên qua sys.check_constraints vì tên tự sinh,
--    có thể khác giữa các môi trường (đã xác minh máy này là CK__USER__role__398D8EEE).
DECLARE @cname NVARCHAR(200);
SELECT @cname = cc.name FROM sys.check_constraints cc
  JOIN sys.tables t ON cc.parent_object_id = t.object_id
  WHERE t.name = 'USER' AND cc.definition LIKE '%role%';
IF @cname IS NOT NULL
  EXEC('ALTER TABLE [USER] DROP CONSTRAINT ' + @cname);
GO

ALTER TABLE [USER] ADD CONSTRAINT CK_USER_role
  CHECK (role IN ('customer','admin','ke_toan','kho','ky_thuat','cskh','giao_hang','kinh_doanh'));
GO

-- 2) Danh sách trang/chức năng cố định (không cho thêm/xoá qua UI, chỉ để FK ràng buộc
--    ROLE_PERMISSION.feature_key khỏi gõ sai chuỗi + cho FE lấy label/nhóm để vẽ lưới).
CREATE TABLE FEATURE (
    feature_key VARCHAR(60) PRIMARY KEY,
    label NVARCHAR(150) NOT NULL,
    group_label NVARCHAR(100) NOT NULL,
    sort_order INT NOT NULL
);
GO

INSERT INTO FEATURE (feature_key, label, group_label, sort_order) VALUES
('dashboard',            N'Bảng điều khiển',               N'Tổng quan',  10),
('analytics',            N'Phân tích',                      N'Tổng quan',  20),
('orders',               N'Đơn hàng',                       N'Bán hàng',   30),
('products_view',        N'Sản phẩm — Xem',                 N'Bán hàng',   40),
('products_manage',      N'Sản phẩm — Thêm/Sửa',            N'Bán hàng',   50),
('stock_movement',       N'Nhập kho',                       N'Bán hàng',   60),
('categories',           N'Quản lý danh mục',               N'Bán hàng',   70),
('kit_templates_view',   N'Mẫu cấu hình — Xem',             N'Bán hàng',   80),
('kit_templates_manage', N'Mẫu cấu hình — Tạo mới',         N'Bán hàng',   90),
('accounts_customer',    N'Quản lý tài khoản — Khách hàng', N'Khách hàng', 100),
('accounts_staff',       N'Quản lý tài khoản — Nhân viên',  N'Khách hàng', 110),
('account_detail',       N'Chi tiết tài khoản',             N'Khách hàng', 120),
('contacts',             N'Liên hệ',                        N'Khách hàng', 130),
('warranty',             N'Bảo hành',                       N'Khách hàng', 140),
('coupons',              N'Khuyến mãi',                     N'Marketing',  150),
('shipping',             N'Phí giao hàng',                  N'Marketing',  160),
('permissions',          N'Phân quyền',                     N'Hệ thống',   170);
GO

-- 3) 8 loại quyền cố định (không cho thêm/xoá qua UI).
CREATE TABLE PERMISSION_TYPE (
    perm_key VARCHAR(30) PRIMARY KEY,
    label NVARCHAR(80) NOT NULL,
    color VARCHAR(20) NOT NULL,
    sort_order INT NOT NULL
);
GO

INSERT INTO PERMISSION_TYPE (perm_key, label, color, sort_order) VALUES
('full',    N'Tất cả các quyền',          '#ff3b5c', 10),
('view',    N'Quyền xem',                  '#7aa2ff', 20),
('add',     N'Quyền thêm',                 '#22d39a', 30),
('edit',    N'Quyền sửa',                  '#ffb43b', 40),
('delete',  N'Quyền xoá',                  '#a855f7', 50),
('perform', N'Quyền thực hiện các tác vụ', '#00e5ff', 60),
('limited', N'Giới hạn hiển thị',          '#f97316', 70),
('none',    N'Không có quyền',             '#7d818a', 80);
GO

-- 4) Ma trận (phòng ban, trang) -> tập quyền được cấp. "Không có quyền" = không có dòng nào
--    (đơn giản hoá kiểm tra: có dòng khớp = được phép, không có dòng = chặn).
CREATE TABLE ROLE_PERMISSION (
    id INT IDENTITY(1,1) PRIMARY KEY,
    department VARCHAR(20) NOT NULL
        CHECK (department IN ('ke_toan','kho','ky_thuat','cskh','giao_hang','kinh_doanh')),
    feature_key VARCHAR(60) NOT NULL REFERENCES FEATURE(feature_key),
    perm_key VARCHAR(30) NOT NULL REFERENCES PERMISSION_TYPE(perm_key),
    CONSTRAINT UQ_ROLE_PERMISSION UNIQUE (department, feature_key, perm_key)
);
CREATE INDEX IX_ROLE_PERMISSION_LOOKUP ON ROLE_PERMISSION(department, feature_key);
GO

-- 5) Seed ma trận theo file Excel đã thống nhất (accounts_staff và permissions: không phòng ban
--    nào có dòng nào -> chỉ admin thấy; cskh + accounts_customer có thêm 'edit' theo yêu cầu sửa).
INSERT INTO ROLE_PERMISSION (department, feature_key, perm_key) VALUES
-- Kế toán
('ke_toan','dashboard','view'),
('ke_toan','analytics','view'),
('ke_toan','orders','view'),
('ke_toan','products_view','view'),
('ke_toan','stock_movement','view'),
('ke_toan','coupons','view'),
-- Kho
('kho','orders','perform'),
('kho','products_view','view'),
('kho','stock_movement','full'),
('kho','categories','full'),
('kho','kit_templates_view','view'),
-- Kỹ thuật
('ky_thuat','products_view','full'),
('ky_thuat','products_manage','full'),
('ky_thuat','categories','full'),
('ky_thuat','kit_templates_view','full'),
('ky_thuat','kit_templates_manage','full'),
('ky_thuat','warranty','view'),
-- Chăm sóc khách hàng
('cskh','dashboard','view'),
('cskh','analytics','view'),
('cskh','orders','view'),
('cskh','products_view','view'),
('cskh','kit_templates_view','view'),
('cskh','accounts_customer','limited'),
('cskh','accounts_customer','view'),
('cskh','accounts_customer','edit'),
('cskh','account_detail','perform'),
('cskh','contacts','full'),
('cskh','warranty','perform'),
('cskh','coupons','view'),
('cskh','shipping','view'),
-- Giao hàng
('giao_hang','orders','view'),
('giao_hang','warranty','view'),
('giao_hang','coupons','view'),
('giao_hang','shipping','add'),
('giao_hang','shipping','edit'),
-- Kinh doanh
('kinh_doanh','dashboard','perform'),
('kinh_doanh','analytics','perform'),
('kinh_doanh','orders','perform'),
('kinh_doanh','products_view','perform'),
('kinh_doanh','stock_movement','view'),
('kinh_doanh','categories','perform'),
('kinh_doanh','kit_templates_view','view'),
('kinh_doanh','accounts_customer','limited'),
('kinh_doanh','account_detail','view'),
('kinh_doanh','warranty','perform'),
('kinh_doanh','coupons','perform'),
('kinh_doanh','shipping','perform');
GO
