-- ============================================================
-- 84_dedup_products.sql
-- GỘP CÁC SẢN PHẨM BỊ TRÙNG trong catalog.
--
-- Triệu chứng: tra đúng tên một sản phẩm thì kết quả trả về 2-4 thẻ giống hệt nhau.
--
-- Nguyên nhân (không phải lỗi code tìm kiếm — dữ liệu vốn đã trùng): các đợt nạp dữ liệu thật
-- trước đây ánh xạ NHIỀU bản ghi cũ vào CÙNG một mẫu có thật rồi UPDATE tên/giá/linh kiện tại
-- chỗ, thay vì xoá bớt. Xem chính lời ghi trong 51_pc_products_real_data_replace.sql:
--   "69 sản phẩm được ánh xạ tới 20 mẫu thật ... (mỗi mẫu dùng lại cho ~3-4 sản phẩm)".
-- Tác giả khi đó cố tình không xoá vì ORDER_ITEM đang tham chiếu (FK NO_ACTION sẽ chặn) —
-- nhưng hệ quả là các bản sao vẫn hiển thị đầy đủ cho khách. Cùng chuyện xảy ra với màn hình
-- và ngoại vi ở 55_/56_.
--
-- Cách xử lý ở đây (KHÔNG XOÁ, giữ nguyên mọi ràng buộc và lịch sử):
--   1. Nhóm theo (tên, danh mục) trong các sản phẩm ĐANG HIỂN THỊ.
--   2. Mỗi nhóm giữ lại ĐÚNG MỘT bản, chọn theo thứ tự ưu tiên:
--        a. Nhiều thông số + ảnh nhất  -> trang chi tiết đầy đặn nhất cho khách.
--        b. Đã từng bán được nhiều nhất -> giữ được số liệu "bán chạy" của sản phẩm.
--        c. Tồn kho lớn nhất, rồi id nhỏ nhất (bản cũ nhất) để kết quả ổn định.
--   3. Các bản còn lại: CHUYỂN TOÀN BỘ TỒN KHO sang biến thể mặc định của bản giữ lại (cùng
--      một món hàng ngoài đời, gộp lại thì tổng hàng bán được không đổi — ẩn suông sẽ làm bay
--      hơi phần tồn của các bản bị ẩn), rồi đặt is_active = 0.
--   4. Mọi lần chuyển kho đều ghi vào STOCK_MOVEMENT để đối chiếu lại được sau này.
--
-- Vì sao ẩn chứ không xoá: ORDER_ITEM / REVIEW / CART_ITEM đang trỏ vào các bản sao này
-- (23 biến thể đã có đơn, 2 đánh giá, 4 dòng giỏ hàng tại thời điểm viết). is_active = 0 làm
-- chúng biến mất khỏi mọi truy vấn phía khách (findByIsActiveTrue) trong khi lịch sử đơn hàng,
-- đánh giá và ràng buộc khoá ngoại vẫn nguyên vẹn — và đảo lại được nếu cần.
--
-- CHẠY LẠI NHIỀU LẦN AN TOÀN: chỉ xét các bản ghi is_active = 1, nên lần chạy thứ hai không
-- còn nhóm nào trùng để xử lý.
-- ============================================================
USE ShopDB;
GO

SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#xep_hang') IS NOT NULL DROP TABLE #xep_hang;
IF OBJECT_ID('tempdb..#gop') IS NOT NULL DROP TABLE #gop;

-- Chấm điểm từng sản phẩm trong các nhóm trùng tên (chỉ tính bản đang hiển thị).
SELECT
    p.id,
    p.name,
    p.category_id,
    (SELECT COUNT(*) FROM PRODUCT_SPEC s WHERE s.product_id = p.id)
      + (SELECT COUNT(*) FROM PRODUCT_IMAGE i WHERE i.product_id = p.id) AS do_day_du,
    ISNULL((SELECT SUM(oi.quantity) FROM ORDER_ITEM oi
            JOIN PRODUCT_VARIANT v ON v.id = oi.variant_id
            WHERE v.product_id = p.id), 0) AS da_ban,
    ISNULL((SELECT SUM(v.stock) FROM PRODUCT_VARIANT v WHERE v.product_id = p.id), 0) AS ton_kho
INTO #xep_hang
FROM PRODUCT p
WHERE p.is_active = 1
  AND EXISTS (SELECT 1 FROM PRODUCT q
              WHERE q.is_active = 1 AND q.name = p.name AND q.category_id = p.category_id AND q.id <> p.id);

-- Ghép mỗi bản BỊ ẨN với bản GIỮ LẠI của nhóm nó.
SELECT
    x.id            AS id_an,
    y.id            AS id_giu,
    x.ton_kho       AS ton_chuyen
INTO #gop
FROM (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY name, category_id
        ORDER BY do_day_du DESC, da_ban DESC, ton_kho DESC, id ASC) AS hang
    FROM #xep_hang
) x
JOIN (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY name, category_id
        ORDER BY do_day_du DESC, da_ban DESC, ton_kho DESC, id ASC) AS hang
    FROM #xep_hang
) y ON y.name = x.name AND y.category_id = x.category_id AND y.hang = 1
WHERE x.hang > 1;

-- PRINT không nhận truy vấn con -> đưa qua biến trước.
DECLARE @so_an INT = (SELECT COUNT(*) FROM #gop);
PRINT N'Số sản phẩm trùng sẽ được ẩn: ' + CAST(@so_an AS VARCHAR(10));

BEGIN TRANSACTION;

-- 1) Ghi nhật ký kho TRƯỚC khi đổi số, để note còn nói được tồn cũ là bao nhiêu.
--    Vế TRỪ: rút hết tồn khỏi biến thể của bản bị ẩn.
INSERT INTO STOCK_MOVEMENT (variant_id, change_qty, reason, note, created_at)
SELECT v.id, -v.stock, 'dieu_chinh',
       N'Gộp sản phẩm trùng: chuyển tồn sang sản phẩm #' + CAST(g.id_giu AS NVARCHAR(10)),
       GETDATE()
FROM #gop g
JOIN PRODUCT_VARIANT v ON v.product_id = g.id_an
WHERE v.stock > 0;

--    Vế CỘNG: dồn vào ĐÚNG biến thể mặc định của bản giữ lại (bản duy nhất được hiển thị giá
--    và tồn trên thẻ sản phẩm — xem CatalogApiService.pickVariant).
INSERT INTO STOCK_MOVEMENT (variant_id, change_qty, reason, note, created_at)
SELECT vg.id, g.ton_chuyen, 'dieu_chinh',
       N'Gộp sản phẩm trùng: nhận tồn từ sản phẩm #' + CAST(g.id_an AS NVARCHAR(10)),
       GETDATE()
FROM #gop g
JOIN PRODUCT_VARIANT vg ON vg.product_id = g.id_giu AND vg.is_default = 1
WHERE g.ton_chuyen > 0;

-- 2) Chuyển tồn thật sự.
UPDATE vg
SET vg.stock = vg.stock + t.tong, vg.version = vg.version + 1
FROM PRODUCT_VARIANT vg
JOIN (SELECT id_giu, SUM(ton_chuyen) AS tong FROM #gop GROUP BY id_giu) t ON t.id_giu = vg.product_id
WHERE vg.is_default = 1 AND t.tong > 0;

UPDATE v
SET v.stock = 0, v.version = v.version + 1
FROM PRODUCT_VARIANT v
JOIN #gop g ON g.id_an = v.product_id
WHERE v.stock <> 0;

-- 3) Ẩn bản trùng khỏi mọi màn hình phía khách.
UPDATE p SET p.is_active = 0
FROM PRODUCT p JOIN #gop g ON g.id_an = p.id;

COMMIT;

DECLARE @con_lai INT = (SELECT COUNT(*) FROM PRODUCT WHERE is_active = 1);
PRINT N'Đã gộp xong. Sản phẩm còn hiển thị: ' + CAST(@con_lai AS VARCHAR(10));
GO
