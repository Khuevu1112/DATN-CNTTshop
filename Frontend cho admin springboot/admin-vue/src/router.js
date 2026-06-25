import { createRouter, createWebHistory } from 'vue-router';
import AdminLayout from './layouts/AdminLayout.vue';

const routes = [
  {
    path: '/',
    component: AdminLayout,
    children: [
      { path: '', redirect: '/dashboard' },
      {
        path: 'dashboard',
        name: 'dashboard',
        component: () => import('./views/Dashboard.vue'),
        meta: {
          title: 'Bảng điều khiển',
          sub: 'Tổng quan hoạt động cửa hàng hôm nay',
        },
      },
      {
        path: 'analytics',
        name: 'analytics',
        component: () => import('./views/Analytics.vue'),
        meta: {
          title: 'Phân tích',
          sub: 'Báo cáo & biểu đồ chi tiết theo thời gian',
        },
      },
      {
        path: 'orders',
        name: 'orders',
        component: () => import('./views/Orders.vue'),
        meta: { title: 'Đơn hàng', sub: 'Theo dõi & cập nhật trạng thái đơn' },
      },
      {
        path: 'products',
        name: 'products',
        component: () => import('./views/Products.vue'),
        meta: { title: 'Sản phẩm', sub: '27 sản phẩm · quản lý kho & giá' },
      },
      {
        path: 'categories',
        name: 'categories',
        component: () => import('./views/Categories.vue'),
        meta: { title: 'Danh mục', sub: 'Cấu trúc danh mục sản phẩm' },
      },
      {
        path: 'customers',
        name: 'customers',
        component: () => import('./views/Customers.vue'),
        meta: { title: 'Khách hàng', sub: 'Danh sách tài khoản & lịch sử mua' },
      },
      {
        path: 'coupons',
        name: 'coupons',
        component: () => import('./views/Coupons.vue'),
        meta: { title: 'Khuyến mãi', sub: 'Mã giảm giá & chương trình' },
      },
      {
        path: 'shipping',
        name: 'shipping',
        component: () => import('./views/Shipping.vue'),
        meta: {
          title: 'Phí giao hàng',
          sub: 'Cấu hình vùng & biểu phí vận chuyển',
        },
      },
    ],
  },
];

export default createRouter({ history: createWebHistory(), routes });
