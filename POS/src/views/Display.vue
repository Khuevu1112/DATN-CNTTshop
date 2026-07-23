<template>
  <div class="display">
    <!-- Chờ -->
    <div v-if="d.trangThai === 'cho'" class="center">
      <div class="biglogo">P</div>
      <div class="shop">POS Shop</div>
      <div class="hello">Kính chào quý khách</div>
    </div>

    <!-- Đang bán -->
    <div v-else-if="d.trangThai === 'ban'" class="sale">
      <div class="sale-head">Đơn hàng của bạn</div>
      <div class="sale-list">
        <div v-for="(l, i) in d.dongHang" :key="i" class="line">
          <div class="name">{{ l.tenSanPham }} <span class="qty">×{{ l.soLuong }}</span></div>
          <div class="amt tnum">{{ fmt(l.thanhTien) }}</div>
        </div>
      </div>
      <div class="sale-total">
        <div class="lbl">Tổng cộng</div>
        <div class="val tnum">{{ fmt(d.tongTien) }}</div>
      </div>
    </div>

    <!-- Chờ thanh toán -->
    <div v-else-if="d.trangThai === 'cho-thanh-toan'" class="center">
      <div class="qr-lbl">Quét mã QR để thanh toán</div>
      <div class="qr" :style="{ backgroundImage: `url(${d.qr})` }"></div>
      <div class="qr-total tnum">{{ fmt(d.tongTien) }}</div>
    </div>

    <!-- Xong -->
    <div v-else class="center">
      <div class="thanks">Cảm ơn quý khách!</div>
      <div class="done-lbl">Tổng thanh toán</div>
      <div class="done-total tnum">{{ fmt(d.tongTien) }}</div>
      <div v-if="d.xuNhanDuoc > 0" class="xu">Bạn nhận được +{{ d.xuNhanDuoc }} Xu</div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { kenh } from '../lib/bus'
import { fmt } from '../lib/api'

const d = ref({ trangThai: 'cho', dongHang: [], tongTien: 0, xuNhanDuoc: 0, qr: '' })

function onMsg(ev) {
  const m = ev.data || {}
  if (m.loai === 'cap-nhat') d.value = m.disp
}

onMounted(() => {
  kenh.addEventListener('message', onMsg)
  kenh.postMessage({ loai: 'xin' }) // xin trạng thái hiện tại từ quầy
})
onUnmounted(() => kenh.removeEventListener('message', onMsg))
</script>

<style scoped>
.display { height: 100vh; background: #101114; color: #f2f3f5; display: flex; flex-direction: column; overflow: hidden; }
.center { flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 20px; }
.biglogo { width: 120px; height: 120px; border-radius: 28px; background: var(--acc); display: flex; align-items: center; justify-content: center; font-size: 64px; font-weight: 800; }
.shop { font-size: 34px; font-weight: 800; letter-spacing: 1px; }
.hello { font-size: 18px; color: var(--muted); }

.sale { flex: 1; display: flex; flex-direction: column; min-height: 0; }
.sale-head { padding: 26px 40px; border-bottom: 1px solid rgba(255,255,255,0.14); font-size: 22px; font-weight: 700; color: var(--muted); }
.sale-list { flex: 1; overflow: auto; padding: 14px 40px; }
.line { display: flex; align-items: center; justify-content: space-between; padding: 16px 0; border-bottom: 1px solid #171c28; }
.line .name { font-size: 26px; font-weight: 600; }
.line .qty { color: var(--muted); font-size: 22px; }
.line .amt { font-size: 26px; font-weight: 700; }
.sale-total { padding: 28px 40px; background: #17181c; display: flex; align-items: baseline; justify-content: space-between; }
.sale-total .lbl { font-size: 28px; font-weight: 700; color: var(--muted); }
.sale-total .val { font-size: 52px; font-weight: 800; color: var(--acc); }

.qr-lbl { font-size: 28px; font-weight: 700; color: var(--muted); }
.qr { width: 420px; height: 420px; background: var(--card) center/contain no-repeat; border-radius: 20px; }
.qr-total { font-size: 44px; font-weight: 800; color: var(--acc); }

.thanks { font-size: 52px; font-weight: 800; color: #2bd47e; }
.done-lbl { font-size: 26px; color: var(--muted); }
.done-total { font-size: 64px; font-weight: 800; }
.xu { font-size: 26px; color: var(--acc); font-weight: 700; }
</style>
