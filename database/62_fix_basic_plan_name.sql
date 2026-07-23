-- ============================================================
-- 62_fix_basic_plan_name.sql
-- Sửa tên gói 'basic' bị hỏng dấu tiếng Việt: 61_membership_subscription.sql chèn
-- N'CNTT Care Cơ bản' nhưng nếu chạy bằng `sqlcmd -i` KHÔNG kèm `-f 65001` thì literal tiếng
-- Việt bị mã hoá kép -> lưu thành "CNTT Care CÆ¡ báº£n" (chỉ gói basic dính vì Plus/Pro không dấu).
--
-- Migration này ghi lại tên đúng bằng NCHAR(code point) nên NGUỒN CHỈ TOÀN ASCII — chạy kiểu gì
-- (có hay không -f 65001) đều ra đúng, không lặp lại lỗi mã hoá. "Cơ bản": ơ=U+01A1, ả=U+1EA3.
-- Idempotent: đặt lại đúng tên, chạy nhiều lần vô hại.
-- ============================================================
USE ShopDB;
GO

UPDATE SUBSCRIPTION_PLAN
SET name = N'CNTT Care C' + NCHAR(0x01A1) + N' b' + NCHAR(0x1EA3) + N'n'
WHERE code = 'basic';
GO
