<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue';
import { state, actions, accent } from '../store.js';
import {
  fetchMyWarranties,
  fetchWarrantyDetail,
  submitWarrantyRequest,
  fetchServiceCenters,
  fetchMyAppointments,
  fetchPhamViTanNoi,
} from '../api.js';
import { tenLoaiThietBi, ngayVN, isoDate } from '../data/supportMeta.js';
import { fmt } from '../data/products.js';

// Phụ phí bảo hành tận nơi — PHẢI khớp WarrantyService.PHU_PHI_TAN_NOI ở backend (150.000đ).
const PHU_PHI_TAN_NOI = 150000;

const warranties = ref([]);
const centers = ref([]);
const history = ref([]); // lịch sử bảo hành = các lần sửa đã hoàn thành
const dangTai = ref(true);

const wStatusLabels = { active: 'Còn hạn', expired: 'Hết hạn', void: 'Vô hiệu' };
const wStatusColors = { active: 'var(--green)', expired: 'var(--muted)', void: 'var(--sale)' };
const wReqLabels = {
  pending: 'Chờ tiếp nhận', accepted: 'Đã tiếp nhận', processing: 'Đang xử lý',
  resolved: 'Đã xử lý', rejected: 'Từ chối',
};
const wReqColors = {
  pending: 'var(--muted2)', accepted: accent, processing: accent,
  resolved: 'var(--green)', rejected: 'var(--sale)',
};

// ===== Chi tiết một phiếu (mở khi bấm vào sản phẩm) =====
const detail = ref(null);
const detailLoading = ref(false);
async function moChiTiet(w) {
  detailLoading.value = true;
  detail.value = null;
  try {
    detail.value = await fetchWarrantyDetail(w.id);
  } catch (e) {
    actions.showToast('Không tải được chi tiết bảo hành');
  } finally {
    detailLoading.value = false;
  }
}
function dongChiTiet() {
  detail.value = null;
}

const conHan = (w) => w.status === 'active';
function soNgayConLai(w) {
  if (!w.endDate) return null;
  const ms = new Date(w.endDate).setHours(23, 59, 59) - Date.now();
  return Math.max(0, Math.ceil(ms / 86400000));
}

// ===== Form yêu cầu bảo hành (sidebar trái) =====
const form = reactive({
  warrantyId: '',
  issue: '',
  ngayHen: '',
  hinhThuc: 'cua_hang', // cua_hang | tan_noi
  centerId: '',
});
const sending = ref(false);
const formError = ref('');
const formOk = ref('');

// ===== Phạm vi phục vụ tận nơi =====
// Kỹ thuật viên xuất phát từ chi nhánh nên chỉ tỉnh CÓ chi nhánh mới đi tận nơi được. Trước đây
// form không kiểm gì: khách ở tỉnh không có chi nhánh vẫn chọn được "Bảo hành tận nơi", bị báo
// phụ phí 150.000đ, rồi mới biết không phục vụ được khi CSKH gọi lại.
// hoTro === null = chưa xác định (chưa có địa chỉ) -> vẫn cho chọn nhưng nhắc thêm địa chỉ.
const phamVi = ref(null);
const tanNoiBiChan = computed(() => phamVi.value?.hoTro === false);
const tenTinhPhucVu = computed(() =>
  (phamVi.value?.tinhPhucVu || []).map((t) => t.tenTinh).join(', '));

// Khách đang chọn tận nơi mà sau khi biết là ngoài vùng -> tự kéo về "mang tới cửa hàng" để
// không có lúc nào form ở trạng thái chắc chắn gửi lỗi.
watch(tanNoiBiChan, (chan) => {
  if (chan && form.hinhThuc === 'tan_noi') form.hinhThuc = 'cua_hang';
});

const ngayToiThieu = isoDate(new Date());

// Chỉ cho gửi yêu cầu với phiếu CÒN HẠN — phiếu hết hạn/vô hiệu thì bảo hành không áp dụng.
const warrantiesConHan = computed(() => warranties.value.filter(conHan));

// Chọn nhanh một phiếu (từ danh sách / modal) để điền sẵn vào form.
function chonPhieuChoForm(w) {
  form.warrantyId = w.id;
  formError.value = '';
  formOk.value = '';
  dongChiTiet();
  document.getElementById('bh-form')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

async function guiYeuCau() {
  formError.value = '';
  formOk.value = '';
  if (!form.warrantyId) {
    formError.value = 'Chọn mã bảo hành của sản phẩm cần yêu cầu.';
    return;
  }
  if (!form.issue.trim()) {
    formError.value = 'Mô tả chi tiết sự cố để kỹ thuật chuẩn bị trước.';
    return;
  }
  if (form.hinhThuc === 'cua_hang' && !form.centerId) {
    formError.value = 'Chọn cửa hàng để mang máy tới.';
    return;
  }

  sending.value = true;
  try {
    await submitWarrantyRequest(form.warrantyId, {
      issue: form.issue.trim(),
      ngayHen: form.ngayHen || null,
      hinhThuc: form.hinhThuc,
      centerId: form.hinhThuc === 'cua_hang' ? Number(form.centerId) : null,
    });
    formOk.value = 'Đã gửi yêu cầu bảo hành! CNTTShop sẽ liên hệ xác nhận sớm.';
    form.issue = '';
    form.ngayHen = '';
    actions.showToast('Đã gửi yêu cầu bảo hành');
    // Nếu đang mở chi tiết đúng phiếu này thì nạp lại để thấy yêu cầu vừa gửi.
    if (detail.value && detail.value.id === Number(form.warrantyId)) {
      detail.value = await fetchWarrantyDetail(form.warrantyId);
    }
  } catch (e) {
    formError.value = e?.message && !e.message.startsWith('HTTP') ? e.message : 'Gửi yêu cầu thất bại, thử lại.';
  } finally {
    sending.value = false;
  }
}

const tenCuaHang = (id) => centers.value.find((c) => c.id === Number(id))?.ten || '';

async function tai() {
  if (!state.user) {
    dangTai.value = false;
    return;
  }
  dangTai.value = true;
  try {
    const [ws, cs, appts, pv] = await Promise.all([
      fetchMyWarranties(),
      fetchServiceCenters().catch(() => []),
      fetchMyAppointments().catch(() => []),
      fetchPhamViTanNoi().catch(() => null),
    ]);
    warranties.value = ws;
    centers.value = cs;
    phamVi.value = pv;
    history.value = appts
      .filter((a) => a.trangThai === 'hoan_thanh')
      .sort((a, b) => String(b.ngayHen).localeCompare(String(a.ngayHen)));
  } catch (e) {
    warranties.value = [];
  } finally {
    dangTai.value = false;
  }
}

onMounted(tai);
</script>

<template>
  <main style="max-width: 1240px; margin: 0 auto; padding: 24px 24px 72px">
    <button class="sp-back" @click="actions.goAccount()">← Tài khoản</button>

    <div style="margin-bottom: 26px">
      <div class="sp-eyebrow">BẢO HÀNH CỦA TÔI</div>
      <h1 class="sp-h1">Quản lý bảo hành <span :style="{ color: accent }">cá nhân</span></h1>
      <p style="font-size: 14.5px; color: var(--muted2); max-width: 640px; line-height: 1.65; margin: 0">
        Xem phiếu bảo hành các sản phẩm đã mua, gửi yêu cầu bảo hành và tra lịch sử sửa chữa.
      </p>
    </div>

    <!-- Chưa đăng nhập -->
    <div v-if="!state.user" class="sp-card sp-empty">
      Bạn cần đăng nhập để quản lý bảo hành cá nhân.<br />
      <button class="sp-btn-acc" style="margin-top: 16px" @click="actions.openLogin()">Đăng nhập</button>
    </div>

    <div v-else style="display: grid; grid-template-columns: 380px 1fr; gap: 22px; align-items: start" class="bh-grid">
      <!-- ===== Sidebar trái: form yêu cầu bảo hành ===== -->
      <aside id="bh-form" class="sp-card" style="padding: 24px 24px; position: sticky; top: 100px">
        <h2 class="sp-h2" style="margin-bottom: 6px">Gửi yêu cầu bảo hành</h2>
        <p style="font-size: 12.3px; color: var(--muted); margin: 0 0 18px; line-height: 1.55">
          Chọn sản phẩm cần bảo hành và mô tả sự cố. Kỹ thuật sẽ liên hệ xác nhận lịch.
        </p>

        <div v-if="formError" class="sp-alert err">{{ formError }}</div>
        <div v-if="formOk" class="sp-alert ok">{{ formOk }}</div>

        <div style="display: flex; flex-direction: column; gap: 15px">
          <div>
            <label class="bh-label">Mã bảo hành *</label>
            <select v-model="form.warrantyId" class="sp-select">
              <option value="">— Chọn sản phẩm —</option>
              <option v-for="w in warrantiesConHan" :key="w.id" :value="w.id">
                {{ w.maBaoHanh }} — {{ w.productName }}
              </option>
            </select>
            <div v-if="!warrantiesConHan.length" style="font-size: 11.5px; color: var(--muted); margin-top: 6px">
              Bạn chưa có phiếu bảo hành nào còn hạn.
            </div>
          </div>

          <div>
            <label class="bh-label">Chi tiết sự cố *</label>
            <textarea
              v-model="form.issue"
              class="sp-textarea"
              rows="4"
              placeholder="vd: máy tự tắt nguồn khi dùng nặng, màn hình xuất hiện sọc dọc…"
            ></textarea>
          </div>

          <div>
            <label class="bh-label">Hẹn ngày bảo hành</label>
            <input v-model="form.ngayHen" type="date" class="sp-input" :min="ngayToiThieu" />
          </div>

          <div>
            <label class="bh-label">Hình thức</label>
            <div style="display: flex; flex-direction: column; gap: 9px">
              <label class="bh-radio" :class="{ on: form.hinhThuc === 'cua_hang' }">
                <input type="radio" value="cua_hang" v-model="form.hinhThuc" />
                <span>
                  <b>Đem đến cửa hàng gần nhất</b>
                  <small>Miễn phụ phí</small>
                </span>
              </label>
              <label
                class="bh-radio"
                :class="{ on: form.hinhThuc === 'tan_noi', off: tanNoiBiChan }"
                :title="tanNoiBiChan ? 'Khu vực của bạn chưa có chi nhánh' : ''"
              >
                <input type="radio" value="tan_noi" v-model="form.hinhThuc" :disabled="tanNoiBiChan" />
                <span>
                  <b>Bảo hành tận nơi</b>
                  <small v-if="tanNoiBiChan">Chưa phục vụ khu vực của bạn</small>
                  <small v-else>Phụ phí {{ fmt(PHU_PHI_TAN_NOI) }}</small>
                </span>
              </label>
            </div>
          </div>

          <!-- Dropdown cửa hàng: chỉ khi mang tới cửa hàng -->
          <div v-if="form.hinhThuc === 'cua_hang'">
            <label class="bh-label">Chọn cửa hàng *</label>
            <select v-model="form.centerId" class="sp-select">
              <option value="">— Chọn cửa hàng —</option>
              <option v-for="c in centers" :key="c.id" :value="c.id">{{ c.ten }}</option>
            </select>
            <!-- Xem trước dạng tối giản của cửa hàng đã chọn: tên + địa chỉ + giờ làm việc -->
            <div
              v-if="form.centerId"
              style="
                margin-top: 10px;
                background: var(--card2);
                border-radius: 10px;
                padding: 12px 14px;
                font-size: 12.3px;
                line-height: 1.55;
              "
            >
              <template v-for="c in centers" :key="c.id">
                <template v-if="c.id === Number(form.centerId)">
                  <div style="font-weight: 700; color: var(--text)">{{ c.ten }}</div>
                  <div style="color: var(--muted2); margin-top: 3px">📍 {{ c.diaChi }}</div>
                  <div v-if="c.gioMoCua" style="color: var(--muted); margin-top: 3px">🕐 {{ c.gioMoCua }}</div>
                </template>
              </template>
            </div>
          </div>

          <!-- Ngoài vùng: nói rõ vì sao + phục vụ ở đâu + làm gì thay thế, thay vì chỉ khoá nút -->
          <div v-if="tanNoiBiChan" class="sp-alert warn" style="margin: 0">
            Địa chỉ của bạn<template v-if="phamVi?.tenTinhCuaToi"> ({{ phamVi.tenTinhCuaToi }})</template>
            nằm ngoài phạm vi phục vụ tận nơi — kỹ thuật viên xuất phát từ chi nhánh nên shop chỉ
            tới tận nơi trong<template v-if="tenTinhPhucVu"> {{ tenTinhPhucVu }}</template>.
            Bạn có thể mang máy tới cửa hàng gần nhất, hoặc gửi máy về trung tâm bảo hành — gọi
            <a href="tel:0835344974" style="color: inherit; font-weight: 700">0835 344 974</a>
            để được hướng dẫn đóng gói và cước gửi.
          </div>

          <!-- Chưa có địa chỉ nào gắn Tỉnh -> chưa kết luận được, nhắc khách bổ sung trước -->
          <div v-else-if="form.hinhThuc === 'tan_noi' && phamVi && phamVi.hoTro === null" class="sp-alert info" style="margin: 0">
            Shop chưa biết bạn ở đâu để cử kỹ thuật viên. Vui lòng thêm địa chỉ trong mục
            <b>Tài khoản</b> trước khi gửi yêu cầu tận nơi.
            <template v-if="tenTinhPhucVu"> Hiện shop phục vụ tận nơi tại: {{ tenTinhPhucVu }}.</template>
          </div>

          <div v-else-if="form.hinhThuc === 'tan_noi'" class="sp-alert info" style="margin: 0">
            Bảo hành tận nơi áp dụng phụ phí {{ fmt(PHU_PHI_TAN_NOI) }} cho chi phí đi lại. Kỹ thuật
            sẽ gọi xác nhận địa chỉ và thời gian.
          </div>

          <button class="sp-btn-acc" style="height: 46px" :disabled="sending" @click="guiYeuCau">
            {{ sending ? 'Đang gửi…' : 'Gửi yêu cầu bảo hành →' }}
          </button>
        </div>
      </aside>

      <!-- ===== Main phải ===== -->
      <div style="display: flex; flex-direction: column; gap: 30px">
        <!-- Sản phẩm & bảo hành (dạng tối giản, bấm để xem chi tiết) -->
        <section>
          <h2 class="sp-h2">Sản phẩm &amp; bảo hành</h2>

          <div v-if="dangTai" class="sp-card sp-empty">Đang tải…</div>
          <div v-else-if="!warranties.length" class="sp-card sp-empty">
            Bạn chưa có phiếu bảo hành nào. Phiếu được tạo tự động khi đơn hàng giao thành công.
          </div>

          <div v-else style="display: flex; flex-direction: column; gap: 10px">
            <button
              v-for="w in warranties"
              :key="w.id"
              class="bh-item"
              @click="moChiTiet(w)"
            >
              <div style="min-width: 0; flex: 1; text-align: left">
                <div style="font-size: 14px; font-weight: 600; color: var(--text)">{{ w.productName }}</div>
                <div style="font-size: 12px; color: var(--muted); margin-top: 4px">
                  Mã: <span :style="{ color: accent }" style="font-weight: 600">{{ w.maBaoHanh }}</span>
                  · đến {{ ngayVN(w.endDate) }}
                </div>
              </div>
              <div style="display: flex; align-items: center; gap: 10px; flex: none">
                <span
                  v-if="conHan(w)"
                  style="font-size: 11px; color: var(--muted)"
                >còn {{ soNgayConLai(w) }} ngày</span>
                <span class="sp-pill" :style="{ color: wStatusColors[w.status] || 'var(--muted)' }">
                  {{ wStatusLabels[w.status] || w.status }}
                </span>
                <span style="color: var(--muted); font-size: 13px">›</span>
              </div>
            </button>
          </div>
        </section>

        <!-- Lịch sử bảo hành (chuyển từ trang Tình trạng sửa chữa sang) -->
        <section>
          <h2 class="sp-h2">Lịch sử bảo hành</h2>
          <div v-if="!history.length" class="sp-card sp-empty" style="padding: 34px 20px">
            Chưa có lần sửa chữa / bảo hành nào hoàn thành.
          </div>
          <div v-else class="sp-card" style="overflow: hidden">
            <div style="overflow-x: auto">
              <table class="bh-history">
                <thead>
                  <tr>
                    <th style="min-width: 220px">Thiết bị đã bảo hành</th>
                    <th style="width: 150px">Ngày bảo hành</th>
                    <th style="width: 150px; text-align: right">Chi phí</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="l in history" :key="l.id">
                    <td>
                      <div style="font-weight: 600; color: var(--text)">
                        {{ tenLoaiThietBi(l.loaiThietBi) }}<template v-if="l.model"> · {{ l.model }}</template>
                      </div>
                      <div style="font-size: 11.8px; color: var(--muted); margin-top: 3px">
                        {{ l.tenTrungTam }} · {{ l.maLich }}
                      </div>
                    </td>
                    <td style="color: var(--muted2)">{{ ngayVN(l.ngayHen) }}</td>
                    <td style="text-align: right; font-weight: 700; color: var(--text)">
                      <template v-if="l.chiPhi != null && Number(l.chiPhi) > 0">{{ fmt(l.chiPhi) }}</template>
                      <span v-else style="color: var(--green); font-weight: 600">Miễn phí</span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </section>
      </div>
    </div>

    <!-- ===== Modal chi tiết phiếu ===== -->
    <div v-if="detail || detailLoading" class="bh-backdrop" @click.self="dongChiTiet">
      <div class="bh-modal sp-card">
        <div v-if="detailLoading" class="sp-empty">Đang tải…</div>
        <template v-else-if="detail">
          <div class="bh-modal-head">
            <div>
              <div class="sp-eyebrow" style="margin-bottom: 6px">CHI TIẾT BẢO HÀNH</div>
              <div style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 17px; color: var(--text)">
                {{ detail.productName }}
              </div>
            </div>
            <button class="bh-close" @click="dongChiTiet">✕</button>
          </div>

          <div class="bh-modal-body">
            <div class="bh-kv-grid">
              <div class="bh-kv">
                <span>Mã bảo hành</span>
                <b :style="{ color: accent }">{{ detail.maBaoHanh }}</b>
              </div>
              <div class="bh-kv"><span>Trạng thái</span>
                <b :style="{ color: wStatusColors[detail.status] || 'var(--muted)' }">
                  {{ wStatusLabels[detail.status] || detail.status }}
                </b>
              </div>
              <div class="bh-kv"><span>Đơn hàng</span><b>{{ detail.orderCode }}</b></div>
              <div class="bh-kv"><span>Serial</span><b>{{ detail.serialNumber || '—' }}</b></div>
              <div class="bh-kv"><span>Bắt đầu</span><b>{{ ngayVN(detail.startDate) }}</b></div>
              <div class="bh-kv"><span>Hết hạn</span><b>{{ ngayVN(detail.endDate) }}</b></div>
            </div>

            <button class="sp-btn-acc" style="width: 100%; margin: 18px 0 6px" @click="chonPhieuChoForm(detail)">
              Tạo yêu cầu bảo hành cho sản phẩm này →
            </button>

            <div style="font-size: 12.5px; font-weight: 700; color: var(--text); margin: 18px 0 10px">
              Yêu cầu đã gửi ({{ detail.requests.length }})
            </div>
            <div v-if="!detail.requests.length" style="font-size: 12.5px; color: var(--muted)">
              Chưa có yêu cầu bảo hành nào cho sản phẩm này.
            </div>
            <div
              v-for="r in detail.requests"
              :key="r.id"
              style="border: 1px solid rgba(var(--line-rgb), 0.14); border-radius: 11px; padding: 13px 15px; margin-bottom: 10px"
            >
              <div style="display: flex; align-items: flex-start; justify-content: space-between; gap: 10px">
                <span style="font-size: 13px; color: var(--text); line-height: 1.5">{{ r.issueDescription }}</span>
                <span class="sp-pill" :style="{ color: wReqColors[r.requestStatus] || 'var(--muted)' }" style="flex: none">
                  {{ wReqLabels[r.requestStatus] || r.requestStatus }}
                </span>
              </div>
              <div style="display: flex; gap: 14px; flex-wrap: wrap; font-size: 11.5px; color: var(--muted); margin-top: 8px">
                <span>Gửi {{ ngayVN(r.createdAt) }}</span>
                <span v-if="r.ngayHen">Hẹn {{ ngayVN(r.ngayHen) }}</span>
                <span v-if="r.hinhThuc === 'tan_noi'">Tận nơi · phụ phí {{ fmt(r.phuPhi) }}</span>
                <span v-else-if="r.hinhThuc === 'cua_hang'">Tại {{ r.centerName || 'cửa hàng' }}</span>
              </div>
            </div>
          </div>
        </template>
      </div>
    </div>
  </main>
</template>

<style scoped>
.bh-label {
  display: block;
  font-size: 11.8px;
  color: var(--muted);
  margin-bottom: 6px;
  font-weight: 500;
}

.bh-item {
  display: flex;
  align-items: center;
  gap: 14px;
  width: 100%;
  background: var(--card);
  border: 1px solid rgba(var(--line-rgb), 0.14);
  border-radius: 14px;
  padding: 16px 18px;
  cursor: pointer;
  font-family: 'Plus Jakarta Sans', sans-serif;
  transition: border-color 0.15s, transform 0.15s;
}
.bh-item:hover {
  border-color: var(--acc, #c6ff4a);
  transform: translateY(-1px);
}

.bh-radio {
  display: flex;
  align-items: center;
  gap: 11px;
  padding: 12px 14px;
  border: 1px solid rgba(var(--line-rgb), 0.2);
  border-radius: 11px;
  cursor: pointer;
  transition: border-color 0.15s, background 0.15s;
}
.bh-radio.on {
  border-color: var(--acc, #c6ff4a);
  background: color-mix(in srgb, var(--acc, #c6ff4a) 8%, transparent);
}
/* Hình thức không khả dụng (VD tận nơi ngoài vùng phục vụ) — vẫn thấy được để khách biết là có
   dịch vụ đó, nhưng rõ ràng là không chọn được. */
.bh-radio.off {
  opacity: 0.55;
  cursor: not-allowed;
}
.bh-radio input {
  accent-color: var(--acc, #c6ff4a);
  flex: none;
}
.bh-radio span {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.bh-radio b {
  font-size: 13px;
  color: var(--text);
  font-weight: 600;
}
.bh-radio small {
  font-size: 11.5px;
  color: var(--muted);
}

.bh-history {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.bh-history th {
  text-align: left;
  padding: 13px 16px;
  font-family: 'Chakra Petch', sans-serif;
  font-size: 11.3px;
  letter-spacing: 0.5px;
  color: var(--muted);
  font-weight: 600;
  background: var(--card2);
  border-bottom: 1px solid rgba(var(--line-rgb), 0.12);
  white-space: nowrap;
}
.bh-history td {
  padding: 13px 16px;
  border-bottom: 1px solid rgba(var(--line-rgb), 0.08);
  vertical-align: top;
}
.bh-history tbody tr:last-child td {
  border-bottom: none;
}
.bh-history tbody tr:hover {
  background: var(--card2);
}

.bh-backdrop {
  position: fixed;
  inset: 0;
  z-index: 3000;
  background: rgba(0, 0, 0, 0.62);
  backdrop-filter: blur(3px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}
.bh-modal {
  width: 100%;
  max-width: 560px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.bh-modal-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 14px;
  padding: 22px 26px 16px;
  border-bottom: 1px solid rgba(var(--line-rgb), 0.12);
}
.bh-close {
  background: transparent;
  border: none;
  color: var(--muted);
  font-size: 17px;
  cursor: pointer;
  padding: 4px 8px;
  line-height: 1;
}
.bh-close:hover {
  color: var(--text);
}
.bh-modal-body {
  padding: 20px 26px 24px;
  overflow-y: auto;
}
.bh-kv-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px 18px;
}
.bh-kv span {
  display: block;
  font-size: 11.3px;
  color: var(--muted);
  margin-bottom: 4px;
}
.bh-kv b {
  font-size: 13.5px;
  color: var(--text);
  font-weight: 700;
}

@media (max-width: 900px) {
  .bh-grid {
    grid-template-columns: 1fr !important;
  }
  #bh-form {
    position: static !important;
  }
}
</style>
