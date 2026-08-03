<script setup>
import { ref, onMounted } from 'vue';
import { state, actions, accent } from '../store.js';
import { fetchWarrantyPolicies, lookupWarrantyBySerial } from '../api.js';
import { ngayVN } from '../data/supportMeta.js';

const chinhSach = ref([]);
const dangTai = ref(true);

const serial = ref('');
const dangTra = ref(false);
const ketQua = ref(null);
const loi = ref('');

async function traCuu() {
  loi.value = '';
  ketQua.value = null;
  const s = serial.value.trim();
  if (!s) {
    loi.value = 'Nhập mã bảo hành (BHCNTT****) hoặc số serial trên tem máy.';
    return;
  }
  dangTra.value = true;
  try {
    ketQua.value = await lookupWarrantyBySerial(s);
  } catch (e) {
    loi.value = e?.message || 'Không tra cứu được, vui lòng thử lại.';
  } finally {
    dangTra.value = false;
  }
}

const mauTrangThai = (tt) =>
  tt === 'active' ? 'var(--green)' : tt === 'void' ? 'var(--sale)' : 'var(--muted2)';

const nhanTrangThai = (tt) =>
  tt === 'active' ? 'Còn bảo hành' : tt === 'void' ? 'Đã vô hiệu' : 'Hết bảo hành';

// Nội dung chính sách. Giữ ở FE vì đây là văn bản pháp lý cố định, không phải dữ liệu vận hành —
// đưa vào CSDL chỉ tạo thêm một màn hình admin phải bảo trì mà gần như không bao giờ dùng tới.
// Riêng BẢNG THỜI HẠN thì nằm trong CSDL (WARRANTY_POLICY) vì con số đó có đổi theo từng đợt hàng.
const DIEU_KIEN = [
  'Sản phẩm còn trong thời hạn bảo hành tính từ ngày xuất hoá đơn.',
  'Tem bảo hành và tem niêm phong của CNTTShop còn nguyên vẹn, không rách, không tẩy xoá.',
  'Số serial trên máy khớp với thông tin trên phiếu bảo hành hoặc hoá đơn.',
  'Lỗi phát sinh do nhà sản xuất trong điều kiện sử dụng bình thường.',
];

const TU_CHOI = [
  'Mất tem bảo hành, tem bị rách hoặc có dấu hiệu bị can thiệp.',
  'Hư hỏng do rơi vỡ, va đập, vào nước, cháy nổ do nguồn điện không ổn định.',
  'Máy đã được tháo hoặc sửa chữa tại nơi khác không phải trung tâm uỷ quyền.',
  'Hao mòn tự nhiên của vật tư tiêu hao: keo tản nhiệt, đệm mút, lớp sơn phủ.',
  'Hỏng hóc do phần mềm, virus, hoặc do người dùng tự ép xung sai thông số.',
  'Dữ liệu trong ổ cứng — khách hàng tự sao lưu trước khi gửi máy.',
];

const QUY_TRINH = [
  { b: '1', t: 'Tra cứu & đặt lịch', m: 'Kiểm tra thời hạn bằng serial, sau đó đặt lịch tại trung tâm gần bạn nhất.' },
  { b: '2', t: 'Tiếp nhận & kiểm tra', m: 'Kỹ thuật kiểm tra máy, xác định lỗi và báo lại phương án cùng thời gian dự kiến.' },
  { b: '3', t: 'Xử lý', m: 'Sửa chữa hoặc thay thế linh kiện bằng hàng chính hãng. Ca ngoài bảo hành luôn hỏi ý bạn trước khi làm.' },
  { b: '4', t: 'Bàn giao', m: 'Test ổn định rồi bàn giao. Phần đã sửa được bảo hành thêm theo thời hạn ghi trên phiếu.' },
];

onMounted(async () => {
  try {
    chinhSach.value = await fetchWarrantyPolicies();
  } catch (e) {
    chinhSach.value = [];
  } finally {
    dangTai.value = false;
  }
});
</script>

<template>
  <main style="max-width: 1080px; margin: 0 auto; padding: 24px 24px 72px">
    <button class="sp-back" @click="actions.goSupport()">← Trung tâm hỗ trợ</button>

    <div style="margin-bottom: 30px">
      <div class="sp-eyebrow">THÔNG TIN BẢO HÀNH</div>
      <h1 class="sp-h1">
        Chính sách &amp; <span :style="{ color: accent }">tra cứu</span><br />bảo hành
      </h1>
      <p style="font-size: 14.5px; color: var(--muted2); max-width: 620px; line-height: 1.65; margin: 0">
        Kiểm tra thời hạn bảo hành bằng mã bảo hành (BHCNTT****) hoặc số serial trên tem máy, và
        xem đầy đủ điều kiện áp dụng cho từng nhóm hàng.
      </p>
    </div>

    <!-- Tra cứu mã bảo hành / serial -->
    <section
      class="sp-card"
      style="padding: 28px 30px; margin-bottom: 34px; border-color: rgba(var(--line-rgb), 0.2)"
    >
      <h2 class="sp-h2">Tra cứu thời hạn bảo hành</h2>
      <form @submit.prevent="traCuu" style="display: flex; gap: 11px; flex-wrap: wrap">
        <input
          v-model="serial"
          class="sp-input"
          style="flex: 1; min-width: 240px; height: 46px"
          placeholder="Nhập mã bảo hành (vd: BHCNTT1A2B) hoặc serial"
        />
        <button type="submit" class="sp-btn-acc" style="height: 46px; padding: 0 28px" :disabled="dangTra">
          {{ dangTra ? 'Đang tra…' : 'Tra cứu' }}
        </button>
      </form>
      <div style="font-size: 12px; color: var(--muted); margin-top: 10px; line-height: 1.55">
        Serial nằm trên tem dán ở mặt dưới laptop, mặt sau màn hình hoặc cạnh bên vỏ case.
        <span v-if="!state.user">
          Đã mua hàng tại CNTTShop?
          <a href="#" @click.prevent="actions.openLogin()" :style="{ color: accent }">Đăng nhập</a>
          để xem tất cả phiếu bảo hành mà không cần nhập serial.
        </span>
        <a v-else href="#" @click.prevent="actions.goWarranty()" :style="{ color: accent }">
          Xem tất cả phiếu bảo hành của tôi →
        </a>
      </div>

      <div v-if="loi" class="sp-alert err" style="margin-top: 16px; margin-bottom: 0">{{ loi }}</div>

      <!-- Kết quả -->
      <div v-if="ketQua" style="margin-top: 20px">
        <div v-if="!ketQua.timThay" class="sp-alert info" style="margin: 0">
          {{ ketQua.thongBao }}
        </div>

        <div
          v-else
          style="
            background: var(--card2);
            border-radius: 14px;
            padding: 22px 24px;
            border: 1px solid rgba(var(--line-rgb), 0.12);
          "
        >
          <div
            style="
              display: flex;
              align-items: center;
              justify-content: space-between;
              gap: 14px;
              flex-wrap: wrap;
              margin-bottom: 18px;
            "
          >
            <div
              style="
                font-family: 'Chakra Petch', sans-serif;
                font-weight: 700;
                font-size: 16px;
                color: var(--text);
              "
            >
              {{ ketQua.tenSanPham || 'Sản phẩm' }}
            </div>
            <span class="sp-pill" :style="{ color: mauTrangThai(ketQua.trangThai) }">
              {{ nhanTrangThai(ketQua.trangThai) }}
            </span>
          </div>

          <div class="wi-kv-grid">
            <div v-if="ketQua.maBaoHanh" class="wi-kv">
              <span>Mã bảo hành</span><b :style="{ color: accent }">{{ ketQua.maBaoHanh }}</b>
            </div>
            <div class="wi-kv"><span>Bạn nhập</span><b>{{ ketQua.serial }}</b></div>
            <div class="wi-kv"><span>Bắt đầu</span><b>{{ ngayVN(ketQua.ngayBatDau) }}</b></div>
            <div class="wi-kv"><span>Hết hạn</span><b>{{ ngayVN(ketQua.ngayHetHan) }}</b></div>
            <div class="wi-kv">
              <span>Còn lại</span>
              <b :style="{ color: ketQua.soNgayConLai > 0 ? 'var(--green)' : 'var(--muted)' }">
                {{ ketQua.soNgayConLai > 0 ? ketQua.soNgayConLai + ' ngày' : 'Đã hết hạn' }}
              </b>
            </div>
          </div>

          <div class="sp-alert info" style="margin: 18px 0 0">{{ ketQua.thongBao }}</div>

          <div style="display: flex; gap: 10px; margin-top: 16px; flex-wrap: wrap">
            <button class="sp-btn-acc" style="height: 40px" @click="actions.goServiceCenters()">
              Đặt lịch bảo hành →
            </button>
            <button class="sp-btn-ghost" @click="actions.goRepairPrice()">Xem bảng giá sửa chữa</button>
          </div>
        </div>
      </div>
    </section>

    <!-- Bảng thời hạn -->
    <section style="margin-bottom: 34px">
      <h2 class="sp-h2">Bảng 1 — Thời hạn bảo hành theo nhóm hàng</h2>
      <div class="sp-card" style="overflow: hidden">
        <div style="overflow-x: auto">
          <table class="wi-table">
            <thead>
              <tr>
                <th style="min-width: 220px">Nhóm hàng</th>
                <th style="width: 110px; text-align: center">Thời hạn</th>
                <th style="min-width: 150px">Tính từ</th>
                <th style="min-width: 260px">Ghi chú</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="c in chinhSach" :key="c.id">
                <td style="font-weight: 600; color: var(--text)">{{ c.nhomHang }}</td>
                <td style="text-align: center">
                  <span class="sp-pill" :style="{ color: accent }">{{ c.soThang }} tháng</span>
                </td>
                <td style="color: var(--muted2)">{{ c.tinhTu }}</td>
                <td style="color: var(--muted2); line-height: 1.55">{{ c.moTa }}</td>
              </tr>
              <tr v-if="!dangTai && !chinhSach.length">
                <td colspan="4" class="sp-empty">Chưa có dữ liệu chính sách bảo hành.</td>
              </tr>
              <tr v-if="dangTai">
                <td colspan="4" class="sp-empty">Đang tải…</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </section>

    <!-- Quy trình -->
    <section style="margin-bottom: 34px">
      <h2 class="sp-h2">Quy trình bảo hành</h2>
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 14px">
        <div v-for="q in QUY_TRINH" :key="q.b" class="sp-card" style="padding: 22px 20px">
          <div
            style="
              width: 32px;
              height: 32px;
              border-radius: 9px;
              display: flex;
              align-items: center;
              justify-content: center;
              font-family: 'Chakra Petch', sans-serif;
              font-weight: 700;
              font-size: 14px;
              margin-bottom: 13px;
            "
            :style="{ background: accent, color: 'var(--acc-ink)' }"
          >
            {{ q.b }}
          </div>
          <div style="font-size: 14px; font-weight: 700; color: var(--text); margin-bottom: 7px">
            {{ q.t }}
          </div>
          <div style="font-size: 12.7px; color: var(--muted2); line-height: 1.6">{{ q.m }}</div>
        </div>
      </div>
    </section>

    <!-- Điều kiện / từ chối -->
    <section style="display: grid; grid-template-columns: 1fr 1fr; gap: 18px" class="wi-two">
      <div class="sp-card" style="padding: 24px 26px">
        <h2 class="sp-h2" style="color: var(--green)">✓ Được bảo hành khi</h2>
        <ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 11px">
          <li v-for="(d, i) in DIEU_KIEN" :key="i" class="wi-li">{{ d }}</li>
        </ul>
      </div>
      <div class="sp-card" style="padding: 24px 26px">
        <h2 class="sp-h2" style="color: var(--sale)">✕ Không áp dụng bảo hành</h2>
        <ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 11px">
          <li v-for="(d, i) in TU_CHOI" :key="i" class="wi-li">{{ d }}</li>
        </ul>
        <div style="font-size: 12.3px; color: var(--muted); margin-top: 16px; line-height: 1.6">
          Các trường hợp này vẫn được sửa dịch vụ.
          <a href="#" @click.prevent="actions.goRepairPrice()" :style="{ color: accent }">
            Xem bảng giá →
          </a>
        </div>
      </div>
    </section>
  </main>
</template>

<style scoped>
.wi-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.wi-table th {
  text-align: left;
  padding: 14px 18px;
  font-family: 'Chakra Petch', sans-serif;
  font-size: 11.5px;
  letter-spacing: 0.6px;
  color: var(--muted);
  font-weight: 600;
  background: var(--card2);
  border-bottom: 1px solid rgba(var(--line-rgb), 0.12);
  white-space: nowrap;
}
.wi-table td {
  padding: 14px 18px;
  border-bottom: 1px solid rgba(var(--line-rgb), 0.08);
  vertical-align: top;
}
.wi-table tbody tr:last-child td {
  border-bottom: none;
}
.wi-table tbody tr:hover {
  background: var(--card2);
}

.wi-kv-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 16px;
}
.wi-kv span {
  display: block;
  font-size: 11.3px;
  color: var(--muted);
  margin-bottom: 5px;
}
.wi-kv b {
  font-size: 13.6px;
  color: var(--text);
  font-weight: 700;
}

.wi-li {
  font-size: 13px;
  color: var(--muted2);
  line-height: 1.6;
  padding-left: 16px;
  position: relative;
}
.wi-li::before {
  content: '•';
  position: absolute;
  left: 0;
  color: var(--muted);
}

@media (max-width: 780px) {
  .wi-two {
    grid-template-columns: 1fr !important;
  }
}
</style>
