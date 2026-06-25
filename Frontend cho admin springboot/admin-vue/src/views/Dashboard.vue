<template>
  <div style="animation: fadeUp 0.35s ease">
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
          style="
            display: flex;
            align-items: center;
            gap: 5px;
            margin-top: 9px;
            font-size: 12px;
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
            ><i class="bi bi-arrow-up-short"></i>{{ k.delta }}</span
          >
          <span style="color: var(--muted)">{{ k.note }}</span>
        </div>
        <svg
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
              {{ weekRevenue }}
            </div>
          </div>
          <div style="display: flex; gap: 4px">
            <span
              style="
                font-size: 12px;
                padding: 5px 11px;
                border-radius: 8px;
                background: color-mix(in srgb, var(--acc) 16%, transparent);
                color: var(--acc);
                font-weight: 600;
              "
              >7N</span
            >
            <span
              style="
                font-size: 12px;
                padding: 5px 11px;
                border-radius: 8px;
                color: var(--muted);
              "
              >28N</span
            >
            <span
              style="
                font-size: 12px;
                padding: 5px 11px;
                border-radius: 8px;
                color: var(--muted);
              "
              >12T</span
            >
          </div>
        </div>
        <svg
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
        <div
          style="display: flex; justify-content: space-between; margin-top: 6px"
        >
          <span
            v-for="lb in revLabels"
            :key="lb"
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
          <button
            @click="router.push('/analytics')"
            style="
              font-size: 12px;
              color: var(--acc);
              background: none;
              border: none;
              cursor: pointer;
              font-weight: 600;
            "
          >
            Phân tích →
          </button>
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
          style="display: flex; align-items: center; gap: 10px; padding: 6px 0"
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
                {{ o.totalFmt }}
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
                {{ p.cat }}
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
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router';
import {
  ORDERS,
  PRODUCTS,
  short,
  grad,
  gradText,
  buildSpark,
  buildArea,
  statusBreak,
} from '../data/adminData';
const router = useRouter();
const week = [180, 225, 198, 262, 241, 312, 288];
const revLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
const weekRevenue = short(week.reduce((a, b) => a + b, 0) * 1e6);
const revLine = buildArea(week, true);
const revArea = buildArea(week, false);
const kpis = [
  {
    icon: 'bi-receipt',
    label: 'Đơn hàng hôm nay',
    value: '47',
    delta: '12%',
    note: 'so với hôm qua',
    spark: buildSpark([12, 18, 15, 22, 19, 28, 31]),
  },
  {
    icon: 'bi-cash-stack',
    label: 'Doanh thu hôm nay',
    value: '288tr',
    delta: '8.4%',
    note: 'so với hôm qua',
    spark: buildSpark([180, 225, 198, 262, 241, 312, 288]),
  },
  {
    icon: 'bi-person-plus',
    label: 'Khách mới hôm nay',
    value: '23',
    delta: '5',
    note: 'tài khoản mới',
    spark: buildSpark([8, 11, 9, 14, 12, 18, 23]),
  },
  {
    icon: 'bi-people',
    label: 'Tổng khách hàng',
    value: '1.284',
    delta: '2.1%',
    note: 'tháng này',
    spark: buildSpark([1180, 1205, 1230, 1248, 1262, 1275, 1284]),
  },
];
const statuses = statusBreak();
const recent = ORDERS.slice(0, 6);
const lowStock = PRODUCTS.filter((p) => p.stock <= 8)
  .sort((a, b) => a.stock - b.stock)
  .slice(0, 6);
</script>
