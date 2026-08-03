-- ============================================================
-- 72_article_news.sql
-- Khu "Tin tuc" (blog) cua shop: bai viet review / huong dan / cong nghe / khuyen mai... Vua la
-- noi dung SEO-marketing, vua ho tro khach chon mua. ARTICLE co trang_thai draft/published va
-- published_at de admin soan nhap roi moi xuat ban.
--
-- Vietnamese trong seed => chay: sqlcmd -f 65001 -i "D:\...\72_article_news.sql"
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ARTICLE_CATEGORY')
BEGIN
    CREATE TABLE ARTICLE_CATEGORY (
        id INT IDENTITY(1,1) PRIMARY KEY,
        ma VARCHAR(40) NOT NULL UNIQUE,
        ten NVARCHAR(120) NOT NULL,
        hien_thi BIT NOT NULL DEFAULT 1,
        sort_order INT NOT NULL DEFAULT 100
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ARTICLE')
BEGIN
    CREATE TABLE ARTICLE (
        id INT IDENTITY(1,1) PRIMARY KEY,
        slug VARCHAR(200) NOT NULL UNIQUE,           -- khoa dep tren URL, tu sinh tu tieu de
        tieu_de NVARCHAR(300) NOT NULL,
        thumbnail NVARCHAR(400) NULL,                -- anh dai dien (url /uploads/... hoac ngoai)
        category_id INT NOT NULL REFERENCES ARTICLE_CATEGORY(id),
        tom_tat NVARCHAR(600) NULL,                  -- doan trich hien o danh sach
        noi_dung NVARCHAR(MAX) NOT NULL,             -- than bai (HTML do admin soan)
        tac_gia NVARCHAR(120) NULL,

        -- draft = ban nhap (khach khong thay) | published = da xuat ban
        trang_thai VARCHAR(20) NOT NULL DEFAULT 'draft',
        noi_bat BIT NOT NULL DEFAULT 0,
        luot_xem INT NOT NULL DEFAULT 0,

        published_at DATETIME2 NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2 NULL
    );
    CREATE INDEX IX_ARTICLE_cat ON ARTICLE (category_id, trang_thai);
    CREATE INDEX IX_ARTICLE_pub ON ARTICLE (trang_thai, published_at DESC);
END
GO

-- ===== Danh muc =====
IF NOT EXISTS (SELECT 1 FROM ARTICLE_CATEGORY)
BEGIN
    INSERT INTO ARTICLE_CATEGORY (ma, ten, sort_order) VALUES
    ('cong_nghe', N'Công nghệ', 10),
    ('review',    N'Review',     20),
    ('huong_dan', N'Hướng dẫn',  30),
    ('build_pc',  N'Tin build PC', 40),
    ('khuyen_mai',N'Tin khuyến mãi', 50),
    ('su_kien',   N'Sự kiện',    60);
END
GO

-- ===== Bai viet mau (published) =====
IF NOT EXISTS (SELECT 1 FROM ARTICLE)
BEGIN
    DECLARE @cn INT = (SELECT id FROM ARTICLE_CATEGORY WHERE ma='cong_nghe');
    DECLARE @rv INT = (SELECT id FROM ARTICLE_CATEGORY WHERE ma='review');
    DECLARE @hd INT = (SELECT id FROM ARTICLE_CATEGORY WHERE ma='huong_dan');
    DECLARE @bp INT = (SELECT id FROM ARTICLE_CATEGORY WHERE ma='build_pc');
    DECLARE @km INT = (SELECT id FROM ARTICLE_CATEGORY WHERE ma='khuyen_mai');

    INSERT INTO ARTICLE (slug, tieu_de, thumbnail, category_id, tom_tat, noi_dung, tac_gia, trang_thai, noi_bat, published_at) VALUES
    ('ryzen-7-9800x3d-vs-core-ultra-9-285k',
     N'Ryzen 7 9800X3D và Core Ultra 9 285K: chọn CPU nào để chơi game?',
     'https://placehold.co/600x360/1c1e22/c6ff4a?text=CPU+Gaming',
     @rv,
     N'So sánh hiệu năng gaming, nhiệt độ và giá trị của hai CPU cao cấp mới nhất từ AMD và Intel.',
     N'<p>Với game thủ, <strong>Ryzen 7 9800X3D</strong> nhờ 3D V-Cache thường dẫn trước ở phần lớn tựa game, trong khi <strong>Core Ultra 9 285K</strong> mạnh hơn ở tác vụ đa nhân.</p><h3>Kết luận</h3><p>Chơi game thuần: chọn 9800X3D. Vừa game vừa dựng phim/stream: cân nhắc 285K.</p>',
     N'CNTTShop', 'published', 1, DATEADD(day,-2,GETDATE())),

    ('huong-dan-chon-nguon-cong-suat-cho-pc',
     N'Hướng dẫn chọn nguồn (PSU) đúng công suất cho PC',
     'https://placehold.co/600x360/1c1e22/c6ff4a?text=PSU+Guide',
     @hd,
     N'Cách tính công suất nguồn cần thiết theo CPU + VGA và vì sao không nên mua nguồn trôi nổi.',
     N'<p>Công thức nhanh: cộng TDP của CPU và VGA rồi cộng thêm khoảng 30% cho ổ cứng, quạt và headroom.</p><p>Ưu tiên nguồn đạt chuẩn <strong>80 Plus</strong> từ các hãng uy tín để bảo vệ linh kiện.</p>',
     N'CNTTShop', 'published', 1, DATEADD(day,-4,GETDATE())),

    ('top-cau-hinh-pc-gaming-2025',
     N'Top cấu hình PC Gaming đáng mua 2025 theo từng tầm giá',
     'https://placehold.co/600x360/1c1e22/c6ff4a?text=PC+Gaming+2025',
     @bp,
     N'Ba cấu hình gợi ý cho các mức 15, 25 và 40 triệu — cân bằng CPU, VGA và màn hình.',
     N'<p>Tầm 15 triệu: tập trung vào VGA tầm trung + màn 144Hz. Tầm 25 triệu: nâng CPU và RAM. Tầm 40 triệu: chơi 2K mượt với card cao cấp.</p><p>Dùng công cụ <em>Xây dựng cấu hình PC</em> của CNTTShop để tự kiểm tra tương thích.</p>',
     N'CNTTShop', 'published', 0, DATEADD(day,-6,GETDATE())),

    ('ai-pc-va-npu-la-gi',
     N'AI PC và NPU là gì? Có nên mua laptop Core Ultra?',
     'https://placehold.co/600x360/1c1e22/c6ff4a?text=AI+PC',
     @cn,
     N'Giải thích ngắn gọn về NPU, những tác vụ AI chạy cục bộ và ai thực sự cần đến AI PC.',
     N'<p>NPU là nhân xử lý AI chuyên biệt giúp chạy các tác vụ AI cục bộ tiết kiệm điện. Với đa số người dùng văn phòng, lợi ích hiện tại còn khiêm tốn nhưng là khoản đầu tư cho tương lai.</p>',
     N'CNTTShop', 'published', 0, DATEADD(day,-8,GETDATE())),

    ('uu-dai-thang-nay-tai-cnttshop',
     N'Ưu đãi tháng này tại CNTTShop: giảm sâu laptop & PC',
     'https://placehold.co/600x360/1c1e22/c6ff4a?text=Khuyen+Mai',
     @km,
     N'Tổng hợp các chương trình giảm giá, trả góp 0% và quà tặng kèm đang áp dụng.',
     N'<p>Nhiều mẫu laptop gaming và PC dựng sẵn đang giảm giá kèm <strong>trả góp 0%</strong>. Xem trang Khuyến mãi và Flash Sale để không bỏ lỡ.</p>',
     N'CNTTShop', 'published', 1, DATEADD(day,-1,GETDATE()));
END
GO

-- ===== Quyen =====
-- Bien tap tin tuc gan voi nhom Kinh doanh (marketing/ban hang). Admin luon co full qua aspect.
IF NOT EXISTS (SELECT 1 FROM FEATURE WHERE feature_key = 'articles')
BEGIN
    INSERT INTO FEATURE (feature_key, label, group_label, sort_order)
    VALUES ('articles', N'Tin tức / Bài viết', N'Marketing', 92);
END
GO

IF NOT EXISTS (SELECT 1 FROM ROLE_PERMISSION WHERE feature_key = 'articles')
BEGIN
    INSERT INTO ROLE_PERMISSION (department, feature_key, perm_key) VALUES
    ('kinh_doanh','articles','view'),
    ('kinh_doanh','articles','add'),
    ('kinh_doanh','articles','edit'),
    ('kinh_doanh','articles','delete');
END
GO
