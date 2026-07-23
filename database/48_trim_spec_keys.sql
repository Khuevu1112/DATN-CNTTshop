-- Dọn dữ liệu: một số PRODUCT_SPEC.spec_key nhập tay bị dính khoảng trắng thừa
-- (vd "Mainboard  "), khiến so khớp chính xác theo tên khoá ở FE (lọc theo Mainboard/...) bị bỏ sót.
-- Lưu ý: so sánh bằng <> không phát hiện được lệch khoảng trắng cuối chuỗi do SQL Server áp dụng
-- ANSI padding khi so sánh NVARCHAR (bỏ qua trailing space) -> phải so DATALENGTH (độ dài byte thật).
UPDATE PRODUCT_SPEC
SET spec_key = LTRIM(RTRIM(spec_key))
WHERE DATALENGTH(spec_key) <> DATALENGTH(LTRIM(RTRIM(spec_key)));
