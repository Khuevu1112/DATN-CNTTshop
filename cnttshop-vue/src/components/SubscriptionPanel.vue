<script setup>
import { ref, computed, onMounted } from 'vue';
import { state, actions, accent } from '../store.js';
import { fetchSubscriptionPlans, fetchMySubscription, buySubscription } from '../api.js';

// Gói hội viên trả phí "CNTT Care" — TÁCH RỜI hạng thành viên tích luỹ (MembershipProgress).
// Panel tự nạp dữ liệu khi mount: bảng 3 gói + trạng thái gói hiện tại của khách.
const plans = ref([]);
const mySub = ref(null);
const loading = ref(true);
const buying = ref('');

// Nhãn nổi trên đầu thẻ theo bản thiết kế — basic không có nhãn.
const PLAN_TAG = { plus: 'Phổ biến', pro: 'Cao cấp' };

async function load() {
  loading.value = true;
  try {
    const [p, m] = await Promise.all([
      fetchSubscriptionPlans(),
      state.user ? fetchMySubscription() : Promise.resolve({ active: false }),
    ]);
    plans.value = p;
    mySub.value = m;
  } catch (e) {
    // im lặng — panel chỉ là 1 tab, không chặn phần còn lại của trang tài khoản
  } finally {
    loading.value = false;
  }
}
onMounted(load);

const money = (n) => Number(n || 0).toLocaleString('vi-VN') + 'đ';
function fmtDate(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  return `${String(d.getDate()).padStart(2, '0')}/${String(d.getMonth() + 1).padStart(2, '0')}/${d.getFullYear()}`;
}

const activePlanCode = computed(() => (mySub.value?.active ? mySub.value.plan.code : null));

/** Ưu đãi của 1 gói -> danh sách dòng ngắn để hiển thị trong thẻ. */
function benefitLines(p) {
  const L = [];
  if (p.freeInnerShipping) L.push('Miễn phí giao hàng nội thành Hải Phòng');
  if (p.freeExpressInner) L.push('Miễn phí giao hoả tốc nội thành');
  if (p.interprovinceQuota > 0) L.push(p.interprovinceQuota + ' lượt miễn phí ship liên tỉnh / năm');
  if (p.warrantyPriority) L.push('Ưu tiên hàng đợi bảo hành');
  if (p.cleaningQuota > 0)
    L.push(p.cleaningQuota + ' lần vệ sinh máy / năm' + (p.thermalPaste ? ' (kèm tra keo tản nhiệt)' : ''));
  if (p.onsiteWarrantyQuota > 0) L.push(p.onsiteWarrantyQuota + ' lượt bảo hành tận nơi / năm');
  if (p.loanerQuota > 0) L.push(p.loanerQuota + ' lượt mượn máy khi đang bảo hành');
  if (p.flashSaleEarly) L.push('Vào Flash Sale sớm 15 phút');
  if (p.pcBuildConsult) L.push('Tư vấn build PC 1-1');
  if (p.activationVoucherAmount)
    L.push('Tặng voucher ' + money(p.activationVoucherAmount) +
      (p.activationVoucherMin ? ' (đơn từ ' + money(p.activationVoucherMin) + ')' : '') + ' khi kích hoạt');
  return L;
}

async function onBuy(p) {
  if (!state.user) {
    actions.openLogin();
    return;
  }
  buying.value = p.code;
  try {
    const res = await buySubscription(p.code, 'vnpay');
    if (res && res.redirectUrl) {
      window.location.href = res.redirectUrl; // chuyển hướng toàn trang sang VNPay
    } else {
      actions.showToast('Không tạo được giao dịch, vui lòng thử lại');
      buying.value = '';
    }
  } catch (e) {
    actions.showToast(e?.message && !e.message.startsWith('HTTP') ? e.message : 'Mua gói thất bại, vui lòng thử lại');
    buying.value = '';
  }
}
</script>

<template>
  <div class="sub-wrap">
    <div v-if="loading" class="sub-loading">Đang tải gói hội viên...</div>

    <template v-else>
      <!-- ===== Trạng thái gói hiện tại ===== -->
      <div v-if="mySub && mySub.active" class="sub-active">
        <div class="sub-active-head">
          <div>
            <div class="sub-active-tag">GÓI HỘI VIÊN ĐANG DÙNG</div>
            <div class="sub-active-name">{{ mySub.plan.name }}</div>
          </div>
          <div class="sub-active-exp">
            <div class="sub-active-exp-label">Hiệu lực tới</div>
            <div class="sub-active-exp-date">{{ fmtDate(mySub.expiresAt) }}</div>
          </div>
        </div>

        <div v-if="mySub.quotas && mySub.quotas.length" class="sub-quotas">
          <div v-for="q in mySub.quotas" :key="q.key" class="sub-quota">
            <div class="sub-quota-top">
              <span>{{ q.label }}</span>
              <span class="sub-quota-num">{{ q.conLai }}/{{ q.tong }}</span>
            </div>
            <div class="sub-quota-track">
              <div class="sub-quota-fill" :style="{ width: (q.tong ? (q.conLai / q.tong) * 100 : 0) + '%', background: accent }"></div>
            </div>
          </div>
        </div>
        <div v-else class="sub-active-note">Gói của bạn gồm các quyền lợi không giới hạn — tận hưởng nhé!</div>
      </div>

      <!-- ===== Giới thiệu ===== -->
      <header class="sub-head">
        <div class="sub-eyebrow">CNTT CARE</div>
        <h2 class="sub-title">Gói hội viên dịch vụ</h2>
        <p class="sub-desc">
          Trả phí một lần, dùng cả năm. Khác với hạng thành viên (tích xu tự nhiên), gói Care mang
          lại dịch vụ tận nơi, miễn phí giao hàng và ưu tiên hỗ trợ — chọn gói hợp với bạn.
        </p>
      </header>

      <!-- ===== Bảng 3 gói — mỗi gói một màu riêng ===== -->
      <div class="sub-grid">
        <div
          v-for="p in plans" :key="p.code"
          class="plan"
          :class="[`plan--${p.code}`, { 'is-current': p.code === activePlanCode }]"
        >
          <div v-if="PLAN_TAG[p.code]" class="plan__tag">{{ PLAN_TAG[p.code] }}</div>

          <div class="plan__name">{{ p.name }}</div>
          <div class="plan__price">
            <span class="plan__amount">{{ money(p.price) }}</span>
            <span class="plan__period">/ {{ p.durationMonths }} tháng</span>
          </div>

          <ul class="plan__features">
            <li v-for="(f, i) in benefitLines(p)" :key="i">
              <span class="plan__check">✓</span><span>{{ f }}</span>
            </li>
          </ul>

          <button
            v-if="p.code === activePlanCode"
            class="plan__btn plan__btn--current" disabled
          >Đang sử dụng</button>
          <button
            v-else
            class="plan__btn"
            :disabled="buying === p.code"
            @click="onBuy(p)"
          >
            {{ buying === p.code ? 'Đang chuyển...' : (activePlanCode ? 'Chuyển / gia hạn' : 'Mua gói') }}
          </button>
        </div>
      </div>

      <div class="sub-foot">
        Thanh toán qua VNPay. Gói kích hoạt ngay sau khi thanh toán thành công và có hiệu lực trong
        suốt thời hạn — không tự động gia hạn.
      </div>
    </template>
  </div>
</template>

<style scoped>
.sub-wrap { display: flex; flex-direction: column; gap: 22px; }
.sub-loading { background: var(--card); border: 1px solid rgba(var(--line-rgb), 0.14); border-radius: 14px; padding: 60px; text-align: center; color: var(--muted); }

/* ===== Gói đang dùng ===== */
.sub-active {
  background: linear-gradient(135deg, color-mix(in srgb, v-bind(accent) 12%, var(--card)), var(--card) 65%);
  border: 1px solid color-mix(in srgb, v-bind(accent) 32%, rgba(var(--line-rgb), 0.14));
  border-radius: 16px;
  padding: 22px 24px;
}
.sub-active-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 16px; flex-wrap: wrap; }
.sub-active-tag { font-family: 'Chakra Petch', sans-serif; font-size: 10.5px; letter-spacing: 2px; color: v-bind(accent); font-weight: 700; }
.sub-active-name { font-size: 22px; font-weight: 800; color: var(--text); margin-top: 4px; }
.sub-active-exp { text-align: right; }
.sub-active-exp-label { font-size: 11px; color: var(--muted); }
.sub-active-exp-date { font-size: 15px; font-weight: 700; color: var(--text); margin-top: 2px; }
.sub-active-note { font-size: 12.5px; color: var(--muted2); margin-top: 14px; }

.sub-quotas { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 14px; margin-top: 18px; }
.sub-quota-top { display: flex; justify-content: space-between; font-size: 12px; color: var(--muted2); margin-bottom: 6px; }
.sub-quota-num { font-weight: 700; color: var(--text); }
.sub-quota-track { height: 7px; background: var(--card2); border-radius: 999px; overflow: hidden; }
.sub-quota-fill { height: 100%; border-radius: 999px; transition: width 0.5s ease; }

/* ===== Giới thiệu =====
   Giữ biến theme cho phần chữ ngoài thẻ: bản thiết kế hardcode #1f2a24 / #5c6b60 (chỉ hợp light
   mode), đặt lên nền tối của dark mode sẽ không đọc được. Ở light mode hai bên nhìn như nhau. */
.sub-head { margin-bottom: 4px; }
.sub-eyebrow {
  font-family: 'Chakra Petch', sans-serif;
  font-size: 11px;
  letter-spacing: 2.5px;
  color: v-bind(accent);
  font-weight: 600;
  margin-bottom: 10px;
}
.sub-title { font-weight: 800; font-size: 26px; margin: 0 0 10px; color: var(--text); }
.sub-desc { margin: 0; max-width: 660px; font-size: 14px; line-height: 1.6; color: var(--muted2); }

/* ===== Lưới 3 gói — GIỮ NGUYÊN kích cỡ hiện tại (3 cột đều, gap 16px), không dùng
   width: 300px + gap 22px của bản thiết kế. ===== */
.sub-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  align-items: stretch;
}

/* ---- base card (kích cỡ giữ như cũ: padding 24px 22px, radius 16px) ---- */
.plan {
  position: relative;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  border-radius: 16px;
  padding: 24px 22px;
  background: #fff;
  border: 1px solid rgba(20, 40, 20, 0.1);
}
.plan__tag {
  position: absolute;
  top: -11px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 10.5px;
  font-weight: 700;
  padding: 3px 12px;
  border-radius: 999px;
  white-space: nowrap;
}
.plan__name { font-weight: 800; font-size: 17px; }
.plan__price { display: flex; align-items: baseline; gap: 6px; margin: 8px 0 18px; }
.plan__amount { font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 24px; }
.plan__period { font-size: 12.5px; font-weight: 500; }
.plan__features {
  list-style: none;
  margin: 0 0 20px;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 10px;
  flex: 1;
}
.plan__features li {
  display: flex;
  gap: 9px;
  align-items: flex-start;
  font-size: 13px;
  line-height: 1.45;
}
.plan__check { font-weight: 800; flex: none; }
.plan__btn {
  height: 44px;
  border-radius: 11px;
  font-weight: 700;
  font-size: 13.5px;
  cursor: pointer;
  width: 100%;
  font-family: 'Plus Jakarta Sans', sans-serif;
  transition: all 0.15s;
}
.plan__btn:disabled { cursor: default; }
.plan__btn--current { opacity: 0.65; }

/* ---- basic: xanh biển nhạt ---- */
.plan--basic {
  background: #eef6fb;
  border: 2px solid #7cb8dd;
}
.plan--basic .plan__name { color: #1f3a4a; }
.plan--basic .plan__amount { color: #2f77a8; }
.plan--basic .plan__period { color: #7196ab; }
.plan--basic .plan__features li { color: #3a4e59; }
.plan--basic .plan__check { color: #3f92c4; }
.plan--basic .plan__btn {
  background: transparent;
  color: #2f77a8;
  border: 1.8px solid #7cb8dd;
}
.plan--basic .plan__btn:hover:not(:disabled) { background: rgba(63, 146, 196, 0.1); }

/* ---- plus: xanh lá thương hiệu ---- */
.plan--plus {
  background: #f1f8ee;
  border: 2.5px solid #3f8a3a;
  box-shadow: 0 22px 46px rgba(63, 138, 58, 0.18);
}
.plan--plus .plan__tag { background: #3f8a3a; color: #fff; }
.plan--plus .plan__name { color: #1f2a24; }
.plan--plus .plan__amount { color: #2f7a2c; }
.plan--plus .plan__period { color: #6b8a63; }
.plan--plus .plan__features li { color: #3a4a37; }
.plan--plus .plan__check { color: #3f8a3a; }
.plan--plus .plan__btn { background: #3f8a3a; color: #fff; border: none; }
.plan--plus .plan__btn:hover:not(:disabled) { background: #347a30; }

/* ---- pro: nền tối + ánh kim ---- */
.plan--pro {
  background: linear-gradient(165deg, #26332b, #161f1a);
  border: 2px solid rgba(230, 196, 119, 0.55);
  box-shadow: 0 22px 50px rgba(0, 0, 0, 0.28);
}
.plan--pro .plan__tag {
  background: linear-gradient(100deg, #d9ab52, #f7e3a1, #d9ab52);
  color: #2b2410;
}
.plan--pro .plan__name { color: #f2f5f0; }
.plan--pro .plan__amount {
  background: linear-gradient(100deg, #a9822f 0%, #e6c477 22%, #fff6dc 42%, #e6c477 60%, #a9822f 82%, #e6c477 100%);
  background-size: 200% 100%;
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  color: transparent;
  animation: goldShimmer 3.2s linear infinite;
}
.plan--pro .plan__period { color: rgba(230, 240, 225, 0.5); }
.plan--pro .plan__features li { color: rgba(233, 240, 230, 0.82); }
.plan--pro .plan__check { color: #e6c477; }
.plan--pro .plan__btn {
  background: linear-gradient(100deg, #d9ab52 0%, #f7e3a1 28%, #e6c477 52%, #f7e3a1 74%, #d9ab52 100%);
  background-size: 220% 100%;
  color: #2b2410;
  border: none;
  box-shadow: 0 6px 18px rgba(214, 171, 82, 0.4);
}
.plan--pro .plan__btn:hover:not(:disabled) { background-position: 100% 0; }

@keyframes goldShimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

.sub-foot { font-size: 12px; color: var(--muted); line-height: 1.6; }

/* Giữ nguyên điểm gãy hiện tại: dưới 860px dồn về 1 cột. */
@media (max-width: 860px) {
  .sub-grid { grid-template-columns: 1fr; }
}

/* Ánh kim của gói Pro chạy vô hạn — tắt theo cài đặt giảm chuyển động của hệ điều hành, đồng bộ
   với MembershipProgress. Không đổi màu, chỉ dừng animation. */
@media (prefers-reduced-motion: reduce) {
  .plan--pro .plan__amount { animation: none; }
  .sub-quota-fill, .plan__btn { transition: none; }
}
</style>
