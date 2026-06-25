<template>
  <div
    style="
      animation: fadeUp 0.35s ease;
      display: grid;
      grid-template-columns: 340px 1fr;
      gap: 14px;
      align-items: start;
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
          font-size: 14.5px;
          font-weight: 600;
          color: var(--text);
          margin-bottom: 16px;
          display: flex;
          align-items: center;
          gap: 8px;
        "
      >
        <i class="bi bi-ticket-perforated" style="color: var(--acc)"></i> Tạo mã
        khuyến mãi
      </div>
      <label
        style="
          font-size: 11px;
          font-weight: 600;
          color: var(--muted);
          text-transform: uppercase;
          display: block;
          margin-bottom: 6px;
        "
        >Mã coupon</label
      >
      <input
        v-model="form.code"
        style="
          width: 100%;
          height: 40px;
          padding: 0 12px;
          border-radius: 9px;
          background: var(--card2);
          border: 1px solid var(--line2);
          color: var(--text);
          font-size: 13px;
          margin-bottom: 14px;
        "
      />
      <div
        style="
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 10px;
          margin-bottom: 14px;
        "
      >
        <div>
          <label
            style="
              font-size: 11px;
              font-weight: 600;
              color: var(--muted);
              text-transform: uppercase;
              display: block;
              margin-bottom: 6px;
            "
            >Loại</label
          ><select
            v-model="form.type"
            style="
              width: 100%;
              height: 40px;
              padding: 0 10px;
              border-radius: 9px;
              background: var(--card2);
              border: 1px solid var(--line2);
              color: var(--text);
              font-size: 13px;
              cursor: pointer;
            "
          >
            <option>Phần trăm (%)</option>
            <option>Tiền mặt (đ)</option>
          </select>
        </div>
        <div>
          <label
            style="
              font-size: 11px;
              font-weight: 600;
              color: var(--muted);
              text-transform: uppercase;
              display: block;
              margin-bottom: 6px;
            "
            >Giá trị</label
          ><input
            v-model="form.value"
            style="
              width: 100%;
              height: 40px;
              padding: 0 12px;
              border-radius: 9px;
              background: var(--card2);
              border: 1px solid var(--line2);
              color: var(--text);
              font-size: 13px;
            "
          />
        </div>
      </div>
      <div
        style="
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 10px;
          margin-bottom: 14px;
        "
      >
        <div>
          <label
            style="
              font-size: 11px;
              font-weight: 600;
              color: var(--muted);
              text-transform: uppercase;
              display: block;
              margin-bottom: 6px;
            "
            >Đơn tối thiểu</label
          ><input
            v-model="form.min"
            style="
              width: 100%;
              height: 40px;
              padding: 0 12px;
              border-radius: 9px;
              background: var(--card2);
              border: 1px solid var(--line2);
              color: var(--text);
              font-size: 13px;
            "
          />
        </div>
        <div>
          <label
            style="
              font-size: 11px;
              font-weight: 600;
              color: var(--muted);
              text-transform: uppercase;
              display: block;
              margin-bottom: 6px;
            "
            >Hạn dùng</label
          ><input
            v-model="form.exp"
            style="
              width: 100%;
              height: 40px;
              padding: 0 12px;
              border-radius: 9px;
              background: var(--card2);
              border: 1px solid var(--line2);
              color: var(--text);
              font-size: 13px;
            "
          />
        </div>
      </div>
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
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 7px;
        "
      >
        <i class="bi bi-plus-circle"></i> Tạo mã
      </button>
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
          font-size: 14.5px;
          font-weight: 600;
          color: var(--text);
          border-bottom: 1px solid var(--line);
        "
      >
        Danh sách mã khuyến mãi
      </div>
      <table style="width: 100%; border-collapse: collapse; font-size: 13px">
        <thead>
          <tr style="background: var(--card2)">
            <th
              v-for="h in heads"
              :key="h.t"
              :style="{
                textAlign: h.a || 'left',
                padding: '10px 18px',
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
            :key="c.code"
            style="border-top: 1px solid var(--line)"
          >
            <td
              class="mono"
              style="
                padding: 12px 18px;
                color: var(--acc);
                font-weight: 700;
                letter-spacing: 0.5px;
              "
            >
              {{ c.code }}
            </td>
            <td style="padding: 12px 12px">
              <span
                style="font-size: 11.5px; font-weight: 600"
                :style="{ color: c.typeColor }"
                >{{ c.type }}</span
              >
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
              {{ c.value }}
            </td>
            <td
              class="mono"
              style="
                padding: 12px 12px;
                text-align: right;
                color: var(--muted2);
                font-size: 12px;
              "
            >
              {{ c.min }}
            </td>
            <td style="padding: 12px 12px">
              <div style="display: flex; align-items: center; gap: 8px">
                <span
                  class="mono"
                  style="
                    font-size: 11.5px;
                    color: var(--muted2);
                    white-space: nowrap;
                  "
                  >{{ c.used }}</span
                >
                <div
                  style="
                    flex: 1;
                    height: 5px;
                    border-radius: 4px;
                    background: var(--card2);
                    overflow: hidden;
                  "
                >
                  <div
                    style="
                      height: 100%;
                      background: var(--acc);
                      border-radius: 4px;
                    "
                    :style="{ width: c.usedPct }"
                  ></div>
                </div>
              </div>
            </td>
            <td
              style="padding: 12px 12px; color: var(--muted2); font-size: 12px"
            >
              {{ c.exp }}
            </td>
            <td style="padding: 12px 18px">
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
                :style="{ background: c.stBg, color: c.stColor }"
                ><span
                  style="width: 6px; height: 6px; border-radius: 50%"
                  :style="{ background: c.stColor }"
                ></span
                >{{ c.stText }}</span
              >
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { reactive } from 'vue';
import { money } from '../data/adminData';
const form = reactive({
  code: 'SUMMER30',
  type: 'Phần trăm (%)',
  value: '30',
  min: '500000',
  exp: '31/07/2024',
});
const heads = [
  { t: 'Mã' },
  { t: 'Loại' },
  { t: 'Giá trị', a: 'right' },
  { t: 'Đơn tối thiểu', a: 'right' },
  { t: 'Đã dùng' },
  { t: 'Hạn' },
  { t: 'Trạng thái' },
];
const raw = [
  ['SUMMER30', 'percent', 30, 500000, 100, 42, '31/07/2024', true],
  ['CNTT500K', 'fixed', 500000, 10000000, 50, 18, '30/06/2024', true],
  ['NEWBIE10', 'percent', 10, 0, 200, 156, '31/12/2024', true],
  ['PCGAMING', 'fixed', 1000000, 30000000, 30, 7, '15/06/2024', false],
  ['FREESHIP', 'fixed', 30000, 300000, 500, 389, '31/12/2024', true],
];
const rows = raw.map((r) => {
  const [code, type, val, min, max, used, exp, active] = r;
  return {
    code,
    type: type === 'percent' ? 'Phần trăm' : 'Tiền mặt',
    typeColor: type === 'percent' ? 'var(--acc)' : '#a855f7',
    value: type === 'percent' ? val + '%' : money(val),
    min: min ? money(min) : 'Không',
    used: used + '/' + max,
    usedPct: Math.round((used / max) * 100) + '%',
    exp,
    stText: active ? 'Đang chạy' : 'Tạm dừng',
    stColor: active ? 'var(--green)' : 'var(--muted)',
    stBg: active
      ? 'color-mix(in srgb,var(--green) 16%,transparent)'
      : 'var(--card2)',
  };
});
</script>
