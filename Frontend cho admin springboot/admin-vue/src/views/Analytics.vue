<template>
  <div style="animation: fadeUp 0.35s ease">
    <div
      style="display: flex; align-items: center; gap: 8px; margin-bottom: 16px"
    >
      <button
        v-for="r in ranges"
        :key="r.key"
        @click="range = r.key"
        style="
          padding: 7px 14px;
          border-radius: 9px;
          font-size: 12.5px;
          font-weight: 600;
          cursor: pointer;
        "
        :style="{
          border:
            '1px solid ' + (range === r.key ? 'var(--acc)' : 'var(--line2)'),
          background: range === r.key ? 'var(--acc)' : 'var(--card)',
          color: range === r.key ? '#04121f' : 'var(--muted2)',
        }"
      >
        {{ r.label }}
      </button>
      <div style="flex: 1"></div>
      <button
        style="
          display: flex;
          align-items: center;
          gap: 7px;
          height: 34px;
          padding: 0 14px;
          border-radius: 9px;
          border: 1px solid var(--line2);
          background: var(--card);
          color: var(--text);
          font-size: 12.5px;
          font-weight: 600;
          cursor: pointer;
        "
      >
        <i class="bi bi-download"></i> Xuất báo cáo
      </button>
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
            {{ totSum }}
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
              style="
                display: inline-flex;
                align-items: center;
                gap: 2px;
                font-weight: 600;
                color: var(--green);
              "
              ><i class="bi bi-arrow-up-short"></i>18%</span
            ><span style="color: var(--muted)">so với 9 tháng trước</span>
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
        v-for="m in metrics"
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
          style="
            display: flex;
            align-items: center;
            gap: 3px;
            margin-top: 7px;
            font-size: 11.5px;
            font-weight: 600;
            color: var(--green);
          "
        >
          <i class="bi bi-arrow-up-short"></i>{{ m.delta }}
        </div>
        <svg
          viewBox="0 0 120 34"
          preserveAspectRatio="none"
          style="
            position: absolute;
            right: 0;
            bottom: 0;
            width: 88px;
            height: 30px;
            opacity: 0.45;
          "
        >
          <path
            :d="m.spark"
            fill="none"
            stroke="var(--acc)"
            stroke-width="2"
          ></path>
        </svg>
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
        <div style="padding: 6px 0">
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
                  >{{ p.revenue }}</span
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
                    :style="{ width: p.bar, background: p.color }"
                  ></div>
                </div>
                <span
                  style="
                    font-size: 11px;
                    color: var(--muted);
                    flex: none;
                    white-space: nowrap;
                  "
                  >{{ p.sold }}</span
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
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import {
  AN_XLABELS,
  CAT_SERIES,
  X,
  Y,
  PLOT_BOTTOM,
  CHART,
  short,
  statusBreak,
} from '../data/adminData';
const range = ref('9m');
const ranges = [
  { key: '7d', label: '7 ngày' },
  { key: '28d', label: '28 ngày' },
  { key: '90d', label: '90 ngày' },
  { key: '9m', label: '9 tháng' },
  { key: '12m', label: '12 tháng' },
];
const nX = AN_XLABELS.length;
const xTicks = AN_XLABELS.map((l, i) => ({ label: l, x: X(i, nX) }));
const catMax = 700,
  totMax = 2000;
const catYTicks = [0, 200, 400, 600].map((v) => ({
  label: v + 'tr',
  y: Y(v, catMax),
}));
const totYTicks = [0, 500, 1000, 1500, 2000].map((v) => ({
  label: short(v * 1e6),
  y: Y(v, totMax),
}));

const hidden = ref([]);
const toggle = (key) => {
  const i = hidden.value.indexOf(key);
  i >= 0 ? hidden.value.splice(i, 1) : hidden.value.push(key);
};
const lines = computed(() =>
  CAT_SERIES.map((s) => {
    const off = hidden.value.includes(s.key);
    const path = s.data
      .map(
        (v, i) =>
          (i ? 'L' : 'M') + X(i, nX).toFixed(1) + ' ' + Y(v, catMax).toFixed(1),
      )
      .join(' ');
    return {
      key: s.key,
      name: s.name,
      color: s.color,
      path,
      off,
      opacity: off ? 0.1 : 1,
      width: off ? 1.5 : 2.4,
      dotX: X(nX - 1, nX),
      dotY: Y(s.data[s.data.length - 1], catMax),
      dotShow: !off,
      total: short(s.data.reduce((a, b) => a + b, 0) * 1e6),
    };
  }),
);

const totals = AN_XLABELS.map((_, i) =>
  CAT_SERIES.reduce((a, s) => a + s.data[i], 0),
);
const totLine = totals
  .map(
    (v, i) =>
      (i ? 'L' : 'M') + X(i, nX).toFixed(1) + ' ' + Y(v, totMax).toFixed(1),
  )
  .join(' ');
const totArea =
  totLine +
  ' L' +
  X(nX - 1, nX).toFixed(1) +
  ' ' +
  PLOT_BOTTOM +
  ' L' +
  CHART.padL +
  ' ' +
  PLOT_BOTTOM +
  ' Z';
const totSumNum = totals.reduce((a, b) => a + b, 0) * 1e6;
const totSum = short(totSumNum);
function spark(arr) {
  const max = Math.max(...arr),
    min = Math.min(...arr),
    w = 120,
    h = 34;
  return arr
    .map((v, i) => {
      const x = (i / (arr.length - 1)) * w;
      const y = h - 2 - ((v - min) / (max - min || 1)) * (h - 6);
      return (i ? 'L' : 'M') + x.toFixed(1) + ' ' + y.toFixed(1);
    })
    .join(' ');
}
const metrics = [
  {
    label: 'Doanh thu (9 tháng)',
    value: totSum,
    delta: '+18%',
    icon: 'bi-cash-stack',
    spark: spark(totals),
  },
  {
    label: 'Tổng đơn hàng',
    value: '1.284',
    delta: '+9.2%',
    icon: 'bi-receipt',
    spark: spark([88, 102, 96, 118, 130, 156, 142, 168, 184]),
  },
  {
    label: 'Khách hàng mới',
    value: '312',
    delta: '+12%',
    icon: 'bi-person-plus',
    spark: spark([22, 28, 25, 31, 30, 38, 35, 42, 48]),
  },
  {
    label: 'Tỷ lệ chuyển đổi',
    value: '3.8%',
    delta: '+0.4%',
    icon: 'bi-graph-up',
    spark: spark([2.9, 3.1, 3.0, 3.3, 3.4, 3.6, 3.5, 3.7, 3.8]),
  },
  {
    label: 'Giá trị TB / đơn',
    value: short(totSumNum / 1284),
    delta: '+5.1%',
    icon: 'bi-bag-check',
    spark: spark([11, 12, 11.5, 13, 12.8, 14, 13.6, 14.5, 15]),
  },
];
const topRaw = [
  ['RAM Corsair Vengeance 32GB DDR5', 410, '#22d39a', 2690000],
  ['SSD Samsung 990 Pro 2TB', 320, '#22d39a', 4290000],
  ['CPU Intel Core i5-13400F', 265, '#22d39a', 4690000],
  ['Màn hình Asus TUF VG27AQ', 176, '#ffb43b', 6490000],
  ['Laptop ASUS TUF Gaming F15', 142, '#00e5ff', 22990000],
  ['Chuột Logitech G Pro X SL2', 138, '#7aa2ff', 2890000],
  ['PC CNTT Spark RTX 4060', 98, '#a855f7', 24900000],
].map((r) => ({ name: r[0], sold: r[1], color: r[2], revenue: r[1] * r[3] }));
const topMaxRev = Math.max(...topRaw.map((t) => t.revenue));
const topProducts = topRaw
  .slice()
  .sort((a, b) => b.revenue - a.revenue)
  .map((t) => ({
    name: t.name,
    sold: t.sold + ' đã bán',
    color: t.color,
    revenue: short(t.revenue),
    bar: Math.round((t.revenue / topMaxRev) * 100) + '%',
  }));
const statuses = statusBreak();
</script>
