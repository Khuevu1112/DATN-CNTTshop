<script setup>
import { ref, onMounted, onBeforeUnmount, watch } from 'vue';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { accent } from '../store.js';
import { ZOOM_TOI_THIEU, GIOI_HAN_VUNG } from '../data/mapSource.js';
import { themLopNen } from '../utils/mapBaseLayer.js';

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

/** Lớp nền (raster VietMap -> vector VietMap -> OpenStreetMap) dùng chung với các bản đồ khác
 * trong app — xem utils/mapBaseLayer.js để biết vì sao chuỗi dự phòng này không được nhân bản. */

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

  themLopNen(map, 'MapPicker');

  if (props.modelValue) datGhim(props.modelValue.lat, props.modelValue.lng, false);

  map.on('click', (e) => { xoaVongSaiSo(); datGhim(e.latlng.lat, e.latlng.lng); });

  // Bản đồ nằm trong khối ẩn/hiện (form địa chỉ mở ra bằng v-if) nên lúc khởi tạo container
  // thường chưa có kích thước thật -> Leaflet vẽ tile lệch. Ép đo lại sau khi trình duyệt đã
  // layout xong.
  setTimeout(() => map && map.invalidateSize(), 60);
});

onBeforeUnmount(() => {
  // Không còn phải reset chốt "đã vẽ nền" ở đây: themLopNen() giữ trạng thái đó cục bộ theo
  // từng lần gọi (xem utils/mapBaseLayer.js), nên mở lại form là có nền mới sạch sẽ.
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
