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
      <button class="btn-ghost" :disabled="exporting || !report" @click="xuatExcel">
        <i class="bi bi-file-earmark-excel" style="margin-right: 6px"></i>{{ exporting ? 'Đang xuất...' : 'Xuất Excel' }}
      </button>
      <button class="btn-acc" :disabled="loading" @click="load">{{ loading ? 'Đang tải...' : 'Xem báo cáo' }}</button>
    </div>

    <div v-if="error" class="alert-err" style="margin-bottom: 16px">{{ error }}</div>

    <div v-if="loading" class="spin"></div>

    <template v-else-if="report">
      <!-- Cảnh báo dòng tiền âm -->
      <div v-if="report.netCashFlow < 0" class="alert-err" style="margin-bottom: 16px; display: flex; align-items: center; gap: 8px">
        <i class="bi bi-exclamation-triangle-fill"></i>
        Dòng tiền ròng trong khoảng đã chọn đang <b>âm</b> ({{ short(report.netCashFlow) }}) — chi phí nhập hàng đang vượt doanh thu ghi nhận được.
      </div>

      <!-- 3 thẻ tổng -->
      <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; margin-bottom: 18px">
        <div class="sum-card" style="border-left: 3px solid var(--green)">
          <div style="display: flex; align-items: center; justify-content: space-between">
            <div class="sum-lbl">Tổng tiền vào</div>
            <span v-if="report.cashInChangePct != null" class="pct-badge" :class="report.cashInChangePct >= 0 ? 'pct-up' : 'pct-down'">
              {{ report.cashInChangePct >= 0 ? '▲' : '▼' }} {{ Math.abs(report.cashInChangePct).toFixed(1) }}%
            </span>
          </div>
          <div class="sum-val mono" style="color: var(--green)">{{ short(report.totalCashIn) }}</div>
          <div class="sum-sub">Online: {{ short(tongOnline) }} · POS: {{ short(tongPos) }}</div>
        </div>
        <div class="sum-card" style="border-left: 3px solid var(--sale)">
          <div style="display: flex; align-items: center; justify-content: space-between">
            <div class="sum-lbl">Tổng tiền ra</div>
            <span v-if="report.cashOutChangePct != null" class="pct-badge" :class="report.cashOutChangePct <= 0 ? 'pct-up' : 'pct-down'">
              {{ report.cashOutChangePct >= 0 ? '▲' : '▼' }} {{ Math.abs(report.cashOutChangePct).toFixed(1) }}%
            </span>
          </div>
          <div class="sum-val mono" style="color: var(--sale)">{{ short(report.totalCashOut) }}</div>
          <div class="sum-sub">Chi phí nhập hàng (phiếu nhập kho)</div>
        </div>
        <div class="sum-card" :style="{ borderLeft: '3px solid ' + (report.netCashFlow >= 0 ? 'var(--acc)' : 'var(--sale)') }">
          <div style="display: flex; align-items: center; justify-content: space-between">
            <div class="sum-lbl">Dòng tiền ròng</div>
            <span v-if="netChangePct != null" class="pct-badge" :class="netChangePct >= 0 ? 'pct-up' : 'pct-down'">
              {{ netChangePct >= 0 ? '▲' : '▼' }} {{ Math.abs(netChangePct).toFixed(1) }}%
            </span>
          </div>
          <div class="sum-val mono" :style="{ color: report.netCashFlow >= 0 ? 'var(--acc)' : 'var(--sale)' }">
            {{ report.netCashFlow >= 0 ? '+' : '' }}{{ short(report.netCashFlow) }}
          </div>
          <div class="sum-sub">So với kỳ trước ({{ short(prevNet) }})</div>
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
          <g v-for="i in [0, 1, 2, 3, 4]" :key="'gl' + i">
            <line :x1="padL" :x2="chartW - 10" :y1="gridY(i)" :y2="gridY(i)" stroke="var(--line)" stroke-width="1" />
            <text :x="padL - 8" :y="gridY(i) + 3" text-anchor="end" font-size="10" fill="var(--muted)">{{ gridLabel(i) }}</text>
          </g>
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
        <div style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-bottom: 1px solid var(--line)">
          <label style="display: flex; align-items: center; gap: 7px; font-size: 12px; color: var(--muted2); cursor: pointer">
            <input type="checkbox" v-model="hideEmpty" />
            Chỉ hiện thời điểm có phát sinh
          </label>
          <div style="font-size: 11.5px; color: var(--muted)">Bấm vào 1 dòng để xem chi tiết đơn hàng / phiếu nhập</div>
        </div>

        <table style="width: 100%; border-collapse: collapse; font-size: 12.5px">
          <thead>
            <tr style="background: var(--card2)">
              <th class="th">Thời gian</th>
              <th class="th" style="text-align: right">Tiền vào</th>
              <th class="th" style="text-align: right">Tiền ra</th>
              <th class="th" style="text-align: right">Dòng tiền ròng</th>
              <th class="th" style="text-align: right">Luỹ kế</th>
            </tr>
          </thead>
          <tbody>
            <template v-for="(p, idx) in filteredPoints" :key="idx">
              <tr
                @click="toggleDetail(p, idx)"
                style="border-top: 1px solid var(--line); cursor: pointer"
                :style="{ background: p.net < 0 ? 'color-mix(in srgb, var(--sale) 7%, transparent)' : (openIdx === idx ? 'var(--card2)' : 'transparent') }"
                class="row-hover"
              >
                <td class="td">
                  <i class="bi" :class="openIdx === idx ? 'bi-chevron-down' : 'bi-chevron-right'" style="font-size: 10px; color: var(--muted); margin-right: 6px"></i>
                  {{ p.label }}
                  <i v-if="p.net < 0" class="bi bi-exclamation-triangle-fill" style="color: var(--sale); margin-left: 6px" title="Dòng tiền âm"></i>
                </td>
                <td class="td mono" style="text-align: right; color: var(--green)">
                  {{ p.cashIn ? short(p.cashIn) : '—' }}
                  <span v-if="p.orderCount" style="color: var(--muted); font-size: 10.5px">({{ p.orderCount }} đơn)</span>
                </td>
                <td class="td mono" style="text-align: right; color: var(--sale)">
                  {{ p.cashOut ? short(p.cashOut) : '—' }}
                  <span v-if="p.movementCount" style="color: var(--muted); font-size: 10.5px">({{ p.movementCount }} phiếu)</span>
                </td>
                <td class="td mono" style="text-align: right; font-weight: 700" :style="{ color: p.net >= 0 ? 'var(--acc)' : 'var(--sale)' }">
                  {{ p.net >= 0 ? '+' : '' }}{{ short(p.net) }}
                </td>
                <td class="td mono" style="text-align: right; color: var(--muted2)">
                  {{ p.cumulativeNet >= 0 ? '+' : '' }}{{ short(p.cumulativeNet) }}
                </td>
              </tr>
              <tr v-if="openIdx === idx" style="background: var(--card2)">
                <td colspan="5" style="padding: 14px 16px 18px 34px">
                  <div v-if="detailLoading" style="font-size: 12px; color: var(--muted)">Đang tải chi tiết...</div>
                  <div v-else-if="detailData" style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px">
                    <div>
                      <div class="detail-title">Đơn hàng ({{ detailData.orders.length }})</div>
                      <div v-if="!detailData.orders.length" class="detail-empty">Không có đơn hàng nào</div>
                      <div v-for="o in detailData.orders" :key="o.id" class="detail-row">
                        <span class="mono">{{ o.code }}</span>
                        <span style="color: var(--muted2); font-size: 10.5px">{{ o.channel === 'pos' ? 'Tại quầy' : 'Online' }}</span>
                        <span class="mono" style="margin-left: auto; color: var(--green)">{{ short(o.total) }}</span>
                      </div>
                    </div>
                    <div>
                      <div class="detail-title">Phiếu nhập kho ({{ detailData.stockMovements.length }})</div>
                      <div v-if="!detailData.stockMovements.length" class="detail-empty">Không có phiếu nhập nào</div>
                      <div v-for="m in detailData.stockMovements" :key="m.id" class="detail-row">
                        <span>{{ m.productName }}</span>
                        <span style="color: var(--muted2); font-size: 10.5px">SKU {{ m.sku }} · x{{ m.changeQty }}</span>
                        <span class="mono" style="margin-left: auto; color: var(--sale)">{{ short(m.changeQty * m.unitCost) }}</span>
                      </div>
                    </div>
                  </div>
                </td>
              </tr>
            </template>
            <tr v-if="!filteredPoints.length">
              <td colspan="5" style="padding: 24px; text-align: center; color: var(--muted)">Không có thời điểm nào phát sinh trong khoảng đã chọn</td>
            </tr>
          </tbody>
          <tfoot v-if="report.points.length">
            <tr style="border-top: 2px solid var(--line2); background: var(--card2); font-weight: 700">
              <td class="td">Tổng / Trung bình mỗi {{ groupBy === 'day' ? 'ngày' : groupBy === 'month' ? 'tháng' : 'năm' }}</td>
              <td class="td mono" style="text-align: right; color: var(--green)">
                {{ short(report.totalCashIn) }}
                <div style="font-size: 10.5px; color: var(--muted); font-weight: 400">TB {{ short(report.totalCashIn / report.points.length) }}</div>
              </td>
              <td class="td mono" style="text-align: right; color: var(--sale)">
                {{ short(report.totalCashOut) }}
                <div style="font-size: 10.5px; color: var(--muted); font-weight: 400">TB {{ short(report.totalCashOut / report.points.length) }}</div>
              </td>
              <td class="td mono" style="text-align: right" :style="{ color: report.netCashFlow >= 0 ? 'var(--acc)' : 'var(--sale)' }">
                {{ report.netCashFlow >= 0 ? '+' : '' }}{{ short(report.netCashFlow) }}
              </td>
              <td class="td"></td>
            </tr>
          </tfoot>
        </table>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { short } from '../data/adminData';
import { getCashFlow, getCashFlowDetail, exportCashFlow } from '../api/admin';

const today = new Date().toISOString().slice(0, 10);
const fromDate = ref(new Date(Date.now() - 29 * 86400000).toISOString().slice(0, 10));
const toDate = ref(today);
const groupBy = ref('day');

const loading = ref(false);
const exporting = ref(false);
const error = ref('');
const report = ref(null);
const hideEmpty = ref(true);

function setQuickRange(days) {
  fromDate.value = new Date(Date.now() - (days - 1) * 86400000).toISOString().slice(0, 10);
  toDate.value = today;
  load();
}
function setThisMonth() {
  const d = new Date();
  fromDate.value = new Date(d.getFullYear(), d.getMonth(), 1).toISOString().slice(0, 10);
  toDate.value = today;
  load();
}

async function load() {
  loading.value = true;
  error.value = '';
  openIdx.value = -1;
  detailData.value = null;
  try {
    report.value = await getCashFlow(fromDate.value, toDate.value, groupBy.value);
  } catch (e) {
    error.value = e.response?.data?.message || 'Không tải được báo cáo dòng tiền.';
  } finally {
    loading.value = false;
  }
}

async function xuatExcel() {
  exporting.value = true;
  try {
    const blob = await exportCashFlow(fromDate.value, toDate.value, groupBy.value);
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `dong-tien_${fromDate.value}_${toDate.value}.xlsx`;
    document.body.appendChild(a);
    a.click();
    a.remove();
    window.URL.revokeObjectURL(url);
  } catch (e) {
    error.value = 'Không xuất được file Excel.';
  } finally {
    exporting.value = false;
  }
}

// ===== 1. Ẩn bớt thời điểm trống =====
const filteredPoints = computed(() => {
  if (!report.value) return [];
  if (!hideEmpty.value) return report.value.points;
  return report.value.points.filter((p) => p.cashIn || p.cashOut);
});

// ===== 6. Tổng theo kênh (dùng cho thẻ tổng) =====
const tongOnline = computed(() => (report.value?.points || []).reduce((s, p) => s + (p.cashInOnline || 0), 0));
const tongPos = computed(() => (report.value?.points || []).reduce((s, p) => s + (p.cashInPos || 0), 0));

// ===== 8. So sánh % với kỳ trước =====
const prevNet = computed(() => (report.value ? report.value.prevTotalCashIn - report.value.prevTotalCashOut : 0));
const netChangePct = computed(() => {
  if (!report.value || !prevNet.value) return null;
  return ((report.value.netCashFlow - prevNet.value) / Math.abs(prevNet.value)) * 100;
});

// ===== 5. Click 1 dòng để xem chi tiết đơn/phiếu =====
const openIdx = ref(-1);
const detailLoading = ref(false);
const detailData = ref(null);
const detailCache = new Map();

async function toggleDetail(p, idx) {
  if (openIdx.value === idx) {
    openIdx.value = -1;
    return;
  }
  openIdx.value = idx;
  const cacheKey = p.periodFrom + '_' + p.periodTo;
  if (detailCache.has(cacheKey)) {
    detailData.value = detailCache.get(cacheKey);
    return;
  }
  detailLoading.value = true;
  detailData.value = null;
  try {
    const data = await getCashFlowDetail(p.periodFrom, p.periodTo);
    detailCache.set(cacheKey, data);
    detailData.value = data;
  } catch (e) {
    detailData.value = { orders: [], stockMovements: [] };
  } finally {
    detailLoading.value = false;
  }
}

// ===== vẽ biểu đồ cột bằng SVG thuần =====
const chartW = 900;
const chartH = 260;
const padL = 54;
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
/** Giá trị tiền tương ứng với đường kẻ i (0 = trên cùng = mức cao nhất, 4 = dưới cùng = 0đ). */
function gridLabel(i) {
  const val = maxVal.value * ((4 - i) / 4);
  return short(Math.round(val));
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
.btn-ghost:disabled {
  opacity: 0.55;
  cursor: not-allowed;
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
.row-hover:hover {
  background: var(--card2) !important;
}
.pct-badge {
  font-size: 10.5px;
  font-weight: 700;
  padding: 2px 7px;
  border-radius: 20px;
}
.pct-up {
  background: color-mix(in srgb, var(--green) 16%, transparent);
  color: var(--green);
}
.pct-down {
  background: color-mix(in srgb, var(--sale) 16%, transparent);
  color: var(--sale);
}
.detail-title {
  font-size: 11px;
  font-weight: 700;
  color: var(--muted2);
  text-transform: uppercase;
  margin-bottom: 8px;
}
.detail-empty {
  font-size: 12px;
  color: var(--muted);
}
.detail-row {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  padding: 6px 0;
  border-bottom: 1px solid var(--line);
}
</style>
