<script setup>
import { computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import DefaultLayout from './layouts/DefaultLayout.vue'
import BlankLayout from './layouts/BlankLayout.vue'
import LoadingOverlay from './components/LoadingOverlay.vue'
import { isLoading } from './composables/loading'
import { initAccent, initMode } from './composables/theme'

const route = useRoute()
// Trang auth (login/register/forgot) dùng layout trống — không header/footer
const layout = computed(() => (route.meta.authLayout ? BlankLayout : DefaultLayout))

onMounted(() => { initAccent(); initMode() })
</script>

<template>
  <component :is="layout">
    <router-view />
  </component>

  <LoadingOverlay v-if="isLoading" />
</template>
