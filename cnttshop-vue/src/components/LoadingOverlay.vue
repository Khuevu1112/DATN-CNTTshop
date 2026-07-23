<script setup>
import { state, accent, themeStyle } from '../store.js';
import AppLogo from './AppLogo.vue';
</script>

<template>
  <div
    v-if="state.loading"
    :style="{ background: themeStyle.pageBg }"
    style="
      position: fixed;
      inset: 0;
      z-index: 120;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 26px;
    "
  >
    <div
      style="
        position: relative;
        width: 88px;
        height: 88px;
        display: flex;
        align-items: center;
        justify-content: center;
      "
    >
      <div
        :style="{
          borderTopColor: accent,
          boxShadow:
            '0 0 26px color-mix(in srgb, ' + accent + ' 35%, transparent)',
        }"
        style="
          position: absolute;
          inset: 0;
          border-radius: 50%;
          border: 3px solid rgba(var(--line-rgb), 0.14);
          animation: spin 0.8s linear infinite;
        "
      ></div>
      <div style="animation: spin 1.6s linear infinite">
        <AppLogo :size="30" :on-light="state.mode === 'light'" :accent-color="accent" />
      </div>
    </div>
    <div style="text-align: center">
      <div
        style="
          font-family: 'Chakra Petch', sans-serif;
          font-weight: 700;
          font-size: 20px;
          letter-spacing: 0.5px;
          color: var(--text);
        "
      >
        CNTT<span :style="{ color: accent }">shop</span>
      </div>
      <div style="font-size: 13px; color: var(--muted); margin-top: 6px">
        {{ state.loadingMsg }}
      </div>
    </div>
    <div
      style="
        width: 180px;
        height: 3px;
        border-radius: 3px;
        background: rgba(var(--line-rgb), 0.14);
        overflow: hidden;
      "
    >
      <div
        :style="{ background: accent }"
        style="
          width: 40%;
          height: 100%;
          border-radius: 3px;
          animation: barSlide 1s ease-in-out infinite;
        "
      ></div>
    </div>
  </div>
</template>
