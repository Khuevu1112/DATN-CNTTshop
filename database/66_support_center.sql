-- ============================================================
-- 66_support_center.sql
-- Trung tâm hỗ trợ — gom 6 mảng nội dung/dịch vụ hậu mãi vào một khu vực:
--   1. Trung tâm bảo hành (SERVICE_CENTER)      -> tra cứu điểm bảo hành gần nhất
--   2. Thông tin bảo hành (WARRANTY_POLICY)     -> bảng thời hạn theo nhóm hàng + tra cứu serial
--   3. Đặt lịch dịch vụ  (SERVICE_APPOINTMENT)  -> khách hẹn giờ mang máy tới, tránh xếp hàng
--   4. Bảng giá sửa chữa (REPAIR_PRICE)         -> giá linh kiện + công thợ, THAM KHẢO
--   5. FAQ               (FAQ_CATEGORY/FAQ_ITEM)
--   6. Trang chủ hỗ trợ                          -> thuần frontend, không cần bảng
--
-- VÌ SAO TÁCH SERVICE_CENTER KHỎI SỔ ĐỊA CHỈ (USER_ADDRESS):
-- USER_ADDRESS là địa chỉ NHẬN HÀNG của một người dùng cụ thể, có vòng đời gắn với tài khoản
-- (xoá tài khoản là mất). Trung tâm bảo hành là tài sản của shop, công khai với mọi khách kể cả
-- chưa đăng nhập, và cần thêm giờ mở cửa / loại dịch vụ nhận. Hai thứ không cùng bản chất.
--
-- VÌ SAO REPAIR_PRICE KHÔNG THAM CHIẾU PRODUCT:
-- Shop sửa cả máy khách mua nơi khác (đó chính là mục đích của bảng giá công khai). Ràng buộc
-- vào PRODUCT sẽ chặn mất phần lớn nhu cầu thật. Vì vậy model lưu dạng chuỗi tự do + nhóm thiết
-- bị, và chỉ dùng để BÁO THAM KHẢO — giá chốt luôn do kỹ thuật quyết sau khi kiểm máy.
-- ============================================================
USE ShopDB;
GO

-- ===== 1. Trung tâm bảo hành / điểm dịch vụ =====
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'SERVICE_CENTER')
BEGIN
    CREATE TABLE SERVICE_CENTER (
        id INT IDENTITY(1,1) PRIMARY KEY,
        ten NVARCHAR(160) NOT NULL,
        dia_chi NVARCHAR(300) NOT NULL,
        province_id INT NULL REFERENCES PROVINCE(id),
        ward_id INT NULL REFERENCES WARD(id),

        -- Toạ độ dùng để sắp xếp theo khoảng cách (Haversine) và cắm ghim lên bản đồ. Cho phép
        -- NULL để admin kịp tạo điểm mới rồi cắm mốc sau, nhưng điểm chưa có toạ độ sẽ không bao
        -- giờ lọt vào kết quả "gần tôi nhất" — SupportService lọc bỏ ngay từ truy vấn.
        lat DECIMAL(10,7) NULL,
        lng DECIMAL(10,7) NULL,

        dien_thoai NVARCHAR(40) NULL,
        email NVARCHAR(120) NULL,
        gio_mo_cua NVARCHAR(200) NULL,          -- vd "T2-T7: 8:00-18:00 · CN: 8:00-12:00"

        -- CSV mã nhóm thiết bị nhận sửa: laptop,pc,man_hinh,linh_kien,may_in,thiet_bi_mang
        -- Dùng CSV thay vì bảng nối vì tập giá trị đóng (6 mã, do FE hiển thị) và không bao giờ
        -- cần truy vấn ngược "trung tâm nào nhận X" theo cách phải JOIN — LIKE là đủ.
        dich_vu VARCHAR(200) NULL,

        -- uy_quyen = trung tâm uỷ quyền của hãng; chi_nhanh = cửa hàng/kho của chính CNTTShop
        loai VARCHAR(20) NOT NULL DEFAULT 'chi_nhanh',
        nhan_dat_lich BIT NOT NULL DEFAULT 1,
        ghi_chu NVARCHAR(500) NULL,

        hien_thi BIT NOT NULL DEFAULT 1,
        sort_order INT NOT NULL DEFAULT 100,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    CREATE INDEX IX_SERVICE_CENTER_province ON SERVICE_CENTER (province_id, hien_thi);
END
GO

-- ===== 2. Đặt lịch dịch vụ =====
-- KHÔNG gộp vào WARRANTY_REQUEST: yêu cầu bảo hành bắt buộc phải có phiếu bảo hành (tức là đã
-- mua hàng ở shop), còn đặt lịch mở cho cả khách vãng lai mang máy mua nơi khác tới sửa dịch vụ.
-- Khi khách có phiếu bảo hành thì gắn kèm warranty_id để kỹ thuật biết trước là ca miễn phí.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'SERVICE_APPOINTMENT')
BEGIN
    CREATE TABLE SERVICE_APPOINTMENT (
        id INT IDENTITY(1,1) PRIMARY KEY,
        ma_lich VARCHAR(20) NOT NULL UNIQUE,     -- mã tra cứu công khai, vd "SV250724ABCD"

        center_id INT NOT NULL REFERENCES SERVICE_CENTER(id),
        user_id INT NULL REFERENCES [USER](id),  -- NULL = khách vãng lai không đăng nhập
        warranty_id INT NULL REFERENCES WARRANTY(id),

        ho_ten NVARCHAR(120) NOT NULL,
        dien_thoai NVARCHAR(40) NOT NULL,
        email NVARCHAR(120) NULL,

        loai_thiet_bi NVARCHAR(40) NOT NULL,     -- laptop / pc / man_hinh / linh_kien / may_in / thiet_bi_mang
        model NVARCHAR(160) NULL,
        mo_ta_loi NVARCHAR(1000) NOT NULL,

        ngay_hen DATE NOT NULL,
        khung_gio VARCHAR(20) NOT NULL,          -- vd "09:00-10:00"

        -- cho_xac_nhan -> da_xac_nhan -> dang_xu_ly -> hoan_thanh | khach_khong_den | da_huy
        trang_thai VARCHAR(20) NOT NULL DEFAULT 'cho_xac_nhan',
        ghi_chu_ktv NVARCHAR(1000) NULL,

        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2 NULL
    );
    CREATE INDEX IX_SERVICE_APPOINTMENT_center ON SERVICE_APPOINTMENT (center_id, ngay_hen);
    CREATE INDEX IX_SERVICE_APPOINTMENT_user ON SERVICE_APPOINTMENT (user_id, created_at DESC);
END
GO

-- Một khung giờ / một trung tâm chỉ nhận một lượt (kỹ thuật viên trực quầy tiếp nhận tuần tự).
-- Đặt ở tầng CSDL vì hai khách bấm cùng lúc thì kiểm tra ở tầng service vẫn lọt — chỉ UNIQUE
-- INDEX mới chặn được thật. Lịch đã huỷ/khách không đến phải nhả chỗ ra, nên dùng filtered index.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_SERVICE_APPOINTMENT_slot')
BEGIN
    CREATE UNIQUE INDEX UX_SERVICE_APPOINTMENT_slot
        ON SERVICE_APPOINTMENT (center_id, ngay_hen, khung_gio)
        WHERE trang_thai NOT IN ('da_huy', 'khach_khong_den');
END
GO

-- ===== 3. Bảng giá sửa chữa / linh kiện =====
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'REPAIR_PRICE')
BEGIN
    CREATE TABLE REPAIR_PRICE (
        id INT IDENTITY(1,1) PRIMARY KEY,
        loai_thiet_bi NVARCHAR(40) NOT NULL,     -- laptop / pc / man_hinh / linh_kien / may_in / thiet_bi_mang
        hang NVARCHAR(60) NULL,                  -- NULL = áp cho mọi hãng
        dong_may NVARCHAR(160) NULL,             -- NULL = áp cho mọi dòng trong nhóm

        ma_loi VARCHAR(40) NOT NULL,             -- man_hinh_vo, pin_chai, ban_phim, quat_tan_nhiet...
        ten_loi NVARCHAR(160) NOT NULL,

        -- Tách bạch tiền linh kiện và tiền công: khách hay thắc mắc "sao thay pin lại đắt thế",
        -- hiện tách ra thì tự hiểu. Cũng để kế toán tính biên lãi phần công riêng.
        gia_linh_kien DECIMAL(12,2) NOT NULL DEFAULT 0,
        tien_cong DECIMAL(12,2) NOT NULL DEFAULT 0,

        -- Khoảng giá khi không thể chốt một con số (vd main laptop phụ thuộc đời máy). Có giá_den
        -- thì FE hiển thị "x – y", không có thì hiển thị một số.
        gia_den DECIMAL(12,2) NULL,

        thoi_gian_du_kien NVARCHAR(60) NULL,     -- vd "2-4 giờ", "1-2 ngày"
        bao_hanh_thang INT NOT NULL DEFAULT 3,   -- bảo hành cho chính lần sửa này
        ghi_chu NVARCHAR(500) NULL,

        hien_thi BIT NOT NULL DEFAULT 1,
        sort_order INT NOT NULL DEFAULT 100,
        updated_at DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    CREATE INDEX IX_REPAIR_PRICE_loai ON REPAIR_PRICE (loai_thiet_bi, hien_thi);
END
GO

-- ===== 4. Thời hạn bảo hành theo nhóm hàng =====
-- PRODUCT.warranty_months (xem 44_warranty_months.sql) là thời hạn của TỪNG sản phẩm cụ thể và
-- vẫn là nguồn sự thật khi lập phiếu. Bảng này chỉ phục vụ trang "Thông tin bảo hành" — nơi cần
-- công bố chính sách theo NHÓM hàng cho cả sản phẩm shop chưa từng bán.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'WARRANTY_POLICY')
BEGIN
    CREATE TABLE WARRANTY_POLICY (
        id INT IDENTITY(1,1) PRIMARY KEY,
        nhom_hang NVARCHAR(160) NOT NULL,
        so_thang INT NOT NULL,
        mo_ta NVARCHAR(500) NULL,
        tinh_tu NVARCHAR(120) NOT NULL DEFAULT N'Ngày xuất hoá đơn',
        hien_thi BIT NOT NULL DEFAULT 1,
        sort_order INT NOT NULL DEFAULT 100
    );
END
GO

-- ===== 5. FAQ =====
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FAQ_CATEGORY')
BEGIN
    CREATE TABLE FAQ_CATEGORY (
        id INT IDENTITY(1,1) PRIMARY KEY,
        ma VARCHAR(40) NOT NULL UNIQUE,
        ten NVARCHAR(120) NOT NULL,
        mo_ta NVARCHAR(300) NULL,
        icon NVARCHAR(20) NULL,
        hien_thi BIT NOT NULL DEFAULT 1,
        sort_order INT NOT NULL DEFAULT 100
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FAQ_ITEM')
BEGIN
    CREATE TABLE FAQ_ITEM (
        id INT IDENTITY(1,1) PRIMARY KEY,
        category_id INT NOT NULL REFERENCES FAQ_CATEGORY(id) ON DELETE CASCADE,
        cau_hoi NVARCHAR(400) NOT NULL,
        tra_loi NVARCHAR(MAX) NOT NULL,
        -- Từ khoá phụ cho ô tìm kiếm: khách gõ "ship" nhưng câu trả lời viết "vận chuyển".
        tu_khoa NVARCHAR(300) NULL,
        noi_bat BIT NOT NULL DEFAULT 0,
        luot_xem INT NOT NULL DEFAULT 0,
        hien_thi BIT NOT NULL DEFAULT 1,
        sort_order INT NOT NULL DEFAULT 100,
        updated_at DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    CREATE INDEX IX_FAQ_ITEM_category ON FAQ_ITEM (category_id, hien_thi);
END
GO

-- ============================================================
--  DỮ LIỆU MẪU
-- ============================================================

-- ----- Trung tâm bảo hành -----
-- Tra province_id theo code để seed không phụ thuộc thứ tự IDENTITY của bảng PROVINCE.
IF NOT EXISTS (SELECT 1 FROM SERVICE_CENTER)
BEGIN
    INSERT INTO SERVICE_CENTER (ten, dia_chi, province_id, lat, lng, dien_thoai, email, gio_mo_cua, dich_vu, loai, sort_order) VALUES
    (N'CNTTShop Hải Phòng — Trung tâm bảo hành chính',
     N'118 Cát Bi, Hải An, Thành phố Hải Phòng',
     (SELECT id FROM PROVINCE WHERE code = '31'), 20.8248000, 106.7169000,
     N'0835 344 974', N'baohanh.hp@cnttshop.vn',
     N'T2-T7: 8:00-18:00 · CN: 8:00-12:00',
     'laptop,pc,man_hinh,linh_kien,may_in,thiet_bi_mang', 'chi_nhanh', 10),

    (N'CNTTShop Hải Phòng — Chi nhánh Lê Chân',
     N'245 Tô Hiệu, Lê Chân, Thành phố Hải Phòng',
     (SELECT id FROM PROVINCE WHERE code = '31'), 20.8449000, 106.6763000,
     N'0225 3838 111', N'lechan@cnttshop.vn',
     N'T2-CN: 8:30-20:00',
     'laptop,pc,man_hinh,linh_kien', 'chi_nhanh', 20),

    (N'CNTTShop Hà Nội — Trung tâm dịch vụ',
     N'89 Thái Hà, Đống Đa, Thành phố Hà Nội',
     (SELECT id FROM PROVINCE WHERE code = '01'), 21.0122000, 105.8221000,
     N'024 3555 8899', N'baohanh.hn@cnttshop.vn',
     N'T2-T7: 8:00-18:30 · CN: 9:00-17:00',
     'laptop,pc,man_hinh,linh_kien,may_in,thiet_bi_mang', 'chi_nhanh', 30),

    (N'CNTTShop Hà Nội — Chi nhánh Cầu Giấy',
     N'12 Trần Thái Tông, Cầu Giấy, Thành phố Hà Nội',
     (SELECT id FROM PROVINCE WHERE code = '01'), 21.0316000, 105.7871000,
     N'024 3766 2200', N'caugiay@cnttshop.vn',
     N'T2-CN: 8:30-20:00',
     'laptop,man_hinh,linh_kien', 'chi_nhanh', 40),

    (N'Trung tâm uỷ quyền Quảng Ninh',
     N'368 Nguyễn Văn Cừ, Hạ Long, Tỉnh Quảng Ninh',
     (SELECT id FROM PROVINCE WHERE code = '22'), 20.9557000, 107.0752000,
     N'0203 3626 888', N'quangninh@cnttshop.vn',
     N'T2-T7: 8:00-17:30',
     'laptop,pc,man_hinh', 'uy_quyen', 50),

    (N'CNTTShop Đà Nẵng — Trung tâm dịch vụ',
     N'201 Nguyễn Văn Linh, Hải Châu, Thành phố Đà Nẵng',
     (SELECT id FROM PROVINCE WHERE code = '48'), 16.0603000, 108.2135000,
     N'0236 3777 456', N'baohanh.dn@cnttshop.vn',
     N'T2-T7: 8:00-18:00',
     'laptop,pc,man_hinh,linh_kien,may_in', 'chi_nhanh', 60),

    (N'CNTTShop TP. Hồ Chí Minh — Trung tâm dịch vụ',
     N'391 Nguyễn Thị Minh Khai, Quận 3, Thành phố Hồ Chí Minh',
     (SELECT id FROM PROVINCE WHERE code = '79'), 10.7724000, 106.6889000,
     N'028 3925 6677', N'baohanh.hcm@cnttshop.vn',
     N'T2-T7: 8:00-19:00 · CN: 9:00-17:00',
     'laptop,pc,man_hinh,linh_kien,may_in,thiet_bi_mang', 'chi_nhanh', 70),

    (N'Trung tâm uỷ quyền Cần Thơ',
     N'88 đường 3 Tháng 2, Ninh Kiều, Thành phố Cần Thơ',
     (SELECT id FROM PROVINCE WHERE code = '92'), 10.0303000, 105.7690000,
     N'0292 3898 234', N'cantho@cnttshop.vn',
     N'T2-T7: 8:00-17:30',
     'laptop,man_hinh,linh_kien', 'uy_quyen', 80);
END
GO

-- ----- Thời hạn bảo hành theo nhóm hàng -----
IF NOT EXISTS (SELECT 1 FROM WARRANTY_POLICY)
BEGIN
    INSERT INTO WARRANTY_POLICY (nhom_hang, so_thang, mo_ta, tinh_tu, sort_order) VALUES
    (N'Laptop / Máy tính xách tay', 24, N'Bảo hành chính hãng toàn bộ máy. Pin và bộ sạc bảo hành 12 tháng.', N'Ngày xuất hoá đơn', 10),
    (N'PC lắp ráp trọn bộ', 36, N'Bảo hành theo từng linh kiện, hỗ trợ kiểm tra và vệ sinh miễn phí trọn đời máy.', N'Ngày xuất hoá đơn', 20),
    (N'CPU / Mainboard / RAM', 36, N'Bảo hành đổi mới trong 30 ngày đầu nếu lỗi do nhà sản xuất.', N'Ngày xuất hoá đơn', 30),
    (N'Ổ cứng SSD / HDD', 36, N'Không bảo hành dữ liệu. Khách hàng tự sao lưu trước khi gửi máy.', N'Ngày xuất hoá đơn', 40),
    (N'Card đồ hoạ (VGA)', 36, N'Mất tem, cong chân, cháy nổ do quá áp không thuộc phạm vi bảo hành.', N'Ngày xuất hoá đơn', 50),
    (N'Màn hình máy tính', 24, N'Áp dụng chính sách điểm chết theo tiêu chuẩn của từng hãng.', N'Ngày xuất hoá đơn', 60),
    (N'Nguồn (PSU) / Vỏ case', 36, N'Vỏ case bảo hành phần khung và quạt kèm theo.', N'Ngày xuất hoá đơn', 70),
    (N'Tản nhiệt nước AIO', 24, N'Rò rỉ dung dịch trong thời hạn được đổi mới và đền bù linh kiện hỏng kèm.', N'Ngày xuất hoá đơn', 80),
    (N'Bàn phím / Chuột / Tai nghe', 12, N'Không bảo hành phần đệm mút, dây bọc và các chi tiết hao mòn tự nhiên.', N'Ngày xuất hoá đơn', 90),
    (N'Phụ kiện (cáp, đế tản, túi chống sốc)', 6, N'Đổi mới trong 7 ngày nếu lỗi nhà sản xuất.', N'Ngày xuất hoá đơn', 100),
    (N'Pin laptop / Bộ sạc', 12, N'Chai pin dưới 60% dung lượng thiết kế được xem là lỗi thuộc bảo hành.', N'Ngày xuất hoá đơn', 110),
    (N'Máy in / Thiết bị mạng', 24, N'Đầu in, mực và hộp mực là vật tư tiêu hao, không thuộc phạm vi bảo hành.', N'Ngày xuất hoá đơn', 120);
END
GO

-- ----- Bảng giá sửa chữa tham khảo -----
IF NOT EXISTS (SELECT 1 FROM REPAIR_PRICE)
BEGIN
    INSERT INTO REPAIR_PRICE (loai_thiet_bi, hang, dong_may, ma_loi, ten_loi, gia_linh_kien, tien_cong, gia_den, thoi_gian_du_kien, bao_hanh_thang, sort_order) VALUES
    -- Laptop
    (N'laptop', NULL, NULL, 'man_hinh_vo',      N'Thay màn hình vỡ / sọc / chảy mực',  1850000, 250000, 6500000, N'2-4 giờ', 6, 10),
    (N'laptop', NULL, NULL, 'pin_chai',         N'Thay pin chai / sụt nguồn',           950000, 150000, 2400000, N'1-2 giờ', 6, 20),
    (N'laptop', NULL, NULL, 'ban_phim',         N'Thay bàn phím liệt / kẹt phím',       450000, 200000, 1400000, N'2-3 giờ', 6, 30),
    (N'laptop', NULL, NULL, 've_sinh_tan_nhiet',N'Vệ sinh + tra keo tản nhiệt',              0, 250000,  400000, N'1 giờ',   3, 40),
    (N'laptop', NULL, NULL, 'quat_tan_nhiet',   N'Thay quạt tản nhiệt kêu / không quay', 350000, 250000,  900000, N'2 giờ',   6, 50),
    (N'laptop', NULL, NULL, 'ban_le',           N'Sửa / thay bản lề gãy',                380000, 350000, 1200000, N'1 ngày',  6, 60),
    (N'laptop', NULL, NULL, 'main_lo',          N'Sửa main không lên nguồn',            1200000, 500000, 5500000, N'2-5 ngày',3, 70),
    (N'laptop', NULL, NULL, 'cong_sac',         N'Thay chân sạc / jack DC',              250000, 300000,  850000, N'1 ngày',  6, 80),
    (N'laptop', NULL, NULL, 'cai_dat_os',       N'Cài đặt hệ điều hành + driver',              0, 150000,  250000, N'1 giờ',   1, 90),
    (N'laptop', NULL, NULL, 'nang_cap_ram_ssd', N'Nâng cấp RAM / SSD (chưa gồm linh kiện)',    0, 100000,  200000, N'30 phút', 1, 100),
    -- PC
    (N'pc', NULL, NULL, 'khong_len_nguon',  N'Kiểm tra PC không lên nguồn',            0, 200000,  500000, N'1 ngày',  3, 110),
    (N'pc', NULL, NULL, 've_sinh_pc',       N'Vệ sinh toàn bộ + tra keo CPU',          0, 250000,  450000, N'1-2 giờ', 3, 120),
    (N'pc', NULL, NULL, 'thay_nguon',       N'Thay nguồn (PSU) hỏng',            750000, 150000, 3200000, N'1-2 giờ', 12, 130),
    (N'pc', NULL, NULL, 'thay_main',        N'Thay mainboard',                  1600000, 300000, 8500000, N'1 ngày',  12, 140),
    (N'pc', NULL, NULL, 'di_lai_day',       N'Đi lại dây + sắp xếp luồng gió',         0, 200000,  350000, N'1-2 giờ', 1, 150),
    -- Màn hình
    (N'man_hinh', NULL, NULL, 'man_hinh_soc',  N'Thay panel màn hình sọc / đốm',   1400000, 300000, 4800000, N'2-4 ngày', 6, 160),
    (N'man_hinh', NULL, NULL, 'nguon_man_hinh',N'Sửa board nguồn màn hình',         400000, 250000, 1200000, N'1-2 ngày', 6, 170),
    (N'man_hinh', NULL, NULL, 'den_nen',       N'Thay đèn nền LED',                 550000, 350000, 1600000, N'2-3 ngày', 6, 180),
    -- Linh kiện lẻ
    (N'linh_kien', NULL, NULL, 'cuu_du_lieu', N'Cứu dữ liệu ổ cứng (mức cơ bản)',     0, 800000, 3500000, N'2-7 ngày', 0, 190),
    (N'linh_kien', NULL, NULL, 'test_linh_kien', N'Kiểm tra & test linh kiện',            0, 100000,  200000, N'1 giờ',   0, 200),
    -- Máy in
    (N'may_in', NULL, NULL, 'ket_giay',   N'Xử lý kẹt giấy / thay lô sấy',   450000, 250000, 1500000, N'1 ngày', 3, 210),
    (N'may_in', NULL, NULL, 'do_muc',     N'Đổ mực + vệ sinh hộp mực',       120000,  80000,  350000, N'30 phút', 1, 220),
    -- Thiết bị mạng
    (N'thiet_bi_mang', NULL, NULL, 'cau_hinh_router', N'Cấu hình router / phát wifi',   0, 200000,  400000, N'1 giờ', 1, 230),
    (N'thiet_bi_mang', NULL, NULL, 'bam_day_mang',    N'Bấm dây mạng + đi dây tại nhà', 0, 150000,  500000, N'1-2 giờ', 1, 240);
END
GO

-- ----- FAQ -----
IF NOT EXISTS (SELECT 1 FROM FAQ_CATEGORY)
BEGIN
    INSERT INTO FAQ_CATEGORY (ma, ten, mo_ta, icon, sort_order) VALUES
    ('tai_khoan',   N'Tài khoản',              N'Đăng ký, đăng nhập, quên mật khẩu và bảo mật tài khoản', N'👤', 10),
    ('don_hang',    N'Sản phẩm & Đơn hàng',    N'Đặt hàng, theo dõi đơn và thay đổi thông tin đơn',       N'📦', 20),
    ('thanh_toan',  N'Thanh toán & Trả góp',   N'Các hình thức thanh toán, VNPay, trả góp và hoá đơn',    N'💳', 30),
    ('giao_hang',   N'Giao hàng & Lắp đặt',    N'Phí ship, thời gian giao và dịch vụ lắp đặt tại nhà',    N'🚚', 40),
    ('doi_tra',     N'Đổi trả & Huỷ đơn',      N'Điều kiện đổi trả, huỷ đơn và hoàn tiền',                N'↩️', 50),
    ('bao_hanh',    N'Bảo hành & Dịch vụ',     N'Chính sách bảo hành, sửa chữa và đặt lịch dịch vụ',      N'🛡️', 60),
    ('thu_cu',      N'Thu cũ đổi mới',         N'Định giá máy cũ, tín dụng thu cũ và cách sử dụng',       N'🔄', 70),
    ('xu_uu_dai',   N'Xu CT & Ưu đãi',         N'Tích Xu, đổi thưởng, hạng thành viên và gói CNTT Care',  N'🎁', 80),
    ('build_pc',    N'Xây dựng cấu hình PC',   N'Công cụ build PC, tương thích linh kiện và tư vấn',      N'🖥️', 90),
    ('ho_tro',      N'Liên hệ & Hỗ trợ',       N'Kênh liên hệ, giờ làm việc và khiếu nại',                N'💬', 100);
END
GO

IF NOT EXISTS (SELECT 1 FROM FAQ_ITEM)
BEGIN
    INSERT INTO FAQ_ITEM (category_id, cau_hoi, tra_loi, tu_khoa, noi_bat, sort_order) VALUES
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='tai_khoan'),
     N'Tôi quên mật khẩu thì lấy lại bằng cách nào?',
     N'Tại màn hình đăng nhập, bấm "Quên mật khẩu" và nhập email đã đăng ký. Hệ thống gửi mã OTP 6 số về email, mã có hiệu lực trong 10 phút. Nhập đúng mã là bạn đặt được mật khẩu mới ngay.',
     N'quen mat khau, otp, reset password', 1, 10),
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='tai_khoan'),
     N'Tôi đăng nhập bằng Google được không?',
     N'Được. Bấm "Đăng nhập với Google" ở trang đăng nhập. Nếu email Google trùng với tài khoản đã có, hai tài khoản sẽ được gộp làm một, toàn bộ đơn hàng và Xu CT giữ nguyên.',
     N'google, oauth, dang nhap nhanh', 0, 20),
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='tai_khoan'),
     N'Vì sao tài khoản của tôi bị khoá?',
     N'Tài khoản có thể bị tạm khoá khi phát hiện hành vi gian lận đơn hàng, lạm dụng chương trình đổi thưởng hoặc theo yêu cầu của chính chủ. Bạn sẽ nhận được email nêu rõ lý do và thời hạn khoá. Liên hệ hotline để được xem xét mở lại.',
     N'khoa tai khoan, bi ban', 0, 30),

    ((SELECT id FROM FAQ_CATEGORY WHERE ma='don_hang'),
     N'Làm sao để theo dõi đơn hàng của tôi?',
     N'Vào Tài khoản → Đơn hàng của tôi. Mỗi đơn hiển thị trạng thái theo thời gian thực: Chờ xác nhận → Đã xác nhận → Đang đóng gói → Đang giao → Đã giao. Bạn cũng nhận được thông báo trong ứng dụng ở mỗi lần đổi trạng thái.',
     N'tracking, theo doi don, trang thai don hang', 1, 10),
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='don_hang'),
     N'Tôi muốn sửa địa chỉ nhận hàng sau khi đặt?',
     N'Khi đơn còn ở trạng thái "Chờ xác nhận", bạn liên hệ hotline để nhân viên cập nhật giúp. Từ trạng thái "Đang đóng gói" trở đi, đơn đã vào tuyến giao nên không đổi được địa chỉ — lúc này chỉ có thể huỷ đơn và đặt lại.',
     N'doi dia chi, sua don hang', 0, 20),
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='don_hang'),
     N'Sản phẩm hết hàng thì bao giờ có lại?',
     N'Sản phẩm hết hàng vẫn hiển thị trên website kèm nhãn "Hết hàng". Thời gian về hàng phụ thuộc lịch nhập của từng hãng, thường 7–20 ngày. Bạn để lại số điện thoại qua form liên hệ để được báo ngay khi có hàng.',
     N'het hang, con hang khong', 0, 30),

    ((SELECT id FROM FAQ_CATEGORY WHERE ma='thanh_toan'),
     N'CNTTShop hỗ trợ những hình thức thanh toán nào?',
     N'Hiện có 4 hình thức: thanh toán khi nhận hàng (COD), chuyển khoản ngân hàng, cổng VNPay (thẻ nội địa/quốc tế, QR, ví điện tử) và thẻ quốc tế qua Stripe. Riêng đơn giá trị lớn trên 20 triệu, shop khuyến nghị chuyển khoản hoặc VNPay để rút ngắn thời gian xác nhận.',
     N'vnpay, cod, chuyen khoan, stripe, tra tien', 1, 10),
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='thanh_toan'),
     N'Trả góp 0% áp dụng cho sản phẩm nào?',
     N'Áp dụng cho đơn từ 3 triệu đồng, kỳ hạn 3/6/9/12 tháng. Lãi suất và khoản trả hàng tháng hiện ngay tại trang sản phẩm — bạn xem được trước cả khi đăng nhập. Hồ sơ trả góp cần CCCD và sẽ được duyệt trong 30 phút giờ hành chính.',
     N'tra gop, lai suat 0%, ky han', 1, 20),
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='thanh_toan'),
     N'Tôi có được xuất hoá đơn VAT không?',
     N'Có. Ghi thông tin công ty (tên, mã số thuế, địa chỉ) vào ô ghi chú khi đặt hàng, hoặc gửi qua form liên hệ trong vòng 24 giờ kể từ khi đặt. Hoá đơn điện tử được gửi về email trong 3 ngày làm việc.',
     N'hoa don vat, xuat hoa don, mst', 0, 30),

    ((SELECT id FROM FAQ_CATEGORY WHERE ma='giao_hang'),
     N'Phí giao hàng được tính như thế nào?',
     N'Nội thành Hải Phòng tính theo quãng đường thật từ kho tới điểm bạn cắm trên bản đồ, có hai mức: giao thường và giao hoả tốc trong 2 giờ. Ngoài Hải Phòng tính theo bảng phí của đơn vị vận chuyển, chia theo cùng miền hoặc liên miền. Phí hiển thị đầy đủ ở bước thanh toán trước khi bạn xác nhận.',
     N'phi ship, phi van chuyen, freeship, hoa toc', 1, 10),
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='giao_hang'),
     N'Vì sao tôi phải cắm mốc trên bản đồ khi thêm địa chỉ?',
     N'Vì phí giao nội thành Hải Phòng tính theo quãng đường thật. Cắm mốc giúp báo đúng phí ngay từ đầu thay vì phát sinh khi giao, đồng thời shipper tìm được nhà nhanh hơn với ngõ nhỏ.',
     N'ban do, cam moc, toa do, dia chi', 0, 20),
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='giao_hang'),
     N'PC lắp ráp có được lắp đặt tại nhà không?',
     N'Có, miễn phí trong nội thành Hải Phòng và Hà Nội. Kỹ thuật viên mang máy tới, đấu nối, cài hệ điều hành, driver và test ổn định trước khi bàn giao. Khu vực khác tính phí theo quãng đường, báo trước khi đi.',
     N'lap dat, setup tai nha, ky thuat', 0, 30),

    ((SELECT id FROM FAQ_CATEGORY WHERE ma='doi_tra'),
     N'Điều kiện đổi trả hàng là gì?',
     N'Đổi trả trong 7 ngày kể từ ngày nhận với hàng lỗi do nhà sản xuất, hoặc giao sai mẫu/sai cấu hình. Sản phẩm phải còn đủ hộp, phụ kiện, tem niêm phong và không có dấu hiệu va đập, vào nước. Hàng đổi trả vì "không thích nữa" chỉ áp dụng với phụ kiện chưa bóc seal.',
     N'doi tra, tra hang, 7 ngay, refund', 1, 10),
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='doi_tra'),
     N'Tôi huỷ đơn thì bao lâu được hoàn tiền?',
     N'Đơn COD huỷ trước khi giao thì không phát sinh gì. Đơn đã thanh toán online được hoàn về nguồn tiền gốc trong 3–7 ngày làm việc, tuỳ ngân hàng. Nếu bạn đã dùng Xu CT hoặc tín dụng thu cũ trong đơn, phần đó được trả lại vào ví ngay khi đơn chuyển sang trạng thái đã huỷ.',
     N'huy don, hoan tien, refund, xu', 0, 20),

    ((SELECT id FROM FAQ_CATEGORY WHERE ma='bao_hanh'),
     N'Tôi tra cứu thời hạn bảo hành ở đâu?',
     N'Có hai cách. Đã đăng nhập: vào Tài khoản → Bảo hành, mọi phiếu bảo hành của bạn nằm ở đó kèm ngày hết hạn. Chưa đăng nhập: vào trang Thông tin bảo hành và nhập số serial in trên tem máy để tra cứu nhanh.',
     N'tra cuu bao hanh, serial, imei, han bao hanh', 1, 10),
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='bao_hanh'),
     N'Trường hợp nào bị từ chối bảo hành?',
     N'Máy mất tem hoặc tem bị rách/sửa; hư hỏng do rơi vỡ, vào nước, cháy nổ do nguồn điện; tự tháo máy hoặc đã sửa ở nơi khác; hao mòn tự nhiên của vật tư tiêu hao (pin dưới ngưỡng chai cho phép, keo tản nhiệt, đệm mút). Các trường hợp này vẫn được sửa dịch vụ theo bảng giá công khai.',
     N'tu choi bao hanh, mat tem, roi vo', 1, 20),
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='bao_hanh'),
     N'Đặt lịch mang máy tới trung tâm như thế nào?',
     N'Vào trang Trung tâm bảo hành, chọn điểm gần bạn nhất rồi bấm "Đặt lịch". Chọn ngày, khung giờ, mô tả lỗi và để lại số điện thoại. Bạn nhận được mã lịch hẹn để tra cứu, kỹ thuật sẽ gọi xác nhận trước giờ hẹn.',
     N'dat lich, hen gio, trung tam bao hanh', 1, 30),
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='bao_hanh'),
     N'Máy mua ở nơi khác có sửa được tại CNTTShop không?',
     N'Được. Shop nhận sửa dịch vụ cho mọi máy, không bắt buộc phải mua tại CNTTShop. Giá tham khảo xem tại trang Bảng giá sửa chữa, giá chốt do kỹ thuật báo sau khi kiểm máy thật và luôn hỏi ý bạn trước khi làm.',
     N'sua may ngoai, dich vu sua chua', 0, 40),

    ((SELECT id FROM FAQ_CATEGORY WHERE ma='thu_cu'),
     N'Thu cũ đổi mới hoạt động ra sao?',
     N'Bạn khai model, tình trạng và gửi tối đa 4 ảnh máy. Shop báo giá tạm tính trong 24 giờ. Đồng ý thì mang máy tới (hoặc shop qua lấy), kỹ thuật kiểm tra và chốt giá thật. Sau khi chốt, bạn nhận tín dụng thu cũ dùng để trừ thẳng vào đơn mua máy mới.',
     N'thu cu doi moi, ban may cu, dinh gia', 1, 10),
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='thu_cu'),
     N'Tín dụng thu cũ dùng chung với mã giảm giá được không?',
     N'Được, và đây là điểm khác biệt so với việc phát mã giảm giá. Tín dụng thu cũ áp song song với mã khuyến mãi và Xu CT trong cùng một đơn. Lưu ý tín dụng dùng một lần, không hoàn phần dư, nên shop đặt luôn mức đơn tối thiểu bằng chính giá trị tín dụng để bạn không bị mất tiền.',
     N'tin dung, ma giam gia, coupon, xu', 0, 20),

    ((SELECT id FROM FAQ_CATEGORY WHERE ma='xu_uu_dai'),
     N'Xu CT là gì và tích được bằng cách nào?',
     N'Xu CT là điểm thưởng nội bộ của CNTTShop, quy đổi 100.000 Xu = 100.000đ khi thanh toán. Bạn tích Xu qua mua hàng thành công, điểm danh mỗi ngày và viết đánh giá sản phẩm kèm ảnh.',
     N'xu ct, diem thuong, tich diem, quy doi', 1, 10),
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='xu_uu_dai'),
     N'Hạng thành viên khác gì gói CNTT Care?',
     N'Hạng thành viên là miễn phí, tự thăng cấp theo tổng Xu tích luỹ, cho bạn ưu đãi phần trăm giảm giá. Gói CNTT Care là gói dịch vụ trả phí — vệ sinh máy định kỳ, ưu tiên kỹ thuật, hỗ trợ tận nơi. Hai thứ độc lập, dùng đồng thời được.',
     N'hang thanh vien, cntt care, goi hoi vien, vip', 0, 20),

    ((SELECT id FROM FAQ_CATEGORY WHERE ma='build_pc'),
     N'Công cụ xây dựng cấu hình PC có kiểm tra tương thích không?',
     N'Có. Công cụ cảnh báo khi socket CPU không khớp mainboard, loại RAM sai thế hệ, công suất nguồn không đủ hoặc VGA/tản nhiệt quá dài so với vỏ case. Bạn vẫn lưu được cấu hình có cảnh báo để nhân viên tư vấn xem lại cùng bạn.',
     N'build pc, tuong thich, socket, nguon', 1, 10),
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='build_pc'),
     N'Tôi lưu cấu hình rồi mua sau được không?',
     N'Được. Cấu hình lưu trong tài khoản, không giới hạn số bản. Khi quyết định mua, bấm "Thêm tất cả vào giỏ" là toàn bộ linh kiện vào giỏ theo giá tại thời điểm đó.',
     N'luu cau hinh, gio hang', 0, 20),

    ((SELECT id FROM FAQ_CATEGORY WHERE ma='ho_tro'),
     N'Giờ làm việc của bộ phận hỗ trợ?',
     N'Hotline 0835 344 974 và Zalo trực từ 8:00 đến 22:00 tất cả các ngày, kể cả lễ Tết. Email cskh@cnttshop.vn phản hồi trong 24 giờ. Trung tâm bảo hành làm theo giờ riêng của từng điểm, xem tại trang Trung tâm bảo hành.',
     N'gio lam viec, hotline, zalo, lien he', 1, 10),
    ((SELECT id FROM FAQ_CATEGORY WHERE ma='ho_tro'),
     N'Tôi muốn khiếu nại về chất lượng phục vụ thì gửi đến đâu?',
     N'Gửi qua form liên hệ với chủ đề "Khiếu nại", nêu rõ mã đơn hàng và diễn biến. Khiếu nại được chuyển thẳng tới quản lý CSKH, xử lý và phản hồi trong 48 giờ làm việc.',
     N'khieu nai, phan anh, complaint', 0, 20);
END
GO

-- ============================================================
--  QUYỀN
-- ============================================================
-- Tách làm hai quyền vì hai nhịp công việc khác hẳn nhau: nội dung hỗ trợ (FAQ, bảng giá, danh
-- sách trung tâm) là việc biên tập thi thoảng mới đụng tới; lịch hẹn dịch vụ là việc trực hằng
-- ngày của kỹ thuật. Gộp một quyền sẽ buộc phải cho kỹ thuật sửa luôn được cả bảng giá.
IF NOT EXISTS (SELECT 1 FROM FEATURE WHERE feature_key = 'support_content')
BEGIN
    INSERT INTO FEATURE (feature_key, label, group_label, sort_order)
    VALUES ('support_content', N'Nội dung hỗ trợ (FAQ, bảng giá, trung tâm)', N'Chăm sóc khách hàng', 82);
END
GO

IF NOT EXISTS (SELECT 1 FROM FEATURE WHERE feature_key = 'service_appointment')
BEGIN
    INSERT INTO FEATURE (feature_key, label, group_label, sort_order)
    VALUES ('service_appointment', N'Lịch hẹn dịch vụ', N'Chăm sóc khách hàng', 84);
END
GO

IF NOT EXISTS (SELECT 1 FROM ROLE_PERMISSION WHERE feature_key = 'support_content')
BEGIN
    INSERT INTO ROLE_PERMISSION (department, feature_key, perm_key) VALUES
    ('cskh','support_content','view'),
    ('cskh','support_content','add'),
    ('cskh','support_content','edit'),
    ('cskh','support_content','delete'),
    -- Kỹ thuật chỉ xem + sửa bảng giá sửa chữa; không tạo/xoá nội dung biên tập.
    ('ky_thuat','support_content','view'),
    ('ky_thuat','support_content','edit');
END
GO

IF NOT EXISTS (SELECT 1 FROM ROLE_PERMISSION WHERE feature_key = 'service_appointment')
BEGIN
    INSERT INTO ROLE_PERMISSION (department, feature_key, perm_key) VALUES
    ('ky_thuat','service_appointment','view'),
    ('ky_thuat','service_appointment','edit'),
    ('cskh','service_appointment','view'),
    ('cskh','service_appointment','edit');
END
GO
