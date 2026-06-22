<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import TheHeader from '../components/TheHeader.vue'
import TheFooter from '../components/TheFooter.vue'

const route = useRoute()
const dimChrome = computed(() => route.meta.authLayout === true)
</script>

<template>
  <TheHeader :class="{ 'chrome-dim': dimChrome }" />
  <main class="app-main">
    <div class="page-wrap"><slot /></div>
  </main>
  <TheFooter :class="{ 'chrome-dim': dimChrome }" />
</template>
