<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { state, actions, accent } from '../store.js';
import { fmt } from '../data/products.js';
import { resolveImageUrl } from '../api.js';
import {
  fetchWallet, fetchRedemptionCatalog, redeemCoupon, redeemGift,
  fetchCheckinStatus, doCheckin, fetchAddresses, fetchFlashSale, fetchFlashSaleAdmin,
} from '../api.js';
import FlashSaleBanner from '../components/FlashSaleBanner.vue';
import FlashSaleEditor from '../components/FlashSaleEditor.vue';

// ===== Hai tab của trang khuyến mãi =====
// Khách thường thấy banner flash sale đang chạy; admin thấy trình soạn ngay tại đây (nội dung
// sửa được tại chỗ, xem FlashSaleEditor). Việc ẩn/hiện theo role chỉ là UX — chốt chặn thật nằm
// ở @RequirePermission("coupons") bên FlashSaleApiController.
const activeTab = ref('doi-thuong');
const laAdmin = computed(() => state.user?.role === 'admin');
const saleCongKhai = ref(null);
const saleAdmin = ref(null);

async function loadFlashSale() {
  try {
    saleCongKhai.value = await fetchFlashSale();
  } catch (e) {
    saleCongKhai.value = null;
  }
  if (!laAdmin.value) return;
  try {
    const st = await fetchFlashSaleAdmin();
    saleAdmin.value = st.dot;
  } catch (e) {
    saleAdmin.value = null;
  }
}

const loading = ref(true);
const loadError = ref('');
const xuBalance = ref(0);
const catalog = ref([]);
const addresses = ref([]);

const checkinStatus = ref(null);
const checkinLoading = ref(false);

// ===== Trạng thái từng ô ngày điểm danh + đếm ngược tới lượt tiếp theo (nửa đêm) =====
const nowTick = ref(Date.now());
let tickTimer = null;

const pad2 = (n) => String(n).padStart(2, '0');
// Còn bao lâu tới 00:00 hôm sau — lúc chuỗi điểm danh mở lại.
const countdown = computed(() => {
  const now = new Date(nowTick.value);
  const mid = new Date(now);
  mid.setHours(24, 0, 0, 0);
  let s = Math.max(0, Math.floor((mid - now) / 1000));
  const h = Math.floor(s / 3600); s %= 3600;
  const m = Math.floor(s / 60); s %= 60;
  return `${pad2(h)}:${pad2(m)}:${pad2(s)}`;
});

// Ô "hôm nay" theo backend (1..7). Khi đã điểm danh: ô này là ngày vừa xong; các ngày trước nó
// đã điểm danh; ngày kế tiếp là khung sáng có đếm ngược. Khi chưa điểm danh: ô này là ngày bấm
// điểm danh hôm nay (khung sáng, chưa mờ).
const curSlot = computed(() => {
  const s = checkinStatus.value ? Math.max(1, checkinStatus.value.currentStreak) : 1;
  return ((s - 1) % 7) + 1;
});
/** Trạng thái ô ngày (idx 0-based): 'done' | 'next' | 'today' | 'future'. */
function dayState(idx) {
  const day = idx + 1;
  const cur = curSlot.value;
  if (checkinStatus.value?.checkedInToday) {
    if (day <= cur) return 'done';
    if (day === cur + 1) return 'next';
    return 'future';
  }
  if (day < cur) return 'done';
  if (day === cur) return 'today';
  return 'future';
}

const redeemingId = ref(null);
const giftPickerItem = ref(null);
const giftAddressId = ref(null);
const couponResult = ref(null);

// ===== Hiệu ứng đổi thưởng/điểm danh: xu bay vào số dư + số dư đếm mượt + confetti/pop-ring =====
const coinFlyId = ref(null); // id mục đang đổi (đang bay xu) trong danh sách coupon/quà
const checkinCoinFly = ref(false);
const popDayIdx = ref(null); // idx (1-based) của ô ngày vừa điểm danh, để nảy + phát sáng
const confetti = ref([]);
let balanceRaf = null;

function animateBalance(target, onDone) {
  const start = xuBalance.value;
  const startTime = performance.now();
  const dur = 450;
  cancelAnimationFrame(balanceRaf);
  function step(now) {
    const t = Math.min(1, (now - startTime) / dur);
    const eased = 1 - Math.pow(1 - t, 3);
    xuBalance.value = Math.round(start + (target - start) * eased);
    if (t < 1) {
      balanceRaf = requestAnimationFrame(step);
    } else {
      onDone?.();
    }
  }
  balanceRaf = requestAnimationFrame(step);
}

function spawnConfetti() {
  confetti.value = Array.from({ length: 10 }, (_, i) => ({
    id: i,
    style: {
      left: (44 + Math.random() * 12).toFixed(0) + '%',
      background: ['#c6ff4a', '#ff45e0', '#2bd47e', '#ffb43b'][i % 4],
      '--cx': (Math.random() * 200 - 100).toFixed(0) + 'px',
      '--cy': (Math.random() * -140 - 20).toFixed(0) + 'px',
      '--cr': (Math.random() * 360).toFixed(0) + 'deg',
    },
  }));
}

const coupons = computed(() => catalog.value.filter((i) => i.type === 'coupon'));
const gifts = computed(() => catalog.value.filter((i) => i.type === 'gift'));

async function loadAll() {
  loading.value = true;
  loadError.value = '';
  try {
    const [wallet, cat, status] = await Promise.all([
      fetchWallet(), fetchRedemptionCatalog(), fetchCheckinStatus(),
    ]);
    xuBalance.value = wallet.balance;
    catalog.value = cat;
    checkinStatus.value = status;
  } catch (e) {
    // checkinStatus có thể vẫn null nếu lỗi ở đây — template phải luôn kiểm tra loadError/
    // checkinStatus trước khi render, không được giả định đã tải xong chỉ vì loading=false.
    loadError.value = e?.message && !e.message.startsWith('HTTP') ? e.message : 'Không tải được trang khuyến mãi, vui lòng thử lại';
  } finally {
    loading.value = false;
  }
}

async function onCheckin() {
  checkinLoading.value = true;
  try {
    const result = await doCheckin();
    const [wallet, status] = await Promise.all([fetchWallet(), fetchCheckinStatus()]);

    checkinCoinFly.value = true;
    setTimeout(() => {
      checkinCoinFly.value = false;
      checkinStatus.value = status;
      checkinLoading.value = false;
      popDayIdx.value = (((status.currentStreak - 1) % 7) + 1);
      animateBalance(wallet.balance);
      actions.showToast(`Điểm danh thành công! +${result.rewardSilver} Xu CT (ngày ${result.streak})`);
    }, 620);
    setTimeout(() => { popDayIdx.value = null; }, 1400);
  } catch (e) {
    actions.showToast(e?.message && !e.message.startsWith('HTTP') ? e.message : 'Điểm danh thất bại');
    checkinLoading.value = false;
  }
}

async function onRedeemCoupon(item) {
  if (xuBalance.value < item.silverCost) {
    actions.showToast('Bạn không đủ Xu CT để đổi mục này');
    return;
  }
  redeemingId.value = item.id;
  try {
    const result = await redeemCoupon(item.id);
    const wallet = await fetchWallet();

    coinFlyId.value = item.id;
    setTimeout(() => {
      coinFlyId.value = null;
      redeemingId.value = null;
      animateBalance(wallet.balance, () => {
        spawnConfetti();
        couponResult.value = { name: item.name, code: result.couponCode };
      });
    }, 500);
  } catch (e) {
    actions.showToast(e?.message && !e.message.startsWith('HTTP') ? e.message : 'Đổi thưởng thất bại');
    redeemingId.value = null;
  }
}

async function openGiftPicker(item) {
  if (xuBalance.value < item.silverCost) {
    actions.showToast('Bạn không đủ Xu CT để đổi mục này');
    return;
  }
  if (!addresses.value.length) {
    try {
      addresses.value = await fetchAddresses();
    } catch (e) {
      addresses.value = [];
    }
  }
  if (!addresses.value.length) {
    actions.showToast('Vui lòng thêm địa chỉ giao hàng trong Quản lý tài khoản trước');
    return;
  }
  giftPickerItem.value = item;
  giftAddressId.value = addresses.value.find((a) => a.isDefault)?.id || addresses.value[0].id;
}

async function confirmRedeemGift() {
  const item = giftPickerItem.value;
  redeemingId.value = item.id;
  try {
    const result = await redeemGift(item.id, giftAddressId.value);
    const wallet = await fetchWallet();
    giftPickerItem.value = null;

    coinFlyId.value = item.id;
    setTimeout(() => {
      coinFlyId.value = null;
      redeemingId.value = null;
      animateBalance(wallet.balance, () => {
        actions.showToast(`Đổi quà thành công! Đơn ${result.orderCode} sẽ sớm được giao.`);
      });
    }, 500);
  } catch (e) {
    actions.showToast(e?.message && !e.message.startsWith('HTTP') ? e.message : 'Đổi quà thất bại');
    redeemingId.value = null;
  }
}

function copyCouponCode() {
  navigator.clipboard?.writeText(couponResult.value.code);
  actions.showToast('Đã sao chép mã giảm giá');
}

onMounted(() => {
  loadAll();
  // Tách riêng khỏi loadAll: flash sale là endpoint công khai, không được để lỗi/đang tải của
  // phần đổi thưởng (yêu cầu đăng nhập) chặn mất tab sale.
  loadFlashSale();
  tickTimer = setInterval(() => (nowTick.value = Date.now()), 1000);
});
onUnmounted(() => clearInterval(tickTimer));
</script>

<template>
  <main style="max-width: 1100px; margin: 0 auto; padding: 24px 24px 64px">
    <div style="font-family: 'Chakra Petch', sans-serif; font-size: 11px; letter-spacing: 2.5px; color: var(--acc,#c6ff4a); font-weight: 600; margin-bottom: 12px">
      TRANG KHUYẾN MÃI
    </div>
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; flex-wrap: wrap; gap: 12px">
      <h1 style="font-family: 'Plus Jakarta Sans', sans-serif; font-weight: 800; font-size: 34px; margin: 0; color: var(--text)">
        Đổi thưởng &amp; Điểm danh
      </h1>
      <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 12px; padding: 10px 18px; display: flex; align-items: center; gap: 10px">
        <span style="font-size: 20px">🪙</span>
        <div>
          <div style="font-size: 17px; font-weight: 700; color: #c7ccd6">{{ xuBalance }}</div>
          <div style="font-size: 10.5px; color: var(--muted2)">Xu CT hiện có</div>
        </div>
      </div>
    </div>

    <!-- Hai tab kiểu tab trình duyệt: tab đang chọn liền mạch với khung nội dung bên dưới -->
    <div class="pv-tabs">
      <button
        class="pv-tab no-auto-hover" :class="{ 'is-active': activeTab === 'doi-thuong' }"
        @click="activeTab = 'doi-thuong'"
      >
        🎁 Đổi thưởng &amp; Điểm danh
      </button>
      <button
        class="pv-tab no-auto-hover" :class="{ 'is-active': activeTab === 'sale' }"
        @click="activeTab = 'sale'"
      >
        ⚡ Flash Sale
        <span v-if="saleAdmin && saleAdmin.coThayDoiChuaPublic" class="pv-tab-dot" title="Có thay đổi chưa đăng"></span>
      </button>
    </div>

    <!-- ==================== TAB FLASH SALE ==================== -->
    <div v-if="activeTab === 'sale'" class="pv-panel">
      <FlashSaleEditor v-if="laAdmin" />

      <template v-else>
        <FlashSaleBanner v-if="saleCongKhai" :sale="saleCongKhai" />
        <div v-else class="pv-empty">
          <div style="font-size: 34px; margin-bottom: 10px">⚡</div>
          <div style="font-size: 14.5px; color: var(--text); font-weight: 600; margin-bottom: 4px">
            Hiện chưa có đợt Flash Sale nào
          </div>
          <div style="font-size: 12.5px; color: var(--muted2)">
            Theo dõi trang này để không bỏ lỡ đợt giảm giá kế tiếp.
          </div>
        </div>
      </template>
    </div>

    <!-- ==================== TAB ĐỔI THƯỞNG (nội dung sẵn có) ==================== -->
    <div v-show="activeTab === 'doi-thuong'">
    <div v-if="!state.user" style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 60px 20px; text-align: center; color: var(--muted)">
      <div style="font-size: 14px; color: var(--muted2); margin-bottom: 14px">Bạn cần đăng nhập để xem trang này.</div>
      <button @click="actions.openLogin" :style="{ background: accent }" style="height: 42px; padding: 0 22px; border: none; border-radius: 10px; color: var(--acc-ink); font-weight: 700; font-size: 13.5px; cursor: pointer">Đăng nhập</button>
    </div>

    <div v-else-if="loading" style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 60px; text-align: center; color: var(--muted)">
      Đang tải...
    </div>

    <div v-else-if="loadError || !checkinStatus" style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 60px 20px; text-align: center; color: var(--muted)">
      <div style="font-size: 14px; color: var(--muted2); margin-bottom: 14px">{{ loadError || 'Không tải được trang khuyến mãi.' }}</div>
      <button @click="loadAll" :style="{ background: accent }" style="height: 42px; padding: 0 22px; border: none; border-radius: 10px; color: var(--acc-ink); font-weight: 700; font-size: 13.5px; cursor: pointer">Thử lại</button>
    </div>

    <template v-else>
      <!-- Điểm danh -->
      <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 22px; margin-bottom: 24px">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; flex-wrap: wrap; gap: 10px">
          <div style="font-size: 15px; font-weight: 700; color: var(--text)">📅 Điểm danh nhận thưởng</div>
          <div style="position: relative">
            <button
              @click="onCheckin" :disabled="checkinStatus.checkedInToday || checkinLoading"
              :style="{ background: checkinStatus.checkedInToday ? 'var(--card2)' : accent, opacity: checkinLoading ? 0.7 : 1 }"
              style="height: 40px; padding: 0 20px; border: none; border-radius: 10px; font-weight: 700; font-size: 13px; cursor: pointer"
            >
              <span :style="{ color: checkinStatus.checkedInToday ? 'var(--muted)' : 'var(--acc-ink)' }">
                {{ checkinStatus.checkedInToday ? '✓ Đã điểm danh hôm nay' : (checkinLoading ? 'Đang xử lý...' : `Điểm danh (+${checkinStatus.nextRewardSilver} xu)`) }}
              </span>
            </button>
            <span v-if="checkinCoinFly" class="pv-ck-coin">🪙</span>
          </div>
        </div>
        <div style="display: grid; grid-template-columns: repeat(7, 1fr); gap: 8px">
          <div
            v-for="(reward, idx) in checkinStatus.weekRewards" :key="idx"
            class="pv-day"
            :class="['pv-' + dayState(idx), { 'pv-day-pop': popDayIdx === idx + 1 }]"
          >
            <!-- Ngày kế tiếp (đã điểm danh hôm nay rồi): khung sáng, nội dung mờ, đếm ngược phía trên -->
            <div v-if="dayState(idx) === 'next'" class="pv-count">{{ countdown }}</div>
            <div :class="{ 'pv-blur': dayState(idx) === 'next' }">
              <div style="font-size: 10.5px; color: var(--muted2); margin-bottom: 4px">
                Ngày {{ idx + 1 }}
                <span v-if="dayState(idx) === 'done'" style="color: var(--green)">✓</span>
              </div>
              <div style="font-size: 13px; font-weight: 700; color: #c7ccd6">+{{ reward }}</div>
            </div>
          </div>
        </div>
        <div style="font-size: 11.5px; color: var(--muted); margin-top: 10px">
          Chuỗi điểm danh hiện tại: {{ checkinStatus.checkedInToday ? checkinStatus.currentStreak : checkinStatus.currentStreak - 1 < 0 ? 0 : checkinStatus.currentStreak - 1 }} ngày liên tiếp. Bỏ lỡ 1 ngày sẽ reset về ngày 1.
        </div>
      </div>

      <!-- Đổi coupon -->
      <div style="margin-bottom: 24px">
        <div style="font-size: 15px; font-weight: 700; color: var(--text); margin-bottom: 14px">🎟️ Đổi mã giảm giá</div>
        <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 14px">
          <div
            v-for="item in coupons" :key="item.id"
            style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 18px; display: flex; flex-direction: column; gap: 10px"
          >
            <div :style="{ color: accent }" style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 26px">
              -{{ item.discountType === 'percent' ? item.discountValue + '%' : fmt(item.discountValue) }}
            </div>
            <div style="font-size: 12px; color: var(--muted2)">Đơn tối thiểu {{ fmt(item.minOrder) }}</div>
            <div style="position: relative; margin-top: auto">
              <button
                @click="onRedeemCoupon(item)" :disabled="redeemingId === item.id || xuBalance < item.silverCost"
                :style="{ background: xuBalance < item.silverCost ? 'var(--card2)' : accent, opacity: redeemingId === item.id ? 0.7 : 1 }"
                style="width: 100%; height: 38px; border: none; border-radius: 9px; font-weight: 700; font-size: 12.5px; cursor: pointer"
              >
                <span :style="{ color: xuBalance < item.silverCost ? 'var(--muted)' : 'var(--acc-ink)' }">
                  🪙 {{ item.silverCost }} Xu CT
                </span>
              </button>
              <span v-if="coinFlyId === item.id" class="pv-rd-coin">🪙</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Đổi quà -->
      <div>
        <div style="font-size: 15px; font-weight: 700; color: var(--text); margin-bottom: 14px">🎁 Đổi quà vật lý</div>
        <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 14px">
          <div
            v-for="item in gifts" :key="item.id"
            style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 18px; display: flex; flex-direction: column; gap: 10px"
          >
            <div style="aspect-ratio: 4/3; border-radius: 10px; background: var(--card2); display: flex; align-items: center; justify-content: center; overflow: hidden">
              <img v-if="item.giftImageUrl" :src="resolveImageUrl(item.giftImageUrl)" style="width: 100%; height: 100%; object-fit: cover" />
              <span v-else style="font-size: 28px">🎁</span>
            </div>
            <div style="font-size: 13px; font-weight: 600; color: var(--text); line-height: 1.4">{{ item.name }}</div>
            <div v-if="item.giftPrice" style="font-size: 11.5px; color: var(--muted); text-decoration: line-through">{{ fmt(item.giftPrice) }}</div>
            <div style="position: relative; margin-top: auto">
              <button
                @click="openGiftPicker(item)" :disabled="xuBalance < item.silverCost"
                :style="{ background: xuBalance < item.silverCost ? 'var(--card2)' : accent }"
                style="width: 100%; height: 38px; border: none; border-radius: 9px; font-weight: 700; font-size: 12.5px; cursor: pointer"
              >
                <span :style="{ color: xuBalance < item.silverCost ? 'var(--muted)' : 'var(--acc-ink)' }">
                  🪙 {{ item.silverCost }} Xu CT
                </span>
              </button>
              <span v-if="coinFlyId === item.id" class="pv-rd-coin">🪙</span>
            </div>
          </div>
        </div>
      </div>
    </template>

    <!-- Modal chọn địa chỉ khi đổi quà -->
    <div v-if="giftPickerItem" style="position: fixed; inset: 0; background: rgba(0,0,0,0.6); display: flex; align-items: center; justify-content: center; z-index: 200; padding: 20px">
      <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.18); border-radius: 16px; padding: 26px; max-width: 420px; width: 100%">
        <div style="font-size: 15px; font-weight: 700; color: var(--text); margin-bottom: 6px">Chọn địa chỉ giao quà</div>
        <div style="font-size: 12.5px; color: var(--muted2); margin-bottom: 16px">{{ giftPickerItem.name }} — 🪙 {{ giftPickerItem.silverCost }} Xu CT</div>
        <div style="display: flex; flex-direction: column; gap: 8px; margin-bottom: 18px; max-height: 260px; overflow-y: auto">
          <div
            v-for="a in addresses" :key="a.id"
            @click="giftAddressId = a.id"
            style="padding: 12px; border-radius: 10px; cursor: pointer; font-size: 12.5px"
            :style="{ border: '1px solid ' + (giftAddressId === a.id ? accent : 'rgba(var(--line-rgb),0.16)'), background: giftAddressId === a.id ? 'color-mix(in srgb, ' + accent + ' 6%, transparent)' : 'transparent' }"
          >
            <strong style="color: var(--text)">{{ a.tenNguoiNhan }}</strong> — {{ a.soDienThoai }}
            <div style="color: var(--muted2); margin-top: 3px">{{ a.diaChiDayDu }}</div>
          </div>
        </div>
        <div style="display: flex; gap: 10px">
          <button
            @click="confirmRedeemGift" :disabled="redeemingId === giftPickerItem.id"
            :style="{ background: accent, opacity: redeemingId === giftPickerItem.id ? 0.7 : 1 }"
            style="flex: 1; height: 42px; border: none; border-radius: 10px; color: var(--acc-ink); font-weight: 700; font-size: 13px; cursor: pointer"
          >
            {{ redeemingId === giftPickerItem.id ? 'Đang xử lý...' : 'Xác nhận đổi quà' }}
          </button>
          <button
            @click="giftPickerItem = null"
            style="height: 42px; padding: 0 18px; border: 1px solid rgba(var(--line-rgb),0.22); background: transparent; border-radius: 10px; color: var(--muted2); font-size: 13px; cursor: pointer"
          >
            Hủy
          </button>
        </div>
      </div>
    </div>

    <!-- Modal kết quả đổi coupon -->
    <div v-if="couponResult" style="position: fixed; inset: 0; background: rgba(0,0,0,0.6); display: flex; align-items: center; justify-content: center; z-index: 200; padding: 20px">
      <div class="pv-rd-modal" style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.18); border-radius: 16px; padding: 26px; max-width: 380px; width: 100%; text-align: center; position: relative; overflow: visible">
        <span v-for="p in confetti" :key="p.id" class="pv-confetti" :style="p.style"></span>

        <div style="font-size: 32px; margin-bottom: 10px">🎉</div>
        <div style="font-size: 15px; font-weight: 700; color: var(--text); margin-bottom: 6px">Đổi thưởng thành công!</div>
        <div style="font-size: 12.5px; color: var(--muted2); margin-bottom: 16px">{{ couponResult.name }}</div>
        <div
          @click="copyCouponCode"
          class="pv-rd-code"
          :style="{ borderColor: accent, color: accent }"
          style="border: 1px dashed; border-radius: 10px; padding: 12px; font-family: 'Chakra Petch', monospace; font-size: 18px; font-weight: 700; letter-spacing: 2px; cursor: pointer; margin-bottom: 16px"
        >
          {{ couponResult.code }}
        </div>
        <div style="font-size: 11.5px; color: var(--muted); margin-bottom: 16px">Nhấn vào mã để sao chép. Áp dụng mã này ở trang thanh toán.</div>
        <button
          @click="couponResult = null"
          :style="{ background: accent }"
          style="width: 100%; height: 42px; border: none; border-radius: 10px; color: var(--acc-ink); font-weight: 700; font-size: 13px; cursor: pointer"
        >
          Đóng
        </button>
      </div>
    </div>
    </div>
  </main>
</template>

<style scoped>
/* Tab kiểu trình duyệt: tab đang chọn cao hơn, bo góc trên và "dính" vào khung nội dung bên
   dưới bằng cách đè lên đường viền của khung (margin-bottom âm). */
.pv-tabs {
  display: flex;
  align-items: flex-end;
  gap: 4px;
  margin-bottom: -1px;
  position: relative;
  z-index: 1;
  overflow-x: auto;
}
.pv-tab {
  position: relative;
  display: inline-flex;
  align-items: center;
  gap: 7px;
  border: 1px solid rgba(var(--line-rgb), 0.14);
  border-bottom-color: transparent;
  background: var(--card2);
  color: var(--muted2);
  font-family: 'Plus Jakarta Sans', sans-serif;
  font-size: 13px;
  font-weight: 600;
  padding: 10px 20px;
  border-radius: 12px 12px 0 0;
  cursor: pointer;
  white-space: nowrap;
  transition: background 0.15s ease, color 0.15s ease, padding 0.15s ease;
}
.pv-tab:hover {
  color: var(--text);
}
.pv-tab.is-active {
  background: var(--card);
  color: var(--text);
  padding-top: 13px;
}
/* Chấm báo admin còn thay đổi chưa đăng */
.pv-tab-dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: #ff9500;
  flex: none;
}

.pv-panel {
  background: var(--card);
  border: 1px solid rgba(var(--line-rgb), 0.14);
  border-radius: 0 14px 14px 14px;
  padding: 22px;
}
.pv-empty {
  text-align: center;
  padding: 50px 20px;
}
</style>

<style scoped>

.pv-rd-coin {
  position: absolute;
  left: 50%;
  top: 4px;
  font-size: 16px;
  pointer-events: none;
  --rd-mx: -20px;
  --rd-my: -90px;
  animation: rd-coin-fly 500ms ease-in forwards;
}
.pv-ck-coin {
  position: absolute;
  right: 14px;
  top: -4px;
  font-size: 18px;
  pointer-events: none;
  animation: ck-coin-fly 620ms ease forwards;
}
.pv-day {
  position: relative;
  border-radius: 10px;
  padding: 12px 6px;
  text-align: center;
  border: 1px solid rgba(var(--line-rgb), 0.14);
  background: var(--card2);
  overflow: hidden;
  transition: background 0.2s ease, border-color 0.2s ease;
}
/* Đã điểm danh: viền xanh theme NHẠT (đánh dấu ngày đã xong). */
.pv-done {
  border-color: color-mix(in srgb, var(--green) 45%, transparent);
  background: color-mix(in srgb, var(--green) 8%, var(--card2));
}
/* Ngày bấm điểm danh hôm nay (chưa điểm danh): khung xanh RÕ. */
.pv-today {
  border-color: var(--acc, #c6ff4a);
  background: color-mix(in srgb, var(--acc, #c6ff4a) 14%, transparent);
}
/* Ngày kế tiếp sau khi đã điểm danh: khung xanh rõ, nội dung mờ, có đếm ngược. */
.pv-next {
  border-color: var(--acc, #c6ff4a);
  background: color-mix(in srgb, var(--acc, #c6ff4a) 10%, transparent);
}
.pv-blur {
  filter: blur(3px);
  opacity: 0.5;
}
.pv-count {
  position: absolute;
  inset: 0;
  z-index: 2;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Chakra Petch', monospace;
  font-weight: 700;
  font-size: 12.5px;
  letter-spacing: 0.5px;
  color: var(--acc, #c6ff4a);
  pointer-events: none;
}
.pv-day-pop {
  animation: ck-day-pop 500ms ease, ck-ring 700ms ease-out;
}
.pv-rd-modal {
  animation: rd-modal-in 0.35s cubic-bezier(0.2, 1.4, 0.4, 1) both;
}
.pv-rd-code {
  animation: rd-code-in 0.4s ease 0.15s both;
}
.pv-confetti {
  position: absolute;
  top: 50%;
  width: 6px;
  height: 10px;
  border-radius: 1px;
  animation: rd-confetti 900ms ease-out forwards;
}

@keyframes rd-coin-fly {
  0%   { transform: translate(-50%, 0) scale(1) rotate(0deg); opacity: 1; }
  50%  { transform: translate(calc(-50% + var(--rd-mx)), var(--rd-my)) scale(1.1) rotate(220deg); opacity: 1; }
  100% { transform: translate(calc(-50% + var(--rd-mx) * 2), calc(var(--rd-my) * 2)) scale(0.4) rotate(400deg); opacity: 0; }
}
@keyframes ck-coin-fly {
  0%   { transform: translate(0,0) scale(1) rotate(0deg); opacity: 1; }
  55%  { transform: translate(-26px,-70px) scale(1.15) rotate(160deg); opacity: 1; }
  100% { transform: translate(-58px,-146px) scale(0.5) rotate(320deg); opacity: 0; }
}
@keyframes ck-day-pop {
  0%   { transform: scale(1); }
  35%  { transform: scale(1.14); }
  60%  { transform: scale(0.96); }
  100% { transform: scale(1); }
}
@keyframes ck-ring {
  0%   { box-shadow: 0 0 0 0 rgba(0,229,255,0.5); }
  100% { box-shadow: 0 0 0 14px rgba(0,229,255,0); }
}
@keyframes rd-modal-in {
  0%   { opacity: 0; transform: scale(0.85) translateY(10px); }
  100% { opacity: 1; transform: scale(1) translateY(0); }
}
@keyframes rd-code-in {
  0%   { opacity: 0; transform: scale(0.8); }
  60%  { opacity: 1; transform: scale(1.06); }
  100% { opacity: 1; transform: scale(1); }
}
@keyframes rd-confetti {
  0%   { transform: translate(0,0) rotate(0deg); opacity: 1; }
  100% { transform: translate(var(--cx), var(--cy)) rotate(var(--cr)); opacity: 0; }
}
</style>
