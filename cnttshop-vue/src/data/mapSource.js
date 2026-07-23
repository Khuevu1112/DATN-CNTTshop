/* ===========================================================================
 * NGUỒN BẢN ĐỒ — nơi duy nhất quyết định bản đồ lấy tile từ đâu.
 *
 * LÝ DO TỒN TẠI FILE NÀY: tile OpenStreetMap tiêu chuẩn có vẽ ranh giới biển tranh chấp trên
 * Biển Đông (đường lưỡi bò), và nhãn địa danh của OSM phần lớn còn mang tên hành chính TRƯỚC
 * đợt sáp nhập 1/7/2025. Cả hai đều không chấp nhận được với sản phẩm phục vụ người dùng Việt
 * Nam. Nguồn trong nước xử lý được cả hai, nhưng bắt buộc phải có API key riêng.
 *
 * ------------------------------------------------------------------
 * CÁCH BẬT NGUỒN TRONG NƯỚC (VietMap)
 * ------------------------------------------------------------------
 * 1. Đăng ký tài khoản tại https://maps.vietmap.vn và tạo API key.
 * 2. Ở trang quản lý key, GIỚI HẠN key theo referer (domain của shop) — key nằm trong mã
 *    JavaScript chạy ở trình duyệt nên ai cũng đọc được, giới hạn referer là thứ duy nhất ngăn
 *    người khác xài chùa hạn mức của bạn.
 * 3. Tạo file cnttshop-vue/.env.local với nội dung:
 *        VITE_VIETMAP_KEY=key_vua_tao
 * 4. Chạy lại `npm run dev` (Vite chỉ đọc biến môi trường lúc khởi động).
 *
 * Chưa có key thì hệ thống tự chạy tiếp bằng OpenStreetMap, KÈM khoá vùng nhìn ở MapPicker để
 * vùng biển tranh chấp không lọt vào khung hình. Đó là giải pháp tạm, không phải giải pháp đúng.
 * =========================================================================== */

export const VIETMAP_KEY = import.meta.env.VITE_VIETMAP_KEY || '';

/** true = đang dùng nguồn trong nước. UI dựa vào cờ này để hiện cảnh báo cho admin. */
export const dungNguonTrongNuoc = Boolean(VIETMAP_KEY);

/** Gắn apikey vào MỌI request gửi tới VietMap.
 *
 * Bắt buộc phải có: style.json tải được bằng key trong URL, nhưng bên trong nó lại khai báo
 * tiếp URL của vector tiles, glyphs (font) và sprite — những URL đó KHÔNG tự mang theo key.
 * Thiếu bước này thì style tải xong, mọi tài nguyên con bị từ chối, MapLibre thử lại liên tục
 * và kết quả là bản đồ trắng trong khi quota vẫn đếm lên hàng chục request. */
export function ganKeyVaoRequest(url) {
  if (!url.includes('vietmap.vn') || url.includes('apikey=')) return { url };
  return { url: url + (url.includes('?') ? '&' : '?') + 'apikey=' + VIETMAP_KEY };
}

/** RASTER {z}/{x}/{y} — thử trước vì Leaflet đọc thẳng được, không cần MapLibre.
 * "tm" là mã style bản đồ đường phố (tài liệu VietMap ghi "st" cho ảnh vệ tinh). Consumer của
 * shop tên "public tile" và quyền được bật đúng là "Tile", nên đây nhiều khả năng là endpoint
 * hợp lệ với gói đang dùng. */
export const VIETMAP_RASTER_URL =
  'https://maps.vietmap.vn/maps/tiles/tm/{z}/{x}/{y}.png?apikey=' + VIETMAP_KEY;

/** Style vector — phương án hai, phải vẽ qua MapLibre vì Leaflet L.tileLayer không đọc style.json. */
export const VIETMAP_STYLE_URL =
  'https://maps.vietmap.vn/maps/styles/tm/style.json?apikey=' + VIETMAP_KEY;

/** Nguồn dự phòng khi chưa cấu hình key. */
export const OSM_TILE_URL = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';

export const ATTRIBUTION = dungNguonTrongNuoc
  ? '&copy; VietMap'
  : '&copy; OpenStreetMap';

/* ===== KHOÁ VÙNG NHÌN — KHÔNG NỚI LỎNG KHI CHƯA KIỂM CHỨNG =====
 * Chỉ có ý nghĩa với nguồn OSM dự phòng: chặn thu nhỏ tới mức nhìn thấy vùng biển có vẽ đường
 * tranh chấp. Ở zoom 10 khung nhìn rộng ~40km, không đủ xa bờ để chạm tới vùng đó.
 *
 * Với nguồn trong nước thì không cần chặn, nhưng vẫn giữ giới hạn theo lãnh thổ Việt Nam vì
 * shop chỉ giao trong nước — cho kéo ra ngoài cũng không để làm gì.
 *
 * Nếu đổi nhà cung cấp tile, PHẢI soi bằng mắt dọc toàn bộ bờ biển ở đúng mức zoom tối thiểu
 * trước khi hạ con số này xuống. */
/* PHẢI bám vào lớp nền THỰC SỰ đang vẽ, không phải vào việc có cấu hình key hay không.
 * Lỗi đã mắc: nới xuống 6 ngay khi có key, nhưng lúc VietMap hỏng và rơi về OSM thì giới hạn
 * vẫn là 6 -> vùng biển tranh chấp hiện lại đầy đủ. Vì vậy MapPicker gọi hàm này SAU khi biết
 * chắc lớp nào được vẽ. */
export const zoomToiThieuCho = (nguon) => (nguon === 'vietmap' ? 6 : 10);

/** Giá trị an toàn dùng lúc khởi tạo, trước khi biết lớp nền nào sẽ vẽ được. */
export const ZOOM_TOI_THIEU = 10;

export const GIOI_HAN_VUNG = [
  [8.0, 102.0],   // tây nam — mũi Cà Mau / biên giới Tây Nam
  [23.5, 110.0],  // đông bắc — Hà Giang / ngoài khơi miền Trung
];
