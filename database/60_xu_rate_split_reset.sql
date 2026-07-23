-- ============================================================
-- 60_xu_rate_split_reset.sql
-- SỬA LỖI KINH TẾ XU: trước đây chiều kiếm và chiều tiêu dùng CHUNG một tỉ giá
-- (WalletService.VND_MOI_XU = 100.000đ), nên mua 25 triệu thì nhận lại xu trị giá đúng 25
-- triệu -> hoàn tiền 100%, mọi món hàng thực chất bán nửa giá.
--
-- Tỉ giá mới TÁCH RỜI (xem WalletService.VND_MOI_XU_KIEM / VND_MOI_XU_TIEU):
--     kiếm  10.000đ tiền hàng = 1 xu
--     tiêu  1 xu               = 1.000đ
--     => hoàn thực tế 10% giá trị đơn hàng.
--
-- Migration này chỉnh lại MỌI con số xu đang lưu trong DB cho khớp tỉ giá mới:
--   1. Reset sạch ví + sổ giao dịch của khách (số dư cũ sinh ra từ tỉ giá hỏng, giữ lại là
--      giữ lại đúng phần lạm phát). Ví của admin/nhân viên GIỮ NGUYÊN để còn tài khoản test.
--   2. Giá quà đổi thưởng: đang tính theo 100.000đ/xu, nhân 100 để về 1.000đ/xu.
--   3. Giá xu của coupon: cùng lý do, nhân 100.
-- Thưởng điểm danh nằm trong code (CheckinService.THUONG_THEO_NGAY), không ở DB.
-- ============================================================
USE ShopDB;
GO

-- 1. Reset ví khách. Xoá giao dịch trước vì WALLET_TRANSACTION tham chiếu WALLET.
DELETE wt
FROM WALLET_TRANSACTION wt
JOIN WALLET w   ON w.id = wt.wallet_id
JOIN [USER] u   ON u.id = w.user_id
WHERE u.role = 'customer';
GO

UPDATE w
SET w.silver_balance = 0
FROM WALLET w
JOIN [USER] u ON u.id = w.user_id
WHERE u.role = 'customer';
GO

-- Lịch sử điểm danh cũng phải xoá: nếu giữ lại, chuỗi ngày liên tiếp vẫn tính tiếp và khách
-- nhận ngay mốc thưởng ngày thứ 7 (cao nhất) dù ví vừa bị reset về 0.
DELETE cl
FROM CHECKIN_LOG cl
JOIN [USER] u ON u.id = cl.user_id
WHERE u.role = 'customer';
GO

-- 2. Quà vật lý: 2/5/7/8 xu (giá theo 100.000đ/xu) -> 200/500/700/800 xu (theo 1.000đ/xu).
UPDATE REDEMPTION_ITEM
SET silver_cost = silver_cost * 100
WHERE type = 'gift';
GO

-- 3. Coupon đổi bằng xu: admin tự đặt xu_cost theo tỉ giá cũ, nhân 100 cho khớp.
UPDATE COUPON
SET xu_cost = xu_cost * 100
WHERE xu_cost IS NOT NULL;
GO
