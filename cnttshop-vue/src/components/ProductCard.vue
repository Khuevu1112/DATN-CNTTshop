<script setup>
import { computed, ref, onBeforeUnmount, watch } from 'vue';
import { useRoute } from 'vue-router';
import { catMeta, fmt, silverTokensFor } from '../data/products.js';
import { accent } from '../store.js';
import { resolveImageUrl } from '../api.js';
import { flyToCart } from '../flyToCart.js';

const props = defineProps({ p: { type: Object, required: true } });
const emit = defineEmits(['open', 'add']);

const catEn = computed(() => catMeta[props.p.cat]?.en || '');
const imageUrl = computed(() => resolveImageUrl(props.p.image));
const priceText = computed(() => fmt(props.p.price));
const tokenText = computed(() => '+' + silverTokensFor(props.p.price) + ' Xu CT');
const oldText = computed(() => (props.p.oldPrice ? fmt(props.p.oldPrice) : ''));
const discount = computed(() =>
  props.p.oldPrice
    ? '-' + Math.round((1 - props.p.price / props.p.oldPrice) * 100) + '%'
    : '',
);
const ratingText = computed(() => props.p.rating.toFixed(1));
const chips = computed(() => props.p.specs.slice(0, 3).map((s) => s.v));

const cardStyle = computed(() => ({
  '--acc': accent.value,
  '--ph': props.p.hue,
}));

function onAdd(e) {
  e.stopPropagation();
  flyToCart(e.currentTarget, imageUrl.value);
  emit('add', props.p.id);
}

// Mở trang chi tiết: LUÔN đóng tháp preview trước khi điều hướng — nếu không, panel preview
// (Teleport ra <body>, position:fixed, z-index cao) có thể còn "kẹt" lại sau khi chuyển trang,
// che nội dung trang mới và nuốt cú click (button ở trang mới bấm không ăn). Xem hidePreview().
function openDetail() {
  hidePreview();
  emit('open', props.p.id);
}

// ---- hover preview (tháp xem trước khi rê chuột, kiểu TTGshop) ----
const route = useRoute();
const cardEl = ref(null);
const showPreview = ref(false);
const previewPos = ref({ left: '0px', top: '0px', width: '300px' });
let enterTimer = null;
let leaveTimer = null;
const PANEL_W = 300;

// Đóng preview + huỷ mọi timer đang chờ. Gọi khi điều hướng / cuộn / rời chuột dứt khoát.
function hidePreview() {
  clearTimeout(enterTimer);
  clearTimeout(leaveTimer);
  showPreview.value = false;
}
// Hễ URL đổi (đổi danh mục, mở chi tiết, bấm menu header...) thì đóng ngay preview để nó
// không còn "treo" trên trang mới. Đây là bug: preview được Teleport ra <body> nên không tự
// biến mất khi thẻ sản phẩm cha bị thay/gỡ lúc chuyển route phía SPA.
watch(() => route.fullPath, hidePreview);

const allSpecs = computed(() => (props.p.specs || []).filter((s) => s.v));
const promos = computed(() => props.p.promotions || []);
const warrantyText = computed(() =>
  props.p.warrantyMonths ? `Bảo hành ${props.p.warrantyMonths} tháng` : '',
);

// Teleport ra <body> + toạ độ tính bằng JS: tránh bị các khối overflow-x:auto
// (hàng sản phẩm cuộn ngang ở Home/Category) cắt mất phần tràn theo chiều dọc.
function placePreview() {
  const el = cardEl.value;
  if (!el) return;
  const r = el.getBoundingClientRect();
  const gap = 10;
  let left = r.right + gap;
  if (left + PANEL_W > window.innerWidth - 8) left = r.left - PANEL_W - gap;
  if (left < 8) left = Math.min(r.left, Math.max(8, window.innerWidth - PANEL_W - 8));
  const maxH = Math.min(460, window.innerHeight - 16);
  let top = r.top;
  if (top + maxH > window.innerHeight - 8) top = Math.max(8, window.innerHeight - maxH - 8);
  previewPos.value = { left: left + 'px', top: top + 'px', width: PANEL_W + 'px' };
}

function onCardEnter() {
  clearTimeout(leaveTimer);
  enterTimer = setTimeout(() => {
    placePreview();
    showPreview.value = true;
  }, 250);
}
function onCardLeave() {
  clearTimeout(enterTimer);
  leaveTimer = setTimeout(() => {
    showPreview.value = false;
  }, 120);
}
onBeforeUnmount(() => {
  // Tắt preview TRƯỚC khi component gỡ — bảo đảm node teleport bị xoá cùng lúc, không mồ côi lại trong <body>.
  hidePreview();
});
</script>

<template>
  <div
    ref="cardEl"
    class="pcard"
    :style="cardStyle"
    @click="openDetail"
    @mouseenter="onCardEnter"
    @mouseleave="onCardLeave"
    style="
      cursor: pointer;
      background: linear-gradient(180deg, var(--card2), var(--card));
      border: 1px solid rgba(var(--line-rgb), 0.14);
      border-radius: 14px;
      overflow: hidden;
      display: flex;
      flex-direction: column;
      transition:
        transform 0.18s ease,
        border-color 0.18s ease,
        box-shadow 0.18s ease;
      height: 100%;
    "
  >
    <div
      style="
        position: relative;
        aspect-ratio: 4/3;
        background: linear-gradient(
          135deg,
          hsl(var(--ph) 42% 16%),
          hsl(var(--ph) 55% 9%)
        );
        overflow: hidden;
        display: flex;
        align-items: center;
        justify-content: center;
      "
    >
      <img
        v-if="imageUrl"
        :src="imageUrl"
        :alt="p.name"
        style="position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover"
      />
      <template v-else>
        <div
          style="
            position: absolute;
            inset: 0;
            background: repeating-linear-gradient(
              125deg,
              rgba(255, 255, 255, 0.045) 0 2px,
              transparent 2px 12px
            );
          "
        ></div>
        <div
          style="
            font-family: 'Chakra Petch', sans-serif;
            font-weight: 700;
            font-size: 34px;
            letter-spacing: 3px;
            color: hsl(var(--ph) 65% 72% / 0.16);
          "
        >
          {{ catEn }}
        </div>
        <div
          style="
            position: absolute;
            bottom: 9px;
            left: 0;
            right: 0;
            text-align: center;
            font-family: 'Chakra Petch', monospace;
            font-size: 9px;
            letter-spacing: 1.5px;
            color: rgba(200, 225, 255, 0.3);
          "
        >
          [ ẢNH SẢN PHẨM ]
        </div>
      </template>
      <div
        v-if="p.badge"
        style="
          position: absolute;
          top: 10px;
          left: 10px;
          font-family: 'Chakra Petch', sans-serif;
          font-weight: 700;
          font-size: 10px;
          letter-spacing: 1px;
          padding: 4px 8px;
          border-radius: 6px;
          background: var(--acc);
          color: var(--acc-ink);
        "
      >
        {{ p.badge }}
      </div>
      <div
        v-if="discount"
        style="
          position: absolute;
          top: 10px;
          right: 10px;
          font-family: 'Chakra Petch', sans-serif;
          font-weight: 700;
          font-size: 11px;
          padding: 4px 8px;
          border-radius: 6px;
          background: #ff3b5c;
          color: #fff;
        "
      >
        {{ discount }}
      </div>
    </div>
    <div
      style="
        padding: 14px 14px 16px;
        display: flex;
        flex-direction: column;
        gap: 9px;
        flex: 1;
      "
    >
      <div
        style="
          font-family: 'Chakra Petch', sans-serif;
          font-size: 10px;
          letter-spacing: 1.5px;
          color: var(--acc);
          font-weight: 600;
          text-transform: uppercase;
        "
      >
        {{ p.brand }}
      </div>
      <div
        style="
          font-family: 'Plus Jakarta Sans', sans-serif;
          font-weight: 600;
          font-size: 14.5px;
          line-height: 1.35;
          color: var(--text);
          display: -webkit-box;
          line-clamp: 2;
          -webkit-line-clamp: 2;
          -webkit-box-orient: vertical;
          overflow: hidden;
          min-height: 39px;
        "
      >
        {{ p.name }}
      </div>
      <div style="display: flex; flex-wrap: wrap; gap: 5px">
        <span
          v-for="(chip, i) in chips"
          :key="i"
          :title="chip"
          style="
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 10.5px;
            color: var(--muted2);
            background: rgba(var(--line-rgb), 0.08);
            border: 1px solid rgba(var(--line-rgb), 0.12);
            padding: 3px 7px;
            border-radius: 5px;
            display: inline-block;
            max-width: 100%;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
          "
          >{{ chip }}</span
        >
      </div>
      <div
        style="
          display: flex;
          align-items: center;
          gap: 5px;
          font-size: 11.5px;
          color: #ffcf4d;
        "
      >
        ★ <span style="color: var(--muted2); font-weight: 600">{{ ratingText }}</span
        ><span style="color: var(--muted)">({{ p.reviews }})</span>
      </div>
      <div
        style="
          margin-top: auto;
          display: flex;
          align-items: flex-end;
          justify-content: space-between;
          gap: 8px;
          padding-top: 4px;
        "
      >
        <div>
          <div
            style="
              font-family: 'Chakra Petch', sans-serif;
              font-weight: 700;
              font-size: 18px;
              color: var(--text);
            "
          >
            {{ priceText }}
          </div>
          <div
            v-if="oldText"
            style="
              font-size: 11px;
              color: var(--muted);
              text-decoration: line-through;
            "
          >
            {{ oldText }}
          </div>
          <div style="font-size: 10.5px; color: #d9b34a; font-weight: 600; margin-top: 2px">
            {{ tokenText }}
          </div>
        </div>
        <button
          @click="onAdd"
          title="Thêm vào giỏ"
          class="add-btn"
          style="
            flex: none;
            width: 40px;
            height: 40px;
            border: none;
            border-radius: 10px;
            background: color-mix(in srgb, var(--acc) 16%, var(--card2));
            color: var(--acc);
            font-size: 20px;
            line-height: 1;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition:
              background 0.15s,
              color 0.15s;
          "
        >
          +
        </button>
      </div>
    </div>
  </div>

  <Teleport to="body">
    <div
      v-if="showPreview"
      class="pcard-preview"
      :style="{ ...cardStyle, left: previewPos.left, top: previewPos.top, width: previewPos.width }"
      @mouseenter="onCardEnter"
      @mouseleave="onCardLeave"
      @click.stop
    >
      <div style="display: flex; gap: 10px; align-items: flex-start">
        <div
          style="
            flex: none;
            width: 60px;
            height: 60px;
            border-radius: 10px;
            background: linear-gradient(135deg, hsl(var(--ph) 42% 16%), hsl(var(--ph) 55% 9%));
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            font-family: 'Chakra Petch', sans-serif;
            font-weight: 700;
            font-size: 10px;
            letter-spacing: 1px;
            color: hsl(var(--ph) 65% 72% / 0.35);
          "
        >
          <img v-if="imageUrl" :src="imageUrl" :alt="p.name" style="width: 100%; height: 100%; object-fit: cover" />
          <template v-else>{{ catEn }}</template>
        </div>
        <div style="min-width: 0; flex: 1">
          <div
            style="
              font-family: 'Chakra Petch', sans-serif;
              font-size: 9.5px;
              letter-spacing: 1.3px;
              color: var(--acc);
              font-weight: 600;
              text-transform: uppercase;
            "
          >
            {{ p.brand }}
          </div>
          <div
            style="
              font-family: 'Plus Jakarta Sans', sans-serif;
              font-weight: 600;
              font-size: 13.5px;
              line-height: 1.32;
              color: var(--text);
              margin-top: 3px;
            "
          >
            {{ p.name }}
          </div>
        </div>
      </div>

      <div style="display: flex; align-items: center; gap: 5px; margin-top: 10px; font-size: 11px; color: #ffcf4d">
        ★ <span style="color: var(--muted2); font-weight: 600">{{ ratingText }}</span
        ><span style="color: var(--muted)">({{ p.reviews }} đánh giá)</span>
      </div>

      <div style="display: flex; align-items: baseline; gap: 8px; margin-top: 9px; flex-wrap: wrap">
        <div style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 19px; color: var(--text)">
          {{ priceText }}
        </div>
        <div v-if="oldText" style="font-size: 11.5px; color: var(--muted); text-decoration: line-through">
          {{ oldText }}
        </div>
        <div v-if="discount" style="font-size: 10.5px; font-weight: 700; color: #ff3b5c">{{ discount }}</div>
      </div>

      <div v-if="warrantyText" style="display: flex; align-items: center; gap: 6px; margin-top: 9px; font-size: 11.5px; color: var(--muted2)">
        <span style="color: var(--acc)">🛡</span> {{ warrantyText }}
      </div>

      <div
        v-if="allSpecs.length"
        style="margin-top: 11px; padding-top: 11px; border-top: 1px solid rgba(var(--line-rgb), 0.14); display: flex; flex-direction: column; gap: 2px"
      >
        <div
          v-for="(s, i) in allSpecs"
          :key="i"
          style="display: flex; align-items: flex-start; gap: 7px; font-size: 12px; color: var(--muted2); padding: 2px 0"
        >
          <span style="color: var(--acc); font-weight: 700; flex: none; line-height: 1.5">✓</span>
          <span><b v-if="s.k" style="color: var(--muted); font-weight: 600">{{ s.k }}:</b> {{ s.v }}</span>
        </div>
      </div>

      <div
        v-if="promos.length"
        style="margin-top: 11px; padding-top: 11px; border-top: 1px solid rgba(var(--line-rgb), 0.14); display: flex; flex-direction: column; gap: 5px"
      >
        <div v-for="(pr, i) in promos" :key="i" style="display: flex; align-items: flex-start; gap: 7px; font-size: 11.5px; color: var(--muted2)">
          <span style="flex: none">🎁</span> <span>{{ pr }}</span>
        </div>
      </div>

      <div style="display: flex; gap: 8px; margin-top: 14px">
        <button
          @click="openDetail"
          style="
            flex: 1;
            height: 36px;
            border: none;
            border-radius: 9px;
            background: rgba(var(--line-rgb), 0.1);
            color: var(--text);
            font-size: 12.5px;
            font-weight: 600;
            cursor: pointer;
            font-family: 'Plus Jakarta Sans', sans-serif;
          "
        >
          Xem chi tiết
        </button>
        <button
          @click="onAdd"
          title="Thêm vào giỏ"
          style="
            flex: none;
            width: 36px;
            height: 36px;
            border: none;
            border-radius: 9px;
            background: var(--acc);
            color: var(--acc-ink);
            font-size: 18px;
            line-height: 1;
            cursor: pointer;
          "
        >
          +
        </button>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.pcard:hover {
  transform: translateY(-4px);
  border-color: var(--acc) !important;
  box-shadow:
    0 14px 34px rgba(0, 0, 0, 0.45),
    0 0 0 1px color-mix(in srgb, var(--acc) 40%, transparent);
}
.add-btn:hover {
  background: var(--acc) !important;
  color: var(--acc-ink) !important;
}
.pcard-preview {
  position: fixed;
  z-index: 150;
  background: var(--card);
  border: 1px solid color-mix(in srgb, var(--acc) 30%, transparent);
  border-radius: 14px;
  padding: 14px;
  max-height: 460px;
  overflow-y: auto;
  box-shadow:
    0 20px 50px rgba(0, 0, 0, 0.55),
    0 0 0 1px rgba(0, 0, 0, 0.2);
  animation: pcard-preview-in 0.16s ease;
}
@keyframes pcard-preview-in {
  from {
    opacity: 0;
    transform: translateY(4px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
