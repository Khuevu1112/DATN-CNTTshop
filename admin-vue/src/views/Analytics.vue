<template>
  <div v-if="loading" class="spin"></div>
  <div v-else style="animation: fadeUp 0.35s ease">
    <div
      style="display: flex; align-items: center; gap: 8px; margin-bottom: 16px"
    >
      <div style="font-size: 13px; color: var(--muted)">9 tháng gần nhất · dữ liệu thật từ đơn hàng</div>
    </div>

    <div
      style="
        background: var(--card);
        border: 1px solid var(--line);
        border-radius: 14px;
        padding: 18px 18px 8px;
        margin-bottom: 16px;
      "
    >
      <div
        style="
          display: flex;
          align-items: flex-start;
          justify-content: space-between;
          margin-bottom: 6px;
        "
      >
        <div>
          <div style="font-size: 13px; color: var(--muted); font-weight: 500">
            Tổng doanh thu · 9 tháng gần nhất
          </div>
          <div
            class="mono"
            style="
              font-size: 30px;
              font-weight: 700;
              color: var(--text);
              margin-top: 6px;
              line-height: 1;
            "
          >
            {{ short(metrics.totalRevenue) }}
          </div>
          <div
            style="
              display: flex;
              align-items: center;
              gap: 5px;
              margin-top: 8px;
              font-size: 12.5px;
            "
          >
            <span
              v-if="metrics.totalRevenueDeltaPct != null"
              :style="{ color: metrics.totalRevenueDeltaPct >= 0 ? 'var(--green)' : 'var(--sale)' }"
              style="display: inline-flex; align-items: center; gap: 2px; font-weight: 600"
              ><i :class="metrics.totalRevenueDeltaPct >= 0 ? 'bi bi-arrow-up-short' : 'bi bi-arrow-down-short'"></i>{{ Math.abs(metrics.totalRevenueDeltaPct) }}%</span
            ><span style="color: var(--muted)">{{ metrics.totalRevenueDeltaPct != null ? 'so với 9 tháng trước' : 'Chưa có dữ liệu kỳ trước để so sánh' }}</span>
          </div>
        </div>
        <div
          style="
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            color: var(--muted);
          "
        >
          <span
            style="
              width: 11px;
              height: 3px;
              border-radius: 2px;
              background: var(--acc);
              display: inline-block;
            "
          ></span>
          Doanh thu
        </div>
      </div>
      <svg
        viewBox="0 0 860 320"
        style="width: 100%; height: auto; display: block"
      >
        <defs>
          <linearGradient id="anfill1" x1="0" y1="0" x2="0" y2="1">
            <stop
              offset="0%"
              stop-color="var(--acc)"
              stop-opacity="0.26"
            ></stop>
            <stop offset="100%" stop-color="var(--acc)" stop-opacity="0"></stop>
          </linearGradient>
        </defs>
        <template v-for="t in totYTicks" :key="t.label">
          <line
            x1="50"
            x2="842"
            :y1="t.y"
            :y2="t.y"
            stroke="var(--line)"
            stroke-width="1"
          ></line>
          <text
            x="44"
            :y="t.y"
            text-anchor="end"
            dominant-baseline="middle"
            fill="var(--muted)"
            font-size="11"
            font-family="Chakra Petch"
          >
            {{ t.label }}
          </text>
        </template>
        <text
          v-for="x in xTicks"
          :key="x.label"
          :x="x.x"
          y="312"
          text-anchor="middle"
          fill="var(--muted)"
          font-size="11"
        >
          {{ x.label }}
        </text>
        <path :d="totArea" fill="url(#anfill1)"></path>
        <path
          :d="totLine"
          fill="none"
          stroke="var(--acc)"
          stroke-width="2.6"
          stroke-linecap="round"
          stroke-linejoin="round"
        ></path>
      </svg>
    </div>

    <div
      style="
        display: grid;
        grid-template-columns: repeat(5, 1fr);
        gap: 14px;
        margin-bottom: 16px;
      "
    >
      <div
        v-for="m in metricCards"
        :key="m.label"
        style="
          background: var(--card);
          border: 1px solid var(--line);
          border-radius: 13px;
          padding: 15px 15px 10px;
          position: relative;
          overflow: hidden;
        "
      >
        <div
          style="
            display: flex;
            align-items: center;
            gap: 7px;
            color: var(--muted);
            font-size: 11.5px;
            font-weight: 500;
            margin-bottom: 9px;
          "
        >
          <i
            class="bi"
            :class="m.icon"
            style="color: var(--acc); font-size: 13px"
          ></i>
          {{ m.label }}
        </div>
        <div
          class="mono"
          style="
            font-size: 22px;
            font-weight: 700;
            color: var(--text);
            line-height: 1;
          "
        >
          {{ m.value }}
        </div>
        <div
          v-if="m.delta != null"
          style="
            display: flex;
            align-items: center;
            gap: 3px;
            margin-top: 7px;
            font-size: 11.5px;
            font-weight: 600;
          "
          :style="{ color: m.delta >= 0 ? 'var(--green)' : 'var(--sale)' }"
        >
          <i :class="m.delta >= 0 ? 'bi bi-arrow-up-short' : 'bi bi-arrow-down-short'"></i>{{ Math.abs(m.delta) }}%
        </div>
        <div v-else style="margin-top: 7px; font-size: 11px; color: var(--muted)">—</div>
      </div>
    </div>

    <div
      style="
        background: var(--card);
        border: 1px solid var(--line);
        border-radius: 14px;
        padding: 18px;
        margin-bottom: 16px;
      "
    >
      <div style="font-size: 15px; font-weight: 600; color: var(--text)">
        Doanh thu theo danh mục
      </div>
      <div style="font-size: 12px; color: var(--muted); margin-top: 3px">
        Mỗi danh mục một đường · bấm chú giải để bật/tắt
      </div>
      <svg
        viewBox="0 0 860 320"
        style="width: 100%; height: auto; display: block; margin-top: 8px"
      >
        <template v-for="t in catYTicks" :key="t.label">
          <line
            x1="50"
            x2="842"
            :y1="t.y"
            :y2="t.y"
            stroke="var(--line)"
            stroke-width="1"
          ></line>
          <text
            x="44"
            :y="t.y"
            text-anchor="end"
            dominant-baseline="middle"
            fill="var(--muted)"
            font-size="11"
            font-family="Chakra Petch"
          >
            {{ t.label }}
          </text>
        </template>
        <text
          v-for="x in xTicks"
          :key="x.label"
          :x="x.x"
          y="312"
          text-anchor="middle"
          fill="var(--muted)"
          font-size="11"
        >
          {{ x.label }}
        </text>
        <template v-for="l in lines" :key="l.key">
          <path
            :d="l.path"
            fill="none"
            :stroke="l.color"
            :stroke-width="l.width"
            :opacity="l.opacity"
            stroke-linecap="round"
            stroke-linejoin="round"
          ></path>
          <circle
            v-if="l.dotShow"
            :cx="l.dotX"
            :cy="l.dotY"
            r="3.5"
            :fill="l.color"
          ></circle>
        </template>
      </svg>
      <div
        style="
          display: flex;
          flex-wrap: wrap;
          gap: 8px;
          margin-top: 14px;
          padding-top: 14px;
          border-top: 1px solid var(--line);
        "
      >
        <button
          v-for="l in lines"
          :key="l.key"
          @click="toggle(l.key)"
          style="
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 7px 12px;
            border-radius: 9px;
            border: 1px solid var(--line2);
            background: var(--card2);
            cursor: pointer;
          "
        >
          <span
            style="width: 10px; height: 10px; border-radius: 3px; flex: none"
            :style="{ background: l.off ? 'var(--card2)' : l.color }"
          ></span>
          <span
            style="font-size: 12.5px; font-weight: 600"
            :style="{
              color: l.off ? 'var(--muted)' : 'var(--text)',
              textDecoration: l.off ? 'line-through' : 'none',
            }"
            >{{ l.name }}</span
          >
          <span
            class="mono"
            style="font-size: 11.5px; color: var(--muted)"
            :style="{ textDecoration: l.off ? 'line-through' : 'none' }"
            >{{ l.total }}</span
          >
        </button>
      </div>
    </div>

    <div style="display: grid; grid-template-columns: 1.5fr 1fr; gap: 16px">
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
            padding: 15px 18px;
            font-size: 15px;
            font-weight: 600;
            color: var(--text);
            border-bottom: 1px solid var(--line);
          "
        >
          Sản phẩm hàng đầu theo doanh thu
        </div>
        <div v-if="!topProducts.length" style="padding: 24px 18px; color: var(--muted); font-size: 13px">
          Chưa có dữ liệu bán hàng trong giai đoạn này.
        </div>
        <div v-else style="padding: 6px 0">
          <div
            v-for="(p, i) in topProducts"
            :key="p.name"
            style="
              display: flex;
              align-items: center;
              gap: 13px;
              padding: 11px 18px;
            "
          >
            <div
              class="mono"
              style="
                width: 24px;
                font-size: 13px;
                font-weight: 700;
                color: var(--muted);
                flex: none;
                text-align: center;
              "
            >
              {{ i + 1 }}
            </div>
            <div style="flex: 1; min-width: 0">
              <div
                style="
                  display: flex;
                  align-items: center;
                  justify-content: space-between;
                  gap: 10px;
                  margin-bottom: 6px;
                "
              >
                <span
                  style="
                    font-size: 12.5px;
                    font-weight: 500;
                    color: var(--text);
                    white-space: nowrap;
                    overflow: hidden;
                    text-overflow: ellipsis;
                  "
                  >{{ p.name }}</span
                >
                <span
                  class="mono"
                  style="
                    font-size: 12.5px;
                    font-weight: 700;
                    color: var(--text);
                    flex: none;
                  "
                  >{{ p.revenueFmt }}</span
                >
              </div>
              <div style="display: flex; align-items: center; gap: 10px">
                <div
                  style="
                    flex: 1;
                    height: 6px;
                    border-radius: 4px;
                    background: var(--card2);
                    overflow: hidden;
                  "
                >
                  <div
                    style="height: 100%; border-radius: 4px"
                    :style="{ width: p.bar, background: 'var(--acc)' }"
                  ></div>
                </div>
                <span
                  style="
                    font-size: 11px;
                    color: var(--muted);
                    flex: none;
                    white-space: nowrap;
                  "
                  >{{ p.sold }} đã bán</span
                >
              </div>
            </div>
          </div>
        </div>
      </div>
      <div
        style="
          background: var(--card);
          border: 1px solid var(--line);
          border-radius: 14px;
          padding: 18px;
        "
      >
        <div
          style="
            font-size: 15px;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 16px;
          "
        >
          Phân bổ trạng thái đơn
        </div>
        <div
          style="
            display: flex;
            height: 12px;
            border-radius: 6px;
            overflow: hidden;
            margin-bottom: 18px;
            background: var(--card2);
          "
        >
          <div
            v-for="s in statuses"
            :key="s.label"
            :style="{ width: s.pct, background: s.color }"
          ></div>
        </div>
        <div
          v-for="s in statuses"
          :key="s.label"
          style="display: flex; align-items: center; gap: 10px; padding: 7px 0"
        >
          <span
            style="width: 9px; height: 9px; border-radius: 3px; flex: none"
            :style="{ background: s.color }"
          ></span>
          <span style="flex: 1; font-size: 12.5px; color: var(--text)">{{
            s.label
          }}</span>
          <span class="mono" style="font-size: 12px; color: var(--muted2)">{{
            s.count
          }}</span>
          <span
            class="mono"
            style="
              font-size: 12px;
              font-weight: 700;
              color: var(--text);
              width: 40px;
              text-align: right;
            "
            >{{ s.pct }}</span
          >
        </div>
      </div>
    </div>

    <!-- ===================== BÁN TẠI QUẦY (POS) ===================== -->
    <div style="display: grid; grid-template-columns: 1.4fr 1fr; gap: 14px; margin-top: 14px">
      <!-- Biểu đồ cột doanh thu tại quầy theo tháng -->
      <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 18px">
        <div style="display: flex; align-items: flex-start; justify-content: space-between; gap: 12px; margin-bottom: 6px; flex-wrap: wrap">
          <div>
            <div style="font-size: 15px; font-weight: 600; color: var(--text)">
              <i class="bi bi-shop" style="color: var(--acc)"></i> Doanh thu bán tại quầy
            </div>
            <!-- Nói rõ để không ai cộng nhầm lần nữa: đây là phần BÓC TÁCH của tổng, không phải
                 khoản thu thêm nằm ngoài. -->
            <div style="font-size: 11.5px; color: var(--muted); margin-top: 3px">
              Đã bao gồm trong doanh thu tổng phía trên — đây là phần bóc tách riêng của kênh showroom.
            </div>
          </div>
          <div style="display: flex; gap: 16px; flex: none">
            <div style="text-align: right">
              <div class="mono" style="font-size: 16px; font-weight: 700; color: var(--acc)">{{ short(Number(posMetrics.revenue)) }}</div>
              <div style="font-size: 10.5px; color: var(--muted)">Doanh thu</div>
            </div>
            <div style="text-align: right">
              <div class="mono" style="font-size: 16px; font-weight: 700; color: var(--text)">{{ posMetrics.orders }}</div>
              <div style="font-size: 10.5px; color: var(--muted)">Đơn</div>
            </div>
            <div style="text-align: right">
              <div class="mono" style="font-size: 16px; font-weight: 700; color: var(--text)">{{ short(Number(posMetrics.avgOrder)) }}</div>
              <div style="font-size: 10.5px; color: var(--muted)">TB/đơn</div>
            </div>
          </div>
        </div>

        <div v-if="!posCoDuLieu" style="padding: 40px 0; text-align: center; color: var(--muted); font-size: 13px">
          Chưa có đơn bán tại quầy nào trong giai đoạn này.
        </div>
        <div v-else style="display: flex; align-items: flex-end; gap: 10px; height: 190px; padding-top: 14px">
          <div v-for="b in posBars" :key="b.label" style="flex: 1; display: flex; flex-direction: column; align-items: center; gap: 6px; height: 100%">
            <div style="flex: 1; width: 100%; display: flex; align-items: flex-end">
              <div
                :style="{ height: Math.max(b.heightPct, b.value > 0 ? 4 : 0) + '%' }"
                :title="b.valueFmt"
                style="width: 100%; border-radius: 7px 7px 0 0; background: linear-gradient(180deg, var(--acc), color-mix(in srgb, var(--acc) 45%, transparent)); transition: height 0.4s ease"
              ></div>
            </div>
            <div class="mono" style="font-size: 10px; color: var(--muted2); white-space: nowrap">{{ b.valueFmt }}</div>
            <div style="font-size: 11px; color: var(--muted)">{{ b.label }}</div>
          </div>
        </div>
      </div>

      <!-- Sản phẩm bán chạy tại quầy + doanh thu của chính sản phẩm đó -->
      <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; overflow: hidden">
        <div style="padding: 15px 18px; font-size: 15px; font-weight: 600; color: var(--text); border-bottom: 1px solid var(--line)">
          <i class="bi bi-trophy" style="color: var(--acc)"></i> Bán chạy tại quầy
        </div>
        <div v-if="!posTopProducts.length" style="padding: 24px 18px; color: var(--muted); font-size: 13px">
          Chưa có dữ liệu bán tại quầy.
        </div>
        <div v-else style="padding: 6px 0">
          <div v-for="(p, i) in posTopProducts" :key="p.name" style="display: flex; align-items: center; gap: 13px; padding: 11px 18px">
            <div class="mono" style="width: 24px; font-size: 13px; font-weight: 700; color: var(--muted); flex: none; text-align: center">{{ i + 1 }}</div>
            <div style="flex: 1; min-width: 0">
              <div style="display: flex; align-items: center; justify-content: space-between; gap: 10px">
                <span style="font-size: 12.5px; color: var(--text); white-space: nowrap; overflow: hidden; text-overflow: ellipsis">{{ p.name }}</span>
                <span class="mono" style="font-size: 12.5px; font-weight: 700; color: var(--text); flex: none">{{ p.revenueFmt }}</span>
              </div>
              <div style="display: flex; align-items: center; gap: 10px; margin-top: 6px">
                <div style="flex: 1; height: 5px; border-radius: 4px; background: var(--card2); overflow: hidden">
                  <div :style="{ width: p.bar }" style="height: 100%; background: var(--acc); border-radius: 4px"></div>
                </div>
                <span class="mono" style="font-size: 11px; color: var(--muted); flex: none">{{ p.sold }} sp</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { X, Y, PLOT_BOTTOM, CHART, short, statusBreak } from '../data/adminData';
import { getAnalytics } from '../api/admin';

const loading = ref(true);
const monthLabels = ref([]);
const totalSeries = ref([]);
const categorySeries = ref({});
const metrics = ref({
  totalRevenue: 0, totalRevenueDeltaPct: 0,
  totalOrders: 0, totalOrdersDeltaPct: 0,
  newCustomers: 0, newCustomersDeltaPct: 0,
  avgOrderValue: 0, avgOrderValueDeltaPct: 0,
  deliveredRate: 0, deliveredRateDeltaPct: 0,
});
const topProductsRaw = ref([]);

// ===== Bán tại quầy (POS) =====
// LƯU Ý: doanh thu POS ĐÃ nằm trong totalSeries và metrics tổng ở trên (backend không lọc theo
// kênh khi tính tổng). Các số dưới đây chỉ BÓC TÁCH RIÊNG để so sánh online / tại quầy — không
// được cộng thêm vào tổng lần nữa.
const posSeries = ref([]);
const posTopRaw = ref([]);
const posMetrics = ref({ revenue: 0, orders: 0, avgOrder: 0 });

const PALETTE = ['#00e5ff', '#a855f7', '#22d39a', '#ffb43b', '#7aa2ff', '#ff6ec7', '#ff8a5b', '#5be0c1'];

onMounted(async () => {
  try {
    const d = await getAnalytics();
    monthLabels.value = d.monthLabels;
    totalSeries.value = d.totalSeries.map(Number);
    const cs = {};
    Object.entries(d.categorySeries).forEach(([name, arr]) => {
      cs[name] = arr.map(Number);
    });
    categorySeries.value = cs;
    metrics.value = d.metrics;
    topProductsRaw.value = d.topProducts;
    posSeries.value = d.posSeries || [];
    posTopRaw.value = d.posTopProducts || [];
    posMetrics.value = d.posMetrics || { revenue: 0, orders: 0, avgOrder: 0 };
  } finally {
    loading.value = false;
  }
});

const nX = computed(() => monthLabels.value.length || 1);
const xTicks = computed(() => monthLabels.value.map((l, i) => ({ label: l, x: X(i, nX.value) })));

/** Làm tròn lên một mốc "đẹp" (1/2/5 x 10^n) để chia trục Y hợp lý theo dữ liệu thật. */
function niceMax(value) {
  if (!value || value <= 0) return 1000000;
  const magnitude = Math.pow(10, Math.floor(Math.log10(value)));
  const n = value / magnitude;
  const step = n <= 1 ? 1 : n <= 2 ? 2 : n <= 5 ? 5 : 10;
  return step * magnitude;
}
function buildTicks(max, count) {
  const ticks = [];
  for (let i = 0; i <= count; i++) {
    const v = (max / count) * i;
    ticks.push({ label: short(v), y: Y(v, max) });
  }
  return ticks;
}

const totMax = computed(() => niceMax(Math.max(1, ...totalSeries.value)));
const totYTicks = computed(() => buildTicks(totMax.value, 4));

const catMax = computed(() => {
  const allValues = Object.values(categorySeries.value).flat();
  return niceMax(Math.max(1, ...allValues, 0));
});
const catYTicks = computed(() => buildTicks(catMax.value, 4));

const hidden = ref([]);
const toggle = (key) => {
  const i = hidden.value.indexOf(key);
  i >= 0 ? hidden.value.splice(i, 1) : hidden.value.push(key);
};
const lines = computed(() =>
  Object.entries(categorySeries.value).map(([name, data], idx) => {
    const key = name;
    const off = hidden.value.includes(key);
    const path = data
      .map((v, i) => (i ? 'L' : 'M') + X(i, nX.value).toFixed(1) + ' ' + Y(v, catMax.value).toFixed(1))
      .join(' ');
    const color = PALETTE[idx % PALETTE.length];
    return {
      key,
      name,
      color,
      path,
      off,
      opacity: off ? 0.1 : 1,
      width: off ? 1.5 : 2.4,
      dotX: X(nX.value - 1, nX.value),
      dotY: Y(data[data.length - 1] || 0, catMax.value),
      dotShow: !off,
      total: short(data.reduce((a, b) => a + b, 0)),
    };
  }),
);

const totLine = computed(() =>
  totalSeries.value
    .map((v, i) => (i ? 'L' : 'M') + X(i, nX.value).toFixed(1) + ' ' + Y(v, totMax.value).toFixed(1))
    .join(' '),
);
const totArea = computed(() =>
  totLine.value +
  ' L' + X(nX.value - 1, nX.value).toFixed(1) + ' ' + PLOT_BOTTOM +
  ' L' + CHART.padL + ' ' + PLOT_BOTTOM + ' Z',
);

const metricCards = computed(() => [
  { label: 'Doanh thu (9 tháng)', value: short(metrics.value.totalRevenue), delta: metrics.value.totalRevenueDeltaPct, icon: 'bi-cash-stack' },
  { label: 'Tổng đơn hàng', value: metrics.value.totalOrders + '', delta: metrics.value.totalOrdersDeltaPct, icon: 'bi-receipt' },
  { label: 'Khách hàng mới', value: metrics.value.newCustomers + '', delta: metrics.value.newCustomersDeltaPct, icon: 'bi-person-plus' },
  { label: 'Tỷ lệ giao thành công', value: metrics.value.deliveredRate + '%', delta: metrics.value.deliveredRateDeltaPct, icon: 'bi-check-circle' },
  { label: 'Giá trị TB / đơn', value: short(metrics.value.avgOrderValue), delta: metrics.value.avgOrderValueDeltaPct, icon: 'bi-bag-check' },
]);

const topProducts = computed(() => {
  const maxRev = Math.max(1, ...topProductsRaw.value.map((t) => Number(t.revenue)));
  return topProductsRaw.value.map((t) => ({
    name: t.name,
    sold: t.sold,
    revenueFmt: short(Number(t.revenue)),
    bar: Math.round((Number(t.revenue) / maxRev) * 100) + '%',
  }));
});

// Biểu đồ CỘT cho doanh thu tại quầy — cố ý khác dạng đường của biểu đồ tổng để nhìn là phân
// biệt được ngay hai thứ đang xem.
const posMax = computed(() => Math.max(1, ...posSeries.value.map(Number)));
const posBars = computed(() =>
  posSeries.value.map((v, i) => ({
    label: monthLabels.value[i] || '',
    value: Number(v) || 0,
    valueFmt: short(Number(v) || 0),
    heightPct: Math.round(((Number(v) || 0) / posMax.value) * 100),
  })),
);
const posCoDuLieu = computed(() => posSeries.value.some((v) => Number(v) > 0));

const posTopProducts = computed(() => {
  const maxRev = Math.max(1, ...posTopRaw.value.map((t) => Number(t.revenue)));
  return posTopRaw.value.map((t) => ({
    name: t.name,
    sold: t.sold,
    revenueFmt: short(Number(t.revenue)),
    bar: Math.round((Number(t.revenue) / maxRev) * 100) + '%',
  }));
});

const statuses = computed(() => statusBreak());
</script>
