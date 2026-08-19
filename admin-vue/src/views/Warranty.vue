<template>
  <div style="animation: fadeUp 0.35s ease">
    <!-- Tabs chính -->
    <div style="display: flex; gap: 8px; margin-bottom: 16px">
      <button
        v-for="t in mainTabs"
        :key="t.key"
        @click="mainTab = t.key; detail = null; requestDetail = null"
        style="padding: 9px 16px; border-radius: 9px; font-size: 13px; font-weight: 600; cursor: pointer"
        :style="{
          border: '1px solid ' + (mainTab === t.key ? 'var(--acc)' : 'var(--line2)'),
          background: mainTab === t.key ? 'var(--acc)' : 'var(--card)',
          color: mainTab === t.key ? 'var(--acc-ink)' : 'var(--muted2)',
        }"
      >
        {{ t.label }}
      </button>
    </div>

    <!-- ===== TAB 1: PHIẾU BẢO HÀNH ===== -->
    <template v-if="mainTab === 'warranties'">
      <div v-if="detail" style="animation: fadeUp 0.3s ease">
        <button @click="detail = null" style="display: inline-flex; align-items: center; gap: 7px; background: none; border: none; color: var(--muted2); font-size: 13px; cursor: pointer; margin-bottom: 16px; font-weight: 500">
          <i class="bi bi-arrow-left"></i> Quay lại danh sách
        </button>
        <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 20px; margin-bottom: 14px">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px">
            <div>
              <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap">
                <div style="font-size: 16px; font-weight: 700; color: var(--text)">{{ detail.productName }}</div>
                <span v-if="detail.maBaoHanh" class="badge" style="background: color-mix(in srgb, var(--acc) 16%, transparent); color: var(--acc); font-family: monospace">{{ detail.maBaoHanh }}</span>
                <button v-if="detail.maBaoHanh" class="btn-copy" @click="saoChepMa(detail.maBaoHanh)" title="Sao chép mã bảo hành">
                  <i :class="copiedMa === detail.maBaoHanh ? 'bi bi-check2' : 'bi bi-clipboard'"></i>
                </button>
              </div>
              <div style="font-size: 12px; color: var(--muted); margin-top: 3px">Đơn {{ detail.orderCode }} · {{ detail.customerName }} ({{ detail.customerEmail }})</div>
            </div>
            <select class="fld" v-model="statusDraft" style="width: 160px">
              <option value="active">Còn hạn</option>
              <option value="expired">Hết hạn</option>
              <option value="void">Vô hiệu</option>
            </select>
          </div>
          <div style="font-size: 12.5px; color: var(--muted2); margin-bottom: 14px">
            Hiệu lực: {{ fmtDate(detail.startDate) }} → {{ fmtDate(detail.endDate) }}
            <span v-if="detail.serialNumber"> · Serial: {{ detail.serialNumber }}</span>
          </div>
          <button class="btn-acc" style="width: auto; padding: 0 18px; height: 38px" :disabled="saving" @click="saveWarrantyStatus">
            {{ saving ? 'Đang lưu...' : 'Lưu trạng thái' }}
          </button>
        </div>

        <div style="font-size: 13px; font-weight: 600; color: var(--text); margin: 18px 0 10px">
          Yêu cầu xử lý ({{ detail.requests.length }})
        </div>
        <div v-if="!detail.requests.length" style="color: var(--muted); font-size: 13px">Chưa có yêu cầu nào.</div>
        <div
          v-for="r in detail.requests"
          :key="r.id"
          @click="openRequestDetail(r.id)"
          style="background: var(--card); border: 1px solid var(--line); border-radius: 12px; padding: 14px 16px; margin-bottom: 8px; cursor: pointer"
        >
          <div style="display: flex; justify-content: space-between">
            <span style="font-size: 13px; color: var(--text)">{{ r.issueDescription }}</span>
            <span class="badge" :style="reqStatusStyle(r.requestStatus)">{{ reqStatusLabel(r.requestStatus) }}</span>
          </div>
          <div style="font-size: 11.5px; color: var(--muted); margin-top: 4px">{{ fmtDateTime(r.createdAt) }}</div>
        </div>
      </div>

      <div v-else>
        <div style="display: flex; align-items: center; gap: 8px; padding: 4px 0 14px">
          <button v-for="s in warrantyFilters" :key="s.key" @click="warrantyStatus = s.key; loadWarranties()"
            style="padding: 7px 13px; border-radius: 9px; font-size: 12.5px; font-weight: 600; cursor: pointer"
            :style="{ border: '1px solid ' + (warrantyStatus === s.key ? 'var(--acc)' : 'var(--line2)'), background: warrantyStatus === s.key ? 'var(--acc)' : 'var(--card)', color: warrantyStatus === s.key ? 'var(--acc-ink)' : 'var(--muted2)' }">
            {{ s.label }}
          </button>
        </div>
        <div v-if="loadingList" class="spin"></div>
        <div v-else style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; overflow: hidden">
          <DataTable
            :columns="warrantyCols"
            :rows="warranties"
            :tim-kiem="ui.search"
            click-duoc
            trong="Chưa có phiếu bảo hành nào."
            @row-click="(w) => openWarrantyDetail(w.id)"
          >
            <template #o-maBaoHanh="{ row: w }">
              <span style="color: var(--acc); font-family: monospace; font-size: 12px">{{ w.maBaoHanh }}</span>
            </template>
            <template #o-customerName="{ row: w }">
              <span style="color: var(--muted2); font-size: 12px">{{ w.customerName }}</span>
            </template>
            <template #o-hieuLuc="{ row: w }">
              <span style="color: var(--muted2); font-size: 12px">{{ fmtDate(w.startDate) }} → {{ fmtDate(w.endDate) }}</span>
            </template>
            <template #o-status="{ row: w }">
              <span class="badge" :style="warrantyStatusStyle(w.status)">{{ warrantyStatusLabel(w.status) }}</span>
            </template>
          </DataTable>
        </div>
      </div>
    </template>

    <!-- ===== TAB 2: YÊU CẦU BẢO HÀNH ===== -->
    <template v-else>
      <div v-if="requestDetail" style="animation: fadeUp 0.3s ease">
        <button @click="requestDetail = null" style="display: inline-flex; align-items: center; gap: 7px; background: none; border: none; color: var(--muted2); font-size: 13px; cursor: pointer; margin-bottom: 16px; font-weight: 500">
          <i class="bi bi-arrow-left"></i> Quay lại danh sách
        </button>
        <div style="display: grid; grid-template-columns: 1.6fr 1fr; gap: 14px">
          <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 20px">
            <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-bottom: 6px">
              <div style="font-size: 15px; font-weight: 700; color: var(--text)">{{ requestDetail.productName }}</div>
              <span v-if="requestDetail.maBaoHanh" class="badge" style="background: color-mix(in srgb, var(--acc) 16%, transparent); color: var(--acc); font-family: monospace">{{ requestDetail.maBaoHanh }}</span>
              <button v-if="requestDetail.maBaoHanh" class="btn-copy" @click="saoChepMa(requestDetail.maBaoHanh)" title="Sao chép mã bảo hành">
                <i :class="copiedMa === requestDetail.maBaoHanh ? 'bi bi-check2' : 'bi bi-clipboard'"></i>
              </button>
            </div>
            <div style="font-size: 12px; color: var(--muted); margin-bottom: 14px">{{ requestDetail.customerName }} ({{ requestDetail.customerEmail }}) · {{ fmtDateTime(requestDetail.createdAt) }}</div>
            <div style="background: var(--card2); border-radius: 10px; padding: 14px; font-size: 13px; color: var(--text); margin-bottom: 16px; white-space: pre-wrap">
              {{ requestDetail.issueDescription }}
            </div>
            <!-- Lịch hẹn khách chọn khi gửi yêu cầu (trang Quản lý bảo hành cá nhân) -->
            <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 16px">
              <span v-if="requestDetail.ngayHen" class="badge" style="background: var(--card2); color: var(--muted2)">
                <i class="bi bi-calendar-event" style="margin-right: 5px"></i>Hẹn {{ fmtDate(requestDetail.ngayHen) }}
              </span>
              <span v-if="requestDetail.hinhThuc === 'tan_noi'" class="badge" style="background: color-mix(in srgb, var(--warn, #f5a524) 16%, transparent); color: var(--warn, #f5a524)">
                Tận nơi · phụ phí {{ fmtTien(requestDetail.phuPhi) }}
              </span>
              <span v-else-if="requestDetail.hinhThuc === 'cua_hang'" class="badge" style="background: var(--card2); color: var(--muted2)">
                <i class="bi bi-shop" style="margin-right: 5px"></i>{{ requestDetail.centerName || 'Mang tới cửa hàng' }}
              </span>
            </div>
            <div style="font-size: 12px; font-weight: 600; color: var(--muted2); margin-bottom: 8px">Lịch sử xử lý</div>
            <div v-for="(h, i) in requestDetail.history" :key="i" style="display: flex; gap: 10px; padding: 8px 0; border-top: 1px solid var(--line)">
              <span class="badge" :style="reqStatusStyle(h.status)">{{ reqStatusLabel(h.status) }}</span>
              <span style="font-size: 12.5px; color: var(--muted2); flex: 1">{{ h.note }}</span>
              <span style="font-size: 11px; color: var(--muted)">{{ fmtDateTime(h.createdAt) }}</span>
            </div>
          </div>
          <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 18px">
            <div style="font-size: 13px; font-weight: 600; color: var(--text); margin-bottom: 12px">Cập nhật xử lý</div>
            <select class="fld" v-model="reqStatusDraft" style="margin-bottom: 10px">
              <option value="pending">Chờ tiếp nhận</option>
              <option value="accepted">Đã tiếp nhận</option>
              <option value="processing">Đang xử lý</option>
              <option value="resolved">Đã hoàn thành</option>
              <option value="rejected">Từ chối</option>
              <option value="no_show">Khách không đến</option>
            </select>
            <textarea class="fld" v-model="reqNoteDraft" rows="3" style="padding: 10px 14px; margin-bottom: 10px" placeholder="Ghi chú xử lý..."></textarea>
            <button class="btn-acc" style="height: 42px" :disabled="saving" @click="saveRequestStatus">
              {{ saving ? 'Đang lưu...' : 'Lưu & gửi email khách' }}
            </button>

            <div style="border-top: 1px solid var(--line); margin: 18px 0 14px"></div>
            <div style="font-size: 13px; font-weight: 600; color: var(--text); margin-bottom: 4px">Đổi lịch hẹn</div>
            <div style="font-size: 11px; color: var(--muted); margin-bottom: 10px">
              Hình thức bảo hành &amp; cửa hàng là lựa chọn của khách, admin chỉ đổi được ngày hẹn khi khách gọi điện xin dời lịch.
            </div>
            <label style="display: block; font-size: 11.5px; color: var(--muted); margin-bottom: 5px">Ngày hẹn</label>
            <input type="date" class="fld" v-model="schedNgayHen" style="margin-bottom: 10px" />
            <button class="btn-acc" style="height: 42px; background: var(--card2); color: var(--text); border: 1px solid var(--line2)" :disabled="savingSched" @click="saveRequestSchedule">
              {{ savingSched ? 'Đang lưu...' : 'Lưu ngày hẹn' }}
            </button>
          </div>
        </div>
      </div>

      <div v-else>
        <div v-if="loadingList" class="spin"></div>
        <div v-else style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; overflow: hidden">
          <DataTable
            :columns="reqCols"
            :rows="requests"
            :tim-kiem="ui.search"
            click-duoc
            trong="Chưa có yêu cầu bảo hành nào."
            @row-click="(r) => openRequestDetail(r.id)"
          >
            <template #o-customerName="{ row: r }">
              <span style="color: var(--muted2); font-size: 12px">{{ r.customerName }}</span>
            </template>
            <template #o-issueDescription="{ row: r }">
              <span style="color: var(--muted2); font-size: 12px; display: block; max-width: 280px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap">{{ r.issueDescription }}</span>
            </template>
            <template #o-requestStatus="{ row: r }">
              <span class="badge" :style="reqStatusStyle(r.requestStatus)">{{ reqStatusLabel(r.requestStatus) }}</span>
              <span v-if="laQuaHen(r)" class="badge" style="background: color-mix(in srgb, var(--sale) 16%, transparent); color: var(--sale); margin-left: 6px">
                <i class="bi bi-exclamation-triangle-fill" style="margin-right: 4px"></i>Quá hẹn
              </span>
            </template>
          </DataTable>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import {
  getAdminWarranties, getAdminWarrantyDetail, updateWarrantyStatus,
  getAdminWarrantyRequests, getAdminWarrantyRequestDetail, updateWarrantyRequestStatus,
  updateWarrantyRequestSchedule,
} from '../api/admin';
import { ui } from '../uiState';
import DataTable from '../components/DataTable.vue';

// Cột cho DataTable — phễu lọc/sắp xếp kiểu Excel trên từng cột (xem components/DataTable.vue).
const warrantyCols = [
  { key: 'maBaoHanh', label: 'Mã BH' },
  { key: 'productName', label: 'Sản phẩm' },
  { key: 'customerName', label: 'Khách hàng' },
  { key: 'hieuLuc', label: 'Hiệu lực', kieu: 'ngay', value: (w) => w.endDate,
    text: (w) => fmtDate(w.startDate) + ' → ' + fmtDate(w.endDate) },
  { key: 'status', label: 'Trạng thái', text: (w) => warrantyStatusLabel(w.status) },
];
const reqCols = [
  { key: 'productName', label: 'Sản phẩm' },
  { key: 'customerName', label: 'Khách hàng' },
  { key: 'issueDescription', label: 'Mô tả' },
  { key: 'requestStatus', label: 'Trạng thái', text: (r) => reqStatusLabel(r.requestStatus) },
];

const mainTabs = [
  { key: 'warranties', label: 'Phiếu bảo hành' },
  { key: 'requests', label: 'Yêu cầu xử lý' },
];
const mainTab = ref('warranties');

const warrantyFilters = [
  { key: '', label: 'Tất cả' },
  { key: 'active', label: 'Còn hạn' },
  { key: 'expired', label: 'Hết hạn' },
  { key: 'void', label: 'Vô hiệu' },
];
const warrantyStatus = ref('');
const warranties = ref([]);
const requests = ref([]);
const detail = ref(null);
const requestDetail = ref(null);
const statusDraft = ref('active');
const reqStatusDraft = ref('pending');
const reqNoteDraft = ref('');
const loadingList = ref(true);
const saving = ref(false);

// ===== Đổi ngày hẹn (chỉ ngày hẹn — hình thức/cửa hàng là lựa chọn của khách) =====
const schedNgayHen = ref('');
const savingSched = ref(false);

// ===== Sao chép mã bảo hành =====
const copiedMa = ref('');
async function saoChepMa(ma) {
  try {
    await navigator.clipboard.writeText(ma);
  } catch (e) {
    // Fallback cho trình duyệt/context không hỗ trợ Clipboard API (vd: http không secure)
    const ta = document.createElement('textarea');
    ta.value = ma;
    ta.style.position = 'fixed';
    ta.style.opacity = '0';
    document.body.appendChild(ta);
    ta.select();
    document.execCommand('copy');
    document.body.removeChild(ta);
  }
  copiedMa.value = ma;
  setTimeout(() => { if (copiedMa.value === ma) copiedMa.value = ''; }, 1500);
}

const reqLabels = { pending: 'Chờ tiếp nhận', accepted: 'Đã tiếp nhận', processing: 'Đang xử lý', resolved: 'Đã hoàn thành', rejected: 'Từ chối', no_show: 'Khách không đến' };
const reqColors = { pending: 'var(--amber)', accepted: 'var(--acc)', processing: '#a855f7', resolved: 'var(--green)', rejected: 'var(--sale)', no_show: 'var(--sale)' };
function reqStatusLabel(s) { return reqLabels[s] || s; }
function reqStatusStyle(s) {
  const c = reqColors[s] || 'var(--muted)';
  return { background: 'color-mix(in srgb,' + c + ' 16%, transparent)', color: c, fontSize: '11px', fontWeight: '600', padding: '3px 9px', borderRadius: '20px' };
}
/** Cảnh báo tức thời trên danh sách khi đã qua ngày hẹn mà chưa xử lý — job nền lúc 7h sáng mới
 * tự động chuyển sang "no_show", nên giữa lúc đó vẫn cần admin nhìn thấy ngay để chủ động gọi khách. */
function laQuaHen(r) {
  if (!r.ngayHen || !['pending', 'accepted'].includes(r.requestStatus)) return false;
  return new Date(r.ngayHen + 'T00:00:00') < new Date(new Date().toDateString());
}

const wLabels = { active: 'Còn hạn', expired: 'Hết hạn', void: 'Vô hiệu' };
const wColors = { active: 'var(--green)', expired: 'var(--muted)', void: 'var(--sale)' };
function warrantyStatusLabel(s) { return wLabels[s] || s; }
function warrantyStatusStyle(s) {
  const c = wColors[s] || 'var(--muted)';
  return { background: 'color-mix(in srgb,' + c + ' 16%, transparent)', color: c, fontSize: '11px', fontWeight: '600', padding: '3px 9px', borderRadius: '20px' };
}

function fmtDate(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  return `${String(d.getDate()).padStart(2, '0')}/${String(d.getMonth() + 1).padStart(2, '0')}/${d.getFullYear()}`;
}
function fmtDateTime(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  return `${fmtDate(iso)} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
}
const fmtTien = (n) => (n == null ? '—' : Number(n).toLocaleString('vi-VN') + 'đ');

async function loadWarranties() {
  loadingList.value = true;
  try {
    warranties.value = await getAdminWarranties(warrantyStatus.value || undefined);
  } finally {
    loadingList.value = false;
  }
}
async function loadRequests() {
  loadingList.value = true;
  try {
    requests.value = await getAdminWarrantyRequests();
  } finally {
    loadingList.value = false;
  }
}

async function openWarrantyDetail(id) {
  detail.value = await getAdminWarrantyDetail(id);
  statusDraft.value = detail.value.status;
}
async function saveWarrantyStatus() {
  saving.value = true;
  try {
    detail.value = await updateWarrantyStatus(detail.value.id, statusDraft.value);
    await loadWarranties();
  } finally {
    saving.value = false;
  }
}

async function openRequestDetail(id) {
  requestDetail.value = await getAdminWarrantyRequestDetail(id);
  reqStatusDraft.value = requestDetail.value.requestStatus;
  reqNoteDraft.value = '';
  schedNgayHen.value = requestDetail.value.ngayHen || '';
}
async function saveRequestStatus() {
  saving.value = true;
  try {
    requestDetail.value = await updateWarrantyRequestStatus(requestDetail.value.id, reqStatusDraft.value, reqNoteDraft.value);
    await loadRequests();
  } finally {
    saving.value = false;
  }
}

async function saveRequestSchedule() {
  savingSched.value = true;
  try {
    requestDetail.value = await updateWarrantyRequestSchedule(requestDetail.value.id, schedNgayHen.value || null);
    await loadRequests();
  } finally {
    savingSched.value = false;
  }
}

onMounted(() => {
  loadWarranties();
  loadRequests();
});
</script>

<style scoped>
.badge {
  display: inline-flex;
  align-items: center;
}
.btn-copy {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 26px;
  height: 26px;
  border-radius: 7px;
  border: 1px solid var(--line2);
  background: var(--card);
  color: var(--muted2);
  cursor: pointer;
  font-size: 12px;
}
.btn-copy:hover {
  border-color: var(--acc);
  color: var(--acc);
}
</style>
