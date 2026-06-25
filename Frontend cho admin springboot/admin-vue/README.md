# CNTTshop · Admin Console (Vue 3)

Frontend luồng quản trị cho dự án Spring Boot CNTTShop, port từ bản thiết kế gốc sang Vue 3 + Vite + vue-router.

## Chạy dev

```bash
cd admin-vue
npm install
npm run dev      # http://localhost:5174
```

## Build

```bash
npm run build
npm run preview
```

## Cấu trúc

- src/router.js — 8 route con dưới AdminLayout.
- src/layouts/AdminLayout.vue — sidebar + topbar + công tắc Sáng/Tối + ô tìm kiếm (chia sẻ qua store.js).
- src/store.js — state dùng chung: ui.search, ui.mode (dark/light, ghi vào data-mode).
- src/data/adminData.js — toàn bộ dữ liệu mẫu (27 SP PC/laptop, đơn, khách, coupon, vùng giao) + helper biểu đồ.
- src/views/\*.vue — Dashboard, Analytics, Products, Orders, Customers, Categories, Coupons, Shipping.

## Trang

- Bảng điều khiển — KPI, doanh thu 7 ngày, trạng thái đơn, đơn gần đây, sắp hết hàng.
- Phân tích — biểu đồ doanh thu, 5 metric, biểu đồ đường đa màu theo danh mục (bấm chú giải bật/tắt), top SP, phân bổ trạng thái.
- Sản phẩm / Đơn hàng / Khách hàng / Danh mục / Khuyến mãi / Phí giao hàng — bảng dữ liệu, bộ lọc, drawer & chi tiết.

## Nối API thật

Thay dữ liệu tĩnh trong src/data/adminData.js bằng lời gọi tới endpoint admin của Spring Boot (vd /admin/api/...); giữ nguyên field trả về để view không phải sửa.
