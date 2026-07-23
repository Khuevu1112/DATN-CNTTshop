<script setup>
import { computed } from 'vue';
import { fmt, silverTokensFor } from '../data/products.js';
import { state, actions, accent } from '../store.js';

const cartLines = computed(() =>
  state.cart.map((c) => ({
    id: c.id,
    name: c.productName,
    sku: c.sku,
    optionsText: c.optionsText,
    priceText: fmt(c.unitPrice),
    qty: c.quantity,
    lineText: fmt(c.lineTotal),
    imageUrl: c.imageUrl,
    lineTotal: c.lineTotal,
  })),
);

const selectedCount = computed(() => state.selectedCartItemIds.length);
const allSelected = computed(() =>
  state.cart.length > 0 && state.selectedCartItemIds.length === state.cart.length,
);
const selectedSubtotal = computed(() =>
  state.cart
    .filter((c) => state.selectedCartItemIds.includes(c.id))
    .reduce((sum, c) => sum + c.lineTotal, 0),
);
const selectedQtyCount = computed(() =>
  state.cart
    .filter((c) => state.selectedCartItemIds.includes(c.id))
    .reduce((sum, c) => sum + c.quantity, 0),
);
const subtotalText = computed(() => fmt(selectedSubtotal.value));
const tokenText = computed(() => '+' + silverTokensFor(selectedSubtotal.value) + ' Xu CT');
</script>

<template>
  <main style="max-width: 1320px; margin: 0 auto; padding: 24px 24px 70px">
    <h1
      style="
        font-family: 'Be Vietnam Pro', sans-serif;
        font-weight: 700;
        font-size: 28px;
        margin: 6px 0 22px;
      "
    >
      Giỏ hàng
    </h1>

    <div
      v-if="cartLines.length"
      style="
        display: grid;
        grid-template-columns: 1fr 340px;
        gap: 24px;
        align-items: start;
      "
    >
      <div style="display: flex; flex-direction: column; gap: 12px">
        <div
          style="
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 4px 6px;
            font-size: 13px;
            color: var(--muted2);
          "
        >
          <input
            type="checkbox"
            :checked="allSelected"
            @change="actions.setAllCartItemsSelected($event.target.checked)"
            style="width: 18px; height: 18px; accent-color: var(--acc, #c6ff4a); cursor: pointer"
          />
          <span @click="actions.setAllCartItemsSelected(!allSelected)" style="cursor: pointer">
            Chọn tất cả ({{ selectedCount }}/{{ cartLines.length }})
          </span>
        </div>
        <TransitionGroup name="cart-line" tag="div" style="display: flex; flex-direction: column; gap: 12px">
        <div
          v-for="line in cartLines"
          :key="line.id"
          style="
            display: flex;
            gap: 16px;
            align-items: center;
            background: var(--card);
            border: 1px solid rgba(var(--line-rgb), 0.12);
            border-radius: 14px;
            padding: 14px;
          "
        >
          <input
            type="checkbox"
            :checked="state.selectedCartItemIds.includes(line.id)"
            @change="actions.toggleCartItemSelected(line.id)"
            style="flex: none; width: 18px; height: 18px; accent-color: var(--acc, #c6ff4a); cursor: pointer"
          />
          <div
            style="
              flex: none;
              width: 78px;
              height: 78px;
              border-radius: 11px;
              background: linear-gradient(140deg, var(--card2), var(--card));
              border: 1px solid rgba(var(--line-rgb), 0.14);
              display: flex;
              align-items: center;
              justify-content: center;
              overflow: hidden;
            "
          >
            <img v-if="line.imageUrl" :src="line.imageUrl" style="width: 100%; height: 100%; object-fit: cover" />
            <span v-else style="font-size: 10px; color: var(--muted)">SẢN PHẨM</span>
          </div>
          <div style="flex: 1; min-width: 0">
            <div style="font-size: 14.5px; font-weight: 600; margin: 3px 0 4px">
              {{ line.name }}
            </div>
            <div
              v-if="line.optionsText"
              style="font-size: 11.5px; color: var(--muted2); margin-bottom: 4px"
            >
              {{ line.optionsText }}
            </div>
            <div style="font-size: 13px; color: var(--muted)">
              {{ line.priceText }}
            </div>
          </div>
          <div
            style="
              display: flex;
              align-items: center;
              gap: 2px;
              background: var(--card2);
              border: 1px solid rgba(var(--line-rgb), 0.18);
              border-radius: 9px;
              padding: 2px;
            "
          >
            <button
              @click="actions.dec(line.id)"
              style="
                width: 30px;
                height: 30px;
                border: none;
                background: transparent;
                color: var(--muted2);
                font-size: 17px;
                cursor: pointer;
                border-radius: 7px;
              "
            >
              −
            </button>
            <Transition name="qty-pulse" mode="out-in">
            <span
              :key="line.qty"
              style="
                width: 30px;
                display: inline-block;
                text-align: center;
                font-family: 'Chakra Petch', sans-serif;
                font-weight: 600;
                font-size: 14px;
              "
              >{{ line.qty }}</span
            >
            </Transition>
            <button
              @click="actions.inc(line.id)"
              style="
                width: 30px;
                height: 30px;
                border: none;
                background: transparent;
                color: var(--muted2);
                font-size: 17px;
                cursor: pointer;
                border-radius: 7px;
              "
            >
              +
            </button>
          </div>
          <div
            style="
              width: 130px;
              text-align: right;
              font-family: 'Chakra Petch', sans-serif;
              font-weight: 700;
              font-size: 16px;
              color: var(--text);
            "
          >
            {{ line.lineText }}
          </div>
          <button
            @click="actions.removeLine(line.id)"
            title="Xóa"
            style="
              flex: none;
              width: 34px;
              height: 34px;
              border: none;
              background: transparent;
              color: var(--muted);
              font-size: 17px;
              cursor: pointer;
              border-radius: 8px;
            "
          >
            ✕
          </button>
        </div>
        </TransitionGroup>
      </div>
      <aside
        style="
          position: sticky;
          top: 130px;
          background: var(--card);
          border: 1px solid rgba(var(--line-rgb), 0.14);
          border-radius: 16px;
          padding: 22px;
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
          TÓM TẮT ĐƠN HÀNG
        </div>
        <div
          style="
            display: flex;
            justify-content: space-between;
            font-size: 13.5px;
            color: var(--muted2);
            margin-bottom: 11px;
          "
        >
          <span>Tạm tính ({{ selectedQtyCount }} món)</span
          ><span style="color: var(--text)">{{ subtotalText }}</span>
        </div>
        <div
          style="
            display: flex;
            justify-content: space-between;
            font-size: 13.5px;
            color: var(--muted2);
            margin-bottom: 11px;
          "
        >
          <span>Phí vận chuyển</span
          ><span style="color: var(--muted2)">Tính khi đặt hàng</span>
        </div>
        <div
          style="
            height: 1px;
            background: rgba(var(--line-rgb), 0.14);
            margin-bottom: 16px;
          "
        ></div>
        <div
          style="
            display: flex;
            justify-content: space-between;
            align-items: baseline;
            margin-bottom: 20px;
          "
        >
          <span style="font-weight: 600; font-size: 15px">Tạm tính</span
          ><span
            :style="{ color: accent }"
            style="
              font-family: 'Chakra Petch', sans-serif;
              font-weight: 700;
              font-size: 24px;
            "
            >{{ subtotalText }}</span
          >
        </div>
        <div
          style="
            display: flex;
            justify-content: flex-end;
            font-size: 12px;
            color: #d9b34a;
            font-weight: 600;
            margin-bottom: 16px;
          "
        >
          🪙 {{ tokenText }}
        </div>
        <button
          @click="actions.goCheckout"
          :disabled="!selectedCount"
          :style="{
            background: accent,
            opacity: selectedCount ? 1 : 0.5,
            boxShadow:
              '0 10px 26px color-mix(in srgb, ' + accent + ' 36%, transparent)',
          }"
          style="
            width: 100%;
            height: 52px;
            border: none;
            border-radius: 12px;
            color: var(--acc-ink);
            font-family: 'Be Vietnam Pro', sans-serif;
            font-weight: 700;
            font-size: 15px;
            cursor: pointer;
          "
        >
          Tiến hành đặt hàng
        </button>
        <button
          @click="actions.goHome"
          style="
            width: 100%;
            height: 46px;
            margin-top: 10px;
            border: 1px solid rgba(var(--line-rgb), 0.22);
            border-radius: 12px;
            background: transparent;
            color: var(--muted2);
            font-family: 'Be Vietnam Pro', sans-serif;
            font-weight: 600;
            font-size: 13.5px;
            cursor: pointer;
          "
        >
          Tiếp tục mua sắm
        </button>
        <div
          style="
            text-align: center;
            margin-top: 16px;
            font-size: 11.5px;
            color: var(--muted);
            letter-spacing: 1px;
          "
        >
          COD · CHUYỂN KHOẢN · VNPAY · VISA/MASTERCARD
        </div>
      </aside>
    </div>

    <div
      v-else
      style="
        text-align: center;
        padding: 70px 24px;
        background: var(--card);
        border: 1px solid rgba(var(--line-rgb), 0.12);
        border-radius: 16px;
      "
    >
      <div style="font-size: 40px; margin-bottom: 14px">🛒</div>
      <div style="font-size: 16px; color: var(--muted2); margin-bottom: 6px">
        Giỏ hàng đang trống
      </div>
      <div style="font-size: 13.5px; color: var(--muted); margin-bottom: 24px">
        Khám phá PC, laptop và gear đang giảm giá nhé.
      </div>
      <button
        @click="actions.goCatAll"
        :style="{ background: accent }"
        style="
          height: 48px;
          padding: 0 28px;
          border: none;
          border-radius: 12px;
          color: var(--acc-ink);
          font-family: 'Be Vietnam Pro', sans-serif;
          font-weight: 700;
          font-size: 14px;
          cursor: pointer;
        "
      >
        Bắt đầu mua sắm →
      </button>
    </div>
  </main>
</template>

<style scoped>

.cart-line-enter-active,
.cart-line-leave-active {
  transition: opacity 0.25s ease, transform 0.25s ease;
}
.cart-line-enter-from,
.cart-line-leave-to {
  opacity: 0;
  transform: translateX(-16px);
}
.cart-line-leave-active {
  position: absolute;
  width: 100%;
}
.cart-line-move {
  transition: transform 0.25s ease;
}
.qty-pulse-enter-active,
.qty-pulse-leave-active {
  transition: opacity 0.15s ease, transform 0.15s ease;
}
.qty-pulse-enter-from {
  opacity: 0;
  transform: scale(1.3) translateY(-4px);
}
.qty-pulse-leave-to {
  opacity: 0;
  transform: scale(0.7) translateY(4px);
}
</style>
