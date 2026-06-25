<script setup>
import { computed } from 'vue'
import { state, accent, themeStyle } from './store.js'
import AppHeader from './components/AppHeader.vue'
import AppFooter from './components/AppFooter.vue'
import ToastMessage from './components/ToastMessage.vue'
import LoadingOverlay from './components/LoadingOverlay.vue'
import HomeView from './views/HomeView.vue'
import CategoryView from './views/CategoryView.vue'
import DetailView from './views/DetailView.vue'
import CartView from './views/CartView.vue'

const views = { home: HomeView, category: CategoryView, detail: DetailView, cart: CartView }
const currentView = computed(() => views[state.route] || HomeView)

const rootStyle = computed(() => ({
  '--acc': accent.value,
  minHeight: '100vh',
  background: themeStyle.value.pageBg,
  color: themeStyle.value.ink,
  fontFamily: "'Be Vietnam Pro', sans-serif",
  WebkitFontSmoothing: 'antialiased'
}))
</script>

<template>
  <div :style="rootStyle">
    <AppHeader />
    <ToastMessage />
    <LoadingOverlay />
    <component :is="currentView" />
    <AppFooter />
  </div>
</template>
