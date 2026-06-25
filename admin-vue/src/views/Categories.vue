<template>
  <div style="animation: fadeUp 0.35s ease">
    <div
      style="
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 16px;
      "
    >
      <div style="font-size: 13.5px; color: var(--muted)">
        6 danh mục đang hoạt động
      </div>
      <button
        style="
          display: flex;
          align-items: center;
          gap: 7px;
          height: 36px;
          padding: 0 15px;
          border-radius: 9px;
          border: none;
          background: var(--acc);
          color: #04121f;
          font-size: 12.5px;
          font-weight: 700;
          cursor: pointer;
        "
      >
        <i class="bi bi-plus-lg"></i> Thêm danh mục
      </button>
    </div>
    <div
      style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px"
    >
      <div
        v-for="c in cards"
        :key="c.name"
        style="
          background: var(--card);
          border: 1px solid var(--line);
          border-radius: 15px;
          overflow: hidden;
          cursor: pointer;
        "
      >
        <div
          style="
            height: 96px;
            position: relative;
            display: flex;
            align-items: flex-end;
            padding: 14px 16px;
            overflow: hidden;
          "
          :style="{ background: gradCat(c.hue) }"
        >
          <div
            style="
              position: absolute;
              inset: 0;
              background: repeating-linear-gradient(
                125deg,
                rgba(255, 255, 255, 0.05) 0 2px,
                transparent 2px 13px
              );
            "
          ></div>
          <div
            class="mono"
            style="
              position: absolute;
              top: 12px;
              right: 16px;
              font-size: 11px;
              letter-spacing: 2px;
              font-weight: 600;
              opacity: 0.9;
            "
            :style="{ color: c.color }"
          >
            {{ c.en }}
          </div>
          <div
            style="
              position: relative;
              font-size: 18px;
              font-weight: 700;
              color: #fff;
            "
          >
            {{ c.name }}
          </div>
        </div>
        <div
          style="
            padding: 16px;
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 8px;
          "
        >
          <div>
            <div
              class="mono"
              style="font-size: 18px; font-weight: 700; color: var(--text)"
            >
              {{ c.count }}
            </div>
            <div
              style="font-size: 10.5px; color: var(--muted); margin-top: 2px"
            >
              Sản phẩm
            </div>
          </div>
          <div>
            <div
              class="mono"
              style="font-size: 18px; font-weight: 700; color: var(--text)"
            >
              {{ c.stock }}
            </div>
            <div
              style="font-size: 10.5px; color: var(--muted); margin-top: 2px"
            >
              Tồn kho
            </div>
          </div>
          <div>
            <div
              class="mono"
              style="font-size: 18px; font-weight: 700"
              :style="{ color: c.color }"
            >
              {{ c.value }}
            </div>
            <div
              style="font-size: 10.5px; color: var(--muted); margin-top: 2px"
            >
              Giá trị
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import {
  CATS,
  CAT_COLORS,
  CAT_EN,
  PRODUCTS,
  short,
  gradCat,
} from '../data/adminData';
const cards = Object.keys(CATS).map((k) => {
  const ps = PRODUCTS.filter((p) => p.catSlug === k);
  return {
    name: CATS[k].label,
    en: CAT_EN[k],
    hue: CATS[k].hue,
    color: CAT_COLORS[k],
    count: ps.length + '',
    stock: ps.reduce((a, p) => a + p.stock, 0) + '',
    value: short(ps.reduce((a, p) => a + p.price * p.stock, 0)),
  };
});
</script>
