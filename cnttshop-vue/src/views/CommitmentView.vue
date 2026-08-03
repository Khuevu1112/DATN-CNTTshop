<script setup>
import { actions, accent } from '../store.js';

const CAM_KET = [
  { i: '🛡️', t: 'Hàng chính hãng 100%', m: 'Mọi sản phẩm đều nhập chính ngạch, có tem và phiếu bảo hành hãng. Phát hiện hàng giả, hoàn tiền 100% và đền bù theo quy định.' },
  { i: '💰', t: 'Giá minh bạch, không phí ẩn', m: 'Giá niêm yết đã gồm thuế. Phí giao hàng và trả góp hiển thị rõ ở bước thanh toán trước khi bạn xác nhận.' },
  { i: '🔧', t: 'Bảo hành & hậu mãi', m: 'Bảo hành chính hãng tới 36 tháng, hỗ trợ kỹ thuật sau bán miễn phí, có trung tâm dịch vụ nhiều tỉnh thành.' },
  { i: '🔄', t: 'Đổi trả 7 ngày', m: 'Đổi trả trong 7 ngày với hàng lỗi nhà sản xuất hoặc giao sai mẫu, còn đủ hộp và phụ kiện.' },
  { i: '🚚', t: 'Giao nhanh, lắp tận nơi', m: 'Nội thành Hải Phòng và Hà Nội giao nhanh, PC lắp ráp được cài đặt và test tại nhà miễn phí.' },
  { i: '🎯', t: 'Tư vấn đúng nhu cầu', m: 'Chuyên gia tư vấn cấu hình theo ngân sách, không ép mua, không bán kèm sản phẩm không cần thiết.' },
];

const CHINH_HANG = [
  'Nhập khẩu chính ngạch, đầy đủ hoá đơn VAT khi khách yêu cầu.',
  'Tem niêm phong và tem bảo hành hãng còn nguyên trên mọi sản phẩm.',
  'Số serial khớp giữa máy, phiếu bảo hành và hệ thống — tra cứu được công khai.',
  'Cam kết đền bù 100% nếu chứng minh được là hàng giả, hàng nhái.',
];
</script>

<template>
  <main style="max-width: 1040px; margin: 0 auto; padding: 24px 24px 72px">
    <button class="sp-back" @click="actions.goHome()">← Quay lại trang chủ</button>

    <div style="margin-bottom: 30px">
      <div class="sp-eyebrow">CAM KẾT CỦA CNTTSHOP</div>
      <h1 class="sp-h1">Hàng chính hãng <span :style="{ color: accent }">100%</span></h1>
      <p style="font-size: 14.5px; color: var(--muted2); max-width: 620px; line-height: 1.65; margin: 0">
        Sáu cam kết CNTTShop giữ với mọi khách hàng — từ nguồn gốc sản phẩm tới hậu mãi lâu dài.
      </p>
    </div>

    <!-- Lưới cam kết -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; margin-bottom: 36px">
      <div v-for="c in CAM_KET" :key="c.t" class="sp-card" style="padding: 24px 22px">
        <div style="font-size: 30px; margin-bottom: 12px">{{ c.i }}</div>
        <div style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 15.5px; color: var(--text); margin-bottom: 8px">{{ c.t }}</div>
        <div style="font-size: 12.8px; color: var(--muted2); line-height: 1.6">{{ c.m }}</div>
      </div>
    </div>

    <!-- Chi tiết chính hãng -->
    <section style="margin-bottom: 34px">
      <div class="sp-card" style="padding: 28px 30px; background: linear-gradient(135deg, #0a2c1e, #061a0e); border-color: rgba(0, 197, 126, 0.2)">
        <div style="font-family: 'Chakra Petch', sans-serif; font-size: 11px; letter-spacing: 2px; color: var(--green); font-weight: 600; margin-bottom: 16px">
          CAM KẾT HÀNG CHÍNH HÃNG
        </div>
        <ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 12px">
          <li v-for="(d, i) in CHINH_HANG" :key="i" style="font-size: 13.5px; color: rgba(255,255,255,0.82); line-height: 1.6; padding-left: 24px; position: relative">
            <span style="position: absolute; left: 0; color: var(--green); font-weight: 700">✓</span>{{ d }}
          </li>
        </ul>
      </div>
    </section>

    <!-- CTA sang các trang liên quan -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 14px">
      <button class="sp-card ct-link" @click="actions.goWarrantyInfo()">
        <span style="font-size: 22px">🛡️</span>
        <span>
          <b>Thông tin bảo hành</b>
          <small>Tra cứu thời hạn &amp; chính sách</small>
        </span>
        <span :style="{ color: accent }">→</span>
      </button>
      <button class="sp-card ct-link" @click="actions.goInstallmentPolicy()">
        <span style="font-size: 22px">💸</span>
        <span>
          <b>Chính sách trả góp 0%</b>
          <small>Quy trình &amp; điều kiện đăng ký</small>
        </span>
        <span :style="{ color: accent }">→</span>
      </button>
      <button class="sp-card ct-link" @click="actions.goSupport()">
        <span style="font-size: 22px">🎧</span>
        <span>
          <b>Trung tâm hỗ trợ</b>
          <small>Tư vấn, sửa chữa, bảo hành</small>
        </span>
        <span :style="{ color: accent }">→</span>
      </button>
    </div>
  </main>
</template>

<style scoped>
.ct-link {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 18px 20px;
  cursor: pointer;
  text-align: left;
  font-family: 'Plus Jakarta Sans', sans-serif;
  transition: border-color 0.16s, transform 0.16s;
}
.ct-link:hover {
  border-color: var(--acc, #c6ff4a);
  transform: translateY(-2px);
}
.ct-link span:nth-child(2) {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 3px;
}
.ct-link b {
  font-size: 13.8px;
  color: var(--text);
  font-weight: 700;
}
.ct-link small {
  font-size: 12px;
  color: var(--muted2);
}
</style>
