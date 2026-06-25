import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// admin-vue chạy cổng 5174 (backend CORS đã cho phép 5173 + 5174)
export default defineConfig({
  plugins: [vue()],
  server: { port: 5174 }
})
