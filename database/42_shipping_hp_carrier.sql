-- ============================================================
-- 42_shipping_hp_carrier.sql
-- Phí ship thật thay cho phí cố định 30.000đ (xem OrderService.PHI_VAN_CHUYEN_MAC_DINH):
--   - Trong Hải Phòng: SHIPPING_HP_TIER (cùng Phường Hải An = rẻ nhất, phường khác = tier còn
--     lại) x hệ số hoả tốc (+30%, hardcode trong ShippingService, không cần bảng riêng).
--   - Ngoài Hải Phòng: CARRIER (5 hãng, phí "liên tỉnh/liên miền" gộp — không phân biệt cùng
--     miền/khác miền về GIÁ, chỉ khác THỜI GIAN giao dự kiến).
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'SHIPPING_HP_TIER')
BEGIN
    CREATE TABLE SHIPPING_HP_TIER (
        id INT IDENTITY(1,1) PRIMARY KEY,
        tier_key VARCHAR(20) NOT NULL UNIQUE,
        label NVARCHAR(100) NOT NULL,
        fee DECIMAL(12,2) NOT NULL
    );
    INSERT INTO SHIPPING_HP_TIER (tier_key, label, fee) VALUES
    ('same_ward', N'Cùng phường Hải An (mốc 118 Cát Bi)', 15000),
    ('other_ward', N'Phường khác trong Hải Phòng', 25000);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'CARRIER')
BEGIN
    CREATE TABLE CARRIER (
        id INT IDENTITY(1,1) PRIMARY KEY,
        code VARCHAR(20) NOT NULL UNIQUE,
        name NVARCHAR(100) NOT NULL,
        fee_lien_tinh DECIMAL(12,2) NOT NULL,
        time_cung_mien NVARCHAR(50) NOT NULL,
        time_khac_mien NVARCHAR(50) NOT NULL,
        is_active BIT NOT NULL DEFAULT 1,
        thu_tu INT NOT NULL DEFAULT 0
    );
    -- Phí = trung bình khoảng phí "liên tỉnh/liên miền" admin cung cấp, làm tròn — admin có thể
    -- sửa lại số thật qua trang Quản lý giao hàng. Thời gian lấy nguyên theo bảng admin cung cấp.
    INSERT INTO CARRIER (code, name, fee_lien_tinh, time_cung_mien, time_khac_mien, thu_tu) VALUES
    ('spx', N'Shopee Xpress (SPX)', 20000, N'2-3 ngày', N'3-5 ngày', 1),
    ('ghtk', N'Giao Hàng Tiết Kiệm (GHTK)', 37500, N'1-2 ngày', N'3-4 ngày', 2),
    ('ghn', N'Giao Hàng Nhanh (GHN)', 42500, N'1-3 ngày', N'3-4 ngày', 3),
    ('jnt', N'J&T Express', 37500, N'2-4 ngày', N'4-7 ngày', 4),
    ('viettel_post', N'Viettel Post', 49000, N'2-3 ngày', N'3-5 ngày', 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='ORDER' AND COLUMN_NAME='shipping_option_code')
BEGIN
    ALTER TABLE [ORDER] ADD shipping_option_code VARCHAR(20) NULL;
END
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='ORDER' AND COLUMN_NAME='shipping_option_label')
BEGIN
    ALTER TABLE [ORDER] ADD shipping_option_label NVARCHAR(100) NULL;
END
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='ORDER' AND COLUMN_NAME='shipping_eta')
BEGIN
    ALTER TABLE [ORDER] ADD shipping_eta NVARCHAR(50) NULL;
END
GO
