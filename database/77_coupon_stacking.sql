-- ============================================================
-- 77_coupon_stacking.sql
-- Bổ sung khả năng ÁP DỤNG NHIỀU MÃ GIẢM GIÁ cùng lúc cho 1 đơn hàng.
--
-- 1) COUPON.stackable: mã có được phép dùng CHUNG với mã khác không.
--    Mặc định = 0 (KHÔNG cộng dồn) để giữ đúng hành vi hiện tại cho toàn
--    bộ mã cũ (chỉ dùng được 1 mình) — an toàn, không phá vỡ dữ liệu sẵn có.
-- 2) COUPON.exclusive_group: các mã CÙNG nhóm (khác NULL) loại trừ nhau dù
--    cả 2 đều stackable = 1 (dùng khi 2 mã stackable riêng lẻ nhưng không
--    muốn dùng chung, ví dụ 2 mã cùng 1 chương trình khuyến mãi).
-- 3) ORDER_COUPON: bảng lưu NHIỀU coupon cho 1 đơn hàng (đơn hàng trước
--    đây chỉ lưu được 1 coupon qua cột ORDER.coupon_id — cột này được GIỮ
--    NGUYÊN để tương thích ngược, luôn trỏ tới mã ĐẦU TIÊN trong danh sách
--    áp dụng; danh sách đầy đủ + số tiền giảm riêng từng mã nằm ở đây).
-- An toàn chạy 1 lần.
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('COUPON') AND name = 'stackable'
)
BEGIN
    ALTER TABLE COUPON ADD stackable BIT NOT NULL DEFAULT 0;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('COUPON') AND name = 'exclusive_group'
)
BEGIN
    ALTER TABLE COUPON ADD exclusive_group NVARCHAR(50) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ORDER_COUPON')
BEGIN
    CREATE TABLE ORDER_COUPON (
        order_id         INT NOT NULL,
        coupon_id        INT NOT NULL,
        discount_amount  DECIMAL(18, 2) NOT NULL,
        CONSTRAINT PK_ORDER_COUPON PRIMARY KEY (order_id, coupon_id),
        CONSTRAINT FK_ORDER_COUPON_ORDER FOREIGN KEY (order_id) REFERENCES [ORDER](id),
        CONSTRAINT FK_ORDER_COUPON_COUPON FOREIGN KEY (coupon_id) REFERENCES COUPON(id)
    );
END
GO

PRINT N'✅ Đã thêm stackable/exclusive_group cho COUPON và bảng ORDER_COUPON.';
GO
