-- ============================================================
-- 61_membership_subscription.sql
-- GÓI HỘI VIÊN TRẢ PHÍ "CNTT Care" — TÁCH RỜI hoàn toàn với hạng thành viên tích luỹ
-- (MembershipTier: Đồng/Bạc/Vàng/Kim cương xét theo xu đã kiếm). Đây là chương trình BÁN
-- DỊCH VỤ có trần chi phí, KHÔNG bán % giảm giá hàng và KHÔNG tặng xu — nếu tặng xu là gián
-- tiếp bán hạng tích luỹ, phá mốc 60/100/200 triệu (xem MembershipTier + XuEconomyTest).
--
-- Vì sao cấu hình gói để DB (khác MembershipTier hardcode enum): giá gói và hạn mức quyền lợi
-- là thứ marketing chỉnh theo mùa; mốc hạng tích luỹ thì khoá cứng trong code vì gắn tỉ giá xu.
-- Ràng buộc kinh tế "giá gói > chi phí quyền lợi tối đa/năm" được canh bằng SubscriptionEconomyTest
-- trên đúng bộ số seed dưới đây — sửa số ở DB thì phải tự đảm bảo bất biến đó không vỡ.
--
-- Quyền lợi có hạn mức (interprovince ship, vệ sinh, tận nơi, máy mượn) được đếm bằng SỔ
-- GIAO DỊCH SUBSCRIPTION_USAGE (mỗi dòng là 1 lượt dùng delta=+1 hoặc hoàn delta=-1), giống
-- cách WALLET_TRANSACTION đếm xu — còn lại = hạn mức - tổng(delta). Nhờ vậy huỷ đơn hoàn lại
-- lượt giao hàng liên tỉnh đã tiêu y như hoàn xu (xem SubscriptionService.hoanLuotTheoDon).
-- ============================================================
USE ShopDB;
GO

-- 1) Cấu hình gói. Marker cột BIT = quyền lợi bật/tắt; cột INT = hạn mức/năm; cột DECIMAL = tiền.
IF OBJECT_ID('SUBSCRIPTION_PLAN', 'U') IS NULL
BEGIN
    CREATE TABLE SUBSCRIPTION_PLAN (
        id                       INT IDENTITY(1,1) PRIMARY KEY,
        code                     VARCHAR(30)   NOT NULL UNIQUE,   -- basic / plus / pro
        name                     NVARCHAR(80)  NOT NULL,
        price                    DECIMAL(12,2) NOT NULL,
        duration_months          INT           NOT NULL DEFAULT 12,
        sort_order               INT           NOT NULL DEFAULT 0,
        -- Ship nội thành Hải Phòng = xe của shop, chi phí biên ~0 nên cho không giới hạn (giống
        -- MembershipTier free nội thành từ bậc Bạc). Chỉ các quyền lợi shop trả bên thứ 3 / tốn
        -- công thợ mới đặt hạn mức.
        free_inner_shipping      BIT           NOT NULL DEFAULT 0,  -- free ship thường nội thành
        free_express_inner       BIT           NOT NULL DEFAULT 0,  -- free luôn cả hoả tốc nội thành
        interprovince_quota      INT           NOT NULL DEFAULT 0,  -- số lượt free ship liên tỉnh / năm
        warranty_priority        BIT           NOT NULL DEFAULT 0,  -- ưu tiên hàng đợi bảo hành (cờ)
        cleaning_quota           INT           NOT NULL DEFAULT 0,  -- số lần vệ sinh máy / năm
        thermal_paste            BIT           NOT NULL DEFAULT 0,  -- vệ sinh có kèm tra keo tản nhiệt
        onsite_warranty_quota    INT           NOT NULL DEFAULT 0,  -- số lượt bảo hành tận nơi / năm
        loaner_quota             INT           NOT NULL DEFAULT 0,  -- số lượt mượn máy khi đang bảo hành
        flash_sale_early         BIT           NOT NULL DEFAULT 0,  -- vào flash sale sớm (cờ)
        pc_build_consult         BIT           NOT NULL DEFAULT 0,  -- tư vấn build PC 1-1 (cờ)
        activation_voucher_amount DECIMAL(12,2) NULL,               -- voucher tặng khi kích hoạt (NULL = không)
        activation_voucher_min    DECIMAL(12,2) NULL,               -- đơn tối thiểu để dùng voucher đó
        is_active                BIT           NOT NULL DEFAULT 1
    );
END
GO

-- 2) Đăng ký của khách. started_at/expires_at NULL tới khi thanh toán thành công mới điền
--    (xem SubscriptionService.kichHoatSauThanhToan). status: pending -> active -> expired.
IF OBJECT_ID('USER_SUBSCRIPTION', 'U') IS NULL
BEGIN
    CREATE TABLE USER_SUBSCRIPTION (
        id           INT IDENTITY(1,1) PRIMARY KEY,
        user_id      INT NOT NULL,
        plan_id      INT NOT NULL,
        started_at   DATETIME2 NULL,
        expires_at   DATETIME2 NULL,
        status       VARCHAR(20) NOT NULL DEFAULT 'pending',
        created_at   DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT FK_USER_SUB_USER FOREIGN KEY (user_id) REFERENCES [USER](id),
        CONSTRAINT FK_USER_SUB_PLAN FOREIGN KEY (plan_id) REFERENCES SUBSCRIPTION_PLAN(id)
    );
END
GO

-- 3) Sổ giao dịch tiêu/hoàn lượt quyền lợi có hạn mức (ledger). Còn lại = hạn mức - SUM(delta).
IF OBJECT_ID('SUBSCRIPTION_USAGE', 'U') IS NULL
BEGIN
    CREATE TABLE SUBSCRIPTION_USAGE (
        id              INT IDENTITY(1,1) PRIMARY KEY,
        subscription_id INT NOT NULL,
        benefit_key     VARCHAR(40) NOT NULL,   -- interprovince_ship / cleaning / onsite_warranty / loaner
        delta           INT NOT NULL,           -- +1 = tiêu 1 lượt, -1 = hoàn 1 lượt
        order_id        INT NULL,               -- đơn gắn với lượt (để hoàn khi đơn bị huỷ)
        note            NVARCHAR(255) NULL,
        created_at      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT FK_SUB_USAGE_SUB FOREIGN KEY (subscription_id) REFERENCES USER_SUBSCRIPTION(id)
    );
END
GO

-- 4) PAYMENT dùng chung cho cả đơn hàng lẫn mua gói: order_id phải cho NULL (mua gói không có
--    đơn hàng), thêm subscription_id. Đúng 1 trong 2 cột có giá trị (không ràng buộc cứng ở DB
--    để khỏi vướng dữ liệu payment cũ, VNPayController rẽ nhánh theo cột nào khác NULL).
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
           WHERE TABLE_NAME='PAYMENT' AND COLUMN_NAME='order_id' AND IS_NULLABLE='NO')
BEGIN
    ALTER TABLE PAYMENT ALTER COLUMN order_id INT NULL;
END
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME='PAYMENT' AND COLUMN_NAME='subscription_id')
BEGIN
    ALTER TABLE PAYMENT ADD subscription_id INT NULL
        CONSTRAINT FK_PAYMENT_SUBSCRIPTION REFERENCES USER_SUBSCRIPTION(id);
END
GO

-- 5) Seed 3 gói. Bộ số này bị SubscriptionEconomyTest canh: giá > chi phí quyền lợi tối đa/năm.
--    Chi phí tham chiếu (giá vốn shop) định nghĩa trong SubscriptionPlan.chiPhiToiDaMotNam().
IF NOT EXISTS (SELECT 1 FROM SUBSCRIPTION_PLAN WHERE code='basic')
BEGIN
    INSERT INTO SUBSCRIPTION_PLAN
        (code, name, price, duration_months, sort_order,
         free_inner_shipping, free_express_inner, interprovince_quota,
         warranty_priority, cleaning_quota, thermal_paste,
         onsite_warranty_quota, loaner_quota, flash_sale_early, pc_build_consult,
         activation_voucher_amount, activation_voucher_min, is_active)
    VALUES
        ('basic', N'CNTT Care Cơ bản', 149000, 12, 1,
         1, 0, 1,
         1, 1, 0,
         0, 0, 0, 0,
         NULL, NULL, 1),
        ('plus',  N'CNTT Care Plus',   399000, 12, 2,
         1, 1, 2,
         1, 2, 1,
         0, 0, 0, 0,
         50000, 2000000, 1),
        ('pro',   N'CNTT Care Pro',    899000, 12, 3,
         1, 1, 4,
         1, 3, 1,
         2, 1, 1, 1,
         100000, 3000000, 1);
END
GO
