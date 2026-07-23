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
              <div style="font-size: 16px; font-weight: 700; color: var(--text)">{{ detail.productName }}</div>
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
          <table style="width: 100%; border-collapse: collapse; font-size: 13px">
            <thead>
              <tr style="background: var(--card2)">
                <th style="text-align:left;padding:10px 16px;font-size:11px;font-weight:600;color:var(--muted);text-transform:uppercase">Sản phẩm</th>
                <th style="text-align:left;padding:10px 12px;font-size:11px;font-weight:600;color:var(--muted);text-transform:uppercase">Khách hàng</th>
                <th style="text-align:left;padding:10px 12px;font-size:11px;font-weight:600;color:var(--muted);text-transform:uppercase">Hiệu lực</th>
                <th style="text-align:left;padding:10px 16px;font-size:11px;font-weight:600;color:var(--muted);text-transform:uppercase">Trạng thái</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="w in warranties" :key="w.id" @click="openWarrantyDetail(w.id)" style="border-top: 1px solid var(--line); cursor: pointer">
                <td style="padding: 11px 16px; color: var(--text)">{{ w.productName }}</td>
                <td style="padding: 11px 12px; color: var(--muted2); font-size: 12px">{{ w.customerName }}</td>
                <td style="padding: 11px 12px; color: var(--muted2); font-size: 12px">{{ fmtDate(w.startDate) }} → {{ fmtDate(w.endDate) }}</td>
                <td style="padding: 11px 16px"><span class="badge" :style="warrantyStatusStyle(w.status)">{{ warrantyStatusLabel(w.status) }}</span></td>
              </tr>
            </tbody>
          </table>
          <div v-if="!warranties.length" style="padding: 30px; text-align: center; color: var(--muted); font-size: 13px">Chưa có phiếu bảo hành nào.</div>
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
            <div style="font-size: 15px; font-weight: 700; color: var(--text); margin-bottom: 6px">{{ requestDetail.productName }}</div>
            <div style="font-size: 12px; color: var(--muted); margin-bottom: 14px">{{ requestDetail.customerName }} ({{ requestDetail.customerEmail }}) · {{ fmtDateTime(requestDetail.createdAt) }}</div>
            <div style="background: var(--card2); border-radius: 10px; padding: 14px; font-size: 13px; color: var(--text); margin-bottom: 16px; white-space: pre-wrap">
              {{ requestDetail.issueDescription }}
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
            </select>
            <textarea class="fld" v-model="reqNoteDraft" rows="3" style="padding: 10px 14px; margin-bottom: 10px" placeholder="Ghi chú xử lý..."></textarea>
            <button class="btn-acc" style="height: 42px" :disabled="saving" @click="saveRequestStatus">
              {{ saving ? 'Đang lưu...' : 'Lưu & gửi email khách' }}
            </button>
          </div>
        </div>
      </div>

      <div v-else>
        <div v-if="loadingList" class="spin"></div>
        <div v-else style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; overflow: hidden">
          <table style="width: 100%; border-collapse: collapse; font-size: 13px">
            <thead>
              <tr style="background: var(--card2)">
                <th style="text-align:left;padding:10px 16px;font-size:11px;font-weight:600;color:var(--muted);text-transform:uppercase">Sản phẩm</th>
                <th style="text-align:left;padding:10px 12px;font-size:11px;font-weight:600;color:var(--muted);text-transform:uppercase">Khách hàng</th>
                <th style="text-align:left;padding:10px 12px;font-size:11px;font-weight:600;color:var(--muted);text-transform:uppercase">Mô tả</th>
                <th style="text-align:left;padding:10px 16px;font-size:11px;font-weight:600;color:var(--muted);text-transform:uppercase">Trạng thái</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="r in requests" :key="r.id" @click="openRequestDetail(r.id)" style="border-top: 1px solid var(--line); cursor: pointer">
                <td style="padding: 11px 16px; color: var(--text)">{{ r.productName }}</td>
                <td style="padding: 11px 12px; color: var(--muted2); font-size: 12px">{{ r.customerName }}</td>
                <td style="padding: 11px 12px; color: var(--muted2); font-size: 12px; max-width: 280px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap">{{ r.issueDescription }}</td>
                <td style="padding: 11px 16px"><span class="badge" :style="reqStatusStyle(r.requestStatus)">{{ reqStatusLabel(r.requestStatus) }}</span></td>
              </tr>
            </tbody>
          </table>
          <div v-if="!requests.length" style="padding: 30px; text-align: center; color: var(--muted); font-size: 13px">Chưa có yêu cầu bảo hành nào.</div>
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
} from '../api/admin';

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

const reqLabels = { pending: 'Chờ tiếp nhận', accepted: 'Đã tiếp nhận', processing: 'Đang xử lý', resolved: 'Đã hoàn thành', rejected: 'Từ chối' };
const reqColors = { pending: 'var(--amber)', accepted: 'var(--acc)', processing: '#a855f7', resolved: 'var(--green)', rejected: 'var(--sale)' };
function reqStatusLabel(s) { return reqLabels[s] || s; }
function reqStatusStyle(s) {
  const c = reqColors[s] || 'var(--muted)';
  return { background: 'color-mix(in srgb,' + c + ' 16%, transparent)', color: c, fontSize: '11px', fontWeight: '600', padding: '3px 9px', borderRadius: '20px' };
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
</style>
