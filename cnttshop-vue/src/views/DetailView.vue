<script setup>
import { computed } from 'vue';
import {
  catMeta,
  fmt,
  productById,
  priceWith,
  products,
} from '../data/products.js';
import { state, actions, accent } from '../store.js';
import ProductCard from '../components/ProductCard.vue';

const sp = computed(() => productById(state.selId));

const live = computed(() => (sp.value ? priceWith(sp.value, state.cfgSel) : 0));
const upgraded = computed(() => sp.value && live.value !== sp.value.price);

const cfgGroups = computed(() => {
  if (!sp.value) return [];
  return (sp.value.cfg || []).map((g) => ({
    key: g.key,
    label: g.label,
    choices: g.ch.map((c, idx) => {
      const on = (state.cfgSel[g.key] || 0) === idx;
      return {
        idx,
        label: c.l,
        deltaText: c.d === 0 ? 'Tiêu chuẩn' : '+' + fmt(c.d),
        bdr: on ? accent.value : 'rgba(120,170,230,0.18)',
        bg: on
          ? 'color-mix(in srgb, ' + accent.value + ' 14%, transparent)'
          : '#0c2742',
        lblColor: on ? '#ffffff' : '#cfdceb',
        dColor: on ? accent.value : '#7e98b6',
      };
    }),
  }));
});

const specRows = computed(() => {
  if (!sp.value) return [];
  return sp.value.specs.map((r) => {
    const g = (sp.value.cfg || []).find((x) => x.label === r.k);
    return g ? { k: r.k, v: g.ch[state.cfgSel[g.key] || 0].l } : r;
  });
});

const detail = computed(() => {
  if (!sp.value) return null;
  const p = sp.value;
  return {
    brand: p.brand,
    name: p.name,
    hue: p.hue,
    catEn: catMeta[p.cat]?.en || '',
    catVn: catMeta[p.cat]?.vn || '',
    ratingText: (p.rating || 0).toFixed(1),
    reviews: p.reviews,
    desc:
      p.description ||
      'Sản phẩm chính hãng phân phối tại CNTTshop, bảo hành 24–36 tháng. Hỗ trợ trả góp 0%, giao hàng toàn quốc và lắp đặt miễn phí khu vực nội thành.',
    hasCfg: (p.cfg || []).length > 0,
    priceText: fmt(live.value),
    oldText: !upgraded.value && p.oldPrice ? fmt(p.oldPrice) : '',
    discount:
      !upgraded.value && p.oldPrice
        ? '-' + Math.round((1 - p.price / p.oldPrice) * 100) + '%'
        : '',
    installText: fmt(Math.round(live.value / 12 / 1000) * 1000),
  };
});

const related = computed(() => {
  if (!sp.value) return [];
  return products
    .filter((x) => x.cat === sp.value.cat && x.id !== sp.value.id)
    .slice(0, 4);
});

function onAdd() {
  actions.addToCart(sp.value.id, state.cfgSel);
}
function onBuy() {
  actions.addToCart(sp.value.id, state.cfgSel);
  actions.goCart();
}
</script>

<template>
  <main
    v-if="detail"
    style="max-width: 1800px; margin: 0 auto; padding: 24px 24px 70px"
  >
    <div style="font-size: 12.5px; color: #7e98b6; margin-bottom: 18px">
      <span @click="actions.goHome" style="cursor: pointer">Trang chủ</span>
      <span style="color: #4a627e">/</span>
      <span style="color: #cfdceb">{{ detail.catVn }}</span>
      <span style="color: #4a627e">/</span>
      <span style="color: #cfdceb">{{ detail.name }}</span>
    </div>
    <div
      style="
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 36px;
        align-items: start;
      "
    >
      <!-- gallery -->
      <div style="position: sticky; top: 130px">
        <div
          :style="{ '--ph': detail.hue }"
          style="
            position: relative;
            aspect-ratio: 1/1;
            border-radius: 18px;
            overflow: hidden;
            background: linear-gradient(
              140deg,
              hsl(var(--ph) 45% 17%),
              hsl(var(--ph) 58% 9%)
            );
            border: 1px solid rgba(120, 170, 230, 0.18);
            display: flex;
            align-items: center;
            justify-content: center;
          "
        >
          <div
            style="
              position: absolute;
              inset: 0;
              background: repeating-linear-gradient(
                125deg,
                rgba(255, 255, 255, 0.04) 0 2px,
                transparent 2px 14px
              );
            "
          ></div>
          <div style="text-align: center">
            <div
              style="
                font-family: 'Chakra Petch', sans-serif;
                font-weight: 700;
                font-size: 42px;
                letter-spacing: 2px;
                color: hsl(var(--ph) 70% 75% / 0.2);
              "
            >
              {{ detail.catEn }}
            </div>
            <div
              style="
                font-family: 'Chakra Petch', monospace;
                font-size: 10px;
                letter-spacing: 2px;
                color: rgba(200, 225, 255, 0.3);
                margin-top: 6px;
              "
            >
              [ ẢNH SẢN PHẨM ]
            </div>
          </div>
        </div>
        <div
          style="
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            margin-top: 10px;
          "
        >
          <div
            v-for="n in 4"
            :key="n"
            :style="{ '--ph': detail.hue }"
            style="
              aspect-ratio: 1/1;
              border-radius: 10px;
              background: linear-gradient(
                140deg,
                hsl(var(--ph) 42% 15%),
                hsl(var(--ph) 55% 9%)
              );
              border: 1px solid rgba(120, 170, 230, 0.14);
            "
          ></div>
        </div>
      </div>
      <!-- info -->
      <div>
        <div
          :style="{ color: accent }"
          style="
            font-family: 'Chakra Petch', sans-serif;
            font-size: 11px;
            letter-spacing: 2px;
            font-weight: 600;
          "
        >
          {{ detail.brand }}
        </div>
        <h1
          style="
            font-family: 'Be Vietnam Pro', sans-serif;
            font-weight: 700;
            font-size: 30px;
            line-height: 1.25;
            margin: 8px 0 12px;
          "
        >
          {{ detail.name }}
        </h1>
        <div
          style="
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 20px;
          "
        >
          <span style="color: #ffcf4d; font-size: 13px"
            >★
            <span style="color: #e8f1fc; font-weight: 600">{{
              detail.ratingText
            }}</span></span
          >
          <span style="color: #6e87a6; font-size: 13px"
            >{{ detail.reviews }} đánh giá</span
          >
          <span style="color: #2bd47e; font-size: 13px; font-weight: 600"
            >● Còn hàng</span
          >
        </div>
        <div
          style="
            background: #0a2138;
            border: 1px solid rgba(120, 170, 230, 0.14);
            border-radius: 14px;
            padding: 20px;
            margin-bottom: 20px;
          "
        >
          <div style="display: flex; align-items: baseline; gap: 12px">
            <span
              :style="{ color: accent }"
              style="
                font-family: 'Chakra Petch', sans-serif;
                font-weight: 700;
                font-size: 34px;
              "
              >{{ detail.priceText }}</span
            >
            <span
              v-if="detail.oldText"
              style="
                font-size: 15px;
                color: #6e87a6;
                text-decoration: line-through;
              "
              >{{ detail.oldText }}</span
            >
            <span
              v-if="detail.discount"
              style="
                font-family: 'Chakra Petch', sans-serif;
                font-weight: 700;
                font-size: 12px;
                background: #ff3b5c;
                color: #fff;
                padding: 4px 8px;
                border-radius: 6px;
              "
              >{{ detail.discount }}</span
            >
          </div>
          <div style="font-size: 12.5px; color: #7e98b6; margin-top: 8px">
            Trả góp chỉ từ
            <span style="color: #cfdceb">{{ detail.installText }}</span
            >/tháng · 0% lãi suất
          </div>
        </div>
        <p
          style="
            font-size: 14px;
            line-height: 1.65;
            color: #cfdceb;
            margin: 0 0 22px;
          "
        >
          {{ detail.desc }}
        </p>

        <div
          v-if="detail.hasCfg"
          style="
            margin-bottom: 24px;
            background: #0a2138;
            border: 1px solid rgba(120, 170, 230, 0.14);
            border-radius: 14px;
            padding: 18px 18px 20px;
          "
        >
          <div
            :style="{ color: accent }"
            style="
              font-family: 'Chakra Petch', sans-serif;
              font-size: 11px;
              letter-spacing: 2px;
              font-weight: 600;
              margin-bottom: 16px;
            "
          >
            TÙY CHỌN CẤU HÌNH
          </div>
          <div style="display: flex; flex-direction: column; gap: 16px">
            <div v-for="g in cfgGroups" :key="g.key">
              <div
                style="font-size: 12.5px; color: #9fb6d2; margin-bottom: 9px"
              >
                {{ g.label }}
              </div>
              <div style="display: flex; flex-wrap: wrap; gap: 10px">
                <div
                  v-for="ch in g.choices"
                  :key="ch.idx"
                  @click="actions.setCfg(g.key, ch.idx)"
                  :style="{ border: '1px solid ' + ch.bdr, background: ch.bg }"
                  style="
                    cursor: pointer;
                    border-radius: 11px;
                    padding: 10px 14px;
                    min-width: 128px;
                    transition:
                      border-color 0.15s,
                      background 0.15s;
                  "
                >
                  <div
                    :style="{ color: ch.lblColor }"
                    style="font-size: 13px; font-weight: 600"
                  >
                    {{ ch.label }}
                  </div>
                  <div
                    :style="{ color: ch.dColor }"
                    style="font-size: 11.5px; font-weight: 600; margin-top: 3px"
                  >
                    {{ ch.deltaText }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div
          style="
            display: flex;
            gap: 14px;
            align-items: center;
            margin-bottom: 24px;
          "
        >
          <button
            @click="onAdd"
            :style="{
              border: '1px solid ' + accent,
              background: 'color-mix(in srgb, ' + accent + ' 14%, transparent)',
              color: accent,
            }"
            style="
              flex: 1;
              height: 54px;
              border-radius: 13px;
              font-family: 'Be Vietnam Pro', sans-serif;
              font-weight: 700;
              font-size: 15px;
              cursor: pointer;
            "
          >
            Thêm vào giỏ
          </button>
          <button
            @click="onBuy"
            :style="{
              background: accent,
              boxShadow:
                '0 10px 26px color-mix(in srgb, ' +
                accent +
                ' 38%, transparent)',
            }"
            style="
              flex: 1;
              height: 54px;
              border: none;
              border-radius: 13px;
              color: #04121f;
              font-family: 'Be Vietnam Pro', sans-serif;
              font-weight: 700;
              font-size: 15px;
              cursor: pointer;
            "
          >
            Mua ngay
          </button>
        </div>

        <div
          style="
            background: #0a2138;
            border: 1px solid rgba(120, 170, 230, 0.12);
            border-radius: 14px;
            overflow: hidden;
          "
        >
          <div
            :style="{ color: accent }"
            style="
              padding: 14px 18px;
              font-family: 'Chakra Petch', sans-serif;
              font-size: 11px;
              letter-spacing: 2px;
              font-weight: 600;
              border-bottom: 1px solid rgba(120, 170, 230, 0.1);
            "
          >
            THÔNG SỐ KỸ THUẬT
          </div>
          <div
            v-for="(row, i) in specRows"
            :key="i"
            style="
              display: flex;
              padding: 12px 18px;
              border-bottom: 1px solid rgba(120, 170, 230, 0.07);
              font-size: 13.5px;
            "
          >
            <div style="width: 42%; color: #7e98b6">{{ row.k }}</div>
            <div style="flex: 1; color: #e8f1fc; font-weight: 500">
              {{ row.v }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- related -->
    <section style="margin-top: 50px">
      <h2
        style="
          font-family: 'Be Vietnam Pro', sans-serif;
          font-weight: 700;
          font-size: 22px;
          margin: 0 0 18px;
        "
      >
        Sản phẩm liên quan
      </h2>
      <div
        style="
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
          gap: 18px;
        "
      >
        <ProductCard
          v-for="p in related"
          :key="p.id"
          :p="p"
          @open="actions.goDetail"
          @add="actions.addToCart"
        />
      </div>
    </section>
  </main>
</template>
