-- Quản lý nhập hàng (tier cơ bản): ghi lại từng lần nhập kho / điều chỉnh kho để có lịch sử
-- (ai, khi nào, bao nhiêu, vì sao) thay vì admin ghi đè trực tiếp số "Số lượng còn" không dấu vết.
CREATE TABLE STOCK_MOVEMENT (
    id INT IDENTITY(1,1) PRIMARY KEY,
    variant_id INT NOT NULL REFERENCES PRODUCT_VARIANT(id),
    change_qty INT NOT NULL,
    reason VARCHAR(20) NOT NULL CHECK (reason IN ('nhap_hang', 'dieu_chinh')),
    unit_cost DECIMAL(18,2) NULL,
    note NVARCHAR(500) NULL,
    created_by INT NULL REFERENCES [USER](id),
    created_at DATETIME2 NOT NULL DEFAULT GETDATE()
);
CREATE INDEX IX_STOCK_MOVEMENT_VARIANT ON STOCK_MOVEMENT(variant_id, created_at DESC);
CREATE INDEX IX_STOCK_MOVEMENT_CREATED ON STOCK_MOVEMENT(created_at DESC);
