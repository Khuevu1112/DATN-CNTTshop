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
          <div
            class="mono"
            style="
              font-size: 21px;
              font-weight: 700;
              color: var(--text);
              line-height: 1;
            "
          >
            {{ s.value }}
          </div>
          <div style="font-size: 11.5px; color: var(--muted); margin-top: 4px">
            {{ s.label }}
          </div>
        </div>
      </div>
    </div>
    <div
      style="
        background: var(--card);
        border: 1px solid var(--line);
        border-radius: 14px;
        overflow: hidden;
      "
    >
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
  </div>
</template>

<script setup>
import { computed } from 'vue';
import { CUSTOMERS, short, gradAvatar } from '../data/adminData';
import { ui } from '../store';
const heads = [
  { t: 'Khách hàng' },
  { t: 'Số điện thoại' },
  { t: 'Vai trò' },
  { t: 'Đơn hàng', a: 'right' },
  { t: 'Tổng chi tiêu', a: 'right' },
  { t: 'Tham gia' },
  { t: 'Trạng thái' },
];
const rows = computed(() => {
  const q = ui.search.trim().toLowerCase();
  return CUSTOMERS.filter(
    (c) =>
      !q ||
      c.name.toLowerCase().includes(q) ||
      c.email.toLowerCase().includes(q),
  );
});
const stats = [
  {
    label: 'Tổng khách hàng',
    value: CUSTOMERS.filter((c) => c.role === 'customer').length + '',
    icon: 'bi-people',
    color: 'var(--acc)',
  },
  {
    label: 'Nhân viên & Admin',
    value: CUSTOMERS.filter((c) => c.role !== 'customer').length + '',
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
];
</script>
