-- Sửa lỗi nhập liệu: spec_value của CPU bị dính thừa tiền tố "CPU " (trùng với spec_key),
-- khiến giá trị không còn bắt đầu bằng tên hãng (AMD/Intel) -> lọc theo hãng CPU ở FE bị sai.
UPDATE PRODUCT_SPEC
SET spec_value = LTRIM(SUBSTRING(spec_value, 5, LEN(spec_value)))
WHERE spec_key = 'CPU' AND spec_value LIKE 'CPU %';
