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
            QT
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
              Quản trị viên
            </div>
            <div style="font-size: 11px; color: var(--muted)">
              admin@cnttshop.vn
            </div>
          </div>
          <i
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
            <kbd
              class="mono"
              style="
                font-size: 10px;
                color: var(--muted);
                border: 1px solid var(--line2);
                border-radius: 5px;
                padding: 1px 5px;
              "
              >/</kbd
            >
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
          <button
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
            <i class="bi bi-bell"></i
            ><span
              style="
                position: absolute;
                top: 7px;
                right: 8px;
                width: 7px;
                height: 7px;
                border-radius: 50%;
                background: var(--sale);
              "
            ></span>
          </button>
          <button
            style="
              display: flex;
              align-items: center;
              gap: 7px;
              height: 38px;
              padding: 0 15px;
              border-radius: 10px;
              border: none;
              background: var(--acc);
              color: #04121f;
              font-weight: 700;
              font-size: 13px;
              cursor: pointer;
              box-shadow: 0 6px 18px
                color-mix(in srgb, var(--acc) 32%, transparent);
            "
          >
            <i class="bi bi-plus-lg"></i> Tạo mới
          </button>
        </div>
      </header>
      <main style="flex: 1; padding: 22px 26px 60px">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { useRoute, useRouter } from 'vue-router';
import { NAV_GROUPS } from '../data/adminData';
import { ui, toggleMode } from '../store';
const route = useRoute();
const router = useRouter();
const groups = NAV_GROUPS;
const go = (name) => router.push('/' + name);
const active = (name) => route.name === name;
</script>
