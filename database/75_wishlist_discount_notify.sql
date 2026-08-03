-- ============================================================
-- 75_wishlist_discount_notify.sql
-- Bo sung co "da bao giam gia" cho WISHLIST (bang goc tao o 74_wishlist.sql). Dung de chan gui
-- mail trung: moi lan gia san pham GIAM, gui 1 lan cho tung nguoi da yeu thich roi bat co nay
-- len; gia TANG tro lai thi mo lai co (cho phep bao lan giam tiep theo). Xem
-- AdminProductService.update() + WishlistService.baoGiamGia/moKhoaNhacGiamGia.
--
-- ASCII thuan, khong Vietnamese trong lenh => chay binh thuong bang sqlcmd, khong can -f 65001.
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME='WISHLIST' AND COLUMN_NAME='discount_notified')
BEGIN
    ALTER TABLE WISHLIST ADD discount_notified BIT NOT NULL DEFAULT 0;
END
GO
