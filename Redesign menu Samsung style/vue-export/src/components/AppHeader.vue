<script setup>
import { ref, computed, onMounted } from 'vue';

/* =========================================================================
   Thanh menu redesign (kiểu Samsung) cho CNTTshop.
   - Top bar: logo, tìm kiếm, đổi màu accent, sáng/tối, chuông, giỏ hàng,
     tài khoản + nút Hỗ trợ (mở panel hỗ trợ).
   - Nav: mega-menu full-width dạng lưới thẻ ảnh + cột "Khám phá".
   Dữ liệu để tĩnh trong file cho dễ xem; khi ghép vào dự án thật hãy nối
   navItems/MENUS với catMeta + actions.goCat(...) trong store của bạn.
   ========================================================================= */

const NAV = [
  { key: 'home', label: 'Trang chủ' },
  { key: 'components', label: 'Linh kiện máy tính', icon: 'bi-cpu', mega: true },
  { key: 'laptop', label: 'Laptop', icon: 'bi-laptop', mega: true },
  { key: 'pc', label: 'PC - Máy tính bàn', icon: 'bi-pc-display-horizontal', mega: true },
  { key: 'screen', label: 'Màn hình', icon: 'bi-display', mega: true },
  { key: 'peripheral', label: 'Thiết bị ngoại vi', icon: 'bi-keyboard', mega: true },
  { key: 'accessory', label: 'Phụ kiện', icon: 'bi-bag', mega: true },
  { key: 'pcbuild', label: 'Xây dựng cấu hình', icon: 'bi-tools' },
  { key: 'compare', label: 'So sánh', icon: 'bi-layout-split' },
  { key: 'contact', label: 'Liên hệ', icon: 'bi-chat-dots' },
  { key: 'promo', label: 'Khuyến mãi', icon: 'bi-gift' },
];

const MENUS = {
  components: {
    label: 'Linh kiện máy tính',
    icon: 'bi-cpu',
    items: [
      { label: 'CPU - Bộ vi xử lý', icon: 'bi-cpu' },
      { label: 'Mainboard', icon: 'bi-motherboard' },
      { label: 'RAM', icon: 'bi-memory' },
      { label: 'Card màn hình (VGA)', icon: 'bi-gpu-card' },
      { label: 'Ổ cứng SSD', icon: 'bi-device-ssd' },
      { label: 'Ổ cứng HDD', icon: 'bi-hdd' },
      { label: 'Nguồn (PSU)', icon: 'bi-lightning-charge' },
      { label: 'Vỏ máy tính (Case)', icon: 'bi-pc-display' },
      { label: 'Tản nhiệt CPU', icon: 'bi-wind' },
    ],
    explore: [
      'Tự xây dựng cấu hình PC',
      'Kiểm tra tương thích linh kiện',
      'Linh kiện bán chạy',
      'Tư vấn nâng cấp máy',
      'Hàng chính hãng 100%',
      'Trả góp 0%',
    ],
  },
  laptop: {
    label: 'Laptop',
    icon: 'bi-laptop',
    items: [
      { label: 'Laptop Gaming', icon: 'bi-joystick' },
      { label: 'Laptop Văn phòng', icon: 'bi-briefcase' },
      { label: 'Laptop Mỏng nhẹ', icon: 'bi-feather' },
      { label: 'Laptop Đồ họa', icon: 'bi-palette' },
      { label: 'Laptop AI', icon: 'bi-cpu' },
    ],
    explore: [
      'Tại sao chọn Laptop Gaming',
      'Laptop cho sinh viên',
      'Laptop cho dân văn phòng',
      'So sánh laptop',
      'Laptop bán chạy',
      'Trả góp 0%',
    ],
  },
  pc: {
    label: 'PC - Máy tính bàn',
    icon: 'bi-pc-display-horizontal',
    items: [
      { label: 'PC Gaming', icon: 'bi-joystick' },
      { label: 'PC Văn phòng', icon: 'bi-briefcase' },
      { label: 'PC Đồ họa - Studio', icon: 'bi-palette' },
      { label: 'PC Full - Kèm màn hình', icon: 'bi-box-seam' },
      { label: 'PC Ảo hóa - Giả lập', icon: 'bi-hdd-stack' },
      { label: 'PC Workstation', icon: 'bi-diagram-3' },
      { label: 'PC Mini - Gọn nhẹ', icon: 'bi-box' },
    ],
    explore: [
      'Tự build PC theo ý bạn',
      'PC dựng sẵn bán chạy',
      'Tư vấn cấu hình miễn phí',
      'PC theo ngân sách',
      'So sánh cấu hình',
      'Trả góp 0%',
    ],
  },
  screen: {
    label: 'Màn hình',
    icon: 'bi-display',
    items: [
      { label: 'Màn hình Văn phòng', icon: 'bi-window' },
      { label: 'Màn hình Gaming', icon: 'bi-joystick' },
      { label: 'Màn hình Ultrawide', icon: 'bi-aspect-ratio' },
      { label: 'Màn hình Đồ họa', icon: 'bi-palette' },
    ],
    explore: [
      'Chọn màn hình chơi game',
      'Màn hình cho đồ họa',
      'Tần số quét là gì?',
      'Kích thước & độ phân giải',
      'Màn hình bán chạy',
    ],
  },
  peripheral: {
    label: 'Thiết bị ngoại vi',
    icon: 'bi-keyboard',
    items: [
      { label: 'Bàn phím', icon: 'bi-keyboard' },
      { label: 'Chuột', icon: 'bi-mouse2' },
      { label: 'Tai nghe', icon: 'bi-headset' },
      { label: 'Webcam & Loa', icon: 'bi-camera-video' },
    ],
    explore: [
      'Combo phím & chuột',
      'Bàn phím cơ',
      'Chuột gaming',
      'Tai nghe bán chạy',
      'Setup góc làm việc',
    ],
  },
  accessory: {
    label: 'Phụ kiện',
    icon: 'bi-bag',
    items: [
      { label: 'Bảo vệ & mang theo', icon: 'bi-backpack' },
      { label: 'Sạc & kết nối', icon: 'bi-plug' },
      { label: 'Âm thanh & chuột', icon: 'bi-headphones' },
    ],
    explore: [
      'Phụ kiện bán chạy',
      'Quà tặng kèm',
      'Balo & túi laptop',
      'Hub & cáp chuyển',
      'Giá đỡ & phụ kiện bàn',
    ],
  },
};

const SUPPORT = {
  columns: [
    {
      title: 'Hỗ trợ sản phẩm',
      items: ['Trang chủ Hỗ Trợ', 'Hướng dẫn sử dụng & Software', 'Tìm kiếm', 'FAQ Hỗ trợ mua trực tuyến'],
    },
    {
      title: 'Dịch vụ bảo hành và sửa chữa',
      items: ['Thông tin Bảo hành', 'Bảng giá linh kiện', 'Tìm Trung Tâm Bảo Hành', 'Tình Trạng Sửa Chữa'],
    },
    {
      title: 'Liên hệ',
      items: ['Tư Vấn Trực Tuyến', 'Gọi Điện Thoại', 'Gửi Email', 'Ngôn Ngữ Ký Hiệu'],
    },
    {
      title: 'Tìm thêm thông tin',
      items: ['Tin Tức & Cảnh Báo', 'Dịch Vụ Sửa Chữa Tiết Kiệm', 'Gói sửa chữa màn hình'],
    },
  ],
  tiles: [
    { label: 'Thông tin Bảo Hành', icon: 'bi-shield-check' },
    { label: 'Hướng dẫn sử dụng', icon: 'bi-download' },
    { label: 'Trung tâm bảo hành', icon: 'bi-tools' },
    { label: 'Liên Hệ', icon: 'bi-headset' },
  ],
};

const ACCENTS = {
  dark: { cyan: ['#c6ff4a', '#101114'], magenta: ['#ff45e0', '#101114'] },
  light: { cyan: ['#4d7a1a', '#ffffff'], magenta: ['#c2185b', '#ffffff'] },
};

const open = ref(null);
const active = ref('home');
const support = ref(false);
const mode = ref('dark');
const themeKey = ref('cyan');

const activeMenu = computed(() => (open.value ? MENUS[open.value] : null));
const modeIcon = computed(() => (mode.value === 'light' ? '🌙' : '☀️'));

function applyTheme() {
  const [acc, ink] = ACCENTS[mode.value][themeKey.value];
  const r = document.documentElement;
  r.setAttribute('data-mode', mode.value);
  r.style.setProperty('--acc', acc);
  r.style.setProperty('--acc-ink', ink);
}
onMounted(applyTheme);

function onEnter(item) {
  if (item.mega) {
    open.value = item.key;
    support.value = false;
  } else {
    open.value = null;
  }
}
function closeMenu() {
  open.value = null;
}
function clickNav(item) {
  active.value = item.key;
  open.value = null;
}
function toggleSupport() {
  support.value = !support.value;
  open.value = null;
}
function closeSupport() {
  support.value = false;
}
function toggleMode() {
  mode.value = mode.value === 'light' ? 'dark' : 'light';
  applyTheme();
}
function setAccent(k) {
  themeKey.value = k;
  applyTheme();
}
function noop() {}
</script>

<template>
  <header
    style="
      position: sticky;
      top: 0;
      z-index: 50;
      backdrop-filter: blur(14px);
      background: color-mix(in srgb, var(--page) 84%, transparent);
      border-bottom: 1px solid rgba(var(--line-rgb), 0.14);
    "
  >
    <!-- ===== Utility bar ===== -->
    <div style="max-width: 1800px; margin: 0 auto; padding: 14px 24px; display: flex; align-items: center; gap: 22px">
      <div @click="noop" style="display: flex; align-items: center; gap: 11px; cursor: pointer; flex: none">
        <svg width="36" height="28" viewBox="0 0 116 90" style="flex: none; display: block">
          <rect x="18" y="76" width="26" height="6" rx="3" fill="var(--text)" />
          <rect x="27" y="48" width="8" height="28" fill="var(--text)" />
          <rect x="4" y="8" width="56" height="40" rx="7" fill="var(--text)" />
          <rect x="9" y="13" width="46" height="30" rx="3" fill="var(--acc)" opacity="0.2" />
          <rect x="76" y="78" width="6" height="4" rx="1" fill="var(--text)" />
          <rect x="94" y="78" width="6" height="4" rx="1" fill="var(--text)" />
          <rect x="72" y="8" width="36" height="70" rx="9" fill="var(--text)" />
          <rect x="72" y="22" width="36" height="2.5" fill="var(--page)" />
          <circle cx="90" cy="15" r="3.2" fill="var(--acc)" />
          <rect x="80" y="48" width="20" height="2" rx="1" fill="var(--page)" opacity="0.45" />
          <rect x="80" y="55" width="20" height="2" rx="1" fill="var(--page)" opacity="0.45" />
          <rect x="80" y="62" width="20" height="2" rx="1" fill="var(--page)" opacity="0.45" />
        </svg>
        <div style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 20px; letter-spacing: 0.5px; line-height: 1">
          CNTT<span style="color: var(--acc)">shop</span>
        </div>
      </div>
      <div
        style="
          flex: 1;
          max-width: 520px;
          display: flex;
          align-items: center;
          gap: 9px;
          background: var(--card);
          border: 1px solid rgba(var(--line-rgb), 0.18);
          border-radius: 11px;
          padding: 0 14px;
          height: 42px;
        "
      >
        <span style="color: var(--muted); font-size: 15px">⌕</span>
        <input
          placeholder="Tìm laptop, PC, RTX 4070, CPU..."
          style="flex: 1; background: transparent; border: none; color: var(--text); font-size: 13.5px; font-family: 'Plus Jakarta Sans', sans-serif"
        />
      </div>
      <div style="flex: 1"></div>
      <div style="display: flex; align-items: center; gap: 6px; flex: none; padding: 0 4px">
        <button
          @click="setAccent('cyan')"
          title="Lime"
          style="width: 16px; height: 16px; border-radius: 50%; border: 1px solid rgba(255, 255, 255, 0.25); background: #c6ff4a; cursor: pointer; padding: 0"
        ></button>
        <button
          @click="setAccent('magenta')"
          title="Magenta"
          style="width: 16px; height: 16px; border-radius: 50%; border: 1px solid rgba(255, 255, 255, 0.25); background: #ff45e0; cursor: pointer; padding: 0"
        ></button>
      </div>
      <button
        @click="toggleMode"
        title="Đổi giao diện sáng / tối"
        class="hbtn"
        style="flex: none; width: 42px; height: 42px; border-radius: 11px; border: 1px solid rgba(var(--line-rgb), 0.2); background: var(--card); color: var(--text); cursor: pointer; font-size: 18px; line-height: 1; display: flex; align-items: center; justify-content: center"
      >
        {{ modeIcon }}
      </button>
      <button
        @click="noop"
        title="Thông báo"
        class="hbtn"
        style="position: relative; flex: none; width: 42px; height: 42px; border-radius: 11px; border: 1px solid rgba(var(--line-rgb), 0.2); background: var(--card); color: var(--text); cursor: pointer; font-size: 17px; line-height: 1; display: flex; align-items: center; justify-content: center"
      >
        <i class="bi bi-bell"></i>
        <span
          style="position: absolute; top: -6px; right: -6px; min-width: 18px; height: 18px; padding: 0 4px; border-radius: 9px; background: var(--acc); color: var(--acc-ink); font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 10px; display: flex; align-items: center; justify-content: center"
          >3</span
        >
      </button>
      <button
        @click="noop"
        class="hbtn"
        style="position: relative; flex: none; height: 42px; display: flex; align-items: center; gap: 9px; padding: 0 16px; border-radius: 11px; border: 1px solid rgba(var(--line-rgb), 0.2); background: color-mix(in srgb, var(--acc) 12%, var(--card)); color: var(--text); cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif; font-weight: 600; font-size: 13.5px"
      >
        <span style="font-size: 17px">🛒</span> Giỏ hàng
        <span
          style="position: absolute; top: -7px; right: -7px; min-width: 20px; height: 20px; padding: 0 5px; border-radius: 10px; background: var(--acc); color: var(--acc-ink); font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 11px; display: flex; align-items: center; justify-content: center"
          >2</span
        >
      </button>
      <div style="flex: none; display: flex; align-items: center; gap: 10px; color: var(--text); font-size: 13px">
        <span @click="noop" style="font-weight: 600; cursor: pointer">👤 Nguyễn An</span>
        <button
          @click="noop"
          class="hbtn"
          style="height: 34px; padding: 0 12px; border-radius: 9px; border: 1px solid rgba(var(--line-rgb), 0.2); background: transparent; color: var(--muted2); cursor: pointer; font-size: 12.5px"
        >
          📦 Đơn hàng
        </button>
        <button
          @click="toggleSupport"
          class="support-btn"
          style="display: flex; align-items: center; gap: 7px; height: 34px; padding: 0 12px; border-radius: 9px; border: 1px solid rgba(var(--line-rgb), 0.2); background: transparent; color: var(--muted2); cursor: pointer; font-size: 12.5px"
        >
          <i class="bi bi-headset" style="font-size: 14px"></i> Hỗ trợ
        </button>
        <button
          @click="noop"
          class="hbtn"
          style="height: 34px; padding: 0 12px; border-radius: 9px; border: 1px solid rgba(var(--line-rgb), 0.2); background: transparent; color: var(--sale); cursor: pointer; font-size: 12.5px"
        >
          Đăng xuất
        </button>
      </div>
    </div>

    <!-- ===== Nav + mega-menu (kiểu Samsung) ===== -->
    <div @mouseleave="closeMenu" style="position: relative; border-top: 1px solid rgba(var(--line-rgb), 0.08)">
      <nav style="max-width: 1800px; margin: 0 auto; padding: 0 24px; display: flex; align-items: stretch; gap: 2px">
        <div v-for="item in NAV" :key="item.key" @mouseenter="onEnter(item)" style="position: relative; display: flex">
          <div
            @click="clickNav(item)"
            class="nav-link"
            style="position: relative; display: flex; align-items: center; gap: 8px; padding: 20px 18px; cursor: pointer; white-space: nowrap; font-size: 15px; font-weight: 600; color: var(--muted2); transition: color 0.15s"
          >
            <i v-if="item.icon" :class="'bi ' + item.icon" style="font-size: 16px; opacity: 0.85"></i>
            <span>{{ item.label }}</span>
            <span v-if="item.mega" style="font-size: 10px; opacity: 0.6; margin-left: -2px">▾</span>
            <span
              v-if="active === item.key || open === item.key"
              style="position: absolute; left: 16px; right: 16px; bottom: 0; height: 3px; border-radius: 2px; background: var(--acc); box-shadow: 0 0 12px var(--acc)"
            ></span>
          </div>
        </div>
        <div style="flex: 1; min-width: 12px"></div>
        <div style="display: flex; align-items: center; gap: 8px; color: var(--sale); font-size: 13px; font-weight: 700; white-space: nowrap">
          <i class="bi bi-lightning-charge-fill" style="font-size: 15px"></i> Trả góp 0%
        </div>
      </nav>

      <div
        v-if="activeMenu"
        style="position: absolute; top: 100%; left: 0; right: 0; width: 100%; background: var(--card2); border-top: 1px solid rgba(var(--line-rgb), 0.1); box-shadow: 0 34px 60px -12px rgba(0, 0, 0, 0.55); z-index: 60; animation: megaIn 0.18s ease"
      >
        <div
          style="max-width: 1800px; margin: 0 auto; padding: 30px 24px 34px; display: grid; grid-template-columns: minmax(0, 1fr) 280px; gap: 44px; align-items: start"
        >
          <div style="display: grid; grid-template-columns: repeat(7, minmax(0, 1fr)); column-gap: 14px; row-gap: 24px; justify-items: center">
            <div
              v-for="it in activeMenu.items"
              :key="it.label"
              @click="noop"
              class="mega-tile"
              style="display: flex; flex-direction: column; align-items: center; gap: 10px; cursor: pointer; width: 100%; max-width: 112px; transition: transform 0.14s"
            >
              <div
                class="mega-thumb"
                style="width: 100%; aspect-ratio: 1 / 1; border-radius: 13px; display: flex; align-items: center; justify-content: center; background: repeating-linear-gradient(45deg, rgba(var(--line-rgb), 0.045) 0 8px, transparent 8px 16px), color-mix(in srgb, var(--acc) 8%, var(--card)); border: 1px solid rgba(var(--line-rgb), 0.1); transition: border-color 0.14s"
              >
                <i :class="'bi ' + it.icon" style="font-size: 32px; color: var(--acc); opacity: 0.9"></i>
              </div>
              <span style="font-size: 12.5px; font-weight: 600; color: var(--text); text-align: center; line-height: 1.25; text-wrap: pretty">{{ it.label }}</span>
            </div>
          </div>

          <div style="border-left: 1px solid rgba(var(--line-rgb), 0.12); padding-left: 32px">
            <div
              style="font-family: 'Chakra Petch', sans-serif; font-size: 11.5px; letter-spacing: 1.8px; font-weight: 700; color: var(--muted); text-transform: uppercase; margin-bottom: 16px"
            >
              Khám phá
            </div>
            <div style="display: flex; flex-direction: column; gap: 13px">
              <div
                v-for="e in activeMenu.explore"
                :key="e"
                @click="noop"
                class="explore-link"
                style="font-size: 13px; color: var(--muted2); cursor: pointer; line-height: 1.35; transition: color 0.12s"
              >
                {{ e }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ===== Panel Hỗ trợ ===== -->
    <template v-if="support">
      <div @click="closeSupport" style="position: fixed; inset: 0; z-index: 55"></div>
      <div
        style="position: absolute; top: 100%; left: 0; right: 0; width: 100%; background: var(--card2); border-top: 1px solid rgba(var(--line-rgb), 0.1); box-shadow: 0 34px 60px -12px rgba(0, 0, 0, 0.55); z-index: 60; animation: megaIn 0.18s ease"
      >
        <div
          style="max-width: 1800px; margin: 0 auto; padding: 40px 24px 44px; display: grid; grid-template-columns: minmax(0, 1fr) 440px; gap: 56px; align-items: start"
        >
          <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); column-gap: 48px; row-gap: 38px">
            <div v-for="c in SUPPORT.columns" :key="c.title">
              <div
                style="font-family: 'Chakra Petch', sans-serif; font-size: 11.5px; letter-spacing: 1.6px; font-weight: 700; color: var(--muted); text-transform: uppercase; margin-bottom: 16px"
              >
                {{ c.title }}
              </div>
              <div style="display: flex; flex-direction: column; gap: 13px">
                <div
                  v-for="e in c.items"
                  :key="e"
                  @click="noop"
                  class="explore-link"
                  style="font-size: 14px; color: var(--muted2); cursor: pointer; line-height: 1.35; transition: color 0.12s"
                >
                  {{ e }}
                </div>
              </div>
            </div>
          </div>

          <div
            style="border-left: 1px solid rgba(var(--line-rgb), 0.12); padding-left: 44px; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 16px"
          >
            <div
              v-for="t in SUPPORT.tiles"
              :key="t.label"
              @click="noop"
              class="support-tile"
              style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 14px; padding: 24px 12px; border-radius: 14px; background: var(--card); border: 1px solid rgba(var(--line-rgb), 0.1); cursor: pointer; transition: border-color 0.14s, transform 0.14s"
            >
              <i :class="'bi ' + t.icon" style="font-size: 34px; color: var(--acc); opacity: 0.9"></i>
              <span style="font-size: 13px; font-weight: 600; color: var(--text); text-align: center; line-height: 1.3; text-wrap: pretty">{{ t.label }}</span>
            </div>
          </div>
        </div>
      </div>
    </template>
  </header>
</template>

<style scoped>
.nav-link:hover {
  color: var(--text) !important;
}
.hbtn:hover {
  border-color: color-mix(in srgb, var(--acc) 45%, transparent) !important;
}
.support-btn:hover {
  color: var(--text) !important;
  border-color: color-mix(in srgb, var(--acc) 45%, transparent) !important;
}
.mega-tile:hover {
  transform: translateY(-3px);
}
.mega-tile:hover .mega-thumb {
  border-color: color-mix(in srgb, var(--acc) 55%, transparent);
}
.explore-link:hover {
  color: var(--acc) !important;
}
.support-tile:hover {
  border-color: color-mix(in srgb, var(--acc) 55%, transparent);
  transform: translateY(-3px);
}
</style>
