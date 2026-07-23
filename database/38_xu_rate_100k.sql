-- ============================================================
-- 38_xu_rate_100k.sql
-- Nâng tỉ giá Xu CT: 1.000đ -> 100.000đ / xu (khớp với WalletService.VND_MOI_XU). Quà vật lý
-- tính lại giá xu theo tỉ lệ mới; 8 mức coupon cũ (đổi theo % cố định, random mã) tạm tắt vì
-- sắp thay bằng cơ chế admin tự tạo coupon khuyến mãi (chưa build ở migration này).
-- ============================================================
USE ShopDB;
GO

UPDATE REDEMPTION_ITEM SET silver_cost = 2 WHERE type = 'gift' AND name = N'Lót chuột Ugreen size M';
UPDATE REDEMPTION_ITEM SET silver_cost = 5 WHERE type = 'gift' AND name = N'Chuột E-Dra EM620';
UPDATE REDEMPTION_ITEM SET silver_cost = 7 WHERE type = 'gift' AND name = N'Tai nghe nhét tai Anker Soundcore P20i';
UPDATE REDEMPTION_ITEM SET silver_cost = 8 WHERE type = 'gift' AND name = N'Bàn phím cơ Rapoo V500';

UPDATE REDEMPTION_ITEM SET is_active = 0 WHERE type = 'coupon';
GO
