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

// Nhấn nhá gói giữa (Plus) như mẫu bảng giá quen thuộc — chỉ trang trí, không đổi logic.
const FEATURED = 'plus';

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

      <!-- ===== Giới thiệu + bảng 3 gói ===== -->
      <div class="sub-intro">
        <div class="sub-intro-tag">CNTT CARE</div>
        <h2 class="sub-intro-title">Gói hội viên dịch vụ</h2>
        <p class="sub-intro-sub">
          Trả phí một lần, dùng cả năm. Khác với hạng thành viên (tích xu tự nhiên), gói Care mang
          lại dịch vụ tận nơi, miễn phí giao hàng và ưu tiên hỗ trợ — chọn gói hợp với bạn.
        </p>
      </div>

      <div class="sub-grid">
        <div
          v-for="p in plans" :key="p.code"
          class="sub-card"
          :class="{ 'is-featured': p.code === FEATURED, 'is-current': p.code === activePlanCode }"
        >
          <div v-if="p.code === FEATURED" class="sub-ribbon">Phổ biến</div>

          <div class="sub-card-name">{{ p.name }}</div>
          <div class="sub-card-price">
            {{ money(p.price) }}
            <span class="sub-card-per">/ {{ p.durationMonths }} tháng</span>
          </div>

          <div class="sub-card-benefits">
            <div v-for="(line, i) in benefitLines(p)" :key="i" class="sub-benefit">
              <span class="sub-benefit-check">✓</span>
              <span>{{ line }}</span>
            </div>
          </div>

          <button
            v-if="p.code === activePlanCode"
            class="sub-btn sub-btn-current" disabled
          >Đang sử dụng</button>
          <button
            v-else
            class="sub-btn"
            :class="{ 'sub-btn-primary': p.code === FEATURED }"
            :style="p.code === FEATURED ? { background: accent, color: 'var(--acc-ink)' } : {}"
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

/* ===== Giới thiệu ===== */
.sub-intro-tag { font-family: 'Chakra Petch', sans-serif; font-size: 11px; letter-spacing: 2.5px; color: v-bind(accent); font-weight: 600; }
.sub-intro-title { font-size: 24px; font-weight: 800; color: var(--text); margin: 8px 0 6px; }
.sub-intro-sub { font-size: 13.5px; color: var(--muted2); line-height: 1.6; max-width: 640px; margin: 0; }

/* ===== Bảng 3 gói ===== */
.sub-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; align-items: stretch; }
.sub-card {
  position: relative;
  background: var(--card);
  border: 1px solid rgba(var(--line-rgb), 0.14);
  border-radius: 16px;
  padding: 24px 22px;
  display: flex;
  flex-direction: column;
  transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
}
.sub-card:hover { transform: translateY(-3px); box-shadow: 0 12px 30px rgba(0, 0, 0, 0.1); }
.sub-card.is-featured { border-color: color-mix(in srgb, v-bind(accent) 55%, transparent); box-shadow: 0 8px 30px color-mix(in srgb, v-bind(accent) 14%, transparent); }
.sub-card.is-current { border-color: var(--green, #22d39a); }
.sub-ribbon {
  position: absolute; top: -11px; left: 50%; transform: translateX(-50%);
  background: v-bind(accent); color: var(--acc-ink);
  font-size: 10.5px; font-weight: 800; letter-spacing: 0.5px;
  padding: 3px 12px; border-radius: 999px; white-space: nowrap;
}
.sub-card-name { font-size: 17px; font-weight: 800; color: var(--text); }
.sub-card-price { font-size: 24px; font-weight: 800; color: var(--text); margin: 8px 0 18px; }
.sub-card-per { font-size: 12.5px; font-weight: 500; color: var(--muted); }
.sub-card-benefits { display: flex; flex-direction: column; gap: 10px; flex: 1; margin-bottom: 20px; }
.sub-benefit { display: flex; gap: 9px; align-items: flex-start; font-size: 13px; color: var(--muted2); line-height: 1.45; }
.sub-benefit-check { flex: none; color: v-bind(accent); font-weight: 800; }

.sub-btn {
  height: 44px; border: 1px solid rgba(var(--line-rgb), 0.25); background: transparent;
  border-radius: 11px; color: var(--text); font-weight: 700; font-size: 13.5px; cursor: pointer;
  font-family: 'Be Vietnam Pro', sans-serif; transition: background 0.15s ease, opacity 0.15s ease;
}
.sub-btn:hover:not(:disabled) { background: rgba(var(--line-rgb), 0.08); }
.sub-btn-primary { border: none; }
.sub-btn-primary:hover:not(:disabled) { opacity: 0.9; }
.sub-btn-current { border-color: var(--green, #22d39a); color: var(--green, #22d39a); cursor: default; }
.sub-btn:disabled { cursor: default; }

.sub-foot { font-size: 12px; color: var(--muted); line-height: 1.6; }

@media (max-width: 860px) {
  .sub-grid { grid-template-columns: 1fr; }
}
</style>
