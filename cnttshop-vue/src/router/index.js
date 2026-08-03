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
    // "Quản lý bảo hành cá nhân" — trang riêng, KHÔNG còn là tab của AccountView. Việc đánh giá
    // sản phẩm vẫn nằm ở tab "Sản phẩm đã mua" trong Tài khoản (mở bằng nút tab, không qua route).
    path: '/tai-khoan/bao-hanh',
    name: 'warranty',
    component: () => import('../views/WarrantyManageView.vue'),
  },
  // ===== Trung tâm hỗ trợ =====
  // Tất cả công khai trừ /ho-tro/lich-hen (trang tự xử lý khi chưa đăng nhập bằng cách cho tra
  // theo mã lịch — khách vãng lai đặt lịch được thì cũng phải xem lại được).
  { path: '/ho-tro', name: 'support', component: () => import('../views/SupportView.vue') },
  {
    path: '/ho-tro/trung-tam-bao-hanh',
    name: 'service-centers',
    component: () => import('../views/ServiceCenterView.vue'),
  },
  {
    path: '/ho-tro/thong-tin-bao-hanh',
    name: 'warranty-info',
    component: () => import('../views/WarrantyInfoView.vue'),
  },
  {
    path: '/ho-tro/bang-gia-sua-chua',
    name: 'repair-price',
    component: () => import('../views/RepairPriceView.vue'),
  },
  { path: '/ho-tro/hoi-dap', name: 'faq', component: () => import('../views/FaqView.vue') },
  {
    path: '/ho-tro/doi-tra',
    name: 'return-policy',
    component: () => import('../views/ReturnPolicyView.vue'),
  },
  {
    path: '/tra-gop',
    name: 'installment-policy',
    component: () => import('../views/InstallmentPolicyView.vue'),
  },
  {
    path: '/cam-ket',
    name: 'commitment',
    component: () => import('../views/CommitmentView.vue'),
  },
  {
    path: '/ho-tro/lich-hen',
    name: 'appointments',
    component: () => import('../views/AppointmentsView.vue'),
  },

  { path: '/tin-tuc', name: 'news', component: () => import('../views/NewsView.vue') },
  { path: '/yeu-thich', name: 'wishlist', component: () => import('../views/WishlistView.vue') },
  { path: '/tin-tuc/:slug', name: 'article', component: () => import('../views/ArticleView.vue') },

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
