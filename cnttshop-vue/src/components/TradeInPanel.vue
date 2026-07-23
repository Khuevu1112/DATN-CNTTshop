<script setup>
import { ref, computed, onMounted } from 'vue';
import { fmt } from '../data/products.js';
import { actions, accent } from '../store.js';
import {
  guiYeuCauThuCu, fetchYeuCauThuCu, phanHoiBaoGiaThuCu, fetchTinDungThuCu, resolveImageUrl,
} from '../api.js';

// Thu cũ đổi mới — khối trong trang cá nhân: gửi yêu cầu, theo dõi tiến trình, xem tín dụng.
// Luồng nghiệp vụ: khách khai máy + gửi ảnh -> shop báo giá TẠM TÍNH -> khách đồng ý -> mang máy
// tới -> kỹ thuật kiểm tra và CHỐT giá -> shop cấp tín dụng. Chỉ bước cuối mới ra tiền thật.

const dsYeuCau = ref([]);
const dsTinDung = ref([]);
const loading = ref(true);
const dangGui = ref(false);
const loi = ref('');
const moForm = ref(false);

const LOAI = [
  ['laptop', 'Laptop'],
  ['pc', 'PC / Máy bàn'],
  ['man_hinh', 'Màn hình'],
  ['linh_kien', 'Linh kiện'],
];
const TINH_TRANG = [
  ['moi_90', 'Như mới (trên 90%)'],
  ['tot', 'Còn tốt'],
  ['trung_binh', 'Trung bình, có trầy xước'],
  ['can_sua', 'Cần sửa chữa'],
];

const form = ref({ loaiThietBi: 'laptop', hang: '', model: '', tinhTrangKhai: 'tot', namMua: null, moTa: '', serial: '' });
const anh = ref([]);        // File[]
const anhPreview = ref([]); // dataURL để xem trước

/** Màu theo nhóm trạng thái: đang chờ / đang xử lý / thành công / kết thúc không thành. */
function mauTrangThai(tt) {
  if (tt === 'da_cap_tin_dung') return 'var(--green)';
  if (tt === 'tu_choi_thu' || tt === 'khach_tu_choi' || tt === 'huy_yeu_cau') return 'var(--muted)';
  if (tt === 'da_bao_gia' || tt === 'da_kiem_tra') return '#ffb43b';
  return accent.value;
}

const tongTinDungDungDuoc = computed(() =>
  dsTinDung.value.filter((c) => c.dungDuoc).reduce((s, c) => s + Number(c.soTien || 0), 0),
);

function chonAnh(e) {
  const files = Array.from(e.target.files || []).slice(0, 4);
  anh.value = files;
  anhPreview.value = [];
  files.forEach((f) => {
    const r = new FileReader();
    r.onload = () => anhPreview.value.push(r.result);
    r.readAsDataURL(f);
  });
}

async function tai() {
  loading.value = true;
  try {
    const [yc, tc] = await Promise.all([fetchYeuCauThuCu(), fetchTinDungThuCu()]);
    dsYeuCau.value = yc;
    dsTinDung.value = tc;
  } catch (e) {
    // im lặng — không chặn phần còn lại của trang cá nhân
  } finally {
    loading.value = false;
  }
}

async function guiYeuCau() {
  loi.value = '';
  if (!form.value.model.trim()) { loi.value = 'Vui lòng nhập tên máy / model'; return; }
  if (!anh.value.length) { loi.value = 'Vui lòng gửi ít nhất 1 ảnh hiện trạng máy'; return; }

  dangGui.value = true;
  try {
    await guiYeuCauThuCu(form.value, anh.value);
    actions.showToast('Đã gửi yêu cầu — shop sẽ báo giá tạm tính sớm');
    moForm.value = false;
    form.value = { loaiThietBi: 'laptop', hang: '', model: '', tinhTrangKhai: 'tot', namMua: null, moTa: '', serial: '' };
    anh.value = [];
    anhPreview.value = [];
    await tai();
  } catch (e) {
    loi.value = e?.message || 'Gửi yêu cầu thất bại';
  } finally {
    dangGui.value = false;
  }
}

async function phanHoi(yc, dongY) {
  try {
    await phanHoiBaoGiaThuCu(yc.id, dongY);
    actions.showToast(dongY ? 'Đã xác nhận — mang máy tới showroom để kiểm tra' : 'Đã từ chối mức giá này');
    await tai();
  } catch (e) {
    actions.showToast(e?.message || 'Có lỗi xảy ra');
  }
}

onMounted(tai);
</script>

<template>
  <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 22px">
    <div style="display: flex; align-items: center; justify-content: space-between; gap: 10px; margin-bottom: 6px">
      <div style="font-size: 14px; font-weight: 700; color: var(--text)">♻️ Thu cũ đổi mới</div>
      <button
        @click="moForm = !moForm"
        :style="{ borderColor: moForm ? accent : 'rgba(var(--line-rgb),0.22)' }"
        style="background: transparent; border: 1px solid; border-radius: 8px; padding: 5px 12px; font-size: 12px; color: var(--muted2); cursor: pointer; font-family: 'Be Vietnam Pro', sans-serif; flex: none"
      >
        {{ moForm ? 'Đóng' : '+ Gửi máy cũ' }}
      </button>
    </div>
    <div style="font-size: 11.5px; color: var(--muted2); line-height: 1.6; margin-bottom: 14px">
      Bán lại máy cũ để lấy tín dụng trừ thẳng vào đơn mới. Giá cuối cùng chốt sau khi kỹ thuật
      kiểm tra máy thật.
    </div>

    <!-- Tín dụng đang có -->
    <div v-if="tongTinDungDungDuoc > 0" style="background: color-mix(in srgb, var(--green) 12%, transparent); border: 1px solid var(--green); border-radius: 10px; padding: 12px 14px; margin-bottom: 14px">
      <div style="font-size: 12px; color: var(--muted2)">Tín dụng khả dụng</div>
      <div style="font-size: 20px; font-weight: 800; color: var(--green); margin-top: 2px">{{ fmt(tongTinDungDungDuoc) }}</div>
      <div style="font-size: 11px; color: var(--muted2); margin-top: 3px">Chọn khi thanh toán để trừ vào đơn hàng.</div>
    </div>

    <!-- Form gửi yêu cầu -->
    <Transition name="dropdown-fade">
    <div v-if="moForm" style="border: 1px dashed rgba(var(--line-rgb),0.3); border-radius: 11px; padding: 14px; margin-bottom: 14px">
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px">
        <label style="font-size: 11.5px; color: var(--muted2)">
          Loại thiết bị
          <select v-model="form.loaiThietBi" class="ti-input">
            <option v-for="l in LOAI" :key="l[0]" :value="l[0]">{{ l[1] }}</option>
          </select>
        </label>
        <label style="font-size: 11.5px; color: var(--muted2)">
          Hãng
          <input v-model="form.hang" placeholder="Dell, Asus..." class="ti-input" />
        </label>
        <label style="grid-column: 1 / -1; font-size: 11.5px; color: var(--muted2)">
          Tên máy / Model *
          <input v-model="form.model" placeholder="VD: Dell XPS 15 9520 i7-12700H" class="ti-input" />
        </label>
        <label style="font-size: 11.5px; color: var(--muted2)">
          Tình trạng
          <select v-model="form.tinhTrangKhai" class="ti-input">
            <option v-for="t in TINH_TRANG" :key="t[0]" :value="t[0]">{{ t[1] }}</option>
          </select>
        </label>
        <label style="font-size: 11.5px; color: var(--muted2)">
          Năm mua
          <input v-model.number="form.namMua" type="number" placeholder="2022" class="ti-input" />
        </label>
        <label style="grid-column: 1 / -1; font-size: 11.5px; color: var(--muted2)">
          Mô tả thêm (lỗi, phụ kiện kèm theo...)
          <textarea v-model="form.moTa" rows="2" class="ti-input" style="height: auto; padding: 9px 12px; resize: vertical"></textarea>
        </label>
      </div>

      <div style="margin-top: 10px">
        <div style="font-size: 11.5px; color: var(--muted2); margin-bottom: 6px">
          Ảnh hiện trạng * (tối đa 4 ảnh — ảnh càng rõ, giá tạm tính càng sát)
        </div>
        <input type="file" accept="image/*" multiple @change="chonAnh" style="font-size: 12px; color: var(--muted2)" />
        <div v-if="anhPreview.length" style="display: flex; gap: 8px; margin-top: 8px; flex-wrap: wrap">
          <img v-for="(a, i) in anhPreview" :key="i" :src="a" style="width: 64px; height: 64px; object-fit: cover; border-radius: 8px; border: 1px solid rgba(var(--line-rgb),0.2)" />
        </div>
      </div>

      <div v-if="loi" style="font-size: 12px; color: var(--sale); margin-top: 10px">{{ loi }}</div>

      <button
        @click="guiYeuCau" :disabled="dangGui"
        :style="{ background: accent, opacity: dangGui ? 0.7 : 1 }"
        style="width: 100%; height: 40px; margin-top: 12px; border: none; border-radius: 9px; color: var(--acc-ink); font-weight: 700; font-size: 13px; cursor: pointer"
      >
        {{ dangGui ? 'Đang gửi...' : 'Gửi yêu cầu định giá' }}
      </button>
    </div>
    </Transition>

    <!-- Danh sách yêu cầu -->
    <div v-if="loading" style="font-size: 12.5px; color: var(--muted); padding: 10px 0">Đang tải...</div>
    <div v-else-if="!dsYeuCau.length" style="font-size: 12.5px; color: var(--muted); padding: 10px 0">
      Bạn chưa gửi máy cũ nào.
    </div>
    <div v-else style="display: flex; flex-direction: column; gap: 10px">
      <div v-for="yc in dsYeuCau" :key="yc.id" style="background: var(--card2); border-radius: 10px; padding: 12px 13px">
        <div style="display: flex; align-items: flex-start; justify-content: space-between; gap: 10px">
          <div style="min-width: 0">
            <div style="font-size: 13px; font-weight: 600; color: var(--text)">{{ yc.model }}</div>
            <div style="font-size: 11px; color: var(--muted); margin-top: 2px">
              {{ yc.hang || '—' }} · Gửi {{ new Date(yc.createdAt).toLocaleDateString('vi-VN') }}
            </div>
          </div>
          <span :style="{ color: mauTrangThai(yc.trangThai) }" style="font-size: 11px; font-weight: 700; flex: none; text-align: right">
            {{ yc.nhanTrangThai }}
          </span>
        </div>

        <div v-if="yc.anh.length" style="display: flex; gap: 6px; margin-top: 8px">
          <img v-for="(a, i) in yc.anh" :key="i" :src="resolveImageUrl(a)" style="width: 46px; height: 46px; object-fit: cover; border-radius: 7px" />
        </div>

        <div v-if="yc.giaTamTinh || yc.giaChot" style="display: flex; gap: 16px; margin-top: 9px; font-size: 12px">
          <div v-if="yc.giaTamTinh">
            <span style="color: var(--muted2)">Tạm tính: </span>
            <b style="color: var(--text)">{{ fmt(yc.giaTamTinh) }}</b>
          </div>
          <div v-if="yc.giaChot">
            <span style="color: var(--muted2)">Chốt: </span>
            <b style="color: var(--green)">{{ fmt(yc.giaChot) }}</b>
          </div>
        </div>

        <div v-if="yc.ghiChuKtv" style="font-size: 11.5px; color: var(--muted2); margin-top: 6px; line-height: 1.5">
          Ghi chú kỹ thuật: {{ yc.ghiChuKtv }}
        </div>

        <!-- Khách phản hồi giá tạm tính -->
        <div v-if="yc.trangThai === 'da_bao_gia'" style="display: flex; gap: 8px; margin-top: 11px">
          <button
            @click="phanHoi(yc, true)"
            :style="{ background: accent }"
            style="flex: 1; height: 34px; border: none; border-radius: 8px; color: var(--acc-ink); font-weight: 700; font-size: 12px; cursor: pointer"
          >
            Đồng ý, mang máy tới
          </button>
          <button
            @click="phanHoi(yc, false)"
            style="height: 34px; padding: 0 14px; border: 1px solid rgba(var(--line-rgb),0.22); background: transparent; border-radius: 8px; color: var(--muted2); font-size: 12px; cursor: pointer"
          >
            Không
          </button>
        </div>

        <div v-if="yc.creditSoTien && yc.creditTrangThai === 'con_hieu_luc'" style="font-size: 11.5px; color: var(--green); margin-top: 8px">
          ✓ Đã nhận {{ fmt(yc.creditSoTien) }} tín dụng — dùng khi thanh toán.
        </div>
        <div v-else-if="yc.creditTrangThai === 'da_dung'" style="font-size: 11.5px; color: var(--muted); margin-top: 8px">
          Tín dụng đã dùng cho đơn hàng.
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.ti-input {
  width: 100%;
  height: 38px;
  margin-top: 4px;
  padding: 0 12px;
  background: var(--card2);
  border: 1px solid rgba(var(--line-rgb), 0.22);
  border-radius: 8px;
  color: var(--text);
  font-size: 12.5px;
  font-family: 'Be Vietnam Pro', sans-serif;
}
</style>
