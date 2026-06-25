<template>
  <div v-if="loading" class="spin"></div>
  <div
    v-else-if="err"
    style="
      background: var(--card);
      border: 1px solid var(--line);
      border-radius: 14px;
      padding: 40px;
      text-align: center;
      color: var(--muted);
    "
  >
    {{ err }}
  </div>

  <div v-else style="animation: fadeUp 0.35s ease">
    <div
      style="
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 14px;
        margin-bottom: 16px;
      "
    >
      <div
        v-for="k in kpis"
        :key="k.label"
        style="
          background: var(--card);
          border: 1px solid var(--line);
          border-radius: 14px;
          padding: 16px 16px 14px;
          position: relative;
          overflow: hidden;
        "
      >
        <div
          style="
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--muted);
            font-size: 12.5px;
            font-weight: 500;
            margin-bottom: 10px;
          "
        >
          <i
            class="bi"
            :class="k.icon"
            style="color: var(--acc); font-size: 14px"
          ></i>
          {{ k.label }}
        </div>
        <div
          class="mono"
          style="
            font-size: 27px;
            font-weight: 700;
            color: var(--text);
            line-height: 1;
          "
        >
          {{ k.value }}
        </div>
        <div
          v-if="k.note"
          style="
            display: flex;
            align-items: center;
            gap: 5px;
            margin-top: 9px;
            font-size: 12px;
            color: var(--muted);
          "
        >
          {{ k.note }}
        </div>
        <svg
          v-if="k.spark"
          viewBox="0 0 120 36"
          preserveAspectRatio="none"
          style="
            position: absolute;
            right: 0;
            bottom: 0;
            width: 110px;
            height: 36px;
            opacity: 0.5;
          "
        >
          <path
            :d="k.spark"
            fill="none"
            stroke="var(--acc)"
            stroke-width="2"
          ></path>
        </svg>
      </div>
    </div>

    <div
      style="
        display: grid;
        grid-template-columns: 1.6fr 1fr;
        gap: 14px;
        margin-bottom: 16px;
      "
    >
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
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            margin-bottom: 4px;
          "
        >
          <div>
            <div
              style="font-size: 14.5px; font-weight: 600; color: var(--text)"
            >
              Doanh thu 7 ngày qua
            </div>
            <div
              class="mono"
              style="
                font-size: 24px;
                font-weight: 700;
                color: var(--text);
                margin-top: 6px;
              "
            >
              {{ money(weekRevenue) }}
            </div>
          </div>
        </div>
        <svg
          v-if="revLine"
          viewBox="0 0 560 200"
          preserveAspectRatio="none"
          style="width: 100%; height: 200px; margin-top: 8px"
        >
          <defs>
            <linearGradient id="revfill" x1="0" y1="0" x2="0" y2="1">
              <stop
                offset="0%"
                stop-color="var(--acc)"
                stop-opacity="0.28"
              ></stop>
              <stop
                offset="100%"
                stop-color="var(--acc)"
                stop-opacity="0"
              ></stop>
            </linearGradient>
          </defs>
          <path :d="revArea" fill="url(#revfill)"></path>
          <path
            :d="revLine"
            fill="none"
            stroke="var(--acc)"
            stroke-width="2.5"
            stroke-linecap="round"
          ></path>
        </svg>
        <p v-else style="color: var(--muted); font-size: 13px">
          Chưa có dữ liệu.
        </p>
        <div
          v-if="revLabels.length"
          style="display: flex; justify-content: space-between; margin-top: 6px"
        >
          <span
            v-for="(lb, i) in revLabels"
            :key="i"
            style="font-size: 11px; color: var(--muted)"
            >{{ lb }}</span
          >
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
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 16px;
          "
        >
          <div style="font-size: 14.5px; font-weight: 600; color: var(--text)">
            Trạng thái đơn hàng
          </div>
        </div>
        <div v-if="statuses.length">
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
            style="
              display: flex;
              align-items: center;
              gap: 10px;
              padding: 6px 0;
            "
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
                width: 38px;
                text-align: right;
              "
              >{{ s.pct }}</span
            >
          </div>
        </div>
        <p v-else style="color: var(--muted); font-size: 13px">
          Chưa có đơn hàng.
        </p>
      </div>
    </div>

    <div style="display: grid; grid-template-columns: 1.6fr 1fr; gap: 14px">
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
            justify-content: space-between;
            padding: 15px 18px;
            border-bottom: 1px solid var(--line);
          "
        >
          <div style="font-size: 14.5px; font-weight: 600; color: var(--text)">
            Đơn hàng gần đây
          </div>
          <button
            @click="router.push('/orders')"
            style="
              font-size: 12.5px;
              color: var(--acc);
              background: none;
              border: none;
              cursor: pointer;
              font-weight: 600;
            "
          >
            Xem tất cả →
          </button>
        </div>
        <table style="width: 100%; border-collapse: collapse; font-size: 13px">
          <thead>
            <tr>
              <th
                style="
                  text-align: left;
                  padding: 9px 18px;
                  font-size: 11px;
                  font-weight: 600;
                  color: var(--muted);
                  text-transform: uppercase;
                  letter-spacing: 0.4px;
                "
              >
                Mã đơn
              </th>
              <th
                style="
                  text-align: left;
                  padding: 9px 12px;
                  font-size: 11px;
                  font-weight: 600;
                  color: var(--muted);
                  text-transform: uppercase;
                  letter-spacing: 0.4px;
                "
              >
                Khách hàng
              </th>
              <th
                style="
                  text-align: right;
                  padding: 9px 12px;
                  font-size: 11px;
                  font-weight: 600;
                  color: var(--muted);
                  text-transform: uppercase;
                  letter-spacing: 0.4px;
                "
              >
                Tổng tiền
              </th>
              <th
                style="
                  text-align: left;
                  padding: 9px 18px;
                  font-size: 11px;
                  font-weight: 600;
                  color: var(--muted);
                  text-transform: uppercase;
                  letter-spacing: 0.4px;
                "
              >
                Trạng thái
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="o in recent"
              :key="o.code"
              style="border-top: 1px solid var(--line); cursor: pointer"
              @click="router.push('/orders')"
            >
              <td
                class="mono"
                style="padding: 11px 18px; color: var(--acc); font-weight: 600"
              >
                {{ o.code }}
              </td>
              <td style="padding: 11px 12px; color: var(--text)">
                {{ o.customer }}
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
                {{ money(o.total) }}
              </td>
              <td style="padding: 11px 18px">
                <span
                  style="
                    display: inline-flex;
                    align-items: center;
                    gap: 5px;
                    font-size: 11.5px;
                    font-weight: 600;
                    padding: 3px 9px;
                    border-radius: 20px;
                  "
                  :style="{ background: o.stBg, color: o.stColor }"
                  ><span
                    style="width: 6px; height: 6px; border-radius: 50%"
                    :style="{ background: o.stColor }"
                  ></span
                  >{{ o.stLabel }}</span
                >
              </td>
            </tr>
            <tr v-if="!recent.length">
              <td colspan="4" style="padding: 18px; color: var(--muted)">
                Chưa có đơn hàng.
              </td>
            </tr>
          </tbody>
        </table>
      </div>

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
            gap: 8px;
            padding: 15px 18px;
            border-bottom: 1px solid var(--line);
          "
        >
          <i
            class="bi bi-exclamation-triangle-fill"
            style="color: var(--amber); font-size: 14px"
          ></i>
          <div style="font-size: 14.5px; font-weight: 600; color: var(--text)">
            Sắp hết hàng
          </div>
        </div>
        <div style="padding: 6px 0">
          <div
            v-for="p in lowStock"
            :key="p.id"
            style="
              display: flex;
              align-items: center;
              gap: 12px;
              padding: 10px 18px;
            "
          >
            <div
              class="mono"
              style="
                width: 38px;
                height: 38px;
                border-radius: 9px;
                flex: none;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 10px;
                font-weight: 700;
              "
              :style="{ background: grad(p.hue), color: gradText(p.hue) }"
            >
              {{ p.tag }}
            </div>
            <div style="flex: 1; min-width: 0">
              <div
                style="
                  font-size: 12.5px;
                  font-weight: 500;
                  color: var(--text);
                  white-space: nowrap;
                  overflow: hidden;
                  text-overflow: ellipsis;
                "
              >
                {{ p.name }}
              </div>
              <div
                style="font-size: 11px; color: var(--muted); margin-top: 1px"
              >
                {{ p.brand }}
              </div>
            </div>
            <div
              class="mono"
              style="font-size: 13px; font-weight: 700"
              :style="{ color: p.stock <= 5 ? 'var(--sale)' : 'var(--amber)' }"
            >
              {{ p.stock }}
            </div>
          </div>
          <p
            v-if="!lowStock.length"
            style="padding: 0 18px 14px; color: var(--muted); font-size: 13px"
          >
            Tồn kho ổn định.
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { getDashboard } from '../api/admin';
import {
  money as fmtMoney,
  short,
  grad,
  gradText,
  buildSpark,
  buildArea,
  STATUS,
} from '../data/adminData';

const router = useRouter();
const data = ref(null);
const loading = ref(true);
const err = ref('');

function money(v) {
  return fmtMoney(Number(v || 0));
}

const kpis = computed(() => {
  if (!data.value) return [];
  const ord7 = (data.value.last7Days || []).map((d) => Number(d[1]));
  return [
    {
      icon: 'bi-receipt',
      label: 'Đơn hàng hôm nay',
      value: String(data.value.todayOrders),
      spark: ord7.length > 1 ? buildSpark(ord7) : null,
    },
    {
      icon: 'bi-cash-stack',
      label: 'Doanh thu hôm nay',
      value: short(Number(data.value.todayRevenue)),
      note: '',
    },
    {
      icon: 'bi-person-plus',
      label: 'Khách mới hôm nay',
      value: String(data.value.newCustomersToday),
      note: 'tài khoản mới',
    },
    {
      icon: 'bi-people',
      label: 'Tổng khách hàng',
      value: String(data.value.totalCustomers),
      note: 'khách hàng',
    },
  ];
});

const revSeries = computed(() =>
  (data.value?.last7Revenue || []).map((d) => Number(d[1])),
);
const revLabels = computed(() =>
  (data.value?.last7Revenue || []).map((d) =>
    d[0].split('/').slice(0, 2).join('/'),
  ),
);
const weekRevenue = computed(() => revSeries.value.reduce((a, b) => a + b, 0));
const revLine = computed(() =>
  revSeries.value.length > 1 ? buildArea(revSeries.value, true) : null,
);
const revArea = computed(() =>
  revSeries.value.length > 1 ? buildArea(revSeries.value, false) : null,
);

const statuses = computed(() => {
  const rows = data.value?.statusBreakdown || [];
  const total = rows.reduce((a, r) => a + Number(r[1]), 0) || 1;
  return rows.map((r) => {
    const meta = STATUS[r[0]] || { label: r[0], color: '#7e98b6' };
    const count = Number(r[1]);
    return {
      label: meta.label,
      color: meta.color,
      count: String(count),
      pct: Math.round((count / total) * 100) + '%',
    };
  });
});

const recent = computed(() =>
  (data.value?.recentOrders || []).map((o) => {
    const meta = STATUS[o[3]] || { label: o[3], color: '#7e98b6' };
    return {
      code: o[0],
      customer: o[1],
      total: o[2],
      stLabel: meta.label,
      stColor: meta.color,
      stBg: 'color-mix(in srgb,' + meta.color + ' 16%, transparent)',
    };
  }),
);

const lowStock = computed(() =>
  (data.value?.lowStock || []).map((p) => {
    const hue = (Number(p[0]) * 47) % 360;
    return {
      id: p[0],
      name: p[1],
      brand: p[2] || '—',
      stock: Number(p[3]),
      hue,
      tag: (p[2] || p[1] || '').slice(0, 3).toUpperCase(),
    };
  }),
);

onMounted(async () => {
  try {
    data.value = await getDashboard();
  } catch (e) {
    err.value =
      'Không tải được dữ liệu. Hãy chắc backend đang chạy và bạn đã đăng nhập tài khoản admin.';
  } finally {
    loading.value = false;
  }
});
</script>
