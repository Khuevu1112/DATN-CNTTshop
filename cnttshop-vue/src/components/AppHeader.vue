<script setup>
import { computed, ref, onMounted, onUnmounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import {
  catMeta,
  products,
  matchesQuery,
  CATEGORY_SEGMENTS,
  COMPONENT_GROUPS_DEF,
  COMPONENT_SLUGS,
} from '../data/products.js';
import { resolveImageUrl } from '../api.js';
import { state, actions, accent, cartCount } from '../store.js';
import AppLogo from './AppLogo.vue';

const route = useRoute();
const router = useRouter();

// Chỉ 1 lớp phủ mở tại 1 thời điểm: mega-menu danh mục HOẶC panel Hỗ trợ/Liên hệ.
const openMenu = ref(null);
const supportOpen = ref(false);
const headerEl = ref(null);

/** GHIM: rê chuột chỉ mở tạm (rời chuột là đóng), còn BẤM vào mục thì ghim menu lại — rời chuột
 * không đóng nữa, chỉ đóng khi bấm lại chính mục đó, bấm ra ngoài header, hoặc nhấn Esc. */
const pinned = ref(false);

function hoverMega(key) {
  supportOpen.value = false;
  openMenu.value = key;
}
/** Rời chuột khỏi vùng nav (hoặc rê qua mục không có mega) — đã ghim thì giữ nguyên. */
function leaveMega() {
  if (!pinned.value) openMenu.value = null;
}
function clickMega(m) {
  supportOpen.value = false;
  if (openMenu.value === m.key && pinned.value) {
    dongHet(); // bấm lại mục đang ghim -> bỏ ghim, đóng
  } else {
    openMenu.value = m.key;
    pinned.value = true;
  }
}
function dongHet() {
  pinned.value = false;
  openMenu.value = null;
  supportOpen.value = false;
}
function toggleSupport() {
  const mo = !supportOpen.value;
  dongHet();
  supportOpen.value = mo;
}

// Bấm ra ngoài header / nhấn Esc -> đóng cả mega-menu đang ghim lẫn panel Hỗ trợ. Dùng listener
// trên document thay cho lớp phủ toàn màn hình: lớp phủ sẽ che luôn thanh nav, khiến menu đang
// ghim không rê/bấm sang mục khác được.
function onDocClick(e) {
  if (headerEl.value && !headerEl.value.contains(e.target)) dongHet();
}
function onKeydown(e) {
  if (e.key === 'Escape') dongHet();
}
onMounted(() => {
  document.addEventListener('click', onDocClick);
  document.addEventListener('keydown', onKeydown);
});
onUnmounted(() => {
  document.removeEventListener('click', onDocClick);
  document.removeEventListener('keydown', onKeydown);
});

// ===== Chuông thông báo (giữ nguyên hành vi cũ) =====
const bellOpen = ref(false);
const loadingBell = ref(false);

async function toggleBell() {
  bellOpen.value = !bellOpen.value;
  if (bellOpen.value) {
    loadingBell.value = true;
    try {
      await actions.loadNotifications();
    } finally {
      loadingBell.value = false;
    }
  }
}
function onClickNotification(n) {
  actions.markNotificationRead(n);
  bellOpen.value = false;
  if (n.link) router.push(n.link);
}
function timeAgo(iso) {
  const diffMs = Date.now() - new Date(iso).getTime();
  const min = Math.floor(diffMs / 60000);
  if (min < 1) return 'vừa xong';
  if (min < 60) return min + ' phút trước';
  const hour = Math.floor(min / 60);
  if (hour < 24) return hour + ' giờ trước';
  return Math.floor(hour / 24) + ' ngày trước';
}

/** Ảnh đại diện cho 1 ô danh mục: lấy ảnh của sản phẩm ĐẦU TIÊN thuộc danh mục (và khớp phân
 * khúc nếu có) — thay cho ô placeholder gạch chéo trong bản thiết kế. Sản phẩm chưa có ảnh thì
 * trả null và ô sẽ rơi về icon như cũ, không để ô trống. */
function anhDaiDien(slug, keyword) {
  const p = products.find(
    (pr) => pr.cat === slug && pr.image && (!keyword || matchesQuery(pr, keyword)),
  );
  return p ? resolveImageUrl(p.image) : null;
}

// ===== Mega-menu "Linh kiện máy tính" — làm phẳng 9 danh mục con thành lưới ô ảnh =====
const componentTiles = computed(() =>
  COMPONENT_GROUPS_DEF.flatMap((g) => g.items)
    .filter((it) => catMeta[it.slug])
    .map((it) => ({
      label: catMeta[it.slug].vn,
      icon: it.icon,
      img: anhDaiDien(it.slug),
      onClick: () => actions.goCat(it.slug),
    })),
);
const componentMenuActive = computed(
  () => route.name === 'category' && COMPONENT_SLUGS.includes(route.params.cat),
);

// ===== Mega-menu theo phân khúc cho Laptop / PC / Màn hình / Ngoại vi / Phụ kiện =====
const categoryMegaMenus = computed(() =>
  CATEGORY_SEGMENTS.filter((def) => catMeta[def.slug])
    .map((def) => {
      const items = def.items
        .map((it) => ({
          label: it.label,
          icon: it.icon,
          count: products.filter((p) => p.cat === def.slug && matchesQuery(p, it.keyword)).length,
          img: anhDaiDien(def.slug, it.keyword),
          onClick: () => actions.goCat(def.slug, it.keyword),
        }))
        .filter((it) => it.count > 0);
      return {
        key: def.slug,
        label: catMeta[def.slug].vn,
        icon: def.icon,
        onClick: () => actions.goCat(def.slug),
        active: route.name === 'category' && route.params.cat === def.slug,
        items,
      };
    })
    .filter((m) => m.items.length),
);

/** Tất cả mục có mega-menu, theo thứ tự hiển thị trên nav. */
const megaMenus = computed(() => {
  const list = [];
  if (componentTiles.value.length) {
    list.push({
      key: 'components',
      label: 'Linh kiện máy tính',
      icon: 'bi-cpu',
      active: componentMenuActive.value,
      // Nhãn "Linh kiện máy tính" chỉ mở mega-menu, KHÔNG điều hướng — giữ đúng hành vi cũ
      // ('linh-kien' nằm trong HIDDEN_SLUGS, không phải trang danh mục thật).
      onClick: () => {},
      items: componentTiles.value,
    });
  }
  return list.concat(categoryMegaMenus.value);
});
const activeMenu = computed(() => megaMenus.value.find((m) => m.key === openMenu.value) || null);

/** Cột "Khám phá" theo từng mega-menu. Key = 'components' hoặc slug danh mục.
 * Mục có `go` là đã nối route thật; mục không có `go` là bài viết CHƯA CÓ TRANG — hiển thị mờ +
 * không bấm được, đúng kiểu các mục chờ bổ sung trong panel Hỗ trợ. Bổ sung sau chỉ cần thêm
 * `go:` vào đúng mục. */
const EXPLORE = {
  components: [
    { label: 'Tự xây dựng cấu hình PC', go: actions.goPcBuild },
    { label: 'Kiểm tra tương thích linh kiện' },
    { label: 'Linh kiện bán chạy' },
    { label: 'Tư vấn nâng cấp máy' },
    { label: 'Hàng chính hãng 100%' },
    { label: 'Trả góp 0%' },
  ],
  laptop: [
    { label: 'Tại sao chọn Laptop Gaming' },
    { label: 'Laptop cho sinh viên' },
    { label: 'Laptop cho dân văn phòng' },
    { label: 'So sánh laptop', go: actions.goCompare },
    { label: 'Laptop bán chạy' },
    { label: 'Trả góp 0%' },
  ],
  'pc-may-tinh-ban': [
    { label: 'Tự build PC theo ý bạn', go: actions.goPcBuild },
    { label: 'PC dựng sẵn bán chạy' },
    { label: 'Tư vấn cấu hình miễn phí' },
    { label: 'PC theo ngân sách' },
    { label: 'So sánh cấu hình', go: actions.goCompare },
    { label: 'Trả góp 0%' },
  ],
  'man-hinh': [
    { label: 'Chọn màn hình chơi game' },
    { label: 'Màn hình cho đồ họa' },
    { label: 'Tần số quét là gì?' },
    { label: 'Kích thước & độ phân giải' },
    { label: 'Màn hình bán chạy' },
  ],
  'ngoai-vi': [
    { label: 'Combo phím & chuột' },
    { label: 'Bàn phím cơ' },
    { label: 'Chuột gaming' },
    { label: 'Tai nghe bán chạy' },
    { label: 'Setup góc làm việc' },
  ],
  'phu-kien': [
    { label: 'Phụ kiện bán chạy' },
    { label: 'Quà tặng kèm' },
    { label: 'Balo & túi laptop' },
    { label: 'Hub & cáp chuyển' },
    { label: 'Giá đỡ & phụ kiện bàn' },
  ],
};
const exploreItems = computed(() => (activeMenu.value ? EXPLORE[activeMenu.value.key] || [] : []));

// ===== Các mục nav không có mega-menu =====
// "Liên hệ" đã gộp vào panel Hỗ trợ trên thanh trên cùng nên KHÔNG còn ở đây nữa.
const plainNavItems = computed(() => [
  { label: 'Xây dựng cấu hình', icon: 'bi-tools', onClick: actions.goPcBuild, active: route.name === 'pcbuild' },
  { label: 'So sánh', icon: 'bi-layout-split', onClick: actions.goCompare, active: route.name === 'compare' },
  { label: 'Khuyến mãi', icon: 'bi-gift', onClick: actions.goPromotions, active: route.name === 'promotions' },
]);

/* ===== Panel Hỗ trợ = "Liên hệ" (menu cũ) GỘP với "Bảo hành" (header cũ) =====
   Mục có `go` là đã nối được route thật; mục KHÔNG có `go` là trang chưa tồn tại trong dự án —
   để trống, hiện dạng mờ + không bấm được, chờ bổ sung. */
const SUPPORT_COLUMNS = computed(() => [
  {
    title: 'Hỗ trợ sản phẩm',
    items: [
      { label: 'Trang chủ Hỗ Trợ', go: actions.goContact },
      { label: 'Hướng dẫn sử dụng & Software' },
      { label: 'Tìm kiếm' },
      { label: 'FAQ Hỗ trợ mua trực tuyến' },
    ],
  },
  {
    title: 'Dịch vụ bảo hành và sửa chữa',
    items: [
      { label: 'Thông tin Bảo hành', go: actions.goWarranty },
      { label: 'Bảng giá linh kiện' },
      { label: 'Tìm Trung Tâm Bảo Hành' },
      { label: 'Tình Trạng Sửa Chữa', go: actions.goWarranty },
    ],
  },
  {
    title: 'Liên hệ',
    items: [
      { label: 'Tư Vấn Trực Tuyến', go: actions.goContact },
      { label: 'Gọi Điện Thoại' },
      { label: 'Gửi Email', go: actions.goContact },
      { label: 'Ngôn Ngữ Ký Hiệu' },
    ],
  },
  {
    title: 'Tìm thêm thông tin',
    items: [
      { label: 'Tin Tức & Cảnh Báo' },
      { label: 'Dịch Vụ Sửa Chữa Tiết Kiệm' },
      { label: 'Gói sửa chữa màn hình' },
    ],
  },
]);
const SUPPORT_TILES = computed(() => [
  { label: 'Thông tin Bảo Hành', icon: 'bi-shield-check', go: actions.goWarranty },
  { label: 'Hướng dẫn sử dụng', icon: 'bi-download' },
  { label: 'Trung tâm bảo hành', icon: 'bi-tools' },
  { label: 'Liên Hệ', icon: 'bi-headset', go: actions.goContact },
]);

/** Dùng chung cho mọi link trong mega-menu lẫn panel Hỗ trợ: chưa có route thì bấm không làm gì. */
function onMenuLinkClick(it) {
  if (!it.go) return; // chưa có trang -> không làm gì
  dongHet();
  it.go();
}

const modeIcon = computed(() => (state.mode === 'light' ? '🌙' : '☀️'));

function onSearchKey(e) {
  if (e.key === 'Enter') actions.onSearchEnter();
}
</script>

<template>
  <header
    ref="headerEl"
    style="
      position: sticky;
      top: 0;
      z-index: 50;
      backdrop-filter: blur(14px);
      background: color-mix(in srgb, var(--page) 84%, transparent);
      border-bottom: 1px solid rgba(var(--line-rgb), 0.14);
    "
  >
    <!-- ===== Thanh trên cùng ===== -->
    <div style="max-width: 1800px; margin: 0 auto; padding: 14px 24px; display: flex; align-items: center; gap: 22px">
      <div @click="actions.goHome" style="display: flex; align-items: center; gap: 11px; cursor: pointer; flex: none">
        <AppLogo :size="28" :on-light="state.mode === 'light'" :accent-color="accent" />
        <div style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 20px; letter-spacing: 0.5px; line-height: 1">
          CNTT<span :style="{ color: accent }">shop</span>
        </div>
      </div>

      <div
        style="flex: 1; max-width: 520px; display: flex; align-items: center; gap: 9px; background: var(--card); border: 1px solid rgba(var(--line-rgb), 0.18); border-radius: 11px; padding: 0 14px; height: 42px"
      >
        <span style="color: var(--muted); font-size: 15px">⌕</span>
        <input
          :value="state.q"
          @input="actions.setQ($event.target.value)"
          @keydown="onSearchKey"
          placeholder="Tìm laptop, PC, RTX 4070, CPU..."
          style="flex: 1; background: transparent; border: none; color: var(--text); font-size: 13.5px; font-family: 'Plus Jakarta Sans', sans-serif"
        />
      </div>
      <div style="flex: 1"></div>

      <div style="display: flex; align-items: center; gap: 6px; flex: none; padding: 0 4px">
        <button @click="actions.setTheme('cyan')" title="Lime"
          style="width: 16px; height: 16px; border-radius: 50%; border: 1px solid rgba(255,255,255,0.25); background: #c6ff4a; cursor: pointer; padding: 0"></button>
        <button @click="actions.setTheme('magenta')" title="Magenta"
          style="width: 16px; height: 16px; border-radius: 50%; border: 1px solid rgba(255,255,255,0.25); background: #ff45e0; cursor: pointer; padding: 0"></button>
      </div>

      <button @click="actions.toggleMode" title="Đổi giao diện sáng / tối" class="hbtn"
        style="flex: none; width: 42px; height: 42px; border-radius: 11px; border: 1px solid rgba(var(--line-rgb),0.2); background: var(--card); color: var(--text); cursor: pointer; font-size: 18px; line-height: 1; display: flex; align-items: center; justify-content: center">
        {{ modeIcon }}
      </button>

      <div v-if="state.user" style="position: relative">
        <button @click="toggleBell" title="Thông báo" class="hbtn"
          style="flex: none; width: 42px; height: 42px; border-radius: 11px; border: 1px solid rgba(var(--line-rgb),0.2); background: var(--card); color: var(--text); cursor: pointer; font-size: 17px; line-height: 1; display: flex; align-items: center; justify-content: center; position: relative">
          <i class="bi bi-bell"></i>
          <span v-if="state.unreadNotifCount" :style="{ background: accent }"
            style="position: absolute; top: -6px; right: -6px; min-width: 18px; height: 18px; padding: 0 4px; border-radius: 9px; color: var(--acc-ink); font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 10px; display: flex; align-items: center; justify-content: center">
            {{ state.unreadNotifCount > 9 ? '9+' : state.unreadNotifCount }}
          </span>
        </button>

        <div v-if="bellOpen" @click="bellOpen = false" style="position: fixed; inset: 0; z-index: 69"></div>
        <Transition name="dropdown-fade">
          <div v-if="bellOpen"
            style="position: absolute; top: 48px; right: 0; width: 340px; max-height: 420px; overflow-y: auto; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.2); border-radius: 13px; box-shadow: 0 24px 50px rgba(0,0,0,0.5); z-index: 70">
            <div style="display: flex; align-items: center; justify-content: space-between; padding: 12px 14px; border-bottom: 1px solid rgba(var(--line-rgb),0.14)">
              <span style="font-size: 13.5px; font-weight: 700; color: var(--text)">Thông báo</span>
              <button v-if="state.unreadNotifCount" @click="actions.markAllNotificationsRead" :style="{ color: accent }"
                style="background: none; border: none; font-size: 12px; font-weight: 600; cursor: pointer">
                Đánh dấu đã đọc hết
              </button>
            </div>
            <div v-if="loadingBell" style="padding: 24px; text-align: center; color: var(--muted); font-size: 13px">Đang tải...</div>
            <div v-else-if="!state.notifications.length" style="padding: 28px 14px; text-align: center; color: var(--muted); font-size: 13px">
              Chưa có thông báo nào.
            </div>
            <div v-else>
              <div v-for="n in state.notifications" :key="n.id" @click="onClickNotification(n)"
                style="display: flex; gap: 10px; padding: 11px 14px; border-bottom: 1px solid rgba(var(--line-rgb),0.1); cursor: pointer"
                :style="{ background: n.isRead ? 'transparent' : 'color-mix(in srgb, ' + accent + ' 7%, transparent)' }">
                <span style="width: 7px; height: 7px; border-radius: 50%; flex: none; margin-top: 5px"
                  :style="{ background: n.isRead ? 'transparent' : accent }"></span>
                <div style="flex: 1; min-width: 0">
                  <div style="font-size: 13px; font-weight: 600; color: var(--text)">{{ n.title }}</div>
                  <div style="font-size: 12px; color: var(--muted2); margin-top: 2px; line-height: 1.4">{{ n.message }}</div>
                  <div style="font-size: 11px; color: var(--muted); margin-top: 4px">{{ timeAgo(n.createdAt) }}</div>
                </div>
              </div>
            </div>
          </div>
        </Transition>
      </div>

      <button id="app-cart-icon" @click="actions.goCart" class="hbtn"
        :style="{ background: 'color-mix(in srgb, ' + accent + ' 12%, var(--card))' }"
        style="position: relative; flex: none; height: 42px; display: flex; align-items: center; gap: 9px; padding: 0 16px; border-radius: 11px; border: 1px solid rgba(var(--line-rgb),0.2); color: var(--text); cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif; font-weight: 600; font-size: 13.5px">
        <span style="font-size: 17px">🛒</span> Giỏ hàng
        <span v-if="cartCount > 0" :style="{ background: accent }"
          style="position: absolute; top: -7px; right: -7px; min-width: 20px; height: 20px; padding: 0 5px; border-radius: 10px; color: var(--acc-ink); font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 11px; display: flex; align-items: center; justify-content: center">
          {{ cartCount }}
        </span>
      </button>

      <!-- Khách chưa đăng nhập: nút Liên hệ (panel hỗ trợ) + Đăng nhập -->
      <template v-if="!state.user">
        <button @click="toggleSupport" class="support-btn"
          :style="{ color: supportOpen ? 'var(--text)' : 'var(--muted2)' }"
          style="flex: none; display: flex; align-items: center; gap: 7px; height: 42px; padding: 0 14px; border-radius: 11px; border: 1px solid rgba(var(--line-rgb),0.2); background: transparent; cursor: pointer; font-size: 13px">
          <i class="bi bi-headset" style="font-size: 15px"></i> Liên hệ
        </button>
        <button @click="actions.openLogin" class="hbtn"
          :style="{ background: 'color-mix(in srgb, ' + accent + ' 12%, var(--card))' }"
          style="flex: none; height: 42px; display: flex; align-items: center; gap: 8px; padding: 0 16px; border-radius: 11px; border: 1px solid rgba(var(--line-rgb),0.2); color: var(--text); cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif; font-weight: 600; font-size: 13.5px">
          <span style="font-size: 16px">👤</span> Đăng nhập
        </button>
      </template>

      <!-- Đã đăng nhập: nút Liên hệ TRÁM ĐÚNG vào vị trí nút "🛡️ Bảo hành" cũ -->
      <div v-else style="flex: none; display: flex; align-items: center; gap: 10px; color: var(--text); font-size: 13px; font-family: 'Plus Jakarta Sans', sans-serif">
        <span @click="actions.goAccount" title="Tài khoản của tôi" style="font-weight: 600; cursor: pointer">
          👤 {{ state.user.fullName || state.user.email || 'Tài khoản' }}
        </span>
        <button @click="actions.goOrders" title="Đơn hàng của tôi" class="hbtn"
          style="height: 34px; padding: 0 12px; border-radius: 9px; border: 1px solid rgba(var(--line-rgb),0.2); background: transparent; color: var(--muted2); cursor: pointer; font-size: 12.5px">
          📦 Đơn hàng
        </button>
        <button @click="toggleSupport" title="Hỗ trợ & Liên hệ" class="support-btn"
          :style="{ color: supportOpen ? 'var(--text)' : 'var(--muted2)' }"
          style="display: flex; align-items: center; gap: 7px; height: 34px; padding: 0 12px; border-radius: 9px; border: 1px solid rgba(var(--line-rgb),0.2); background: transparent; cursor: pointer; font-size: 12.5px">
          <i class="bi bi-headset" style="font-size: 14px"></i> Liên hệ
        </button>
        <button @click="actions.logout" title="Đăng xuất" class="hbtn"
          style="height: 34px; padding: 0 12px; border-radius: 9px; border: 1px solid rgba(var(--line-rgb),0.2); background: transparent; color: var(--sale); cursor: pointer; font-size: 12.5px">
          Đăng xuất
        </button>
      </div>
    </div>

    <!-- ===== Nav + mega-menu full-width ===== -->
    <div @mouseleave="leaveMega" style="position: relative; border-top: 1px solid rgba(var(--line-rgb), 0.08)">
      <nav style="max-width: 1800px; margin: 0 auto; padding: 0 24px; display: flex; align-items: stretch; gap: 2px">
        <div @mouseenter="leaveMega" style="display: flex">
          <div @click="actions.goHome" class="nav-link"
            :style="{ color: route.name === 'home' ? 'var(--text)' : 'var(--muted2)' }"
            style="position: relative; display: flex; align-items: center; gap: 8px; padding: 20px 18px; cursor: pointer; white-space: nowrap; font-size: 15px; font-weight: 600; transition: color 0.15s">
            <span>Trang chủ</span>
            <span v-if="route.name === 'home'" :style="{ background: accent, boxShadow: '0 0 12px ' + accent }"
              style="position: absolute; left: 16px; right: 16px; bottom: 0; height: 3px; border-radius: 2px"></span>
          </div>
        </div>

        <div v-for="m in megaMenus" :key="m.key" @mouseenter="hoverMega(m.key)" style="position: relative; display: flex">
          <div @click="clickMega(m)" class="nav-link"
            :style="{ color: m.active || openMenu === m.key ? 'var(--text)' : 'var(--muted2)' }"
            style="position: relative; display: flex; align-items: center; gap: 8px; padding: 20px 18px; cursor: pointer; white-space: nowrap; font-size: 15px; font-weight: 600; transition: color 0.15s">
            <i :class="'bi ' + m.icon" style="font-size: 16px; opacity: 0.85"></i>
            <span>{{ m.label }}</span>
            <span style="font-size: 10px; opacity: 0.6; margin-left: -2px">▾</span>
            <span v-if="m.active || openMenu === m.key" :style="{ background: accent, boxShadow: '0 0 12px ' + accent }"
              style="position: absolute; left: 16px; right: 16px; bottom: 0; height: 3px; border-radius: 2px"></span>
          </div>
        </div>

        <div v-for="(item, i) in plainNavItems" :key="'p' + i" @mouseenter="leaveMega" style="display: flex">
          <div @click="item.onClick" class="nav-link"
            :style="{ color: item.active ? 'var(--text)' : 'var(--muted2)' }"
            style="position: relative; display: flex; align-items: center; gap: 8px; padding: 20px 18px; cursor: pointer; white-space: nowrap; font-size: 15px; font-weight: 600; transition: color 0.15s">
            <i :class="'bi ' + item.icon" style="font-size: 16px; opacity: 0.85"></i>
            <span>{{ item.label }}</span>
            <span v-if="item.active" :style="{ background: accent, boxShadow: '0 0 12px ' + accent }"
              style="position: absolute; left: 16px; right: 16px; bottom: 0; height: 3px; border-radius: 2px"></span>
          </div>
        </div>

        <div style="flex: 1; min-width: 12px"></div>
        <div style="display: flex; align-items: center; gap: 8px; color: var(--sale); font-size: 13px; font-weight: 700; white-space: nowrap">
          <i class="bi bi-lightning-charge-fill" style="font-size: 15px"></i> Trả góp 0%
        </div>
      </nav>

      <!-- Mega-menu: lưới ô ảnh + cột "Khám phá" (đang để trống, xem EXPLORE) -->
      <div v-if="activeMenu"
        class="mega-panel"
        style="position: absolute; top: 100%; left: 0; right: 0; width: 100%; background: var(--card2); border-top: 1px solid rgba(var(--line-rgb),0.1); box-shadow: 0 34px 60px -12px rgba(0,0,0,0.55); z-index: 60">
        <div
          :style="{ gridTemplateColumns: exploreItems.length ? 'minmax(0, 1fr) 280px' : 'minmax(0, 1fr)' }"
          style="max-width: 1800px; margin: 0 auto; padding: 30px 24px 34px; display: grid; gap: 44px; align-items: start">
          <div style="display: grid; grid-template-columns: repeat(7, minmax(0, 1fr)); column-gap: 20px; row-gap: 34px; justify-items: center">
            <div v-for="it in activeMenu.items" :key="it.label" @click="it.onClick(); dongHet()" class="mega-tile"
              style="display: flex; flex-direction: column; align-items: center; gap: 12px; cursor: pointer; width: 100%; max-width: 158px">
              <!-- Viền theo chế độ sáng/tối (màu đặt trong <style> để đổi được theo data-mode).
                   Không padding + overflow:hidden để ảnh ăn sát viền, không chừa khoảng trống. -->
              <div class="mega-thumb"
                style="width: 100%; aspect-ratio: 1 / 1; display: flex; align-items: center; justify-content: center; border-radius: 13px; overflow: hidden; box-sizing: border-box">
                <img v-if="it.img" :src="it.img" :alt="it.label" loading="lazy"
                  style="width: 100%; height: 100%; object-fit: cover; display: block" />
                <i v-else :class="'bi ' + it.icon" style="font-size: 46px; color: var(--acc); opacity: 0.9"></i>
              </div>
              <span style="font-size: 14px; font-weight: 600; color: var(--text); text-align: center; line-height: 1.3; text-wrap: pretty">
                {{ it.label }}
              </span>
            </div>
          </div>

          <div v-if="exploreItems.length" style="border-left: 1px solid rgba(var(--line-rgb),0.12); padding-left: 32px">
            <div style="font-family: 'Chakra Petch', sans-serif; font-size: 11.5px; letter-spacing: 1.8px; font-weight: 700; color: var(--muted); text-transform: uppercase; margin-bottom: 16px">
              Khám phá
            </div>
            <div style="display: flex; flex-direction: column; gap: 13px">
              <div v-for="e in exploreItems" :key="e.label" @click="onMenuLinkClick(e)"
                :class="e.go ? 'explore-link' : ''"
                :title="e.go ? '' : 'Chưa có trang — sẽ bổ sung sau'"
                :style="{ cursor: e.go ? 'pointer' : 'default', opacity: e.go ? 1 : 0.45 }"
                style="font-size: 13px; color: var(--muted2); line-height: 1.35; transition: color 0.12s">
                {{ e.label }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ===== Panel Hỗ trợ / Liên hệ (gộp Liên hệ + Bảo hành) ===== -->
    <template v-if="supportOpen">
      <div
        class="mega-panel"
        style="position: absolute; top: 100%; left: 0; right: 0; width: 100%; background: var(--card2); border-top: 1px solid rgba(var(--line-rgb),0.1); box-shadow: 0 34px 60px -12px rgba(0,0,0,0.55); z-index: 60">
        <div style="max-width: 1800px; margin: 0 auto; padding: 40px 24px 44px; display: grid; grid-template-columns: minmax(0, 1fr) 440px; gap: 56px; align-items: start">
          <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); column-gap: 48px; row-gap: 38px">
            <div v-for="c in SUPPORT_COLUMNS" :key="c.title">
              <div style="font-family: 'Chakra Petch', sans-serif; font-size: 11.5px; letter-spacing: 1.6px; font-weight: 700; color: var(--muted); text-transform: uppercase; margin-bottom: 16px">
                {{ c.title }}
              </div>
              <div style="display: flex; flex-direction: column; gap: 13px">
                <div v-for="e in c.items" :key="e.label" @click="onMenuLinkClick(e)"
                  :class="e.go ? 'explore-link' : 'pending-link'"
                  :title="e.go ? '' : 'Chưa có trang — sẽ bổ sung sau'"
                  :style="{ cursor: e.go ? 'pointer' : 'default', opacity: e.go ? 1 : 0.45 }"
                  style="font-size: 14px; color: var(--muted2); line-height: 1.35; transition: color 0.12s">
                  {{ e.label }}
                </div>
              </div>
            </div>
          </div>

          <div style="border-left: 1px solid rgba(var(--line-rgb),0.12); padding-left: 44px; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 16px">
            <div v-for="t in SUPPORT_TILES" :key="t.label" @click="onMenuLinkClick(t)"
              :class="t.go ? 'support-tile' : ''"
              :title="t.go ? '' : 'Chưa có trang — sẽ bổ sung sau'"
              :style="{ cursor: t.go ? 'pointer' : 'default', opacity: t.go ? 1 : 0.45 }"
              style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 14px; padding: 24px 12px; border-radius: 14px; background: var(--card); border: 1px solid rgba(var(--line-rgb),0.1); transition: border-color 0.14s, transform 0.14s">
              <i :class="'bi ' + t.icon" style="font-size: 34px; color: var(--acc); opacity: 0.9"></i>
              <span style="font-size: 13px; font-weight: 600; color: var(--text); text-align: center; line-height: 1.3; text-wrap: pretty">
                {{ t.label }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </template>
  </header>
</template>

<style scoped>
.nav-link:hover { color: var(--text) !important; }
.hbtn:hover { border-color: color-mix(in srgb, var(--acc) 45%, transparent) !important; }
.support-btn:hover { color: var(--text) !important; border-color: color-mix(in srgb, var(--acc) 45%, transparent) !important; }
/* Viền ô ảnh trong mega-menu:
   - Tối  (mặc định): màu accent của theme (var(--acc) — lime hoặc magenta tuỳ khách chọn).
   - Sáng: trắng.
   Đặt màu ở đây chứ không inline vì inline style không đổi được theo [data-mode] trên <html>. */
.mega-thumb {
  border: 1px solid var(--acc);
  transition: transform 0.16s ease, border-color 0.16s ease;
}
:root[data-mode='light'] .mega-thumb {
  border-color: #fff;
}
.mega-tile:hover .mega-thumb { transform: scale(1.06); }
.mega-tile:hover span { color: var(--acc) !important; }
.explore-link:hover { color: var(--acc) !important; }
.support-tile:hover { border-color: color-mix(in srgb, var(--acc) 55%, transparent); transform: translateY(-3px); }

/* Animation phải khai báo trong khối scoped này (không để inline style): Vue đổi tên @keyframes
   theo hash của scope, mà inline style thì Vue không viết lại -> tên sẽ không khớp, animation
   không chạy. */
.mega-panel { animation: megaIn 0.18s ease; }

@keyframes megaIn {
  from { opacity: 0; transform: translateY(-6px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
