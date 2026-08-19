-- ============================================================
-- 86_goods_receipt.sql
-- CHUẨN HOÁ NGHIỆP VỤ NHẬP KHO: nhà cung cấp + phiếu nhập kho nhiều dòng + hoá đơn in được.
--
-- Hiện trạng trước thay đổi: nhập kho chỉ là bảng STOCK_MOVEMENT — mỗi lần nhập là MỘT dòng
-- rời rạc (1 biến thể, 1 số lượng, 1 đơn giá, 1 ghi chú tự do). Từ đó không trả lời được những
-- câu hỏi cơ bản nhất của kho:
--   - Lô hàng hôm qua nhập của nhà cung cấp nào? (không có trường nhà cung cấp)
--   - Đối chiếu với hoá đơn số mấy? (không có số/ngày hoá đơn)
--   - Cả lô 12 mặt hàng đó tổng bao nhiêu tiền, VAT bao nhiêu? (12 dòng rời, không có đầu phiếu)
--   - In phiếu cho kế toán ký? (không có gì để in)
--
-- Thiết kế: tách 2 tầng, đúng như kế toán kho thật.
--   GOODS_RECEIPT       = CHỨNG TỪ nghiệp vụ (đầu phiếu): nhà cung cấp, số/ngày hoá đơn, VAT,
--                         tổng tiền, người lập. Đây là thứ đem in và ký.
--   GOODS_RECEIPT_ITEM  = các dòng hàng của phiếu.
--   STOCK_MOVEMENT      = SỔ CÁI tồn kho, giữ nguyên vai trò cũ. Mỗi dòng hàng của phiếu vẫn
--                         sinh đúng 1 dòng ở đây (thêm cột receipt_id trỏ ngược về phiếu), nên
--                         lịch sử tồn kho của một biến thể vẫn là một dòng thời gian liền mạch
--                         dù hàng vào bằng phiếu nhập hay bằng điều chỉnh tay.
--
-- Cố ý KHÔNG bỏ đường nhập nhanh cũ (điều chỉnh kho 1 dòng): kiểm kê lệch, hàng lỗi trả về,
-- quà tặng... vẫn cần sửa tồn mà không có hoá đơn nào để gắn.
-- ============================================================
USE ShopDB;
GO

-- ===== 1. Nhà cung cấp =====
IF OBJECT_ID('SUPPLIER', 'U') IS NULL
BEGIN
    CREATE TABLE SUPPLIER (
        id INT IDENTITY(1,1) PRIMARY KEY,
        ten NVARCHAR(200) NOT NULL,
        ma_so_thue VARCHAR(20) NULL,
        dien_thoai VARCHAR(30) NULL,
        email NVARCHAR(120) NULL,
        dia_chi NVARCHAR(300) NULL,
        nguoi_lien_he NVARCHAR(120) NULL,
        ghi_chu NVARCHAR(500) NULL,
        hien_thi BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    CREATE INDEX IX_SUPPLIER_TEN ON SUPPLIER(ten);
END
GO

-- ===== 2. Phiếu nhập kho (đầu phiếu) =====
IF OBJECT_ID('GOODS_RECEIPT', 'U') IS NULL
BEGIN
    CREATE TABLE GOODS_RECEIPT (
        id INT IDENTITY(1,1) PRIMARY KEY,
        -- Mã phiếu tự sinh dạng PNyyMMdd-#### — dùng để tra cứu và in lên chứng từ.
        ma_phieu VARCHAR(30) NOT NULL UNIQUE,
        supplier_id INT NULL REFERENCES SUPPLIER(id),

        -- Đối chiếu với hoá đơn GTGT của nhà cung cấp. Để trống khi nhập hàng chưa có hoá đơn.
        so_hoa_don NVARCHAR(60) NULL,
        ngay_hoa_don DATE NULL,

        ngay_nhap DATETIME2 NOT NULL DEFAULT GETDATE(),

        -- Tiền: lưu CẢ ba con số thay vì tính lại khi hiển thị. Thuế suất và đơn giá có thể đổi
        -- theo thời gian, chứng từ đã lập thì con số trên đó không được đổi theo.
        vat_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
        tien_hang DECIMAL(18,2) NOT NULL DEFAULT 0,
        tien_vat DECIMAL(18,2) NOT NULL DEFAULT 0,
        tong_tien DECIMAL(18,2) NOT NULL DEFAULT 0,

        ghi_chu NVARCHAR(500) NULL,
        created_by INT NULL REFERENCES [USER](id),
        created_at DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    CREATE INDEX IX_GOODS_RECEIPT_NGAY ON GOODS_RECEIPT(ngay_nhap DESC);
    CREATE INDEX IX_GOODS_RECEIPT_NCC ON GOODS_RECEIPT(supplier_id);
END
GO

-- ===== 3. Dòng hàng của phiếu =====
IF OBJECT_ID('GOODS_RECEIPT_ITEM', 'U') IS NULL
BEGIN
    CREATE TABLE GOODS_RECEIPT_ITEM (
        id INT IDENTITY(1,1) PRIMARY KEY,
        receipt_id INT NOT NULL REFERENCES GOODS_RECEIPT(id) ON DELETE CASCADE,
        variant_id INT NOT NULL REFERENCES PRODUCT_VARIANT(id),

        -- CHỤP LẠI tên/SKU tại thời điểm nhập, cùng lý do với ORDER_ITEM: sản phẩm đổi tên sau
        -- này thì phiếu đã in vẫn phải khớp với bản lưu trong hệ thống.
        ten_san_pham NVARCHAR(300) NOT NULL,
        sku NVARCHAR(100) NULL,

        so_luong INT NOT NULL,
        don_gia DECIMAL(18,2) NOT NULL DEFAULT 0,
        thanh_tien DECIMAL(18,2) NOT NULL DEFAULT 0,
        ghi_chu NVARCHAR(300) NULL
    );
    CREATE INDEX IX_GR_ITEM_RECEIPT ON GOODS_RECEIPT_ITEM(receipt_id);
    CREATE INDEX IX_GR_ITEM_VARIANT ON GOODS_RECEIPT_ITEM(variant_id);
END
GO

-- ===== 4. Nối sổ cái tồn kho về phiếu =====
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='STOCK_MOVEMENT' AND COLUMN_NAME='receipt_id')
BEGIN
    ALTER TABLE STOCK_MOVEMENT ADD receipt_id INT NULL REFERENCES GOODS_RECEIPT(id);
END
GO

-- ===== 5. Vài nhà cung cấp mẫu để dùng được ngay =====
IF NOT EXISTS (SELECT 1 FROM SUPPLIER)
BEGIN
    INSERT INTO SUPPLIER (ten, ma_so_thue, dien_thoai, dia_chi, nguoi_lien_he) VALUES
    (N'Công ty TNHH Phân phối Công nghệ Việt', '0101234567', '024 3555 1234',
     N'Số 12 Lê Duẩn, Hoàn Kiếm, Hà Nội', N'Nguyễn Văn Bình'),
    (N'Công ty CP Máy tính Đại Việt', '0301987654', '028 3822 7788',
     N'45 Nguyễn Thị Minh Khai, Quận 1, TP.HCM', N'Trần Thu Hà'),
    (N'Nhà phân phối Linh kiện Hải Phòng', '0201456789', '0225 3826 555',
     N'88 Tô Hiệu, Lê Chân, Hải Phòng', N'Phạm Quốc Anh');
END
GO
