import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import { usePermissionsStore } from '../stores/permissions';
import AdminLayout from '../layouts/AdminLayout.vue';

const routes = [
  {
    path: '/login',
    name: 'login',
    component: () => import('../views/LoginView.vue'),
    meta: { public: true },
  },
  {
    path: '/',
    component: AdminLayout,
    children: [
      { path: '', redirect: () => ({ name: firstAccessibleRouteName() || 'dashboard' }) },
      {
        path: 'dashboard',
        name: 'dashboard',
        component: () => import('../views/Dashboard.vue'),
        meta: {
          title: 'Bảng điều khiển',
          sub: 'Tổng quan hoạt động cửa hàng hôm nay',
          feature: 'dashboard',
        },
      },
      {
        path: 'analytics',
        name: 'analytics',
        component: () => import('../views/Analytics.vue'),
        meta: {
          title: 'Phân tích',
          sub: 'Báo cáo & biểu đồ chi tiết theo thời gian',
          feature: 'analytics',
        },
      },
      {
        path: 'orders',
        name: 'orders',
        component: () => import('../views/Orders.vue'),
        meta: { title: 'Đơn hàng', sub: 'Theo dõi & cập nhật trạng thái đơn', feature: 'orders' },
      },
      {
        path: 'products',
        name: 'products',
        component: () => import('../views/Products.vue'),
        meta: { title: 'Sản phẩm', sub: 'Danh mục, kho & giá sản phẩm', feature: 'products_view' },
      },
      {
        path: 'goods-receipts',
        name: 'goods-receipts',
        component: () => import('../views/GoodsReceipts.vue'),
        meta: {
          title: 'Nhập kho',
          sub: 'Phiếu nhập kho theo nhà cung cấp, xuất chứng từ cho kế toán',
          feature: 'products_view',
        },
      },
      {
        path: 'kit-templates',
        name: 'kit-templates',
        component: () => import('../views/KitTemplates.vue'),
        meta: {
          title: 'Mẫu cấu hình PC',
          sub: 'Định nghĩa sẵn bộ linh kiện để áp dụng nhanh khi tạo sản phẩm',
          feature: 'kit_templates_view',
        },
      },
      {
        path: 'customers',
        name: 'customers',
        component: () => import('../views/Customers.vue'),
        meta: { title: 'Quản lý tài khoản', sub: 'Nhân viên & khách hàng', feature: 'accounts_customer' },
      },
      {
        path: 'customers/:id',
        name: 'customer-detail',
        component: () => import('../views/CustomerDetail.vue'),
        meta: { title: 'Chi tiết tài khoản', sub: 'Thông tin cá nhân, phân quyền & trạng thái', feature: 'account_detail' },
      },
      {
        path: 'coupons',
        name: 'coupons',
        component: () => import('../views/Coupons.vue'),
        meta: { title: 'Khuyến mãi', sub: 'Mã giảm giá & chương trình', feature: 'coupons' },
      },
      {
        path: 'articles',
        name: 'articles',
        component: () => import('../views/Articles.vue'),
        meta: { title: 'Tin tức', sub: 'Bài viết blog: review, hướng dẫn, khuyến mãi', feature: 'articles' },
      },
      {
        path: 'contacts',
        name: 'contacts',
        component: () => import('../views/Contacts.vue'),
        meta: { title: 'Liên hệ', sub: 'Yêu cầu hỗ trợ & tư vấn từ khách hàng', feature: 'contacts' },
      },
      {
        path: 'trade-in',
        name: 'trade-in',
        component: () => import('../views/TradeIn.vue'),
        meta: {
          title: 'Thu cũ đổi mới',
          sub: 'Định giá máy cũ khách gửi và cấp tín dụng mua hàng',
          feature: 'trade_in',
        },
      },
      {
        path: 'warranty',
        name: 'warranty',
        component: () => import('../views/Warranty.vue'),
        meta: { title: 'Bảo hành', sub: 'Phiếu bảo hành & yêu cầu xử lý từ khách hàng', feature: 'warranty' },
      },
      {
        path: 'service-appointments',
        name: 'service-appointments',
        component: () => import('../views/ServiceAppointments.vue'),
        meta: {
          title: 'Lịch hẹn dịch vụ',
          sub: 'Khách hẹn mang máy tới trung tâm bảo hành',
          feature: 'service_appointment',
        },
      },
      {
        path: 'returns',
        name: 'returns',
        component: () => import('../views/Returns.vue'),
        meta: {
          title: 'Đổi trả hàng',
          sub: 'Yêu cầu đổi trả 1-đổi-1 trong 7 ngày kèm minh chứng',
          feature: 'return_request',
        },
      },
      {
        path: 'support-content',
        name: 'support-content',
        component: () => import('../views/SupportContent.vue'),
        meta: {
          title: 'Nội dung hỗ trợ',
          sub: 'Trung tâm bảo hành, bảng giá sửa chữa, chính sách và FAQ',
          feature: 'support_content',
        },
      },
      {
        path: 'shipping',
        name: 'shipping',
        component: () => import('../views/Shipping.vue'),
        meta: {
          title: 'Phí giao hàng',
          sub: 'Cấu hình vùng & biểu phí vận chuyển',
          feature: 'shipping',
        },
      },
    ],
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

// Không phải phòng ban nào cũng có quyền "dashboard" (VD Kho/Kỹ thuật/Giao hàng theo ma trận gốc)
// nên không thể mặc định điều hướng ai cũng về /dashboard — phải tìm trang đầu tiên họ thực sự
// vào được, tránh vòng lặp redirect vô hạn khi trang mặc định lại chính là trang họ bị chặn.
const adminChildren = routes.find((r) => r.path === '/').children;
function firstAccessibleRouteName() {
  const permissions = usePermissionsStore();
  const found = adminChildren.find((r) => r.meta?.feature && permissions.canAccess(r.meta.feature));
  return found?.name || null;
}

router.beforeEach(async (to) => {
  const auth = useAuthStore();
  if (!to.meta.public && !auth.isAuthenticated) return { name: 'login' };
  if (to.name === 'login' && auth.isAuthenticated) return { name: 'dashboard' };
  if (to.meta.public || !auth.isAuthenticated) return;

  const permissions = usePermissionsStore();
  if (!permissions.loaded) {
    try {
      await permissions.load();
    } catch (e) {
      return; // token hỏng -> interceptor 401 của http.js sẽ tự lo việc đăng xuất
    }
  }

  if (to.meta.feature && !permissions.canAccess(to.meta.feature)) {
    const fallback = firstAccessibleRouteName();
    // Không có gì để chuyển tới (hoặc trang đích đã chính là fallback) -> để trang tự hiển thị
    // rỗng/lỗi qua các lời gọi API 422, tránh lặp vô hạn thay vì cố redirect tiếp.
    if (!fallback || fallback === to.name) return;
    return { name: fallback };
  }
});

export default router;
