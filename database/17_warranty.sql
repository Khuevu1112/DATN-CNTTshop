-- ============================================================
-- 17_warranty.sql
-- Bảo hành: 1 phiếu bảo hành / 1 dòng sản phẩm trong đơn (tự tạo khi đơn
-- chuyển trạng thái "delivered"), khách gửi yêu cầu xử lý sự cố,
-- admin tiếp nhận/xử lý + lịch sử trạng thái.
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'WARRANTY')
BEGIN
    CREATE TABLE WARRANTY (
        id            INT IDENTITY(1,1) PRIMARY KEY,
        order_item_id INT NOT NULL UNIQUE REFERENCES ORDER_ITEM(id),
        user_id       INT NOT NULL REFERENCES [USER](id),
        serial_number VARCHAR(100) NULL,
        start_date    DATE NOT NULL,
        end_date      DATE NOT NULL,
        status        VARCHAR(20) NOT NULL DEFAULT 'active'
                      CHECK (status IN ('active','expired','void'))
    );
    PRINT N'Da tao bang WARRANTY';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'WARRANTY_REQUEST')
BEGIN
    CREATE TABLE WARRANTY_REQUEST (
        id               INT IDENTITY(1,1) PRIMARY KEY,
        warranty_id      INT NOT NULL REFERENCES WARRANTY(id),
        issue_description NVARCHAR(1000) NOT NULL,
        request_status   VARCHAR(20) NOT NULL DEFAULT 'pending',
        created_at       DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT CK_WarrantyRequest_Status CHECK (request_status IN ('pending', 'accepted', 'processing', 'resolved', 'rejected'))
    );
    PRINT N'Da tao bang WARRANTY_REQUEST';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'WARRANTY_HISTORY')
BEGIN
    CREATE TABLE WARRANTY_HISTORY (
        id         INT IDENTITY(1,1) PRIMARY KEY,
        request_id INT NOT NULL REFERENCES WARRANTY_REQUEST(id),
        status     VARCHAR(20) NOT NULL,
        note       NVARCHAR(500) NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    PRINT N'Da tao bang WARRANTY_HISTORY';
END
GO
