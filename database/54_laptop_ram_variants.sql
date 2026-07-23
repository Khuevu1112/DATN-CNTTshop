-- 54_laptop_ram_variants.sql
-- Bổ sung biến thể (variant) nâng cấp RAM (hoặc Ổ cứng cho 2 máy Apple, vì dòng M-series không
-- có tùy chọn nâng RAM) cho 19/86 sản phẩm Laptop — mẫu đại diện trải đều các phân khúc (văn
-- phòng/gaming/mỏng nhẹ), tham khảo mức giá nâng cấp RAM/SSD phổ biến trên thị trường VN
-- (8GB->16GB ~700k, 16GB->32GB ~1.2tr, 32GB->64GB ~1.8tr, Apple SSD 512GB->1TB ~4tr).
-- Biến thể mặc định hiện có được giữ nguyên (không đổi giá/SKU) và chỉ được gắn thêm vào option
-- value "cấu hình gốc" để so sánh cạnh biến thể nâng cấp mới. Chạy lại nhiều lần an toàn (guard
-- theo NOT EXISTS PRODUCT_OPTION).
USE ShopDB;
GO

IF OBJECT_ID('tempdb..#variant_plan') IS NOT NULL DROP TABLE #variant_plan;
CREATE TABLE #variant_plan (
    product_id INT PRIMARY KEY,
    option_name NVARCHAR(50),
    base_value NVARCHAR(100),
    upgrade_value NVARCHAR(100),
    price_delta DECIMAL(18,2)
);

INSERT INTO #variant_plan (product_id, option_name, base_value, upgrade_value, price_delta) VALUES
(18,  N'RAM', N'8GB DDR5', N'16GB DDR5', 700000),
(49,  N'RAM', N'8GB', N'16GB', 700000),
(50,  N'RAM', N'16GB', N'32GB', 1200000),
(54,  N'RAM', N'32GB', N'64GB', 1800000),
(55,  N'Ổ cứng', N'512GB SSD', N'1TB SSD', 4000000),
(313, N'RAM', N'16GB', N'32GB', 1200000),
(315, N'RAM', N'16GB', N'32GB', 1200000),
(318, N'RAM', N'16GB', N'32GB', 1200000),
(323, N'RAM', N'32GB', N'64GB', 1800000),
(689, N'RAM', N'8GB', N'16GB', 700000),
(691, N'RAM', N'16GB', N'32GB', 1200000),
(692, N'RAM', N'16GB', N'32GB', 1200000),
(693, N'RAM', N'16GB', N'32GB', 1200000),
(705, N'RAM', N'8GB', N'16GB', 700000),
(712, N'RAM', N'16GB', N'32GB', 1200000),
(717, N'RAM', N'16GB', N'32GB', 1200000),
(718, N'Ổ cứng', N'512GB SSD', N'1TB SSD', 4000000),
(723, N'RAM', N'16GB', N'32GB', 1200000),
(727, N'RAM', N'8GB', N'16GB', 700000);
GO

DECLARE @pid INT, @optionName NVARCHAR(50), @baseValue NVARCHAR(100), @upgradeValue NVARCHAR(100), @delta DECIMAL(18,2);
DECLARE @optId INT, @baseValId INT, @upgValId INT, @defVariantId INT, @newVariantId INT, @baseSku NVARCHAR(100), @basePrice DECIMAL(18,2);

DECLARE plan_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT product_id, option_name, base_value, upgrade_value, price_delta FROM #variant_plan;

OPEN plan_cursor;
FETCH NEXT FROM plan_cursor INTO @pid, @optionName, @baseValue, @upgradeValue, @delta;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PRODUCT_OPTION WHERE product_id = @pid)
    BEGIN
        INSERT INTO PRODUCT_OPTION (product_id, option_name) VALUES (@pid, @optionName);
        SET @optId = SCOPE_IDENTITY();

        INSERT INTO OPTION_VALUE (option_id, value) VALUES (@optId, @baseValue), (@optId, @upgradeValue);
        SELECT @baseValId = id FROM OPTION_VALUE WHERE option_id = @optId AND value = @baseValue;
        SELECT @upgValId = id FROM OPTION_VALUE WHERE option_id = @optId AND value = @upgradeValue;

        SELECT TOP 1 @defVariantId = id, @baseSku = sku, @basePrice = price
        FROM PRODUCT_VARIANT WHERE product_id = @pid AND is_default = 1;

        INSERT INTO VARIANT_OPTION_VALUE (variant_id, option_value_id) VALUES (@defVariantId, @baseValId);

        INSERT INTO PRODUCT_VARIANT (product_id, sku, price, original_price, stock, is_default)
        VALUES (@pid, @baseSku + N'-UPG', @basePrice + @delta, NULL, 5, 0);
        SET @newVariantId = SCOPE_IDENTITY();

        INSERT INTO VARIANT_OPTION_VALUE (variant_id, option_value_id) VALUES (@newVariantId, @upgValId);
    END

    FETCH NEXT FROM plan_cursor INTO @pid, @optionName, @baseValue, @upgradeValue, @delta;
END

CLOSE plan_cursor;
DEALLOCATE plan_cursor;

DROP TABLE #variant_plan;
GO
