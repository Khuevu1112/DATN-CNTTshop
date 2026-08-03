-- ============================================================
-- 74_wishlist.sql
-- Bang WISHLIST (san pham yeu thich) - mang ve tu nhanh "Review" cua teammate tren origin/main
-- (file goc "SQL Wishlist" o commit ecd916e), chuyen thanh migration co guard idempotent + DATETIME2
-- cho dung quy uoc cua repo nay. CHI mang phan bang nay sang - phan Thymeleaf PcBuild/Compare/
-- Address cung nam tren nhanh do KHONG duoc merge vi xung dot voi ban REST API hien tai.
--
-- File nay CHUA co code ung dung (entity/API/UI) di kem - moi co bang du lieu.
--
-- ASCII thuan, khong Vietnamese trong lenh => chay binh thuong bang sqlcmd, khong can -f 65001.
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'WISHLIST')
BEGIN
    CREATE TABLE WISHLIST (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL REFERENCES [USER](id),
        product_id INT NOT NULL REFERENCES PRODUCT(id),
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT UQ_WISHLIST UNIQUE (user_id, product_id)
    );
    CREATE INDEX IX_WISHLIST_user ON WISHLIST (user_id, created_at DESC);
END
GO
