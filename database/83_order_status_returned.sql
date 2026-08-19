-- ============================================================
-- 83_order_status_returned.sql
-- Thêm trạng thái đơn "returned" (HOÀN HÀNG) và tách bạch nó với "refunded" (HOÀN TIỀN).
--
-- Vì sao cần: trước đây chỉ có "refunded", nên khi khách trả hàng về, admin buộc phải đánh
-- luôn là đã hoàn tiền dù tiền chưa chuyển đi — báo cáo doanh thu và đối soát công nợ đều sai,
-- còn khách thì nhận thông báo "đã hoàn tiền" trong lúc chưa nhận được đồng nào.
--
-- Ý nghĩa từng trạng thái sau thay đổi này (xem OrderService.MO_TA_TRANG_THAI):
--   pending    Đơn vừa tạo, chưa ai xác nhận.
--   confirmed  Shop đã nhận đơn, cam kết có hàng.
--   processing Đang soạn/đóng gói, chưa rời kho.
--   shipped    Đã bàn giao vận chuyển, HÀNG ĐANG TRÊN ĐƯỜNG (từ mốc này KHÔNG huỷ được nữa).
--   delivered  Khách đã nhận hàng, đơn kết thúc bình thường.
--   cancelled  Huỷ TRƯỚC khi hàng rời kho — hàng chưa từng đi đâu.
--   returned   Hàng ĐÃ QUAY VỀ kho shop (khách từ chối nhận / trả lại) — tiền CHƯA trả.
--   refunded   Đã chuyển tiền lại cho khách. Chỉ tới được từ "returned".
-- ============================================================
USE ShopDB;
GO

-- Ràng buộc CHECK cũ được đặt tên tự sinh -> tra ngược theo bảng/cột thay vì đoán tên.
DECLARE @ten SYSNAME;
SELECT @ten = cc.name
FROM sys.check_constraints cc
JOIN sys.columns c ON c.object_id = cc.parent_object_id AND c.column_id = cc.parent_column_id
WHERE cc.parent_object_id = OBJECT_ID('[ORDER]') AND c.name = 'status';

IF @ten IS NOT NULL
BEGIN
    EXEC('ALTER TABLE [ORDER] DROP CONSTRAINT ' + @ten);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE parent_object_id = OBJECT_ID('[ORDER]') AND name = 'CK_ORDER_status'
)
BEGIN
    ALTER TABLE [ORDER] ADD CONSTRAINT CK_ORDER_status CHECK (status IN (
        'pending', 'confirmed', 'processing', 'shipped',
        'delivered', 'cancelled', 'returned', 'refunded'
    ));
END
GO
