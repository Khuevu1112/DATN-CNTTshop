-- ============================================================
-- 79_return_restock.sql
-- HOAN TON KHO khi don doi/tra hoan tat, va cho phep ADMIN tu khoi tao yeu cau doi tra.
--
-- Truoc day RETURN_REQUEST chi luu ten_san_pham dang chu tu do nen he thong khong biet phai
-- cong lai ton kho cho BIEN THE nao => hang tra ve bien mat khoi so sach. Bo sung:
--   variant_id  : bien the cu the duoc doi/tra (lay tu dong san pham trong don)
--   so_luong    : so luong tra ve kho
--   da_hoan_kho : chong cong kho 2 lan neu yeu cau bi chuyen trang thai lap lai
--   tao_boi_admin : phan biet yeu cau do CSKH tu khoi tao voi yeu cau khach tu gui
--
-- An toan chay 1 lan.
-- ASCII thuan, chay: sqlcmd -f 65001 -i "D:\...\79_return_restock.sql"
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('RETURN_REQUEST') AND name = 'variant_id'
)
BEGIN
    ALTER TABLE RETURN_REQUEST
    ADD variant_id INT NULL REFERENCES PRODUCT_VARIANT(id);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('RETURN_REQUEST') AND name = 'so_luong'
)
BEGIN
    ALTER TABLE RETURN_REQUEST ADD so_luong INT NULL;
END
GO

-- Mac dinh 0: cac yeu cau CU (truoc migration nay) coi nhu chua hoan kho. Chung khong co
-- variant_id nen se khong duoc cong kho tu dong — dung y do, tranh cong bu khong co can cu.
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('RETURN_REQUEST') AND name = 'da_hoan_kho'
)
BEGIN
    ALTER TABLE RETURN_REQUEST
    ADD da_hoan_kho BIT NOT NULL CONSTRAINT DF_RETURN_REQUEST_da_hoan_kho DEFAULT 0;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('RETURN_REQUEST') AND name = 'tao_boi_admin'
)
BEGIN
    ALTER TABLE RETURN_REQUEST
    ADD tao_boi_admin BIT NOT NULL CONSTRAINT DF_RETURN_REQUEST_tao_boi_admin DEFAULT 0;
END
GO

-- CSKH truoc day chi 'view' + 'edit' (duyet yeu cau khach gui). Nay CSKH tu khoi tao duoc
-- yeu cau ho khach nen can them quyen 'add'. Role admin luon duoc bo qua kiem tra quyen
-- (xem PermissionAspect) nen khong can seed rieng.
IF NOT EXISTS (
    SELECT 1 FROM ROLE_PERMISSION
    WHERE department = 'cskh' AND feature_key = 'return_request' AND perm_key = 'add'
)
BEGIN
    INSERT INTO ROLE_PERMISSION (department, feature_key, perm_key)
    VALUES ('cskh','return_request','add');
END
GO

PRINT N'79_return_restock.sql: da bo sung variant_id, so_luong, da_hoan_kho, tao_boi_admin cho RETURN_REQUEST + quyen add cho CSKH.';
GO
