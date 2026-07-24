<script setup>
import { ref, computed, onMounted } from 'vue';
import { state, actions, accent } from '../store.js';
import { fetchOrderDetail } from '../api.js';
import OrderDetailCard from '../components/OrderDetailCard.vue';

const order = ref(null);
const loading = ref(true);

// kind điều khiển icon/animation trong vòng tròn: 'success' (dấu tick vẽ nét), 'failed' (dấu X
// vẽ nét), 'pending' (⏳ lắc nhẹ liên tục), 'plain' (emoji tĩnh, chỉ có hiệu ứng xuất hiện chung).
const PAYMENT_BANNER = {
  success: { kind: 'success', text: 'Thanh toán thành công!', color: 'var(--green)' },
  failed: { kind: 'failed', text: 'Thanh toán thất bại', color: 'var(--sale)' },
  'invalid-signature': { kind: 'plain', icon: '⚠', text: 'Không xác thực được giao dịch, vui lòng liên hệ hỗ trợ', color: 'var(--sale)' },
  'already-processed': { kind: 'plain', icon: 'ℹ', text: 'Giao dịch đã được xử lý trước đó', color: 'var(--amber)' },
  'gateway-not-configured': { kind: 'plain', icon: '⚠', text: 'Cổng thanh toán thẻ chưa sẵn sàng, vui lòng chọn phương thức khác hoặc thử lại sau', color: 'var(--sale)' },
};

const banner = computed(() => {
  if (state.returnPaymentStatus) {
    return PAYMENT_BANNER[state.returnPaymentStatus] || null;
  }
  // Không có query trả về từ cổng thanh toán (vừa đặt COD/chuyển khoản, hoặc bấm "Đơn hàng của
  // tôi" ngay sau khi đặt) -> suy banner theo trạng thái thanh toán thật của đơn vừa tải, đợi
  // tải xong mới hiện để tránh nhấp nháy sai rồi đúng.
  if (!order.value) return null;
  if (order.value.payment && order.value.payment.status !== 'paid' && order.value.payment.methodCode !== 'cod') {
    return { kind: 'pending', icon: '⏳', text: 'Đặt hàng thành công — vui lòng hoàn tất thanh toán trong 24 giờ', color: 'var(--amber)' };
  }
  return { kind: 'success', text: 'Đặt hàng thành công!', color: 'var(--green)' };
});

async function load() {
  if (!state.returnOrderId) return;
  loading.value = true;
  try {
    order.value = await fetchOrderDetail(state.returnOrderId);
  } finally {
    loading.value = false;
  }
}

onMounted(load);
</script>

<template>
  <main style="max-width: 760px; margin: 0 auto; padding: 24px 24px 64px">
    <div v-if="!state.returnOrderId" style="text-align: center; padding: 60px 24px; color: var(--muted)">
      Không có thông tin đơn hàng.
      <div style="margin-top: 16px">
        <button @click="actions.goHome" :style="{ background: accent }" style="height: 44px; padding: 0 24px; border: none; border-radius: 10px; color: var(--acc-ink); font-weight: 700; cursor: pointer">Về trang chủ</button>
      </div>
    </div>

    <template v-else>
      <div v-if="banner" style="text-align: center; padding: 32px 24px; margin-bottom: 20px">
        <div class="or-circle"
          :style="{ background: 'color-mix(in srgb, ' + banner.color + ' 18%, var(--card2))', color: banner.color, '--or-ring-color': 'color-mix(in srgb, ' + banner.color + ' 55%, transparent)' }"
        >
          <div class="or-ring"></div>
          <svg v-if="banner.kind === 'success'" width="34" height="34" viewBox="0 0 34 34" fill="none">
            <path class="or-draw" d="M8 18 L14.5 24.5 L26 10" stroke="var(--green)" stroke-width="3.4" stroke-linecap="round" stroke-linejoin="round" style="stroke-dasharray: 34; stroke-dashoffset: 34" />
          </svg>
          <svg v-else-if="banner.kind === 'failed'" width="30" height="30" viewBox="0 0 30 30" fill="none">
            <path class="or-draw" d="M7 7 L23 23 M23 7 L7 23" stroke="var(--sale)" stroke-width="3.4" stroke-linecap="round" style="stroke-dasharray: 46; stroke-dashoffset: 46" />
          </svg>
          <span v-else-if="banner.kind === 'pending'" class="or-pending" style="font-size: 30px">{{ banner.icon }}</span>
          <span v-else style="font-size: 30px">{{ banner.icon }}</span>
        </div>
        <h1 class="or-text" style="font-family: 'Plus Jakarta Sans', sans-serif; font-weight: 700; font-size: 24px; margin: 0; color: var(--text)">{{ banner.text }}</h1>
      </div>

      <div v-if="loading" style="color: var(--muted); padding: 40px; text-align: center">Đang tải...</div>
      <OrderDetailCard v-else-if="order" :order="order" @updated="load" />

      <div style="display: flex; gap: 10px; margin-top: 20px; justify-content: center">
        <button @click="actions.goOrders" style="height: 46px; padding: 0 22px; border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 11px; background: transparent; color: var(--muted2); cursor: pointer; font-size: 13.5px">Đơn hàng của tôi</button>
        <button @click="actions.goHome" :style="{ background: accent }" style="height: 46px; padding: 0 22px; border: none; border-radius: 11px; color: var(--acc-ink); font-weight: 700; cursor: pointer; font-size: 13.5px">Tiếp tục mua sắm</button>
      </div>
    </template>
  </main>
</template>

<style scoped>
.or-circle {
  width: 64px;
  height: 64px;
  margin: 0 auto 16px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  animation: or-circle-in 0.5s cubic-bezier(0.2, 1.4, 0.4, 1) both;
}
.or-ring {
  position: absolute;
  inset: 0;
  border-radius: 50%;
  animation: or-ring 0.9s ease-out 0.15s both;
}
.or-draw {
  animation: or-draw 0.5s ease 0.35s forwards;
}
.or-pending {
  display: inline-block;
  animation: or-pending-pulse 1.4s ease-in-out 0.5s infinite;
}
.or-text {
  animation: or-text-in 0.4s ease 0.55s both;
}

@keyframes or-circle-in {
  0%   { transform: scale(0.4); opacity: 0; }
  55%  { transform: scale(1.08); opacity: 1; }
  100% { transform: scale(1); opacity: 1; }
}
@keyframes or-ring {
  0%   { box-shadow: 0 0 0 0 var(--or-ring-color); opacity: 1; }
  100% { box-shadow: 0 0 0 22px transparent; opacity: 0; }
}
@keyframes or-draw {
  to { stroke-dashoffset: 0; }
}
@keyframes or-text-in {
  0% { opacity: 0; transform: translateY(10px); }
  100% { opacity: 1; transform: translateY(0); }
}
@keyframes or-pending-pulse {
  0%, 100% { transform: scale(1) rotate(-4deg); }
  50% { transform: scale(1.08) rotate(4deg); }
}
</style>
