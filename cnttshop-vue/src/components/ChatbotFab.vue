<script setup>
/**
 * Nút tròn nổi mở Trợ lý chat — xếp NGAY TRÊN nút So sánh ở góc phải màn hình (xem
 * CompareFab: bottom 22px + 56px cao + 12px khoảng cách = 90px cho nút này).
 * Tách khỏi ChatbotDrawer.vue để component drawer (nặng, nhiều logic) không phải mount
 * ngay từ đầu — chỉ mount khi state.chatOpen bật lần đầu tiên.
 */
import { state, actions } from '../store.js';
</script>

<template>
  <button class="cbfab" :title="state.chatOpen ? 'Đóng trợ lý' : 'Trợ lý CNTTshop'" @click="actions.toggleChat()">
    <span v-if="!state.chatOpen">💬</span>
    <span v-else>✕</span>
  </button>
</template>

<style scoped>
.cbfab {
  position: fixed;
  right: 22px;
  bottom: 90px;
  z-index: 200;
  width: 56px;
  height: 56px;
  border-radius: 50%;
  border: none;
  background: var(--acc, #c6ff4a);
  color: var(--acc-ink, #04121f);
  font-size: 24px;
  cursor: pointer;
  box-shadow: 0 10px 26px rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.16s;
}
.cbfab:hover { transform: translateY(-2px); }
</style>
