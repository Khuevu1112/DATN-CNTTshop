<template>
  <div class="fsp">
    <div class="fsp-head">
      <div>
        <div class="fsp-title">⚡ Flash Sale</div>
        <div class="fsp-sub">
          Chỉ tồn tại một đợt còn hiệu lực tại một thời điểm. Lưu chỉ ghi bản nháp — khách chỉ
          thấy sau khi bấm Đăng.
        </div>
      </div>
      <div v-if="dot" class="fsp-badge" :class="dot.dangChay ? 'is-live' : 'is-off'">
        {{ dot.dangChay ? 'ĐANG CHẠY' : 'CHƯA ĐĂNG' }}
      </div>
    </div>

    <div v-if="loading" class="fsp-empty">Đang tải...</div>

    <template v-else>
      <div v-if="khoaTaoMoi" class="fsp-lock">
        🔒 Đang có một Flash Sale còn hiệu lực — chỉ sửa được đợt này. Muốn mở đợt khác thì gỡ
        hoặc để đợt hiện tại kết thúc trước.
      </div>

      <div class="fsp-grid">
        <label class="fsp-field">
          <span>Tiêu đề</span>
          <input v-model="form.tieuDe" placeholder="FLASH SALE" class="fsp-input" />
        </label>
        <label class="fsp-field">
          <span>Mô tả ngắn</span>
          <input v-model="form.moTa" placeholder="Giảm sốc cuối tuần" class="fsp-input" />
        </label>
        <label class="fsp-field">
          <span>Bắt đầu</span>
          <input v-model="form.batDauLuc" type="datetime-local" class="fsp-input" />
        </label>
        <label class="fsp-field">
          <span>Kết thúc</span>
          <input v-model="form.ketThucLuc" type="datetime-local" class="fsp-input" />
        </label>
      </div>

      <div class="fsp-label">Màu banner</div>
      <div class="fsp-colors">
        <button
          v-for="m in BANG_MAU" :key="m.ten" class="fsp-color"
          :class="{ 'is-active': form.mauBatDau === m.from && form.mauKetThuc === m.to }"
          :style="{ background: `linear-gradient(115deg, ${m.from}, ${m.to})` }"
          :title="m.ten" @click="form.mauBatDau = m.from; form.mauKetThuc = m.to"
        ></button>
        <label class="fsp-color-custom">
          <input type="color" v-model="form.mauBatDau" />
          <input type="color" v-model="form.mauKetThuc" />
          <span>Tự chọn</span>
        </label>
      </div>

      <!-- Xem trước thanh banner đúng như khách sẽ thấy -->
      <div class="fsp-label">Xem trước</div>
      <div class="fsp-preview" :style="{ background: `linear-gradient(115deg, ${form.mauBatDau}, ${form.mauKetThuc})` }">
        <span class="fsp-preview-title">{{ form.tieuDe || 'FLASH SALE' }}</span>
        <span v-if="form.moTa" class="fsp-preview-sub">{{ form.moTa }}</span>
        <span class="fsp-preview-count">{{ items.length }} sản phẩm</span>
      </div>

      <div class="fsp-label">Sản phẩm ({{ items.length }})</div>
      <div class="fsp-search">
        <input
          v-model="timKiem" @keyup.enter="timSanPham"
          placeholder="Tìm theo tên hoặc SKU rồi Enter..." class="fsp-input" style="flex: 1"
        />
        <button class="fsp-btn-ghost" @click="timSanPham" :disabled="dangTim">
          {{ dangTim ? '...' : 'Tìm' }}
        </button>
      </div>

      <div v-if="ketQua.length" class="fsp-results">
        <div v-for="sp in ketQua" :key="sp.variantId" class="fsp-result" @click="themSanPham(sp)">
          <img v-if="sp.imageUrl" :src="resolveImageUrl(sp.imageUrl)" class="fsp-img" />
          <div style="flex: 1; min-width: 0">
            <div class="fsp-name">{{ sp.productName }}</div>
            <div class="fsp-meta">{{ money(sp.giaGoc) }}<span v-if="sp.sku"> · {{ sp.sku }}</span></div>
          </div>
          <span class="fsp-add">+ Thêm</span>
        </div>
      </div>

      <div v-if="!items.length" class="fsp-empty">Chưa có sản phẩm nào trong đợt sale.</div>
      <div v-else class="fsp-items">
        <div v-for="i in items" :key="i.variantId" class="fsp-item">
          <img v-if="i.imageUrl" :src="resolveImageUrl(i.imageUrl)" class="fsp-img" />
          <div style="flex: 1; min-width: 0">
            <div class="fsp-name">{{ i.productName }}</div>
            <div class="fsp-meta">Giá gốc {{ money(i.giaGoc) }}</div>
          </div>
          <label class="fsp-price">
            <span>Giá sale</span>
            <input v-model.number="i.giaSale" type="number" min="0" class="fsp-input" style="width: 120px" />
          </label>
          <span class="fsp-pct" :class="{ 'is-bad': Number(i.giaSale) >= i.giaGoc }">
            {{ i.giaGoc > 0 ? Math.round((1 - (Number(i.giaSale) || 0) / i.giaGoc) * 100) : 0 }}%
          </span>
          <button class="fsp-del" @click="xoaSanPham(i.variantId)" title="Xoá">×</button>
        </div>
      </div>

      <div v-if="error" class="fsp-err">{{ error }}</div>

      <div class="fsp-actions">
        <label class="fsp-toggle">
          <input type="checkbox" v-model="form.isActive" />
          <span>Bật đợt sale</span>
        </label>
        <div style="flex: 1"></div>
        <button v-if="dot && dot.dangChay" class="fsp-btn-ghost" @click="goXuong" :disabled="saving">
          Gỡ khỏi trang khách
        </button>
        <button class="fsp-btn-ghost" @click="luuNhap" :disabled="saving">
          {{ saving ? 'Đang lưu...' : 'Lưu nháp' }}
        </button>
        <button class="fsp-btn-primary" @click="moXacNhan" :disabled="saving || !items.length">
          Đăng (Public)
        </button>
      </div>

      <div v-if="dot" class="fsp-status">
        <span v-if="dot.coThayDoiChuaPublic" style="color: #ff9500">● Có thay đổi chưa đăng</span>
        <span v-else style="color: #22d39a">● Bản đang chạy khớp với nội dung này</span>
        <span v-if="dot.publicLuc" style="color: var(--muted)">
          · Đăng lần cuối {{ new Date(dot.publicLuc).toLocaleString('vi-VN') }}
        </span>
      </div>
    </template>

    <!-- Popup xác nhận đăng -->
    <Teleport to="body">
      <div v-if="confirmPublish" class="fsp-overlay" @click.self="confirmPublish = false">
        <div class="fsp-dialog">
          <div style="font-size: 30px; margin-bottom: 10px">⚡</div>
          <div class="fsp-dialog-title">Đăng Flash Sale này?</div>
          <div class="fsp-dialog-sub">
            Sau khi đăng, khách hàng sẽ thấy ngay banner với {{ items.length }} sản phẩm trên
            trang chủ và trang khuyến mãi.
          </div>
          <div style="display: flex; gap: 10px">
            <button class="fsp-btn-ghost" style="flex: 1" @click="confirmPublish = false">Chưa, để sau</button>
            <button class="fsp-btn-primary" style="flex: 1" @click="xacNhanDang" :disabled="saving">
              {{ saving ? 'Đang đăng...' : 'Đăng ngay' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { resolveImageUrl } from '../api/http';
import {
  getFlashSaleAdmin, createFlashSale, updateFlashSale,
  publishFlashSale, unpublishFlashSale, searchProductsForSale,
} from '../api/admin';

// Quản lý flash sale trong Admin console. Cùng nghiệp vụ với trình soạn bên trang khuyến mãi
// của khách (cnttshop-vue/components/FlashSaleEditor.vue) — cả hai gọi chung một API, sửa ở đâu
// cũng ra cùng một bản nháp.

const BANG_MAU = [
  { ten: 'Đỏ cam', from: '#ff3d24', to: '#ff9500' },
  { ten: 'Tím hồng', from: '#7028e4', to: '#e5b2ca' },
  { ten: 'Xanh dương', from: '#2193b0', to: '#6dd5ed' },
  { ten: 'Xanh lá', from: '#11998e', to: '#38ef7d' },
  { ten: 'Hoàng hôn', from: '#f7971e', to: '#ffd200' },
  { ten: 'Đêm', from: '#232526', to: '#414345' },
];

const dot = ref(null);
const khoaTaoMoi = ref(false);
const loading = ref(true);
const saving = ref(false);
const error = ref('');
const confirmPublish = ref(false);

const form = reactive({
  tieuDe: '', moTa: '', mauBatDau: '#ff3d24', mauKetThuc: '#ff9500',
  batDauLuc: '', ketThucLuc: '', isActive: true,
});
const items = ref([]);

const timKiem = ref('');
const ketQua = ref([]);
const dangTim = ref(false);

const money = (n) => (n == null ? '0₫' : Number(n).toLocaleString('vi-VN') + '₫');

/** datetime-local cần "YYYY-MM-DDTHH:mm" — cắt giây và offset khỏi chuỗi ISO backend trả về. */
function toLocalInput(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  const p = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}T${p(d.getHours())}:${p(d.getMinutes())}`;
}

function napTuDto(dto) {
  dot.value = dto;
  if (!dto) return;
  Object.assign(form, {
    tieuDe: dto.tieuDe || '', moTa: dto.moTa || '',
    mauBatDau: dto.mauBatDau, mauKetThuc: dto.mauKetThuc,
    batDauLuc: toLocalInput(dto.batDauLuc), ketThucLuc: toLocalInput(dto.ketThucLuc),
    isActive: dto.isActive !== false,
  });
  items.value = (dto.sanPham || []).map((s) => ({ ...s }));
}

/** Lỗi nghiệp vụ backend trả về dạng { message }; hiện đúng câu đó thay vì "Lỗi không xác định". */
function loi(e, mac) {
  return e?.response?.data?.message || e?.message || mac;
}

async function load() {
  loading.value = true;
  try {
    const st = await getFlashSaleAdmin();
    khoaTaoMoi.value = st.dangCoDotConHieuLuc;
    napTuDto(st.dot);
  } catch (e) {
    error.value = loi(e, 'Không tải được Flash Sale');
  } finally {
    loading.value = false;
  }
}

function payload() {
  return {
    ...form,
    batDauLuc: form.batDauLuc || null,
    ketThucLuc: form.ketThucLuc || null,
    sanPham: items.value.map((i) => ({ variantId: i.variantId, giaSale: Number(i.giaSale) || 0 })),
  };
}

async function luuNhap() {
  error.value = '';
  saving.value = true;
  try {
    const dto = dot.value
      ? await updateFlashSale(dot.value.id, payload())
      : await createFlashSale(payload());
    napTuDto(dto);
    khoaTaoMoi.value = true;
  } catch (e) {
    error.value = loi(e, 'Lưu thất bại');
  } finally {
    saving.value = false;
  }
}

/** Lưu nháp trước rồi mới mở popup — đảm bảo thứ đem đăng đúng là thứ đang hiện trên màn hình. */
async function moXacNhan() {
  error.value = '';
  await luuNhap();
  if (!error.value) confirmPublish.value = true;
}

async function xacNhanDang() {
  saving.value = true;
  try {
    napTuDto(await publishFlashSale(dot.value.id));
    confirmPublish.value = false;
  } catch (e) {
    error.value = loi(e, 'Đăng thất bại');
    confirmPublish.value = false;
  } finally {
    saving.value = false;
  }
}

async function goXuong() {
  if (!window.confirm('Gỡ Flash Sale khỏi trang khách? Nội dung vẫn được giữ để bật lại sau.')) return;
  saving.value = true;
  try {
    napTuDto(await unpublishFlashSale(dot.value.id));
  } catch (e) {
    error.value = loi(e, 'Gỡ thất bại');
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
    error.value = 'Sản phẩm này đã có trong đợt sale';
    return;
  }
  // Mặc định giảm 20%, làm tròn nghìn — admin sửa lại ngay ở ô giá.
  items.value.push({ ...sp, giaSale: Math.round((sp.giaGoc * 0.8) / 1000) * 1000 });
  timKiem.value = '';
  ketQua.value = [];
}

function xoaSanPham(variantId) {
  items.value = items.value.filter((i) => i.variantId !== variantId);
}

onMounted(load);
</script>

<style scoped>
.fsp {
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 14px;
  padding: 18px;
}
.fsp-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 14px;
}
.fsp-title { font-size: 14px; font-weight: 700; color: var(--text); }
.fsp-sub { font-size: 11.5px; color: var(--muted); margin-top: 3px; line-height: 1.5; max-width: 520px; }
.fsp-badge {
  flex: none;
  font-size: 10px;
  font-weight: 800;
  letter-spacing: 0.5px;
  padding: 4px 10px;
  border-radius: 20px;
}
.fsp-badge.is-live { background: #22d39a; color: #06281c; }
.fsp-badge.is-off { background: var(--line); color: var(--muted); }

.fsp-lock {
  background: rgba(255, 149, 0, 0.1);
  border: 1px solid rgba(255, 149, 0, 0.3);
  border-radius: 10px;
  padding: 11px 14px;
  font-size: 12px;
  color: var(--muted);
  line-height: 1.55;
  margin-bottom: 14px;
}
.fsp-label {
  font-size: 10.5px;
  letter-spacing: 1.2px;
  text-transform: uppercase;
  color: var(--muted);
  font-weight: 700;
  margin: 16px 0 8px;
}
.fsp-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.fsp-field { display: flex; flex-direction: column; gap: 4px; font-size: 11px; color: var(--muted); }
.fsp-input {
  height: 38px;
  padding: 0 11px;
  background: var(--bg);
  border: 1px solid var(--line);
  border-radius: 8px;
  color: var(--text);
  font-size: 12.5px;
  font-family: inherit;
}
.fsp-colors { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; }
.fsp-color {
  width: 50px; height: 30px; border-radius: 8px;
  border: 2px solid transparent; cursor: pointer;
  transition: transform 0.15s ease, border-color 0.15s ease;
}
.fsp-color:hover { transform: translateY(-2px); }
.fsp-color.is-active { border-color: var(--text); }
.fsp-color-custom { display: flex; align-items: center; gap: 4px; font-size: 11px; color: var(--muted); cursor: pointer; }
.fsp-color-custom input[type='color'] { width: 26px; height: 26px; border: none; background: none; padding: 0; cursor: pointer; }

.fsp-preview {
  border-radius: 12px;
  padding: 13px 18px;
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}
.fsp-preview-title { font-size: 15px; font-weight: 800; letter-spacing: 1px; color: #fff; }
.fsp-preview-sub { font-size: 12px; color: rgba(255, 255, 255, 0.85); }
.fsp-preview-count {
  margin-left: auto; font-size: 11px; font-weight: 700; color: #fff;
  background: rgba(0, 0, 0, 0.25); padding: 3px 10px; border-radius: 20px;
}

.fsp-search { display: flex; gap: 8px; }
.fsp-results {
  margin-top: 8px; border: 1px solid var(--line); border-radius: 10px;
  overflow: hidden; max-height: 230px; overflow-y: auto;
}
.fsp-result {
  display: flex; align-items: center; gap: 10px; padding: 8px 11px;
  cursor: pointer; transition: background 0.12s ease;
}
.fsp-result:hover { background: var(--bg); }
.fsp-img { width: 36px; height: 36px; object-fit: contain; background: var(--bg); border-radius: 6px; flex: none; }
.fsp-name { font-size: 12px; color: var(--text); font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.fsp-meta { font-size: 10.5px; color: var(--muted); margin-top: 2px; }
.fsp-add { font-size: 11px; font-weight: 700; color: var(--acc); flex: none; }

.fsp-items { display: flex; flex-direction: column; gap: 7px; }
.fsp-item {
  display: flex; align-items: center; gap: 10px;
  background: var(--bg); border-radius: 9px; padding: 9px 11px; flex-wrap: wrap;
}
.fsp-price { display: flex; flex-direction: column; gap: 2px; font-size: 10px; color: var(--muted); flex: none; }
.fsp-pct { font-size: 12px; font-weight: 800; color: #ff3d24; min-width: 42px; text-align: right; flex: none; }
.fsp-pct.is-bad { color: var(--muted); }
.fsp-del {
  background: transparent; border: 1px solid var(--line); color: var(--muted);
  width: 28px; height: 28px; border-radius: 7px; font-size: 16px; line-height: 1;
  cursor: pointer; flex: none;
}
.fsp-del:hover { color: #ff5b5b; border-color: #ff5b5b; }

.fsp-empty {
  background: var(--bg); border-radius: 9px; padding: 18px;
  text-align: center; font-size: 12px; color: var(--muted);
}
.fsp-err { margin-top: 10px; font-size: 12px; color: #ff5b5b; }
.fsp-actions { display: flex; align-items: center; gap: 9px; margin-top: 16px; flex-wrap: wrap; }
.fsp-toggle { display: flex; align-items: center; gap: 6px; font-size: 12px; color: var(--text); cursor: pointer; }
.fsp-btn-ghost {
  height: 36px; padding: 0 14px; border: 1px solid var(--line); background: transparent;
  border-radius: 8px; color: var(--muted); font-size: 12px; font-weight: 600;
  cursor: pointer; font-family: inherit;
}
.fsp-btn-ghost:hover:not(:disabled) { color: var(--text); }
.fsp-btn-ghost:disabled { opacity: 0.5; cursor: default; }
.fsp-btn-primary {
  height: 36px; padding: 0 18px; border: none; background: var(--acc);
  border-radius: 8px; color: #0b0b0b; font-size: 12.5px; font-weight: 700;
  cursor: pointer; font-family: inherit;
}
.fsp-btn-primary:disabled { opacity: 0.5; cursor: default; }
.fsp-status { margin-top: 9px; font-size: 11px; }

.fsp-overlay {
  position: fixed; inset: 0; background: rgba(0, 0, 0, 0.6);
  display: flex; align-items: center; justify-content: center; z-index: 300; padding: 20px;
}
.fsp-dialog {
  background: var(--card); border: 1px solid var(--line); border-radius: 16px;
  padding: 26px; max-width: 380px; width: 100%; text-align: center;
}
.fsp-dialog-title { font-size: 15px; font-weight: 800; color: var(--text); margin-bottom: 6px; }
.fsp-dialog-sub { font-size: 12px; color: var(--muted); line-height: 1.6; margin-bottom: 20px; }

@media (max-width: 900px) {
  .fsp-grid { grid-template-columns: 1fr; }
}
</style>
