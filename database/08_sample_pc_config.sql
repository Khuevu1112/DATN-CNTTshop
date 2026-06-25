-- ============================================================
--  08_sample_pc_config.sql
--  Cấu hình NHIỀU NHÓM tùy chọn (CPU / Card đồ họa / RAM / Ổ cứng)
--  cho "PC Gaming CNTT Spark RTX 4060" — để trang chi tiết hiện
--  4 nhóm cấu hình + giá chênh lệch (giống thiết kế gốc).
--  Cần chạy SAU 07. Chạy lại nhiều lần an toàn (có IF guard).
-- ============================================================
USE ShopDB;
GO

DECLARE @pid INT = (SELECT id FROM PRODUCT WHERE slug = 'pc-cntt-spark-rtx4060');

IF @pid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM PRODUCT_OPTION WHERE product_id = @pid)
BEGIN
    -- Xoá biến thể đơn (do 07 tạo) để dựng lại theo cấu hình
    DELETE FROM PRODUCT_VARIANT WHERE product_id = @pid;

    -- 4 nhóm tùy chọn
    INSERT INTO PRODUCT_OPTION (product_id, option_name)
    VALUES (@pid, N'CPU'), (@pid, N'Card đồ họa'), (@pid, N'RAM'), (@pid, N'Ổ cứng');

    DECLARE @optCPU INT = (SELECT id FROM PRODUCT_OPTION WHERE product_id=@pid AND option_name=N'CPU');
    DECLARE @optGPU INT = (SELECT id FROM PRODUCT_OPTION WHERE product_id=@pid AND option_name=N'Card đồ họa');
    DECLARE @optRAM INT = (SELECT id FROM PRODUCT_OPTION WHERE product_id=@pid AND option_name=N'RAM');
    DECLARE @optSSD INT = (SELECT id FROM PRODUCT_OPTION WHERE product_id=@pid AND option_name=N'Ổ cứng');

    INSERT INTO OPTION_VALUE (option_id, value) VALUES
    (@optCPU, N'Intel Core i5-12400F'), (@optCPU, N'Intel Core i5-14400F'),
    (@optGPU, N'RTX 4060 8GB'),         (@optGPU, N'RTX 4060 Ti 8GB'),
    (@optRAM, N'16GB DDR5'),            (@optRAM, N'32GB DDR5'),
    (@optSSD, N'512GB NVMe SSD'),       (@optSSD, N'1TB NVMe SSD');

    -- 5 biến thể: base + 4 nâng cấp (mỗi cái đổi đúng 1 option)
    INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default) VALUES
    (@pid, 'SPARK-BASE', 24990000, NULL, 10, 1),  -- i5-12400F / 4060 8GB / 16GB / 512GB
    (@pid, 'SPARK-CPU',  26990000, NULL, 10, 0),  -- + i5-14400F (+2.000.000)
    (@pid, 'SPARK-GPU',  27990000, NULL, 10, 0),  -- + RTX 4060 Ti (+3.000.000)
    (@pid, 'SPARK-RAM',  26390000, NULL, 10, 0),  -- + 32GB (+1.400.000)
    (@pid, 'SPARK-SSD',  25890000, NULL, 10, 0);  -- + 1TB (+900.000)

    -- Liên kết từng biến thể -> 4 giá trị option của nó
    INSERT INTO VARIANT_OPTION_VALUE (variant_id, option_value_id)
    SELECT v.id, ov.id FROM PRODUCT_VARIANT v, OPTION_VALUE ov
    WHERE v.sku='SPARK-BASE' AND ov.id IN (
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optCPU AND value=N'Intel Core i5-12400F'),
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optGPU AND value=N'RTX 4060 8GB'),
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optRAM AND value=N'16GB DDR5'),
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optSSD AND value=N'512GB NVMe SSD'));

    INSERT INTO VARIANT_OPTION_VALUE (variant_id, option_value_id)
    SELECT v.id, ov.id FROM PRODUCT_VARIANT v, OPTION_VALUE ov
    WHERE v.sku='SPARK-CPU' AND ov.id IN (
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optCPU AND value=N'Intel Core i5-14400F'),
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optGPU AND value=N'RTX 4060 8GB'),
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optRAM AND value=N'16GB DDR5'),
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optSSD AND value=N'512GB NVMe SSD'));

    INSERT INTO VARIANT_OPTION_VALUE (variant_id, option_value_id)
    SELECT v.id, ov.id FROM PRODUCT_VARIANT v, OPTION_VALUE ov
    WHERE v.sku='SPARK-GPU' AND ov.id IN (
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optCPU AND value=N'Intel Core i5-12400F'),
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optGPU AND value=N'RTX 4060 Ti 8GB'),
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optRAM AND value=N'16GB DDR5'),
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optSSD AND value=N'512GB NVMe SSD'));

    INSERT INTO VARIANT_OPTION_VALUE (variant_id, option_value_id)
    SELECT v.id, ov.id FROM PRODUCT_VARIANT v, OPTION_VALUE ov
    WHERE v.sku='SPARK-RAM' AND ov.id IN (
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optCPU AND value=N'Intel Core i5-12400F'),
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optGPU AND value=N'RTX 4060 8GB'),
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optRAM AND value=N'32GB DDR5'),
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optSSD AND value=N'512GB NVMe SSD'));

    INSERT INTO VARIANT_OPTION_VALUE (variant_id, option_value_id)
    SELECT v.id, ov.id FROM PRODUCT_VARIANT v, OPTION_VALUE ov
    WHERE v.sku='SPARK-SSD' AND ov.id IN (
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optCPU AND value=N'Intel Core i5-12400F'),
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optGPU AND value=N'RTX 4060 8GB'),
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optRAM AND value=N'16GB DDR5'),
      (SELECT id FROM OPTION_VALUE WHERE option_id=@optSSD AND value=N'1TB NVMe SSD'));

    -- Bổ sung thông số Ổ cứng + Nguồn (07 đã có CPU/Card/RAM)
    INSERT INTO PRODUCT_SPEC (product_id, spec_key, spec_value, sort_order)
    SELECT @pid, d.k, d.v, d.so
    FROM (VALUES (N'Ổ cứng', N'512GB NVMe SSD', 3), (N'Nguồn', N'650W 80+ Bronze', 4)) AS d(k, v, so)
    WHERE NOT EXISTS (SELECT 1 FROM PRODUCT_SPEC s WHERE s.product_id=@pid AND s.spec_key=d.k);

    PRINT N'✅ Đã cấu hình 4 nhóm tùy chọn cho PC Spark RTX 4060.';
END
ELSE
    PRINT N'(Bỏ qua) Không thấy sản phẩm hoặc đã cấu hình trước đó.';
GO
