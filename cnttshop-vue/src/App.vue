<script setup>
import { computed } from 'vue';
import { accent, themeStyle } from './store.js';
import AppHeader from './components/AppHeader.vue';
import AppFooter from './components/AppFooter.vue';
import ToastMessage from './components/ToastMessage.vue';
import LoadingOverlay from './components/LoadingOverlay.vue';
import WelcomePopup from './components/WelcomePopup.vue';
import ChatbotWidget from './components/ChatbotWidget.vue';

const rootStyle = computed(() => ({
  '--acc': accent.value,
  minHeight: '100vh',
  background: themeStyle.value.pageBg,
  color: themeStyle.value.ink,
  fontFamily: "'Plus Jakarta Sans', sans-serif",
  WebkitFontSmoothing: 'antialiased',
}));
</script>

<template>
  <div :style="rootStyle">
    <AppHeader />
    <ToastMessage />
    <LoadingOverlay />
    <router-view />
    <AppFooter />
    <WelcomePopup />
    <ChatbotWidget />
  </div>
</template>
