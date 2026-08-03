-- ============================================================
-- 67_support_adjust.sql
-- Tinh chỉnh Trung tâm hỗ trợ theo yêu cầu nghiệp vụ sau khi dựng xong 66:
--   1. Gộp "Máy in" + "Thiết bị mạng" thành MỘT nhóm "Thiết bị ngoại vi" (mã ngoai_vi) ở khắp
--      nơi có loại thiết bị: bảng giá sửa chữa, lịch hẹn, danh sách dịch vụ của trung tâm, và
--      dòng chính sách bảo hành tương ứng.
--   2. Thêm cột chi_phi cho SERVICE_APPOINTMENT — dùng cho "Lịch sử bảo hành" phía khách (mỗi
--      lần sửa hoàn thành, kỹ thuật ghi lại chi phí thực để khách tra lại về sau).
--
-- ------------------------------------------------------------
-- LƯU Ý KHI CHẠY (giống 66_support_center.sql):
--   * File này CÓ BOM UTF-8 — đừng xoá, nếu không sqlcmd đọc theo ANSI và mọi chữ tiếng Việt
--     trong câu UPDATE ... WHERE nhom_hang = N'Máy in...' sẽ khớp 0 dòng.
--   * SERVICE_APPOINTMENT mang FILTERED INDEX nên MỌI thao tác ghi (kể cả UPDATE dưới đây và
--     ALTER ADD cột) đều đòi SET QUOTED_IDENTIFIER ON.
-- ============================================================
USE ShopDB;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- ===== 1. Gộp máy in + thiết bị mạng -> thiết bị ngoại vi =====

-- 1a. Bảng giá sửa chữa: đổi thẳng mã loại.
UPDATE REPAIR_PRICE SET loai_thiet_bi = 'ngoai_vi'
WHERE loai_thiet_bi IN ('may_in', 'thiet_bi_mang');
GO

-- 1b. Lịch hẹn đã có: giữ lịch sử đúng nhóm mới.
UPDATE SERVICE_APPOINTMENT SET loai_thiet_bi = 'ngoai_vi'
WHERE loai_thiet_bi IN ('may_in', 'thiet_bi_mang');
GO

-- 1c. Danh sách dịch vụ của trung tâm là CSV. Đổi từng token rồi khử trùng lặp: trung tâm nào
-- nhận cả hai nhóm cũ sẽ thành "ngoai_vi,ngoai_vi" (hai token liền nhau vì trong seed 66 chúng
-- luôn đứng cạnh nhau ở cuối chuỗi), REPLACE lần cuối gộp lại còn một.
UPDATE SERVICE_CENTER SET dich_vu = REPLACE(dich_vu, 'may_in', 'ngoai_vi')
WHERE dich_vu LIKE '%may_in%';
GO
UPDATE SERVICE_CENTER SET dich_vu = REPLACE(dich_vu, 'thiet_bi_mang', 'ngoai_vi')
WHERE dich_vu LIKE '%thiet_bi_mang%';
GO
UPDATE SERVICE_CENTER SET dich_vu = REPLACE(dich_vu, 'ngoai_vi,ngoai_vi', 'ngoai_vi')
WHERE dich_vu LIKE '%ngoai_vi,ngoai_vi%';
GO

-- 1d. Dòng chính sách bảo hành: nhóm hàng "Máy in / Thiết bị mạng" -> "Thiết bị ngoại vi".
UPDATE WARRANTY_POLICY
SET nhom_hang = N'Thiết bị ngoại vi',
    mo_ta = N'Bàn phím, chuột, tai nghe, máy in và thiết bị mạng. Vật tư tiêu hao (mực in, pin, đệm mút) không thuộc phạm vi bảo hành.'
WHERE nhom_hang = N'Máy in / Thiết bị mạng';
GO

-- 1e. Bổ sung vài hạng mục ngoại vi phổ biến để nhóm mới không chỉ toàn máy in/mạng.
IF NOT EXISTS (SELECT 1 FROM REPAIR_PRICE WHERE loai_thiet_bi='ngoai_vi' AND ma_loi='thay_switch_phim')
BEGIN
    INSERT INTO REPAIR_PRICE (loai_thiet_bi, ma_loi, ten_loi, gia_linh_kien, tien_cong, gia_den, thoi_gian_du_kien, bao_hanh_thang, sort_order) VALUES
    (N'ngoai_vi', 'thay_switch_phim', N'Thay switch bàn phím cơ (mỗi phím)',   15000,  30000,  120000, N'1-2 giờ', 3, 232),
    (N'ngoai_vi', 've_sinh_phim_chuot', N'Vệ sinh bàn phím / chuột',                  0,  80000,  150000, N'30 phút', 1, 234),
    (N'ngoai_vi', 'thay_nut_chuot', N'Thay nút bấm / encoder cuộn chuột',        45000,  80000,  220000, N'1 giờ',   3, 236),
    (N'ngoai_vi', 'sua_tai_nghe',   N'Sửa tai nghe (rè, đứt tiếp xúc)',         60000, 120000,  400000, N'1-2 ngày', 3, 238);
END
GO

-- ===== 2. Chi phí thực của một lần sửa (phục vụ "Lịch sử bảo hành" phía khách) =====
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME='SERVICE_APPOINTMENT' AND COLUMN_NAME='chi_phi')
BEGIN
    ALTER TABLE SERVICE_APPOINTMENT ADD chi_phi DECIMAL(12,2) NULL;
END
GO
