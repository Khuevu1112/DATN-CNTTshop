-- ============================================================
-- 26_bulk_coupons.sql
-- Bo sung 50 ma giam gia moi, da dang loai/han/trang thai.
-- File duoc sinh tu dong (xem scratchpad/gen_coupons.js).
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'TET2026')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('TET2026', 'percent', 15, 500000, 300, 0, GETDATE(), DATEADD(DAY, 20, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'VALENTINE14')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('VALENTINE14', 'fixed', 100000, 500000, 200, 0, GETDATE(), DATEADD(DAY, -5, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'HE2026')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('HE2026', 'percent', 12, 300000, 500, 0, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'TRUNGTHU2026')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('TRUNGTHU2026', 'fixed', 80000, 400000, 200, 0, GETDATE(), DATEADD(DAY, 45, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'NOEL2026')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('NOEL2026', 'percent', 20, 1000000, 150, 0, GETDATE(), DATEADD(DAY, 90, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'BLACKFRIDAY')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('BLACKFRIDAY', 'percent', 25, 1000000, 500, 0, GETDATE(), DATEADD(DAY, -10, GETDATE()), 0, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'SALE1111')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('SALE1111', 'percent', 30, 500000, 1000, 0, GETDATE(), DATEADD(DAY, -20, GETDATE()), 0, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'SALE1212')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('SALE1212', 'percent', 22, 500000, 500, 0, GETDATE(), DATEADD(DAY, 120, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'LAPTOP10')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('LAPTOP10', 'percent', 10, 8000000, 100, 0, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'LAPTOPVIP')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('LAPTOPVIP', 'fixed', 500000, 15000000, 50, 0, GETDATE(), DATEADD(DAY, 90, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'PCBUILD15')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('PCBUILD15', 'percent', 15, 10000000, 80, 0, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'GAMING20')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('GAMING20', 'percent', 20, 5000000, 100, 0, GETDATE(), DATEADD(DAY, 45, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'MANHINH10')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('MANHINH10', 'percent', 10, 2000000, 150, 0, GETDATE(), DATEADD(DAY, 30, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'LINHKIEN15')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('LINHKIEN15', 'percent', 15, 1000000, 300, 0, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'TAINGHE10')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('TAINGHE10', 'percent', 10, 500000, 200, 0, GETDATE(), DATEADD(DAY, -15, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'BANPHIM15')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('BANPHIM15', 'percent', 15, 500000, 200, 0, GETDATE(), DATEADD(DAY, 30, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'PHUKIEN20')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('PHUKIEN20', 'percent', 20, 200000, NULL, 0, GETDATE(), DATEADD(DAY, 90, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'SSDSALE')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('SSDSALE', 'fixed', 150000, 1000000, 150, 0, GETDATE(), DATEADD(DAY, 45, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'FLASH50K')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('FLASH50K', 'fixed', 50000, 300000, 500, 0, GETDATE(), DATEADD(DAY, 10, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'FLASH100K')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('FLASH100K', 'fixed', 100000, 800000, 400, 0, GETDATE(), DATEADD(DAY, 10, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'FLASH200K')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('FLASH200K', 'fixed', 200000, 1500000, 300, 0, GETDATE(), DATEADD(DAY, 10, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'FLASH500K')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('FLASH500K', 'fixed', 500000, 4000000, 100, 0, GETDATE(), DATEADD(DAY, 10, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'GIAM5')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('GIAM5', 'percent', 5, 0, NULL, 0, GETDATE(), NULL, 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'GIAM10')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('GIAM10', 'percent', 10, 200000, NULL, 0, GETDATE(), NULL, 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'GIAM15')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('GIAM15', 'percent', 15, 500000, 1000, 0, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'GIAM20')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('GIAM20', 'percent', 20, 1000000, 500, 0, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'GIAM25')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('GIAM25', 'percent', 25, 2000000, 300, 0, GETDATE(), DATEADD(DAY, -30, GETDATE()), 0, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'GIAM30')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('GIAM30', 'percent', 30, 3000000, 200, 0, GETDATE(), DATEADD(DAY, 15, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'VIP2026')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('VIP2026', 'percent', 18, 2000000, NULL, 0, GETDATE(), DATEADD(DAY, 180, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'MEMBER10')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('MEMBER10', 'percent', 10, 300000, NULL, 0, GETDATE(), NULL, 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'LOYALTY15')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('LOYALTY15', 'percent', 15, 800000, 500, 0, GETDATE(), DATEADD(DAY, 90, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'GOLD20')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('GOLD20', 'fixed', 300000, 3000000, 100, 0, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'SILVER10')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('SILVER10', 'fixed', 100000, 1000000, 300, 0, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'PLATINUM25')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('PLATINUM25', 'percent', 25, 5000000, 50, 0, GETDATE(), DATEADD(DAY, 90, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'NEWBIE10')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('NEWBIE10', 'percent', 10, 200000, NULL, 0, GETDATE(), DATEADD(DAY, 90, GETDATE()), 1, 0, 0, 1, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'WELCOME50K')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('WELCOME50K', 'fixed', 50000, 200000, NULL, 0, GETDATE(), DATEADD(DAY, 90, GETDATE()), 1, 0, 0, 1, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'FIRSTORDER')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('FIRSTORDER', 'percent', 15, 300000, NULL, 0, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 0, 0, 1, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'HELLO2026')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('HELLO2026', 'fixed', 30000, 0, NULL, 0, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 0, 0, 1, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'JOIN15')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('JOIN15', 'percent', 15, 400000, 1000, 0, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 0, 0, 1, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'FREESHIP30K')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('FREESHIP30K', 'fixed', 30000, 200000, NULL, 0, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'FREESHIP50K')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('FREESHIP50K', 'fixed', 50000, 500000, NULL, 0, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'FREESHIPVIP')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('FREESHIPVIP', 'fixed', 40000, 300000, 500, 0, GETDATE(), DATEADD(DAY, -7, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'SHIP0D')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('SHIP0D', 'fixed', 35000, 250000, NULL, 0, GETDATE(), DATEADD(DAY, 45, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'BIGSPEND500K')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('BIGSPEND500K', 'fixed', 200000, 5000000, 200, 0, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'BIGSPEND1TR')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('BIGSPEND1TR', 'fixed', 400000, 10000000, 100, 0, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'MEGA1TR5')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('MEGA1TR5', 'fixed', 700000, 15000000, 50, 0, GETDATE(), DATEADD(DAY, 90, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'SUPER2TR')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('SUPER2TR', 'fixed', 1000000, 20000000, 30, 0, GETDATE(), DATEADD(DAY, 90, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'CNTTSHOP10')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('CNTTSHOP10', 'percent', 10, 500000, NULL, 0, GETDATE(), NULL, 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'THANKYOU')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('THANKYOU', 'fixed', 50000, 300000, 300, 0, GETDATE(), DATEADD(DAY, -3, GETDATE()), 0, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'LUCKY99')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('LUCKY99', 'percent', 9, 99000, 999, 0, GETDATE(), DATEADD(DAY, 30, GETDATE()), 1, 1, 0, 0, 0);
END
GO
