<script setup>
/**
 * Nút tròn nổi mở bảng So sánh — cùng phong cách với nút chatbot, xếp NGAY DƯỚI nút chatbot
 * ở góc phải màn hình (chatbot được đẩy lên trên, xem ChatbotWidget.cbw-root).
 * Badge hiện số cấu hình đang so sánh để khách biết mình đã chọn mấy cái mà không phải mở ra.
 */
import { state, actions } from '../store.js';
</script>

<template>
  <button
    class="cmpfab"
    :class="{ 'has-items': state.compareItems.length }"
    title="So sánh cấu hình"
    @click="actions.toggleCompare()"
  >
    <span class="cmpfab-icon">⇄</span>
    <span v-if="state.compareItems.length" class="cmpfab-badge">{{ state.compareItems.length }}</span>
  </button>
</template>

<style scoped>
.cmpfab {
  position: fixed;
  right: 22px;
  bottom: 22px;
  z-index: 200;
  width: 56px;
  height: 56px;
  border-radius: 50%;
  border: 1px solid rgba(var(--line-rgb), 0.25);
  background: var(--card, #0a2138);
  color: var(--muted2);
  cursor: pointer;
  box-shadow: 0 10px 26px rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: border-color 0.16s, color 0.16s, transform 0.16s;
}
.cmpfab:hover { transform: translateY(-2px); border-color: var(--acc, #c6ff4a); color: var(--acc, #c6ff4a); }
/* Đang có cấu hình trong danh sách thì nút sáng lên để nhắc khách còn dở việc so sánh. */
.cmpfab.has-items { border-color: var(--acc, #c6ff4a); color: var(--acc, #c6ff4a); }
.cmpfab-icon { font-size: 23px; line-height: 1; font-weight: 700; }
.cmpfab-badge {
  position: absolute;
  top: -3px;
  right: -3px;
  min-width: 21px;
  height: 21px;
  padding: 0 5px;
  border-radius: 11px;
  background: var(--acc, #c6ff4a);
  color: var(--acc-ink, #04121f);
  font-size: 11.5px;
  font-weight: 800;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Plus Jakarta Sans', sans-serif;
}
</style>
