<template>
  <div style="animation: fadeUp 0.35s ease">
    <button
      @click="router.push('/customers')"
      style="
        display: inline-flex; align-items: center; gap: 7px;
        background: none; border: none; color: var(--muted2);
        font-size: 13px; cursor: pointer; margin-bottom: 16px; font-weight: 500;
      "
    >
      <i class="bi bi-arrow-left"></i> Quay lại danh sách
    </button>

    <div v-if="loading" class="spin"></div>

    <div v-else-if="detail" :style="{ gridTemplateColumns: showRightColumn ? '1.7fr 1fr' : '1fr' }" style="display: grid; gap: 14px; align-items: start">
      <!-- ===== TRÁI: thông tin (giống USER thấy) ===== -->
      <div style="display: flex; flex-direction: column; gap: 14px">
        <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 20px">
          <div style="display: flex; align-items: center; gap: 14px; margin-bottom: 18px">
            <div
              class="mono"
              style="width: 52px; height: 52px; border-radius: 13px; flex: none; display: flex; align-items: center; justify-content: center; font-size: 18px; font-weight: 700; color: #fff"
              :style="{ background: gradAvatar(210) }"
            >
              {{ initials(detail.name || '?') }}
            </div>
            <div style="flex: 1">
              <div style="font-size: 17px; font-weight: 700; color: var(--text)">{{ detail.name }}</div>
              <div style="font-size: 12.5px; color: var(--muted); margin-top: 3px">{{ detail.email }}</div>
            </div>
            <div style="display: flex; flex-direction: column; gap: 6px; align-items: flex-end">
              <span class="badge" :style="{ background: 'color-mix(in srgb,' + roleColor(detail.role) + ' 16%,transparent)', color: roleColor(detail.role) }">{{ (RM[detail.role] && RM[detail.role].label) || detail.role }}</span>
              <span class="badge" :style="{ background: detail.isActive ? 'color-mix(in srgb,var(--green) 16%,transparent)' : 'color-mix(in srgb,var(--muted) 16%,transparent)', color: detail.isActive ? 'var(--green)' : 'var(--muted)' }">{{ detail.isActive ? 'Hoạt động' : 'Đã khoá' }}</span>
            </div>
          </div>

          <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; font-size: 13px; color: var(--muted2); margin-bottom: 4px">
            <div><i class="bi bi-telephone" style="margin-right: 7px; color: var(--muted)"></i>{{ detail.phone || 'Chưa cập nhật' }}</div>
            <div><i class="bi bi-calendar3" style="margin-right: 7px; color: var(--muted)"></i>Tham gia {{ fmtDate(detail.joinedAt) }}</div>
          </div>
        </div>

        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 14px">
          <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 16px">
            <div class="mono" style="font-size: 22px; font-weight: 700; color: var(--text)">{{ detail.orderCount }}</div>
            <div style="font-size: 11.5px; color: var(--muted); margin-top: 4px">Đơn hàng đã đặt</div>
          </div>
          <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 16px">
            <div class="mono" style="font-size: 22px; font-weight: 700; color: var(--text)">{{ money(Number(detail.totalSpent || 0)) }}</div>
            <div style="font-size: 11.5px; color: var(--muted); margin-top: 4px">Tổng chi tiêu</div>
          </div>
        </div>

        <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 20px">
          <div style="font-size: 13.5px; font-weight: 700; color: var(--text); margin-bottom: 12px">Địa chỉ</div>
          <div v-if="!detail.addresses.length" style="font-size: 13px; color: var(--muted)">Chưa có địa chỉ nào.</div>
          <div v-for="a in detail.addresses" :key="a.id" style="padding: 10px 0; border-top: 1px solid var(--line)" class="addr-row">
            <div style="font-size: 13px; font-weight: 600; color: var(--text)">
              {{ a.tenNguoiNhan }} · {{ a.soDienThoai }}
              <span v-if="a.isDefault" class="badge" style="margin-left: 8px; background: color-mix(in srgb,var(--acc) 16%,transparent); color: var(--acc)">Mặc định</span>
            </div>
            <div style="font-size: 12.5px; color: var(--muted2); margin-top: 3px">{{ a.diaChiDayDu }}</div>
          </div>
        </div>

        <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 20px">
          <div style="font-size: 13.5px; font-weight: 700; color: var(--text); margin-bottom: 12px">Đơn hàng gần đây</div>
          <div v-if="!detail.recentOrders.length" style="font-size: 13px; color: var(--muted)">Chưa có đơn hàng nào.</div>
          <div v-for="o in detail.recentOrders" :key="o.id" style="display: flex; align-items: center; justify-content: space-between; padding: 10px 0; border-top: 1px solid var(--line)" class="addr-row">
            <div>
              <div style="font-size: 13px; font-weight: 600; color: var(--text)">{{ o.code }}</div>
              <div style="font-size: 11.5px; color: var(--muted); margin-top: 2px">{{ fmtDateTime(o.createdAt) }}</div>
            </div>
            <div style="text-align: right">
              <div class="mono" style="font-size: 13px; font-weight: 700; color: var(--text)">{{ money(Number(o.total || 0)) }}</div>
              <span class="badge" style="margin-top: 3px" :style="{ background: 'color-mix(in srgb,' + orderStColor(o.status) + ' 16%,transparent)', color: orderStColor(o.status) }">{{ orderStLabel(o.status) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- ===== PHẢI: phân quyền (chỉ admin) / trạng thái (admin + CSKH) ===== -->
      <div v-if="showRightColumn" style="display: flex; flex-direction: column; gap: 14px">
        <div v-if="isSelf" class="alert-err" style="background: color-mix(in srgb, var(--amber) 14%, transparent); color: var(--amber); border-color: color-mix(in srgb, var(--amber) 30%, transparent)">
          Đây là tài khoản của bạn — không thể tự đổi vai trò hoặc khoá chính mình.
        </div>

        <div v-if="permissions.isAdmin" style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 18px">
          <div style="font-size: 13px; font-weight: 600; color: var(--text); margin-bottom: 12px">Phân quyền</div>
          <select class="fld" v-model="roleDraft" :disabled="isSelf">
            <option v-for="[key, meta] in Object.entries(RM)" :key="key" :value="key">{{ meta.label }}</option>
          </select>
          <button class="btn-acc" :disabled="isSelf || savingRole || roleDraft === detail.role" @click="saveRole">
            {{ savingRole ? 'Đang lưu...' : 'Lưu vai trò' }}
          </button>
        </div>

        <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 18px">
          <div style="font-size: 13px; font-weight: 600; color: var(--text); margin-bottom: 12px">Trạng thái tài khoản</div>
          <div style="display: flex; gap: 8px">
            <button
              @click="saveStatus(true)" :disabled="isSelf || savingStatus || detail.isActive"
              style="flex: 1; height: 42px; border-radius: 10px; cursor: pointer; font-size: 13px; font-weight: 600; border: 1px solid var(--line2)"
              :style="{ background: detail.isActive ? 'color-mix(in srgb,var(--green) 16%,transparent)' : 'var(--card2)', color: detail.isActive ? 'var(--green)' : 'var(--muted2)' }"
            >
              <i class="bi bi-unlock" style="margin-right: 6px"></i>Hoạt động
            </button>
            <button
              @click="showLockModal = true" :disabled="isSelf || savingStatus || !detail.isActive"
              style="flex: 1; height: 42px; border-radius: 10px; cursor: pointer; font-size: 13px; font-weight: 600; border: 1px solid var(--line2)"
              :style="{ background: !detail.isActive ? 'color-mix(in srgb,var(--sale) 16%,transparent)' : 'var(--card2)', color: !detail.isActive ? 'var(--sale)' : 'var(--muted2)' }"
            >
              <i class="bi bi-lock" style="margin-right: 6px"></i>Khoá
            </button>
          </div>
          <div style="font-size: 11.5px; color: var(--muted); margin-top: 10px; line-height: 1.5">
            Tài khoản bị khoá sẽ không thể đăng nhập.
          </div>
        </div>

        <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 18px">
          <div style="font-size: 13px; font-weight: 600; color: var(--text); margin-bottom: 12px">Lịch sử hoạt động</div>
          <div v-if="loadingLog" style="font-size: 12.5px; color: var(--muted)">Đang tải...</div>
          <div v-else-if="!activityLog.length" style="font-size: 12.5px; color: var(--muted)">Chưa có hoạt động nào được ghi nhận.</div>
          <div v-else style="display: flex; flex-direction: column; gap: 12px; max-height: 360px; overflow-y: auto; padding-right: 2px">
            <div v-for="log in activityLog" :key="log.id" style="border-left: 2px solid var(--line2); padding: 0 0 2px 12px">
              <div style="display: flex; align-items: center; gap: 7px">
                <i :class="logIcon(log.logType)" :style="{ color: logColor(log.logType) }" style="font-size: 12px"></i>
                <span style="font-size: 12.5px; font-weight: 600; color: var(--text)">{{ logLabel(log.logType) }}</span>
                <span style="font-size: 10.5px; color: var(--muted); margin-left: auto; white-space: nowrap">{{ fmtDateTime(log.createdAt) }}</span>
              </div>
              <div v-if="log.logType !== 'login'" style="font-size: 11px; color: var(--muted); margin-top: 3px">
                Thực hiện bởi: {{ log.performedByName || '—' }}
              </div>
              <template v-if="log.logType === 'lock'">
                <div style="font-size: 12px; color: var(--muted2); margin-top: 5px">{{ log.reason }}</div>
                <div style="font-size: 11px; color: var(--muted); margin-top: 3px">
                  Hạn khoá: {{ log.lockUntil ? fmtDate(log.lockUntil) : 'Vĩnh viễn' }}
                </div>
                <a v-if="log.evidenceImage" :href="API_ORIGIN + log.evidenceImage" target="_blank" rel="noopener">
                  <img
                    :src="API_ORIGIN + log.evidenceImage"
                    alt="Ảnh chứng minh"
                    style="max-width: 150px; max-height: 110px; border-radius: 8px; border: 1px solid var(--line2); margin-top: 7px; display: block; cursor: zoom-in"
                  />
                </a>
              </template>
              <div v-if="log.logType === 'login' && log.ipAddress" style="font-size: 11px; color: var(--muted); margin-top: 2px">IP: {{ log.ipAddress }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <LockAccountModal v-if="showLockModal" :user-id="detail.id" @close="showLockModal = false" @locked="onLocked" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import { usePermissionsStore } from '../stores/permissions';
import { getAdminCustomerDetail, updateCustomerRole, updateCustomerStatus, getCustomerActivityLog } from '../api/admin';
import { money, initials, gradAvatar, STATUS, RM } from '../data/adminData';
import { API_ORIGIN } from '../api/http';
import LockAccountModal from '../components/LockAccountModal.vue';

const route = useRoute();
const router = useRouter();
const auth = useAuthStore();
const permissions = usePermissionsStore();

const loading = ref(true);
const detail = ref(null);
const roleDraft = ref('customer');
const savingRole = ref(false);
const savingStatus = ref(false);
const showLockModal = ref(false);
const activityLog = ref([]);
const loadingLog = ref(true);

const LOG_ICON = { login: 'bi bi-box-arrow-in-right', lock: 'bi bi-lock-fill', unlock: 'bi bi-unlock-fill' };
const LOG_COLOR = { login: 'var(--muted2)', lock: 'var(--sale)', unlock: 'var(--green)' };
const LOG_LABEL = { login: 'Đăng nhập', lock: 'Khoá tài khoản', unlock: 'Mở khoá tài khoản' };
const logIcon = (t) => LOG_ICON[t] || 'bi bi-dot';
const logColor = (t) => LOG_COLOR[t] || 'var(--muted)';
const logLabel = (t) => LOG_LABEL[t] || t;

const roleColor = (r) => (RM[r] && RM[r].color) || '#7aa2ff';
const orderStLabel = (s) => (STATUS[s] ? STATUS[s].label : s);
const orderStColor = (s) => (STATUS[s] ? STATUS[s].color : 'var(--muted)');

const isSelf = computed(() => detail.value && auth.user?.id === detail.value.id);
// Panel phân quyền/khoá tài khoản: admin thấy cả 2; CSKH chỉ có quyền "perform" trên
// account_detail (khoá/mở khoá) nên chỉ thấy panel trạng thái, không thấy đổi vai trò.
const showRightColumn = computed(() => permissions.isAdmin || permissions.hasPerm('account_detail', 'perform'));

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

async function load() {
  loading.value = true;
  try {
    detail.value = await getAdminCustomerDetail(route.params.id);
    roleDraft.value = detail.value.role;
  } finally {
    loading.value = false;
  }
}

async function loadActivityLog() {
  loadingLog.value = true;
  try {
    activityLog.value = await getCustomerActivityLog(route.params.id);
  } finally {
    loadingLog.value = false;
  }
}

async function onLocked() {
  showLockModal.value = false;
  detail.value.isActive = false;
  await loadActivityLog();
}

async function saveRole() {
  savingRole.value = true;
  try {
    await updateCustomerRole(detail.value.id, roleDraft.value);
    detail.value.role = roleDraft.value;
  } finally {
    savingRole.value = false;
  }
}

async function saveStatus(next) {
  savingStatus.value = true;
  try {
    await updateCustomerStatus(detail.value.id, next);
    detail.value.isActive = next;
  } finally {
    savingStatus.value = false;
  }
}

onMounted(() => {
  load();
  // Panel trạng thái/log hoạt động chỉ hiện với admin + CSKH (showRightColumn) — người khác
  // (VD Kinh doanh chỉ có "view") không cần tải log vì không bao giờ hiển thị ra.
  if (showRightColumn.value) loadActivityLog();
  else loadingLog.value = false;
});
</script>

<style scoped>
.badge {
  display: inline-flex;
  align-items: center;
  font-size: 11px;
  font-weight: 600;
  padding: 3px 10px;
  border-radius: 20px;
}
.addr-row:first-of-type {
  border-top: none;
  padding-top: 0;
}
</style>
