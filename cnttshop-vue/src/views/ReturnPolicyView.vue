<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { state, actions, accent } from '../store.js';
import { fetchMyReturns, submitReturnRequest, resolveImageUrl } from '../api.js';
import { ngayVN } from '../data/supportMeta.js';

// Chính sách đổi trả — RIÊNG với bảo hành: đổi trả áp dụng NGAY sau khi nhận hàng (1 đổi 1 trong
// 7 ngày), bảo hành mới là lỗi phát sinh khi dùng lâu dài.
const DIEU_KIEN = [
  'Áp dụng trong vòng 7 ngày kể từ khi nhận hàng — 1 đổi 1 với sản phẩm lỗi.',
  'Lỗi do nhà sản xuất, giao sai mẫu/màu/cấu hình, hoặc không đúng mô tả.',
  'Sản phẩm còn nguyên hộp, tem niêm phong, đầy đủ phụ kiện, không trầy xước do người dùng.',
  'Đơn mua online: bắt buộc có video tự tay mở hàng để đối chiếu (chống tranh chấp).',
];
const KHONG_AP_DUNG = [
  'Quá 7 ngày kể từ khi nhận hàng.',
  'Hư hỏng do rơi vỡ, vào nước, sử dụng sai hướng dẫn.',
  'Mất hộp, mất phụ kiện, tem niêm phong bị rách hoặc đã bóc.',
  'Sản phẩm đã qua sửa chữa/can thiệp ở nơi khác.',
];
const QUY_TRINH = [
  { b: '1', t: 'Gửi yêu cầu', m: 'Điền form bên dưới kèm video lỗi, video mở hàng (đơn online) và ảnh lỗi.' },
  { b: '2', t: 'CSKH kiểm tra', m: 'Đối chiếu minh chứng và điều kiện đổi trả, phản hồi trong 24 giờ làm việc.' },
  { b: '3', t: 'Xác nhận', m: 'Chấp nhận đổi/trả hoặc nêu rõ lý do từ chối. Bạn theo dõi trạng thái ngay tại đây.' },
  { b: '4', t: 'Đổi / hoàn tiền', m: 'Đổi sản phẩm mới hoặc hoàn tiền về nguồn thanh toán gốc.' },
];
const LY_DO = [
  { v: 'loi_nsx', t: 'Lỗi nhà sản xuất' },
  { v: 'giao_sai', t: 'Giao sai mẫu / cấu hình' },
  { v: 'khong_dung_mo_ta', t: 'Không đúng mô tả' },
  { v: 'khac', t: 'Lý do khác' },
];

const NHAN_TT = {
  cho_xu_ly: { t: 'Chờ xử lý', c: 'var(--muted2)' },
  dang_xu_ly: { t: 'Đang xử lý', c: 'var(--acc, #c6ff4a)' },
  chap_nhan: { t: 'Chấp nhận', c: 'var(--green)' },
  tu_choi: { t: 'Từ chối', c: 'var(--sale)' },
  hoan_tat: { t: 'Hoàn tất', c: 'var(--green)' },
};

const form = reactive({ kenhMua: 'online', maDon: '', lyDo: '', noiDung: '' });
const videoLoi = ref(null);
const videoMoHang = ref(null);
const anh = ref([]); // File[]
const sending = ref(false);
const error = ref('');
const ok = ref('');

const myReturns = ref([]);
const loadingList = ref(false);

function onFile(kind, e) {
  const files = Array.from(e.target.files || []);
  if (kind === 'videoLoi') videoLoi.value = files[0] || null;
  else if (kind === 'videoMoHang') videoMoHang.value = files[0] || null;
  else if (kind === 'anh') anh.value = files.slice(0, 3);
}

const canSubmit = computed(() => form.noiDung.trim() && (form.kenhMua !== 'online' || videoMoHang.value));

async function gui() {
  error.value = '';
  ok.value = '';
  if (!form.noiDung.trim()) {
    error.value = 'Vui lòng mô tả nội dung cần đổi trả.';
    return;
  }
  if (form.kenhMua === 'online' && !videoMoHang.value) {
    error.value = 'Đơn mua online bắt buộc kèm video tự tay mở hàng.';
    return;
  }
  sending.value = true;
  try {
    await submitReturnRequest(
      { maDon: form.maDon, kenhMua: form.kenhMua, lyDo: form.lyDo, noiDung: form.noiDung },
      { videoLoi: videoLoi.value, videoMoHang: videoMoHang.value, anh: anh.value },
    );
    ok.value = 'Đã gửi yêu cầu đổi trả! CNTTShop sẽ phản hồi trong 24 giờ làm việc.';
    form.maDon = form.lyDo = form.noiDung = '';
    videoLoi.value = videoMoHang.value = null;
    anh.value = [];
    actions.showToast('Đã gửi yêu cầu đổi trả');
    taiDanhSach();
  } catch (e) {
    error.value = e?.message && !e.message.startsWith('HTTP') ? e.message : 'Gửi yêu cầu thất bại, thử lại.';
  } finally {
    sending.value = false;
  }
}

async function taiDanhSach() {
  if (!state.user) return;
  loadingList.value = true;
  try {
    myReturns.value = await fetchMyReturns();
  } catch (e) {
    myReturns.value = [];
  } finally {
    loadingList.value = false;
  }
}

onMounted(taiDanhSach);
</script>

<template>
  <main style="max-width: 1040px; margin: 0 auto; padding: 24px 24px 72px">
    <button class="sp-back" @click="actions.goSupport()">← Trung tâm hỗ trợ</button>

    <div style="margin-bottom: 30px">
      <div class="sp-eyebrow">CHÍNH SÁCH ĐỔI TRẢ</div>
      <h1 class="sp-h1">Đổi trả <span :style="{ color: accent }">1 đổi 1</span> trong 7 ngày</h1>
      <p style="font-size: 14.5px; color: var(--muted2); max-width: 640px; line-height: 1.65; margin: 0">
        Chính sách đổi trả áp dụng cho sản phẩm lỗi <b>ngay sau khi nhận hàng</b> — khác với bảo
        hành (lỗi phát sinh trong quá trình sử dụng lâu dài).
      </p>
    </div>

    <!-- Điều kiện / không áp dụng -->
    <section style="display: grid; grid-template-columns: 1fr 1fr; gap: 18px; margin-bottom: 30px" class="rt-two">
      <div class="sp-card" style="padding: 24px 26px">
        <h2 class="sp-h2" style="color: var(--green)">✓ Được đổi trả khi</h2>
        <ul class="rt-ul">
          <li v-for="(d, i) in DIEU_KIEN" :key="i">{{ d }}</li>
        </ul>
      </div>
      <div class="sp-card" style="padding: 24px 26px">
        <h2 class="sp-h2" style="color: var(--sale)">✕ Không áp dụng</h2>
        <ul class="rt-ul rt-ul-x">
          <li v-for="(d, i) in KHONG_AP_DUNG" :key="i">{{ d }}</li>
        </ul>
      </div>
    </section>

    <!-- Quy trình -->
    <section style="margin-bottom: 34px">
      <h2 class="sp-h2">Quy trình đổi trả</h2>
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); gap: 14px">
        <div v-for="q in QUY_TRINH" :key="q.b" class="sp-card" style="padding: 20px">
          <div class="rt-step" :style="{ background: accent, color: 'var(--acc-ink)' }">{{ q.b }}</div>
          <div style="font-size: 14px; font-weight: 700; color: var(--text); margin: 12px 0 6px">{{ q.t }}</div>
          <div style="font-size: 12.7px; color: var(--muted2); line-height: 1.6">{{ q.m }}</div>
        </div>
      </div>
    </section>

    <!-- Form gửi yêu cầu -->
    <section class="sp-card" style="padding: 28px 30px; margin-bottom: 30px; border-color: rgba(var(--line-rgb), 0.2)">
      <h2 class="sp-h2">Gửi yêu cầu đổi trả</h2>

      <div v-if="!state.user" class="sp-alert info" style="margin: 0">
        Vui lòng <a href="#" @click.prevent="actions.openLogin()" :style="{ color: accent }">đăng nhập</a>
        để gửi yêu cầu đổi trả và theo dõi trạng thái.
      </div>

      <template v-else>
        <div v-if="error" class="sp-alert err">{{ error }}</div>
        <div v-if="ok" class="sp-alert ok">{{ ok }}</div>

        <div style="display: flex; flex-direction: column; gap: 16px">
          <div>
            <label class="rt-label">Kênh mua hàng</label>
            <div style="display: flex; gap: 10px; flex-wrap: wrap">
              <label class="rt-radio" :class="{ on: form.kenhMua === 'online' }">
                <input type="radio" value="online" v-model="form.kenhMua" /> Mua online
              </label>
              <label class="rt-radio" :class="{ on: form.kenhMua === 'tai_cua_hang' }">
                <input type="radio" value="tai_cua_hang" v-model="form.kenhMua" /> Mua tại cửa hàng
              </label>
            </div>
          </div>

          <div class="rt-grid">
            <div>
              <label class="rt-label">Mã đơn hàng (nếu có)</label>
              <input v-model="form.maDon" class="sp-input" placeholder="vd: DH25..." />
            </div>
            <div>
              <label class="rt-label">Lý do</label>
              <select v-model="form.lyDo" class="sp-select">
                <option value="">— Chọn lý do —</option>
                <option v-for="l in LY_DO" :key="l.v" :value="l.v">{{ l.t }}</option>
              </select>
            </div>
          </div>

          <div>
            <label class="rt-label">Nội dung cần đổi trả *</label>
            <textarea v-model="form.noiDung" class="sp-textarea" rows="4"
              placeholder="Mô tả sản phẩm, tình trạng lỗi, mong muốn đổi hay hoàn tiền…"></textarea>
          </div>

          <!-- Upload minh chứng -->
          <div class="rt-grid">
            <div>
              <label class="rt-label">Video minh chứng lỗi</label>
              <input type="file" accept="video/*" class="rt-file" @change="onFile('videoLoi', $event)" />
              <div v-if="videoLoi" class="rt-fname">✓ {{ videoLoi.name }}</div>
            </div>
            <div>
              <label class="rt-label">
                Video tự tay mở hàng
                <span v-if="form.kenhMua === 'online'" style="color: var(--sale)">*</span>
              </label>
              <input type="file" accept="video/*" class="rt-file" @change="onFile('videoMoHang', $event)" />
              <div v-if="videoMoHang" class="rt-fname">✓ {{ videoMoHang.name }}</div>
              <div v-else-if="form.kenhMua === 'online'" style="font-size: 11px; color: var(--muted); margin-top: 5px">
                Bắt buộc với đơn mua online.
              </div>
            </div>
          </div>

          <div>
            <label class="rt-label">Ảnh lỗi (tối đa 3)</label>
            <input type="file" accept="image/*" multiple class="rt-file" @change="onFile('anh', $event)" />
            <div v-if="anh.length" class="rt-fname">✓ Đã chọn {{ anh.length }} ảnh</div>
          </div>

          <div style="font-size: 11.5px; color: var(--muted); line-height: 1.5">
            Dung lượng tối đa mỗi tệp 120MB. Video giúp CSKH xử lý nhanh và chính xác hơn.
          </div>

          <button class="sp-btn-acc" style="height: 46px; align-self: flex-start; padding: 0 26px"
            :disabled="sending || !canSubmit" @click="gui">
            {{ sending ? 'Đang gửi…' : 'Gửi yêu cầu đổi trả →' }}
          </button>
        </div>
      </template>
    </section>

    <!-- Yêu cầu của tôi -->
    <section v-if="state.user">
      <h2 class="sp-h2">Yêu cầu đổi trả của tôi</h2>
      <div v-if="loadingList" class="sp-card sp-empty">Đang tải…</div>
      <div v-else-if="!myReturns.length" class="sp-card sp-empty">Bạn chưa gửi yêu cầu đổi trả nào.</div>
      <div v-else style="display: flex; flex-direction: column; gap: 12px">
        <div v-for="r in myReturns" :key="r.id" class="sp-card" style="padding: 18px 20px">
          <div style="display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; margin-bottom: 12px">
            <div>
              <span :style="{ color: accent }" style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 15px">{{ r.maYeuCau }}</span>
              <span style="font-size: 12px; color: var(--muted); margin-left: 10px">{{ ngayVN(r.createdAt) }}</span>
            </div>
            <span class="sp-pill" :style="{ color: (NHAN_TT[r.trangThai] || {}).c || 'var(--muted2)' }">
              {{ r.nhanTrangThai }}
            </span>
          </div>
          <div style="font-size: 13px; color: var(--muted2); line-height: 1.6; margin-bottom: 10px">{{ r.noiDung }}</div>
          <div style="display: flex; gap: 8px; flex-wrap: wrap">
            <a v-if="r.videoLoi" :href="resolveImageUrl(r.videoLoi)" target="_blank" rel="noopener" class="rt-chip">🎬 Video lỗi</a>
            <a v-if="r.videoMoHang" :href="resolveImageUrl(r.videoMoHang)" target="_blank" rel="noopener" class="rt-chip">📦 Video mở hàng</a>
            <a v-for="(a, i) in r.anhLoi" :key="i" :href="resolveImageUrl(a)" target="_blank" rel="noopener" class="rt-chip">🖼️ Ảnh {{ i + 1 }}</a>
          </div>
          <div v-if="r.ghiChuCskh" style="font-size: 12.3px; color: var(--muted2); margin-top: 10px">
            <b style="color: var(--text)">CSKH:</b> {{ r.ghiChuCskh }}
          </div>
        </div>
      </div>
    </section>
  </main>
</template>

<style scoped>
.rt-two, .rt-grid { display: grid; }
.rt-grid { grid-template-columns: 1fr 1fr; gap: 14px; }
.rt-ul { list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 11px; }
.rt-ul li { font-size: 13px; color: var(--muted2); line-height: 1.6; padding-left: 22px; position: relative; }
.rt-ul li::before { content: '✓'; position: absolute; left: 0; color: var(--green); font-weight: 700; }
.rt-ul-x li::before { content: '✕'; color: var(--sale); }
.rt-step {
  width: 32px; height: 32px; border-radius: 9px; display: flex; align-items: center; justify-content: center;
  font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 14px;
}
.rt-label { display: block; font-size: 11.8px; color: var(--muted); margin-bottom: 6px; font-weight: 500; }
.rt-radio {
  display: inline-flex; align-items: center; gap: 8px; padding: 10px 16px; border-radius: 10px;
  border: 1px solid rgba(var(--line-rgb), 0.2); cursor: pointer; font-size: 13px; color: var(--muted2);
}
.rt-radio.on { border-color: var(--acc, #c6ff4a); color: var(--text); background: color-mix(in srgb, var(--acc, #c6ff4a) 8%, transparent); }
.rt-radio input { accent-color: var(--acc, #c6ff4a); }
.rt-file {
  width: 100%; font-size: 12.5px; color: var(--muted2);
  background: var(--card2); border: 1px solid rgba(var(--line-rgb), 0.22); border-radius: 10px; padding: 9px 12px;
}
.rt-fname { font-size: 11.5px; color: var(--green); margin-top: 6px; }
.rt-chip {
  font-size: 11.5px; color: var(--muted2); background: var(--card2); border: 1px solid rgba(var(--line-rgb), 0.16);
  border-radius: 8px; padding: 5px 10px; text-decoration: none;
}
.rt-chip:hover { border-color: var(--acc, #c6ff4a); color: var(--acc, #c6ff4a); }
@media (max-width: 720px) {
  .rt-two, .rt-grid { grid-template-columns: 1fr !important; }
}
</style>
