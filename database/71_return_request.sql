-- ============================================================
-- 71_return_request.sql
-- Chinh sach DOI TRA (1 doi 1 trong 7 ngay) — RIENG voi bao hanh (bao hanh la loi phat sinh khi
-- dung lau dai; doi tra la doi/tra ngay sau khi nhan hang). Khach gui yeu cau doi tra kem minh
-- chung: video loi, video tu tay mo hang (bat buoc voi don mua online de chong tranh chap), anh
-- loi. Nhan vien CSKH duyet.
--
-- ASCII thuan, chay: sqlcmd -f 65001 -i "D:\...\71_return_request.sql"
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'RETURN_REQUEST')
BEGIN
    CREATE TABLE RETURN_REQUEST (
        id INT IDENTITY(1,1) PRIMARY KEY,
        ma_yeu_cau VARCHAR(20) NOT NULL UNIQUE,      -- ma tra cuu, vd DT250728ABCD
        user_id INT NOT NULL REFERENCES [USER](id),

        -- Don hang lien quan (tuy chon — khach co the khong nho ma don, van cho gui). order_id
        -- giup CSKH doi chieu nhanh; order_item chua bat buoc vi 1 yeu cau co the ve ca don.
        order_id INT NULL REFERENCES [ORDER](id),
        ma_don NVARCHAR(40) NULL,
        ten_san_pham NVARCHAR(300) NULL,

        -- online => bat buoc co video mo hang; tai_cua_hang => khong bat buoc.
        kenh_mua VARCHAR(20) NOT NULL DEFAULT 'online',
        ly_do VARCHAR(30) NULL,                       -- loi_nsx / giao_sai / khong_dung_mo_ta / khac
        noi_dung NVARCHAR(2000) NOT NULL,

        -- Duong dan minh chung, luu /uploads/return/...
        video_loi NVARCHAR(300) NULL,
        video_mo_hang NVARCHAR(300) NULL,
        anh_loi1 NVARCHAR(300) NULL,
        anh_loi2 NVARCHAR(300) NULL,
        anh_loi3 NVARCHAR(300) NULL,

        -- cho_xu_ly -> dang_xu_ly -> chap_nhan | tu_choi -> hoan_tat
        trang_thai VARCHAR(20) NOT NULL DEFAULT 'cho_xu_ly',
        ghi_chu_cskh NVARCHAR(1000) NULL,

        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2 NULL
    );
    CREATE INDEX IX_RETURN_REQUEST_user ON RETURN_REQUEST (user_id, created_at DESC);
    CREATE INDEX IX_RETURN_REQUEST_status ON RETURN_REQUEST (trang_thai);
END
GO

-- Quyen: CSKH duyet doi tra (cung nhom voi lien he / lich hen dich vu).
IF NOT EXISTS (SELECT 1 FROM FEATURE WHERE feature_key = 'return_request')
BEGIN
    INSERT INTO FEATURE (feature_key, label, group_label, sort_order)
    VALUES ('return_request', N'Đổi trả hàng', N'Chăm sóc khách hàng', 86);
END
GO

IF NOT EXISTS (SELECT 1 FROM ROLE_PERMISSION WHERE feature_key = 'return_request')
BEGIN
    INSERT INTO ROLE_PERMISSION (department, feature_key, perm_key) VALUES
    ('cskh','return_request','view'),
    ('cskh','return_request','edit');
END
GO
