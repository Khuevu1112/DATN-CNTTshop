import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import { initMode } from './store';
import './style.css';

initMode();
createApp(App).use(router).mount('#app');
