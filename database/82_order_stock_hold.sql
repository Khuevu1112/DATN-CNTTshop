-- ============================================================
-- 82_order_stock_hold.sql
-- GIỮ HÀNG có thời hạn cho đơn thanh toán qua cổng redirect (Stripe / VNPay).
--
-- Vấn đề: trước đây đơn qua cổng redirect KHÔNG trừ kho lúc tạo đơn (chỉ trừ khi cổng báo
-- thanh toán thành công). Còn đúng 1 máy mà 2 khách cùng bấm mua thì cả hai đều tạo được đơn,
-- cả hai đều được đưa sang trang thanh toán, và người trả tiền sau sẽ trả cho món hàng không
-- còn tồn tại. Đơn COD tuy có trừ kho nhưng lại trừ theo kiểu đọc-rồi-ghi nên hai giao dịch
-- song song vẫn có thể cùng trừ trên cùng một con số.
--
-- Cách xử lý: mọi đơn đều GIỮ HÀNG ngay khi tạo (trừ kho bằng UPDATE có điều kiện, xem
-- TonKhoService) — nên sản phẩm lập tức chuyển sang "tạm hết hàng" với người khác. Đơn qua
-- cổng redirect chỉ được giữ trong PHUT_GIU_HANG_THANH_TOAN phút (xem OrderService); quá hạn
-- mà chưa trả tiền thì đơn tự huỷ và hàng được trả lại kho cho người khác mua.
--
-- hold_until = thời điểm hết hạn giữ hàng. NULL với đơn COD/chuyển khoản/POS (không có đồng
-- hồ đếm ngược) và với mọi đơn đã thanh toán xong.
-- ============================================================
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='ORDER' AND COLUMN_NAME='hold_until')
BEGIN
    ALTER TABLE [ORDER] ADD hold_until DATETIME NULL;
END
GO

-- Quét "đơn đang giữ hàng đã quá hạn" chạy mỗi phút -> cần index để không phải quét cả bảng.
-- Index CÓ ĐIỀU KIỆN (filtered index) bắt buộc QUOTED_IDENTIFIER ON, mà sqlcmd mặc định chạy
-- với OFF -> không set ở đây thì lệnh CREATE INDEX bên dưới báo lỗi 1934.
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_ORDER_hold_until')
BEGIN
    CREATE INDEX IX_ORDER_hold_until ON [ORDER] (hold_until) WHERE hold_until IS NOT NULL;
END
GO
