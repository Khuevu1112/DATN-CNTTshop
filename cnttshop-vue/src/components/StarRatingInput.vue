<script setup>
defineProps({
  modelValue: { type: Number, default: 0 },
  size: { type: Number, default: 24 },
  readonly: { type: Boolean, default: false },
});
const emit = defineEmits(['update:modelValue']);
</script>

<template>
  <div style="display: flex; gap: 4px">
    <span
      v-for="i in 5" :key="i"
      @click="!readonly && emit('update:modelValue', i)"
      :style="{
        fontSize: size + 'px',
        color: i <= modelValue ? '#ffb43b' : 'var(--muted)',
        cursor: readonly ? 'default' : 'pointer',
        lineHeight: 1,
      }"
      >★</span
    >
  </div>
</template>
