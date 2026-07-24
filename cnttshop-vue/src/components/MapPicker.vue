<script setup>
import { ref, onMounted, onBeforeUnmount, watch } from 'vue';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { accent } from '../store.js';
import {
  dungNguonTrongNuoc, VIETMAP_STYLE_URL, OSM_TILE_URL, ATTRIBUTION,
  ZOOM_TOI_THIEU, GIOI_HAN_VUNG, ganKeyVaoRequest, zoomToiThieuCho, VIETMAP_RASTER_URL,
} from '../data/mapSource.js';

// modelValue = { lat, lng } | null. Component chỉ lo phần bản đồ; việc BẮT BUỘC phải cắm mốc
// trước khi lưu do form cha kiểm (xem CheckoutView/AccountView), backend kiểm lần nữa
// (AddressService.kiemTraToaDo) vì không được tin dữ liệu từ client.
const props = defineProps({
  modelValue: { type: Object, default: null },
  height: { type: String, default: '280px' },
});
const emit = defineEmits(['update:modelValue', 'reverse']);

// Mặc định canh về kho 118 Cát Bi, Hải An, Hải Phòng — phần lớn khách của shop ở quanh đây nên
// mở bản đồ ra là đã thấy đúng khu vực.
const TAM_MAC_DINH = [20.8248, 106.7169];

// Nguồn bản đồ + mức zoom tối thiểu + giới hạn vùng: xem data/mapSource.js. Ở đó có hướng dẫn
// bật nguồn trong nước và lý do vì sao phải khoá vùng nhìn khi còn chạy bằng OpenStreetMap.

const mapEl = ref(null);
let map = null;
let marker = null;
const dangTraNguoc = ref(false);

/** Ghim tự vẽ bằng divIcon thay vì ảnh mặc định của Leaflet: ảnh mặc định trỏ tới file PNG theo
 * đường dẫn tương đối, khi build bằng Vite sẽ 404 và ghim biến mất. */
function taoIcon() {
  return L.divIcon({
    className: '',
    html: `<div style="width:26px;height:26px;border-radius:50% 50% 50% 0;transform:rotate(-45deg);
           background:${accent};border:2.5px solid #fff;box-shadow:0 2px 6px rgba(0,0,0,0.4)"></div>`,
    iconSize: [26, 26],
    iconAnchor: [13, 26],
  });
}

function datGhim(lat, lng, baoChaTraNguoc = true) {
  const pos = [lat, lng];
  if (marker) {
    marker.setLatLng(pos);
  } else {
    marker = L.marker(pos, { icon: taoIcon(), draggable: true }).addTo(map);
    marker.on('dragend', () => {
      const p = marker.getLatLng();
      xoaVongSaiSo();
      phatToaDo(p.lat, p.lng);
    });
  }
  emit('update:modelValue', { lat: Number(lat.toFixed(7)), lng: Number(lng.toFixed(7)) });
  if (baoChaTraNguoc) emit('reverse', { lat, lng });
}

function phatToaDo(lat, lng) {
  datGhim(lat, lng);
}

/** Vẽ lớp nền bản đồ.
 *
 * Hai đường đi khác hẳn nhau về kỹ thuật:
 *   - VietMap phát hành bản đồ đường phố dưới dạng VECTOR STYLE (style.json), Leaflet không tự
 *     đọc được -> nạp qua cầu nối maplibre-gl-leaflet. Import động để bundle chỉ kéo maplibre
 *     (~800KB) về khi thật sự có key, không bắt mọi khách tải thêm chừng đó dữ liệu vô ích.
 *   - OpenStreetMap là raster {z}/{x}/{y} -> L.tileLayer bình thường.
 *
 * Nạp VietMap hỏng (key sai/hết hạn mức/lỗi mạng) thì rơi về OSM thay vì để bản đồ trắng —
 * khách vẫn phải cắm được mốc mới đặt được hàng. */
let daVeNen = false;

/** Lớp nền OpenStreetMap — vừa là nguồn mặc định khi chưa có key, vừa là lưới an toàn khi
 * nguồn trong nước hỏng. Có chốt daVeNen để không vẽ chồng hai lớp lên nhau. */
function veLopOsm(lyDo) {
  if (daVeNen || !map) return;
  daVeNen = true;
  if (lyDo) console.warn('[MapPicker] Dùng OpenStreetMap thay thế —', lyDo);

  L.tileLayer(OSM_TILE_URL, {
    maxZoom: 19,
    minZoom: ZOOM_TOI_THIEU,
    bounds: GIOI_HAN_VUNG,
    attribution: ATTRIBUTION,
  }).addTo(map);
}

/** Chốt lại mức zoom tối thiểu theo lớp nền THỰC SỰ vẽ được. Rơi về OSM thì phải siết lại 10 để
 * vùng biển tranh chấp không lọt vào khung nhìn — xem mapSource.js. */
function chotZoomToiThieu(nguon) {
  const z = zoomToiThieuCho(nguon);
  map.setMinZoom(z);
  if (map.getZoom() < z) map.setZoom(z);
}

/** Thử raster VietMap trước: Leaflet đọc thẳng, không cần MapLibre. Trả về true nếu tile về được.
 * Dò bằng cách nghe 'tileload'/'tileerror' của chính lớp vừa thêm — endpoint sai thì mọi tile
 * đều lỗi và ta biết ngay, thay vì để bản đồ trống mà không ai báo. */
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
        console.warn('[MapPicker] Raster VietMap không dùng được —', lyDo);
      }
      resolve(ok);
    };

    layer.on('tileload', () => ketThuc(true));
    layer.on('tileerror', () => ketThuc(false, 'tile trả về lỗi (endpoint hoặc quyền Tile)'));
    layer.addTo(map);
    setTimeout(() => ketThuc(false, 'quá 6 giây không có tile nào về'), 6000);
  });
}

async function themLopNen() {
  if (!dungNguonTrongNuoc) {
    veLopOsm();
    chotZoomToiThieu('osm');
    return;
  }

  if (await thuRasterVietMap()) {
    daVeNen = true;
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
  mlMap.on('load', () => { daTaiXong = true; chotZoomToiThieu('vietmap'); });

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
    if (daTaiXong || daVeNen) return;
    map.removeLayer(glLayer);
    veLopOsm('quá 8 giây chưa tải xong style VietMap');
    chotZoomToiThieu('osm');
  }, 8000);
}

/** Nút "Vị trí của tôi".
 *
 * Trình duyệt LUÔN trả kèm pos.coords.accuracy — bán kính sai số tính bằng mét. Trước đây ta bỏ
 * qua con số này và cứ cắm ghim như thể nó chính xác tuyệt đối, nên khách không có cách nào biết
 * ghim lệch là do máy định vị kém hay do bản đồ sai. Giờ vẽ hẳn vòng tròn sai số và hiện số mét.
 *
 * Máy bàn / laptop không có GPS thì trình duyệt định vị bằng WiFi hoặc địa chỉ IP, sai số thường
 * vài trăm mét tới vài km — không có cách nào cải thiện từ phía web. Điện thoại bật GPS thường
 * xuống dưới 20m. Vì vậy ghim luôn kéo được, và ta nhắc khách kéo lại khi sai số lớn. */
const doChinhXacM = ref(null);
let vongSaiSo = null;

const NGUONG_CANH_BAO_M = 100;

function dungViTriHienTai() {
  if (!navigator.geolocation) return;
  dangTraNguoc.value = true;
  navigator.geolocation.getCurrentPosition(
    (pos) => {
      const { latitude, longitude, accuracy } = pos.coords;
      doChinhXacM.value = Math.round(accuracy);

      // Zoom theo sai số: định vị lệch 2km mà phóng tới zoom 17 chỉ tạo cảm giác chính xác giả.
      const zoom = accuracy > 1000 ? 13 : accuracy > 200 ? 15 : 17;
      map.setView([latitude, longitude], zoom);
      datGhim(latitude, longitude);

      if (vongSaiSo) map.removeLayer(vongSaiSo);
      vongSaiSo = L.circle([latitude, longitude], {
        radius: accuracy,
        color: accent,
        weight: 1,
        fillOpacity: 0.08,
        interactive: false, // không chặn cú bấm chọn lại vị trí trên bản đồ
      }).addTo(map);

      dangTraNguoc.value = false;
    },
    () => { dangTraNguoc.value = false; },
    // maximumAge: 0 buộc lấy vị trí mới, không dùng lại kết quả cũ đã cache trong trình duyệt.
    { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 },
  );
}

/** Khách tự bấm/kéo ghim = đã tự chỉnh tay -> vòng sai số của máy không còn ý nghĩa, xoá đi. */
function xoaVongSaiSo() {
  if (vongSaiSo) {
    map.removeLayer(vongSaiSo);
    vongSaiSo = null;
  }
  doChinhXacM.value = null;
}

onMounted(() => {
  const batDau = props.modelValue
    ? [props.modelValue.lat, props.modelValue.lng]
    : TAM_MAC_DINH;

  map = L.map(mapEl.value, {
    zoomControl: true,
    minZoom: ZOOM_TOI_THIEU,
    maxBounds: GIOI_HAN_VUNG,
    // 1.0 = chặn cứng, kéo ra ngoài vùng là bật lại ngay chứ không cho trôi tự do.
    maxBoundsViscosity: 1.0,
  }).setView(batDau, props.modelValue ? 17 : 13);

  themLopNen();

  if (props.modelValue) datGhim(props.modelValue.lat, props.modelValue.lng, false);

  map.on('click', (e) => { xoaVongSaiSo(); datGhim(e.latlng.lat, e.latlng.lng); });

  // Bản đồ nằm trong khối ẩn/hiện (form địa chỉ mở ra bằng v-if) nên lúc khởi tạo container
  // thường chưa có kích thước thật -> Leaflet vẽ tile lệch. Ép đo lại sau khi trình duyệt đã
  // layout xong.
  setTimeout(() => map && map.invalidateSize(), 60);
});

onBeforeUnmount(() => {
  // Đóng form địa chỉ rồi mở lại là component dựng mới — quên reset chốt này thì lần sau
  // veLopOsm() tưởng đã vẽ rồi và bỏ qua, ra bản đồ trắng.
  daVeNen = false;
  if (map) {
    map.remove();
    map = null;
    marker = null;
  }
});

// Cha đổi toạ độ từ bên ngoài (VD bấm "Sửa" 1 địa chỉ đã có mốc) -> di chuyển ghim theo.
watch(() => props.modelValue, (v) => {
  if (!map || !v) return;
  const cur = marker && marker.getLatLng();
  if (cur && Math.abs(cur.lat - v.lat) < 1e-7 && Math.abs(cur.lng - v.lng) < 1e-7) return;
  map.setView([v.lat, v.lng], 17);
  datGhim(v.lat, v.lng, false);
});
</script>

<template>
  <div>
    <div style="display: flex; align-items: center; justify-content: space-between; gap: 10px; margin-bottom: 8px">
      <div style="font-size: 12px; color: var(--muted2)">
        Bấm lên bản đồ hoặc kéo ghim để chọn đúng vị trí giao hàng
      </div>
      <button
        type="button" @click="dungViTriHienTai" :disabled="dangTraNguoc"
        style="background: transparent; border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 8px; padding: 5px 11px; font-size: 11.5px; color: var(--muted2); cursor: pointer; flex: none; font-family: 'Plus Jakarta Sans', sans-serif"
      >
        📍 Vị trí của tôi
      </button>
    </div>

    <div
      ref="mapEl"
      :style="{ height }"
      style="width: 100%; border-radius: 10px; overflow: hidden; border: 1px solid rgba(var(--line-rgb),0.18); z-index: 0"
    ></div>

    <div v-if="modelValue" style="font-size: 11.5px; color: var(--green); margin-top: 7px">
      ✓ Đã cắm mốc: {{ modelValue.lat.toFixed(6) }}, {{ modelValue.lng.toFixed(6) }}
    </div>
    <div
      v-if="doChinhXacM != null"
      :style="{ color: doChinhXacM > 100 ? 'var(--sale,#ff5b5b)' : 'var(--muted2)' }"
      style="font-size: 11.5px; margin-top: 4px; line-height: 1.5"
    >
      <template v-if="doChinhXacM > 100">
        ⚠ Máy của bạn chỉ định vị được trong bán kính ~{{ doChinhXacM }}m (vòng tròn trên bản đồ).
        Hãy kéo ghim về đúng nhà — sai số này ảnh hưởng trực tiếp tới phí giao hàng.
      </template>
      <template v-else>
        Độ chính xác định vị ~{{ doChinhXacM }}m. Kéo ghim nếu cần chỉnh lại.
      </template>
    </div>
    <div v-else style="font-size: 11.5px; color: var(--sale); margin-top: 7px">
      Chưa cắm mốc — bắt buộc chọn vị trí trên bản đồ trước khi lưu địa chỉ
    </div>
  </div>
</template>
