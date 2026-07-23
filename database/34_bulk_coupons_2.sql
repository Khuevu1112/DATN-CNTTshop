-- ============================================================
-- 34_bulk_coupons_2.sql
-- Bo sung 50 ma giam gia moi (dot 2), da dang loai/han/trang thai.
-- File duoc sinh tu dong (xem scratchpad/gen_coupons2.js).
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'GAMER2027')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('GAMER2027', 'percent', 18, 800000, 300, 37, GETDATE(), DATEADD(DAY, 90, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'APPLE5')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('APPLE5', 'percent', 5, 2000000, 100, 22, GETDATE(), DATEADD(DAY, 200, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'MONITOR15')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('MONITOR15', 'percent', 15, 1000000, 150, 3, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'KEYCAP20')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('KEYCAP20', 'fixed', 50000, 200000, 400, 24, GETDATE(), DATEADD(DAY, 45, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'CHUOTVIP')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('CHUOTVIP', 'percent', 12, 150000, 500, 18, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'TAIVIP20')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('TAIVIP20', 'percent', 20, 500000, 250, 7, GETDATE(), DATEADD(DAY, 30, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'SSD2TB')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('SSD2TB', 'fixed', 150000, 1500000, 100, 12, GETDATE(), DATEADD(DAY, 45, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'RAM32GB')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('RAM32GB', 'fixed', 80000, 800000, 150, 28, GETDATE(), DATEADD(DAY, 45, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'GPUSALE')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('GPUSALE', 'percent', 8, 5000000, 80, 37, GETDATE(), DATEADD(DAY, 20, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'CPUINTEL')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('CPUINTEL', 'percent', 10, 3000000, 100, 6, GETDATE(), DATEADD(DAY, 25, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'CPUAMD')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('CPUAMD', 'percent', 10, 3000000, 100, 23, GETDATE(), DATEADD(DAY, 25, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'MAINSALE')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('MAINSALE', 'fixed', 120000, 1200000, 120, 33, GETDATE(), DATEADD(DAY, 35, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'PSUGOLD')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('PSUGOLD', 'fixed', 60000, 600000, 150, 28, GETDATE(), DATEADD(DAY, 45, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'CASEMOD')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('CASEMOD', 'fixed', 70000, 500000, 200, 21, GETDATE(), DATEADD(DAY, 45, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'TANNHIET')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('TANNHIET', 'percent', 15, 300000, 200, 6, GETDATE(), DATEADD(DAY, 30, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'WEBCAMHD')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('WEBCAMHD', 'percent', 20, 200000, 250, 7, GETDATE(), DATEADD(DAY, 30, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'GHEGAMING')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('GHEGAMING', 'fixed', 200000, 2000000, 100, 31, GETDATE(), DATEADD(DAY, 40, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'BANPHIMWL')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('BANPHIMWL', 'percent', 15, 250000, 300, 24, GETDATE(), DATEADD(DAY, 30, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'CHUOTWL')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('CHUOTWL', 'percent', 15, 150000, 300, 21, GETDATE(), DATEADD(DAY, 30, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'COMBO5PC')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('COMBO5PC', 'percent', 22, 5000000, 60, 8, GETDATE(), DATEADD(DAY, 90, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'STUDENT15')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('STUDENT15', 'percent', 15, 500000, 1000, 39, GETDATE(), DATEADD(DAY, 180, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'BIRTHDAY20')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('BIRTHDAY20', 'percent', 20, 300000, 500, 20, GETDATE(), DATEADD(DAY, 365, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'REFER50K')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('REFER50K', 'fixed', 50000, 300000, 1000, 31, GETDATE(), DATEADD(DAY, 365, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'APP10')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('APP10', 'percent', 10, 200000, 2000, 26, GETDATE(), DATEADD(DAY, 365, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'MIDNIGHT')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('MIDNIGHT', 'percent', 12, 300000, 300, 26, GETDATE(), DATEADD(DAY, 20, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'WEEKEND10')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('WEEKEND10', 'percent', 10, 200000, 800, 19, GETDATE(), DATEADD(DAY, 10, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'MONDAY5')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('MONDAY5', 'fixed', 30000, 150000, 1000, 7, GETDATE(), DATEADD(DAY, 10, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'PAYDAY')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('PAYDAY', 'percent', 12, 500000, 500, 15, GETDATE(), DATEADD(DAY, 15, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'COMBO2IN1')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('COMBO2IN1', 'percent', 10, 1000000, 300, 1, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'UPGRADE10')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('UPGRADE10', 'percent', 10, 500000, 400, 31, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'TRADE1TR')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('TRADE1TR', 'fixed', 100000, 1000000, 300, 31, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'VIP30')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('VIP30', 'percent', 30, 3000000, 50, 30, GETDATE(), DATEADD(DAY, 30, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'DIAMOND35')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('DIAMOND35', 'percent', 35, 5000000, 30, 29, GETDATE(), DATEADD(DAY, 45, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'BRONZE5')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('BRONZE5', 'percent', 5, 200000, 2000, 10, GETDATE(), DATEADD(DAY, 90, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'ANNIVERSARY')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('ANNIVERSARY', 'percent', 25, 1000000, 200, 31, GETDATE(), DATEADD(DAY, 30, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'NEWYEAR2027')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('NEWYEAR2027', 'percent', 20, 800000, 300, 0, GETDATE(), DATEADD(DAY, 25, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'SUMMER2027')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('SUMMER2027', 'percent', 15, 600000, 400, 12, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'AUTUMN2027')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('AUTUMN2027', 'fixed', 100000, 500000, 400, 24, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'WINTER2027')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('WINTER2027', 'percent', 18, 700000, 300, 16, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'SPRING2027')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('SPRING2027', 'percent', 15, 500000, 400, 37, GETDATE(), DATEADD(DAY, 60, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'DOUBLE99')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('DOUBLE99', 'percent', 9, 300000, 999, 30, GETDATE(), DATEADD(DAY, 9, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'DOUBLE1010')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('DOUBLE1010', 'percent', 10, 300000, 999, 8, GETDATE(), DATEADD(DAY, 9, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'ENDYEAR')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('ENDYEAR', 'percent', 24, 1200000, 150, 29, GETDATE(), DATEADD(DAY, 45, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'FLASHTODAY')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('FLASHTODAY', 'fixed', 40000, 150000, 500, 4, GETDATE(), DATEADD(DAY, 3, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'CLEARANCE')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('CLEARANCE', 'percent', 30, 500000, 200, 38, GETDATE(), DATEADD(DAY, 20, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'BUNDLE3')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('BUNDLE3', 'percent', 12, 1500000, 150, 10, GETDATE(), DATEADD(DAY, 45, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'EXPIRED30')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('EXPIRED30', 'percent', 30, 500000, 100, 29, GETDATE(), DATEADD(DAY, -15, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'EXPIREDVIP')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('EXPIREDVIP', 'fixed', 300000, 2000000, 50, 7, GETDATE(), DATEADD(DAY, -30, GETDATE()), 1, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'PAUSED20')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('PAUSED20', 'percent', 20, 500000, 200, 17, GETDATE(), DATEADD(DAY, 40, GETDATE()), 0, 1, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM COUPON WHERE code = 'COMINGSOON')
BEGIN
    INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, used_count, starts_at, expires_at, is_active, condition_all_product, condition_new_product, condition_new_customer, condition_no_sale)
    VALUES ('COMINGSOON', 'percent', 15, 400000, 300, 14, GETDATE(), DATEADD(DAY, 40, GETDATE()), 0, 1, 0, 0, 0);
END
GO

