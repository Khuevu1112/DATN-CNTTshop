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
        <i class="bi bi-calculator" style="color: var(--acc)"></i> Tính thử phí
        giao
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
        >Khu vực</label
      >
      <select
        v-model.number="zoneIdx"
        style="
          width: 100%;
          height: 40px;
          padding: 0 10px;
          border-radius: 9px;
          background: var(--card2);
          border: 1px solid var(--line2);
          color: var(--text);
          font-size: 13px;
          margin-bottom: 14px;
          cursor: pointer;
        "
      >
        <option v-for="(z, i) in raw" :key="z[0]" :value="i">{{ z[0] }}</option>
      </select>
      <div
        style="
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 10px;
          margin-bottom: 16px;
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
            >Khối lượng (kg)</label
          ><input
            v-model.number="kg"
            type="number"
            step="0.1"
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
            >Giá trị đơn</label
          ><input
            v-model.number="orderVal"
            type="number"
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
      <div style="background: var(--card2); border-radius: 11px; padding: 14px">
        <div
          style="
            display: flex;
            justify-content: space-between;
            font-size: 12.5px;
            margin-bottom: 9px;
          "
        >
          <span style="color: var(--muted)">Phí cơ bản</span
          ><span class="mono" style="color: var(--text)">{{
            money(base)
          }}</span>
        </div>
        <div
          style="
            display: flex;
            justify-content: space-between;
            font-size: 12.5px;
            margin-bottom: 9px;
          "
        >
          <span style="color: var(--muted)"
            >Phụ phí {{ extraKg.toFixed(1) }}kg</span
          ><span class="mono" style="color: var(--text)">{{
            money(extra)
          }}</span>
        </div>
        <div
          style="
            display: flex;
            justify-content: space-between;
            font-size: 15px;
            font-weight: 700;
            padding-top: 9px;
            border-top: 1px solid var(--line);
          "
        >
          <span style="color: var(--text)">{{
            freeShip ? 'Miễn phí' : 'Tổng phí'
          }}</span
          ><span class="mono" style="color: var(--acc)">{{
            freeShip ? money(0) : money(base + extra)
          }}</span>
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
          justify-content: space-between;
          padding: 14px 18px;
          border-bottom: 1px solid var(--line);
        "
      >
        <div style="font-size: 14.5px; font-weight: 600; color: var(--text)">
          Cấu hình vùng giao hàng
        </div>
        <button
          style="
            display: flex;
            align-items: center;
            gap: 7px;
            height: 34px;
            padding: 0 14px;
            border-radius: 9px;
            border: none;
            background: var(--acc);
            color: #04121f;
            font-size: 12.5px;
            font-weight: 700;
            cursor: pointer;
          "
        >
          <i class="bi bi-plus-lg"></i> Thêm vùng
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
            v-for="z in rows"
            :key="z.key"
            style="border-top: 1px solid var(--line)"
          >
            <td style="padding: 12px 18px">
              <div style="display: flex; align-items: center; gap: 10px">
                <i
                  class="bi bi-geo-alt-fill"
                  style="color: var(--acc); font-size: 14px"
                ></i>
                <div>
                  <div
                    style="
                      font-size: 13px;
                      color: var(--text);
                      font-weight: 500;
                    "
                  >
                    {{ z.name }}
                  </div>
                  <div
                    class="mono"
                    style="font-size: 11px; color: var(--muted)"
                  >
                    {{ z.key }}
                  </div>
                </div>
              </div>
            </td>
            <td
              class="mono"
              style="
                padding: 12px 12px;
                text-align: right;
                color: var(--text);
                font-weight: 600;
              "
            >
              {{ z.base }}
            </td>
            <td
              class="mono"
              style="
                padding: 12px 12px;
                text-align: right;
                color: var(--muted2);
              "
            >
              {{ z.kg }}
            </td>
            <td
              class="mono"
              style="
                padding: 12px 12px;
                text-align: right;
                color: var(--muted2);
              "
            >
              {{ z.free }}
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
                :style="{ background: z.stBg, color: z.stColor }"
                ><span
                  style="width: 6px; height: 6px; border-radius: 50%"
                  :style="{ background: z.stColor }"
                ></span
                >{{ z.stText }}</span
              >
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { money } from '../data/adminData';
const heads = [
  { t: 'Vùng giao hàng' },
  { t: 'Phí cơ bản', a: 'right' },
  { t: 'Phí / kg thêm', a: 'right' },
  { t: 'Miễn phí từ', a: 'right' },
  { t: 'Trạng thái' },
];
const raw = [
  ['Nội thành TP.HCM', 'hcm-noi-thanh', 15000, 5000, 500000, true],
  ['Nội thành Hà Nội', 'hn-noi-thanh', 18000, 5000, 500000, true],
  ['Các tỉnh miền Nam', 'mien-nam', 25000, 7000, 1000000, true],
  ['Các tỉnh miền Bắc', 'mien-bac', 28000, 7000, 1000000, true],
  ['Miền Trung & Tây Nguyên', 'mien-trung', 30000, 8000, 1500000, true],
  ['Vùng sâu, hải đảo', 'vung-xa', 45000, 12000, 2000000, false],
];
const rows = raw.map((r) => {
  const [name, key, base, kg, free, active] = r;
  return {
    name,
    key,
    base: money(base),
    kg: money(kg),
    free: money(free),
    stText: active ? 'Bật' : 'Tắt',
    stColor: active ? 'var(--green)' : 'var(--muted)',
    stBg: active
      ? 'color-mix(in srgb,var(--green) 16%,transparent)'
      : 'var(--card2)',
  };
});
const zoneIdx = ref(0);
const kg = ref(2.5);
const orderVal = ref(850000);
const base = computed(() => raw[zoneIdx.value][2]);
const extraKg = computed(() => Math.max(0, (kg.value || 0) - 1));
const extra = computed(() => Math.round(extraKg.value) * raw[zoneIdx.value][3]);
const freeShip = computed(() => (orderVal.value || 0) >= raw[zoneIdx.value][4]);
</script>
