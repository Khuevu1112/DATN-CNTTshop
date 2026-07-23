import { createRouter, createWebHashHistory } from 'vue-router'
import Login from './views/Login.vue'
import Sales from './views/Sales.vue'
import Display from './views/Display.vue'

const routes = [
  { path: '/login', component: Login },
  { path: '/', component: Sales, meta: { requiresAuth: true } },
  { path: '/display', component: Display },
  { path: '/:pathMatch(.*)*', redirect: '/' }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

router.beforeEach((to) => {
  const token = localStorage.getItem('pos_token')
  if (to.meta.requiresAuth && !token) return '/login'
  if (to.path === '/login' && token) return '/'
})

export default router
