<script setup>
import { ref, computed, onMounted, reactive } from 'vue';
import {
  getMembers, getMemberDetail, getSubscriptionPlans, updateSubscriptionPlan,
} from '../api/admin';
import { money, fmtMoneyInput, parseMoneyInput } from '../data/adminData';
import DataTable from '../components/DataTable.vue';

// Trường lọc cho chế độ thẻ — cùng phễu Excel như các bảng khác (xem components/DataTable.vue).
const memberCols = [
  { key: 'fullName', label: 'Hội viên', text: (m) => (m.fullName || 'Chưa đặt tên') + ' · ' + (m.email || '') },
  { key: 'planName', label: 'Gói' },
  { key: 'status', label: 'Trạng thái', text: (m) => st(m.status).label },
  { key: 'startedAt', label: 'Ngày bắt đầu', kieu: 'ngay', text: (m) => fmtDate(m.startedAt) },
  { key: 'expiresAt', label: 'Ngày hết hạn', kieu: 'ngay', text: (m) => fmtDate(m.expiresAt) },
];

// Nhúng trong trang "Quản lý tài khoản" (Customers.vue): khi có prop `view` thì bị điều khiển
// từ ngoài (ẩn thanh chọn nội bộ). Không có prop -> tự chạy độc lập với thanh chọn riêng.
// Dù nhúng ở đâu, mọi API vẫn là membership_admin -> chỉ admin gọi được (phòng ban khác 422).
const props = defineProps({ view: { type: String, default: '' } });
const innerTab = ref('members'); // dùng khi chạy độc lập
const tab = computed(() => props.view || innerTab.value); // 'members' | 'plans'

// ===== Tab Hội viên: danh sách (trái) + chi tiết (phải) =====
const members = ref([]);
const membersLoading = ref(true);
const search = ref('');
const selectedId = ref(null);
const detail = ref(null);
const detailLoading = ref(false);

const STATUS = {
  active: { label: 'Đang dùng', color: 'var(--green)' },
  expired: { label: 'Hết hạn', color: 'var(--muted)' },
  cancelled: { label: 'Đã huỷ', color: 'var(--sale)' },
  pending: { label: 'Chờ thanh toán', color: 'var(--amber)' },
};
const st = (s) => STATUS[s] || { label: s, color: 'var(--muted)' };

const filteredMembers = computed(() => {
  const q = search.value.trim().toLowerCase();
  if (!q) return members.value;
  return members.value.filter(
    (m) => (m.fullName || '').toLowerCase().includes(q) || (m.email || '').toLowerCase().includes(q),
  );
});

function fmtDate(iso) {
  if (!iso) return '—';
  const d = new Date(iso);
  return `${String(d.getDate()).padStart(2, '0')}/${String(d.getMonth() + 1).padStart(2, '0')}/${d.getFullYear()}`;
}

async function loadMembers() {
  membersLoading.value = true;
  try {
    members.value = await getMembers();
  } finally {
    membersLoading.value = false;
  }
}

async function selectMember(m) {
  selectedId.value = m.userId;
  detailLoading.value = true;
  detail.value = null;
  try {
    detail.value = await getMemberDetail(m.userId);
  } finally {
    detailLoading.value = false;
  }
}

// ===== Tab Gói & ưu đãi: sửa giá + ưu đãi (chỉ admin) =====
const plans = ref([]);
const plansLoading = ref(true);
const forms = reactive({}); // planId -> bản nháp đang sửa
const saving = ref(null);
const flash = reactive({ msg: '', type: 'ok' }); // banner kết quả lưu

function showFlash(msg, type = 'ok') {
  flash.msg = msg;
  flash.type = type;
  setTimeout(() => { if (flash.msg === msg) flash.msg = ''; }, 4000);
}

function toForm(p) {
  return {
    name: p.name,
    price: p.price,
    durationMonths: p.durationMonths,
    freeInnerShipping: p.freeInnerShipping,
    freeExpressInner: p.freeExpressInner,
    interprovinceQuota: p.interprovinceQuota,
    warrantyPriority: p.warrantyPriority,
    cleaningQuota: p.cleaningQuota,
    thermalPaste: p.thermalPaste,
    onsiteWarrantyQuota: p.onsiteWarrantyQuota,
    loanerQuota: p.loanerQuota,
    flashSaleEarly: p.flashSaleEarly,
    pcBuildConsult: p.pcBuildConsult,
    activationVoucherAmount: p.activationVoucherAmount,
    activationVoucherMin: p.activationVoucherMin,
    isActive: p.isActive,
  };
}

async function loadPlans() {
  plansLoading.value = true;
  try {
    plans.value = await getSubscriptionPlans();
    plans.value.forEach((p) => { forms[p.id] = toForm(p); });
  } finally {
    plansLoading.value = false;
  }
}

// Chi phí ưu đãi tối đa/năm ước tính lại NGAY trên client khi admin gõ (đồng bộ công thức với
// SubscriptionPlan.chiPhiToiDaMotNam) để thấy trước còn lãi/lỗ trước khi bấm Lưu.
const COST = { ship: 49000, clean: 45000, cleanPaste: 60000, onsite: 40000, loaner: 100000 };
function maxCost(f) {
  const clean = f.thermalPaste ? COST.cleanPaste : COST.clean;
  return (Number(f.interprovinceQuota) || 0) * COST.ship
    + (Number(f.cleaningQuota) || 0) * clean
    + (Number(f.onsiteWarrantyQuota) || 0) * COST.onsite
    + (Number(f.loanerQuota) || 0) * COST.loaner
    + (Number(f.activationVoucherAmount) || 0);
}
function margin(f) {
  const price = Number(f.price) || 0;
  const cost = maxCost(f);
  if (price <= 0) return -100;
  return Math.round(((price - cost) / price) * 100);
}

async function savePlan(p) {
  const f = forms[p.id];
  saving.value = p.id;
  try {
    const updated = await updateSubscriptionPlan(p.id, {
      name: f.name,
      price: Number(f.price) || 0,
      durationMonths: Number(f.durationMonths) || 12,
      freeInnerShipping: f.freeInnerShipping,
      freeExpressInner: f.freeExpressInner,
      interprovinceQuota: Number(f.interprovinceQuota) || 0,
      warrantyPriority: f.warrantyPriority,
      cleaningQuota: Number(f.cleaningQuota) || 0,
      thermalPaste: f.thermalPaste,
      onsiteWarrantyQuota: Number(f.onsiteWarrantyQuota) || 0,
      loanerQuota: Number(f.loanerQuota) || 0,
      flashSaleEarly: f.flashSaleEarly,
      pcBuildConsult: f.pcBuildConsult,
      activationVoucherAmount: Number(f.activationVoucherAmount) || 0,
      activationVoucherMin: Number(f.activationVoucherMin) || 0,
      isActive: f.isActive,
    });
    // Cập nhật lại thẻ theo dữ liệu server trả về
    const idx = plans.value.findIndex((x) => x.id === p.id);
    if (idx >= 0) plans.value[idx] = updated;
    forms[p.id] = toForm(updated);
    showFlash('Đã lưu gói "' + updated.name + '"', 'ok');
  } catch (e) {
    const msg = e?.response?.data?.message || 'Lưu gói thất bại, vui lòng thử lại';
    showFlash(msg, 'err');
  } finally {
    saving.value = null;
  }
}

// Ô nhập tiền: hiện dấu chấm phân cách khi gõ, lưu số thuần trong form.
function onMoneyInput(f, key, e) {
  f[key] = parseMoneyInput(e.target.value) ?? 0;
}

onMounted(() => {
  loadMembers();
  loadPlans();
});
</script>

<template>
  <div>
    <!-- Thanh chọn nội bộ — chỉ hiện khi chạy độc lập (không bị Customers.vue điều khiển) -->
    <div v-if="!view" style="display: flex; gap: 8px; margin-bottom: 20px">
      <button
        v-for="t in [['members', 'Hội viên'], ['plans', 'Gói & ưu đãi']]" :key="t[0]"
        @click="innerTab = t[0]"
        :style="{
          background: tab === t[0] ? 'var(--acc)' : 'var(--card)',
          color: tab === t[0] ? 'var(--acc-ink)' : 'var(--muted2)',
          borderColor: tab === t[0] ? 'var(--acc)' : 'var(--line2)',
        }"
        style="padding: 9px 18px; border: 1px solid; border-radius: 10px; font-size: 13.5px; font-weight: 600; cursor: pointer"
      >{{ t[1] }}</button>
    </div>

    <!-- ============ TAB HỘI VIÊN: trái danh sách (lớn) / phải chi tiết ============ -->
    <div v-if="tab === 'members'" style="display: grid; grid-template-columns: 1.7fr 1fr; gap: 18px; align-items: start">
      <!-- Cột trái: danh sách hội viên -->
      <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; overflow: hidden">
        <div style="padding: 16px 18px; border-bottom: 1px solid var(--line); display: flex; align-items: center; gap: 12px">
          <div style="font-size: 14px; font-weight: 700; color: var(--text); flex: none">
            Hội viên <span style="color: var(--muted)">({{ members.length }})</span>
          </div>
          <div style="flex: 1; display: flex; align-items: center; gap: 8px; background: var(--card2); border: 1px solid var(--line2); border-radius: 9px; padding: 0 12px; height: 36px">
            <i class="bi bi-search" style="color: var(--muted); font-size: 13px"></i>
            <input v-model="search" placeholder="Tìm theo tên hoặc email..."
              style="flex: 1; background: transparent; border: none; outline: none; color: var(--text); font-size: 13px" />
          </div>
        </div>

        <div v-if="membersLoading" style="padding: 50px; text-align: center; color: var(--muted); font-size: 13px">Đang tải...</div>
        <div v-else-if="!filteredMembers.length" style="padding: 50px; text-align: center; color: var(--muted); font-size: 13px">
          {{ members.length ? 'Không tìm thấy hội viên phù hợp.' : 'Chưa có hội viên nào mua gói.' }}
        </div>
        <!-- Chế độ THẺ của DataTable: danh sách hội viên là cột chọn (bấm để xem chi tiết bên
             phải) nên giữ nguyên dạng dòng, nhưng vẫn lọc được theo gói/trạng thái/ngày. -->
        <DataTable v-else che-do="the" :columns="memberCols" :rows="filteredMembers" row-key="userId" trong="Chưa có hội viên nào mua gói.">
          <template #the="{ rows }">
        <div style="max-height: 70vh; overflow-y: auto">
          <div
            v-for="m in rows" :key="m.userId"
            @click="selectMember(m)"
            :style="{ background: selectedId === m.userId ? 'color-mix(in srgb, var(--acc) 10%, transparent)' : 'transparent' }"
            style="display: flex; align-items: center; gap: 12px; padding: 13px 18px; border-bottom: 1px solid var(--line); cursor: pointer"
          >
            <div style="width: 38px; height: 38px; border-radius: 10px; flex: none; background: linear-gradient(135deg, var(--acc), #1c1d21); color: var(--acc-ink); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px">
              {{ (m.fullName || m.email || '?').trim().charAt(0).toUpperCase() }}
            </div>
            <div style="flex: 1; min-width: 0">
              <div style="font-size: 13.5px; font-weight: 600; color: var(--text); white-space: nowrap; overflow: hidden; text-overflow: ellipsis">{{ m.fullName || 'Chưa đặt tên' }}</div>
              <div style="font-size: 11.5px; color: var(--muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis">{{ m.email }}</div>
            </div>
            <div style="text-align: right; flex: none">
              <div style="font-size: 12.5px; font-weight: 600; color: var(--text)">{{ m.planName }}</div>
              <span :style="{ color: st(m.status).color }" style="font-size: 11px; font-weight: 600">● {{ st(m.status).label }}</span>
            </div>
          </div>
        </div>
          </template>
        </DataTable>
      </div>

      <!-- Cột phải: chi tiết hội viên đang chọn -->
      <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 20px; position: sticky; top: 84px">
        <div v-if="!selectedId" style="padding: 40px 10px; text-align: center; color: var(--muted); font-size: 13px">
          <i class="bi bi-arrow-left-circle" style="font-size: 22px; display: block; margin-bottom: 10px; opacity: 0.6"></i>
          Chọn một hội viên bên trái để xem chi tiết.
        </div>
        <div v-else-if="detailLoading" style="padding: 40px; text-align: center; color: var(--muted); font-size: 13px">Đang tải...</div>
        <template v-else-if="detail">
          <!-- Thông tin người -->
          <div style="display: flex; align-items: center; gap: 13px; margin-bottom: 18px">
            <div style="width: 46px; height: 46px; border-radius: 12px; flex: none; background: linear-gradient(135deg, var(--acc), #1c1d21); color: var(--acc-ink); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 17px">
              {{ (detail.fullName || detail.email || '?').trim().charAt(0).toUpperCase() }}
            </div>
            <div style="min-width: 0">
              <div style="font-size: 15px; font-weight: 700; color: var(--text)">{{ detail.fullName || 'Chưa đặt tên' }}</div>
              <div style="font-size: 12px; color: var(--muted)">{{ detail.email }}</div>
              <div v-if="detail.phone" style="font-size: 12px; color: var(--muted)">{{ detail.phone }}</div>
            </div>
          </div>

          <!-- Gói đang dùng -->
          <div v-if="detail.hasActive" style="background: color-mix(in srgb, var(--acc) 8%, var(--card2)); border: 1px solid color-mix(in srgb, var(--acc) 26%, var(--line)); border-radius: 12px; padding: 15px 16px; margin-bottom: 16px">
            <div style="display: flex; justify-content: space-between; align-items: baseline">
              <div style="font-size: 15px; font-weight: 800; color: var(--text)">{{ detail.currentPlan.name }}</div>
              <div style="font-size: 15px; font-weight: 700; color: var(--acc)">{{ money(detail.currentPlan.price) }}</div>
            </div>
            <div style="font-size: 12px; color: var(--muted2); margin-top: 3px">
              {{ fmtDate(detail.startedAt) }} → {{ fmtDate(detail.expiresAt) }}
            </div>

            <div v-if="detail.quotas.length" style="margin-top: 14px; display: flex; flex-direction: column; gap: 11px">
              <div v-for="q in detail.quotas" :key="q.key">
                <div style="display: flex; justify-content: space-between; font-size: 12px; color: var(--muted2); margin-bottom: 5px">
                  <span>{{ q.label }}</span>
                  <span style="font-weight: 700; color: var(--text)">{{ q.conLai }}/{{ q.tong }}</span>
                </div>
                <div style="height: 6px; background: var(--card); border-radius: 999px; overflow: hidden">
                  <div :style="{ width: (q.tong ? (q.conLai / q.tong) * 100 : 0) + '%' }" style="height: 100%; background: var(--acc); border-radius: 999px"></div>
                </div>
              </div>
            </div>
          </div>
          <div v-else style="background: var(--card2); border: 1px solid var(--line); border-radius: 12px; padding: 14px 16px; margin-bottom: 16px; font-size: 12.5px; color: var(--muted)">
            Hội viên hiện không có gói còn hiệu lực.
          </div>

          <!-- Lịch sử đăng ký -->
          <div style="font-size: 12.5px; font-weight: 700; color: var(--muted2); margin-bottom: 10px">Lịch sử đăng ký ({{ detail.history.length }})</div>
          <div style="display: flex; flex-direction: column; gap: 8px; max-height: 240px; overflow-y: auto">
            <div v-for="h in detail.history" :key="h.id" style="display: flex; justify-content: space-between; align-items: center; gap: 10px; background: var(--card2); border-radius: 9px; padding: 10px 12px">
              <div>
                <div style="font-size: 12.5px; font-weight: 600; color: var(--text)">{{ h.planName }}</div>
                <div style="font-size: 11px; color: var(--muted); margin-top: 2px">{{ fmtDate(h.startedAt) }} → {{ fmtDate(h.expiresAt) }}</div>
              </div>
              <div style="text-align: right; flex: none">
                <div style="font-size: 12.5px; font-weight: 600; color: var(--text)">{{ money(h.price) }}</div>
                <span :style="{ color: st(h.status).color }" style="font-size: 10.5px; font-weight: 600">● {{ st(h.status).label }}</span>
              </div>
            </div>
          </div>
        </template>
      </div>
    </div>

    <!-- ============ TAB GÓI & ƯU ĐÃI: sửa giá + ưu đãi (admin-only) ============ -->
    <!-- Bám ĐÚNG 'plans' chứ không phải v-else: prop `view` do trang cha truyền vào, một giá trị
         lạ (VD 'walkin') mà rơi vào v-else sẽ vẽ nhầm trình sửa giá gói ra màn hình khác. -->
    <div v-else-if="tab === 'plans'">
      <div v-if="flash.msg"
        :style="{
          background: flash.type === 'ok' ? 'color-mix(in srgb, var(--green) 14%, transparent)' : 'color-mix(in srgb, var(--sale) 14%, transparent)',
          borderColor: flash.type === 'ok' ? 'var(--green)' : 'var(--sale)',
          color: flash.type === 'ok' ? 'var(--green)' : 'var(--sale)',
        }"
        style="border: 1px solid; border-radius: 10px; padding: 11px 15px; font-size: 13px; margin-bottom: 16px">
        {{ flash.msg }}
      </div>

      <div style="font-size: 12.5px; color: var(--muted); margin-bottom: 16px; line-height: 1.6">
        Chỉ quản trị viên chỉnh sửa được giá &amp; ưu đãi. Hệ thống chặn lưu nếu giá bán không lớn hơn
        <b style="color: var(--muted2)">chi phí ưu đãi tối đa/năm</b> — để gói không bao giờ lỗ khi khách dùng hết hạn mức.
      </div>

      <div v-if="plansLoading" style="padding: 50px; text-align: center; color: var(--muted)">Đang tải gói...</div>
      <div v-else style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 16px; align-items: start">
        <div v-for="p in plans" :key="p.id" style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 20px">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px">
            <span style="font-family: 'JetBrains Mono', monospace; font-size: 11px; letter-spacing: 1px; text-transform: uppercase; color: var(--muted)">{{ p.code }}</span>
            <label style="display: flex; align-items: center; gap: 6px; font-size: 12px; color: var(--muted2); cursor: pointer">
              <input type="checkbox" v-model="forms[p.id].isActive" /> Đang bán
            </label>
          </div>

          <label class="lbl">Tên gói</label>
          <input v-model="forms[p.id].name" class="inp" />

          <div style="display: grid; grid-template-columns: 1.4fr 1fr; gap: 10px; margin-top: 12px">
            <div>
              <label class="lbl">Giá bán (đ)</label>
              <input :value="fmtMoneyInput(forms[p.id].price)" @input="onMoneyInput(forms[p.id], 'price', $event)" class="inp" inputmode="numeric" />
            </div>
            <div>
              <label class="lbl">Thời hạn (tháng)</label>
              <input type="number" min="1" v-model.number="forms[p.id].durationMonths" class="inp" />
            </div>
          </div>

          <div class="sec">Ưu đãi giao hàng</div>
          <label class="chk"><input type="checkbox" v-model="forms[p.id].freeInnerShipping" /> Miễn phí ship nội thành</label>
          <label class="chk"><input type="checkbox" v-model="forms[p.id].freeExpressInner" /> Miễn phí hoả tốc nội thành</label>
          <div style="margin-top: 8px">
            <label class="lbl">Lượt free ship liên tỉnh / năm</label>
            <input type="number" min="0" v-model.number="forms[p.id].interprovinceQuota" class="inp" />
          </div>

          <div class="sec">Dịch vụ kỹ thuật</div>
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px">
            <div>
              <label class="lbl">Vệ sinh máy / năm</label>
              <input type="number" min="0" v-model.number="forms[p.id].cleaningQuota" class="inp" />
            </div>
            <div>
              <label class="lbl">Bảo hành tận nơi / năm</label>
              <input type="number" min="0" v-model.number="forms[p.id].onsiteWarrantyQuota" class="inp" />
            </div>
            <div>
              <label class="lbl">Mượn máy / năm</label>
              <input type="number" min="0" v-model.number="forms[p.id].loanerQuota" class="inp" />
            </div>
          </div>
          <label class="chk" style="margin-top: 8px"><input type="checkbox" v-model="forms[p.id].thermalPaste" /> Vệ sinh kèm tra keo tản nhiệt</label>
          <label class="chk"><input type="checkbox" v-model="forms[p.id].warrantyPriority" /> Ưu tiên hàng đợi bảo hành</label>
          <label class="chk"><input type="checkbox" v-model="forms[p.id].flashSaleEarly" /> Vào Flash Sale sớm</label>
          <label class="chk"><input type="checkbox" v-model="forms[p.id].pcBuildConsult" /> Tư vấn build PC 1-1</label>

          <div class="sec">Voucher kích hoạt</div>
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px">
            <div>
              <label class="lbl">Mệnh giá (đ, 0 = không)</label>
              <input :value="fmtMoneyInput(forms[p.id].activationVoucherAmount)" @input="onMoneyInput(forms[p.id], 'activationVoucherAmount', $event)" class="inp" inputmode="numeric" />
            </div>
            <div>
              <label class="lbl">Đơn tối thiểu (đ)</label>
              <input :value="fmtMoneyInput(forms[p.id].activationVoucherMin)" @input="onMoneyInput(forms[p.id], 'activationVoucherMin', $event)" class="inp" inputmode="numeric" />
            </div>
          </div>

          <!-- Ước tính lãi/lỗ ngay khi gõ -->
          <div style="margin-top: 16px; padding: 12px 14px; border-radius: 10px; background: var(--card2); font-size: 12px; line-height: 1.7">
            <div style="display: flex; justify-content: space-between; color: var(--muted2)">
              <span>Chi phí tối đa/năm</span><span style="font-weight: 600; color: var(--text)">{{ money(maxCost(forms[p.id])) }}</span>
            </div>
            <div style="display: flex; justify-content: space-between; color: var(--muted2)">
              <span>Biên lãi khi dùng hết hạn mức</span>
              <span :style="{ color: margin(forms[p.id]) >= 15 ? 'var(--green)' : (margin(forms[p.id]) >= 0 ? 'var(--amber)' : 'var(--sale)') }" style="font-weight: 700">{{ margin(forms[p.id]) }}%</span>
            </div>
          </div>

          <button
            @click="savePlan(p)" :disabled="saving === p.id"
            style="width: 100%; margin-top: 16px; height: 42px; border: none; border-radius: 10px; background: var(--acc); color: var(--acc-ink); font-weight: 700; font-size: 13.5px; cursor: pointer"
            :style="{ opacity: saving === p.id ? 0.6 : 1 }"
          >{{ saving === p.id ? 'Đang lưu...' : 'Lưu thay đổi' }}</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.lbl { display: block; font-size: 11.5px; color: var(--muted2); margin-bottom: 6px; }
.inp {
  width: 100%; height: 38px; padding: 0 12px; background: var(--card2);
  border: 1px solid var(--line2); border-radius: 9px; color: var(--text); font-size: 13px;
  font-family: inherit; box-sizing: border-box;
}
.inp:focus { outline: none; border-color: var(--acc); }
.sec { font-size: 12px; font-weight: 700; color: var(--muted2); margin: 18px 0 10px; padding-bottom: 6px; border-bottom: 1px solid var(--line); }
.chk { display: flex; align-items: center; gap: 8px; font-size: 12.5px; color: var(--text); cursor: pointer; padding: 4px 0; }
</style>
