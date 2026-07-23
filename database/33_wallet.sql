-- ============================================================
-- 33_wallet.sql
-- Ví CNTTShop (giai đoạn 1): số dư token vàng/bạc + sổ giao dịch + theo dõi nạp ví qua
-- Stripe. Token vàng mua bằng tiền thật (mô phỏng, Stripe test mode — không xử lý tiền
-- thật), token bạc kiếm được khi mua hàng (xem WalletService/OrderService).
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name='WALLET' AND xtype='U')
BEGIN
    CREATE TABLE WALLET (
        id INT IDENTITY(1,1) PRIMARY KEY,

        user_id INT NOT NULL UNIQUE
            REFERENCES [USER](id),

        gold_balance INT NOT NULL DEFAULT 0,

        silver_balance INT NOT NULL DEFAULT 0,

        updated_at DATETIME2 NOT NULL DEFAULT GETDATE()
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name='WALLET_TRANSACTION' AND xtype='U')
BEGIN
    CREATE TABLE WALLET_TRANSACTION (
        id INT IDENTITY(1,1) PRIMARY KEY,

        wallet_id INT NOT NULL
            REFERENCES WALLET(id) ON DELETE CASCADE,

        token_type VARCHAR(10) NOT NULL
            CHECK (token_type IN ('gold', 'silver')),

        -- deposit = nạp tiền thật đổi vàng, earn = kiếm bạc từ mua hàng,
        -- redeem = đổi bạc lấy coupon/quà (giai đoạn 2), spend = tiêu vàng đổi bạc/khác,
        -- adjust = admin điều chỉnh tay
        type VARCHAR(20) NOT NULL
            CHECK (type IN ('deposit', 'earn', 'redeem', 'spend', 'adjust')),

        -- Số dương = cộng, số âm = trừ (đơn vị: số token, không phải tiền)
        amount INT NOT NULL,

        note NVARCHAR(255),

        ref_order_id INT NULL
            REFERENCES [ORDER](id),

        created_at DATETIME2 NOT NULL DEFAULT GETDATE()
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name='WALLET_TOPUP' AND xtype='U')
BEGIN
    CREATE TABLE WALLET_TOPUP (
        id INT IDENTITY(1,1) PRIMARY KEY,

        user_id INT NOT NULL
            REFERENCES [USER](id),

        vnd_amount DECIMAL(18,2) NOT NULL,

        gold_amount INT NOT NULL,

        status VARCHAR(20) NOT NULL DEFAULT 'pending'
            CHECK (status IN ('pending', 'paid', 'failed')),

        transaction_ref VARCHAR(200),

        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),

        paid_at DATETIME2 NULL
    );
END
GO
