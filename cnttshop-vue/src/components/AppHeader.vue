<script setup>
import { computed, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import {
  catMeta,
  products,
  matchesQuery,
  CATEGORY_SEGMENTS,
  COMPONENT_GROUPS_DEF,
  COMPONENT_SLUGS,
  HIDDEN_SLUGS,
} from '../data/products.js';
import { state, actions, accent, cartCount } from '../store.js';
import AppLogo from './AppLogo.vue';

const route = useRoute();
const router = useRouter();
// Ở trang chủ, các mục danh mục trên nav không mở dropdown/điều hướng nữa — bấm sẽ đổi
// nội dung widget "luôn hiện" (state.homeWidgetCat) ngay tại trang chủ.
const isHome = computed(() => route.name === 'home');
// Panel danh mục có thể thu gọn/mở lại — mặc định mở, không lưu localStorage (chỉ là tiện
// ích hiển thị tạm thời trong phiên xem, không phải lựa chọn cần nhớ lâu dài).
const widgetOpen = ref(true);
// Bấm mục đang chọn sẵn trên nav lần nữa -> thu gọn/mở lại panel; bấm mục khác -> đổi nội
// dung panel và luôn mở ra (không cần dòng "Thu gọn/Xem danh mục" riêng nữa).
function onWidgetNavClick(key) {
  if (state.homeWidgetCat === key) {
    widgetOpen.value = !widgetOpen.value;
  } else {
    state.homeWidgetCat = key;
    widgetOpen.value = true;
  }
}

// ===== Chuông thông báo — lấy đúng UI/UX từ nút chuông bên admin-vue, dữ liệu đọc/ghi
// qua state.notifications dùng chung với danh sách thông báo trong Quản lý tài khoản. =====
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

// Mega-menu theo chức năng cho các danh mục còn lại (kiểu TTGShop) — dùng chung CATEGORY_SEGMENTS
// với bộ lọc "Phân khúc" ở CategoryView.vue để 2 nơi luôn khớp nhau.
const CATEGORY_MEGA_DEFS = CATEGORY_SEGMENTS;
const CATEGORY_MEGA_SLUGS = CATEGORY_MEGA_DEFS.map((d) => d.slug);

// Chỉ 1 dropdown mở tại 1 thời điểm — dùng chung cho cả 6 mega-menu (Linh kiện + 5 danh mục).
const openMenu = ref(null);

const componentColumns = computed(() =>
  COMPONENT_GROUPS_DEF.map((g) => ({
    title: g.title,
    items: g.items
      .filter((it) => catMeta[it.slug])
      .map((it) => ({
        label: catMeta[it.slug].vn,
        icon: it.icon,
        onClick: () => actions.goCat(it.slug),
        active: route.name === 'category' && route.params.cat === it.slug,
      })),
  })).filter((g) => g.items.length),
);
const componentMenuActive = computed(() =>
  route.name === 'category' && COMPONENT_SLUGS.includes(route.params.cat),
);

const categoryMegaMenus = computed(() =>
  CATEGORY_MEGA_DEFS.filter((def) => catMeta[def.slug]).map((def) => {
    const items = def.items
      .map((it) => ({
        label: it.label,
        icon: it.icon,
        count: products.filter((p) => p.cat === def.slug && matchesQuery(p, it.keyword)).length,
        onClick: () => actions.goCat(def.slug, it.keyword),
        active: route.name === 'category' && route.params.cat === def.slug && route.query.seg === it.keyword,
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
  }).filter((m) => m.items.length),
);

// Panel "luôn hiện" ở trang chủ (thay dropdown hover) — nội dung là 1 trong các categoryMegaMenus,
// chọn theo state.homeWidgetCat (đặt khi bấm mục trên menu, xem các @click bên dưới).
const activeWidgetMenu = computed(() =>
  categoryMegaMenus.value.find((cm) => cm.key === state.homeWidgetCat),
);

const navItems = computed(() => {
  const items = [];
  Object.keys(catMeta).forEach((k) => {
    if (COMPONENT_SLUGS.includes(k) || HIDDEN_SLUGS.includes(k) || CATEGORY_MEGA_SLUGS.includes(k)) return;
    items.push({
      label: catMeta[k].vn,
      onClick: () => actions.goCat(k),
      active: route.name === 'category' && route.params.cat === k,
    });
  });
  items.push({
    label: '⚙️ Xây dựng cấu hình PC',
    onClick: actions.goPcBuild,
    active: route.name === 'pcbuild',
  });
  items.push({
    label: '⚖️ So sánh cấu hình',
    onClick: actions.goCompare,
    active: route.name === 'compare',
  });
  items.push({
    label: '💬 Liên hệ',
    onClick: actions.goContact,
    active: route.name === 'contact',
  });
  items.push({
    label: '🎁 Khuyến mãi',
    onClick: actions.goPromotions,
    active: route.name === 'promotions',
  });
  return items;
});

const modeIcon = computed(() => (state.mode === 'light' ? '🌙' : '☀️'));

function onSearchKey(e) {
  if (e.key === 'Enter') actions.onSearchEnter();
}
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
    <div
      style="
        max-width: 1800px;
        margin: 0 auto;
        padding: 14px 24px;
        display: flex;
        align-items: center;
        gap: 22px;
      "
    >
      <div
        @click="actions.goHome"
        style="
          display: flex;
          align-items: center;
          gap: 11px;
          cursor: pointer;
          flex: none;
        "
      >
        <AppLogo :size="28" :on-light="state.mode === 'light'" :accent-color="accent" />
        <div
          style="
            font-family: 'Chakra Petch', sans-serif;
            font-weight: 700;
            font-size: 20px;
            letter-spacing: 0.5px;
            line-height: 1;
          "
        >
          CNTT<span :style="{ color: accent }">shop</span>
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
          :value="state.q"
          @input="actions.setQ($event.target.value)"
          @keydown="onSearchKey"
          placeholder="Tìm laptop, PC, RTX 4070, CPU..."
          style="
            flex: 1;
            background: transparent;
            border: none;
            color: var(--text);
            font-size: 13.5px;
            font-family: 'Be Vietnam Pro', sans-serif;
          "
        />
      </div>
      <div style="flex: 1"></div>
      <div
        style="
          display: flex;
          align-items: center;
          gap: 6px;
          flex: none;
          padding: 0 4px;
        "
      >
        <button
          @click="actions.setTheme('cyan')"
          title="Lime"
          style="
            width: 16px;
            height: 16px;
            border-radius: 50%;
            border: 1px solid rgba(255, 255, 255, 0.25);
            background: #c6ff4a;
            cursor: pointer;
            padding: 0;
          "
        ></button>
        <button
          @click="actions.setTheme('magenta')"
          title="Magenta"
          style="
            width: 16px;
            height: 16px;
            border-radius: 50%;
            border: 1px solid rgba(255, 255, 255, 0.25);
            background: #ff45e0;
            cursor: pointer;
            padding: 0;
          "
        ></button>
      </div>
      <button
        @click="actions.toggleMode"
        title="Đổi giao diện sáng / tối"
        style="
          flex: none;
          width: 42px;
          height: 42px;
          border-radius: 11px;
          border: 1px solid rgba(var(--line-rgb), 0.2);
          background: var(--card);
          color: var(--text);
          cursor: pointer;
          font-size: 18px;
          line-height: 1;
          display: flex;
          align-items: center;
          justify-content: center;
        "
      >
        {{ modeIcon }}
      </button>
      <div v-if="state.user" style="position: relative">
        <button
          @click="toggleBell"
          title="Thông báo"
          style="
            flex: none;
            width: 42px;
            height: 42px;
            border-radius: 11px;
            border: 1px solid rgba(var(--line-rgb), 0.2);
            background: var(--card);
            color: var(--text);
            cursor: pointer;
            font-size: 17px;
            line-height: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
          "
        >
          <i class="bi bi-bell"></i>
          <span
            v-if="state.unreadNotifCount"
            :style="{ background: accent }"
            style="
              position: absolute;
              top: -6px;
              right: -6px;
              min-width: 18px;
              height: 18px;
              padding: 0 4px;
              border-radius: 9px;
              color: var(--acc-ink);
              font-family: 'Chakra Petch', sans-serif;
              font-weight: 700;
              font-size: 10px;
              display: flex;
              align-items: center;
              justify-content: center;
            "
            >{{ state.unreadNotifCount > 9 ? '9+' : state.unreadNotifCount }}</span
          >
        </button>

        <div v-if="bellOpen" @click="bellOpen = false" style="position: fixed; inset: 0; z-index: 69"></div>
        <Transition name="dropdown-fade">
        <div
          v-if="bellOpen"
          style="
            position: absolute;
            top: 48px;
            right: 0;
            width: 340px;
            max-height: 420px;
            overflow-y: auto;
            background: var(--card2);
            border: 1px solid rgba(var(--line-rgb), 0.2);
            border-radius: 13px;
            box-shadow: 0 24px 50px rgba(0, 0, 0, 0.5);
            z-index: 70;
          "
        >
          <div
            style="
              display: flex;
              align-items: center;
              justify-content: space-between;
              padding: 12px 14px;
              border-bottom: 1px solid rgba(var(--line-rgb), 0.14);
            "
          >
            <span style="font-size: 13.5px; font-weight: 700; color: var(--text)">Thông báo</span>
            <button
              v-if="state.unreadNotifCount"
              @click="actions.markAllNotificationsRead"
              :style="{ color: accent }"
              style="background: none; border: none; font-size: 12px; font-weight: 600; cursor: pointer"
            >
              Đánh dấu đã đọc hết
            </button>
          </div>
          <div v-if="loadingBell" style="padding: 24px; text-align: center; color: var(--muted); font-size: 13px">
            Đang tải...
          </div>
          <div v-else-if="!state.notifications.length" style="padding: 28px 14px; text-align: center; color: var(--muted); font-size: 13px">
            Chưa có thông báo nào.
          </div>
          <div v-else>
            <div
              v-for="n in state.notifications"
              :key="n.id"
              @click="onClickNotification(n)"
              style="display: flex; gap: 10px; padding: 11px 14px; border-bottom: 1px solid rgba(var(--line-rgb), 0.1); cursor: pointer"
              :style="{ background: n.isRead ? 'transparent' : 'color-mix(in srgb, ' + accent + ' 7%, transparent)' }"
            >
              <span
                style="width: 7px; height: 7px; border-radius: 50%; flex: none; margin-top: 5px"
                :style="{ background: n.isRead ? 'transparent' : accent }"
              ></span>
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
      <button
        id="app-cart-icon"
        @click="actions.goCart"
        :style="{
          background: 'color-mix(in srgb, ' + accent + ' 12%, var(--card))',
        }"
        style="
          position: relative;
          flex: none;
          height: 42px;
          display: flex;
          align-items: center;
          gap: 9px;
          padding: 0 16px;
          border-radius: 11px;
          border: 1px solid rgba(var(--line-rgb), 0.2);
          color: var(--text);
          cursor: pointer;
          font-family: 'Be Vietnam Pro', sans-serif;
          font-weight: 600;
          font-size: 13.5px;
        "
      >
        <span style="font-size: 17px">🛒</span> Giỏ hàng
        <span
          v-if="cartCount > 0"
          :style="{ background: accent }"
          style="
            position: absolute;
            top: -7px;
            right: -7px;
            min-width: 20px;
            height: 20px;
            padding: 0 5px;
            border-radius: 10px;
            color: var(--acc-ink);
            font-family: 'Chakra Petch', sans-serif;
            font-weight: 700;
            font-size: 11px;
            display: flex;
            align-items: center;
            justify-content: center;
          "
          >{{ cartCount }}</span
        >
      </button>

      <button
        v-if="!state.user"
        @click="actions.openLogin"
        :style="{
          background: 'color-mix(in srgb, ' + accent + ' 12%, var(--card))',
        }"
        style="
          flex: none;
          height: 42px;
          display: flex;
          align-items: center;
          gap: 8px;
          padding: 0 16px;
          border-radius: 11px;
          border: 1px solid rgba(var(--line-rgb), 0.2);
          color: var(--text);
          cursor: pointer;
          font-family: 'Be Vietnam Pro', sans-serif;
          font-weight: 600;
          font-size: 13.5px;
        "
      >
        <span style="font-size: 16px">👤</span> Đăng nhập
      </button>
      <div
        v-else
        style="
          flex: none;
          display: flex;
          align-items: center;
          gap: 10px;
          color: var(--text);
          font-size: 13px;
          font-family: 'Be Vietnam Pro', sans-serif;
        "
      >
        <span
          @click="actions.goAccount"
          title="Tài khoản của tôi"
          style="font-weight: 600; cursor: pointer"
          >👤 {{ state.user.fullName || state.user.email || 'Tài khoản' }}</span
        >
        <button
          @click="actions.goOrders"
          title="Đơn hàng của tôi"
          style="
            height: 34px;
            padding: 0 12px;
            border-radius: 9px;
            border: 1px solid rgba(var(--line-rgb), 0.2);
            background: transparent;
            color: var(--muted2);
            cursor: pointer;
            font-size: 12.5px;
          "
        >
          📦 Đơn hàng
        </button>
        <button
          @click="actions.goWarranty"
          title="Bảo hành của tôi"
          style="
            height: 34px;
            padding: 0 12px;
            border-radius: 9px;
            border: 1px solid rgba(var(--line-rgb), 0.2);
            background: transparent;
            color: var(--muted2);
            cursor: pointer;
            font-size: 12.5px;
          "
        >
          🛡️ Bảo hành
        </button>
        <button
          @click="actions.logout"
          title="Đăng xuất"
          style="
            height: 34px;
            padding: 0 12px;
            border-radius: 9px;
            border: 1px solid rgba(var(--line-rgb), 0.2);
            background: transparent;
            color: var(--sale);
            cursor: pointer;
            font-size: 12.5px;
          "
        >
          Đăng xuất
        </button>
      </div>
    </div>
    <nav style="border-top: 1px solid rgba(var(--line-rgb), 0.08)">
      <div
        style="
          max-width: 1800px;
          margin: 0 auto;
          padding: 6px 24px;
          display: flex;
          flex-wrap: wrap;
          align-items: center;
          column-gap: 4px;
          row-gap: 2px;
        "
      >
        <div
          @click="actions.goHome"
          :style="{ color: route.name === 'home' ? 'var(--text)' : 'var(--muted2)' }"
          style="
            position: relative;
            display: flex;
            align-items: center;
            padding: 12px 16px;
            cursor: pointer;
            white-space: nowrap;
            font-size: 14.5px;
            font-weight: 500;
          "
        >
          Trang chủ
          <Transition name="underline-grow">
          <span
            v-if="route.name === 'home'"
            :style="{ background: accent, boxShadow: '0 0 10px ' + accent }"
            style="position: absolute; left: 14px; right: 14px; bottom: 0; height: 2px"
          ></span>
          </Transition>
        </div>

        <!-- Mega-menu ngang "Linh kiện máy tính" (kiểu TTGShop) — gộp 9 danh mục con (CPU..Tản nhiệt).
        Ở trang chủ: không mở dropdown nữa, bấm sẽ đổi nội dung widget "luôn hiện" thay vì rời trang. -->
        <div
          v-if="componentColumns.length"
          @mouseenter="!isHome && (openMenu = 'components')"
          @mouseleave="!isHome && (openMenu = null)"
          style="position: relative"
        >
          <div
            @click="isHome && onWidgetNavClick('components')"
            :style="{ color: (isHome ? state.homeWidgetCat === 'components' : componentMenuActive) || openMenu === 'components' ? 'var(--text)' : 'var(--muted2)' }"
            style="
              position: relative;
              display: flex;
              align-items: center;
              gap: 6px;
              padding: 12px 16px;
              cursor: pointer;
              white-space: nowrap;
              font-size: 14.5px;
              font-weight: 500;
            "
          >
            <i class="bi bi-cpu" style="font-size: 16px"></i>
            Linh kiện máy tính
            <span v-if="!isHome" style="font-size: 11px; transition: transform 0.15s" :style="{ transform: openMenu === 'components' ? 'rotate(180deg)' : 'none' }">▾</span>
            <Transition name="underline-grow">
            <span
              v-if="isHome ? state.homeWidgetCat === 'components' : componentMenuActive"
              :style="{ background: accent, boxShadow: '0 0 10px ' + accent }"
              style="position: absolute; left: 14px; right: 14px; bottom: 0; height: 2px"
            ></span>
            </Transition>
          </div>
          <Transition name="dropdown-fade">
          <div
            v-if="openMenu === 'components'"
            style="
              position: absolute;
              top: 100%;
              left: 0;
              width: 980px;
              background: var(--card2);
              border: 1px solid rgba(var(--line-rgb), 0.2);
              border-radius: 14px;
              padding: 28px 30px;
              box-shadow: 0 24px 50px rgba(0, 0, 0, 0.5);
              z-index: 60;
              display: grid;
              grid-template-columns: repeat(3, 1fr) 230px;
              column-gap: 24px;
            "
          >
            <div v-for="(col, ci) in componentColumns" :key="ci">
              <div
                style="
                  font-family: 'Chakra Petch', sans-serif;
                  font-size: 12.5px;
                  letter-spacing: 1.5px;
                  font-weight: 700;
                  color: var(--muted);
                  text-transform: uppercase;
                  padding: 0 12px 12px;
                  border-bottom: 1px solid rgba(var(--line-rgb), 0.14);
                  margin-bottom: 10px;
                "
              >
                {{ col.title }}
              </div>
              <div
                v-for="(sub, si) in col.items"
                :key="si"
                @click="sub.onClick(); openMenu = null"
                :style="{ color: sub.active ? 'var(--text)' : 'var(--muted2)', background: sub.active ? 'color-mix(in srgb, ' + accent + ' 14%, transparent)' : 'transparent' }"
                style="display: flex; align-items: center; gap: 12px; padding: 12px 14px; border-radius: 9px; cursor: pointer; font-size: 15px; line-height: 1.3"
              >
                <i :class="'bi ' + sub.icon" :style="{ color: sub.active ? accent : 'var(--muted)' }" style="font-size: 17px; width: 20px; text-align: center; flex: none"></i>
                <span>{{ sub.label }}</span>
              </div>
            </div>

            <!-- Ô nổi bật: dẫn sang trình xây dựng cấu hình PC -->
            <div
              @click="actions.goPcBuild(); openMenu = null"
              :style="{ background: 'linear-gradient(160deg, color-mix(in srgb, ' + accent + ' 22%, var(--card2)) 0%, var(--card2) 75%)', border: '1px solid color-mix(in srgb, ' + accent + ' 35%, transparent)' }"
              style="border-radius: 12px; padding: 18px 16px; cursor: pointer; display: flex; flex-direction: column; gap: 9px; justify-content: center"
            >
              <span style="font-size: 25px">⚙️</span>
              <span style="font-size: 14.5px; font-weight: 700; color: var(--text); line-height: 1.35">Tự xây dựng cấu hình PC theo ý bạn</span>
              <span :style="{ color: accent }" style="font-size: 13px; font-weight: 600">Bắt đầu ngay →</span>
            </div>
          </div>
          </Transition>
        </div>

        <!-- Mega-menu theo chức năng cho Laptop / PC / Màn hình / Ngoại vi / Phụ kiện (kiểu TTGShop) -->
        <div
          v-for="cm in categoryMegaMenus"
          :key="cm.key"
          @mouseenter="!isHome && (openMenu = cm.key)"
          @mouseleave="!isHome && (openMenu = null)"
          style="position: relative"
        >
          <div
            @click="isHome ? onWidgetNavClick(cm.key) : cm.onClick()"
            :style="{ color: (isHome ? state.homeWidgetCat === cm.key : cm.active) || openMenu === cm.key ? 'var(--text)' : 'var(--muted2)' }"
            style="
              position: relative;
              display: flex;
              align-items: center;
              gap: 6px;
              padding: 12px 16px;
              cursor: pointer;
              white-space: nowrap;
              font-size: 14.5px;
              font-weight: 500;
            "
          >
            <i :class="'bi ' + cm.icon" style="font-size: 16px"></i>
            {{ cm.label }}
            <span v-if="!isHome" style="font-size: 11px; transition: transform 0.15s" :style="{ transform: openMenu === cm.key ? 'rotate(180deg)' : 'none' }">▾</span>
            <Transition name="underline-grow">
            <span
              v-if="isHome ? state.homeWidgetCat === cm.key : cm.active"
              :style="{ background: accent, boxShadow: '0 0 10px ' + accent }"
              style="position: absolute; left: 14px; right: 14px; bottom: 0; height: 2px"
            ></span>
            </Transition>
          </div>
          <Transition name="dropdown-fade">
          <div
            v-if="openMenu === cm.key"
            style="
              position: absolute;
              top: 100%;
              left: 0;
              width: 480px;
              background: var(--card2);
              border: 1px solid rgba(var(--line-rgb), 0.2);
              border-radius: 14px;
              padding: 20px 22px;
              box-shadow: 0 24px 50px rgba(0, 0, 0, 0.5);
              z-index: 60;
              display: grid;
              grid-template-columns: repeat(2, 1fr);
              column-gap: 14px;
            "
          >
            <div
              style="
                grid-column: 1 / -1;
                font-family: 'Chakra Petch', sans-serif;
                font-size: 12.5px;
                letter-spacing: 1.5px;
                font-weight: 700;
                color: var(--muted);
                text-transform: uppercase;
                padding: 0 12px 12px;
                border-bottom: 1px solid rgba(var(--line-rgb), 0.14);
                margin-bottom: 10px;
              "
            >
              {{ cm.label }}
            </div>
            <div
              v-for="(it, ii) in cm.items"
              :key="ii"
              @click="it.onClick(); openMenu = null"
              :style="{ color: it.active ? 'var(--text)' : 'var(--muted2)', background: it.active ? 'color-mix(in srgb, ' + accent + ' 14%, transparent)' : 'transparent' }"
              style="display: flex; align-items: center; gap: 12px; padding: 12px 14px; border-radius: 9px; cursor: pointer; font-size: 15px; line-height: 1.3"
            >
              <i :class="'bi ' + it.icon" :style="{ color: it.active ? accent : 'var(--muted)' }" style="font-size: 17px; width: 20px; text-align: center; flex: none"></i>
              <span style="flex: 1">{{ it.label }}</span>
              <span style="font-size: 12.5px; color: var(--muted)">{{ it.count }}</span>
            </div>
            <div
              @click="cm.onClick(); openMenu = null"
              style="grid-column: 1 / -1; text-align: center; padding: 11px; margin-top: 4px; border-radius: 9px; cursor: pointer; font-size: 13.5px; font-weight: 600"
              :style="{ color: accent }"
            >
              Xem tất cả {{ cm.label }} →
            </div>
          </div>
          </Transition>
        </div>

        <div
          v-for="(item, i) in navItems"
          :key="i"
          @click="item.onClick"
          :style="{ color: item.active ? 'var(--text)' : 'var(--muted2)' }"
          style="
            position: relative;
            display: flex;
            align-items: center;
            padding: 12px 16px;
            cursor: pointer;
            white-space: nowrap;
            font-size: 14.5px;
            font-weight: 500;
          "
        >
          {{ item.label }}
          <Transition name="underline-grow">
          <span
            v-if="item.active"
            :style="{ background: accent, boxShadow: '0 0 10px ' + accent }"
            style="
              position: absolute;
              left: 14px;
              right: 14px;
              bottom: 0;
              height: 2px;
            "
          ></span>
          </Transition>
        </div>
        <div style="flex: 1; min-width: 12px"></div>
        <div
          style="
            display: flex;
            align-items: center;
            gap: 7px;
            padding: 10px 4px;
            color: var(--sale);
            font-size: 12.5px;
            font-weight: 600;
            white-space: nowrap;
          "
        >
          <span style="font-size: 14px">⚡</span> Trả góp 0%
        </div>
      </div>
    </nav>

    <!-- Panel danh mục "luôn hiện" ở trang chủ — thay cho dropdown hover, nằm ngay dưới thanh
    menu như 1 phần bình thường của trang (không phải overlay che nội dung). Nội dung đổi theo
    state.homeWidgetCat khi bấm mục tương ứng ở nav trên (xem các @click trong <nav>). -->
    <div v-if="isHome" style="border-top: 1px solid rgba(var(--line-rgb), 0.08); background: var(--card2)">
      <div v-show="widgetOpen" style="max-width: 1800px; margin: 0 auto; padding: 22px 24px">
        <div
          v-if="state.homeWidgetCat === 'components'"
          style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 22px"
        >
          <div v-for="(col, ci) in componentColumns" :key="ci">
            <div
              style="
                font-family: 'Chakra Petch', sans-serif;
                font-size: 12px;
                letter-spacing: 1.5px;
                font-weight: 700;
                color: var(--muted);
                text-transform: uppercase;
                padding-bottom: 10px;
                border-bottom: 1px solid rgba(var(--line-rgb), 0.14);
                margin-bottom: 10px;
              "
            >
              {{ col.title }}
            </div>
            <div
              v-for="(sub, si) in col.items"
              :key="si"
              @click="sub.onClick()"
              class="widget-row"
              style="display: flex; align-items: center; gap: 10px; padding: 9px 8px; border-radius: 8px; cursor: pointer; font-size: 14px; color: var(--muted2)"
            >
              <i :class="'bi ' + sub.icon" :style="{ color: accent }" style="font-size: 16px; width: 20px; text-align: center; flex: none"></i>
              <span>{{ sub.label }}</span>
            </div>
          </div>
        </div>
        <div v-else-if="activeWidgetMenu">
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 10px">
            <div
              v-for="it in activeWidgetMenu.items"
              :key="it.label"
              @click="it.onClick()"
              class="widget-row"
              style="display: flex; align-items: center; gap: 10px; padding: 12px 14px; border-radius: 10px; cursor: pointer; background: var(--card); border: 1px solid rgba(var(--line-rgb), 0.12)"
            >
              <i :class="'bi ' + it.icon" :style="{ color: accent }" style="font-size: 17px; width: 20px; text-align: center; flex: none"></i>
              <span style="flex: 1; font-size: 14px; color: var(--text); font-weight: 600">{{ it.label }}</span>
              <span style="font-size: 12px; color: var(--muted)">{{ it.count }}</span>
            </div>
          </div>
          <div
            @click="activeWidgetMenu.onClick()"
            :style="{ color: accent }"
            style="display: inline-flex; align-items: center; gap: 6px; margin-top: 16px; font-size: 13.5px; font-weight: 600; cursor: pointer"
          >
            Xem chi tiết →
          </div>
        </div>
      </div>
    </div>
  </header>
</template>

<style scoped>
.widget-row:hover {
  background: color-mix(in srgb, var(--acc, #c6ff4a) 10%, transparent);
  color: var(--text) !important;
}
</style>
