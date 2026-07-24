<script setup>
import { ref, computed } from 'vue';
import { fmt } from '../data/products.js';
import { actions } from '../store.js';
import { uploadPaymentProof, cancelOrder, resolveImageUrl } from '../api.js';

const props = defineProps({ order: { type: Object, required: true } });
const emit = defineEmits(['updated']);

const uploading = ref(false);
const cancelling = ref(false);
const fileInput = ref(null);
const showCancelConfirm = ref(false);
const cancelReason = ref('');

// Đơn qua cổng redirect (Stripe/VNPay) bị bỏ dở giữa chừng (đóng tab / hủy trên trang thanh
// toán) vẫn ở trạng thái "pending" và có thể mở lại đúng phiên qua endpoint tương ứng (xem
// StripeController.pay / VNPayController.pay).
const gatewayPayUrl = computed(() => {
  const code = props.order.payment?.methodCode;
  const path = code === 'vnpay' ? '/payment/vnpay/pay' : '/payment/stripe/pay';
  return `http://localhost:8080${path}?paymentId=${props.order.payment?.id}`;
});

const STATUS_LABEL = {
  pending: 'Chờ xác nhận', confirmed: 'Đã xác nhận', processing: 'Đang xử lý',
  shipped: 'Đang giao', delivered: 'Đã giao', cancelled: 'Đã hủy', refunded: 'Đã hoàn tiền',
};
const PAYMENT_STATUS_LABEL = {
  pending: 'Chưa thanh toán', paid: 'Đã thanh toán', failed: 'Thất bại',
  waiting_verify: 'Chờ đối soát', refunded: 'Đã hoàn tiền',
};

// Tên SỰ KIỆN đã xảy ra (thì quá khứ) cho log lịch sử — khác STATUS_LABEL (tên trạng thái hiện
// tại), VD "pending" ở đây luôn là dòng log đầu tiên nên hiển thị "Đặt hàng" thay vì "Chờ xác nhận".
const HISTORY_EVENT_LABELS = {
  pending: 'Đặt hàng', paid: 'Đã thanh toán', confirmed: 'Đã xác nhận',
  processing: 'Đang xử lý', shipped: 'Bắt đầu giao hàng', delivered: 'Giao hàng thành công',
  cancelled: 'Đã huỷ đơn', refunded: 'Đã hoàn tiền',
};
function fmtLogTime(iso) {
  const d = new Date(iso);
  const p = (n) => String(n).padStart(2, '0');
  return `${p(d.getHours())}:${p(d.getMinutes())} - ${p(d.getDate())}/${p(d.getMonth() + 1)}/${d.getFullYear()}`;
}
const historyEntries = computed(() =>
  (props.order.statusHistory || []).map((h) => ({
    label: HISTORY_EVENT_LABELS[h.status] || h.status,
    note: h.note,
    at: fmtLogTime(h.changedAt),
  })),
);

async function onUploadProof(e) {
  const file = e.target.files[0];
  if (!file) return;
  uploading.value = true;
  try {
    await uploadPaymentProof(props.order.payment.id, file);
    actions.showToast('Đã nộp biên lai, vui lòng chờ admin đối soát');
    emit('updated');
  } catch (err) {
    actions.showToast(err?.message || 'Lỗi khi tải ảnh');
  } finally {
    uploading.value = false;
  }
}

function onCancel() {
  cancelReason.value = '';
  showCancelConfirm.value = true;
}

async function confirmCancel() {
  cancelling.value = true;
  try {
    await cancelOrder(props.order.id, cancelReason.value.trim());
    actions.showToast('Đã hủy đơn hàng');
    showCancelConfirm.value = false;
    emit('updated');
  } catch (err) {
    actions.showToast(err?.message || 'Không thể hủy đơn');
  } finally {
    cancelling.value = false;
  }
}
</script>

<template>
  <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 20px">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px">
      <div style="font-size: 14.5px; font-weight: 700; color: var(--text)">{{ order.orderCode }}</div>
      <span style="font-size: 11px; padding: 4px 10px; border-radius: 20px; background: color-mix(in srgb, var(--acc, #c6ff4a) 12%, transparent); color: var(--acc,#c6ff4a); font-weight: 600">
        {{ STATUS_LABEL[order.status] || order.status }}
      </span>
    </div>

    <div v-if="historyEntries.length" style="margin-bottom: 14px">
      <div
        v-for="(h, hi) in historyEntries"
        :key="hi"
        style="display: flex; gap: 10px"
      >
        <div style="display: flex; flex-direction: column; align-items: center; flex: none">
          <span style="width: 8px; height: 8px; border-radius: 50%; background: var(--acc, #c6ff4a); flex: none"></span>
          <span v-if="hi < historyEntries.length - 1" style="width: 1px; flex: 1; min-height: 18px; background: rgba(var(--line-rgb),0.16)"></span>
        </div>
        <div :style="{ paddingBottom: hi < historyEntries.length - 1 ? '14px' : '0' }">
          <div style="font-size: 12.5px; font-weight: 600; color: var(--text)">{{ h.label }}</div>
          <div style="font-size: 11px; color: var(--muted); margin-top: 2px">{{ h.at }}</div>
        </div>
      </div>
    </div>

    <div v-for="it in order.items" :key="it.id" style="display: flex; align-items: center; gap: 12px; padding: 9px 0">
      <div style="flex: none; width: 56px; height: 56px; border-radius: 10px; background: linear-gradient(140deg, var(--card2), var(--card)); border: 1px solid rgba(var(--line-rgb),0.14); display: flex; align-items: center; justify-content: center; overflow: hidden">
        <img v-if="it.imageUrl" :src="resolveImageUrl(it.imageUrl)" :alt="it.productName" style="width: 100%; height: 100%; object-fit: cover" />
        <i v-else class="bi bi-box-seam" style="color: var(--muted); font-size: 20px"></i>
      </div>
      <div style="flex: 1; min-width: 0">
        <div style="font-size: 14.5px; font-weight: 600; color: var(--text); line-height: 1.35">{{ it.productName }}</div>
        <div style="font-size: 12.5px; color: var(--muted); margin-top: 4px">Số lượng: <strong style="color: var(--muted2); font-size: 13.5px">{{ it.quantity }}</strong></div>
      </div>
      <div style="flex: none; text-align: right; font-size: 14px; font-weight: 700; color: var(--text)">{{ fmt(it.lineTotal) }}</div>
    </div>

    <div style="height: 1px; background: rgba(var(--line-rgb),0.14); margin: 12px 0"></div>

    <div style="font-size: 12.5px; color: var(--muted2); margin-bottom: 4px">
      Giao tới: <strong style="color: var(--muted2)">{{ order.address.tenNguoiNhan }}</strong> — {{ order.address.soDienThoai }}
    </div>
    <div style="font-size: 12.5px; color: var(--muted2); margin-bottom: 12px">{{ order.address.diaChiDayDu }}</div>

    <div style="display: flex; justify-content: space-between; font-size: 13px; color: var(--muted2); margin-bottom: 6px">
      <span>Tổng cộng</span><span style="color: var(--text); font-weight: 700">{{ fmt(order.totalAmount) }}</span>
    </div>

    <div v-if="order.payment" style="margin-top: 12px; padding: 12px; background: var(--card2); border-radius: 10px">
      <div style="font-size: 12.5px; color: var(--muted2)">
        Thanh toán: <strong>{{ order.payment.methodName }}</strong> —
        <span :style="{ color: order.payment.status === 'paid' ? 'var(--green)' : 'var(--amber)' }">
          {{ PAYMENT_STATUS_LABEL[order.payment.status] || order.payment.status }}
        </span>
      </div>

      <div v-if="order.payment.methodCode === 'banking' && order.payment.status === 'pending'" style="margin-top: 10px">
        <div style="font-size: 12px; color: var(--muted2); margin-bottom: 8px">
          Chuyển khoản tới: <strong style="color: var(--text)">Vietcombank — 0123456789 — CNTTSHOP</strong>, nội dung "{{ order.orderCode }}", sau đó nộp ảnh biên lai bên dưới.
          Đơn được giữ trong vòng <strong style="color: var(--amber)">24 giờ</strong> kể từ khi đặt hàng.
        </div>
        <input ref="fileInput" type="file" accept="image/*" @change="onUploadProof" :disabled="uploading" style="font-size: 12px; color: var(--muted2)" />
      </div>
      <div v-else-if="order.payment.methodCode === 'banking' && order.payment.proofImage" style="margin-top: 10px; font-size: 12px; color: var(--muted)">
        Đã nộp biên lai, đang chờ admin xác nhận.
      </div>

      <div v-else-if="['stripe_card', 'vnpay'].includes(order.payment.methodCode) && order.payment.status === 'pending'" style="margin-top: 10px">
        <div style="font-size: 12px; color: var(--muted2); margin-bottom: 8px">
          Đơn hàng chưa hoàn tất thanh toán. Đơn được giữ trong vòng <strong style="color: var(--amber)">24 giờ</strong> kể từ khi đặt hàng, sau đó sẽ tự động bị hủy.
        </div>
        <a :href="gatewayPayUrl"
          style="display: inline-block; height: 36px; line-height: 36px; padding: 0 16px; border-radius: 9px; background: var(--acc,#c6ff4a); color: var(--acc-ink); font-weight: 700; font-size: 12.5px; text-decoration: none">
          Hoàn tất thanh toán →
        </a>
      </div>
    </div>

    <button v-if="['pending','confirmed'].includes(order.status) && !(order.payment && order.payment.status === 'paid')"
      @click="onCancel" :disabled="cancelling"
      style="margin-top: 14px; height: 38px; padding: 0 16px; border: 1px solid rgba(var(--sale-rgb),0.3); border-radius: 9px; background: transparent; color: var(--sale); cursor: pointer; font-size: 12.5px">
      {{ cancelling ? 'Đang hủy...' : 'Hủy đơn hàng' }}
    </button>

    <div v-if="showCancelConfirm" @click="showCancelConfirm = false" style="position: fixed; inset: 0; background: rgba(0,0,0,0.6); display: flex; align-items: center; justify-content: center; z-index: 200; padding: 20px">
      <div @click.stop style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.18); border-radius: 16px; padding: 26px; max-width: 380px; width: 100%">
        <div style="font-size: 15px; font-weight: 700; color: var(--text); margin-bottom: 6px; text-align: center">Hủy đơn hàng này?</div>
        <div style="font-size: 12.5px; color: var(--muted2); margin-bottom: 16px; text-align: center">
          Đơn hàng <strong style="color: var(--text)">{{ order.orderCode }}</strong> sẽ bị hủy và không thể khôi phục.
        </div>
        <label style="display: block; font-size: 12px; color: var(--muted2); margin-bottom: 6px">Lý do hủy (không bắt buộc)</label>
        <textarea
          v-model="cancelReason"
          rows="3"
          placeholder="VD: Đặt nhầm, muốn đổi cấu hình khác..."
          style="width: 100%; padding: 10px 12px; border-radius: 9px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.2); color: var(--text); font-size: 13px; font-family: 'Plus Jakarta Sans', sans-serif; resize: vertical; margin-bottom: 18px"
        ></textarea>
        <div style="display: flex; gap: 10px">
          <button
            @click="showCancelConfirm = false"
            style="flex: 1; height: 42px; border: 1px solid rgba(var(--line-rgb),0.22); background: transparent; border-radius: 10px; color: var(--muted2); font-size: 13px; cursor: pointer"
          >
            Để sau
          </button>
          <button
            @click="confirmCancel" :disabled="cancelling"
            :style="{ opacity: cancelling ? 0.7 : 1 }"
            style="flex: 1; height: 42px; border: none; background: var(--sale); border-radius: 10px; color: #fff; font-weight: 700; font-size: 13px; cursor: pointer"
          >
            {{ cancelling ? 'Đang hủy...' : 'Xác nhận hủy' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
