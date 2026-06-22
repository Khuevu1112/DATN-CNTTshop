import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import { isLoading } from '../composables/loading'

// Placeholder tạm cho các trang sẽ làm ở bước sau (giỏ hàng, tài khoản...)
const Placeholder = {
  template: `<div class="text-center py-5">
    <i class="bi bi-cone-striped fs-1 text-navy"></i>
    <h4 class="mt-3">Tính năng đang được phát triển</h4>
    <router-link to="/" class="btn btn-navy mt-2">Về trang chủ</router-link>
  </div>`
}

// Lưu ý: trang QUẢN TRỊ dùng bản Thymeleaf có sẵn (chạy tại http://localhost:8080/admin),
// không nằm trong SPA Vue này. Vue chỉ phục vụ phần khách hàng.
const routes = [
  { path: '/', name: 'home', component: HomeView },
  { path: '/products', name: 'products', component: () => import('../views/ProductListView.vue') },
  { path: '/category/:slug', name: 'category', component: () => import('../views/ProductListView.vue') },
  { path: '/product/:slug', name: 'product-detail', component: () => import('../views/ProductDetailView.vue') },

  { path: '/login', name: 'login', component: () => import('../views/LoginView.vue'), meta: { authLayout: true } },
  { path: '/register', name: 'register', component: () => import('../views/RegisterView.vue'), meta: { authLayout: true } },
  { path: '/forgot-password', name: 'forgot-password', component: Placeholder, meta: { authLayout: true } },

  { path: '/cart', name: 'cart', component: Placeholder },
  { path: '/account', name: 'account', component: Placeholder },
  { path: '/orders', name: 'orders', component: Placeholder },

  { path: '/:pathMatch(.*)*', redirect: '/' }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() { return { top: 0 } }
})

// Hiển thị loading (logo xoay) khi chuyển trang, giữ tối thiểu ~0.5s cho mượt
let hideTimer = null
router.beforeEach(() => {
  clearTimeout(hideTimer)
  isLoading.value = true
})
router.afterEach(() => {
  hideTimer = setTimeout(() => { isLoading.value = false }, 500)
})

export default router
