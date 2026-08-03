<script setup>
import { ref, computed, onMounted } from 'vue';
import { actions, accent } from '../store.js';
import { fetchInstallmentConfig } from '../api.js';
import { fmt } from '../data/products.js';

const config = ref(null);
const dangTai = ref(true);

const kyHan = computed(() => config.value?.kyHan || []);
const traTruocToiThieu = computed(() =>
  config.value?.tyLeTraTruocToiThieu != null ? Math.round(config.value.tyLeTraTruocToiThieu * 100) : 30,
);

// Bảng ví dụ: khoản trả hàng tháng cho một đơn 20 triệu, trả trước tối thiểu, theo từng kỳ hạn.
const VI_DU_GIA = 20000000;
const viDu = computed(() =>
  kyHan.value.map((k) => {
    const traTruoc = Math.round((VI_DU_GIA * traTruocToiThieu.value) / 100);
    const conLai = VI_DU_GIA - traTruoc;
    const laiThang = Number(k.laiSuat || 0) / 100 / 12;
    // Khoản trả hàng tháng theo dư nợ gốc + lãi phẳng trên gốc còn lại (mô phỏng, giống cách
    // báo tham khảo — số chốt do đối tác tài chính duyệt).
    const goc = conLai / k.soThang;
    const thang = Math.round(goc + conLai * laiThang);
    return { soThang: k.soThang, laiSuat: k.laiSuat, traTruoc, thang };
  }),
);

const QUY_TRINH = [
  { b: '1', t: 'Chọn sản phẩm & kỳ hạn', m: 'Ở trang sản phẩm, chọn "Mua trả góp" và kỳ hạn phù hợp. Khoản trả hàng tháng hiện ngay trước khi đăng nhập.' },
  { b: '2', t: 'Điền hồ sơ', m: 'Cung cấp CCCD và thông tin liên hệ. Với khoản lớn có thể cần thêm giấy tờ thu nhập theo yêu cầu của đối tác tài chính.' },
  { b: '3', t: 'Chờ duyệt', m: 'Hồ sơ được duyệt trong khoảng 30 phút giờ hành chính. Bạn nhận thông báo kết quả qua ứng dụng và điện thoại.' },
  { b: '4', t: 'Nhận máy & trả góp', m: 'Duyệt xong, thanh toán khoản trả trước và nhận máy. Các kỳ tiếp theo trả theo lịch đã ký.' },
];

const DIEU_KIEN = [
  'Công dân Việt Nam từ 20 đến 60 tuổi, có CCCD còn hiệu lực.',
  'Đơn hàng đạt giá trị tối thiểu áp dụng trả góp (từ 3 triệu đồng).',
  'Có số điện thoại chính chủ đang sử dụng để đối tác tài chính xác minh.',
  'Không có nợ xấu nhóm 3 trở lên tại thời điểm đăng ký.',
];
const HO_SO = [
  'CCCD (bắt buộc).',
  'Giấy phép lái xe hoặc thẻ tín dụng (giúp tăng tỷ lệ duyệt, không bắt buộc).',
  'Ảnh chụp hoá đơn điện/nước hoặc sao kê lương với khoản vay lớn (nếu được yêu cầu).',
];

onMounted(async () => {
  try {
    config.value = await fetchInstallmentConfig();
  } catch (e) {
    config.value = null;
  } finally {
    dangTai.value = false;
  }
});
</script>

<template>
  <main style="max-width: 1040px; margin: 0 auto; padding: 24px 24px 72px">
    <button class="sp-back" @click="actions.goHome()">← Quay lại trang chủ</button>

    <div style="margin-bottom: 30px">
      <div class="sp-eyebrow">CHÍNH SÁCH TRẢ GÓP</div>
      <h1 class="sp-h1">Trả góp <span :style="{ color: accent }">0%</span> lãi suất</h1>
      <p style="font-size: 14.5px; color: var(--muted2); max-width: 620px; line-height: 1.65; margin: 0">
        Sở hữu máy ngay, trả dần theo tháng. Duyệt nhanh trong 30 phút, thủ tục chỉ cần CCCD.
        Khoản trả hàng tháng luôn hiển thị minh bạch trước khi bạn đăng ký.
      </p>
    </div>

    <!-- Điểm nổi bật -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 14px; margin-bottom: 34px">
      <div v-for="h in [
          { i: '⚡', t: 'Duyệt trong 30 phút', m: 'Giờ hành chính, kết quả báo ngay.' },
          { i: '🪪', t: 'Chỉ cần CCCD', m: 'Không cần chứng minh thu nhập với đơn nhỏ.' },
          { i: '💸', t: 'Lãi suất 0%', m: 'Nhiều kỳ hạn 0% cho sản phẩm chọn lọc.' },
          { i: '📄', t: 'Minh bạch', m: 'Xem khoản trả hàng tháng trước khi ký.' },
        ]" :key="h.t" class="sp-card" style="padding: 20px">
        <div style="font-size: 26px; margin-bottom: 10px">{{ h.i }}</div>
        <div style="font-size: 14px; font-weight: 700; color: var(--text); margin-bottom: 5px">{{ h.t }}</div>
        <div style="font-size: 12.5px; color: var(--muted2); line-height: 1.55">{{ h.m }}</div>
      </div>
    </div>

    <!-- Bảng kỳ hạn + ví dụ -->
    <section style="margin-bottom: 34px">
      <h2 class="sp-h2">Kỳ hạn &amp; ví dụ khoản trả hàng tháng</h2>
      <p style="font-size: 12.8px; color: var(--muted); margin: 0 0 16px">
        Ví dụ cho đơn {{ fmt(VI_DU_GIA) }}, trả trước {{ traTruocToiThieu }}%. Số liệu tham khảo —
        khoản chốt do đối tác tài chính duyệt.
      </p>
      <div v-if="dangTai" class="sp-card sp-empty">Đang tải cấu hình trả góp…</div>
      <div v-else-if="!viDu.length" class="sp-card sp-empty">Hiện chưa có gói trả góp nào được cấu hình.</div>
      <div v-else class="sp-card" style="overflow: hidden">
        <div style="overflow-x: auto">
          <table class="ip-table">
            <thead>
              <tr>
                <th>Kỳ hạn</th>
                <th>Lãi suất</th>
                <th style="text-align: right">Trả trước</th>
                <th style="text-align: right">Trả mỗi tháng (ước tính)</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="v in viDu" :key="v.soThang">
                <td style="font-weight: 600; color: var(--text)">{{ v.soThang }} tháng</td>
                <td>
                  <span class="sp-pill" :style="{ color: Number(v.laiSuat) === 0 ? 'var(--green)' : accent }">
                    {{ Number(v.laiSuat) === 0 ? '0%' : v.laiSuat + '%/năm' }}
                  </span>
                </td>
                <td style="text-align: right; color: var(--muted2)">{{ fmt(v.traTruoc) }}</td>
                <td style="text-align: right; font-weight: 700; color: var(--text)">{{ fmt(v.thang) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </section>

    <!-- Quy trình đăng ký -->
    <section style="margin-bottom: 34px">
      <h2 class="sp-h2">Quy trình đăng ký trả góp</h2>
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 14px">
        <div v-for="q in QUY_TRINH" :key="q.b" class="sp-card" style="padding: 22px 20px">
          <div
            style="width: 32px; height: 32px; border-radius: 9px; display: flex; align-items: center; justify-content: center; font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 14px; margin-bottom: 13px"
            :style="{ background: accent, color: 'var(--acc-ink)' }"
          >{{ q.b }}</div>
          <div style="font-size: 14px; font-weight: 700; color: var(--text); margin-bottom: 7px">{{ q.t }}</div>
          <div style="font-size: 12.7px; color: var(--muted2); line-height: 1.6">{{ q.m }}</div>
        </div>
      </div>
    </section>

    <!-- Điều kiện + hồ sơ -->
    <section style="display: grid; grid-template-columns: 1fr 1fr; gap: 18px; margin-bottom: 34px" class="ip-two">
      <div class="sp-card" style="padding: 24px 26px">
        <h2 class="sp-h2">Điều kiện</h2>
        <ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 11px">
          <li v-for="(d, i) in DIEU_KIEN" :key="i" class="ip-li">{{ d }}</li>
        </ul>
      </div>
      <div class="sp-card" style="padding: 24px 26px">
        <h2 class="sp-h2">Hồ sơ cần chuẩn bị</h2>
        <ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 11px">
          <li v-for="(d, i) in HO_SO" :key="i" class="ip-li">{{ d }}</li>
        </ul>
      </div>
    </section>

    <!-- CTA -->
    <div style="border-radius: 18px; padding: 30px 34px; background: linear-gradient(135deg, rgba(var(--line-rgb), 0.1), transparent); border: 1px solid rgba(var(--line-rgb), 0.14); display: flex; align-items: center; justify-content: space-between; gap: 20px; flex-wrap: wrap">
      <div>
        <div style="font-size: 18px; font-weight: 800; color: var(--text); margin-bottom: 6px">Sẵn sàng mua trả góp?</div>
        <div style="font-size: 13px; color: var(--muted2)">Chọn sản phẩm và bấm "Mua trả góp" ngay tại trang sản phẩm.</div>
      </div>
      <div style="display: flex; gap: 10px; flex-wrap: wrap">
        <button class="sp-btn-ghost" @click="actions.goCatLap()">Xem Laptop</button>
        <button class="sp-btn-acc" @click="actions.goCatPC()">Xem PC →</button>
      </div>
    </div>
  </main>
</template>

<style scoped>
.ip-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.ip-table th {
  text-align: left;
  padding: 13px 16px;
  font-family: 'Chakra Petch', sans-serif;
  font-size: 11.3px;
  letter-spacing: 0.5px;
  color: var(--muted);
  font-weight: 600;
  background: var(--card2);
  border-bottom: 1px solid rgba(var(--line-rgb), 0.12);
  white-space: nowrap;
}
.ip-table td {
  padding: 13px 16px;
  border-bottom: 1px solid rgba(var(--line-rgb), 0.08);
}
.ip-table tbody tr:last-child td {
  border-bottom: none;
}
.ip-li {
  font-size: 13px;
  color: var(--muted2);
  line-height: 1.6;
  padding-left: 22px;
  position: relative;
}
.ip-li::before {
  content: '✓';
  position: absolute;
  left: 0;
  color: var(--green);
  font-weight: 700;
}
@media (max-width: 720px) {
  .ip-two { grid-template-columns: 1fr !important; }
}
</style>
