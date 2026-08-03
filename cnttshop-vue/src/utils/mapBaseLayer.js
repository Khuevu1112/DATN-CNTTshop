/* ===========================================================================
 * LỚP NỀN BẢN ĐỒ — tách khỏi MapPicker.vue để mọi bản đồ trong app dùng chung một đường đi.
 *
 * VÌ SAO PHẢI TÁCH: chuỗi dự phòng ở đây (raster VietMap -> vector VietMap qua MapLibre -> OSM)
 * có nhiều nhánh hỏng ÂM THẦM — key sai, referer bị chặn, style treo không báo lỗi. Nhân bản
 * đoạn này sang bản đồ thứ hai gần như chắc chắn sẽ bỏ sót một nhánh, và triệu chứng là bản đồ
 * trắng mà không có gì trong console. Một nơi duy nhất thì sửa một lần là mọi bản đồ cùng đúng.
 *
 * Lý do dùng nguồn trong nước thay vì OSM thẳng: xem data/mapSource.js.
 * =========================================================================== */

import L from 'leaflet';
import {
  dungNguonTrongNuoc, VIETMAP_STYLE_URL, VIETMAP_RASTER_URL, OSM_TILE_URL, ATTRIBUTION,
  GIOI_HAN_VUNG, ganKeyVaoRequest, zoomToiThieuCho,
} from '../data/mapSource.js';

/**
 * Vẽ lớp nền cho một đối tượng bản đồ Leaflet, tự dự phòng khi nguồn trong nước hỏng.
 *
 * @param {L.Map} map      bản đồ đã khởi tạo
 * @param {string} tenGoi  tên hiển thị trong console.warn, để biết bản đồ nào đang rơi về OSM
 * @returns {Promise<void>} resolve khi đã chọn xong lớp nền (có thể vẫn còn dự phòng chạy nền)
 */
export async function themLopNen(map, tenGoi = 'Map') {
  // Chốt cục bộ theo từng lần gọi: hai bản đồ cùng sống trên một trang không được chia nhau
  // biến trạng thái, nếu không bản đồ thứ hai sẽ tưởng nền đã vẽ rồi và bỏ trống.
  const trangThai = { daVeNen: false };

  /** Lớp nền OpenStreetMap — vừa là nguồn mặc định khi chưa có key, vừa là lưới an toàn khi
   * nguồn trong nước hỏng. Có chốt daVeNen để không vẽ chồng hai lớp lên nhau. */
  function veLopOsm(lyDo) {
    if (trangThai.daVeNen || !map) return;
    trangThai.daVeNen = true;
    if (lyDo) console.warn(`[${tenGoi}] Dùng OpenStreetMap thay thế —`, lyDo);

    L.tileLayer(OSM_TILE_URL, {
      maxZoom: 19,
      minZoom: zoomToiThieuCho('osm'),
      bounds: GIOI_HAN_VUNG,
      attribution: ATTRIBUTION,
    }).addTo(map);
  }

  /** Chốt lại mức zoom tối thiểu theo lớp nền THỰC SỰ vẽ được. Rơi về OSM thì phải siết lại để
   * vùng biển tranh chấp không lọt vào khung nhìn — xem mapSource.js. */
  function chotZoomToiThieu(nguon) {
    const z = zoomToiThieuCho(nguon);
    map.setMinZoom(z);
    if (map.getZoom() < z) map.setZoom(z);
  }

  /** Thử raster VietMap trước: Leaflet đọc thẳng, không cần MapLibre. Dò bằng cách nghe
   * 'tileload'/'tileerror' của chính lớp vừa thêm — endpoint sai thì mọi tile đều lỗi và ta biết
   * ngay, thay vì để bản đồ trống mà không ai báo. */
  function thuRasterVietMap() {
    return new Promise((resolve) => {
      const layer = L.tileLayer(VIETMAP_RASTER_URL, {
        maxZoom: 19,
        minZoom: zoomToiThieuCho('vietmap'),
        bounds: GIOI_HAN_VUNG,
        attribution: ATTRIBUTION,
      });

      let xong = false;
      const ketThuc = (ok, lyDo) => {
        if (xong) return;
        xong = true;
        if (!ok) {
          map.removeLayer(layer);
          console.warn(`[${tenGoi}] Raster VietMap không dùng được —`, lyDo);
        }
        resolve(ok);
      };

      layer.on('tileload', () => ketThuc(true));
      layer.on('tileerror', () => ketThuc(false, 'tile trả về lỗi (endpoint hoặc quyền Tile)'));
      layer.addTo(map);
      setTimeout(() => ketThuc(false, 'quá 6 giây không có tile nào về'), 6000);
    });
  }

  if (!dungNguonTrongNuoc) {
    veLopOsm();
    chotZoomToiThieu('osm');
    return;
  }

  if (await thuRasterVietMap()) {
    trangThai.daVeNen = true;
    chotZoomToiThieu('vietmap');
    return;
  }

  let glLayer;
  try {
    // THỨ TỰ QUAN TRỌNG, không gộp vào Promise.all được: plugin cầu nối đọc biến toàn cục
    // `maplibregl` ngay lúc nó được nạp, nên phải có maplibre-gl và gán window trước đã.
    const { default: maplibregl } = await import('maplibre-gl');
    await import('maplibre-gl/dist/maplibre-gl.css');
    window.maplibregl = maplibregl;
    await import('@maplibre/maplibre-gl-leaflet');

    glLayer = L.maplibreGL({
      style: VIETMAP_STYLE_URL,
      attribution: ATTRIBUTION,
      // Gắn apikey vào cả vector tiles / glyphs / sprite mà style.json trỏ tới — xem mapSource.js.
      transformRequest: ganKeyVaoRequest,
    });
    glLayer.addTo(map);
  } catch (e) {
    veLopOsm('không nạp được thư viện MapLibre: ' + e.message);
    chotZoomToiThieu('osm');
    return;
  }

  /* Tới đây thư viện đã nạp xong nhưng BẢN ĐỒ CHƯA CHẮC HIỆN. MapLibre mới bắt đầu đi tải
   * style.json, và nếu key sai / chưa bật quyền cho style này / referer bị chặn thì nó thất bại
   * ÂM THẦM sau đó — try/catch ở trên không với tới được, kết quả là bản đồ trắng.
   *
   * Nên phải bắt sự kiện 'error' của chính maplibre, kèm một mốc thời gian dự phòng cho trường
   * hợp request treo mà không bao giờ báo lỗi. */
  const mlMap = glLayer.getMaplibreMap?.();
  if (!mlMap) {
    veLopOsm('không lấy được đối tượng bản đồ MapLibre');
    chotZoomToiThieu('osm');
    return;
  }

  let daTaiXong = false;
  mlMap.on('load', () => {
    daTaiXong = true;
    chotZoomToiThieu('vietmap');
  });

  mlMap.on('error', (e) => {
    if (daTaiXong) return; // lỗi lẻ tẻ sau khi bản đồ đã chạy thì bỏ qua, đừng đập lớp nền đi
    const chiTiet = e?.error?.status
      ? 'VietMap trả về HTTP ' + e.error.status + ' (kiểm tra API key, quyền style, và referer cho localhost)'
      : 'VietMap báo lỗi: ' + (e?.error?.message || 'không rõ');
    map.removeLayer(glLayer);
    veLopOsm(chiTiet);
    chotZoomToiThieu('osm');
  });

  setTimeout(() => {
    if (daTaiXong || trangThai.daVeNen) return;
    map.removeLayer(glLayer);
    veLopOsm('quá 8 giây chưa tải xong style VietMap');
    chotZoomToiThieu('osm');
  }, 8000);
}
