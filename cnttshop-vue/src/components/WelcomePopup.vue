<script setup>
import { ref, onMounted } from 'vue';
import { state, actions, accent } from '../store.js';
import { fetchFlashSale, fetchCheckinStatus } from '../api.js';

// Pop-up chào khi mới vào phiên. Hiện 1 LẦN mỗi phiên (sessionStorage) để không phiền khi
// chuyển trang. Nội dung tuỳ trạng thái đăng nhập:
//   - Chưa đăng nhập  -> mời xem Flash Sale (nếu đang có đợt) / ưu đãi.
//   - Đã đăng nhập     -> nhắc điểm danh nhận Xu (ẩn nếu hôm nay đã điểm danh).
const SESSION_KEY = 'welcomePopupShown';

const show = ref(false);
const mode = ref('guest'); // 'guest' | 'checkin'
const flash = ref(null);

function dong() {
  show.value = false;
}
function di(action) {
  dong();
  action();
}

onMounted(async () => {
  if (sessionStorage.getItem(SESSION_KEY)) return;

  if (state.user) {
    // Đã đăng nhập: chỉ nhắc nếu hôm nay CHƯA điểm danh.
    try {
      const st = await fetchCheckinStatus();
      if (st?.checkedInToday) {
        sessionStorage.setItem(SESSION_KEY, '1');
        return;
      }
    } catch (e) {
      // Không lấy được trạng thái điểm danh -> vẫn nhắc, không chặn.
    }
    mode.value = 'checkin';
  } else {
    // Khách vãng lai: lấy flash sale đang chạy (nếu có) để nội dung sát thực tế.
    mode.value = 'guest';
    try {
      flash.value = await fetchFlashSale();
    } catch (e) {
      flash.value = null;
    }
  }

  sessionStorage.setItem(SESSION_KEY, '1');
  // Chờ một nhịp cho trang ổn định rồi mới bật, tránh nhảy ngay lúc đang tải.
  setTimeout(() => (show.value = true), 900);
});
</script>

<template>
  <Teleport to="body">
    <Transition name="wp-fade">
      <div v-if="show" class="wp-backdrop" @click.self="dong">
        <div class="wp-box">
          <button class="wp-close" @click="dong">✕</button>

          <!-- Khách vãng lai: Flash Sale / ưu đãi -->
          <template v-if="mode === 'guest'">
            <div class="wp-hero wp-hero-sale">
              <div class="wp-badge">⚡ FLASH SALE</div>
              <div class="wp-title">{{ flash?.tieuDe || 'Ưu đãi sốc mỗi ngày' }}</div>
              <div class="wp-sub">
                {{ flash?.moTa || 'Săn deal giảm sâu laptop, PC, linh kiện — số lượng có hạn!' }}
              </div>
            </div>
            <div class="wp-body">
              <p class="wp-note">Đăng nhập để nhận thêm Xu CT, mã giảm giá và tích điểm mỗi ngày.</p>
              <div class="wp-actions">
                <button class="wp-btn-ghost" @click="di(actions.openLogin)">Đăng nhập</button>
                <button class="wp-btn-acc" @click="di(flash ? actions.goPromotions : actions.goDeals)">
                  {{ flash ? 'Xem Flash Sale →' : 'Xem ưu đãi →' }}
                </button>
              </div>
            </div>
          </template>

          <!-- Đã đăng nhập: nhắc điểm danh nhận Xu -->
          <template v-else>
            <div class="wp-hero wp-hero-xu">
              <div class="wp-coin">🪙</div>
              <div class="wp-title">Điểm danh nhận Xu hôm nay!</div>
              <div class="wp-sub">
                Xin chào {{ state.user?.fullName || 'bạn' }} — điểm danh mỗi ngày để tích Xu CT,
                đổi mã giảm giá và quà tặng.
              </div>
            </div>
            <div class="wp-body">
              <p class="wp-note">Chuỗi điểm danh liên tục càng dài, thưởng Xu càng lớn.</p>
              <div class="wp-actions">
                <button class="wp-btn-ghost" @click="dong">Để sau</button>
                <button class="wp-btn-acc" @click="di(actions.goPromotions)">Điểm danh ngay →</button>
              </div>
            </div>
          </template>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.wp-backdrop {
  position: fixed;
  inset: 0;
  z-index: 4000;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(3px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}
.wp-box {
  position: relative;
  width: 100%;
  max-width: 400px;
  background: var(--card);
  border: 1px solid rgba(var(--line-rgb), 0.16);
  border-radius: 18px;
  overflow: hidden;
  box-shadow: 0 24px 60px rgba(0, 0, 0, 0.4);
  animation: wp-pop 0.4s cubic-bezier(0.2, 1.3, 0.4, 1) both;
}
.wp-close {
  position: absolute;
  top: 12px;
  right: 12px;
  z-index: 2;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  border: none;
  background: rgba(0, 0, 0, 0.3);
  color: #fff;
  font-size: 13px;
  cursor: pointer;
}
.wp-close:hover {
  background: rgba(0, 0, 0, 0.5);
}
.wp-hero {
  padding: 34px 26px 26px;
  text-align: center;
}
.wp-hero-sale {
  background: linear-gradient(135deg, #ff5d7a, #b3143a);
}
.wp-hero-xu {
  background: linear-gradient(135deg, color-mix(in srgb, var(--acc, #c6ff4a) 55%, #06110a), #06110a);
}
.wp-badge {
  display: inline-block;
  font-family: 'Chakra Petch', sans-serif;
  font-weight: 700;
  font-size: 11px;
  letter-spacing: 2px;
  color: #fff;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 20px;
  padding: 4px 12px;
  margin-bottom: 12px;
}
.wp-coin {
  font-size: 40px;
  margin-bottom: 8px;
}
.wp-title {
  font-family: 'Chakra Petch', sans-serif;
  font-weight: 800;
  font-size: 21px;
  color: #fff;
  line-height: 1.2;
  margin-bottom: 8px;
}
.wp-sub {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.82);
  line-height: 1.55;
}
.wp-body {
  padding: 20px 24px 24px;
}
.wp-note {
  font-size: 12.5px;
  color: var(--muted2);
  line-height: 1.55;
  margin: 0 0 18px;
  text-align: center;
}
.wp-actions {
  display: flex;
  gap: 10px;
}
.wp-btn-ghost {
  flex: 1;
  height: 44px;
  border: 1px solid rgba(var(--line-rgb), 0.22);
  background: transparent;
  border-radius: 11px;
  color: var(--muted2);
  font-size: 13.5px;
  font-weight: 600;
  cursor: pointer;
  font-family: 'Plus Jakarta Sans', sans-serif;
}
.wp-btn-acc {
  flex: 1.4;
  height: 44px;
  border: none;
  border-radius: 11px;
  background: var(--acc, #c6ff4a);
  color: var(--acc-ink);
  font-size: 13.5px;
  font-weight: 700;
  cursor: pointer;
  font-family: 'Plus Jakarta Sans', sans-serif;
}

@keyframes wp-pop {
  from { opacity: 0; transform: translateY(24px) scale(0.94); }
  to { opacity: 1; transform: none; }
}
.wp-fade-enter-active,
.wp-fade-leave-active {
  transition: opacity 0.25s ease;
}
.wp-fade-enter-from,
.wp-fade-leave-to {
  opacity: 0;
}
@media (prefers-reduced-motion: reduce) {
  .wp-box { animation: none; }
}
</style>
