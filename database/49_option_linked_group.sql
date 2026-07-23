-- Cho phép admin đánh dấu 2 (hay nhiều) nhóm tuỳ chọn cấu hình phải "khoá cặp" đi cùng nhau
-- (vd CPU phải đi kèm đúng RAM tương ứng) thay vì tự do phối mọi tổ hợp.
-- NULL = độc lập (mặc định, giữ nguyên hành vi tự do phối hiện tại cho toàn bộ sản phẩm cũ).
-- Cùng 1 giá trị (khác NULL) trên 2 nhóm của cùng 1 sản phẩm = 2 nhóm đó bị khoá cặp với nhau.
ALTER TABLE PRODUCT_OPTION ADD linked_group NVARCHAR(50) NULL;
