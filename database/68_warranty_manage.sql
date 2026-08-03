-- ============================================================
-- 68_warranty_manage.sql
-- Trang "Quan ly bao hanh ca nhan" phia USER can hai thu o tang du lieu:
--
--   1. MA BAO HANH cho tung phieu -- cu phap BHCNTT + 4 ky tu. Day la ma khach dung de tra cuu
--      thong tin / tinh trang / dang ky bao hanh. Khac serial_number (in tren tem may, co the
--      trong): ma nay do shop cap, luon co, va la khoa tra cuu chinh thuc.
--
--   2. Yeu cau bao hanh gan them lich hen: ngay hen, hinh thuc (tan noi co phu phi / mang toi
--      cua hang), va trung tam khach chon khi mang toi.
--
-- KHONG dung BOM/tieng Viet trong cau lenh: toan bo chu tieng Viet nam trong comment, moi cau
-- lenh thuc thi deu ASCII (ma sinh tu NEWID hex), nen chay bang sqlcmd khong can co -f 65001.
-- ============================================================
USE ShopDB;
GO

-- ===== 1. Ma bao hanh cho moi phieu =====
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME='WARRANTY' AND COLUMN_NAME='ma_bao_hanh')
BEGIN
    ALTER TABLE WARRANTY ADD ma_bao_hanh VARCHAR(20) NULL;
END
GO

-- Cap ma cho cac phieu cu con trong. Sinh ngau nhien + kiem trung trong vong lap thay vi bam
-- theo id: ma bam id thi doan duoc ca day (BHCNTT0001, 0002...), trong khi trang tra cuu cong
-- khai lo duoc tinh trang bao hanh -- ma kho doan la lop chan toi thieu. Phieu moi do Java tu
-- sinh ma (cung cach) TRUOC khi luu nen khong roi vao day.
DECLARE @id INT, @code VARCHAR(20);
DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT id FROM WARRANTY WHERE ma_bao_hanh IS NULL;
OPEN cur;
FETCH NEXT FROM cur INTO @id;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @code = NULL;
    WHILE @code IS NULL OR EXISTS (SELECT 1 FROM WARRANTY WHERE ma_bao_hanh = @code)
        SET @code = 'BHCNTT' + UPPER(SUBSTRING(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 1, 4));
    UPDATE WARRANTY SET ma_bao_hanh = @code WHERE id = @id;
    FETCH NEXT FROM cur INTO @id;
END
CLOSE cur;
DEALLOCATE cur;
GO

-- Sau khi da cap du, khoa NOT NULL + UNIQUE. Khong dung filtered index (tranh rang buoc
-- QUOTED_IDENTIFIER cho moi thao tac ghi ve sau) -- Java sinh ma truoc khi luu nen khong co
-- khoanh khac NULL tam thoi can ne.
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
           WHERE TABLE_NAME='WARRANTY' AND COLUMN_NAME='ma_bao_hanh' AND IS_NULLABLE='YES')
BEGIN
    ALTER TABLE WARRANTY ALTER COLUMN ma_bao_hanh VARCHAR(20) NOT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_WARRANTY_ma_bao_hanh')
BEGIN
    CREATE UNIQUE INDEX UX_WARRANTY_ma_bao_hanh ON WARRANTY (ma_bao_hanh);
END
GO

-- ===== 2. Lich hen gan vao yeu cau bao hanh =====
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME='WARRANTY_REQUEST' AND COLUMN_NAME='ngay_hen')
BEGIN
    ALTER TABLE WARRANTY_REQUEST ADD ngay_hen DATE NULL;
END
GO

-- tan_noi = bao hanh tan noi (co phu phi) | cua_hang = mang toi cua hang gan nhat
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME='WARRANTY_REQUEST' AND COLUMN_NAME='hinh_thuc')
BEGIN
    ALTER TABLE WARRANTY_REQUEST ADD hinh_thuc VARCHAR(20) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME='WARRANTY_REQUEST' AND COLUMN_NAME='center_id')
BEGIN
    ALTER TABLE WARRANTY_REQUEST ADD center_id INT NULL REFERENCES SERVICE_CENTER(id);
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME='WARRANTY_REQUEST' AND COLUMN_NAME='phu_phi')
BEGIN
    ALTER TABLE WARRANTY_REQUEST ADD phu_phi DECIMAL(12,2) NOT NULL DEFAULT 0;
END
GO
