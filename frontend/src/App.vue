<script setup>
import { onMounted } from 'vue'
import DefaultLayout from './layouts/DefaultLayout.vue'
import LoadingOverlay from './components/LoadingOverlay.vue'
import { isLoading } from './composables/loading'
import { initAccent } from './composables/theme'

onMounted(initAccent)
</script>

<template>
  <DefaultLayout>
    <router-view />
  </DefaultLayout>

  <LoadingOverlay v-if="isLoading" />
</template>
