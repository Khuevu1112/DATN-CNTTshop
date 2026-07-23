<script setup>
import { ref, computed, onMounted } from 'vue';
import { fmt } from '../data/products.js';
import { actions, accent } from '../store.js';
import { resolveImageUrl } from '../api.js';
import {
  fetchFlashSaleAdmin, createFlashSale, updateFlashSale, publishFlashSale, unpublishFlashSale,
  searchProductsForSale,
} from '../api.js';
import FlashSaleBanner from './FlashSaleBanner.vue';

// Trình soạn flash sale, hiển thị ngay trong tab Flash Sale của trang khuyến mãi (chỉ admin).
// Mọi thao tác lưu ở đây chỉ ghi BẢN NHÁP — khách vẫn thấy bản cũ cho tới khi bấm "Đăng".

const dang = ref(null);          // FlashSaleAdminDto đang sửa
const dangCoDotConHieuLuc = ref(false);
const loading = ref(true);
const saving = ref(false);
const err = ref('');

// Popup xác nhận trước khi đẩy ra cho khách
const confirmPublish = ref(false);

// Bảng màu dựng sẵn — admin đổi màu banner mà không cần biết mã hex.
const BANG_MAU = [
  { ten: 'Đỏ cam', from: '#ff3d24', to: '#ff9500' },
  { ten: 'Tím hồng', from: '#7028e4', to: '#e5b2ca' },
  { ten: 'Xanh dương', from: '#2193b0', to: '#6dd5ed' },
  { ten: 'Xanh lá', from: '#11998e', to: '#38ef7d' },
  { ten: 'Hoàng hôn', from: '#f7971e', to: '#ffd200' },
  { ten: 'Đêm', from: '#232526', to: '#414345' },
];

const form = ref({
  tieuDe: '', moTa: '', mauBatDau: '#ff3d24', mauKetThuc: '#ff9500',
  batDauLuc: '', ketThucLuc: '', isActive: true,
});
const items = ref([]); // [{ variantId, productName, imageUrl, giaGoc, giaSale, phanTramGiam, stock, productSlug }]

// Tìm sản phẩm để thêm vào đợt
const timKiem = ref('');
const ketQua = ref([]);
const dangTim = ref(false);

/** Bản xem trước dựng từ form + items, đúng cấu trúc FlashSaleCongKhaiDto để tái dùng
 * FlashSaleBanner — admin thấy chính xác thứ khách sẽ thấy, không phải đoán. */
const xemTruoc = computed(() => ({
  tieuDe: form.value.tieuDe || 'FLASH SALE',
  moTa: form.value.moTa,
  mauBatDau: form.value.mauBatDau,
  mauKetThuc: form.value.mauKetThuc,
  ketThucLuc: form.value.ketThucLuc || null,
  sanPham: items.value.map((i) => ({
    variantId: i.variantId, productId: i.productId, productSlug: i.productSlug,
    productName: i.productName, imageUrl: i.imageUrl,
    giaGoc: i.giaGoc, giaSale: Number(i.giaSale) || 0,
    phanTramGiam: i.giaGoc > 0 ? Math.round((1 - (Number(i.giaSale) || 0) / i.giaGoc) * 100) : 0,
    stock: i.stock,
  })),
}));

/** datetime-local cần "YYYY-MM-DDTHH:mm" — cắt giây/millisecond và phần offset khỏi ISO string. */
function toLocalInput(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  const p = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}T${p(d.getHours())}:${p(d.getMinutes())}`;
}

function napTuDto(dto) {
  dang.value = dto;
  if (!dto) return;
  form.value = {
    tieuDe: dto.tieuDe || '', moTa: dto.moTa || '',
    mauBatDau: dto.mauBatDau, mauKetThuc: dto.mauKetThuc,
    batDauLuc: toLocalInput(dto.batDauLuc), ketThucLuc: toLocalInput(dto.ketThucLuc),
    isActive: dto.isActive !== false,
  };
  items.value = (dto.sanPham || []).map((s) => ({ ...s }));
}

async function load() {
  loading.value = true;
  try {
    const st = await fetchFlashSaleAdmin();
    dangCoDotConHieuLuc.value = st.dangCoDotConHieuLuc;
    napTuDto(st.dot);
  } catch (e) {
    err.value = e?.message || 'Không tải được flash sale';
  } finally {
    loading.value = false;
  }
}

function payload() {
  return {
    ...form.value,
    // datetime-local trả chuỗi không có timezone; backend nhận LocalDateTime nên gửi nguyên.
    batDauLuc: form.value.batDauLuc || null,
    ketThucLuc: form.value.ketThucLuc || null,
    sanPham: items.value.map((i) => ({ variantId: i.variantId, giaSale: Number(i.giaSale) || 0 })),
  };
}

async function luuNhap() {
  err.value = '';
  saving.value = true;
  try {
    const dto = dang.value
      ? await updateFlashSale(dang.value.id, payload())
      : await createFlashSale(payload());
    napTuDto(dto);
    dangCoDotConHieuLuc.value = true;
    actions.showToast('Đã lưu bản nháp — khách chưa nhìn thấy thay đổi này');
  } catch (e) {
    err.value = e?.message || 'Lưu thất bại';
  } finally {
    saving.value = false;
  }
}

/** Bấm "Đăng" -> lưu nháp trước rồi mới mở popup xác nhận, để nội dung đem đăng luôn là thứ
 * admin đang nhìn thấy trên màn hình (tránh đăng nhầm bản cũ nếu quên bấm Lưu). */
async function moXacNhanDang() {
  err.value = '';
  await luuNhap();
  if (!err.value) confirmPublish.value = true;
}

async function xacNhanDang() {
  saving.value = true;
  try {
    napTuDto(await publishFlashSale(dang.value.id));
    confirmPublish.value = false;
    actions.showToast('Đã đăng — khách hàng bắt đầu nhìn thấy Flash Sale này');
  } catch (e) {
    err.value = e?.message || 'Đăng thất bại';
    confirmPublish.value = false;
  } finally {
    saving.value = false;
  }
}

async function goXuong() {
  if (!window.confirm('Gỡ Flash Sale khỏi trang khách? Nội dung vẫn được giữ để bật lại sau.')) return;
  saving.value = true;
  try {
    napTuDto(await unpublishFlashSale(dang.value.id));
    actions.showToast('Đã gỡ Flash Sale khỏi trang khách');
  } catch (e) {
    err.value = e?.message || 'Gỡ thất bại';
  } finally {
    saving.value = false;
  }
}

async function timSanPham() {
  if (!timKiem.value.trim()) { ketQua.value = []; return; }
  dangTim.value = true;
  try {
    ketQua.value = await searchProductsForSale(timKiem.value.trim());
  } catch (e) {
    ketQua.value = [];
  } finally {
    dangTim.value = false;
  }
}

function themSanPham(sp) {
  if (items.value.some((i) => i.variantId === sp.variantId)) {
    actions.showToast('Sản phẩm này đã có trong đợt sale');
    return;
  }
  items.value.push({
    ...sp,
    // Mặc định giảm 20% cho nhanh, admin sửa lại được ngay ở ô giá.
    giaSale: Math.round((sp.giaGoc * 0.8) / 1000) * 1000,
  });
  timKiem.value = '';
  ketQua.value = [];
}

function xoaSanPham(variantId) {
  items.value = items.value.filter((i) => i.variantId !== variantId);
}

onMounted(load);
</script>

<template>
  <div v-if="loading" style="padding: 40px; text-align: center; color: var(--muted)">Đang tải...</div>

  <div v-else>
    <!-- Chưa có đợt nào -> cho tạo. Đang có đợt còn hiệu lực -> chỉ sửa, không tạo thêm. -->
    <div v-if="!dang" class="fse-hint">
      <div style="font-size: 30px; margin-bottom: 8px">⚡</div>
      <div style="font-size: 14.5px; font-weight: 700; color: var(--text); margin-bottom: 4px">Chưa có đợt Flash Sale nào</div>
      <div style="font-size: 12.5px; color: var(--muted2)">Điền nội dung bên dưới rồi bấm Lưu để tạo đợt đầu tiên.</div>
    </div>

    <div v-else-if="dangCoDotConHieuLuc" class="fse-hint fse-hint-lock">
      🔒 Đang có một Flash Sale còn hiệu lực — chỉ sửa được đợt này, không tạo thêm đợt mới.
      Muốn mở đợt khác thì gỡ hoặc để đợt hiện tại kết thúc trước.
    </div>

    <!-- Xem trước: đúng thứ khách sẽ thấy -->
    <div class="fse-section-label">Xem trước</div>
    <FlashSaleBanner v-if="items.length" :sale="xemTruoc" preview />
    <div v-else class="fse-empty-preview">Chưa có sản phẩm nào — thêm ít nhất 1 sản phẩm để xem trước.</div>

    <!-- Nội dung -->
    <div class="fse-section-label">Nội dung</div>
    <div class="fse-grid">
      <label class="fse-field">
        <span>Tiêu đề</span>
        <input v-model="form.tieuDe" placeholder="FLASH SALE" class="fse-input" />
      </label>
      <label class="fse-field">
        <span>Mô tả ngắn (để trống nếu không cần)</span>
        <input v-model="form.moTa" placeholder="Giảm sốc cuối tuần" class="fse-input" />
      </label>
      <label class="fse-field">
        <span>Bắt đầu</span>
        <input v-model="form.batDauLuc" type="datetime-local" class="fse-input" />
      </label>
      <label class="fse-field">
        <span>Kết thúc</span>
        <input v-model="form.ketThucLuc" type="datetime-local" class="fse-input" />
      </label>
    </div>

    <!-- Màu -->
    <div class="fse-section-label">Màu banner</div>
    <div class="fse-colors">
      <button
        v-for="m in BANG_MAU" :key="m.ten" class="fse-color no-auto-hover"
        :class="{ 'is-active': form.mauBatDau === m.from && form.mauKetThuc === m.to }"
        :style="{ background: 'linear-gradient(115deg, ' + m.from + ', ' + m.to + ')' }"
        :title="m.ten"
        @click="form.mauBatDau = m.from; form.mauKetThuc = m.to"
      ></button>
      <label class="fse-color-custom">
        <input type="color" v-model="form.mauBatDau" />
        <input type="color" v-model="form.mauKetThuc" />
        <span>Tự chọn</span>
      </label>
    </div>

    <!-- Sản phẩm -->
    <div class="fse-section-label">Sản phẩm trong đợt ({{ items.length }})</div>
    <div class="fse-search">
      <input
        v-model="timKiem" @keyup.enter="timSanPham"
        placeholder="Tìm sản phẩm theo tên rồi Enter..." class="fse-input" style="flex: 1"
      />
      <button class="fse-btn-ghost" @click="timSanPham" :disabled="dangTim">
        {{ dangTim ? '...' : 'Tìm' }}
      </button>
    </div>
    <div v-if="ketQua.length" class="fse-results">
      <div v-for="sp in ketQua" :key="sp.variantId" class="fse-result" @click="themSanPham(sp)">
        <img v-if="sp.imageUrl" :src="resolveImageUrl(sp.imageUrl)" class="fse-result-img" />
        <div style="flex: 1; min-width: 0">
          <div class="fse-result-name">{{ sp.productName }}</div>
          <div class="fse-result-price">{{ fmt(sp.giaGoc) }}<span v-if="sp.sku"> · {{ sp.sku }}</span></div>
        </div>
        <span class="fse-add">+ Thêm</span>
      </div>
    </div>

    <div v-if="!items.length" class="fse-empty-preview">Chưa có sản phẩm nào.</div>
    <div v-else class="fse-items">
      <div v-for="i in items" :key="i.variantId" class="fse-item">
        <img v-if="i.imageUrl" :src="resolveImageUrl(i.imageUrl)" class="fse-result-img" />
        <div style="flex: 1; min-width: 0">
          <div class="fse-result-name">{{ i.productName }}</div>
          <div class="fse-result-price">Giá gốc {{ fmt(i.giaGoc) }}</div>
        </div>
        <label class="fse-price-edit">
          <span>Giá sale</span>
          <input v-model.number="i.giaSale" type="number" min="0" :max="i.giaGoc" class="fse-input" style="width: 130px" />
        </label>
        <span class="fse-pct" :class="{ 'is-bad': Number(i.giaSale) >= i.giaGoc }">
          {{ i.giaGoc > 0 ? Math.round((1 - (Number(i.giaSale) || 0) / i.giaGoc) * 100) : 0 }}%
        </span>
        <button class="fse-del no-auto-hover" @click="xoaSanPham(i.variantId)" title="Xoá khỏi đợt sale">×</button>
      </div>
    </div>

    <div v-if="err" class="fse-err">{{ err }}</div>

    <!-- Hành động -->
    <div class="fse-actions">
      <label class="fse-toggle">
        <input type="checkbox" v-model="form.isActive" />
        <span>Bật đợt sale này</span>
      </label>

      <div style="flex: 1"></div>

      <button v-if="dang && dang.dangChay" class="fse-btn-ghost" @click="goXuong" :disabled="saving">
        Gỡ khỏi trang khách
      </button>
      <button class="fse-btn-ghost" @click="luuNhap" :disabled="saving">
        {{ saving ? 'Đang lưu...' : 'Lưu nháp' }}
      </button>
      <button
        class="fse-btn-primary" :style="{ background: accent }"
        @click="moXacNhanDang" :disabled="saving || !items.length"
      >
        Đăng (Public)
      </button>
    </div>

    <div v-if="dang" class="fse-status">
      <span v-if="dang.coThayDoiChuaPublic" style="color: #ff9500">● Có thay đổi chưa đăng</span>
      <span v-else style="color: var(--green,#22d39a)">● Bản đang chạy khớp với nội dung này</span>
      <span v-if="dang.publicLuc" style="color: var(--muted)"> · Đăng lần cuối {{ new Date(dang.publicLuc).toLocaleString('vi-VN') }}</span>
    </div>
  </div>

  <!-- Popup xác nhận đăng -->
  <Teleport to="body">
    <div v-if="confirmPublish" class="fse-overlay" @click.self="confirmPublish = false">
      <div class="fse-dialog">
        <div style="font-size: 30px; margin-bottom: 10px">⚡</div>
        <div class="fse-dialog-title">Đăng Flash Sale này?</div>
        <div class="fse-dialog-sub">
          Sau khi đăng, khách hàng sẽ thấy ngay banner với {{ items.length }} sản phẩm
          trên trang chủ và trang khuyến mãi.
        </div>
        <div class="fse-dialog-actions">
          <button class="fse-btn-ghost" style="flex: 1" @click="confirmPublish = false">Chưa, để sau</button>
          <button class="fse-btn-primary" style="flex: 1" :style="{ background: accent }" @click="xacNhanDang" :disabled="saving">
            {{ saving ? 'Đang đăng...' : 'Đăng ngay' }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.fse-hint {
  background: var(--card2);
  border: 1px dashed rgba(var(--line-rgb), 0.25);
  border-radius: 12px;
  padding: 22px;
  text-align: center;
  margin-bottom: 18px;
}
.fse-hint-lock {
  text-align: left;
  font-size: 12.5px;
  color: var(--muted2);
  line-height: 1.6;
  padding: 14px 18px;
}
.fse-section-label {
  font-size: 11px;
  letter-spacing: 1.4px;
  text-transform: uppercase;
  color: var(--muted);
  font-weight: 700;
  margin: 22px 0 10px;
}
.fse-empty-preview {
  background: var(--card2);
  border-radius: 10px;
  padding: 22px;
  text-align: center;
  font-size: 12.5px;
  color: var(--muted2);
}
.fse-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}
.fse-field {
  display: flex;
  flex-direction: column;
  gap: 5px;
  font-size: 11.5px;
  color: var(--muted2);
}
.fse-input {
  height: 40px;
  padding: 0 12px;
  background: var(--card2);
  border: 1px solid rgba(var(--line-rgb), 0.22);
  border-radius: 9px;
  color: var(--text);
  font-size: 13px;
  font-family: 'Be Vietnam Pro', sans-serif;
}
.fse-colors {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  align-items: center;
}
.fse-color {
  width: 54px;
  height: 32px;
  border-radius: 9px;
  border: 2px solid transparent;
  cursor: pointer;
  transition: transform 0.15s ease, border-color 0.15s ease;
}
.fse-color:hover { transform: translateY(-2px); }
.fse-color.is-active { border-color: var(--text); }
.fse-color-custom {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 11.5px;
  color: var(--muted2);
  cursor: pointer;
}
.fse-color-custom input[type='color'] {
  width: 28px;
  height: 28px;
  border: none;
  background: none;
  padding: 0;
  cursor: pointer;
}
.fse-search {
  display: flex;
  gap: 8px;
}
.fse-results {
  margin-top: 8px;
  border: 1px solid rgba(var(--line-rgb), 0.16);
  border-radius: 10px;
  overflow: hidden;
  max-height: 240px;
  overflow-y: auto;
}
.fse-result {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 9px 12px;
  cursor: pointer;
  transition: background 0.12s ease;
}
.fse-result:hover { background: var(--card2); }
.fse-result-img {
  width: 38px;
  height: 38px;
  object-fit: contain;
  background: var(--card2);
  border-radius: 7px;
  flex: none;
}
.fse-result-name {
  font-size: 12.5px;
  color: var(--text);
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.fse-result-price {
  font-size: 11px;
  color: var(--muted2);
  margin-top: 2px;
}
.fse-add {
  font-size: 11.5px;
  font-weight: 700;
  color: var(--acc, #c6ff4a);
  flex: none;
}
.fse-items {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.fse-item {
  display: flex;
  align-items: center;
  gap: 12px;
  background: var(--card2);
  border-radius: 10px;
  padding: 10px 12px;
  flex-wrap: wrap;
}
.fse-price-edit {
  display: flex;
  flex-direction: column;
  gap: 3px;
  font-size: 10.5px;
  color: var(--muted2);
  flex: none;
}
.fse-pct {
  font-size: 12.5px;
  font-weight: 800;
  color: #ff3d24;
  min-width: 44px;
  text-align: right;
  flex: none;
}
.fse-pct.is-bad { color: var(--muted); }
.fse-del {
  background: transparent;
  border: 1px solid rgba(var(--line-rgb), 0.22);
  color: var(--muted);
  width: 30px;
  height: 30px;
  border-radius: 8px;
  font-size: 17px;
  line-height: 1;
  cursor: pointer;
  flex: none;
  transition: color 0.15s ease, border-color 0.15s ease;
}
.fse-del:hover { color: var(--sale, #ff5b5b); border-color: var(--sale, #ff5b5b); }
.fse-err {
  margin-top: 12px;
  font-size: 12.5px;
  color: var(--sale, #ff5b5b);
}
.fse-actions {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-top: 20px;
  flex-wrap: wrap;
}
.fse-toggle {
  display: flex;
  align-items: center;
  gap: 7px;
  font-size: 12.5px;
  color: var(--text);
  cursor: pointer;
}
.fse-btn-ghost {
  height: 40px;
  padding: 0 16px;
  border: 1px solid rgba(var(--line-rgb), 0.22);
  background: transparent;
  border-radius: 9px;
  color: var(--muted2);
  font-size: 12.5px;
  font-weight: 600;
  cursor: pointer;
  font-family: 'Be Vietnam Pro', sans-serif;
  transition: color 0.15s ease, border-color 0.15s ease;
}
.fse-btn-ghost:hover:not(:disabled) { color: var(--text); border-color: rgba(var(--line-rgb), 0.4); }
.fse-btn-ghost:disabled { opacity: 0.5; cursor: default; }
.fse-btn-primary {
  height: 40px;
  padding: 0 22px;
  border: none;
  border-radius: 9px;
  color: var(--acc-ink);
  font-weight: 700;
  font-size: 13px;
  cursor: pointer;
  font-family: 'Be Vietnam Pro', sans-serif;
}
.fse-btn-primary:disabled { opacity: 0.5; cursor: default; }
.fse-status {
  margin-top: 10px;
  font-size: 11.5px;
}

.fse-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 200;
  padding: 20px;
}
.fse-dialog {
  background: var(--card);
  border: 1px solid rgba(var(--line-rgb), 0.18);
  border-radius: 16px;
  padding: 26px;
  max-width: 380px;
  width: 100%;
  text-align: center;
}
.fse-dialog-title {
  font-size: 15.5px;
  font-weight: 800;
  color: var(--text);
  margin-bottom: 6px;
}
.fse-dialog-sub {
  font-size: 12.5px;
  color: var(--muted2);
  line-height: 1.6;
  margin-bottom: 20px;
}
.fse-dialog-actions {
  display: flex;
  gap: 10px;
}

@media (max-width: 640px) {
  .fse-grid { grid-template-columns: 1fr; }
}
</style>
