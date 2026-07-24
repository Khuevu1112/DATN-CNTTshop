<script setup>
import { ref, computed } from 'vue';
import { accent } from '../store.js';

// data = MembershipStatusDto từ /api/membership (xem MembershipService.trangThai) — null khi
// chưa tải xong hoặc gọi lỗi, lúc đó component không vẽ gì.
// variant 'card'  = khối gọn trong cột (dùng nơi không gian hẹp)
// variant 'hero'  = băng ngang nổi bật full-width (đầu trang Cá nhân)
const props = defineProps({
  data: { type: Object, default: null },
  variant: { type: String, default: 'card' },
});

const showDetail = ref(false);

// Màu kim loại nhận diện từng bậc — dùng cho phần TRANG TRÍ (vòng huy hiệu, chấm mốc, gradient
// thanh tiến độ). KHÔNG dùng thẳng làm màu chữ: xem các lớp .ink-* dưới phần style, vì #E6E6E6
// và #B9F2FF đặt lên nền trắng của light mode thì gần như không đọc được.
const TIER_COLOR = {
  dong: '#996515', bac: '#E6E6E6', vang: '#FFD700', kim_cuong: '#B9F2FF',
};
const TIER_CARD = {
  dong: { bg: 'linear-gradient(135deg, #FF9900 0%, #FF5500 100%)', shadow: '0 10px 25px rgba(255,120,0,0.4)', text: '#ffffff' },
  bac: { bg: 'linear-gradient(135deg, #FFFFFF 0%, #A8C0FF 100%)', shadow: '0 10px 25px rgba(168,192,255,0.4)', text: '#1a1a2e' },
  vang: { bg: 'linear-gradient(135deg, #FFEA11 0%, #FF9900 100%)', shadow: '0 10px 25px rgba(255,215,0,0.5)', text: '#1a1a2e' },
  kim_cuong: { bg: 'linear-gradient(135deg, #00F2FE 0%, #4FACFE 100%)', shadow: '0 10px 25px rgba(0,242,254,0.5)', text: '#ffffff' },
};
const TIER_ICON = { dong: '🥉', bac: '🥈', vang: '🥇', kim_cuong: '💎' };
const TIER_ORDER = ['dong', 'bac', 'vang', 'kim_cuong'];

const color = (code) => TIER_COLOR[code] || accent;
const icon = (code) => TIER_ICON[code] || '⭐';
/** Lớp màu chữ theo bậc — có bản riêng cho light mode, xem phần style. */
const ink = (code) => 'ink-' + code;

const current = computed(() => props.data?.bacHienTai);
const next = computed(() => props.data?.bacKeTiep);

const currentIndex = computed(() => TIER_ORDER.indexOf(current.value?.code));

// Mốc cuối = null ở bậc Kim cương (không có trần) -> hiện "∞" ở đầu bên phải thanh tiến độ.
const mocCuoiText = computed(() => (props.data?.mocCuoi == null ? '∞' : props.data.mocCuoi));

/** Mô tả ưu đãi của 1 bậc thành các dòng ngắn — bậc Đồng không có ưu đãi nào. */
function benefitLines(t) {
  if (!t.mienPhiNoiThanh && !t.phanTramGiamPhiLienTinh && !t.phanTramGiamDon) {
    return ['Chưa có ưu đãi — tích thêm xu để lên bậc Bạc'];
  }
  const lines = [];
  if (t.mienPhiNoiThanh) lines.push('Miễn phí giao hàng nội thành');
  if (t.phanTramGiamPhiLienTinh) lines.push('Giảm ' + t.phanTramGiamPhiLienTinh + '% phí giao liên tỉnh / liên miền');
  if (t.phanTramGiamDon) lines.push('Giảm ' + t.phanTramGiamDon + '% mọi hoá đơn');
  return lines;
}

function rangeText(t) {
  return t.xuToiDa == null
    ? 'Từ ' + t.xuToiThieu.toLocaleString('vi-VN') + ' xu'
    : t.xuToiThieu.toLocaleString('vi-VN') + ' – ' + t.xuToiDa.toLocaleString('vi-VN') + ' xu';
}
</script>

<template>
  <!-- ============ BĂNG NGANG (hero) — dùng ở đầu trang Cá nhân ============ -->
  <div v-if="data && variant === 'hero'" class="mp-hero" :style="{ '--tc': color(current.code) }">
    <div class="mp-hero-badge-col">
      <div class="mp-badge-ring mp-hero-ring">
        <div class="mp-badge mp-hero-badge">{{ icon(current.code) }}</div>
      </div>
      <div>
        <div class="mp-tier-name mp-hero-name" :class="ink(current.code)">{{ current.name }}</div>
        <div class="mp-coins">{{ data.xuTichLuy.toLocaleString('vi-VN') }} xu tích luỹ</div>
      </div>
    </div>

    <div class="mp-hero-progress">
      <div class="mp-steps">
        <template v-for="(code, i) in TIER_ORDER" :key="code">
          <div
            class="mp-step-dot"
            :class="{ 'is-active': i <= currentIndex }"
            :style="i <= currentIndex ? { background: color(code), boxShadow: '0 0 0 3px color-mix(in srgb, ' + color(code) + ' 25%, transparent)' } : {}"
          ></div>
          <div v-if="i < TIER_ORDER.length - 1" class="mp-step-line" :class="{ 'is-active': i < currentIndex }"></div>
        </template>
      </div>
      <div class="mp-track">
        <div
          class="mp-fill"
          :style="{
            width: data.phanTram + '%',
            background: 'linear-gradient(90deg, ' + color(current.code) + ', ' + color(next ? next.code : current.code) + ')',
          }"
        >
          <div class="mp-shimmer"></div>
        </div>
      </div>
      <div class="mp-track-labels">
        <span>{{ data.mocDau.toLocaleString('vi-VN') }}</span>
        <span class="mp-track-pct" :class="ink(current.code)">{{ data.phanTram }}%</span>
        <span>{{ mocCuoiText }}</span>
      </div>
    </div>

    <div class="mp-hero-side">
      <div class="mp-note mp-hero-note">
        <template v-if="next">
          Còn <strong :class="ink(next.code)">{{ data.xuConThieu.toLocaleString('vi-VN') }} xu</strong> lên hạng {{ next.name }}
        </template>
        <template v-else>Bạn đang ở hạng cao nhất 🎉</template>
      </div>
      <button class="mp-detail-btn" @click="showDetail = true">
        Xem ưu đãi
        <span class="mp-detail-arrow">›</span>
      </button>
    </div>
  </div>

  <!-- ============ THẺ GỌN (card) — mặc định ============ -->
  <div v-else-if="data" class="mp-card">
    <div class="mp-head">
      <div class="mp-title">Hạng thành viên</div>
      <button class="mp-detail-btn" @click="showDetail = true">
        Chi tiết
        <span class="mp-detail-arrow">›</span>
      </button>
    </div>

    <div class="mp-badge-row">
      <div class="mp-badge-ring" :style="{ '--tc': color(current.code) }">
        <div class="mp-badge">{{ icon(current.code) }}</div>
      </div>
      <div style="min-width: 0">
        <div class="mp-tier-name" :class="ink(current.code)">{{ current.name }}</div>
        <div class="mp-coins">{{ data.xuTichLuy.toLocaleString('vi-VN') }} xu tích luỹ</div>
      </div>
    </div>

    <div class="mp-steps">
      <template v-for="(code, i) in TIER_ORDER" :key="code">
        <div
          class="mp-step-dot"
          :class="{ 'is-active': i <= currentIndex }"
          :style="i <= currentIndex ? { background: color(code), boxShadow: '0 0 0 3px color-mix(in srgb, ' + color(code) + ' 25%, transparent)' } : {}"
        ></div>
        <div v-if="i < TIER_ORDER.length - 1" class="mp-step-line" :class="{ 'is-active': i < currentIndex }"></div>
      </template>
    </div>

    <div class="mp-track">
      <div
        class="mp-fill"
        :style="{
          width: data.phanTram + '%',
          background: 'linear-gradient(90deg, ' + color(current.code) + ', ' + color(next ? next.code : current.code) + ')',
        }"
      >
        <div class="mp-shimmer"></div>
      </div>
    </div>
    <div class="mp-track-labels">
      <span>{{ data.mocDau.toLocaleString('vi-VN') }}</span>
      <span class="mp-track-pct" :class="ink(current.code)">{{ data.phanTram }}%</span>
      <span>{{ mocCuoiText }}</span>
    </div>

    <div class="mp-note">
      <template v-if="next">
        Còn <strong :class="ink(next.code)">{{ data.xuConThieu.toLocaleString('vi-VN') }} xu</strong>
        nữa để lên hạng {{ next.name }}.
      </template>
      <template v-else>
        Bạn đang ở hạng cao nhất — tận hưởng toàn bộ ưu đãi của CNTTShop.
      </template>
    </div>
  </div>

  <!-- Popup ưu đãi: 4 thẻ hạng, xếp ngang trên màn rộng và dồn thành cột dọc khi hẹp -->
  <Teleport to="body">
    <Transition name="mp-fade">
      <div v-if="showDetail" class="mp-overlay" @click.self="showDetail = false">
        <Transition name="mp-pop" appear>
          <div class="mp-dialog">
            <div class="mp-dialog-head">
              <div>
                <div class="mp-dialog-title">Ưu đãi theo hạng thành viên</div>
                <div class="mp-dialog-sub">
                  Hạng được xét theo tổng Xu CT bạn đã tích luỹ — tiêu xu không làm tụt hạng.
                </div>
              </div>
              <button class="mp-close-btn" @click="showDetail = false" aria-label="Đóng">×</button>
            </div>

            <div class="mp-dialog-body">
              <div class="mp-timeline">
                <div
                  v-for="t in data.tatCaBac" :key="t.code"
                  class="mp-tier-card"
                  :class="{ 'is-current': t.code === current.code }"
                  :style="{
                    background: TIER_CARD[t.code].bg,
                    boxShadow: t.code === current.code ? TIER_CARD[t.code].shadow + ', 0 0 0 2px #fff' : TIER_CARD[t.code].shadow,
                    color: TIER_CARD[t.code].text,
                  }"
                >
                  <div class="mp-tier-icon">
                    <svg v-if="t.code === 'dong'" viewBox="0 0 24 24" width="26" height="26" fill="currentColor"><circle cx="12" cy="12" r="9"/></svg>
                    <svg v-else-if="t.code === 'bac'" viewBox="0 0 24 24" width="26" height="26" fill="currentColor"><rect x="4" y="4" width="16" height="16" rx="4"/></svg>
                    <svg v-else-if="t.code === 'vang'" viewBox="0 0 24 24" width="26" height="26" fill="currentColor"><polygon points="12,2 14.7,9.1 22,9.4 16.2,14.1 18.2,21.3 12,17.1 5.8,21.3 7.8,14.1 2,9.4 9.3,9.1"/></svg>
                    <svg v-else viewBox="0 0 24 24" width="26" height="26" fill="currentColor"><polygon points="12,2 22,12 12,22 2,12"/></svg>
                  </div>
                  <div class="mp-tier-card-name">{{ t.name }}</div>
                  <span v-if="t.code === current.code" class="mp-current-pill">HẠNG CỦA BẠN</span>
                  <div class="mp-tier-range">{{ rangeText(t) }}</div>

                  <div class="mp-benefits">
                    <div v-for="(line, i2) in benefitLines(t)" :key="i2" class="mp-benefit-line">
                      <span class="mp-benefit-mark">{{ t.code === 'dong' ? '–' : '✓' }}</span>
                      <span>{{ line }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </Transition>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
/* ===== Màu CHỮ theo bậc =====
   Tách khỏi TIER_COLOR (màu trang trí) vì bạc #E6E6E6 và kim cương #B9F2FF đặt lên nền trắng
   của light mode chỉ đạt độ tương phản ~1.2:1 — mắt thường không đọc nổi. Dark mode giữ nguyên
   màu kim loại cho đẹp, light mode thay bằng bản đậm hơn đạt ~4.5:1 trên nền trắng. */
.ink-dong { color: #996515; }
.ink-bac { color: #E6E6E6; }
.ink-vang { color: #FFD700; }
.ink-kim_cuong { color: #B9F2FF; }

:root[data-mode='light'] .ink-bac { color: #6B7A8F; }
:root[data-mode='light'] .ink-vang { color: #A67C00; }
:root[data-mode='light'] .ink-kim_cuong { color: #0E7490; }

.mp-card {
  background: var(--card);
  border: 1px solid rgba(var(--line-rgb), 0.14);
  border-radius: 14px;
  padding: 22px;
  transition: box-shadow 0.25s ease, transform 0.25s ease;
}
.mp-card:hover {
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  transform: translateY(-1px);
}

.mp-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  margin-bottom: 16px;
}
.mp-title {
  font-size: 14px;
  font-weight: 700;
  color: var(--text);
}
.mp-detail-btn {
  display: inline-flex;
  align-items: center;
  gap: 3px;
  background: transparent;
  border: 1px solid rgba(var(--line-rgb), 0.22);
  border-radius: 8px;
  padding: 5px 10px 5px 12px;
  font-size: 12px;
  color: var(--muted2);
  cursor: pointer;
  font-family: 'Plus Jakarta Sans', sans-serif;
  flex: none;
  white-space: nowrap;
  transition: background 0.15s ease, border-color 0.15s ease, color 0.15s ease;
}
.mp-detail-btn:hover {
  background: rgba(var(--line-rgb), 0.08);
  border-color: rgba(var(--line-rgb), 0.35);
  color: var(--text);
}
.mp-detail-arrow {
  font-size: 14px;
  transition: transform 0.15s ease;
}
.mp-detail-btn:hover .mp-detail-arrow {
  transform: translateX(2px);
}

.mp-badge-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

/* Vòng gradient quay quanh huy hiệu. Phải khai báo --mp-angle bằng @property thì trình duyệt
   mới nội suy được kiểu <angle>; animate background-position (cách quen dùng với linear-gradient)
   không làm conic-gradient quay, animation thành vô nghĩa. Trình duyệt cũ không hỗ trợ @property
   sẽ hiện vòng tĩnh — vẫn đẹp, chỉ là không quay. */
@property --mp-angle {
  syntax: '<angle>';
  initial-value: 0deg;
  inherits: false;
}
.mp-badge-ring {
  flex: none;
  width: 52px;
  height: 52px;
  border-radius: 14px;
  padding: 2px;
  background: conic-gradient(
    from var(--mp-angle),
    var(--tc),
    color-mix(in srgb, var(--tc) 30%, transparent),
    var(--tc)
  );
  animation: mp-ring-spin 6s linear infinite;
}
@keyframes mp-ring-spin {
  to { --mp-angle: 360deg; }
}
.mp-badge {
  width: 100%;
  height: 100%;
  border-radius: 12px;
  background: color-mix(in srgb, var(--tc) 16%, var(--card));
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
}
.mp-tier-name {
  font-size: 16px;
  font-weight: 800;
}
.mp-coins {
  font-size: 11.5px;
  color: var(--muted2);
  margin-top: 2px;
}

.mp-steps {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
  padding: 0 2px;
}
.mp-step-dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: var(--card2);
  flex: none;
  transition: background 0.3s ease, box-shadow 0.3s ease;
}
.mp-step-line {
  flex: 1;
  height: 2px;
  background: var(--card2);
  margin: 0 3px;
  transition: background 0.3s ease;
}
.mp-step-line.is-active {
  background: rgba(var(--line-rgb), 0.4);
}

.mp-track {
  height: 9px;
  background: var(--card2);
  border-radius: 999px;
  overflow: hidden;
}
.mp-fill {
  position: relative;
  height: 100%;
  border-radius: 999px;
  transition: width 0.6s cubic-bezier(0.22, 1, 0.36, 1);
  overflow: hidden;
}
.mp-shimmer {
  position: absolute;
  inset: 0;
  background: linear-gradient(100deg, transparent 20%, rgba(255, 255, 255, 0.45) 50%, transparent 80%);
  background-size: 200% 100%;
  animation: mp-shimmer-move 2.2s ease-in-out infinite;
}
@keyframes mp-shimmer-move {
  0% { background-position: 150% 0; }
  100% { background-position: -50% 0; }
}
.mp-track-labels {
  display: flex;
  justify-content: space-between;
  font-size: 11px;
  color: var(--muted);
  margin-top: 6px;
}
.mp-track-pct {
  font-weight: 700;
}

.mp-note {
  font-size: 12px;
  color: var(--muted2);
  margin-top: 12px;
  line-height: 1.6;
}

/* ===== Hero (băng ngang) ===== */
.mp-hero {
  background: linear-gradient(135deg, color-mix(in srgb, var(--tc) 10%, var(--card)), var(--card) 60%);
  border: 1px solid color-mix(in srgb, var(--tc) 30%, rgba(var(--line-rgb), 0.14));
  border-radius: 16px;
  padding: 20px 26px;
  display: flex;
  align-items: center;
  gap: 28px;
  flex-wrap: wrap;
}
.mp-hero-badge-col {
  display: flex;
  align-items: center;
  gap: 14px;
  flex: none;
}
.mp-hero-ring {
  width: 62px;
  height: 62px;
  border-radius: 16px;
}
.mp-hero-badge {
  font-size: 28px;
  border-radius: 14px;
}
.mp-hero-name {
  font-size: 18px;
}
.mp-hero-progress {
  flex: 1 1 260px;
  min-width: 220px;
}
.mp-hero-side {
  flex: none;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 10px;
}
.mp-hero-note {
  margin: 0;
  text-align: right;
  white-space: nowrap;
}

.mp-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 200;
  padding: 20px;
}
.mp-fade-enter-active, .mp-fade-leave-active { transition: opacity 0.2s ease; }
.mp-fade-enter-from, .mp-fade-leave-to { opacity: 0; }

.mp-dialog {
  background: var(--card);
  border: 1px solid rgba(var(--line-rgb), 0.18);
  border-radius: 16px;
  width: 100%;
  max-width: 900px;
  max-height: 86vh;
  display: flex;
  flex-direction: column;
}
.mp-pop-enter-active { transition: opacity 0.22s ease, transform 0.28s cubic-bezier(0.22, 1, 0.36, 1); }
.mp-pop-enter-from { opacity: 0; transform: translateY(10px) scale(0.97); }

.mp-dialog-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  padding: 22px 26px 14px;
}
.mp-dialog-title {
  font-size: 16px;
  font-weight: 800;
  color: var(--text);
}
.mp-dialog-sub {
  font-size: 12px;
  color: var(--muted2);
  margin-top: 3px;
}
.mp-close-btn {
  background: transparent;
  border: none;
  color: var(--muted);
  font-size: 22px;
  line-height: 1;
  cursor: pointer;
  flex: none;
  padding: 4px 6px;
  border-radius: 8px;
  transition: background 0.15s ease, color 0.15s ease;
}
.mp-close-btn:hover {
  background: rgba(var(--line-rgb), 0.1);
  color: var(--text);
}

.mp-dialog-body {
  overflow-y: auto;
  padding: 6px 26px 26px;
}

.mp-timeline {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
}

.mp-tier-card {
  border-radius: 16px;
  padding: 20px 16px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  transition: transform 0.3s ease, filter 0.3s ease;
}
.mp-tier-card:hover {
  transform: translateY(-5px);
  filter: brightness(1.08);
}
.mp-tier-card.is-current {
  transform: translateY(-2px);
}
.mp-tier-icon {
  width: 46px;
  height: 46px;
  border-radius: 13px;
  background: color-mix(in srgb, currentColor 16%, transparent);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 12px;
}
.mp-tier-card-name {
  font-size: 20px;
  font-weight: 800;
  letter-spacing: 0.2px;
  color: inherit;
}
/* Viền mảnh để nhãn không tàng hình trên thẻ Bạc — nền thẻ đó bắt đầu bằng #FFFFFF, mà nhãn
   cũng nền trắng. */
.mp-current-pill {
  display: inline-block;
  margin-top: 6px;
  font-size: 9.5px;
  font-weight: 700;
  color: #0b0b0b;
  background: #fff;
  border: 1px solid rgba(0, 0, 0, 0.18);
  padding: 2px 8px;
  border-radius: 10px;
  letter-spacing: 0.3px;
}
.mp-tier-range {
  font-size: 12.5px;
  color: inherit;
  opacity: 0.75;
  margin-top: 6px;
  font-weight: 600;
}

.mp-benefits {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 14px;
}
.mp-benefit-line {
  display: flex;
  align-items: flex-start;
  gap: 7px;
  font-size: 13px;
  font-weight: 500;
  color: inherit;
  opacity: 0.9;
  line-height: 1.45;
}
.mp-benefit-mark {
  flex: none;
  font-weight: 800;
  color: inherit;
}

/* 4 cột chỉ vừa khi dialog còn đủ 900px. Hẹp hơn thì dồn dần xuống, nếu không mỗi thẻ chỉ còn
   ~75px trên điện thoại và chữ ưu đãi vỡ vụn. */
@media (max-width: 860px) {
  .mp-timeline { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 520px) {
  .mp-timeline { grid-template-columns: 1fr; }
  .mp-hero { gap: 18px; padding: 18px; }
  .mp-hero-side { align-items: flex-start; width: 100%; }
  .mp-hero-note { text-align: left; white-space: normal; }
}

/* Tôn trọng cài đặt giảm chuyển động của hệ điều hành — vòng quay và shimmer chạy vô hạn, đúng
   nhóm hiệu ứng gây khó chịu cho người nhạy cảm với chuyển động. */
@media (prefers-reduced-motion: reduce) {
  .mp-badge-ring,
  .mp-shimmer {
    animation: none;
  }
  .mp-card,
  .mp-tier-card,
  .mp-fill {
    transition: none;
  }
}
</style>
