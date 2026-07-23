-- ============================================================
-- 15_seed_orders.sql
-- Thêm khách hàng mẫu + đơn hàng thật (đa dạng trạng thái, trải 9 tháng)
-- để Dashboard / Đơn hàng / Phân tích có dữ liệu thật thay vì rỗng.
-- ============================================================
USE ShopDB;
GO

-- ===== 1. Khách hàng mẫu =====
IF NOT EXISTS (SELECT 1 FROM [USER] WHERE email = 'tran.minh.anh@gmail.com')
BEGIN
    INSERT INTO [USER] (full_name, email, phone, password_hash, role, is_active, created_at) VALUES
    (N'Trần Minh Anh',   'tran.minh.anh@gmail.com',   '0901234001', '$2b$10$DuZScRENmipapZZ.jLGYPuYE/P.hqv0WaPubJl5A1KrQzlLSv2Pwq', 'customer', 1, DATEADD(DAY,-260,GETDATE())),
    (N'Nguyễn Thị Hoa',  'nguyen.thi.hoa@gmail.com',  '0901234002', '$2b$10$DuZScRENmipapZZ.jLGYPuYE/P.hqv0WaPubJl5A1KrQzlLSv2Pwq', 'customer', 1, DATEADD(DAY,-245,GETDATE())),
    (N'Lê Văn Đức',      'le.van.duc@gmail.com',      '0901234003', '$2b$10$DuZScRENmipapZZ.jLGYPuYE/P.hqv0WaPubJl5A1KrQzlLSv2Pwq', 'customer', 1, DATEADD(DAY,-230,GETDATE())),
    (N'Phạm Quốc Bảo',   'pham.quoc.bao@gmail.com',   '0901234004', '$2b$10$DuZScRENmipapZZ.jLGYPuYE/P.hqv0WaPubJl5A1KrQzlLSv2Pwq', 'customer', 1, DATEADD(DAY,-210,GETDATE())),
    (N'Đỗ Thị Mai',      'do.thi.mai@gmail.com',      '0901234005', '$2b$10$DuZScRENmipapZZ.jLGYPuYE/P.hqv0WaPubJl5A1KrQzlLSv2Pwq', 'customer', 1, DATEADD(DAY,-190,GETDATE())),
    (N'Vũ Đình Khang',   'vu.dinh.khang@gmail.com',   '0901234006', '$2b$10$DuZScRENmipapZZ.jLGYPuYE/P.hqv0WaPubJl5A1KrQzlLSv2Pwq', 'customer', 1, DATEADD(DAY,-170,GETDATE())),
    (N'Hoàng Thị Lan',   'hoang.thi.lan@gmail.com',   '0901234007', '$2b$10$DuZScRENmipapZZ.jLGYPuYE/P.hqv0WaPubJl5A1KrQzlLSv2Pwq', 'customer', 1, DATEADD(DAY,-150,GETDATE())),
    (N'Bùi Anh Tuấn',    'bui.anh.tuan@gmail.com',    '0901234008', '$2b$10$DuZScRENmipapZZ.jLGYPuYE/P.hqv0WaPubJl5A1KrQzlLSv2Pwq', 'customer', 1, DATEADD(DAY,-120,GETDATE())),
    (N'Ngô Thị Thu',     'ngo.thi.thu@gmail.com',     '0901234009', '$2b$10$DuZScRENmipapZZ.jLGYPuYE/P.hqv0WaPubJl5A1KrQzlLSv2Pwq', 'customer', 1, DATEADD(DAY,-95,GETDATE())),
    (N'Đặng Văn Phúc',   'dang.van.phuc@gmail.com',   '0901234010', '$2b$10$DuZScRENmipapZZ.jLGYPuYE/P.hqv0WaPubJl5A1KrQzlLSv2Pwq', 'customer', 1, DATEADD(DAY,-60,GETDATE())),
    (N'Trương Ngọc Hân', 'truong.ngoc.han@gmail.com', '0901234011', '$2b$10$DuZScRENmipapZZ.jLGYPuYE/P.hqv0WaPubJl5A1KrQzlLSv2Pwq', 'customer', 1, DATEADD(DAY,-30,GETDATE())),
    (N'Lý Gia Huy',      'ly.gia.huy@gmail.com',      '0901234012', '$2b$10$DuZScRENmipapZZ.jLGYPuYE/P.hqv0WaPubJl5A1KrQzlLSv2Pwq', 'customer', 1, DATEADD(DAY,-10,GETDATE()));

    PRINT N'Da them 12 khach hang mau';
END
GO

-- ===== 2. Địa chỉ mặc định cho mọi khách hàng chưa có địa chỉ =====
INSERT INTO USER_ADDRESS (user_id, receiver_name, phone, address, province, district, ward, is_default)
SELECT u.id, u.full_name, ISNULL(u.phone, '0900000000'),
       N'Số ' + CAST(u.id AS NVARCHAR(10)) + N' Đường Nguyễn Huệ',
       N'TP.HCM', N'Quận 1', N'Phường Bến Nghé', 1
FROM [USER] u
WHERE u.role = 'customer'
  AND NOT EXISTS (SELECT 1 FROM USER_ADDRESS a WHERE a.user_id = u.id);
GO

-- ===== 3. Đơn hàng mẫu (chỉ chạy nếu chưa có đơn nào) =====
IF (SELECT COUNT(*) FROM [ORDER]) = 0
BEGIN
    DECLARE @i INT = 1;
    DECLARE @totalOrders INT = 90;

    WHILE @i <= @totalOrders
    BEGIN
        DECLARE @userId INT, @addressId INT, @daysAgo INT, @status VARCHAR(30), @orderId INT;
        DECLARE @subtotal DECIMAL(18,2) = 0, @shippingFee DECIMAL(18,2) = 30000;
        DECLARE @orderCode VARCHAR(30), @createdAt DATETIME2, @r INT;

        SELECT TOP 1 @userId = id FROM [USER] WHERE role = 'customer' ORDER BY NEWID();
        SELECT TOP 1 @addressId = id FROM USER_ADDRESS WHERE user_id = @userId;

        -- Phân bổ mượt, hơi nghiêng về gần đây (lệch mũ 1.6) thay vì chia 2 cụm cứng,
        -- để biểu đồ theo tháng không bị 1 tháng vọt cao bất thường so với các tháng còn lại.
        DECLARE @rnd FLOAT = (ABS(CHECKSUM(NEWID())) % 1000000) / 1000000.0;
        SET @daysAgo = CAST(269.0 * POWER(@rnd, 1.6) AS INT);

        SET @createdAt = DATEADD(SECOND, -(ABS(CHECKSUM(NEWID())) % 86400), DATEADD(DAY, -@daysAgo, GETDATE()));

        SET @r = ABS(CHECKSUM(NEWID())) % 100;
        SET @status = CASE
            WHEN @r < 38 THEN 'delivered'
            WHEN @r < 53 THEN 'shipped'
            WHEN @r < 63 THEN 'processing'
            WHEN @r < 73 THEN 'confirmed'
            WHEN @r < 83 THEN 'pending'
            WHEN @r < 93 THEN 'cancelled'
            ELSE 'refunded'
        END;

        SET @orderCode = 'ORD' + FORMAT(@createdAt, 'yyMMdd') + RIGHT('0000' + CAST(@i AS VARCHAR(4)), 4);

        INSERT INTO [ORDER] (user_id, address_id, order_code, subtotal, discount_amount, shipping_fee, total_amount, status, created_at)
        VALUES (@userId, @addressId, @orderCode, 0, 0, @shippingFee, 0, @status, @createdAt);

        SET @orderId = SCOPE_IDENTITY();

        DECLARE @itemCount INT = 1 + ABS(CHECKSUM(NEWID())) % 3;
        DECLARE @j INT = 1;
        SET @subtotal = 0;

        WHILE @j <= @itemCount
        BEGIN
            DECLARE @variantId INT, @price DECIMAL(18,2), @pname NVARCHAR(300), @qty INT;

            SELECT TOP 1 @variantId = v.id, @price = v.price, @pname = p.name
            FROM PRODUCT_VARIANT v JOIN PRODUCT p ON v.product_id = p.id
            ORDER BY NEWID();

            SET @qty = 1 + ABS(CHECKSUM(NEWID())) % 2;

            INSERT INTO ORDER_ITEM (order_id, variant_id, product_name, variant_info, unit_price, quantity)
            VALUES (@orderId, @variantId, @pname, NULL, @price, @qty);

            SET @subtotal = @subtotal + (@price * @qty);
            SET @j = @j + 1;
        END

        UPDATE [ORDER] SET subtotal = @subtotal, total_amount = @subtotal + @shippingFee WHERE id = @orderId;

        SET @i = @i + 1;
    END

    PRINT N'Da tao 90 don hang mau';
END
ELSE
    PRINT N'Da co don hang, bo qua seed';
GO
