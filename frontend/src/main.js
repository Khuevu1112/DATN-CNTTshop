import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router'

// Bootstrap (CSS + JS bundle) + icons
import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap-icons/font/bootstrap-icons.css'
import 'bootstrap/dist/js/bootstrap.bundle.min.js'

// Theme dự án (Arial + navy) — load sau Bootstrap để override
import './style.css'

import App from './App.vue'

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.mount('#app')
