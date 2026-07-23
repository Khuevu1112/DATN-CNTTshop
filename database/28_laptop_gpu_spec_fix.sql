-- Sửa thứ tự spec của Laptop để Card đồ họa (GPU) luôn nằm trong 3 chip hiển thị ở
-- danh sách sản phẩm (backend chỉ lấy top-3 theo sort_order — xem CatalogApiService.toSummary).
-- 78/86 laptop sinh hàng loạt đang có thứ tự CPU/RAM/Ổ cứng/Card đồ họa nên GPU bị rớt khỏi
-- top-3. Đổi sang CPU/Card đồ họa/RAM/Ổ cứng. An toàn với 4 laptop đã đúng thứ tự từ trước
-- (CPU/GPU/RAM, không có Ổ cứng) vì phép gán idempotent với chúng.
UPDATE ps
SET ps.sort_order = CASE ps.spec_key
    WHEN N'CPU' THEN 0
    WHEN N'Card đồ họa' THEN 1
    WHEN N'RAM' THEN 2
    WHEN N'Ổ cứng' THEN 3
    ELSE ps.sort_order
END
FROM PRODUCT_SPEC ps
JOIN PRODUCT p ON p.id = ps.product_id
JOIN CATEGORY c ON c.id = p.category_id
WHERE c.slug = N'laptop';
GO

-- Bổ sung spec còn thiếu cho 4 laptop đời đầu (trước khi có quy ước sinh dữ liệu hàng loạt)
-- hoàn toàn chưa có specs nào — thuần bổ sung thêm, không đổi tên/giá/lịch sử đơn hàng.
IF NOT EXISTS (SELECT 1 FROM PRODUCT_SPEC WHERE product_id = 5)
BEGIN
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order) VALUES
    (5, N'CPU', N'Intel Core i5-1340P', 0),
    (5, N'Card đồ họa', N'Intel Iris Xe', 1),
    (5, N'RAM', N'16GB', 2),
    (5, N'Ổ cứng', N'512GB SSD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT_SPEC WHERE product_id = 6)
BEGIN
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order) VALUES
    (6, N'CPU', N'Intel Core i5-13450HX', 0),
    (6, N'Card đồ họa', N'RTX 3050 6GB', 1),
    (6, N'RAM', N'16GB', 2),
    (6, N'Ổ cứng', N'512GB SSD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT_SPEC WHERE product_id = 8)
BEGIN
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order) VALUES
    (8, N'CPU', N'AMD Ryzen 7 7735HS', 0),
    (8, N'Card đồ họa', N'RTX 4050 6GB', 1),
    (8, N'RAM', N'16GB', 2),
    (8, N'Ổ cứng', N'512GB SSD', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM PRODUCT_SPEC WHERE product_id = 9)
BEGIN
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order) VALUES
    (9, N'CPU', N'Intel Core i7-1355U', 0),
    (9, N'Card đồ họa', N'Intel Iris Xe', 1),
    (9, N'RAM', N'16GB', 2),
    (9, N'Ổ cứng', N'512GB SSD', 3);
END
GO
