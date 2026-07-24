-- ============================================================
-- 65_installment.sql
-- Trả góp — lấy từ nhánh "review+trả-góp" của dev khác (file "DB trả góp+review.sql").
--
-- KHÁC BẢN GỐC hai điểm, đều có lý do:
--
-- 1. BỎ HẲN phần PRODUCT_REVIEW trong file gốc. Dự án đã có bảng REVIEW đang chạy với dữ liệu
--    thật, và REVIEW còn đầy đủ hơn: gắn order_id (chứng minh đã mua thật), cờ is_verified, và
--    2 ảnh kèm theo. Tạo thêm bảng thứ hai sẽ chia đôi dữ liệu đánh giá — số sao hiển thị lệch
--    nhau tuỳ chỗ nào đọc từ bảng nào.
--
-- 2. Thêm IF NOT EXISTS + khoá ngoại. Bản gốc CREATE TABLE trần nên chạy lần hai là lỗi, và
--    product_id/user_id không ràng buộc gì nên có thể trỏ tới sản phẩm không tồn tại.
--
-- Ý ĐỒ THIẾT KẾ (giữ nguyên của dev gốc): INSTALLMENT_ORDER độc lập với ORDER vì đây là ĐƠN
-- ĐĂNG KÝ tư vấn trả góp, chưa phải đơn hàng. Trả góp cần duyệt hồ sơ tín dụng trước, không
-- chốt ngay được — nên chưa trừ kho, chưa vào doanh thu.
-- ============================================================
USE ShopDB;
GO

-- ===== Kỳ hạn + lãi suất =====
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'INSTALLMENT_PLAN')
BEGIN
    CREATE TABLE INSTALLMENT_PLAN (
        id INT IDENTITY(1,1) PRIMARY KEY,
        months INT NOT NULL UNIQUE,
        interest_rate DECIMAL(5,2) NOT NULL,
        active BIT NOT NULL DEFAULT 1
    );

    -- interest_rate là lãi suất %/THÁNG trên dư nợ gốc ban đầu (cách tính phẳng, xem
    -- InstallmentService.tinhToan) — 6 kỳ hạn theo đúng bảng dev gốc đưa.
    INSERT INTO INSTALLMENT_PLAN(months, interest_rate, active) VALUES
    (3, 0.00, 1),
    (6, 1.50, 1),
    (9, 2.50, 1),
    (12, 3.50, 1),
    (18, 5.00, 1),
    (24, 7.00, 1);
END
GO

-- ===== Đơn đăng ký trả góp =====
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'INSTALLMENT_ORDER')
BEGIN
    CREATE TABLE INSTALLMENT_ORDER (
        id INT IDENTITY(1,1) PRIMARY KEY,

        -- NULL = khách vãng lai đăng ký khi chưa đăng nhập (giữ nguyên ý đồ bản gốc).
        user_id INT NULL REFERENCES [USER](id),
        product_id INT NOT NULL REFERENCES PRODUCT(id),
        variant_id INT NULL REFERENCES PRODUCT_VARIANT(id),

        -- Chụp lại tên + tuỳ chọn tại thời điểm đăng ký, giống cách ORDER_ITEM lưu tenSanPham:
        -- hồ sơ trả góp kéo dài nhiều tháng, sản phẩm có thể bị đổi tên hoặc gỡ khỏi catalog.
        product_name NVARCHAR(255) NOT NULL,
        selected_options NVARCHAR(1000) NULL,
        quantity INT NOT NULL DEFAULT 1,

        months INT NOT NULL,
        interest_rate DECIMAL(5,2) NOT NULL,

        price DECIMAL(18,2) NOT NULL,
        down_payment DECIMAL(18,2) NOT NULL DEFAULT 0,
        loan_amount DECIMAL(18,2) NOT NULL,
        total_interest DECIMAL(18,2) NOT NULL,
        monthly_payment DECIMAL(18,2) NOT NULL,
        total_payment DECIMAL(18,2) NOT NULL,

        -- Thông tin hồ sơ. identity_number là CCCD/CMND — dữ liệu định danh cá nhân, chỉ nhân
        -- viên có quyền "installment" mới đọc được (xem AdminInstallmentApiController).
        customer_name NVARCHAR(150) NOT NULL,
        customer_phone VARCHAR(20) NOT NULL,
        customer_email VARCHAR(150) NULL,
        customer_address NVARCHAR(500) NOT NULL,
        identity_number VARCHAR(20) NOT NULL,

        -- PENDING -> APPROVED | REJECTED | CANCELLED
        status NVARCHAR(30) NOT NULL DEFAULT N'PENDING',
        staff_note NVARCHAR(1000) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NULL
    );

    CREATE INDEX IX_INSTALLMENT_ORDER_status ON INSTALLMENT_ORDER (status, created_at DESC);
    CREATE INDEX IX_INSTALLMENT_ORDER_user ON INSTALLMENT_ORDER (user_id);
END
GO

-- Bản gốc không có cột ghi chú của nhân viên duyệt — thêm cho trường hợp bảng đã được tạo trước.
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='INSTALLMENT_ORDER' AND COLUMN_NAME='staff_note')
BEGIN
    ALTER TABLE INSTALLMENT_ORDER ADD staff_note NVARCHAR(1000) NULL;
END
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='INSTALLMENT_ORDER' AND COLUMN_NAME='updated_at')
BEGIN
    ALTER TABLE INSTALLMENT_ORDER ADD updated_at DATETIME2 NULL;
END
GO

-- ===== Quyền =====
IF NOT EXISTS (SELECT 1 FROM FEATURE WHERE feature_key = 'installment')
BEGIN
    INSERT INTO FEATURE (feature_key, label, group_label, sort_order)
    VALUES ('installment', N'Trả góp', N'Bán hàng', 79);
END
GO

IF NOT EXISTS (SELECT 1 FROM ROLE_PERMISSION WHERE feature_key='installment' AND department='kinh_doanh')
BEGIN
    INSERT INTO ROLE_PERMISSION (department, feature_key, perm_key) VALUES
    ('kinh_doanh','installment','view'),
    ('kinh_doanh','installment','edit'),
    ('ke_toan','installment','view');
END
GO
