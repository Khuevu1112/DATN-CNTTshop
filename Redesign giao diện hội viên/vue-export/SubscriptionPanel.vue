<script setup>
import { computed } from 'vue';

const period = '12 tháng';

const plans = computed(() => [
  {
    key: 'basic',
    name: 'CNTT Care Cơ bản',
    price: '149.000đ',
    tag: '',
    features: [
      'Miễn phí giao hàng nội thành Hải Phòng',
      '1 lượt miễn phí ship liên tỉnh / năm',
      'Ưu tiên hàng đợi bảo hành',
      '1 lần vệ sinh máy / năm',
    ],
  },
  {
    key: 'plus',
    name: 'CNTT Care Plus',
    price: '399.000đ',
    tag: 'Phổ biến',
    features: [
      'Miễn phí giao hàng nội thành Hải Phòng',
      'Miễn phí giao hoả tốc nội thành',
      '2 lượt miễn phí ship liên tỉnh / năm',
      'Ưu tiên hàng đợi bảo hành',
      '2 lần vệ sinh máy / năm (kèm tra keo tản nhiệt)',
      'Tặng voucher 50.000đ (đơn từ 2.000.000đ) khi kích hoạt',
    ],
  },
  {
    key: 'pro',
    name: 'CNTT Care Pro',
    price: '899.000đ',
    tag: 'Cao cấp',
    features: [
      'Miễn phí giao hàng nội thành Hải Phòng',
      'Miễn phí giao hoả tốc nội thành',
      '4 lượt miễn phí ship liên tỉnh / năm',
      'Ưu tiên hàng đợi bảo hành',
      '3 lần vệ sinh máy / năm (kèm tra keo tản nhiệt)',
      '2 lượt bảo hành tận nơi / năm',
      '1 lượt mượn máy khi đang bảo hành',
      'Vào Flash Sale sớm 15 phút',
      'Tư vấn build PC 1-1',
      'Tặng voucher 100.000đ (đơn từ 3.000.000đ) khi kích hoạt',
    ],
  },
]);

const emit = defineEmits(['buy']);
function buy(plan) {
  emit('buy', plan.key);
}
</script>

<template>
  <div class="sub-panel">
    <header class="sub-head">
      <div class="sub-eyebrow">CNTT CARE</div>
      <h2 class="sub-title">Gói hội viên dịch vụ</h2>
      <p class="sub-desc">
        Trả phí một lần, dùng cả năm. Khác với hạng thành viên (tích xu tự nhiên),
        gói Care mang lại dịch vụ tận nơi, miễn phí giao hàng và ưu tiên hỗ trợ — chọn gói hợp với bạn.
      </p>
    </header>

    <div class="sub-grid">
      <div
        v-for="plan in plans"
        :key="plan.key"
        class="plan"
        :class="`plan--${plan.key}`"
      >
        <div v-if="plan.tag" class="plan__tag">{{ plan.tag }}</div>
        <div class="plan__name">{{ plan.name }}</div>
        <div class="plan__price">
          <span class="plan__amount">{{ plan.price }}</span>
          <span class="plan__period">/ {{ period }}</span>
        </div>
        <ul class="plan__features">
          <li v-for="(f, i) in plan.features" :key="i">
            <span class="plan__check">✓</span><span>{{ f }}</span>
          </li>
        </ul>
        <button class="plan__btn" @click="buy(plan)">Mua gói</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.sub-panel {
  font-family: 'Be Vietnam Pro', system-ui, sans-serif;
  color: #1f2a24;
}
.sub-head { margin-bottom: 26px; }
.sub-eyebrow {
  font-family: 'Chakra Petch', sans-serif;
  font-size: 11px;
  letter-spacing: 2.5px;
  color: #4a8a3d;
  font-weight: 600;
  margin-bottom: 10px;
}
.sub-title {
  font-weight: 800;
  font-size: 26px;
  margin: 0 0 10px;
  color: #1f2a24;
}
.sub-desc {
  margin: 0;
  max-width: 660px;
  font-size: 14px;
  line-height: 1.6;
  color: #5c6b60;
}

.sub-grid {
  display: flex;
  gap: 22px;
  flex-wrap: wrap;
  align-items: stretch;
}

/* ---- base card ---- */
.plan {
  position: relative;
  display: flex;
  flex-direction: column;
  width: 300px;
  box-sizing: border-box;
  border-radius: 16px;
  padding: 30px 26px 26px;
  background: #fff;
  border: 1px solid rgba(20, 40, 20, 0.1);
}
.plan__tag {
  position: absolute;
  top: -13px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 11px;
  font-weight: 700;
  padding: 5px 15px;
  border-radius: 20px;
  white-space: nowrap;
}
.plan__name { font-weight: 700; font-size: 17px; margin-bottom: 12px; }
.plan__price { display: flex; align-items: baseline; gap: 6px; margin-bottom: 20px; }
.plan__amount { font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 27px; }
.plan__period { font-size: 13px; }
.plan__features {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 11px;
  flex: 1;
}
.plan__features li {
  display: flex;
  gap: 9px;
  align-items: flex-start;
  font-size: 13px;
  line-height: 1.5;
}
.plan__check { font-weight: 700; flex: none; }
.plan__btn {
  height: 46px;
  border-radius: 10px;
  font-weight: 700;
  font-size: 14px;
  cursor: pointer;
  margin-top: 22px;
  width: 100%;
  font-family: 'Be Vietnam Pro', sans-serif;
  transition: all 0.15s;
}

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
.plan--basic .plan__btn:hover { background: rgba(63, 146, 196, 0.1); }

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
.plan--plus .plan__btn:hover { background: #347a30; }

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
.plan--pro .plan__btn:hover { background-position: 100% 0; }

@keyframes goldShimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
</style>
