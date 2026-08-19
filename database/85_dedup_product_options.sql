-- ============================================================
-- 85_dedup_product_options.sql
-- GỘP CÁC NHÓM TUỲ CHỌN BỊ TRÙNG TÊN trong cùng một sản phẩm.
--
-- Triệu chứng: trang chi tiết sản phẩm hiện HAI ô chọn "Cấu hình" giống hệt nhau, mỗi ô cùng
-- một danh sách giá trị. Ví dụ đã gặp: "Laptop Lenovo LOQ 15" có 2 nhóm PRODUCT_OPTION cùng
-- tên "Cấu hình" (id 1 và 2), mỗi nhóm 3 giá trị y hệt, và mỗi biến thể bị nối tới CẢ HAI —
-- nên nhãn biến thể trong admin cũng bị lặp: "i5 / 16GB / 512GB / i5 / 16GB / 512GB".
--
-- Nguyên nhân: dữ liệu mẫu nạp nhóm tuỳ chọn hai lần cho cùng sản phẩm; trước đây tầng lưu
-- sản phẩm cũng không chặn hai nhóm trùng tên (đã bổ sung kiểm tra ở AdminProductService).
--
-- Cách xử lý: mỗi (sản phẩm, tên nhóm) giữ lại nhóm có id NHỎ NHẤT, rồi:
--   1. Chuyển mọi liên kết biến thể đang trỏ vào giá trị của nhóm bị bỏ sang giá trị CÙNG TÊN
--      của nhóm được giữ. Biến thể nào sau khi chuyển bị trùng liên kết (vốn đã nối tới cả hai
--      nhóm) thì chỉ giữ lại một dòng.
--   2. Xoá các OPTION_VALUE và PRODUCT_OPTION của nhóm bị bỏ.
-- Không đụng tới PRODUCT_VARIANT: id/SKU/giá/kho và mọi tham chiếu từ ORDER_ITEM giữ nguyên.
--
-- CHẠY LẠI NHIỀU LẦN AN TOÀN: sau lần đầu không còn nhóm nào trùng tên để xử lý.
-- ============================================================
USE ShopDB;
GO

SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#gop_option') IS NOT NULL DROP TABLE #gop_option;

-- Ghép từng giá trị của nhóm BỊ BỎ với giá trị cùng tên của nhóm ĐƯỢC GIỮ.
SELECT
    ov_bo.id  AS gia_tri_bo,
    ov_giu.id AS gia_tri_giu,
    po_bo.id  AS nhom_bo
INTO #gop_option
FROM PRODUCT_OPTION po_bo
JOIN (
    SELECT product_id, option_name, MIN(id) AS id_giu
    FROM PRODUCT_OPTION
    GROUP BY product_id, option_name
    HAVING COUNT(*) > 1
) k ON k.product_id = po_bo.product_id AND k.option_name = po_bo.option_name AND po_bo.id <> k.id_giu
JOIN OPTION_VALUE ov_bo  ON ov_bo.option_id = po_bo.id
JOIN OPTION_VALUE ov_giu ON ov_giu.option_id = k.id_giu AND ov_giu.value = ov_bo.value;

DECLARE @so_gia_tri INT = (SELECT COUNT(*) FROM #gop_option);
DECLARE @so_nhom INT = (SELECT COUNT(DISTINCT nhom_bo) FROM #gop_option);
PRINT N'Nhóm tuỳ chọn trùng sẽ gộp: ' + CAST(@so_nhom AS VARCHAR(10))
      + N' (tương ứng ' + CAST(@so_gia_tri AS VARCHAR(10)) + N' giá trị)';

BEGIN TRANSACTION;

-- 1a) Biến thể đã nối tới CẢ hai nhóm -> xoá luôn liên kết tới nhóm bị bỏ (chuyển sang sẽ trùng).
DELETE vov
FROM VARIANT_OPTION_VALUE vov
JOIN #gop_option g ON g.gia_tri_bo = vov.option_value_id
WHERE EXISTS (
    SELECT 1 FROM VARIANT_OPTION_VALUE v2
    WHERE v2.variant_id = vov.variant_id AND v2.option_value_id = g.gia_tri_giu
);

-- 1b) Số còn lại: trỏ sang giá trị của nhóm được giữ.
UPDATE vov
SET vov.option_value_id = g.gia_tri_giu
FROM VARIANT_OPTION_VALUE vov
JOIN #gop_option g ON g.gia_tri_bo = vov.option_value_id;

-- 2) Dọn nhóm thừa. Đến đây không còn liên kết nào trỏ vào chúng nữa.
DELETE ov FROM OPTION_VALUE ov JOIN #gop_option g ON g.gia_tri_bo = ov.id;

DELETE ov FROM OPTION_VALUE ov
JOIN (SELECT DISTINCT nhom_bo FROM #gop_option) n ON n.nhom_bo = ov.option_id;

DELETE po FROM PRODUCT_OPTION po
JOIN (SELECT DISTINCT nhom_bo FROM #gop_option) n ON n.nhom_bo = po.id;

COMMIT;

DECLARE @con_trung INT = (
    SELECT COUNT(*) FROM (
        SELECT product_id FROM PRODUCT_OPTION GROUP BY product_id, option_name HAVING COUNT(*) > 1
    ) x);
PRINT N'Đã gộp xong. Sản phẩm còn nhóm tuỳ chọn trùng tên: ' + CAST(@con_trung AS VARCHAR(10));
GO
