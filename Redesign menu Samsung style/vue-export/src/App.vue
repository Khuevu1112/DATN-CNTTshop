<script setup>
import AppHeader from './components/AppHeader.vue';
</script>

<template>
  <div style="min-height: 100vh; background: var(--page)">
    <AppHeader />

    <!-- Nội dung trang (placeholder) để mega-menu đổ bóng lên như thật -->
    <div style="max-width: 1800px; margin: 0 auto; padding: 26px 24px 80px">
      <div
        style="
          height: 320px;
          border-radius: 18px;
          display: flex;
          align-items: center;
          justify-content: center;
          background: repeating-linear-gradient(
              45deg,
              rgba(var(--line-rgb), 0.04) 0 11px,
              transparent 11px 22px
            ),
            var(--card);
          border: 1px solid rgba(var(--line-rgb), 0.1);
        "
      >
        <span style="font-family: monospace; font-size: 12px; letter-spacing: 1px; color: var(--muted)">
          nội dung trang chủ · rê chuột vào menu để xem mega-menu
        </span>
      </div>
    </div>
  </div>
</template>
