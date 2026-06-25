<template>
  <div style="display: flex; min-height: 100vh; background: var(--page)">
    <aside
      style="
        width: 248px;
        flex: none;
        background: var(--bg);
        border-right: 1px solid var(--line);
        display: flex;
        flex-direction: column;
        position: sticky;
        top: 0;
        height: 100vh;
      "
    >
      <div
        style="
          display: flex;
          align-items: center;
          gap: 11px;
          padding: 18px 20px 16px;
        "
      >
        <div
          style="
            width: 30px;
            height: 30px;
            transform: rotate(45deg);
            border-radius: 7px;
            background: linear-gradient(135deg, var(--acc), #0b4f9e);
            box-shadow: 0 0 18px color-mix(in srgb, var(--acc) 55%, transparent);
          "
        ></div>
        <div>
          <div
            class="mono"
            style="
              font-weight: 700;
              font-size: 17px;
              letter-spacing: 0.5px;
              color: var(--text);
              line-height: 1;
            "
          >
            CNTT<span style="color: var(--acc)">shop</span>
          </div>
          <div
            style="
              font-size: 10.5px;
              color: var(--muted);
              letter-spacing: 1.5px;
              text-transform: uppercase;
              margin-top: 3px;
            "
          >
            Admin Console
          </div>
        </div>
      </div>
      <nav style="flex: 1; overflow-y: auto; padding: 6px 12px">
        <template v-for="grp in groups" :key="grp.title">
          <div
            style="
              font-size: 10px;
              font-weight: 600;
              color: var(--muted);
              text-transform: uppercase;
              letter-spacing: 1px;
              padding: 14px 10px 6px;
            "
          >
            {{ grp.title }}
          </div>
          <button
            v-for="it in grp.items"
            :key="it[0]"
            @click="go(it[0])"
            style="
              width: 100%;
              display: flex;
              align-items: center;
              gap: 11px;
              padding: 9px 10px;
              margin-bottom: 2px;
              border: none;
              border-radius: 9px;
              cursor: pointer;
              text-align: left;
              font-size: 13.5px;
              font-weight: 500;
              transition: background 0.12s;
            "
            :style="{
              background: active(it[0])
                ? 'color-mix(in srgb,var(--acc) 14%,transparent)'
                : 'transparent',
              color: active(it[0]) ? 'var(--acc)' : 'var(--muted2)',
            }"
          >
            <i
              class="bi"
              :class="it[2]"
              style="font-size: 15px; width: 18px; text-align: center"
            ></i>
            <span style="flex: 1">{{ it[1] }}</span>
            <span
              v-if="it[3]"
              class="mono"
              style="
                font-size: 11px;
                font-weight: 700;
                padding: 1px 7px;
                border-radius: 9px;
                background: color-mix(in srgb, var(--acc) 18%, transparent);
                color: var(--acc);
              "
              >{{ it[3] }}</span
            >
          </button>
        </template>
      </nav>
      <div style="padding: 12px; border-top: 1px solid var(--line)">
        <div
          style="
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 8px 10px;
            border-radius: 10px;
            background: var(--card);
            border: 1px solid var(--line);
          "
        >
          <div
            class="mono"
            style="
              width: 34px;
              height: 34px;
              border-radius: 9px;
              background: linear-gradient(135deg, var(--acc), #0b4f9e);
              color: #04121f;
              display: flex;
              align-items: center;
              justify-content: center;
              font-weight: 700;
              font-size: 14px;
              flex: none;
            "
          >
            {{ initials }}
          </div>
          <div style="flex: 1; min-width: 0">
            <div
              style="
                font-size: 13px;
                font-weight: 600;
                color: var(--text);
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
              "
            >
              {{ auth.displayName }}
            </div>
            <div
              style="
                font-size: 11px;
                color: var(--muted);
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
              "
            >
              {{ auth.user?.email }}
            </div>
          </div>
          <i
            @click="logout"
            title="Đăng xuất"
            class="bi bi-box-arrow-right"
            style="color: var(--muted); font-size: 15px; cursor: pointer"
          ></i>
        </div>
      </div>
    </aside>

    <div style="flex: 1; min-width: 0; display: flex; flex-direction: column">
      <header
        style="
          position: sticky;
          top: 0;
          z-index: 30;
          background: color-mix(in srgb, var(--page) 86%, transparent);
          backdrop-filter: blur(12px);
          border-bottom: 1px solid var(--line);
          display: flex;
          align-items: center;
          gap: 16px;
          padding: 13px 26px;
        "
      >
        <div style="flex: none">
          <div
            style="
              font-size: 17px;
              font-weight: 700;
              color: var(--text);
              line-height: 1.1;
            "
          >
            {{ route.meta.title }}
          </div>
          <div style="font-size: 12px; color: var(--muted); margin-top: 2px">
            {{ route.meta.sub }}
          </div>
        </div>
        <div style="flex: 1; display: flex; justify-content: center">
          <div
            style="
              width: 100%;
              max-width: 420px;
              display: flex;
              align-items: center;
              gap: 9px;
              background: var(--card);
              border: 1px solid var(--line2);
              border-radius: 10px;
              padding: 0 13px;
              height: 38px;
            "
          >
            <i
              class="bi bi-search"
              style="color: var(--muted); font-size: 14px"
            ></i>
            <input
              v-model="ui.search"
              placeholder="Tìm sản phẩm, đơn hàng, khách hàng..."
              style="
                flex: 1;
                background: transparent;
                border: none;
                outline: none;
                color: var(--text);
                font-size: 13px;
              "
            />
          </div>
        </div>
        <div style="flex: none; display: flex; align-items: center; gap: 8px">
          <button
            @click="toggleMode"
            title="Sáng / Tối"
            style="
              width: 38px;
              height: 38px;
              border-radius: 10px;
              border: 1px solid var(--line2);
              background: var(--card);
              color: var(--text);
              cursor: pointer;
              font-size: 15px;
              display: flex;
              align-items: center;
              justify-content: center;
            "
          >
            <i
              class="bi"
              :class="ui.mode === 'dark' ? 'bi-sun' : 'bi-moon-stars'"
            ></i>
          </button>

          <div style="position: relative">
            <button
              @click="toggleBell"
              title="Thông báo"
              style="
                width: 38px;
                height: 38px;
                border-radius: 10px;
                border: 1px solid var(--line2);
                background: var(--card);
                color: var(--text);
                cursor: pointer;
                font-size: 15px;
                position: relative;
                display: flex;
                align-items: center;
                justify-content: center;
              "
            >
              <i class="bi bi-bell"></i>
              <span
                v-if="unreadCount"
                style="
                  position: absolute;
                  top: 5px;
                  right: 5px;
                  min-width: 14px;
                  height: 14px;
                  padding: 0 3px;
                  border-radius: 7px;
                  background: var(--sale);
                  color: #fff;
                  font-size: 9.5px;
                  line-height: 14px;
                  font-weight: 700;
                "
                >{{ unreadCount > 9 ? '9+' : unreadCount }}</span
              >
            </button>

            <div
              v-if="bellOpen"
              @click="bellOpen = false"
              style="position: fixed; inset: 0; z-index: 39"
            ></div>
            <div
              v-if="bellOpen"
              style="
                position: absolute;
                top: 48px;
                right: 0;
                width: 340px;
                max-height: 420px;
                overflow-y: auto;
                background: var(--card);
                border: 1px solid var(--line2);
                border-radius: 13px;
                box-shadow: 0 16px 40px rgba(0, 0, 0, 0.4);
                z-index: 40;
              "
            >
              <div
                style="
                  display: flex;
                  align-items: center;
                  justify-content: space-between;
                  padding: 12px 14px;
                  border-bottom: 1px solid var(--line);
                "
              >
                <span
                  style="
                    font-size: 13.5px;
                    font-weight: 700;
                    color: var(--text);
                  "
                  >Thông báo</span
                >
                <button
                  v-if="unreadCount"
                  @click="onMarkAllRead"
                  style="
                    background: none;
                    border: none;
                    color: var(--acc);
                    font-size: 12px;
                    font-weight: 600;
                    cursor: pointer;
                  "
                >
                  Đánh dấu đã đọc hết
                </button>
              </div>
              <div
                v-if="loadingBell"
                style="
                  padding: 24px;
                  text-align: center;
                  color: var(--muted);
                  font-size: 13px;
                "
              >
                Đang tải...
              </div>
              <div
                v-else-if="!notifications.length"
                style="
                  padding: 28px 14px;
                  text-align: center;
                  color: var(--muted);
                  font-size: 13px;
                "
              >
                Chưa có thông báo nào.
              </div>
              <div v-else>
                <div
                  v-for="n in notifications"
                  :key="n.id"
                  @click="onClickNotification(n)"
                  style="
                    display: flex;
                    gap: 10px;
                    padding: 11px 14px;
                    border-bottom: 1px solid var(--line);
                    cursor: pointer;
                  "
                  :style="{
                    background: n.isRead
                      ? 'transparent'
                      : 'color-mix(in srgb, var(--acc) 7%, transparent)',
                  }"
                >
                  <span
                    style="
                      width: 7px;
                      height: 7px;
                      border-radius: 50%;
                      flex: none;
                      margin-top: 5px;
                    "
                    :style="{
                      background: n.isRead ? 'transparent' : 'var(--acc)',
                    }"
                  ></span>
                  <div style="flex: 1; min-width: 0">
                    <div
                      style="
                        font-size: 13px;
                        font-weight: 600;
                        color: var(--text);
                      "
                    >
                      {{ n.title }}
                    </div>
                    <div
                      style="
                        font-size: 12px;
                        color: var(--muted2);
                        margin-top: 2px;
                        line-height: 1.4;
                      "
                    >
                      {{ n.message }}
                    </div>
                    <div
                      style="
                        font-size: 11px;
                        color: var(--muted);
                        margin-top: 4px;
                      "
                    >
                      {{ timeAgo(n.createdAt) }}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </header>
      <main style="flex: 1; padding: 22px 26px 60px">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { NAV_GROUPS, initials as initialsOf } from '../data/adminData';
import { ui, toggleMode } from '../uiState';
import { useAuthStore } from '../stores/auth';
import {
  getNotifications,
  getUnreadCount,
  markNotificationRead,
  markAllNotificationsRead,
} from '../api/admin';

const route = useRoute();
const router = useRouter();
const auth = useAuthStore();
const groups = NAV_GROUPS;

const go = (name) => router.push('/' + name);
const active = (name) => route.name === name;
const initials = computed(() =>
  initialsOf(auth.displayName || 'Quản trị viên'),
);

function logout() {
  auth.logout();
  router.push('/login');
}

const bellOpen = ref(false);
const loadingBell = ref(false);
const notifications = ref([]);
const unreadCount = ref(0);

async function refreshUnreadCount() {
  try {
    unreadCount.value = await getUnreadCount();
  } catch (e) {
    /* im lặng, không làm phiền admin nếu lỗi mạng tạm thời */
  }
}

async function toggleBell() {
  bellOpen.value = !bellOpen.value;
  if (bellOpen.value) {
    loadingBell.value = true;
    try {
      notifications.value = await getNotifications();
    } finally {
      loadingBell.value = false;
    }
  }
}

async function onClickNotification(n) {
  if (!n.isRead) {
    await markNotificationRead(n.id);
    n.isRead = true;
    refreshUnreadCount();
  }
  bellOpen.value = false;
  if (n.link) router.push(n.link);
}

async function onMarkAllRead() {
  await markAllNotificationsRead();
  notifications.value.forEach((n) => {
    n.isRead = true;
  });
  unreadCount.value = 0;
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

let pollTimer = null;
onMounted(() => {
  refreshUnreadCount();
  pollTimer = setInterval(refreshUnreadCount, 30000);
});
onUnmounted(() => {
  if (pollTimer) clearInterval(pollTimer);
});
</script>
