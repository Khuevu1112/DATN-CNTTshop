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

    <!-- Trình quản lý hội viên (gói trả phí) nhúng ngay trong trang Quản lý tài khoản.
         Liệt kê ĐÍCH DANH hai tab nó phụ trách, không dùng `tab !== 'accounts'`: điều kiện phủ
         định đó kéo theo cả tab "Khách vãng lai", và bên trong MembershipAdmin nhánh cuối là
         `v-else` nên view='walkin' rơi thẳng vào trình sửa "Gói & ưu đãi" — kết quả là bảng giá
         gói bị vẽ đè lên trên danh sách khách vãng lai. -->
    <MembershipAdmin v-if="permissions.isAdmin && ['members', 'plans'].includes(tab)" :view="tab" />

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
      <DataTable
        :columns="staffCols"
        :rows="staffRows"
        :tim-kiem="ui.search"
        click-duoc
        trong="Chưa có tài khoản nhân viên nào."
        @row-click="(c) => router.push('/customers/' + c.id)"
      >
        <template #o-name="{ row: c }">
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
        </template>
        <template #o-phone="{ row: c }">
          <span class="mono" style="color: var(--muted2); font-size: 12.5px">{{ c.phone }}</span>
        </template>
        <template #o-roleLabel="{ row: c }">
            <span
              style="font-size: 11.5px; font-weight: 600; padding: 3px 10px; border-radius: 20px"
              :style="{ background: c.roleBg, color: c.roleColor }"
            >{{ c.roleLabel }}</span>
        </template>
        <template #o-joined="{ row: c }">
          <span style="color: var(--muted2); font-size: 12px">{{ c.joined }}</span>
        </template>
        <template #o-active="{ row: c }">
            <span
              style="display: inline-flex; align-items: center; gap: 5px; font-size: 11.5px; font-weight: 600"
              :style="{ color: c.active ? 'var(--green)' : 'var(--muted)' }"
            >
              <span style="width: 6px; height: 6px; border-radius: 50%" :style="{ background: c.active ? 'var(--green)' : 'var(--muted)' }"></span>
              {{ c.active ? 'Hoạt động' : 'Khoá' }}
            </span>
        </template>
      </DataTable>
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
      <DataTable
        :columns="cols"
        :rows="rows"
        :tim-kiem="ui.search"
        click-duoc
        trong="Chưa có khách hàng nào."
        @row-click="(c) => router.push('/customers/' + c.id)"
      >
        <template #o-name="{ row: c }">
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
        </template>
        <template #o-phone="{ row: c }">
          <span class="mono" style="color: var(--muted2); font-size: 12.5px">{{ c.phone }}</span>
        </template>
        <template #o-roleLabel="{ row: c }">
            <span
              style="font-size: 11.5px; font-weight: 600; padding: 3px 10px; border-radius: 20px"
              :style="{ background: c.roleBg, color: c.roleColor }"
            >{{ c.roleLabel }}</span>
        </template>
        <template #o-orders="{ row: c }">
          <span class="mono" style="font-weight: 600">{{ c.orders }}</span>
        </template>
        <template #o-spent="{ row: c }">
          <span class="mono" style="font-weight: 700">{{ c.spentFmt }}</span>
        </template>
        <template #o-joined="{ row: c }">
          <span style="color: var(--muted2); font-size: 12px">{{ c.joined }}</span>
        </template>
        <template #o-active="{ row: c }">
            <span
              style="display: inline-flex; align-items: center; gap: 5px; font-size: 11.5px; font-weight: 600"
              :style="{ color: c.active ? 'var(--green)' : 'var(--muted)' }"
            >
              <span style="width: 6px; height: 6px; border-radius: 50%" :style="{ background: c.active ? 'var(--green)' : 'var(--muted)' }"></span>
              {{ c.active ? 'Hoạt động' : 'Khoá' }}
            </span>
        </template>
      </DataTable>
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

        <div v-if="walkInLoading" style="padding: 30px; text-align: center; color: var(--muted); font-size: 12.5px">
          Đang tải...
        </div>
        <DataTable
          v-else
          :columns="walkInCols"
          :rows="walkInRows"
          :tim-kiem="ui.search"
          click-duoc
          trong="Chưa có khách mua tại quầy nào."
          @row-click="(c) => router.push({ name: 'customer-detail', params: { id: c.id } })"
        >
          <template #o-maKhach="{ row: c }">
            <span class="mono" style="color: var(--acc); font-weight: 700; letter-spacing: 0.5px">{{ c.maKhach }}</span>
          </template>
          <template #o-phone="{ row: c }">
            <span class="mono">{{ c.phone || '—' }}</span>
          </template>
          <template #o-orderCount="{ row: c }">
            <span class="mono" style="color: var(--muted2)">{{ c.orderCount }}</span>
          </template>
          <template #o-totalSpent="{ row: c }">
            <span class="mono" style="font-weight: 700">{{ tienVN(c.totalSpent) }}</span>
          </template>
          <template #o-joinedAt="{ row: c }">
            <span style="color: var(--muted2); font-size: 12px">{{ ngayVN(c.joinedAt) }}</span>
          </template>
        </DataTable>
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
import DataTable from '../components/DataTable.vue';
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

// Cột cho DataTable — phễu lọc/sắp xếp kiểu Excel trên từng cột (xem components/DataTable.vue).
const walkInCols = [
  { key: 'maKhach', label: 'Mã khách' },
  { key: 'phone', label: 'Số điện thoại', text: (c) => c.phone || '—' },
  { key: 'orderCount', label: 'Đơn hàng', align: 'right', kieu: 'so' },
  { key: 'totalSpent', label: 'Tổng chi tiêu', align: 'right', kieu: 'so', text: (c) => tienVN(c.totalSpent) },
  { key: 'joinedAt', label: 'Ngày tham gia', kieu: 'ngay', text: (c) => ngayVN(c.joinedAt) },
];

// Tìm theo từ khoá đã do DataTable đảm nhận (quét mọi cột, bỏ dấu).
const walkInRows = computed(() => walkIn.value);

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

const staffCols = [
  { key: 'name', label: 'Tài khoản', text: (c) => c.name + ' · ' + c.email },
  { key: 'phone', label: 'Số điện thoại' },
  { key: 'roleLabel', label: 'Phòng ban' },
  { key: 'joined', label: 'Tham gia', kieu: 'ngay', value: (c) => c.joinedRaw, text: (c) => c.joined },
  { key: 'active', label: 'Trạng thái', text: (c) => (c.active ? 'Hoạt động' : 'Khoá') },
];
const staffRows = computed(() => STAFF_ACCOUNTS);

const cols = [
  { key: 'name', label: 'Khách hàng', text: (c) => c.name + ' · ' + c.email },
  { key: 'phone', label: 'Số điện thoại' },
  { key: 'roleLabel', label: 'Vai trò' },
  { key: 'orders', label: 'Đơn hàng', align: 'right', kieu: 'so' },
  { key: 'spent', label: 'Tổng chi tiêu', align: 'right', kieu: 'so', text: (c) => c.spentFmt },
  { key: 'joined', label: 'Tham gia', kieu: 'ngay', value: (c) => c.joinedRaw, text: (c) => c.joined },
  { key: 'active', label: 'Trạng thái', text: (c) => (c.active ? 'Hoạt động' : 'Khoá') },
];
const statusFilter = ref('all');
// Tìm theo từ khoá đã do DataTable đảm nhận — ở đây chỉ còn lọc theo tab trạng thái phía trên.
const rows = computed(() =>
  CUSTOMERS.filter(
    (c) => statusFilter.value === 'all' || (statusFilter.value === 'active' ? c.active : !c.active),
  ),
);
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
