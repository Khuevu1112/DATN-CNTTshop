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
            background: color-mix(in srgb, var(--acc) 14%, transparent);
            color: var(--acc);
            font-size: 17px;
          "
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
      <div
        style="
          display: flex;
          align-items: center;
          gap: 8px;
          padding: 14px 16px;
          border-bottom: 1px solid var(--line);
          flex-wrap: wrap;
        "
      >
        <button
          v-for="ch in chips"
          :key="ch.key"
          @click="cat = ch.key"
          style="
            display: flex;
            align-items: center;
            gap: 7px;
            padding: 6px 12px;
            border-radius: 9px;
            font-size: 12.5px;
            font-weight: 600;
            cursor: pointer;
          "
          :style="{
            border:
              '1px solid ' + (cat === ch.key ? 'var(--acc)' : 'var(--line2)'),
            background: cat === ch.key ? 'var(--acc)' : 'var(--card)',
            color: cat === ch.key ? '#04121f' : 'var(--muted2)',
          }"
        >
          {{ ch.label }}
          <span
            class="mono"
            style="font-size: 10.5px; padding: 0 6px; border-radius: 8px"
            :style="{
              background:
                cat === ch.key ? 'rgba(4,18,31,0.18)' : 'var(--card2)',
              color: cat === ch.key ? '#04121f' : 'var(--muted)',
            }"
            >{{ ch.count }}</span
          >
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
            border: none;
            background: var(--acc);
            color: #04121f;
            font-size: 12.5px;
            font-weight: 700;
            cursor: pointer;
          "
        >
          <i class="bi bi-plus-lg"></i> Thêm sản phẩm
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
            v-for="p in rows"
            :key="p.id"
            @click="detail = p"
            style="border-top: 1px solid var(--line); cursor: pointer"
          >
            <td style="padding: 11px 16px">
              <div style="display: flex; align-items: center; gap: 11px">
                <div
                  class="mono"
                  style="
                    width: 40px;
                    height: 40px;
                    border-radius: 9px;
                    flex: none;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 11px;
                    font-weight: 700;
                  "
                  :style="{ background: grad(p.hue), color: gradText(p.hue) }"
                >
                  {{ p.tag }}
                </div>
                <div style="min-width: 0">
                  <div
                    style="
                      font-size: 13px;
                      font-weight: 500;
                      color: var(--text);
                    "
                  >
                    {{ p.name }}
                  </div>
                  <div
                    class="mono"
                    style="
                      font-size: 11px;
                      color: var(--muted);
                      margin-top: 2px;
                    "
                  >
                    {{ p.sku }} · {{ p.spec }}
                  </div>
                </div>
              </div>
            </td>
            <td style="padding: 11px 12px">
              <span style="font-size: 12px; color: var(--muted2)">{{
                p.cat
              }}</span>
            </td>
            <td
              style="padding: 11px 12px; color: var(--text); font-size: 12.5px"
            >
              {{ p.brand }}
            </td>
            <td style="padding: 11px 12px; text-align: right">
              <div
                class="mono"
                style="font-size: 13.5px; font-weight: 700; color: var(--text)"
              >
                {{ p.priceFmt }}
              </div>
              <div
                v-if="p.oldp"
                style="
                  display: flex;
                  align-items: center;
                  justify-content: flex-end;
                  gap: 6px;
                  margin-top: 2px;
                "
              >
                <span
                  class="mono"
                  style="
                    font-size: 10.5px;
                    color: var(--muted);
                    text-decoration: line-through;
                  "
                  >{{ p.oldFmt }}</span
                ><span
                  class="mono"
                  style="font-size: 10px; font-weight: 700; color: var(--sale)"
                  >-{{ p.disc }}%</span
                >
              </div>
            </td>
            <td style="padding: 11px 12px">
              <div style="display: flex; align-items: center; gap: 8px">
                <span
                  class="mono"
                  style="font-size: 13px; font-weight: 700; width: 24px"
                  :style="{ color: stockColor(p.stock) }"
                  >{{ p.stock }}</span
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
                    style="height: 100%; border-radius: 4px"
                    :style="{
                      width:
                        Math.min(100, Math.round((p.stock / 50) * 100)) + '%',
                      background: stockColor(p.stock),
                    }"
                  ></div>
                </div>
              </div>
            </td>
            <td style="padding: 11px 12px">
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
                :style="{
                  background: p.active
                    ? 'color-mix(in srgb,var(--green) 16%,transparent)'
                    : 'var(--card2)',
                  color: p.active ? 'var(--green)' : 'var(--muted)',
                }"
                ><span
                  style="width: 6px; height: 6px; border-radius: 50%"
                  :style="{
                    background: p.active ? 'var(--green)' : 'var(--muted)',
                  }"
                ></span
                >{{ p.active ? 'Hiển thị' : 'Ẩn' }}</span
              >
            </td>
            <td style="padding: 11px 16px; text-align: center">
              <i
                class="bi bi-three-dots-vertical"
                style="color: var(--muted); font-size: 15px"
              ></i>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <template v-if="detail">
      <div
        @click="detail = null"
        style="
          position: fixed;
          inset: 0;
          background: rgba(2, 8, 18, 0.55);
          backdrop-filter: blur(2px);
          z-index: 60;
          animation: fadeUp 0.2s ease;
        "
      ></div>
      <div
        style="
          position: fixed;
          top: 0;
          right: 0;
          width: 440px;
          max-width: 92vw;
          height: 100vh;
          background: var(--bg);
          border-left: 1px solid var(--line2);
          z-index: 61;
          display: flex;
          flex-direction: column;
          box-shadow: -20px 0 60px rgba(0, 0, 0, 0.4);
          animation: fadeUp 0.25s ease;
        "
      >
        <div
          style="
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 18px 20px;
            border-bottom: 1px solid var(--line);
          "
        >
          <div style="font-size: 14px; font-weight: 600; color: var(--text)">
            Chi tiết sản phẩm
          </div>
          <button
            @click="detail = null"
            style="
              width: 32px;
              height: 32px;
              border-radius: 8px;
              border: 1px solid var(--line2);
              background: var(--card);
              color: var(--text);
              cursor: pointer;
            "
          >
            <i class="bi bi-x-lg" style="font-size: 13px"></i>
          </button>
        </div>
        <div style="flex: 1; overflow-y: auto; padding: 20px">
          <div
            style="
              display: flex;
              gap: 14px;
              align-items: center;
              margin-bottom: 20px;
            "
          >
            <div
              class="mono"
              style="
                width: 72px;
                height: 72px;
                border-radius: 14px;
                flex: none;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 16px;
                font-weight: 700;
              "
              :style="{
                background: grad(detail.hue),
                color: gradText(detail.hue),
              }"
            >
              {{ detail.tag }}
            </div>
            <div>
              <div
                style="
                  font-size: 16px;
                  font-weight: 700;
                  color: var(--text);
                  line-height: 1.3;
                "
              >
                {{ detail.name }}
              </div>
              <div
                class="mono"
                style="font-size: 12px; color: var(--muted); margin-top: 4px"
              >
                {{ detail.sku }}
              </div>
            </div>
          </div>
          <div
            style="
              display: grid;
              grid-template-columns: 1fr 1fr;
              gap: 10px;
              margin-bottom: 18px;
            "
          >
            <div
              style="
                background: var(--card);
                border: 1px solid var(--line);
                border-radius: 11px;
                padding: 13px;
              "
            >
              <div
                style="font-size: 11px; color: var(--muted); margin-bottom: 5px"
              >
                Giá bán
              </div>
              <div
                class="mono"
                style="font-size: 18px; font-weight: 700; color: var(--acc)"
              >
                {{ detail.priceFmt }}
              </div>
              <span
                v-if="detail.oldp"
                class="mono"
                style="
                  font-size: 11px;
                  color: var(--muted);
                  text-decoration: line-through;
                "
                >{{ detail.oldFmt }}</span
              >
            </div>
            <div
              style="
                background: var(--card);
                border: 1px solid var(--line);
                border-radius: 11px;
                padding: 13px;
              "
            >
              <div
                style="font-size: 11px; color: var(--muted); margin-bottom: 5px"
              >
                Tồn kho
              </div>
              <div
                class="mono"
                style="font-size: 18px; font-weight: 700; color: var(--text)"
              >
                {{ detail.stock }}
              </div>
              <span
                style="font-size: 11px"
                :style="{
                  color: detail.active ? 'var(--green)' : 'var(--muted)',
                }"
                >{{ detail.active ? 'Đang hiển thị' : 'Đang ẩn' }}</span
              >
            </div>
          </div>
          <div
            style="
              font-size: 11px;
              font-weight: 600;
              color: var(--muted);
              text-transform: uppercase;
              letter-spacing: 0.5px;
              margin-bottom: 10px;
            "
          >
            Thông tin chung
          </div>
          <div
            style="
              background: var(--card);
              border: 1px solid var(--line);
              border-radius: 12px;
              overflow: hidden;
              margin-bottom: 20px;
            "
          >
            <div
              style="
                display: flex;
                justify-content: space-between;
                padding: 11px 14px;
                font-size: 13px;
                border-bottom: 1px solid var(--line);
              "
            >
              <span style="color: var(--muted)">Danh mục</span
              ><span style="color: var(--text); font-weight: 500">{{
                detail.cat
              }}</span>
            </div>
            <div
              style="
                display: flex;
                justify-content: space-between;
                padding: 11px 14px;
                font-size: 13px;
                border-bottom: 1px solid var(--line);
              "
            >
              <span style="color: var(--muted)">Thương hiệu</span
              ><span style="color: var(--text); font-weight: 500">{{
                detail.brand
              }}</span>
            </div>
            <div
              style="
                display: flex;
                justify-content: space-between;
                padding: 11px 14px;
                font-size: 13px;
              "
            >
              <span style="color: var(--muted)">Cấu hình</span
              ><span
                style="
                  color: var(--text);
                  font-weight: 500;
                  text-align: right;
                  max-width: 60%;
                "
                >{{ detail.spec }}</span
              >
            </div>
          </div>
          <div style="display: flex; gap: 10px">
            <button
              style="
                flex: 1;
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
              <i class="bi bi-pencil-square"></i> Chỉnh sửa
            </button>
            <button
              style="
                width: 42px;
                height: 42px;
                border-radius: 10px;
                border: 1px solid var(--line2);
                background: var(--card);
                color: var(--sale);
                font-size: 15px;
                cursor: pointer;
              "
            >
              <i class="bi bi-trash3"></i>
            </button>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { PRODUCTS, CATS, short, grad, gradText } from '../data/adminData';
import { ui } from '../uiState';
const cat = ref('all');
const detail = ref(null);
const heads = [
  { t: 'Sản phẩm' },
  { t: 'Danh mục' },
  { t: 'Hãng' },
  { t: 'Giá bán', a: 'right' },
  { t: 'Tồn kho' },
  { t: 'Trạng thái' },
  { t: '' },
];
const chips = computed(() =>
  [{ key: 'all', label: 'Tất cả', count: PRODUCTS.length }].concat(
    Object.keys(CATS).map((k) => ({
      key: k,
      label: CATS[k].label,
      count: PRODUCTS.filter((p) => p.catSlug === k).length,
    })),
  ),
);
const rows = computed(() => {
  const q = ui.search.trim().toLowerCase();
  return PRODUCTS.filter(
    (p) =>
      (cat.value === 'all' || p.catSlug === cat.value) &&
      (!q ||
        p.name.toLowerCase().includes(q) ||
        p.brand.toLowerCase().includes(q)),
  );
});
const stockColor = (s) =>
  s <= 5 ? 'var(--sale)' : s <= 12 ? 'var(--amber)' : 'var(--green)';
const stats = [
  { label: 'Tổng sản phẩm', value: PRODUCTS.length + '', icon: 'bi-box-seam' },
  {
    label: 'Đang hiển thị',
    value: PRODUCTS.filter((p) => p.active).length + '',
    icon: 'bi-eye',
  },
  {
    label: 'Sắp hết hàng',
    value: PRODUCTS.filter((p) => p.stock <= 5).length + '',
    icon: 'bi-exclamation-triangle',
  },
  {
    label: 'Giá trị tồn kho',
    value: short(PRODUCTS.reduce((a, p) => a + p.price * p.stock, 0)),
    icon: 'bi-cash-stack',
  },
];
</script>
