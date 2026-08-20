<template>
  <div v-if="alerts.length" style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 18px; margin-bottom: 16px">
    <div
      v-for="(a, idx) in alerts"
      :key="idx"
      class="ai-alert"
      :class="a.severity === 'danger' ? 'ai-alert-danger' : 'ai-alert-warning'"
      :style="{ marginBottom: idx < alerts.length - 1 ? '8px' : '0' }"
    >
      <i class="bi bi-exclamation-triangle-fill"></i>
      <div>
        <b>{{ a.title }}</b>
        <div style="font-size: 12px; margin-top: 2px; opacity: 0.9">{{ a.message }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { getAiAlerts } from '../api/admin';

const alerts = ref([]);

async function loadAlerts() {
  try {
    const data = await getAiAlerts();
    alerts.value = data.alerts || [];
  } catch (e) {
    alerts.value = [];
  }
}

defineExpose({ refresh: loadAlerts });

onMounted(loadAlerts);
</script>

<style scoped>
.ai-alert {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 10px 12px;
  border-radius: 9px;
  font-size: 13px;
}
.ai-alert-danger {
  background: color-mix(in srgb, var(--sale) 14%, transparent);
  color: var(--sale);
}
.ai-alert-warning {
  background: color-mix(in srgb, var(--amber) 16%, transparent);
  color: var(--amber);
}
</style>
