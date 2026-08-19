<template>
  <div style="animation: fadeUp 0.35s ease">
    <!-- Tab switcher: tách Mã khuyến mãi / Flash sale thay vì xếp chồng dọc như trước -->
    <div
      style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 8px; display: flex; align-items: center; gap: 6px; margin-bottom: 14px; width: fit-content"
    >
      <div
        v-for="t in TABS"
        :key="t[0]"
        @click="tab = t[0]"
        :style="{
          background: tab === t[0] ? 'var(--acc)' : 'transparent',
          color: tab === t[0] ? 'var(--acc-ink)' : 'var(--muted)',
        }"
        style="display: flex; align-items: center; gap: 8px; padding: 10px 16px; border-radius: 9px; font-size: 13.5px; cursor: pointer; white-space: nowrap; font-weight: 600"
      >
        <i class="bi" :class="t[1]"></i> {{ t[2] }}
      </div>
    </div>

    <!-- ===================== TAB: MÃ KHUYẾN MÃI ===================== -->
    <div v-if="tab === 'coupons'" style="display: grid; grid-template-columns: 340px 1fr; gap: 14px; align-items: start">
      <!-- Tạo mã -->
      <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 18px">
        <div style="font-size: 14.5px; font-weight: 600; color: var(--text); margin-bottom: 16px; display: flex; align-items: center; gap: 8px">
          <i class="bi bi-ticket-perforated" style="color: var(--acc)"></i> Tạo mã khuyến mãi
        </div>

        <label class="lbl">Mã coupon</label>
        <input v-model="form.code" placeholder="VD: SALE50" class="field" style="margin-bottom: 14px" />

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 14px">
          <div>
            <label class="lbl">Loại</label>
            <select v-model="form.type" class="field" style="cursor: pointer">
              <option value="percent">Phần trăm (%)</option>
              <option value="fixed">Tiền mặt (đ)</option>
            </select>
          </div>
          <div>
            <label class="lbl">Giá trị</label>
            <input v-model="form.value" placeholder="0" class="field" />
          </div>
        </div>

        <!-- Giảm tối đa chỉ có ý nghĩa với loại % — với tiền mặt giá trị đã là số tiền cố định -->
        <div v-if="form.type === 'percent'" style="margin-bottom: 14px">
          <label class="lbl">Giảm tối đa (đ)</label>
          <input v-model="form.maxDiscountAmount" placeholder="Không giới hạn" class="field" />
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 14px">
          <div>
            <label class="lbl">Đơn tối thiểu</label>
            <input v-model="form.min" placeholder="0" class="field" />
          </div>
          <div>
            <label class="lbl">Hạn dùng</label>
            <input v-model="form.exp" type="date" class="field" />
          </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 14px">
          <div>
            <label class="lbl">Lượt dùng tối đa</label>
            <input v-model="form.maxUses" placeholder="Không giới hạn" class="field" />
          </div>
          <div>
            <label class="lbl">Giá xu (đổi ở trang KM)</label>
            <input v-model="form.xuCost" placeholder="Trống = không đổi bằng xu" class="field" />
          </div>
        </div>

        <!-- Cộng dồn/loại trừ: mặc định mã KHÔNG cộng dồn (phải đi 1 mình) — bật lên nếu muốn
             cho khách dùng chung với mã khác. Nhóm loại trừ chỉ hiện khi đã bật cộng dồn, vì
             không có ý nghĩa gì với mã đi 1 mình. -->
        <div style="margin-bottom: 14px">
          <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; font-size: 13px; color: var(--text)">
            <input type="checkbox" v-model="form.stackable" style="width: 16px; height: 16px; cursor: pointer" />
            Cho phép dùng chung với mã khác (cộng dồn)
          </label>
        </div>
        <div v-if="form.stackable" style="margin-bottom: 14px">
          <label class="lbl">Nhóm loại trừ (tuỳ chọn)</label>
          <input v-model="form.exclusiveGroup" placeholder="Trống = không loại trừ mã nào" class="field" />
          <div style="font-size: 11px; color: var(--muted); margin-top: 5px">
            Các mã cùng tên nhóm sẽ không dùng chung được với nhau, dù cả 2 đều cho cộng dồn.
          </div>
        </div>

        <div v-if="error" style="color: var(--sale); font-size: 12px; margin-bottom: 10px">{{ error }}</div>

        <button
          @click="submit" :disabled="saving"
          style="width: 100%; height: 42px; border-radius: 10px; border: none; background: var(--acc); color: var(--acc-ink); font-weight: 700; font-size: 13px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 7px"
        >
          <i class="bi bi-plus-circle"></i> {{ saving ? 'Đang tạo...' : 'Tạo mã' }}
        </button>
      </div>

      <!-- Danh sách -->
      <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; overflow: hidden">
        <div style="padding: 14px 18px; font-size: 14.5px; font-weight: 600; color: var(--text); border-bottom: 1px solid var(--line)">
          Danh sách mã khuyến mãi
        </div>
        <div style="display: flex; align-items: center; gap: 10px; padding: 12px 18px; border-bottom: 1px solid var(--line); flex-wrap: wrap">
          <select
            v-model="statusFilter"
            style="height: 32px; padding: 0 10px; border-radius: 8px; border: 1px solid var(--line2); background: var(--card2); color: var(--text); font-size: 12.5px; cursor: pointer"
          >
            <option value="all">Mọi trạng thái</option>
            <option value="active">Đang chạy</option>
            <option value="expired">Hết hạn</option>
            <option value="paused">Tạm dừng</option>
          </select>
          <button
            v-if="statusFilter !== 'all'" @click="statusFilter = 'all'"
            style="background: transparent; border: none; color: var(--sale); font-size: 12px; cursor: pointer"
          >
            Xóa lọc
          </button>
          <div style="flex: 1"></div>
          <span class="mono" style="font-size: 11.5px; color: var(--muted)">{{ rows.length }} mã</span>
        </div>
        <DataTable
          :columns="cols"
          :rows="rows"
          row-key="code"
          :tim-kiem="ui.search"
          trong="Chưa có mã khuyến mãi nào."
        >
          <template #o-code="{ row }">
            <span class="mono" style="color: var(--acc); font-weight: 700; letter-spacing: 0.5px">{{ row.code }}</span>
          </template>
          <template #o-type="{ row }">
            <span style="font-size: 11.5px; font-weight: 600" :style="{ color: row.typeColor }">{{ row.type }}</span>
          </template>
          <template #o-value="{ row }">
            <span class="mono" style="font-weight: 700">{{ row.value }}</span>
          </template>
          <template #o-min="{ row }">
            <span class="mono" style="color: var(--muted2); font-size: 12px">{{ row.min }}</span>
          </template>
          <template #o-used="{ row }">
            <div style="display: flex; align-items: center; gap: 8px">
              <span class="mono" style="font-size: 11.5px; color: var(--muted2); white-space: nowrap">{{ row.used }}</span>
              <!-- Mã không giới hạn lượt (usedPct = '—') thì không vẽ thanh tiến độ: không có
                   mẫu số nên mọi bề rộng đều vô nghĩa. -->
              <div v-if="row.usedPct !== '—'" style="flex: 1; height: 5px; border-radius: 4px; background: var(--card2); overflow: hidden">
                <div style="height: 100%; background: var(--acc); border-radius: 4px" :style="{ width: row.usedPct }"></div>
              </div>
            </div>
          </template>
          <template #o-exp="{ row }">
            <span style="color: var(--muted2); font-size: 12px">{{ row.exp }}</span>
          </template>
          <template #o-xuCost="{ row }">
            <span class="mono" style="font-size: 12px" :style="{ color: row.xuCost ? '#d9b34a' : 'var(--muted2)' }">
              {{ row.xuCost ? '🪙 ' + row.xuCost : '—' }}
            </span>
          </template>
          <template #o-stackable="{ row }">
            <span
              v-if="row.stackable"
              :title="row.exclusiveGroup ? `Loại trừ với mã cùng nhóm: ${row.exclusiveGroup}` : 'Cộng dồn được với mọi mã khác'"
              style="font-size: 11px; font-weight: 600; color: var(--green); display: inline-flex; align-items: center; gap: 4px"
            >
              <i class="bi bi-link-45deg"></i> Cộng dồn
            </span>
            <span v-else style="font-size: 11px; color: var(--muted2)">Đi 1 mình</span>
          </template>
          <template #o-stText="{ row }">
            <span
              style="display: inline-flex; align-items: center; gap: 5px; font-size: 11.5px; font-weight: 600; padding: 3px 9px; border-radius: 20px"
              :style="{ background: row.stBg, color: row.stColor }"
            >
              <span style="width: 6px; height: 6px; border-radius: 50%" :style="{ background: row.stColor }"></span>{{ row.stText }}
            </span>
          </template>
          <template #o-thaoTac="{ row }">
            <button
              @click="removeCoupon(row)"
              style="width: 30px; height: 30px; border-radius: 8px; border: 1px solid var(--line2); background: var(--card); color: var(--sale); cursor: pointer"
            >
              <i class="bi bi-trash3" style="font-size: 12px"></i>
            </button>
          </template>
        </DataTable>
      </div>
    </div>

    <!-- ===================== TAB: FLASH SALE ===================== -->
    <!-- Dùng FlashSalePanel thật (bản nháp + publish, tìm sản phẩm thật), không phải bảng demo
         trong bản thiết kế. -->
    <FlashSalePanel v-else />
  </div>
</template>

<script setup>
import { computed, reactive, ref } from 'vue';
import { COUPONS, refreshAdminCoupons } from '../data/adminData';
import { createCoupon, deleteCoupon } from '../api/admin';
import { ui } from '../uiState';
import FlashSalePanel from '../components/FlashSalePanel.vue';
import DataTable from '../components/DataTable.vue';

const tab = ref('coupons');
const TABS = [
  ['coupons', 'bi-ticket-perforated', 'Mã khuyến mãi'],
  ['flash', 'bi-lightning-charge-fill', 'Flash sale'],
];

const form = reactive({
  code: '',
  type: 'percent',
  value: '',
  maxDiscountAmount: '',
  min: '',
  exp: '',
  maxUses: '',
  xuCost: '',
});
const error = ref('');
const saving = ref(false);
// Cột cho DataTable: mỗi cột tự có phễu lọc/sắp xếp kiểu Excel (xem components/DataTable.vue).
// value/text tách riêng khi giá trị dùng để LỌC khác chuỗi hiển thị (VD số tiền đã format).
const cols = [
  { key: 'code', label: 'Mã' },
  { key: 'type', label: 'Loại' },
  { key: 'value', label: 'Giá trị', align: 'right', kieu: 'so', value: (r) => r.giaTriSo, text: (r) => r.value },
  { key: 'min', label: 'Đơn tối thiểu', align: 'right', kieu: 'so', value: (r) => r.donToiThieuSo, text: (r) => r.min },
  { key: 'used', label: 'Đã dùng', kieu: 'so', value: (r) => r.daDungSo, text: (r) => r.used },
  { key: 'exp', label: 'Hạn', kieu: 'ngay', value: (r) => r.hetHanLuc, text: (r) => r.exp },
  { key: 'xuCost', label: 'Giá xu', align: 'right', kieu: 'so', text: (r) => (r.xuCost ? '🪙 ' + r.xuCost : '—') },
  { key: 'stackable', label: 'Cộng dồn', align: 'center', text: (r) => (r.stackable ? 'Cộng dồn' : 'Đi 1 mình') },
  { key: 'stText', label: 'Trạng thái' },
  { key: 'thaoTac', label: '', align: 'right', loc: false },
];
const statusFilter = ref('all');
// Tìm theo từ khoá đã do DataTable đảm nhận (quét mọi cột, bỏ dấu) — ở đây chỉ còn lọc theo
// tab trạng thái phía trên bảng.
const rows = computed(() =>
  COUPONS.filter((c) => statusFilter.value === 'all' || c.status === statusFilter.value),
);

async function submit() {
  error.value = '';
  if (!form.code.trim() || !form.value) {
    error.value = 'Vui lòng nhập mã và giá trị giảm';
    return;
  }
  saving.value = true;
  try {
    await createCoupon({
      code: form.code.trim(),
      discountType: form.type,
      discountValue: Number(form.value),
      maxDiscountAmount: form.type === 'percent' && form.maxDiscountAmount ? Number(form.maxDiscountAmount) : null,
      minOrderValue: form.min ? Number(form.min) : 0,
      maxUses: form.maxUses ? Number(form.maxUses) : null,
      expiresAt: form.exp || null,
      xuCost: form.xuCost ? Number(form.xuCost) : null,
    });
    await refreshAdminCoupons();
    form.code = '';
    form.value = '';
    form.maxDiscountAmount = '';
    form.min = '';
    form.exp = '';
    form.maxUses = '';
    form.xuCost = '';
  } catch (e) {
    error.value = e.response?.data?.message || 'Có lỗi khi tạo mã';
  } finally {
    saving.value = false;
  }
}

async function removeCoupon(c) {
  if (!window.confirm(`Xoá mã "${c.code}"?`)) return;
  await deleteCoupon(c.id);
  await refreshAdminCoupons();
}
</script>

<style scoped>
.lbl {
  font-size: 11px;
  font-weight: 600;
  color: var(--muted);
  text-transform: uppercase;
  display: block;
  margin-bottom: 6px;
}
.field {
  width: 100%;
  height: 40px;
  padding: 0 12px;
  border-radius: 9px;
  background: var(--card2);
  border: 1px solid var(--line2);
  color: var(--text);
  font-size: 13px;
  box-sizing: border-box;
  font-family: inherit;
}
.field:focus {
  outline: none;
  border-color: var(--acc);
}
.th {
  text-align: left;
  padding: 10px 18px;
  font-size: 11px;
  font-weight: 600;
  color: var(--muted);
  text-transform: uppercase;
  letter-spacing: 0.4px;
}
</style>
