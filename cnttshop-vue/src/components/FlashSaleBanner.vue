<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { actions } from '../store.js';
import { products } from '../data/products.js';
import ProductCard from './ProductCard.vue';

// GIAO DIỆN bê nguyên si từ Sale/views/HomeView.vue theo yêu cầu — thanh ngang gradient, đồng hồ
// đếm ngược, nút "Xem chi tiết" nổi, panel sản phẩm dạng ProductCard, nút "Xem tất cả deal".
// CHỈ thay hai thứ so với bản mẫu (mẫu chạy dữ liệu tĩnh):
//   1. Nguồn sản phẩm: từ props.sale.sanPham (API flash sale thật) thay vì lọc products cứng.
//   2. Đồng ngược đếm theo ends_at THẬT của đợt sale, thay vì khung 6 giờ giả lặp lại — cách
//      hiển thị h/m/s giữ y hệt.
const props = defineProps({
  sale: { type: Object, default: null },
  // preview: admin xem trước trong trình soạn — mở sẵn panel, không điều hướng khi bấm.
  preview: { type: Boolean, default: false },
});

// Màu mặc định trùng bản mẫu; giữ nguyên gradient 3 chặng của mẫu khi admin chưa đổi màu, còn
// admin đã đổi thì dùng đúng 2 màu họ chọn.
const DEFAULT_FROM = '#ff3d24';
const DEFAULT_TO = '#ff9500';
const gradient = computed(() => {
  const from = props.sale?.mauBatDau || DEFAULT_FROM;
  const to = props.sale?.mauKetThuc || DEFAULT_TO;
  if (from === DEFAULT_FROM && to === DEFAULT_TO) {
    return 'linear-gradient(115deg, #ff3d24 0%, #ff7a1a 60%, #ff9500 100%)';
  }
  return `linear-gradient(115deg, ${from} 0%, ${to} 100%)`;
});

// Tra sản phẩm ĐẦY ĐỦ trong store.products (đã có rating/specs/hue/ảnh...) theo productId rồi chỉ
// ghi đè giá sale — card flash sale nhờ vậy giống HỆT mọi card khác trên trang (đúng "nguyên si"),
// và ProductCard không crash vì thiếu rating/specs (nó truy cập .toFixed()/.slice() không guard).
// Không tìm thấy trong store (chưa tải xong hoặc sản phẩm ẩn) thì dựng shape tối thiểu an toàn.
const flashItems = computed(() =>
  (props.sale?.sanPham || []).map((s) => {
    const full = products.find((p) => p.id === s.productId);
    const base = full || {
      id: s.productSlug || s.productId,
      name: s.productName, image: s.imageUrl,
      rating: 0, reviews: 0, specs: [],
    };
    return { pct: s.phanTramGiam, product: { ...base, price: s.giaSale, oldPrice: s.giaGoc } };
  }),
);

// Đếm ngược tới ends_at thật của đợt sale.
const conLaiMs = ref(0);
let flashTimer = null;
function tinhConLai() {
  conLaiMs.value = props.sale?.ketThucLuc
    ? Math.max(0, new Date(props.sale.ketThucLuc).getTime() - Date.now())
    : 0;
}
onMounted(() => {
  tinhConLai();
  flashTimer = setInterval(tinhConLai, 1000);
});
onUnmounted(() => clearInterval(flashTimer));

const flashCountdown = computed(() => {
  const total = Math.max(0, Math.floor(conLaiMs.value / 1000));
  const d = Math.floor(total / 86400);
  // Quá 24 giờ thì tách riêng ô "ngày", giờ chỉ còn 0-23 (không dồn hết vào ô giờ ra "162").
  return {
    d,
    h: String(Math.floor((total % 86400) / 3600)).padStart(2, '0'),
    m: String(Math.floor((total % 3600) / 60)).padStart(2, '0'),
    s: String(total % 60).padStart(2, '0'),
  };
});

// Dropdown chi tiết sản phẩm flash sale — thanh ngang chỉ hiện nhãn + đếm ngược, bấm để mở/đóng.
const isFlashOpen = ref(props.preview);

// Trong preview (admin) không điều hướng khỏi trang soạn khi bấm card.
const moChiTiet = (id) => { if (!props.preview) actions.goDetail(id); };
const themGio = (id) => { if (!props.preview) actions.addToCart(id); };
const xemTatCa = () => { if (!props.preview) actions.goDeals(); };
</script>

<template>
  <!-- FLASH SALE: thanh ngang mảnh (nhãn + đếm ngược), bấm để mở dropdown sản phẩm -->
  <div v-if="flashItems.length" style="margin-top: 20px">
    <div
      :style="{ background: gradient }"
      style="
        position: relative;
        overflow: hidden;
        border-radius: 16px;
        box-shadow: 0 12px 28px rgba(255, 61, 36, 0.35);
        padding: 14px 26px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 20px;
        flex-wrap: wrap;
      "
    >
      <div
        style="
          position: absolute;
          inset: 0;
          background: repeating-linear-gradient(-45deg, rgba(255, 255, 255, 0.06) 0 14px, transparent 14px 28px);
          pointer-events: none;
        "
      ></div>
      <div style="position: relative; display: flex; align-items: center; gap: 12px">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
          <path d="M13 2 4 14h6l-1 8 9-12h-6l1-8Z" fill="#fff" />
        </svg>
        <span style="font-family: 'Chakra Petch', sans-serif; font-size: 16px; font-weight: 800; letter-spacing: 1px; color: #fff">{{ sale.tieuDe || 'FLASH SALE' }}</span>
      </div>
      <div style="position: relative; display: flex; align-items: center; gap: 14px">
        <span style="font-size: 12px; color: rgba(255, 255, 255, 0.85)">Kết thúc sau</span>
        <div style="display: flex; align-items: center; gap: 6px">
          <template v-if="flashCountdown.d > 0">
            <div class="flash-clock-cell flash-clock-day">{{ flashCountdown.d }} ngày</div>
            <div class="flash-clock-sep">:</div>
          </template>
          <div class="flash-clock-cell">{{ flashCountdown.h }}</div>
          <div class="flash-clock-sep">:</div>
          <div class="flash-clock-cell">{{ flashCountdown.m }}</div>
          <div class="flash-clock-sep">:</div>
          <div class="flash-clock-cell">{{ flashCountdown.s }}</div>
        </div>
      </div>
    </div>

    <!-- Panel dropdown. maxHeight nới rộng (mẫu để 420px làm CẮT chân card thật) để card + giá +
         nút hiện đủ. Viền dày 3px màu gradient giống banner qua kỹ thuật padding-box/border-box
         (giữ được bo góc, khác với border-image). -->
    <div :style="{ overflow: 'hidden', transition: 'max-height 0.45s cubic-bezier(.4,0,.2,1)', maxHeight: isFlashOpen ? '1600px' : '0px', marginTop: '6px' }">
      <div
        :style="{
          borderRadius: '16px',
          border: '3px solid transparent',
          background: 'linear-gradient(var(--card), var(--card)) padding-box, ' + gradient + ' border-box',
          padding: '20px 26px 30px',
        }"
      >
        <div
          :style="{
            transition: 'opacity 0.3s ease ' + (isFlashOpen ? '0.08s' : '0s') + ', transform 0.35s cubic-bezier(.4,0,.2,1) ' + (isFlashOpen ? '0.08s' : '0s'),
            opacity: isFlashOpen ? 1 : 0,
            transform: isFlashOpen ? 'translateY(0)' : 'translateY(-14px)',
          }"
          style="display: flex; gap: 14px; flex-wrap: wrap; align-items: stretch"
        >
          <div
            v-for="f in flashItems"
            :key="f.product.id"
            style="position: relative; flex: 1; min-width: 200px; max-width: 260px; border-radius: 14px; padding: 6px; cursor: pointer"
          >
            <div
              style="
                position: absolute;
                top: 8px;
                left: 8px;
                z-index: 1;
                background: #ffe600;
                color: #7a1a00;
                font-size: 11px;
                font-weight: 800;
                padding: 3px 8px;
                border-radius: 20px;
              "
            >
              -{{ f.pct }}%
            </div>
            <ProductCard :p="f.product" @open="moChiTiet" @add="themGio" />
          </div>
        </div>

        <div
          :style="{
            transition: 'opacity 0.3s ease ' + (isFlashOpen ? '0.18s' : '0s') + ', transform 0.35s cubic-bezier(.4,0,.2,1) ' + (isFlashOpen ? '0.18s' : '0s'),
            opacity: isFlashOpen ? 1 : 0,
            transform: isFlashOpen ? 'translateY(0)' : 'translateY(-14px)',
          }"
          @click="xemTatCa"
          style="
            margin-top: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 14px;
            border: 1px dashed rgba(var(--line-rgb), 0.3);
            cursor: pointer;
            padding: 12px;
          "
        >
          <span style="font-size: 13.5px; font-weight: 700; color: var(--acc)">Xem thêm Ưu đãi →</span>
        </div>
      </div>
    </div>

    <!-- Nút "Xem chi tiết" đặt DƯỚI panel: khi mở, panel cao lên đẩy nút TRƯỢT XUỐNG theo; khi
         đóng (panel cao 0) nút nằm ngay dưới banner. margin-top âm để nút đè lên mép. -->
    <div style="display: flex; justify-content: center; position: relative; z-index: 2; margin-top: -15px">
      <div
        @click="isFlashOpen = !isFlashOpen"
        :style="{ background: gradient }"
        style="display: flex; align-items: center; gap: 6px; color: #fff; font-size: 12px; font-weight: 700; padding: 6px 16px 6px 18px; border-radius: 20px; box-shadow: 0 6px 16px rgba(255, 61, 36, 0.4); cursor: pointer"
      >
        <span>Xem chi tiết</span>
        <svg
          :style="{ transform: isFlashOpen ? 'rotate(180deg)' : 'rotate(0deg)' }"
          style="transition: transform 0.2s ease" width="13" height="13" viewBox="0 0 24 24" fill="none"
        >
          <path d="M6 9l6 6 6-6" stroke="#fff" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      </div>
    </div>
  </div>
</template>

<style scoped>
.flash-clock-cell {
  min-width: 30px;
  text-align: center;
  background: rgba(255, 255, 255, 0.22);
  color: #fff;
  font-family: 'Chakra Petch', sans-serif;
  font-weight: 700;
  font-size: 17px;
  padding: 4px 5px;
  border-radius: 6px;
}
.flash-clock-sep {
  color: rgba(255, 255, 255, 0.85);
  font-weight: 700;
  font-size: 16px;
}
/* Ô "N ngày" rộng hơn ô số vì chứa cả chữ. */
.flash-clock-day {
  min-width: auto;
  padding: 4px 9px;
  white-space: nowrap;
}
</style>
