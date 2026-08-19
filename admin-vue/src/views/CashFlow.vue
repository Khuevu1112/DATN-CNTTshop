<template>
  <div style="animation: fadeUp 0.35s ease">
    <!-- Bộ lọc thời gian -->
    <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 16px 18px; margin-bottom: 16px; display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap">
      <div>
        <label class="lbl">Từ ngày</label>
        <input type="date" class="fld" v-model="fromDate" :max="toDate" style="width: 165px" />
      </div>
      <div>
        <label class="lbl">Đến ngày</label>
        <input type="date" class="fld" v-model="toDate" :min="fromDate" :max="today" style="width: 165px" />
      </div>
      <div>
        <label class="lbl">Nhóm theo</label>
        <div style="display: flex; border: 1px solid var(--line2); border-radius: 8px; overflow: hidden">
          <button
            v-for="g in [['day', 'Ngày'], ['month', 'Tháng'], ['year', 'Năm']]"
            :key="g[0]"
            @click="groupBy = g[0]"
            :style="{ background: groupBy === g[0] ? 'var(--acc)' : 'var(--card)', color: groupBy === g[0] ? 'var(--acc-ink)' : 'var(--muted2)' }"
            style="height: 38px; padding: 0 14px; border: none; font-size: 12.5px; font-weight: 600; cursor: pointer"
          >
            {{ g[1] }}
          </button>
        </div>
      </div>
      <div style="display: flex; gap: 8px">
        <button class="btn-ghost" @click="setQuickRange(7)">7 ngày</button>
        <button class="btn-ghost" @click="setQuickRange(30)">30 ngày</button>
        <button class="btn-ghost" @click="setThisMonth">Tháng này</button>
      </div>
      <div style="flex: 1"></div>
      <button class="btn-acc" :disabled="loading" @click="load">{{ loading ? 'Đang tải...' : 'Xem báo cáo' }}</button>
    </div>

    <div v-if="error" class="alert-err" style="margin-bottom: 16px">{{ error }}</div>

    <div v-if="loading" class="spin"></div>

    <template v-else-if="report">
      <!-- 3 thẻ tổng -->
      <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; margin-bottom: 18px">
        <div class="sum-card" style="border-left: 3px solid var(--green)">
          <div class="sum-lbl">Tổng tiền vào</div>
          <div class="sum-val mono" style="color: var(--green)">{{ short(report.totalCashIn) }}</div>
          <div class="sum-sub">Doanh thu đơn hàng đã giao thành công</div>
        </div>
        <div class="sum-card" style="border-left: 3px solid var(--sale)">
          <div class="sum-lbl">Tổng tiền ra</div>
          <div class="sum-val mono" style="color: var(--sale)">{{ short(report.totalCashOut) }}</div>
          <div class="sum-sub">Chi phí nhập hàng (phiếu nhập kho)</div>
        </div>
        <div class="sum-card" :style="{ borderLeft: '3px solid ' + (report.netCashFlow >= 0 ? 'var(--acc)' : 'var(--sale)') }">
          <div class="sum-lbl">Dòng tiền ròng</div>
          <div class="sum-val mono" :style="{ color: report.netCashFlow >= 0 ? 'var(--acc)' : 'var(--sale)' }">
            {{ report.netCashFlow >= 0 ? '+' : '' }}{{ short(report.netCashFlow) }}
          </div>
          <div class="sum-sub">Tiền vào − Tiền ra</div>
        </div>
      </div>

      <!-- Biểu đồ cột -->
      <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 18px; margin-bottom: 16px">
        <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 14px; font-size: 12px; color: var(--muted2)">
          <div style="display: flex; align-items: center; gap: 6px"><span class="dot" style="background: var(--green)"></span> Tiền vào</div>
          <div style="display: flex; align-items: center; gap: 6px"><span class="dot" style="background: var(--sale)"></span> Tiền ra</div>
        </div>

        <div v-if="!report.points.length" style="padding: 30px; text-align: center; color: var(--muted)">Không có dữ liệu trong khoảng đã chọn</div>
        <svg v-else :viewBox="`0 0 ${chartW} ${chartH}`" style="width: 100%; height: 260px; display: block">
          <line v-for="i in 4" :key="'gl' + i" :x1="padL" :x2="chartW - 10" :y1="gridY(i)" :y2="gridY(i)" stroke="var(--line)" stroke-width="1" />
          <g v-for="(p, idx) in report.points" :key="idx">
            <rect :x="barX(idx)" :y="barY(p.cashIn)" :width="barW / 2 - 1.5" :height="barH(p.cashIn)" fill="var(--green)" rx="2" />
            <rect :x="barX(idx) + barW / 2 + 1.5" :y="barY(p.cashOut)" :width="barW / 2 - 1.5" :height="barH(p.cashOut)" fill="var(--sale)" rx="2" />
            <text
              v-if="shouldLabel(idx)"
              :x="barX(idx) + barW / 2"
              :y="chartH - 6"
              text-anchor="middle"
              font-size="10"
              fill="var(--muted)"
            >{{ p.label }}</text>
          </g>
        </svg>
      </div>

      <!-- Bảng chi tiết -->
      <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; overflow: hidden">
        <table style="width: 100%; border-collapse: collapse; font-size: 12.5px">
          <thead>
            <tr style="background: var(--card2)">
              <th class="th">Thời gian</th>
              <th class="th" style="text-align: right">Tiền vào</th>
              <th class="th" style="text-align: right">Tiền ra</th>
              <th class="th" style="text-align: right">Dòng tiền ròng</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(p, idx) in report.points" :key="idx" style="border-top: 1px solid var(--line)">
              <td class="td">{{ p.label }}</td>
              <td class="td mono" style="text-align: right; color: var(--green)">{{ p.cashIn ? short(p.cashIn) : '—' }}</td>
              <td class="td mono" style="text-align: right; color: var(--sale)">{{ p.cashOut ? short(p.cashOut) : '—' }}</td>
              <td class="td mono" style="text-align: right; font-weight: 700" :style="{ color: p.net >= 0 ? 'var(--acc)' : 'var(--sale)' }">
                {{ p.net >= 0 ? '+' : '' }}{{ short(p.net) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { short } from '../data/adminData';
import { getCashFlow } from '../api/admin';

const today = new Date().toISOString().slice(0, 10);
const fromDate = ref(new Date(Date.now() - 29 * 86400000).toISOString().slice(0, 10));
const toDate = ref(today);
const groupBy = ref('day');

const loading = ref(false);
const error = ref('');
const report = ref(null);

function setQuickRange(days) {
  fromDate.value = new Date(Date.now() - (days - 1) * 86400000).toISOString().slice(0, 10);
  toDate.value = today;
  groupBy.value = days > 14 ? 'day' : 'day';
  load();
}
function setThisMonth() {
  const d = new Date();
  fromDate.value = new Date(d.getFullYear(), d.getMonth(), 1).toISOString().slice(0, 10);
  toDate.value = today;
  groupBy.value = 'day';
  load();
}

async function load() {
  loading.value = true;
  error.value = '';
  try {
    report.value = await getCashFlow(fromDate.value, toDate.value, groupBy.value);
  } catch (e) {
    error.value = e.response?.data?.message || 'Không tải được báo cáo dòng tiền.';
  } finally {
    loading.value = false;
  }
}

// ===== vẽ biểu đồ cột bằng SVG thuần =====
const chartW = 900;
const chartH = 260;
const padL = 10;
const padTop = 14;
const padBottom = 24;

const maxVal = computed(() => {
  if (!report.value?.points?.length) return 1;
  const m = Math.max(...report.value.points.flatMap((p) => [p.cashIn, p.cashOut]));
  return m > 0 ? m : 1;
});

const barW = computed(() => {
  const n = report.value?.points?.length || 1;
  return (chartW - padL - 10) / n;
});

function barX(idx) {
  return padL + idx * barW.value + 2;
}
function barH(val) {
  const usable = chartH - padTop - padBottom;
  return Math.max(1, (val / maxVal.value) * usable);
}
function barY(val) {
  return chartH - padBottom - barH(val);
}
function gridY(i) {
  const usable = chartH - padTop - padBottom;
  return padTop + (usable / 4) * i;
}
function shouldLabel(idx) {
  const n = report.value?.points?.length || 1;
  const step = Math.ceil(n / 12); // tối đa ~12 nhãn để không chồng chữ
  return idx % step === 0;
}

onMounted(load);
</script>

<style scoped>
.lbl {
  display: block;
  font-size: 11.5px;
  font-weight: 600;
  color: var(--muted2);
  margin-bottom: 5px;
}
.btn-ghost {
  height: 38px;
  padding: 0 14px;
  border-radius: 9px;
  border: 1px solid var(--line2);
  background: var(--card);
  color: var(--text);
  font-size: 12.5px;
  font-weight: 600;
  cursor: pointer;
}
.btn-acc {
  height: 38px;
  padding: 0 20px;
  border-radius: 9px;
  border: none;
  background: var(--acc);
  color: var(--acc-ink);
  font-size: 12.5px;
  font-weight: 700;
  cursor: pointer;
}
.btn-acc:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}
.alert-err {
  background: color-mix(in srgb, var(--sale) 14%, transparent);
  color: var(--sale);
  border-radius: 9px;
  padding: 10px 14px;
  font-size: 12.5px;
}
.sum-card {
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 14px;
  padding: 16px 18px;
}
.sum-lbl {
  font-size: 12.5px;
  color: var(--muted);
  font-weight: 500;
}
.sum-val {
  font-size: 26px;
  font-weight: 700;
  margin-top: 6px;
  line-height: 1;
}
.sum-sub {
  font-size: 11.5px;
  color: var(--muted);
  margin-top: 8px;
}
.dot {
  width: 9px;
  height: 9px;
  border-radius: 3px;
  display: inline-block;
}
.th {
  text-align: left;
  padding: 10px 16px;
  font-size: 11px;
  font-weight: 600;
  color: var(--muted2);
  text-transform: uppercase;
}
.td {
  padding: 9px 16px;
  color: var(--text);
}
</style>
