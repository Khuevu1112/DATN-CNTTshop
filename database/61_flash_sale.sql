-- ============================================================
-- 61_flash_sale.sql
-- Flash sale — thuộc nhóm Quản lý khuyến mãi (cùng feature RBAC "coupons").
--
-- Quy tắc nghiệp vụ: CHỈ tồn tại tối đa 1 flash sale đang hoạt động tại một thời điểm. Chưa có
-- thì admin tạo mới; đang có thì chỉ được sửa cái đó, không tạo thêm (xem FlashSaleService).
--
-- Tách "bản đang sửa" và "bản đã public":
--   - Các cột thường (title, subtitle, màu, thời gian, danh sách sản phẩm ở FLASH_SALE_ITEM) là
--     BẢN NHÁP admin đang chỉnh. Sửa tới đâu lưu tới đó, đóng trình duyệt mở lại không mất —
--     đây là phần "lưu lại phiên bản gần nhất".
--   - published_payload là ẢNH CHỤP JSON tại lần bấm Public gần nhất. Khách hàng CHỈ đọc cột
--     này, nên admin sửa dở dang giữa chừng không làm hỏng banner đang chạy ngoài trang chủ.
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FLASH_SALE')
BEGIN
    CREATE TABLE FLASH_SALE (
        id INT IDENTITY(1,1) PRIMARY KEY,

        -- Nội dung admin sửa được trực tiếp trên trang khuyến mãi
        title NVARCHAR(120) NOT NULL DEFAULT N'FLASH SALE',
        subtitle NVARCHAR(255) NULL,

        -- Màu dải gradient của banner, admin đổi được (xem bảng màu dựng sẵn ở PromotionsView)
        color_from VARCHAR(9) NOT NULL DEFAULT '#ff3d24',
        color_to VARCHAR(9) NOT NULL DEFAULT '#ff9500',

        starts_at DATETIME2 NOT NULL,
        ends_at DATETIME2 NOT NULL,

        -- Admin tắt tay mà không cần xoá. Banner chỉ hiện khi is_active=1 VÀ đang trong khung giờ.
        is_active BIT NOT NULL DEFAULT 1,

        -- Ảnh chụp JSON của lần Public gần nhất; NULL = chưa từng public, khách chưa thấy gì.
        published_payload NVARCHAR(MAX) NULL,
        published_at DATETIME2 NULL,

        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2 NULL,
        updated_by INT NULL REFERENCES [USER](id)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FLASH_SALE_ITEM')
BEGIN
    CREATE TABLE FLASH_SALE_ITEM (
        id INT IDENTITY(1,1) PRIMARY KEY,
        flash_sale_id INT NOT NULL REFERENCES FLASH_SALE(id) ON DELETE CASCADE,
        variant_id INT NOT NULL REFERENCES PRODUCT_VARIANT(id),

        -- Giá bán trong đợt sale. Lưu riêng chứ không tính % từ giá gốc: giá gốc có thể bị sửa
        -- giữa đợt, khi đó số tiền khách nhìn thấy sẽ tự nhảy theo mà không ai chủ động duyệt.
        sale_price DECIMAL(12,2) NOT NULL,

        sort_order INT NOT NULL DEFAULT 0,

        CONSTRAINT UQ_FLASH_SALE_ITEM UNIQUE (flash_sale_id, variant_id)
    );
END
GO

-- Mỗi biến thể chỉ nằm 1 lần trong 1 đợt sale (ràng buộc UNIQUE ở trên đã lo). Index phục vụ
-- truy vấn "lấy đợt đang chạy" mà khách gọi ở mọi lượt vào trang chủ.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FLASH_SALE_active')
BEGIN
    CREATE INDEX IX_FLASH_SALE_active ON FLASH_SALE (is_active, starts_at, ends_at);
END
GO
