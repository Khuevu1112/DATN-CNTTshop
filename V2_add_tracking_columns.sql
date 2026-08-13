-- ============================================================
--  Migration: mở rộng tracking cho GHN, Viettel Post, Shopee Express
-- ============================================================

-- Order: lưu mã vận đơn ngoài (GHN order_code / SPX tracking_number) + id tracking AfterShip
ALTER TABLE [ORDER]
    ADD external_tracking_number NVARCHAR(100) NULL,
        aftership_tracking_id    NVARCHAR(100) NULL;
GO

-- Carrier: cột override đã thêm ở migration trước (V_add_carrier_fee_override.sql).
-- Thêm carrier "viettelpost" nếu chưa có — bỏ comment nếu cần:
--
-- INSERT INTO CARRIER (code, name, fee_lien_tinh, time_cung_mien, time_khac_mien, is_active, thu_tu)
-- VALUES (N'viettelpost', N'Viettel Post', 28000, N'2-3 ngày', N'4-6 ngày', 1, 2);
-- GO

-- Xác nhận
SELECT code, name, fee_lien_tinh, fee_override, is_active FROM CARRIER ORDER BY thu_tu;
