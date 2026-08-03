<script setup>
import { ref, onMounted, onBeforeUnmount, watch, nextTick } from 'vue';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { accent } from '../store.js';
import { ZOOM_TOI_THIEU, GIOI_HAN_VUNG } from '../data/mapSource.js';
import { themLopNen } from '../utils/mapBaseLayer.js';

/* Bản đồ CHỈ ĐỌC hiển thị các trung tâm bảo hành — khác MapPicker ở chỗ không cắm mốc, không
 * sửa gì, chỉ xem và chọn. Dùng chung lớp nền qua utils/mapBaseLayer.js. */
const props = defineProps({
  centers: { type: Array, default: () => [] },
  selectedId: { type: Number, default: null },
  userPosition: { type: Object, default: null },
  height: { type: String, default: '520px' },
});
const emit = defineEmits(['select']);

// Canh về giữa Việt Nam khi chưa biết xem điểm nào — zoom 5 đủ thấy cả ba miền.
const TAM_VIET_NAM = [16.0, 107.5];

const mapEl = ref(null);
let map = null;
let lopGhim = null;
let ghimTheoId = {};
let ghimNguoiDung = null;

function iconTrungTam(chon, uyQuyen) {
  const mau = chon ? accent.value : uyQuyen ? '#8a8f98' : '#2bd47e';
  const to = chon ? 34 : 26;
  return L.divIcon({
    className: '',
    html: `<div style="width:${to}px;height:${to}px;border-radius:50% 50% 50% 0;
           transform:rotate(-45deg);background:${mau};border:2.5px solid #fff;
           box-shadow:0 2px 8px rgba(0,0,0,0.45)"></div>`,
    iconSize: [to, to],
    iconAnchor: [to / 2, to],
  });
}

function iconNguoiDung() {
  return L.divIcon({
    className: '',
    html: `<div style="width:16px;height:16px;border-radius:50%;background:#3b82f6;
           border:3px solid #fff;box-shadow:0 0 0 6px rgba(59,130,246,0.25)"></div>`,
    iconSize: [16, 16],
    iconAnchor: [8, 8],
  });
}

/** Vẽ lại toàn bộ ghim. Xoá sạch rồi vẽ lại thay vì cập nhật từng cái: danh sách đổi theo bộ lọc
 * nên phần lớn ghim là mới, so khớp từng cái phức tạp hơn mà không nhanh hơn với vài chục điểm. */
function veGhim() {
  if (!map) return;
  if (lopGhim) map.removeLayer(lopGhim);
  lopGhim = L.layerGroup().addTo(map);
  ghimTheoId = {};

  const coToaDo = props.centers.filter((c) => c.lat != null && c.lng != null);

  coToaDo.forEach((c) => {
    const m = L.marker([Number(c.lat), Number(c.lng)], {
      icon: iconTrungTam(c.id === props.selectedId, c.loai === 'uy_quyen'),
      zIndexOffset: c.id === props.selectedId ? 1000 : 0,
    });
    m.bindPopup(
      `<div style="font-family:'Plus Jakarta Sans',sans-serif;min-width:180px">
         <div style="font-weight:700;font-size:13px;margin-bottom:5px">${thoat(c.ten)}</div>
         <div style="font-size:12px;color:#666;line-height:1.5">${thoat(c.diaChi)}</div>
         ${c.dienThoai ? `<div style="font-size:12px;color:#666;margin-top:4px">📞 ${thoat(c.dienThoai)}</div>` : ''}
         ${c.gioMoCua ? `<div style="font-size:11.5px;color:#888;margin-top:4px">${thoat(c.gioMoCua)}</div>` : ''}
       </div>`,
    );
    m.on('click', () => emit('select', c.id));
    m.addTo(lopGhim);
    ghimTheoId[c.id] = m;
  });

  if (props.userPosition) {
    ghimNguoiDung = L.marker([props.userPosition.lat, props.userPosition.lng], {
      icon: iconNguoiDung(),
      interactive: false,
    }).addTo(lopGhim);
  }

  canKhungNhin(coToaDo);
}

/** Canh khung nhìn ôm trọn các điểm đang hiển thị. Một điểm duy nhất thì fitBounds sẽ phóng tới
 * mức zoom tối đa — quá sát, khách mất ngữ cảnh xung quanh — nên đặt zoom tay cho trường hợp đó. */
function canKhungNhin(coToaDo) {
  const diem = coToaDo.map((c) => [Number(c.lat), Number(c.lng)]);
  if (props.userPosition) diem.push([props.userPosition.lat, props.userPosition.lng]);

  if (!diem.length) {
    map.setView(TAM_VIET_NAM, 5);
    return;
  }
  if (diem.length === 1) {
    map.setView(diem[0], 14);
    return;
  }
  map.fitBounds(L.latLngBounds(diem), { padding: [40, 40], maxZoom: 15 });
}

/** Chuỗi từ CSDL đi thẳng vào innerHTML của popup Leaflet — phải thoát, nếu không tên trung tâm
 * do admin nhập có thể chèn được thẻ script vào trang khách. */
function thoat(s) {
  if (s == null) return '';
  return String(s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

watch(() => props.centers, veGhim, { deep: true });
watch(() => props.userPosition, veGhim);

// Chọn từ danh sách bên trái -> đổi màu ghim, bay tới nơi và bung popup, để hai bên luôn khớp.
watch(
  () => props.selectedId,
  (id) => {
    if (!map) return;
    Object.entries(ghimTheoId).forEach(([key, m]) => {
      const c = props.centers.find((x) => String(x.id) === key);
      m.setIcon(iconTrungTam(Number(key) === id, c?.loai === 'uy_quyen'));
      m.setZIndexOffset(Number(key) === id ? 1000 : 0);
    });
    const chon = ghimTheoId[id];
    if (chon) {
      map.flyTo(chon.getLatLng(), Math.max(map.getZoom(), 14), { duration: 0.6 });
      chon.openPopup();
    }
  },
);

// Nhắc "Giữ Ctrl + lăn chuột" khi khách lăn chuột qua bản đồ mà KHÔNG giữ Ctrl — hiện lên rồi
// tự tắt sau hơn một giây.
const nhacCtrl = ref(false);
let hetNhacTimer = null;

/** Thu phóng bằng Ctrl + lăn chuột khi trỏ đang trên bản đồ.
 *
 * Vì sao không bật scrollWheelZoom mặc định của Leaflet: bản đồ nằm giữa một trang dài, để cuộn
 * chuột phóng to thẳng thì khách cuộn trang qua đây là bị kẹt/zoom ngoài ý muốn. Ràng vào Ctrl
 * là quy ước quen thuộc của bản đồ nhúng — cuộn thường = cuộn trang, Ctrl + cuộn = zoom bản đồ.
 *
 * passive:false là bắt buộc để preventDefault() chặn được zoom-cả-trang mặc định của trình duyệt
 * khi giữ Ctrl. Zoom quanh vị trí con trỏ (setZoomAround) thay vì quanh tâm để cảm giác tự nhiên. */
function onWheel(e) {
  if (!map) return;
  if (e.ctrlKey || e.metaKey) {
    e.preventDefault();
    nhacCtrl.value = false;
    const diem = map.mouseEventToContainerPoint(e);
    const viTri = map.containerPointToLatLng(diem);
    const buoc = e.deltaY < 0 ? 1 : -1;
    const zoomMoi = Math.max(map.getMinZoom(), Math.min(map.getMaxZoom(), map.getZoom() + buoc));
    map.setZoomAround(viTri, zoomMoi);
  } else {
    nhacCtrl.value = true;
    clearTimeout(hetNhacTimer);
    hetNhacTimer = setTimeout(() => (nhacCtrl.value = false), 1400);
  }
}

onMounted(async () => {
  map = L.map(mapEl.value, {
    zoomControl: true,
    minZoom: ZOOM_TOI_THIEU,
    maxBounds: GIOI_HAN_VUNG,
    maxBoundsViscosity: 1.0,
    scrollWheelZoom: false, // tự lo bằng onWheel — chỉ zoom khi giữ Ctrl
  }).setView(TAM_VIET_NAM, 5);

  mapEl.value.addEventListener('wheel', onWheel, { passive: false });

  themLopNen(map, 'ServiceCenterMap');
  await nextTick();
  veGhim();
  setTimeout(() => map && map.invalidateSize(), 60);
});

onBeforeUnmount(() => {
  clearTimeout(hetNhacTimer);
  if (mapEl.value) mapEl.value.removeEventListener('wheel', onWheel);
  if (map) {
    map.remove();
    map = null;
    lopGhim = null;
    ghimTheoId = {};
    ghimNguoiDung = null;
  }
});
</script>

<template>
  <div class="sp-card" style="overflow: hidden">
    <div style="position: relative">
      <div ref="mapEl" :style="{ height, width: '100%' }"></div>
      <!-- Nhắc thao tác zoom, chỉ hiện khi khách lăn chuột mà quên giữ Ctrl -->
      <transition name="scm-fade">
        <div v-if="nhacCtrl" class="scm-hint">
          Giữ <b>Ctrl</b> + lăn chuột để thu phóng bản đồ
        </div>
      </transition>
    </div>
    <div
      style="
        padding: 11px 16px;
        border-top: 1px solid rgba(var(--line-rgb), 0.1);
        display: flex;
        gap: 16px;
        flex-wrap: wrap;
        align-items: center;
      "
    >
      <span style="display: inline-flex; align-items: center; gap: 6px; font-size: 11.5px; color: var(--muted)">
        <i style="width: 9px; height: 9px; border-radius: 50%; background: #2bd47e; display: inline-block"></i>
        Chi nhánh CNTTShop
      </span>
      <span style="display: inline-flex; align-items: center; gap: 6px; font-size: 11.5px; color: var(--muted)">
        <i style="width: 9px; height: 9px; border-radius: 50%; background: #8a8f98; display: inline-block"></i>
        Trung tâm uỷ quyền
      </span>
      <span
        v-if="userPosition"
        style="display: inline-flex; align-items: center; gap: 6px; font-size: 11.5px; color: var(--muted)"
      >
        <i style="width: 9px; height: 9px; border-radius: 50%; background: #3b82f6; display: inline-block"></i>
        Vị trí của bạn
      </span>
      <span style="font-size: 11px; color: var(--muted); margin-left: auto">
        Khoảng cách tính theo đường chim bay · Ctrl + lăn chuột để thu phóng
      </span>
    </div>
  </div>
</template>

<style scoped>
.scm-hint {
  position: absolute;
  inset: 0;
  z-index: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  pointer-events: none;
  font-size: 14px;
  color: #fff;
  background: rgba(0, 0, 0, 0.42);
  backdrop-filter: blur(1px);
}
.scm-hint b {
  margin: 0 4px;
  padding: 2px 8px;
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.22);
}
.scm-fade-enter-active,
.scm-fade-leave-active {
  transition: opacity 0.18s;
}
.scm-fade-enter-from,
.scm-fade-leave-to {
  opacity: 0;
}
</style>
