<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { actions, accent } from '../store.js';
import { fetchServiceCenters, fetchProvinces } from '../api.js';
import { LOAI_THIET_BI, BAN_KINH, tenLoaiThietBi } from '../data/supportMeta.js';
import ServiceCenterMap from '../components/ServiceCenterMap.vue';
import AppointmentModal from '../components/AppointmentModal.vue';

const danhSach = ref([]);
const tinhThanh = ref([]);
const dangTai = ref(true);
const loi = ref('');

const filter = ref({ provinceId: '', dichVu: '', q: '' });
const banKinhKm = ref(null);
const viTri = ref(null); // { lat, lng } — chỉ có khi khách bấm "Gần tôi nhất"
const dangDinhVi = ref(false);
const chonId = ref(null);
const centerDatLich = ref(null);

async function taiDanhSach() {
  dangTai.value = true;
  loi.value = '';
  try {
    danhSach.value = await fetchServiceCenters({
      provinceId: filter.value.provinceId || undefined,
      dichVu: filter.value.dichVu || undefined,
      q: filter.value.q || undefined,
      lat: viTri.value?.lat,
      lng: viTri.value?.lng,
      banKinhKm: banKinhKm.value || undefined,
    });
    // Bán kính lọc hết kết quả là trạng thái hợp lệ nhưng dễ bị hiểu là lỗi mạng — nói rõ ra.
    if (!danhSach.value.length && viTri.value && banKinhKm.value) {
      loi.value = `Không có trung tâm nào trong bán kính ${banKinhKm.value} km quanh bạn. Thử nới rộng bán kính.`;
    }
  } catch (e) {
    loi.value = 'Không tải được danh sách trung tâm bảo hành. Vui lòng thử lại.';
    danhSach.value = [];
  } finally {
    dangTai.value = false;
  }
}

/** Định vị trình duyệt. Bị từ chối / hết giờ là chuyện thường (khách chặn quyền, máy bàn không
 * có GPS) nên phải nói rõ và để họ tiếp tục lọc theo tỉnh, không được để trang chết đứng. */
function dinhVi() {
  if (!navigator.geolocation) {
    loi.value = 'Trình duyệt của bạn không hỗ trợ định vị. Bạn có thể chọn tỉnh/thành ở trên.';
    return;
  }
  dangDinhVi.value = true;
  loi.value = '';
  navigator.geolocation.getCurrentPosition(
    (pos) => {
      viTri.value = { lat: pos.coords.latitude, lng: pos.coords.longitude };
      if (!banKinhKm.value) banKinhKm.value = 50;
      dangDinhVi.value = false;
      taiDanhSach();
    },
    () => {
      dangDinhVi.value = false;
      loi.value =
        'Không lấy được vị trí của bạn. Kiểm tra quyền truy cập vị trí của trình duyệt, hoặc chọn tỉnh/thành ở trên.';
    },
    { timeout: 10000 },
  );
}

function boDinhVi() {
  viTri.value = null;
  banKinhKm.value = null;
  taiDanhSach();
}

function datBanKinh(km) {
  banKinhKm.value = banKinhKm.value === km ? null : km;
  taiDanhSach();
}

let timer = null;
watch(
  () => filter.value.q,
  () => {
    clearTimeout(timer);
    timer = setTimeout(taiDanhSach, 350);
  },
);

const soKetQua = computed(() => danhSach.value.length);

function chiDuong(t) {
  // Mở Google Maps ở tab mới thay vì nhúng: dẫn đường cần app bản đồ thật (giao thông, giọng
  // nói), nhúng iframe chỉ hiển thị được tuyến tĩnh.
  const dich = t.lat && t.lng ? `${t.lat},${t.lng}` : encodeURIComponent(t.diaChi);
  window.open(`https://www.google.com/maps/dir/?api=1&destination=${dich}`, '_blank', 'noopener');
}

onMounted(async () => {
  try {
    tinhThanh.value = await fetchProvinces();
  } catch (e) {
    tinhThanh.value = [];
  }
  taiDanhSach();
});
</script>

<template>
  <main style="max-width: 1240px; margin: 0 auto; padding: 24px 24px 72px">
    <button class="sp-back" @click="actions.goSupport()">← Trung tâm hỗ trợ</button>

    <div style="margin-bottom: 26px">
      <div class="sp-eyebrow">TRUNG TÂM BẢO HÀNH</div>
      <h1 class="sp-h1">
        Tìm điểm dịch vụ<br /><span :style="{ color: accent }">gần bạn nhất</span>
      </h1>
      <p style="font-size: 14.5px; color: var(--muted2); max-width: 620px; line-height: 1.65; margin: 0">
        Tất cả trung tâm đều dùng linh kiện chính hãng và kỹ thuật viên được đào tạo. Đặt lịch
        trước để không phải chờ khi tới nơi.
      </p>
    </div>

    <!-- Bộ lọc -->
    <div class="sp-card" style="padding: 20px 22px; margin-bottom: 20px">
      <div
        style="
          display: grid;
          grid-template-columns: 1.4fr 1fr 1fr auto;
          gap: 12px;
          align-items: end;
        "
        class="sc-filters"
      >
        <div>
          <label class="sc-label">Tìm theo tên hoặc địa chỉ</label>
          <input v-model="filter.q" class="sp-input" placeholder="vd: Hải Phòng, Cầu Giấy…" />
        </div>
        <div>
          <label class="sc-label">Tỉnh / Thành phố</label>
          <select v-model="filter.provinceId" @change="taiDanhSach" class="sp-select">
            <option value="">Tất cả tỉnh/thành</option>
            <option v-for="p in tinhThanh" :key="p.id" :value="p.id">{{ p.name }}</option>
          </select>
        </div>
        <div>
          <label class="sc-label">Loại thiết bị</label>
          <select v-model="filter.dichVu" @change="taiDanhSach" class="sp-select">
            <option value="">Tất cả loại</option>
            <option v-for="l in LOAI_THIET_BI" :key="l.ma" :value="l.ma">{{ l.ten }}</option>
          </select>
        </div>
        <button
          class="sp-btn-ghost"
          style="height: 42px"
          :disabled="dangDinhVi"
          @click="viTri ? boDinhVi() : dinhVi()"
        >
          {{ dangDinhVi ? 'Đang định vị…' : viTri ? '✕ Bỏ vị trí' : '📍 Gần tôi nhất' }}
        </button>
      </div>

      <!-- Bán kính: chỉ có nghĩa khi đã biết vị trí khách -->
      <div
        v-if="viTri"
        style="
          display: flex;
          align-items: center;
          gap: 10px;
          flex-wrap: wrap;
          margin-top: 16px;
          padding-top: 16px;
          border-top: 1px solid rgba(var(--line-rgb), 0.1);
        "
      >
        <span style="font-size: 12.5px; color: var(--muted)">Bán kính tìm kiếm:</span>
        <button
          v-for="b in BAN_KINH"
          :key="b.km"
          class="sp-chip"
          :class="{ active: banKinhKm === b.km }"
          @click="datBanKinh(b.km)"
        >
          {{ b.nhan }}
        </button>
      </div>
    </div>

    <div v-if="loi" class="sp-alert err">{{ loi }}</div>

    <!-- Bản đồ + danh sách -->
    <div style="display: grid; grid-template-columns: 1fr 1.15fr; gap: 20px; align-items: start" class="sc-body">
      <!-- Danh sách -->
      <div>
        <div
          style="
            display: flex;
            align-items: baseline;
            justify-content: space-between;
            margin-bottom: 12px;
          "
        >
          <h2 class="sp-h2" style="margin: 0">
            {{ dangTai ? 'Đang tải…' : soKetQua + ' trung tâm' }}
          </h2>
          <span v-if="viTri" style="font-size: 11.5px; color: var(--muted)">
            Sắp xếp theo khoảng cách
          </span>
        </div>

        <div v-if="!dangTai && !soKetQua" class="sp-card sp-empty">
          Không tìm thấy trung tâm nào khớp bộ lọc.<br />
          Thử bỏ bớt điều kiện, hoặc gọi hotline 0835 344 974 để được hướng dẫn.
        </div>

        <div style="display: flex; flex-direction: column; gap: 12px">
          <div
            v-for="t in danhSach"
            :key="t.id"
            class="sp-card sc-item"
            :class="{ 'sc-active': chonId === t.id }"
            @click="chonId = t.id"
          >
            <div
              style="
                display: flex;
                align-items: flex-start;
                justify-content: space-between;
                gap: 12px;
              "
            >
              <div style="flex: 1">
                <div
                  style="
                    font-family: 'Chakra Petch', sans-serif;
                    font-weight: 700;
                    font-size: 14.5px;
                    color: var(--text);
                    line-height: 1.4;
                  "
                >
                  {{ t.ten }}
                </div>
                <div style="display: flex; gap: 7px; margin-top: 7px; flex-wrap: wrap">
                  <span
                    class="sp-pill"
                    :style="{ color: t.loai === 'uy_quyen' ? 'var(--muted2)' : 'var(--green)' }"
                  >
                    {{ t.loai === 'uy_quyen' ? 'Uỷ quyền' : 'Chi nhánh CNTTShop' }}
                  </span>
                  <span v-if="t.khoangCachKm != null" class="sp-pill" :style="{ color: accent }">
                    {{ t.khoangCachKm }} km
                  </span>
                </div>
              </div>
            </div>

            <div style="margin-top: 12px; display: flex; flex-direction: column; gap: 7px">
              <div class="sc-line">📍 {{ t.diaChi }}<span v-if="t.tenTinh">, {{ t.tenTinh }}</span></div>
              <div v-if="t.gioMoCua" class="sc-line">🕐 {{ t.gioMoCua }}</div>
              <div v-if="t.dienThoai" class="sc-line">📞 {{ t.dienThoai }}</div>
              <div v-if="t.email" class="sc-line">✉️ {{ t.email }}</div>
            </div>

            <div v-if="t.dichVu?.length" style="margin-top: 12px; display: flex; gap: 6px; flex-wrap: wrap">
              <span
                v-for="d in t.dichVu"
                :key="d"
                style="
                  font-size: 11px;
                  color: var(--muted);
                  background: var(--card2);
                  border-radius: 6px;
                  padding: 4px 9px;
                "
              >
                {{ tenLoaiThietBi(d) }}
              </span>
            </div>

            <div style="display: flex; gap: 9px; margin-top: 15px">
              <button
                v-if="t.nhanDatLich"
                class="sp-btn-acc"
                style="height: 38px; font-size: 13px; flex: 1"
                @click.stop="centerDatLich = t"
              >
                Đặt lịch
              </button>
              <button
                class="sp-btn-ghost"
                style="height: 38px; flex: 1"
                @click.stop="chiDuong(t)"
              >
                Chỉ đường
              </button>
            </div>
            <div
              v-if="!t.nhanDatLich"
              style="font-size: 11.5px; color: var(--muted); margin-top: 8px"
            >
              Trung tâm này hiện không nhận đặt lịch, vui lòng tới trực tiếp trong giờ mở cửa.
            </div>
          </div>
        </div>
      </div>

      <!-- Bản đồ (dính khi cuộn để danh sách dài vẫn luôn thấy được vị trí) -->
      <div style="position: sticky; top: 120px">
        <ServiceCenterMap
          :centers="danhSach"
          :selected-id="chonId"
          :user-position="viTri"
          @select="(id) => (chonId = id)"
        />
      </div>
    </div>

    <AppointmentModal
      v-if="centerDatLich"
      :center="centerDatLich"
      @close="centerDatLich = null"
    />
  </main>
</template>

<style scoped>
.sc-label {
  display: block;
  font-size: 11.5px;
  color: var(--muted);
  margin-bottom: 6px;
  font-weight: 500;
}

.sc-item {
  padding: 18px 20px;
  cursor: pointer;
  transition: border-color 0.16s;
}
.sc-item:hover,
.sc-item.sc-active {
  border-color: var(--acc, #c6ff4a);
}

.sc-line {
  font-size: 12.7px;
  color: var(--muted2);
  line-height: 1.55;
}

@media (max-width: 980px) {
  .sc-body {
    grid-template-columns: 1fr !important;
  }
  .sc-filters {
    grid-template-columns: 1fr 1fr !important;
  }
}
@media (max-width: 620px) {
  .sc-filters {
    grid-template-columns: 1fr !important;
  }
}
</style>
