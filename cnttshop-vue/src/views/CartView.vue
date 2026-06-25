<script setup>
import { computed } from 'vue';
import { catMeta, fmt, productById, priceWith } from '../data/products.js';
import { state, actions, accent, cartCount } from '../store.js';

const cartLines = computed(() =>
  state.cart.map((c) => {
    const p = productById(c.id);
    const unit = priceWith(p, c.sel);
    const cfgText = (p.cfg || [])
      .map((g) => g.ch[(c.sel && c.sel[g.key]) || 0].l)
      .join(' · ');
    return {
      id: p.id,
      key: c.key,
      name: p.name,
      brand: p.brand,
      hue: p.hue,
      catEn: catMeta[p.cat].en,
      priceText: fmt(unit),
      cfgText,
      qty: c.qty,
      lineText: fmt(unit * c.qty),
    };
  }),
);

const subtotal = computed(() =>
  state.cart.reduce((a, c) => {
    const p = productById(c.id);
    return a + priceWith(p, c.sel) * c.qty;
  }, 0),
);

const subtotalText = computed(() => fmt(subtotal.value));
const orderCode = computed(
  () => '#CNTT' + (48210 + cartCount.value * 7 + state.cart.length * 13),
);
</script>

<template>
  <main style="max-width: 1320px; margin: 0 auto; padding: 24px 24px 70px">
    <!-- order placed -->
    <div
      v-if="state.placed"
      style="
        text-align: center;
        padding: 70px 24px;
        background: #0a2138;
        border: 1px solid rgba(120, 170, 230, 0.14);
        border-radius: 18px;
        margin-top: 20px;
      "
    >
      <div
        :style="{
          background: 'color-mix(in srgb, ' + accent + ' 18%, #0c2742)',
          color: accent,
        }"
        style="
          width: 74px;
          height: 74px;
          margin: 0 auto 22px;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 36px;
        "
      >
        ✓
      </div>
      <h1
        style="
          font-family: 'Be Vietnam Pro', sans-serif;
          font-weight: 700;
          font-size: 28px;
          margin: 0 0 10px;
        "
      >
        Đặt hàng thành công!
      </h1>
      <p style="color: #a9c0dc; font-size: 14.5px; margin: 0 0 6px">
        Mã đơn hàng của bạn:
        <span
          :style="{ color: accent }"
          style="font-family: 'Chakra Petch', sans-serif; font-weight: 700"
          >{{ orderCode }}</span
        >
      </p>
      <p style="color: #7e98b6; font-size: 13.5px; margin: 0 0 28px">
        CNTTshop sẽ gọi xác nhận trong ít phút. Cảm ơn bạn!
      </p>
      <button
        @click="actions.resetShop"
        :style="{ background: accent }"
        style="
          height: 50px;
          padding: 0 30px;
          border: none;
          border-radius: 12px;
          color: #04121f;
          font-family: 'Be Vietnam Pro', sans-serif;
          font-weight: 700;
          font-size: 14.5px;
          cursor: pointer;
        "
      >
        Tiếp tục mua sắm
      </button>
    </div>

    <!-- cart -->
    <div v-else>
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
            v-for="line in cartLines"
            :key="line.key"
            style="
              display: flex;
              gap: 16px;
              align-items: center;
              background: #0a2138;
              border: 1px solid rgba(120, 170, 230, 0.12);
              border-radius: 14px;
              padding: 14px;
            "
          >
            <div
              :style="{ '--ph': line.hue }"
              style="
                flex: none;
                width: 78px;
                height: 78px;
                border-radius: 11px;
                background: linear-gradient(
                  140deg,
                  hsl(var(--ph) 45% 17%),
                  hsl(var(--ph) 55% 9%)
                );
                border: 1px solid rgba(120, 170, 230, 0.14);
                display: flex;
                align-items: center;
                justify-content: center;
                font-family: 'Chakra Petch', sans-serif;
                font-size: 10px;
                letter-spacing: 1px;
                color: hsl(var(--ph) 70% 75% / 0.4);
              "
            >
              {{ line.catEn }}
            </div>
            <div style="flex: 1; min-width: 0">
              <div
                :style="{ color: accent }"
                style="
                  font-family: 'Chakra Petch', sans-serif;
                  font-size: 10px;
                  letter-spacing: 1.5px;
                  font-weight: 600;
                "
              >
                {{ line.brand }}
              </div>
              <div
                style="font-size: 14.5px; font-weight: 600; margin: 3px 0 4px"
              >
                {{ line.name }}
              </div>
              <div
                v-if="line.cfgText"
                style="
                  font-size: 11.5px;
                  color: #9fb6d2;
                  margin-bottom: 4px;
                  display: -webkit-box;
                  -webkit-line-clamp: 1;
                  -webkit-box-orient: vertical;
                  overflow: hidden;
                "
              >
                {{ line.cfgText }}
              </div>
              <div style="font-size: 13px; color: #7e98b6">
                {{ line.priceText }}
              </div>
            </div>
            <div
              style="
                display: flex;
                align-items: center;
                gap: 2px;
                background: #0c2742;
                border: 1px solid rgba(120, 170, 230, 0.18);
                border-radius: 9px;
                padding: 2px;
              "
            >
              <button
                @click="actions.dec(line.key)"
                style="
                  width: 30px;
                  height: 30px;
                  border: none;
                  background: transparent;
                  color: #cfdceb;
                  font-size: 17px;
                  cursor: pointer;
                  border-radius: 7px;
                "
              >
                −
              </button>
              <span
                style="
                  width: 30px;
                  text-align: center;
                  font-family: 'Chakra Petch', sans-serif;
                  font-weight: 600;
                  font-size: 14px;
                "
                >{{ line.qty }}</span
              >
              <button
                @click="actions.inc(line.key)"
                style="
                  width: 30px;
                  height: 30px;
                  border: none;
                  background: transparent;
                  color: #cfdceb;
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
                color: #fff;
              "
            >
              {{ line.lineText }}
            </div>
            <button
              @click="actions.removeLine(line.key)"
              title="Xóa"
              style="
                flex: none;
                width: 34px;
                height: 34px;
                border: none;
                background: transparent;
                color: #5f7a9c;
                font-size: 17px;
                cursor: pointer;
                border-radius: 8px;
              "
            >
              ✕
            </button>
          </div>
        </div>
        <aside
          style="
            position: sticky;
            top: 130px;
            background: #0a2138;
            border: 1px solid rgba(120, 170, 230, 0.14);
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
              color: #a9c0dc;
              margin-bottom: 11px;
            "
          >
            <span>Tạm tính ({{ cartCount }} món)</span
            ><span style="color: #e8f1fc">{{ subtotalText }}</span>
          </div>
          <div
            style="
              display: flex;
              justify-content: space-between;
              font-size: 13.5px;
              color: #a9c0dc;
              margin-bottom: 11px;
            "
          >
            <span>Phí vận chuyển</span
            ><span style="color: #2bd47e">Miễn phí</span>
          </div>
          <div
            style="
              display: flex;
              justify-content: space-between;
              font-size: 13.5px;
              color: #a9c0dc;
              margin-bottom: 16px;
            "
          >
            <span>Đã bao gồm VAT</span><span style="color: #e8f1fc">✓</span>
          </div>
          <div
            style="
              height: 1px;
              background: rgba(120, 170, 230, 0.14);
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
            <span style="font-weight: 600; font-size: 15px">Tổng cộng</span
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
          <button
            @click="actions.placeOrder"
            :style="{
              background: accent,
              boxShadow:
                '0 10px 26px color-mix(in srgb, ' +
                accent +
                ' 36%, transparent)',
            }"
            style="
              width: 100%;
              height: 52px;
              border: none;
              border-radius: 12px;
              color: #04121f;
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
              border: 1px solid rgba(120, 170, 230, 0.22);
              border-radius: 12px;
              background: transparent;
              color: #cfdceb;
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
              color: #5f7a9c;
              letter-spacing: 1px;
            "
          >
            VISA · MASTERCARD · MOMO · VNPAY · COD
          </div>
        </aside>
      </div>

      <div
        v-else
        style="
          text-align: center;
          padding: 70px 24px;
          background: #0a2138;
          border: 1px solid rgba(120, 170, 230, 0.12);
          border-radius: 16px;
        "
      >
        <div style="font-size: 40px; margin-bottom: 14px">🛒</div>
        <div style="font-size: 16px; color: #cfdceb; margin-bottom: 6px">
          Giỏ hàng đang trống
        </div>
        <div style="font-size: 13.5px; color: #7e98b6; margin-bottom: 24px">
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
            color: #04121f;
            font-family: 'Be Vietnam Pro', sans-serif;
            font-weight: 700;
            font-size: 14px;
            cursor: pointer;
          "
        >
          Bắt đầu mua sắm →
        </button>
      </div>
    </div>
  </main>
</template>
