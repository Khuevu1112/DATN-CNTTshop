-- ============================================================
-- 64_trade_in.sql
-- Thu cũ đổi mới — chặng 1.
--
-- Bản chất nghiệp vụ: giá trị máy cũ chỉ biết chắc SAU KHI cầm máy trên tay. Vì vậy luôn tồn tại
-- hai con số — giá TẠM TÍNH (khách tự khai model + tình trạng + ảnh) và giá CHỐT (kỹ thuật kiểm
-- tra thật). Khách chỉ nhận được tín dụng ở bước thứ hai; trước đó không có đồng nào được cấp.
--
-- VÌ SAO KHÔNG PHÁT COUPON làm tín dụng (phương án đã cân nhắc và loại):
--   1. ORDER.coupon_id là FK đơn -> dùng tín dụng thu cũ sẽ mất quyền dùng mã khuyến mãi. Khách
--      đổi laptop 8 triệu mà không áp được mã sale là vô lý.
--   2. CouponService.layCouponHopLe KHÔNG kiểm tra mã thuộc về ai — mã là toàn cục theo code.
--      Một mã trị giá 8 triệu bị lộ thì bất kỳ ai cũng tiêu được.
-- Nên tín dụng có bảng riêng, gắn cứng user_id, và áp SONG SONG với coupon + Xu CT.
-- ============================================================
USE ShopDB;
GO

-- ===== 1. Yêu cầu thu cũ =====
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TRADE_IN_REQUEST')
BEGIN
    CREATE TABLE TRADE_IN_REQUEST (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL REFERENCES [USER](id),

        -- Khách tự khai
        loai_thiet_bi NVARCHAR(40) NOT NULL,      -- laptop / pc / man_hinh / linh_kien
        hang NVARCHAR(60) NULL,
        model NVARCHAR(160) NOT NULL,
        tinh_trang_khai NVARCHAR(30) NOT NULL,    -- moi_90 / tot / trung_binh / can_sua
        nam_mua INT NULL,
        mo_ta NVARCHAR(1000) NULL,
        serial NVARCHAR(80) NULL,

        -- Tối đa 4 ảnh hiện trạng, lưu đường dẫn /uploads/trade-in/...
        photo1 NVARCHAR(300) NULL,
        photo2 NVARCHAR(300) NULL,
        photo3 NVARCHAR(300) NULL,
        photo4 NVARCHAR(300) NULL,

        -- Hai con số tách bạch: tạm tính (báo online) và chốt (sau khi kiểm máy thật).
        gia_tam_tinh DECIMAL(12,2) NULL,
        gia_chot DECIMAL(12,2) NULL,

        -- cho_dinh_gia -> da_bao_gia -> khach_dong_y -> da_nhan_may -> da_kiem_tra
        --              -> da_cap_tin_dung | tu_choi_thu | khach_tu_choi | huy_yeu_cau
        trang_thai VARCHAR(20) NOT NULL DEFAULT 'cho_dinh_gia',
        ghi_chu_ktv NVARCHAR(1000) NULL,

        appraised_by INT NULL REFERENCES [USER](id),
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2 NULL
    );
    CREATE INDEX IX_TRADE_IN_REQUEST_user ON TRADE_IN_REQUEST (user_id, created_at DESC);
    CREATE INDEX IX_TRADE_IN_REQUEST_status ON TRADE_IN_REQUEST (trang_thai);
END
GO

-- ===== 2. Lịch sử trạng thái =====
-- Tách bảng riêng thay vì chỉ ghi đè trang_thai, cùng lý do với ORDER_STATUS_LOG: cần biết ai
-- đổi, khi nào, vì sao — nhất là khi có tranh chấp về giá định.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TRADE_IN_HISTORY')
BEGIN
    CREATE TABLE TRADE_IN_HISTORY (
        id INT IDENTITY(1,1) PRIMARY KEY,
        request_id INT NOT NULL REFERENCES TRADE_IN_REQUEST(id) ON DELETE CASCADE,
        trang_thai VARCHAR(20) NOT NULL,
        ghi_chu NVARCHAR(500) NULL,
        nguoi_thuc_hien INT NULL REFERENCES [USER](id),
        thoi_gian DATETIME2 NOT NULL DEFAULT GETDATE()
    );
END
GO

-- ===== 3. Tín dụng thu cũ =====
-- Tách khỏi TRADE_IN_REQUEST để tín dụng có vòng đời riêng (hết hạn, bị thu hồi, đã tiêu vào đơn
-- nào) mà không làm bẩn bảng yêu cầu.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TRADE_IN_CREDIT')
BEGIN
    CREATE TABLE TRADE_IN_CREDIT (
        id INT IDENTITY(1,1) PRIMARY KEY,
        request_id INT NOT NULL REFERENCES TRADE_IN_REQUEST(id),
        -- GẮN CỨNG người sở hữu: đây là điểm khác cốt lõi so với coupon. Người khác biết mã cũng
        -- không tiêu được vì mọi lượt áp đều kiểm user_id.
        user_id INT NOT NULL REFERENCES [USER](id),

        so_tien DECIMAL(12,2) NOT NULL,
        -- Đặt bằng chính so_tien khi phát hành: tín dụng dùng MỘT LẦN và không hoàn phần dư, nên
        -- ràng buộc đơn tối thiểu để khách không bao giờ bị mất tiền vì mua đơn nhỏ hơn.
        don_toi_thieu DECIMAL(12,2) NOT NULL DEFAULT 0,

        het_han DATETIME2 NULL,
        trang_thai VARCHAR(20) NOT NULL DEFAULT 'con_hieu_luc',  -- con_hieu_luc | da_dung | het_han | thu_hoi
        used_order_id INT NULL REFERENCES [ORDER](id),

        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        used_at DATETIME2 NULL
    );
    CREATE INDEX IX_TRADE_IN_CREDIT_user ON TRADE_IN_CREDIT (user_id, trang_thai);
END
GO

-- ===== 4. Ghi nhận phần giảm do thu cũ trên đơn =====
-- Cột riêng, KHÔNG gộp vào discount_amount: kế toán cần tách bạch "giảm giá khuyến mãi" với
-- "trừ vào tiền thu mua máy cũ" — bản chất hai khoản này khác hẳn nhau.
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='ORDER' AND COLUMN_NAME='trade_in_credit_id')
BEGIN
    ALTER TABLE [ORDER] ADD trade_in_credit_id INT NULL REFERENCES TRADE_IN_CREDIT(id);
END
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='ORDER' AND COLUMN_NAME='trade_in_amount')
BEGIN
    ALTER TABLE [ORDER] ADD trade_in_amount DECIMAL(12,2) NOT NULL DEFAULT 0;
END
GO

-- ===== 5. Quyền =====
-- FEATURE phải khai báo TRƯỚC ROLE_PERMISSION (có khoá ngoại feature_key), và cũng là nguồn dữ
-- liệu cho màn hình phân quyền của admin.
IF NOT EXISTS (SELECT 1 FROM FEATURE WHERE feature_key = 'trade_in')
BEGIN
    INSERT INTO FEATURE (feature_key, label, group_label, sort_order)
    VALUES ('trade_in', N'Thu cũ đổi mới', N'Bán hàng', 78);
END
GO

-- Kỹ thuật định giá máy; Kinh doanh theo dõi và chốt với khách.
IF NOT EXISTS (SELECT 1 FROM ROLE_PERMISSION WHERE feature_key='trade_in' AND department='ky_thuat')
BEGIN
    INSERT INTO ROLE_PERMISSION (department, feature_key, perm_key) VALUES
    ('ky_thuat','trade_in','view'),
    ('ky_thuat','trade_in','edit'),
    ('kinh_doanh','trade_in','view'),
    ('kinh_doanh','trade_in','edit');
END
GO
