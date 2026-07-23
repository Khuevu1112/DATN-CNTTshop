import { createRouter, createWebHistory } from 'vue-router';

const routes = [
  { path: '/', name: 'home', component: () => import('../views/HomeView.vue') },
  {
    path: '/danh-muc/:cat?',
    name: 'category',
    component: () => import('../views/CategoryView.vue'),
  },
  {
    path: '/san-pham/:id',
    name: 'detail',
    component: () => import('../views/DetailView.vue'),
  },
  { path: '/gio-hang', name: 'cart', component: () => import('../views/CartView.vue') },
  {
    path: '/thanh-toan',
    name: 'checkout',
    component: () => import('../views/CheckoutView.vue'),
  },
  { path: '/dang-nhap', name: 'login', component: () => import('../views/LoginView.vue') },
  { path: '/lien-he', name: 'contact', component: () => import('../views/ContactView.vue') },
  {
    path: '/khuyen-mai',
    name: 'promotions',
    component: () => import('../views/PromotionsView.vue'),
  },
  {
    path: '/tai-khoan',
    name: 'account',
    component: () => import('../views/AccountView.vue'),
  },
  {
    path: '/tai-khoan/don-hang',
    name: 'orders',
    component: () => import('../views/AccountView.vue'),
  },
  {
    path: '/tai-khoan/don-hang/:id/danh-gia',
    name: 'order-review',
    component: () => import('../views/AccountView.vue'),
  },
  {
    path: '/tai-khoan/bao-hanh',
    name: 'warranty',
    component: () => import('../views/AccountView.vue'),
  },
  { path: '/so-sanh', name: 'compare', component: () => import('../views/CompareView.vue') },
  {
    path: '/xay-dung-cau-hinh',
    name: 'pcbuild',
    component: () => import('../views/PcBuildView.vue'),
  },
  {
    path: '/ket-qua-thanh-toan',
    name: 'order-result',
    component: () => import('../views/OrderResultView.vue'),
  },
  { path: '/:pathMatch(.*)*', redirect: '/' },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 };
  },
});

export default router;
