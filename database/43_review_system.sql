-- ============================================================
-- 43_review_system.sql
-- Bổ sung ảnh cho REVIEW (giới hạn 2 ảnh/đánh giá), dọn dữ liệu đánh giá giả lập trong
-- 06_sample_reviews.sql (mỗi khách 1 review chung chung cho mỗi sản phẩm, order_id NULL) để
-- badge sao/số lượt đánh giá trên trang sản phẩm (CatalogApiService.loadRatingMap) chỉ còn phản
-- ánh đánh giá thật do khách nộp qua luồng mới, và thêm bảng đánh giá giao hàng (tách riêng vì
-- chấm theo ĐƠN, không phải theo từng sản phẩm như REVIEW).
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('REVIEW') AND name = 'photo1_url')
BEGIN
    ALTER TABLE REVIEW ADD photo1_url NVARCHAR(255) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('REVIEW') AND name = 'photo2_url')
BEGIN
    ALTER TABLE REVIEW ADD photo2_url NVARCHAR(255) NULL;
END
GO

-- Xoá review giả lập từ 06_sample_reviews.sql: nhận diện qua order_id NULL (review thật luôn gắn
-- 1 đơn hàng cụ thể) + đúng câu bình luận cố định mà script đó dùng cho mọi sản phẩm/khách.
DELETE FROM REVIEW WHERE order_id IS NULL AND comment = N'Sản phẩm tốt, đáng mua.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ORDER_DELIVERY_REVIEW')
BEGIN
    CREATE TABLE ORDER_DELIVERY_REVIEW (
        id INT IDENTITY(1,1) PRIMARY KEY,
        order_id INT NOT NULL UNIQUE REFERENCES [ORDER](id),
        user_id INT NOT NULL REFERENCES [USER](id),
        rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
        comment NVARCHAR(1000) NULL,
        target_type VARCHAR(20) NOT NULL CHECK (target_type IN ('shop_shipper','carrier')),
        carrier_id INT NULL REFERENCES CARRIER(id),
        created_at DATETIME2 NOT NULL DEFAULT GETDATE()
    );
END
GO
