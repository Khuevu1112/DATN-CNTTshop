-- ============================================================
-- 69_faq_ky_thuat.sql
-- Đổi danh mục FAQ "Xây dựng cấu hình PC" (ma=build_pc) thành "Kỹ thuật" (ma=ky_thuat) và bổ
-- sung các câu hỏi thiên về kỹ thuật (tần số quét, tương thích linh kiện, kích thước/độ phân
-- giải màn hình, tấm nền...). Các mục "Khám phá" trên menu trỏ tới đây bằng ?cat=ky_thuat.
--
-- CHẠY BẰNG: sqlcmd -f 65001 -i "D:\...\69_faq_ky_thuat.sql"  (không BOM, có Vietnamese data).
-- ============================================================
USE ShopDB;
GO

-- Đổi tên + mã danh mục. Giữ nguyên id nên các câu hỏi cũ (công cụ build PC) vẫn thuộc danh mục
-- này — chúng vốn đã mang tính kỹ thuật, hợp với tên mới.
UPDATE FAQ_CATEGORY
SET ma = 'ky_thuat',
    ten = N'Kỹ thuật',
    mo_ta = N'Kiến thức kỹ thuật: tương thích linh kiện, thông số màn hình, cấu hình PC',
    icon = N'🔧'
WHERE ma = 'build_pc';
GO

-- Thêm câu hỏi kỹ thuật vào danh mục Kỹ thuật (chỉ thêm nếu chưa có, tránh trùng khi chạy lại).
IF NOT EXISTS (SELECT 1 FROM FAQ_ITEM i JOIN FAQ_CATEGORY c ON c.id = i.category_id
               WHERE c.ma = 'ky_thuat' AND i.cau_hoi LIKE N'Tần số quét%')
BEGIN
    DECLARE @cat INT = (SELECT id FROM FAQ_CATEGORY WHERE ma = 'ky_thuat');

    INSERT INTO FAQ_ITEM (category_id, cau_hoi, tra_loi, tu_khoa, noi_bat, sort_order) VALUES
    (@cat,
     N'Tần số quét là gì? Chọn màn hình bao nhiêu Hz?',
     N'Tần số quét (Hz) là số lần màn hình làm mới hình ảnh mỗi giây. 60Hz đủ cho văn phòng; 144Hz trở lên cho cảm giác mượt rõ rệt khi chơi game; 240Hz/360Hz dành cho game bắn súng chuyên nghiệp. Muốn tận dụng tần số cao, card đồ họa phải đẩy được khung hình tương ứng.',
     N'tan so quet, hz, refresh rate, man hinh gaming', 1, 10),

    (@cat,
     N'Kiểm tra tương thích linh kiện khi build PC như thế nào?',
     N'Công cụ Xây dựng cấu hình PC của CNTTShop tự cảnh báo khi socket CPU không khớp mainboard, RAM sai thế hệ (DDR4/DDR5), nguồn không đủ công suất, hoặc VGA/tản nhiệt quá dài so với vỏ case. Bạn vẫn lưu được cấu hình có cảnh báo để nhân viên tư vấn xem lại cùng bạn.',
     N'tuong thich, build pc, socket, ddr4 ddr5, nguon, tuong thich linh kien', 1, 20),

    (@cat,
     N'Độ phân giải và kích thước màn hình nên chọn thế nào?',
     N'FHD (1920×1080) hợp màn 24-27 inch cho văn phòng/gaming phổ thông; 2K/QHD (2560×1440) cho 27 inch trở lên, cân bằng nét và hiệu năng; 4K/UHD cho làm đồ họa hoặc màn lớn từ 32 inch. Màn càng lớn với cùng độ phân giải thì mật độ điểm ảnh càng thấp, chữ có thể vỡ nếu ngồi gần.',
     N'do phan giai, kich thuoc, fhd 2k 4k, inch, resolution', 1, 30),

    (@cat,
     N'Tấm nền IPS, VA, TN khác nhau ra sao?',
     N'IPS: màu chuẩn, góc nhìn rộng — hợp đồ họa và dùng chung. VA: tương phản cao, màu đen sâu — hợp xem phim, một số màn cong. TN: thời gian phản hồi thấp, giá rẻ nhưng màu và góc nhìn kém — nay ít dùng. Đa số màn hình CNTTShop bán dùng tấm IPS.',
     N'tam nen, ips va tn, panel, goc nhin', 0, 40),

    (@cat,
     N'Nâng cấp máy cũ nên bắt đầu từ đâu?',
     N'Máy chậm thường cải thiện nhiều nhất khi thêm RAM và thay ổ cứng HDD sang SSD. Chơi game nặng thì nâng card đồ họa, nhưng phải kiểm tra nguồn có đủ công suất và CPU có bị nghẽn cổ chai không. Mang máy tới trung tâm dịch vụ hoặc dùng Trung tâm hỗ trợ để được tư vấn nâng cấp đúng nhu cầu.',
     N'nang cap, upgrade, ram ssd vga, co chai', 0, 50),

    (@cat,
     N'Thời gian phản hồi (ms) của màn hình quan trọng không?',
     N'Thời gian phản hồi càng thấp (1ms, 0.3ms) thì ảnh chuyển động càng ít bị bóng mờ — quan trọng với game tốc độ cao. Với văn phòng và đồ họa, thông số này ít ảnh hưởng, nên ưu tiên độ chính xác màu và độ phân giải hơn.',
     N'thoi gian phan hoi, response time, ms, ghosting', 0, 60);
END
GO
