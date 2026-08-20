<template>
  <div style="animation: fadeUp 0.35s ease; max-width: 720px">
    <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 14px">
      <i class="bi bi-stars" style="color: var(--acc); font-size: 18px"></i>
      <div style="font-size: 15px; font-weight: 700; color: var(--text)">AI Phân tích</div>
    </div>

    <AiInsightWidget />

    <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 16px 18px; font-size: 12.5px; color: var(--muted)">
      <b style="color: var(--muted2)">Về tính năng này:</b> Hệ thống tự phân tích số liệu kinh doanh (doanh thu,
      dòng tiền, đơn hàng, tồn kho...) và phát hiện bất thường bằng ngưỡng số cố định.
    </div>
  </div>
</template>

<script setup>
import AiInsightWidget from '../components/AiInsightWidget.vue';
</script>
