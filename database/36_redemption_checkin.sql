-- ============================================================
-- 36_redemption_checkin.sql
-- Giai đoạn 2 của Ví CNTTShop: kho đổi thưởng bằng token bạc (coupon hoặc quà vật lý) +
-- điểm danh định kỳ, cả 2 sống trong "trang khuyến mãi" riêng (xem PromotionsView.vue).
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name='REDEMPTION_ITEM' AND xtype='U')
BEGIN
    CREATE TABLE REDEMPTION_ITEM (
        id INT IDENTITY(1,1) PRIMARY KEY,

        type VARCHAR(20) NOT NULL
            CHECK (type IN ('coupon', 'gift')),

        name NVARCHAR(200) NOT NULL,

        silver_cost INT NOT NULL,

        -- Chỉ dùng khi type='coupon': % giảm giá + đơn tối thiểu để tạo coupon dùng 1 lần.
        discount_percent INT NULL,
        coupon_min_order DECIMAL(18,2) NULL,

        -- Chỉ dùng khi type='gift': variant cụ thể sẽ giao khi đổi (tái dùng hệ Đơn hàng).
        variant_id INT NULL
            REFERENCES PRODUCT_VARIANT(id),

        is_active BIT NOT NULL DEFAULT 1,
        sort_order INT NOT NULL DEFAULT 0,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE()
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name='CHECKIN_LOG' AND xtype='U')
BEGIN
    CREATE TABLE CHECKIN_LOG (
        id INT IDENTITY(1,1) PRIMARY KEY,

        user_id INT NOT NULL
            REFERENCES [USER](id),

        checkin_date DATE NOT NULL,

        streak_count INT NOT NULL,

        reward_silver INT NOT NULL,

        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),

        CONSTRAINT UQ_CheckinLog_User_Date UNIQUE (user_id, checkin_date)
    );
END
GO

-- Payment method riêng cho đơn đổi quà bằng token (0đ, không phải mua thật) — is_active=0 nên
-- không bao giờ hiện trong danh sách chọn thanh toán bình thường, chỉ dùng làm FK nội bộ.
IF NOT EXISTS (SELECT 1 FROM PAYMENT_METHOD WHERE code = 'redemption')
BEGIN
    INSERT INTO PAYMENT_METHOD (name, code, is_active)
    VALUES (N'Đổi bằng token (nội bộ)', 'redemption', 0);
END
GO

-- ===== Seed catalog đổi thưởng =====
IF NOT EXISTS (SELECT 1 FROM REDEMPTION_ITEM)
BEGIN
    INSERT INTO REDEMPTION_ITEM (type, name, silver_cost, discount_percent, coupon_min_order, sort_order) VALUES
    ('coupon', N'Mã giảm giá 1%', 20, 1, 0, 1),
    ('coupon', N'Mã giảm giá 3%', 50, 3, 200000, 2),
    ('coupon', N'Mã giảm giá 5%', 100, 5, 300000, 3),
    ('coupon', N'Mã giảm giá 10%', 250, 10, 500000, 4),
    ('coupon', N'Mã giảm giá 15%', 450, 15, 800000, 5),
    ('coupon', N'Mã giảm giá 20%', 700, 20, 1000000, 6),
    ('coupon', N'Mã giảm giá 30%', 1200, 30, 2000000, 7),
    ('coupon', N'Mã giảm giá 50%', 2500, 50, 5000000, 8);

    INSERT INTO REDEMPTION_ITEM (type, name, silver_cost, variant_id, sort_order)
    SELECT 'gift', N'Lót chuột Ugreen size M', 150, id, 9 FROM PRODUCT_VARIANT WHERE id = 684;

    INSERT INTO REDEMPTION_ITEM (type, name, silver_cost, variant_id, sort_order)
    SELECT 'gift', N'Chuột E-Dra EM620', 500, id, 10 FROM PRODUCT_VARIANT WHERE id = 644;

    INSERT INTO REDEMPTION_ITEM (type, name, silver_cost, variant_id, sort_order)
    SELECT 'gift', N'Tai nghe nhét tai Anker Soundcore P20i', 650, id, 11 FROM PRODUCT_VARIANT WHERE id = 315;

    INSERT INTO REDEMPTION_ITEM (type, name, silver_cost, variant_id, sort_order)
    SELECT 'gift', N'Bàn phím cơ Rapoo V500', 800, id, 12 FROM PRODUCT_VARIANT WHERE id = 636;
END
GO
