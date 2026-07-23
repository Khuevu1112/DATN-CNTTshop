<template>
  <div v-if="loading || coupons.length || !hideWhenEmpty">
    <div v-if="title" style="font-size: 14px; font-weight: 700; color: var(--text); margin-bottom: 16px">
      {{ title }} ({{ coupons.length }})
    </div>

    <div v-if="loading" style="text-align: center; padding: 16px 0; color: var(--muted); font-size: 13px">Đang tải...</div>

    <div v-else-if="!coupons.length" style="font-size: 13.5px; color: var(--muted)">
      Bạn chưa đổi mã giảm giá nào. Ghé
      <a href="#" @click.prevent="actions.goPromotions" :style="{ color: accent }" style="text-decoration: none">trang khuyến mãi</a>
      để đổi Xu CT lấy mã giảm giá.
    </div>

    <div v-else style="display: flex; flex-direction: column; gap: 10px">
      <div
        v-for="c in coupons" :key="c.couponId"
        class="ct-ticket"
        @click="openTicket(c)"
        :style="{
          overflow: tearingId === c.couponId ? 'visible' : 'hidden',
          cursor: (c.used || isRevealed(c.couponId)) ? 'default' : 'pointer',
          opacity: c.used ? 0.55 : 1,
        }"
      >
        <div style="flex: 1; padding: 14px 16px; min-width: 0; position: relative; z-index: 1">
          <div :style="{ color: accent }" style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 19px">
            {{ discountLabel(c) }}
          </div>
          <div style="font-size: 11.5px; color: var(--muted2); margin-top: 4px">
            Đơn tối thiểu {{ fmt(c.minOrder) }}
          </div>

          <div v-if="(isRevealed(c.couponId) || c.used) && tearingId !== c.couponId" class="ct-code-in" style="margin-top: 8px; display: flex; align-items: center; gap: 8px; flex-wrap: wrap">
            <span
              @click.stop="copyCode(c.code)"
              style="font-family: 'Chakra Petch', monospace; font-weight: 700; font-size: 13.5px; letter-spacing: 1px; color: var(--text); cursor: pointer"
            >{{ c.code }}</span>
            <span style="font-size: 10.5px; color: var(--muted)">HSD {{ fmtDate(c.expiresAt) || 'Không giới hạn' }}</span>
          </div>
          <div v-else-if="tearingId !== c.couponId" style="margin-top: 8px; font-size: 11px; color: var(--muted)">Nhấn để xem mã</div>
        </div>

        <div class="ct-stub">
          <template v-if="tearingId !== c.couponId">
            <span style="font-size: 18px; position: relative; z-index: 2">{{ stubIcon(c) }}</span>
            <span style="font-size: 9.5px; color: var(--muted2); text-align: center; padding: 0 4px; position: relative; z-index: 2">{{ stubLabel(c) }}</span>
          </template>

          <template v-else>
            <div class="ct-tear-overlay">
              <span style="font-size: 18px">✂️</span>
              <span style="font-size: 9.5px; color: var(--muted2); text-align: center; padding: 0 4px">Xé vé</span>
            </div>
            <div class="ct-scrap ct-scrap-a"></div>
            <div class="ct-scrap ct-scrap-b"></div>
            <div class="ct-scrap ct-scrap-c"></div>
          </template>
        </div>

        <div v-if="tearingId === c.couponId" class="ct-edge"></div>
      </div>
    </div>
  </div>

  <Teleport to="body">
    <div v-if="confirmCoupon" style="position: fixed; inset: 0; background: rgba(0,0,0,0.6); display: flex; align-items: center; justify-content: center; z-index: 200; padding: 20px">
      <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.18); border-radius: 16px; padding: 26px; max-width: 340px; width: 100%; text-align: center">
        <div style="font-size: 32px; margin-bottom: 10px">🎫</div>
        <div style="font-size: 15px; font-weight: 700; color: var(--text); margin-bottom: 6px">Bạn muốn áp dụng ưu đãi này?</div>
        <div style="font-size: 12.5px; color: var(--muted2); margin-bottom: 20px">
          {{ discountLabel(confirmCoupon) }} — đơn tối thiểu {{ fmt(confirmCoupon.minOrder) }}
        </div>
        <div style="display: flex; gap: 10px">
          <button
            @click="cancelApply"
            style="flex: 1; height: 42px; border: 1px solid rgba(var(--line-rgb),0.22); background: transparent; border-radius: 10px; color: var(--muted2); font-size: 13px; cursor: pointer"
          >
            Không
          </button>
          <button
            @click="confirmApply"
            :style="{ background: accent }"
            style="flex: 1; height: 42px; border: none; border-radius: 10px; color: var(--acc-ink); font-weight: 700; font-size: 13px; cursor: pointer"
          >
            Có, áp dụng
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { ref } from 'vue';
import { state, actions, accent } from '../store.js';
import { fmt } from '../data/products.js';

const props = defineProps({
  coupons: { type: Array, default: () => [] },
  loading: { type: Boolean, default: false },
  title: { type: String, default: '🎟️ Mã giảm giá của tôi' },
  hideWhenEmpty: { type: Boolean, default: false },
});
const emit = defineEmits(['apply']);

const TEAR_MS = 680;

function fmtDate(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  return `${String(d.getDate()).padStart(2, '0')}/${String(d.getMonth() + 1).padStart(2, '0')}/${d.getFullYear()}`;
}

function revealedStorageKey() {
  return 'revealedCoupons:' + (state.user?.email || '');
}
const revealedIds = ref(new Set(JSON.parse(localStorage.getItem(revealedStorageKey()) || '[]')));
function isRevealed(couponId) {
  return revealedIds.value.has(couponId);
}
function persistRevealed(couponId) {
  revealedIds.value.add(couponId);
  localStorage.setItem(revealedStorageKey(), JSON.stringify([...revealedIds.value]));
}

function discountLabel(c) {
  return c.discountType === 'percent' ? `Giảm ${Number(c.discountValue)}%` : `Giảm ${fmt(c.discountValue)}`;
}
function stubIcon(c) {
  const shown = isRevealed(c.couponId) || c.used;
  return shown ? (c.used ? '✅' : '🎫') : '✂️';
}
function stubLabel(c) {
  const shown = isRevealed(c.couponId) || c.used;
  return shown ? (c.used ? 'Đã dùng' : 'Đã mở') : 'Xé vé';
}

const confirmCoupon = ref(null);
const tearingId = ref(null);
let tearTimer = null;

function openTicket(c) {
  if (c.used || isRevealed(c.couponId) || tearingId.value) return;
  confirmCoupon.value = c;
}
function cancelApply() {
  confirmCoupon.value = null;
}
function confirmApply() {
  const c = confirmCoupon.value;
  confirmCoupon.value = null;
  tearingId.value = c.couponId;
  clearTimeout(tearTimer);
  tearTimer = setTimeout(() => {
    tearingId.value = null;
    persistRevealed(c.couponId);
    emit('apply', c);
  }, TEAR_MS);
}

function copyCode(code) {
  navigator.clipboard?.writeText(code);
  actions.showToast('Đã sao chép mã giảm giá');
}
</script>

<style scoped>
.ct-ticket {
  display: flex;
  position: relative;
  border-radius: 10px;
  border: 1px solid rgba(var(--line-rgb), 0.16);
  transition: opacity 0.25s ease;
}
.ct-stub {
  width: 84px;
  flex: none;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  position: relative;
  border-left: 2px dashed rgba(var(--line-rgb), 0.3);
  background: var(--card);
}
.ct-tear-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  background: var(--card);
  border-left: 2px dashed rgba(var(--line-rgb), 0.3);
  z-index: 3;
  animation: ct-stub-fly 680ms ease forwards;
}
.ct-scrap {
  position: absolute;
  background: var(--card2);
  border-radius: 1px;
  z-index: 4;
}
.ct-scrap-a { top: 10px; left: 6px; width: 7px; height: 7px; animation: ct-scrap-a 0.6s ease-out forwards; }
.ct-scrap-b { top: 34px; left: 10px; width: 6px; height: 6px; animation: ct-scrap-b 0.6s ease-out forwards; }
.ct-scrap-c { bottom: 8px; left: 4px; width: 8px; height: 5px; animation: ct-scrap-c 0.6s ease-out forwards; }
.ct-edge {
  position: absolute;
  top: 0;
  bottom: 0;
  right: 84px;
  width: 10px;
  background-image: linear-gradient(135deg, transparent 50%, var(--card) 50%), linear-gradient(-135deg, transparent 50%, var(--card) 50%);
  background-size: 10px 10px;
  background-repeat: repeat-y;
  animation: ct-edge-in 0.3s ease both;
}
.ct-code-in {
  animation: ct-code-in 0.35s ease both;
}

@keyframes ct-stub-fly {
  0%   { transform: translate(0,0) rotate(0deg) scale(1); opacity: 1; }
  45%  { transform: translate(30px,6px) rotate(10deg) scale(1); opacity: 1; }
  100% { transform: translate(120px,26px) rotate(26deg) scale(0.9); opacity: 0; }
}
@keyframes ct-scrap-a {
  0% { transform: translate(0,0) rotate(0deg); opacity: 1; }
  100% { transform: translate(64px,-38px) rotate(140deg); opacity: 0; }
}
@keyframes ct-scrap-b {
  0% { transform: translate(0,0) rotate(0deg); opacity: 1; }
  100% { transform: translate(70px,30px) rotate(-120deg); opacity: 0; }
}
@keyframes ct-scrap-c {
  0% { transform: translate(0,0) rotate(0deg); opacity: 1; }
  100% { transform: translate(48px,54px) rotate(200deg); opacity: 0; }
}
@keyframes ct-edge-in {
  from { opacity: 0; transform: scaleY(0.6); }
  to   { opacity: 1; transform: scaleY(1); }
}
@keyframes ct-code-in {
  from { opacity: 0; transform: translateY(8px); }
  to   { opacity: 1; transform: translateY(0); }
}
</style>
