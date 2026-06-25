<script setup>
import { state, accent } from '../store.js'
</script>

<template>
  <div v-if="state.toast" :style="{ border: '1px solid ' + accent, boxShadow: '0 16px 40px rgba(0,0,0,0.5), 0 0 0 1px color-mix(in srgb, ' + accent + ' 30%, transparent)' }" style="position:fixed; left:50%; bottom:28px; transform:translateX(-50%); z-index:90; background:#0c2742; color:#e8f1fc; padding:13px 20px; border-radius:12px; font-size:13.5px; font-weight:500; display:flex; align-items:center; gap:10px; animation:fadeUp .25s ease;">
    <span :style="{ color: accent }" style="font-size:16px;">✓</span> {{ state.toast }}
  </div>
</template>
