-- ============================================================
--  ĐÁNH GIÁ MẪU — để card sản phẩm hiển thị sao (★ điểm + số lượt)
--  Mỗi user tạo 1 đánh giá / sản phẩm (order_id = NULL). Chạy an toàn nhiều lần.
-- ============================================================
USE ShopDB;
GO

INSERT INTO REVIEW (product_id, user_id, order_id, rating, comment, is_verified, created_at)
SELECT p.id, u.id, NULL,
       4 + (ABS(CHECKSUM(p.id, u.id)) % 2),   -- 4 hoặc 5 sao
       N'Sản phẩm tốt, đáng mua.', 1, GETDATE()
FROM PRODUCT p
CROSS JOIN [USER] u
WHERE NOT EXISTS (
    SELECT 1 FROM REVIEW r
    WHERE r.product_id = p.id AND r.user_id = u.id AND r.order_id IS NULL
);
GO

PRINT N'✅ Đã thêm đánh giá mẫu (card sẽ hiện sao).';
GO
