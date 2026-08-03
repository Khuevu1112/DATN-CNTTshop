-- ============================================================
-- 73_articles_bulk.sql
-- Bo sung ~10 bai viet CHI TIET: 5 bai kien thuc lay tu Trung tam ho tro (bao hanh / doi tra /
-- ky thuat / bao duong) + 5 bai kieu tin cong nghe (tham khao nguyencongpc: so sanh CPU/GPU,
-- build PC, review laptop, SSD...). Idempotent: moi bai guard theo slug.
--
-- Vietnamese trong noi dung => chay: sqlcmd -f 65001 -i "D:\...\73_articles_bulk.sql"
-- ============================================================
USE ShopDB;
GO

DECLARE @cn INT = (SELECT id FROM ARTICLE_CATEGORY WHERE ma='cong_nghe');
DECLARE @rv INT = (SELECT id FROM ARTICLE_CATEGORY WHERE ma='review');
DECLARE @hd INT = (SELECT id FROM ARTICLE_CATEGORY WHERE ma='huong_dan');
DECLARE @bp INT = (SELECT id FROM ARTICLE_CATEGORY WHERE ma='build_pc');

-- ===== 5 bai tu Trung tam ho tro =====

IF NOT EXISTS (SELECT 1 FROM ARTICLE WHERE slug='phan-biet-bao-hanh-va-doi-tra')
INSERT INTO ARTICLE (slug, tieu_de, thumbnail, category_id, tom_tat, noi_dung, tac_gia, trang_thai, noi_bat, published_at) VALUES
('phan-biet-bao-hanh-va-doi-tra',
 N'Phân biệt bảo hành và đổi trả: quyền lợi khách hàng cần biết',
 'https://placehold.co/600x360/1c1e22/c6ff4a?text=Bao+Hanh+vs+Doi+Tra', @hd,
 N'Bảo hành và đổi trả là hai chính sách khác nhau. Hiểu đúng để dùng đúng quyền lợi khi sản phẩm gặp vấn đề.',
 N'<p>Nhiều khách hàng nhầm lẫn giữa <strong>bảo hành</strong> và <strong>đổi trả</strong>. Hai chính sách này áp dụng cho các tình huống hoàn toàn khác nhau.</p>
<h3>Đổi trả — lỗi ngay khi nhận hàng</h3>
<p>Áp dụng trong <strong>7 ngày</strong> kể từ khi nhận hàng, theo hình thức 1 đổi 1 với sản phẩm lỗi nhà sản xuất, giao sai mẫu hoặc không đúng mô tả. Sản phẩm phải còn nguyên hộp, tem và phụ kiện. Đơn mua online cần kèm video tự tay mở hàng.</p>
<h3>Bảo hành — lỗi phát sinh khi sử dụng lâu dài</h3>
<p>Áp dụng theo thời hạn của từng nhóm hàng (12 - 36 tháng), cho lỗi kỹ thuật xuất hiện trong quá trình dùng. Khách mang máy tới trung tâm hoặc đặt lịch dịch vụ.</p>
<ul><li>Còn 7 ngày đầu, lỗi rõ ràng: dùng <em>đổi trả</em>.</li><li>Đã dùng một thời gian mới hỏng: dùng <em>bảo hành</em>.</li></ul>
<p>Xem chi tiết tại trang Thông tin bảo hành và Chính sách đổi trả trong Trung tâm hỗ trợ.</p>',
 N'CNTTShop', 'published', 0, DATEADD(day,-9,GETDATE()));

IF NOT EXISTS (SELECT 1 FROM ARTICLE WHERE slug='dieu-kien-ho-so-doi-tra-7-ngay')
INSERT INTO ARTICLE (slug, tieu_de, thumbnail, category_id, tom_tat, noi_dung, tac_gia, trang_thai, noi_bat, published_at) VALUES
('dieu-kien-ho-so-doi-tra-7-ngay',
 N'Đổi trả 1 đổi 1 trong 7 ngày: điều kiện và hồ sơ cần chuẩn bị',
 'https://placehold.co/600x360/1c1e22/c6ff4a?text=Doi+Tra+7+Ngay', @hd,
 N'Chuẩn bị đúng minh chứng giúp yêu cầu đổi trả được duyệt nhanh, tránh tranh chấp không đáng có.',
 N'<h3>Điều kiện đổi trả</h3>
<ul><li>Trong vòng 7 ngày kể từ khi nhận hàng.</li><li>Lỗi do nhà sản xuất, giao sai mẫu/cấu hình, hoặc không đúng mô tả.</li><li>Còn đủ hộp, tem niêm phong, phụ kiện; không trầy xước do người dùng.</li></ul>
<h3>Hồ sơ cần chuẩn bị</h3>
<p>Khi gửi yêu cầu ở Trung tâm hỗ trợ, bạn đính kèm:</p>
<ul><li><strong>Video minh chứng lỗi</strong> — quay rõ hiện tượng.</li><li><strong>Video tự tay mở hàng</strong> — bắt buộc với đơn online, là bằng chứng chống tranh chấp.</li><li><strong>Ảnh lỗi</strong> — tối đa 3 ảnh.</li></ul>
<p>CSKH phản hồi trong 24 giờ làm việc. Được chấp nhận sẽ đổi sản phẩm mới hoặc hoàn tiền về nguồn thanh toán gốc.</p>',
 N'CNTTShop', 'published', 0, DATEADD(day,-10,GETDATE()));

IF NOT EXISTS (SELECT 1 FROM ARTICLE WHERE slug='chon-man-hinh-tan-so-quet-tam-nen')
INSERT INTO ARTICLE (slug, tieu_de, thumbnail, category_id, tom_tat, noi_dung, tac_gia, trang_thai, noi_bat, published_at) VALUES
('chon-man-hinh-tan-so-quet-tam-nen',
 N'Chọn màn hình đúng nhu cầu: tần số quét, tấm nền và độ phân giải',
 'https://placehold.co/600x360/1c1e22/c6ff4a?text=Chon+Man+Hinh', @hd,
 N'Ba thông số quyết định trải nghiệm màn hình. Nắm rõ để không chi thừa tiền hoặc mua thiếu.',
 N'<h3>Tần số quét (Hz)</h3>
<p>60Hz đủ cho văn phòng; 144Hz trở lên cho cảm giác mượt khi chơi game; 240Hz/360Hz cho game bắn súng chuyên nghiệp. Card đồ họa phải đẩy đủ khung hình mới tận dụng được.</p>
<h3>Tấm nền</h3>
<ul><li><strong>IPS</strong>: màu chuẩn, góc nhìn rộng — hợp đồ họa và dùng chung.</li><li><strong>VA</strong>: tương phản cao, đen sâu — hợp xem phim, màn cong.</li><li><strong>TN</strong>: phản hồi thấp, giá rẻ nhưng màu kém — nay ít dùng.</li></ul>
<h3>Độ phân giải &amp; kích thước</h3>
<p>FHD hợp 24-27 inch phổ thông; 2K/QHD cho 27 inch trở lên; 4K cho làm đồ họa hoặc màn từ 32 inch. Màn càng lớn cùng độ phân giải thì mật độ điểm ảnh càng thấp.</p>',
 N'CNTTShop', 'published', 0, DATEADD(day,-11,GETDATE()));

IF NOT EXISTS (SELECT 1 FROM ARTICLE WHERE slug='kiem-tra-tuong-thich-linh-kien-build-pc')
INSERT INTO ARTICLE (slug, tieu_de, thumbnail, category_id, tom_tat, noi_dung, tac_gia, trang_thai, noi_bat, published_at) VALUES
('kiem-tra-tuong-thich-linh-kien-build-pc',
 N'Tự build PC: cách kiểm tra tương thích linh kiện',
 'https://placehold.co/600x360/1c1e22/c6ff4a?text=Tuong+Thich+PC', @bp,
 N'Những điểm tương thích quan trọng nhất khi ráp một dàn PC để tránh mua nhầm, lắp không vừa.',
 N'<p>Trước khi chốt cấu hình, hãy kiểm tra các điểm tương thích sau:</p>
<ul>
<li><strong>Socket CPU và mainboard</strong> phải khớp (AM5, LGA1700, LGA1851...).</li>
<li><strong>RAM đúng thế hệ</strong>: DDR4 và DDR5 không cắm lẫn nhau.</li>
<li><strong>Công suất nguồn</strong> đủ cho CPU + VGA, nên dư khoảng 30% headroom.</li>
<li><strong>Kích thước VGA và tản nhiệt</strong> không vượt giới hạn của vỏ case.</li>
<li><strong>Chuẩn cỡ mainboard</strong> (ATX/mATX/ITX) khớp với case.</li>
</ul>
<p>Công cụ <em>Xây dựng cấu hình PC</em> của CNTTShop tự cảnh báo khi các điều kiện trên không thỏa, và vẫn cho lưu cấu hình để nhân viên tư vấn kiểm tra lại cùng bạn.</p>',
 N'CNTTShop', 'published', 0, DATEADD(day,-12,GETDATE()));

IF NOT EXISTS (SELECT 1 FROM ARTICLE WHERE slug='bao-duong-pc-laptop-dinh-ky')
INSERT INTO ARTICLE (slug, tieu_de, thumbnail, category_id, tom_tat, noi_dung, tac_gia, trang_thai, noi_bat, published_at) VALUES
('bao-duong-pc-laptop-dinh-ky',
 N'Bảo dưỡng PC và laptop định kỳ để máy luôn mượt',
 'https://placehold.co/600x360/1c1e22/c6ff4a?text=Bao+Duong+May', @hd,
 N'Vệ sinh và tra keo tản nhiệt định kỳ giúp máy mát, chạy ổn định và bền hơn nhiều.',
 N'<p>Sau 6 - 12 tháng, bụi bám và keo tản nhiệt khô khiến máy nóng, giảm hiệu năng và ồn hơn. Bảo dưỡng định kỳ là cách rẻ nhất để giữ máy khỏe.</p>
<h3>Nên làm gì</h3>
<ul><li>Vệ sinh quạt, khe tản nhiệt, lá tản.</li><li>Tra lại keo tản nhiệt CPU/GPU.</li><li>Kiểm tra nhiệt độ khi tải nặng, tối ưu luồng gió trong case.</li><li>Với laptop: kiểm tra pin chai, vệ sinh bàn phím.</li></ul>
<p>CNTTShop có các gói <strong>Combo sửa chữa</strong> (Full Case, Laptop + phụ kiện...) và bảng giá công khai. Xem trang Bảng giá sửa chữa để ước tính chi phí trước khi mang máy tới.</p>',
 N'CNTTShop', 'published', 0, DATEADD(day,-13,GETDATE()));

-- ===== 5 bai kieu tin cong nghe / review / build =====

IF NOT EXISTS (SELECT 1 FROM ARTICLE WHERE slug='rtx-5070-vs-rtx-4070-super')
INSERT INTO ARTICLE (slug, tieu_de, thumbnail, category_id, tom_tat, noi_dung, tac_gia, trang_thai, noi_bat, published_at) VALUES
('rtx-5070-vs-rtx-4070-super',
 N'RTX 5070 vs RTX 4070 SUPER: chọn card nào để chơi 2K?',
 'https://placehold.co/600x360/1c1e22/c6ff4a?text=RTX+5070+vs+4070S', @rv,
 N'So sánh hiệu năng, mức giá và công nghệ để chọn card đồ họa hợp lý cho độ phân giải 2K.',
 N'<p>Ở phân khúc tầm trung cao, <strong>RTX 5070</strong> và <strong>RTX 4070 SUPER</strong> đều thừa sức chơi 2K ở thiết lập cao.</p>
<h3>Hiệu năng</h3>
<p>RTX 5070 nhỉnh hơn khoảng 15 - 20% ở phần lớn tựa game và hỗ trợ thế hệ DLSS mới, giúp khung hình mượt hơn khi bật ray tracing.</p>
<h3>Nên chọn gì</h3>
<ul><li>Muốn hiệu năng mới nhất, chơi lâu dài: RTX 5070.</li><li>Ưu tiên giá tốt, đã có sẵn hàng: RTX 4070 SUPER vẫn rất đáng tiền.</li></ul>
<p>Dù chọn card nào, hãy đảm bảo nguồn đủ công suất và CPU không bị nghẽn cổ chai.</p>',
 N'CNTTShop', 'published', 1, DATEADD(day,-3,GETDATE()));

IF NOT EXISTS (SELECT 1 FROM ARTICLE WHERE slug='ddr5-vs-ddr4-2025')
INSERT INTO ARTICLE (slug, tieu_de, thumbnail, category_id, tom_tat, noi_dung, tac_gia, trang_thai, noi_bat, published_at) VALUES
('ddr5-vs-ddr4-2025',
 N'DDR5 vs DDR4 năm 2025: đã đến lúc chuyển chưa?',
 'https://placehold.co/600x360/1c1e22/c6ff4a?text=DDR5+vs+DDR4', @cn,
 N'Giá DDR5 đã hạ, nhưng liệu nâng cấp có đáng với nhu cầu của bạn? Cùng phân tích.',
 N'<p><strong>DDR5</strong> mang lại băng thông cao hơn và là chuẩn của các nền tảng CPU mới. Năm 2025 giá đã dễ chịu hơn nhiều so với thời điểm ra mắt.</p>
<h3>Khi nào nên chọn DDR5</h3>
<ul><li>Ráp máy mới với CPU đời mới (chỉ hỗ trợ DDR5).</li><li>Làm việc nặng RAM: dựng phim, ảo hóa, nhiều tab/ứng dụng.</li></ul>
<h3>Khi nào DDR4 vẫn ổn</h3>
<p>Nếu bạn đang dùng nền tảng DDR4 và chủ yếu chơi game, khác biệt thực tế thường nhỏ. Nâng cấp SSD hoặc VGA có thể đáng tiền hơn.</p>',
 N'CNTTShop', 'published', 0, DATEADD(day,-5,GETDATE()));

IF NOT EXISTS (SELECT 1 FROM ARTICLE WHERE slug='build-pc-gaming-20-trieu-2025')
INSERT INTO ARTICLE (slug, tieu_de, thumbnail, category_id, tom_tat, noi_dung, tac_gia, trang_thai, noi_bat, published_at) VALUES
('build-pc-gaming-20-trieu-2025',
 N'Gợi ý build PC gaming 20 triệu chiến mọi tựa game 2025',
 'https://placehold.co/600x360/1c1e22/c6ff4a?text=Build+20+Trieu', @bp,
 N'Một cấu hình cân bằng quanh mốc 20 triệu, chơi tốt ở Full HD và chạm ngưỡng 2K.',
 N'<p>Với khoảng 20 triệu, mục tiêu là cân bằng giữa CPU và VGA để không nghẽn cổ chai, kèm màn hình tần số quét cao.</p>
<h3>Định hướng linh kiện</h3>
<ul><li><strong>CPU</strong>: 6 nhân đời mới, đủ mạnh cho game và làm việc.</li><li><strong>VGA</strong>: card tầm trung chơi mượt Full HD, ổn ở 2K.</li><li><strong>RAM</strong>: 16GB (2x8) đủ dùng, có thể lên 32GB.</li><li><strong>SSD NVMe</strong>: 1TB cho tốc độ tải nhanh.</li><li><strong>Nguồn</strong>: chuẩn 80 Plus, dư công suất.</li></ul>
<p>Dùng công cụ Xây dựng cấu hình PC để chốt linh kiện tương thích và xem tổng giá theo thời gian thực. Có hỗ trợ trả góp 0%.</p>',
 N'CNTTShop', 'published', 0, DATEADD(day,-7,GETDATE()));

IF NOT EXISTS (SELECT 1 FROM ARTICLE WHERE slug='top-5-laptop-gaming-nua-cuoi-2025')
INSERT INTO ARTICLE (slug, tieu_de, thumbnail, category_id, tom_tat, noi_dung, tac_gia, trang_thai, noi_bat, published_at) VALUES
('top-5-laptop-gaming-nua-cuoi-2025',
 N'Top 5 laptop gaming đáng mua nửa cuối 2025',
 'https://placehold.co/600x360/1c1e22/c6ff4a?text=Top+Laptop+Gaming', @rv,
 N'Các mẫu laptop gaming cân bằng hiệu năng, nhiệt độ và giá cho từng nhóm ngân sách.',
 N'<p>Nửa cuối 2025 có nhiều lựa chọn laptop gaming tốt ở đủ tầm giá. Dưới đây là các tiêu chí và nhóm sản phẩm đáng chú ý.</p>
<h3>Tiêu chí chọn</h3>
<ul><li>CPU + GPU cân bằng, tản nhiệt tốt để giữ xung ổn định.</li><li>Màn hình 144Hz trở lên, tấm nền IPS.</li><li>Bàn phím, cổng kết nối và thời lượng pin phù hợp nhu cầu.</li></ul>
<h3>Gợi ý theo ngân sách</h3>
<p>Tầm 20 - 25 triệu: cấu hình chơi tốt Full HD. Tầm 30 - 40 triệu: chiến 2K, sáng tạo nội dung. Xem danh mục Laptop và bộ lọc Laptop Gaming để so sánh nhanh.</p>',
 N'CNTTShop', 'published', 0, DATEADD(day,-8,GETDATE()));

IF NOT EXISTS (SELECT 1 FROM ARTICLE WHERE slug='ssd-pcie-5-0-nhanh-co-nao')
INSERT INTO ARTICLE (slug, tieu_de, thumbnail, category_id, tom_tat, noi_dung, tac_gia, trang_thai, noi_bat, published_at) VALUES
('ssd-pcie-5-0-nhanh-co-nao',
 N'SSD PCIe 5.0 nhanh cỡ nào và ai thực sự cần?',
 'https://placehold.co/600x360/1c1e22/c6ff4a?text=SSD+PCIe+5.0', @cn,
 N'SSD PCIe 5.0 đạt tốc độ tuần tự rất cao, nhưng lợi ích thực tế còn tùy nhu cầu.',
 N'<p><strong>SSD PCIe 5.0</strong> có thể đạt tốc độ đọc tuần tự trên 10.000 MB/s, gấp đôi PCIe 4.0. Nhưng con số ấn tượng này không phải lúc nào cũng chuyển thành trải nghiệm nhanh hơn rõ rệt.</p>
<h3>Ai nên dùng</h3>
<ul><li>Làm việc với file rất lớn: dựng video 4K/8K, sao chép dữ liệu khối lượng lớn.</li><li>Muốn nền tảng tương lai và có ngân sách.</li></ul>
<h3>Đa số người dùng</h3>
<p>Với chơi game và văn phòng, PCIe 4.0 (thậm chí 3.0) đã cho thời gian tải gần như tương đương. Ưu tiên dung lượng và độ bền thay vì chạy theo tốc độ đỉnh. Lưu ý SSD PCIe 5.0 tỏa nhiệt cao, cần tản nhiệt tốt.</p>',
 N'CNTTShop', 'published', 0, DATEADD(day,-6,GETDATE()));
GO
