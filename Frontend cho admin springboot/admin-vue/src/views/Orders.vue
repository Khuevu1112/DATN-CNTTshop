<template>
  <div>
    <div v-if="detail" style="animation: fadeUp 0.3s ease">
      <button
        @click="detail = null"
        style="
          display: inline-flex;
          align-items: center;
          gap: 7px;
          background: none;
          border: none;
          color: var(--muted2);
          font-size: 13px;
          cursor: pointer;
          margin-bottom: 16px;
          font-weight: 500;
        "
      >
        <i class="bi bi-arrow-left"></i> Quay lại danh sách
      </button>
      <div style="display: grid; grid-template-columns: 1.7fr 1fr; gap: 14px">
        <div>
          <div
            style="
              background: var(--card);
              border: 1px solid var(--line);
              border-radius: 14px;
              padding: 20px;
              margin-bottom: 14px;
            "
          >
            <div
              style="
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 18px;
              "
            >
              <div>
                <div
                  class="mono"
                  style="font-size: 20px; font-weight: 700; color: var(--text)"
                >
                  {{ detail.code }}
                </div>
                <div
                  style="
                    font-size: 12.5px;
                    color: var(--muted);
                    margin-top: 3px;
                  "
                >
                  Đặt lúc {{ detail.date }}
                </div>
              </div>
              <span
                style="
                  display: inline-flex;
                  align-items: center;
                  gap: 6px;
                  font-size: 12.5px;
                  font-weight: 600;
                  padding: 6px 13px;
                  border-radius: 20px;
                "
                :style="{ background: detail.stBg, color: detail.stColor }"
                ><span
                  style="width: 7px; height: 7px; border-radius: 50%"
                  :style="{ background: detail.stColor }"
                ></span
                >{{ detail.stLabel }}</span
              >
            </div>
            <div
              v-if="cancelled"
              style="
                padding: 14px;
                border-radius: 10px;
                background: color-mix(in srgb, var(--sale) 12%, transparent);
                border: 1px solid
                  color-mix(in srgb, var(--sale) 30%, transparent);
                color: var(--sale);
                font-size: 13px;
                display: flex;
                align-items: center;
                gap: 9px;
              "
            >
              <i class="bi bi-x-octagon-fill"></i> Đơn hàng đã bị huỷ / hoàn
              tiền.
            </div>
            <div
              v-else
              style="
                display: flex;
                justify-content: space-between;
                position: relative;
                margin-top: 6px;
              "
            >
              <div
                v-for="t in timeline"
                :key="t.label"
                style="
                  flex: 1;
                  display: flex;
                  flex-direction: column;
                  align-items: center;
                  gap: 8px;
                "
              >
                <div
                  style="
                    width: 38px;
                    height: 38px;
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 15px;
                    background: var(--card2);
                  "
                  :style="{ border: '2px solid ' + t.color, color: t.color }"
                >
                  <i class="bi" :class="t.icon"></i>
                </div>
                <span
                  style="font-size: 11.5px; font-weight: 500"
                  :style="{ color: t.color }"
                  >{{ t.label }}</span
                >
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
            <div
              style="
                padding: 14px 18px;
                font-size: 14px;
                font-weight: 600;
                color: var(--text);
                border-bottom: 1px solid var(--line);
              "
            >
              Sản phẩm
            </div>
            <div
              style="
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 14px 18px;
                border-bottom: 1px solid var(--line);
              "
            >
              <div style="font-size: 13px; color: var(--text)">
                {{ detail.item }}
              </div>
              <div style="display: flex; align-items: center; gap: 18px">
                <span class="mono" style="font-size: 12px; color: var(--muted)"
                  >x1</span
                ><span
                  class="mono"
                  style="font-size: 13px; font-weight: 700; color: var(--text)"
                  >{{ detail.totalFmt }}</span
                >
              </div>
            </div>
            <div
              style="
                padding: 14px 18px;
                display: flex;
                flex-direction: column;
                gap: 8px;
              "
            >
              <div
                style="
                  display: flex;
                  justify-content: space-between;
                  font-size: 13px;
                "
              >
                <span style="color: var(--muted)">Tạm tính</span
                ><span class="mono" style="color: var(--text)">{{
                  detail.totalFmt
                }}</span>
              </div>
              <div
                style="
                  display: flex;
                  justify-content: space-between;
                  font-size: 13px;
                "
              >
                <span style="color: var(--muted)">Phí vận chuyển</span
                ><span class="mono" style="color: var(--text)">{{
                  money(30000)
                }}</span>
              </div>
              <div
                style="
                  display: flex;
                  justify-content: space-between;
                  font-size: 15px;
                  font-weight: 700;
                  padding-top: 8px;
                  border-top: 1px solid var(--line);
                "
              >
                <span style="color: var(--text)">Tổng cộng</span
                ><span class="mono" style="color: var(--acc)">{{
                  money(detail.total + 30000)
                }}</span>
              </div>
            </div>
          </div>
        </div>
        <div>
          <div
            style="
              background: var(--card);
              border: 1px solid var(--line);
              border-radius: 14px;
              padding: 18px;
              margin-bottom: 14px;
            "
          >
            <div
              style="
                font-size: 13px;
                font-weight: 600;
                color: var(--text);
                margin-bottom: 14px;
              "
            >
              Khách hàng
            </div>
            <div style="display: flex; align-items: center; gap: 12px">
              <div
                class="mono"
                style="
                  width: 44px;
                  height: 44px;
                  border-radius: 11px;
                  background: linear-gradient(135deg, var(--acc), #0b4f9e);
                  color: #04121f;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  font-weight: 700;
                  font-size: 15px;
                "
              >
                {{ detail.init }}
              </div>
              <div>
                <div
                  style="font-size: 14px; font-weight: 600; color: var(--text)"
                >
                  {{ detail.customer }}
                </div>
                <div style="font-size: 12px; color: var(--muted)">
                  {{ detail.email }}
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
                font-size: 13px;
                font-weight: 600;
                color: var(--text);
                margin-bottom: 12px;
              "
            >
              Cập nhật trạng thái
            </div>
            <select
              style="
                width: 100%;
                height: 42px;
                padding: 0 12px;
                border-radius: 10px;
                background: var(--card2);
                color: var(--text);
                border: 1px solid var(--line2);
                font-size: 13px;
                margin-bottom: 10px;
                cursor: pointer;
              "
            >
              <option>Chờ xác nhận</option>
              <option>Đã xác nhận</option>
              <option>Đang xử lý</option>
              <option>Đang giao</option>
              <option>Đã giao</option>
              <option>Đã huỷ</option>
              <option>Hoàn tiền</option>
            </select>
            <button
              style="
                width: 100%;
                height: 42px;
                border-radius: 10px;
                border: none;
                background: var(--acc);
                color: #04121f;
                font-weight: 700;
                font-size: 13px;
                cursor: pointer;
              "
            >
              Lưu thay đổi
            </button>
          </div>
        </div>
      </div>
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
            <div
              style="font-size: 11.5px; color: var(--muted); margin-top: 4px"
            >
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
        <div
          style="
            display: flex;
            align-items: center;
            gap: 2px;
            padding: 4px 12px;
            border-bottom: 1px solid var(--line);
            overflow-x: auto;
          "
        >
          <button
            v-for="t in tabs"
            :key="t.key"
            @click="filter = t.key"
            style="
              display: flex;
              align-items: center;
              gap: 7px;
              padding: 12px 13px;
              border: none;
              background: transparent;
              font-size: 12.5px;
              cursor: pointer;
              white-space: nowrap;
            "
            :style="{
              borderBottom:
                '2px solid ' +
                (filter === t.key ? 'var(--acc)' : 'transparent'),
              color: filter === t.key ? 'var(--text)' : 'var(--muted)',
              fontWeight: filter === t.key ? 600 : 500,
            }"
          >
            {{ t.label }}
            <span
              class="mono"
              style="
                font-size: 10.5px;
                padding: 0 6px;
                border-radius: 8px;
                background: var(--card2);
                color: var(--muted);
              "
              >{{ t.count }}</span
            >
          </button>
        </div>
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
              v-for="o in rows"
              :key="o.code"
              @click="detail = o"
              style="border-top: 1px solid var(--line); cursor: pointer"
            >
              <td
                class="mono"
                style="padding: 12px 16px; color: var(--acc); font-weight: 600"
              >
                {{ o.code }}
              </td>
              <td style="padding: 12px 12px">
                <div style="display: flex; align-items: center; gap: 10px">
                  <div
                    class="mono"
                    style="
                      width: 32px;
                      height: 32px;
                      border-radius: 8px;
                      flex: none;
                      background: var(--card2);
                      color: var(--muted2);
                      display: flex;
                      align-items: center;
                      justify-content: center;
                      font-size: 11px;
                      font-weight: 700;
                    "
                  >
                    {{ o.init }}
                  </div>
                  <div style="min-width: 0">
                    <div
                      style="
                        font-size: 12.5px;
                        color: var(--text);
                        font-weight: 500;
                      "
                    >
                      {{ o.customer }}
                    </div>
                    <div style="font-size: 11px; color: var(--muted)">
                      {{ o.email }}
                    </div>
                  </div>
                </div>
              </td>
              <td
                style="
                  padding: 12px 12px;
                  color: var(--muted2);
                  font-size: 12px;
                  max-width: 200px;
                "
              >
                {{ o.item }}
              </td>
              <td
                style="
                  padding: 12px 12px;
                  color: var(--muted2);
                  font-size: 12px;
                "
              >
                {{ o.date }}
              </td>
              <td
                class="mono"
                style="
                  padding: 12px 12px;
                  text-align: right;
                  color: var(--text);
                  font-weight: 700;
                "
              >
                {{ o.totalFmt }}
              </td>
              <td style="padding: 12px 16px">
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
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { ORDERS, money, short } from '../data/adminData';
import { ui } from '../store';
const filter = ref('all');
const detail = ref(null);
const heads = [
  { t: 'Mã đơn' },
  { t: 'Khách hàng' },
  { t: 'Sản phẩm' },
  { t: 'Ngày đặt' },
  { t: 'Tổng tiền', a: 'right' },
  { t: 'Trạng thái' },
];
const stKeys = [
  'all',
  'pending',
  'confirmed',
  'processing',
  'shipped',
  'delivered',
  'cancelled',
  'refunded',
];
const stLabels = {
  all: 'Tất cả',
  pending: 'Chờ xác nhận',
  confirmed: 'Đã xác nhận',
  processing: 'Đang xử lý',
  shipped: 'Đang giao',
  delivered: 'Đã giao',
  cancelled: 'Đã huỷ',
  refunded: 'Hoàn tiền',
};
const tabs = computed(() =>
  stKeys.map((k) => ({
    key: k,
    label: stLabels[k],
    count:
      k === 'all' ? ORDERS.length : ORDERS.filter((o) => o.st === k).length,
  })),
);
const rows = computed(() => {
  const q = ui.search.trim().toLowerCase();
  return ORDERS.filter(
    (o) =>
      (filter.value === 'all' || o.st === filter.value) &&
      (!q ||
        o.code.toLowerCase().includes(q) ||
        o.customer.toLowerCase().includes(q)),
  );
});
const stats = [
  {
    label: 'Tổng đơn',
    value: ORDERS.length + '',
    icon: 'bi-receipt',
    color: 'var(--acc)',
  },
  {
    label: 'Chờ xử lý',
    value:
      ORDERS.filter((o) =>
        ['pending', 'confirmed', 'processing'].includes(o.st),
      ).length + '',
    icon: 'bi-hourglass-split',
    color: 'var(--amber)',
  },
  {
    label: 'Đang giao',
    value: ORDERS.filter((o) => o.st === 'shipped').length + '',
    icon: 'bi-truck',
    color: '#a855f7',
  },
  {
    label: 'Doanh thu',
    value: short(
      ORDERS.filter((o) => o.st !== 'cancelled' && o.st !== 'refunded').reduce(
        (a, o) => a + o.total,
        0,
      ),
    ),
    icon: 'bi-cash-stack',
    color: 'var(--green)',
  },
];
const cancelled = computed(
  () =>
    detail.value &&
    (detail.value.st === 'cancelled' || detail.value.st === 'refunded'),
);
const timeline = computed(() => {
  if (!detail.value) return [];
  const steps = ['pending', 'confirmed', 'processing', 'shipped', 'delivered'];
  const cur = steps.indexOf(detail.value.st);
  return [
    ['Đặt hàng', 'bi-bag-check'],
    ['Xác nhận', 'bi-check-circle'],
    ['Đóng gói', 'bi-box-seam'],
    ['Giao hàng', 'bi-truck'],
    ['Hoàn tất', 'bi-flag'],
  ].map((s, i) => ({
    label: s[0],
    icon: s[1],
    color: i <= cur ? 'var(--acc)' : 'var(--muted)',
  }));
});
</script>
