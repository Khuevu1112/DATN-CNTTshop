<template>
  <div style="animation: fadeUp 0.35s ease">
    <!-- Chuyển giữa Tài khoản / Hội viên / Gói & ưu đãi — chỉ admin thấy tab hội viên (gói trả
         phí là dữ liệu admin-only; phòng ban khác vẫn thấy danh sách tài khoản như cũ). -->
    <div v-if="permissions.isAdmin" style="display: flex; gap: 8px; margin-bottom: 16px; flex-wrap: wrap">
      <button
        v-for="t in TABS" :key="t[0]"
        @click="tab = t[0]"
        :style="{
          background: tab === t[0] ? 'var(--acc)' : 'var(--card)',
          color: tab === t[0] ? 'var(--acc-ink)' : 'var(--muted2)',
          borderColor: tab === t[0] ? 'var(--acc)' : 'var(--line2)',
        }"
        style="padding: 9px 18px; border: 1px solid; border-radius: 10px; font-size: 13.5px; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 7px"
      ><i class="bi" :class="t[2]"></i> {{ t[1] }}</button>
    </div>

    <!-- Trình quản lý hội viên (gói trả phí) nhúng ngay trong trang Quản lý tài khoản -->
    <MembershipAdmin v-if="permissions.isAdmin && tab !== 'accounts'" :view="tab" />

    <!-- ===== Nội dung tài khoản (mặc định) ===== -->
    <template v-if="tab === 'accounts'">
    <!-- Widget trên: tài khoản nhân viên — chỉ admin thấy -->
    <div
      v-if="permissions.isAdmin"
      style="
        background: var(--card);
        border: 1px solid var(--line);
        border-radius: 14px;
        overflow: hidden;
        margin-bottom: 16px;
      "
    >
      <div
        style="
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 12px 16px;
          border-bottom: 1px solid var(--line);
          flex-wrap: wrap;
        "
      >
        <div style="font-size: 14.5px; font-weight: 600; color: var(--text); display: flex; align-items: center; gap: 8px">
          <i class="bi bi-person-badge" style="color: var(--acc)"></i> Tài khoản nhân viên
        </div>
        <div style="flex: 1"></div>
        <span class="mono" style="font-size: 11.5px; color: var(--muted)">{{ staffRows.length }} tài khoản</span>
        <button
          @click="showPermissionsModal = true"
          style="
            height: 32px;
            padding: 0 14px;
            border-radius: 8px;
            border: 1px solid var(--line2);
            background: var(--card);
            color: var(--text);
            font-size: 12.5px;
            font-weight: 700;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
          "
        >
          <i class="bi bi-shield-lock"></i> Phân quyền
        </button>
        <button
          @click="showAddModal = true"
          style="
            height: 32px;
            padding: 0 14px;
            border-radius: 8px;
            border: none;
            background: var(--acc);
            color: var(--acc-ink);
            font-size: 12.5px;
            font-weight: 700;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
          "
        >
          <i class="bi bi-plus-lg"></i> Thêm tài khoản
        </button>
      </div>
      <table style="width: 100%; border-collapse: collapse; font-size: 13px">
        <thead>
          <tr style="background: var(--card2)">
            <th
              v-for="h in staffHeads"
              :key="h.t"
              :style="{
                textAlign: h.a || 'left',
                padding: '10px 16px',
                fontSize: '11px',
                fontWeight: 600,
                color: 'var(--muted)',
                textTransform: 'uppercase',
                letterSpacing: '.4px',
              }"
            >
              {{ h.t }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="!staffRows.length">
            <td :colspan="staffHeads.length" style="padding: 26px; text-align: center; color: var(--muted); font-size: 12.5px">
              Chưa có tài khoản nhân viên nào.
            </td>
          </tr>
          <tr
            v-for="c in staffRows"
            :key="c.id"
            @click="router.push('/customers/' + c.id)"
            style="border-top: 1px solid var(--line); cursor: pointer"
          >
            <td style="padding: 11px 16px">
              <div style="display: flex; align-items: center; gap: 11px">
                <div
                  class="mono"
                  style="width: 38px; height: 38px; border-radius: 10px; flex: none; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 700; color: #fff"
                  :style="{ background: gradAvatar(c.hue) }"
                >
                  {{ c.init }}
                </div>
                <div>
                  <div style="font-size: 13px; font-weight: 500; color: var(--text)">{{ c.name }}</div>
                  <div style="font-size: 11.5px; color: var(--muted)">{{ c.email }}</div>
                </div>
              </div>
            </td>
            <td class="mono" style="padding: 11px 12px; color: var(--muted2); font-size: 12.5px">{{ c.phone }}</td>
            <td style="padding: 11px 12px">
              <span
                style="font-size: 11.5px; font-weight: 600; padding: 3px 10px; border-radius: 20px"
                :style="{ background: c.roleBg, color: c.roleColor }"
                >{{ c.roleLabel }}</span
              >
            </td>
            <td style="padding: 11px 12px; color: var(--muted2); font-size: 12px">{{ c.joined }}</td>
            <td style="padding: 11px 16px">
              <span
                style="display: inline-flex; align-items: center; gap: 5px; font-size: 11.5px; font-weight: 600"
                :style="{ color: c.active ? 'var(--green)' : 'var(--muted)' }"
                ><span
                  style="width: 6px; height: 6px; border-radius: 50%"
                  :style="{ background: c.active ? 'var(--green)' : 'var(--muted)' }"
                ></span
                >{{ c.active ? 'Hoạt động' : 'Khoá' }}</span
              >
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Thống kê: giữ nguyên y hệt nội dung/cách tính, chỉ dời vị trí lên trên danh sách khách hàng -->
    <div
      v-if="permissions.isAdmin"
      style="
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 14px;
        margin-bottom: 16px;
      "
    >
      <div
        v-for="s in stats"
        :key="s.label"
        style="
          background: var(--card);
          border: 1px solid var(--line);
          border-radius: 13px;
          padding: 14px 16px;
          display: flex;
          align-items: center;
          gap: 13px;
        "
      >
        <div
          style="
            width: 40px;
            height: 40px;
            border-radius: 10px;
            flex: none;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 17px;
          "
          :style="{
            background: 'color-mix(in srgb,' + s.color + ' 16%,transparent)',
            color: s.color,
          }"
        >
          <i class="bi" :class="s.icon"></i>
        </div>
        <div>
          <div class="mono" style="font-size: 21px; font-weight: 700; color: var(--text); line-height: 1">
            {{ s.value }}
          </div>
          <div style="font-size: 11.5px; color: var(--muted); margin-top: 4px">
            {{ s.label }}
          </div>
        </div>
      </div>
    </div>

    <!-- Widget dưới: khách hàng -->
    <div
      style="
        background: var(--card);
        border: 1px solid var(--line);
        border-radius: 14px;
        overflow: hidden;
      "
    >
      <div
        style="
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 12px 16px;
          border-bottom: 1px solid var(--line);
          flex-wrap: wrap;
        "
      >
        <div style="font-size: 14.5px; font-weight: 600; color: var(--text); display: flex; align-items: center; gap: 8px">
          <i class="bi bi-people" style="color: var(--acc)"></i> Khách hàng
        </div>
        <select
          v-model="statusFilter"
          style="
            height: 32px;
            padding: 0 10px;
            border-radius: 8px;
            border: 1px solid var(--line2);
            background: var(--card2);
            color: var(--text);
            font-size: 12.5px;
            cursor: pointer;
          "
        >
          <option value="all">Mọi trạng thái</option>
          <option value="active">Hoạt động</option>
          <option value="locked">Đã khoá</option>
        </select>
        <button
          v-if="statusFilter !== 'all'"
          @click="statusFilter = 'all'"
          style="background: transparent; border: none; color: var(--sale); font-size: 12px; cursor: pointer"
        >
          Xóa lọc
        </button>
        <div style="flex: 1"></div>
        <span class="mono" style="font-size: 11.5px; color: var(--muted)">{{ rows.length }} khách hàng</span>
      </div>
      <table style="width: 100%; border-collapse: collapse; font-size: 13px">
        <thead>
          <tr style="background: var(--card2)">
            <th
              v-for="h in heads"
              :key="h.t"
              :style="{
                textAlign: h.a || 'left',
                padding: '10px 16px',
                fontSize: '11px',
                fontWeight: 600,
                color: 'var(--muted)',
                textTransform: 'uppercase',
                letterSpacing: '.4px',
              }"
            >
              {{ h.t }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="c in rows"
            :key="c.id"
            @click="router.push('/customers/' + c.id)"
            style="border-top: 1px solid var(--line); cursor: pointer"
          >
            <td style="padding: 11px 16px">
              <div style="display: flex; align-items: center; gap: 11px">
                <div
                  class="mono"
                  style="
                    width: 38px;
                    height: 38px;
                    border-radius: 10px;
                    flex: none;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 12px;
                    font-weight: 700;
                    color: #fff;
                  "
                  :style="{ background: gradAvatar(c.hue) }"
                >
                  {{ c.init }}
                </div>
                <div>
                  <div
                    style="
                      font-size: 13px;
                      font-weight: 500;
                      color: var(--text);
                    "
                  >
                    {{ c.name }}
                  </div>
                  <div style="font-size: 11.5px; color: var(--muted)">
                    {{ c.email }}
                  </div>
                </div>
              </div>
            </td>
            <td
              class="mono"
              style="
                padding: 11px 12px;
                color: var(--muted2);
                font-size: 12.5px;
              "
            >
              {{ c.phone }}
            </td>
            <td style="padding: 11px 12px">
              <span
                style="
                  font-size: 11.5px;
                  font-weight: 600;
                  padding: 3px 10px;
                  border-radius: 20px;
                "
                :style="{ background: c.roleBg, color: c.roleColor }"
                >{{ c.roleLabel }}</span
              >
            </td>
            <td
              class="mono"
              style="
                padding: 11px 12px;
                text-align: right;
                color: var(--text);
                font-weight: 600;
              "
            >
              {{ c.orders }}
            </td>
            <td
              class="mono"
              style="
                padding: 11px 12px;
                text-align: right;
                color: var(--text);
                font-weight: 700;
              "
            >
              {{ c.spentFmt }}
            </td>
            <td
              style="padding: 11px 12px; color: var(--muted2); font-size: 12px"
            >
              {{ c.joined }}
            </td>
            <td style="padding: 11px 16px">
              <span
                style="
                  display: inline-flex;
                  align-items: center;
                  gap: 5px;
                  font-size: 11.5px;
                  font-weight: 600;
                "
                :style="{ color: c.active ? 'var(--green)' : 'var(--muted)' }"
                ><span
                  style="width: 6px; height: 6px; border-radius: 50%"
                  :style="{
                    background: c.active ? 'var(--green)' : 'var(--muted)',
                  }"
                ></span
                >{{ c.active ? 'Hoạt động' : 'Khoá' }}</span
              >
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    </template>

    <!-- ===================== TAB: KHÁCH VÃNG LAI / KHÁCH LẺ ===================== -->
    <template v-if="tab === 'walkin'">
      <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; overflow: hidden">
        <div style="padding: 14px 18px; border-bottom: 1px solid var(--line); display: flex; align-items: center; gap: 10px; flex-wrap: wrap">
          <div>
            <div style="font-size: 14.5px; font-weight: 600; color: var(--text)">Khách vãng lai / khách lẻ</div>
            <div style="font-size: 11.5px; color: var(--muted); margin-top: 3px">
              Tài khoản tạo tự động khi bán tại quầy, định danh bằng số điện thoại — vẫn tích Xu và
              lên hạng như khách đăng ký.
            </div>
          </div>
          <div style="flex: 1"></div>
          <span class="mono" style="font-size: 11.5px; color: var(--muted)">{{ walkInRows.length }} khách</span>
        </div>

        <table style="width: 100%; border-collapse: collapse; font-size: 13px">
          <thead>
            <tr style="background: var(--card2)">
              <th v-for="h in walkInHeads" :key="h.t" class="th" :style="{ textAlign: h.a || 'left' }">{{ h.t }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="walkInLoading">
              <td :colspan="walkInHeads.length" style="padding: 30px; text-align: center; color: var(--muted); font-size: 12.5px">
                Đang tải...
              </td>
            </tr>
            <tr v-else-if="!walkInRows.length">
              <td :colspan="walkInHeads.length" style="padding: 30px; text-align: center; color: var(--muted); font-size: 12.5px">
                Chưa có khách mua tại quầy nào.
              </td>
            </tr>
            <tr
              v-for="c in walkInRows" :key="c.id"
              style="border-top: 1px solid var(--line); cursor: pointer"
              @click="router.push({ name: 'customer-detail', params: { id: c.id } })"
            >
              <td class="mono" style="padding: 12px 18px; color: var(--acc); font-weight: 700; letter-spacing: 0.5px">
                {{ c.maKhach }}
              </td>
              <td class="mono" style="padding: 12px 12px; color: var(--text)">{{ c.phone || '—' }}</td>
              <td class="mono" style="padding: 12px 12px; text-align: right; color: var(--muted2)">{{ c.orderCount }}</td>
              <td class="mono" style="padding: 12px 12px; text-align: right; color: var(--text); font-weight: 700">
                {{ tienVN(c.totalSpent) }}
              </td>
              <td style="padding: 12px 18px; color: var(--muted2); font-size: 12px">{{ ngayVN(c.joinedAt) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </template>

    <AddStaffModal v-if="showAddModal" @close="showAddModal = false" @saved="onStaffAdded" />
    <PermissionsModal v-if="showPermissionsModal" @close="showPermissionsModal = false" />
  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { CUSTOMERS, STAFF_ACCOUNTS, short, gradAvatar, refreshStaffAccounts } from '../data/adminData';
import { getWalkInCustomers } from '../api/admin';
import { usePermissionsStore } from '../stores/permissions';
import { ui } from '../uiState';
import AddStaffModal from '../components/AddStaffModal.vue';
import PermissionsModal from '../components/PermissionsModal.vue';
import MembershipAdmin from './MembershipAdmin.vue';

const router = useRouter();
const permissions = usePermissionsStore();
const showAddModal = ref(false);
const showPermissionsModal = ref(false);

// Gộp "Quản lý hội viên" vào đây: tab 'accounts' = tài khoản như cũ; 'members'/'plans' nhúng
// MembershipAdmin (chỉ admin). Prop `view` truyền xuống để ẩn thanh chọn nội bộ của component đó.
const tab = ref('accounts');
const TABS = [
  ['accounts', 'Tài khoản', 'bi-people'],
  ['walkin', 'Khách vãng lai', 'bi-person-walking'],
  ['members', 'Hội viên', 'bi-gem'],
  ['plans', 'Gói & ưu đãi', 'bi-box-seam'],
];

// ===== Khách vãng lai / khách lẻ =====
// Tài khoản do POS tự tạo khi bán tại quầy (auth_provider='pos'). Không có email thật nên định
// danh bằng mã KH*** + số điện thoại — xem AdminApiController.walkInCustomers.
const walkIn = ref([]);
const walkInLoading = ref(false);

async function loadWalkIn() {
  walkInLoading.value = true;
  try {
    walkIn.value = await getWalkInCustomers();
  } catch (e) {
    walkIn.value = [];
  } finally {
    walkInLoading.value = false;
  }
}

const walkInHeads = [
  { t: 'Mã khách' },
  { t: 'Số điện thoại' },
  { t: 'Đơn hàng', a: 'right' },
  { t: 'Tổng chi tiêu', a: 'right' },
  { t: 'Ngày tham gia' },
];

const walkInRows = computed(() => {
  const q = ui.search.trim().toLowerCase();
  return walkIn.value.filter(
    (c) => !q
      || String(c.maKhach || '').toLowerCase().includes(q)
      || String(c.phone || '').toLowerCase().includes(q),
  );
});

const tienVN = (n) => (Number(n) || 0).toLocaleString('vi-VN') + '₫';
const ngayVN = (d) => (d ? new Date(d).toLocaleDateString('vi-VN') : '—');

onMounted(() => {
  if (permissions.isAdmin) refreshStaffAccounts();
  loadWalkIn();
});

async function onStaffAdded() {
  // Không đóng modal ở đây — nó đang chuyển sang màn hình hiện mật khẩu 1 lần,
  // tự đóng khi người dùng bấm "Xong"/"X" (xem @close bên dưới).
  await refreshStaffAccounts();
}

const staffHeads = [
  { t: 'Tài khoản' },
  { t: 'Số điện thoại' },
  { t: 'Phòng ban' },
  { t: 'Tham gia' },
  { t: 'Trạng thái' },
];
const staffRows = computed(() => {
  const q = ui.search.trim().toLowerCase();
  return STAFF_ACCOUNTS.filter(
    (c) => !q || c.name.toLowerCase().includes(q) || c.email.toLowerCase().includes(q),
  );
});

const heads = [
  { t: 'Khách hàng' },
  { t: 'Số điện thoại' },
  { t: 'Vai trò' },
  { t: 'Đơn hàng', a: 'right' },
  { t: 'Tổng chi tiêu', a: 'right' },
  { t: 'Tham gia' },
  { t: 'Trạng thái' },
];
const statusFilter = ref('all');
const rows = computed(() => {
  const q = ui.search.trim().toLowerCase();
  return CUSTOMERS.filter(
    (c) =>
      (statusFilter.value === 'all' ||
        (statusFilter.value === 'active' ? c.active : !c.active)) &&
      (!q ||
        c.name.toLowerCase().includes(q) ||
        c.email.toLowerCase().includes(q)),
  );
});
const stats = computed(() => [
  {
    label: 'Tổng khách hàng',
    value: CUSTOMERS.filter((c) => c.role === 'customer').length + '',
    icon: 'bi-people',
    color: 'var(--acc)',
  },
  {
    label: 'Nhân viên & Admin',
    value: STAFF_ACCOUNTS.filter((c) => c.role !== 'customer').length + '',
    icon: 'bi-person-badge',
    color: '#a855f7',
  },
  {
    label: 'Tổng đơn đã đặt',
    value: CUSTOMERS.reduce((a, c) => a + c.orders, 0) + '',
    icon: 'bi-bag-check',
    color: 'var(--green)',
  },
  {
    label: 'Tổng chi tiêu',
    value: short(CUSTOMERS.reduce((a, c) => a + c.spent, 0)),
    icon: 'bi-cash-stack',
    color: 'var(--amber)',
  },
]);
</script>
