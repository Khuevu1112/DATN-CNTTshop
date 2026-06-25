# CNTTshop — Vue 3 Project

Cửa hàng PC & Laptop Gaming (prototype) được chuyển từ bản gốc sang **Vue 3 + Vite**, dùng Single-File Components.

## Chạy bản dev (khuyến nghị)

```bash
npm install
npm run dev
```

Mở địa chỉ Vite in ra (mặc định http://localhost:5173).

Build production:

```bash
npm run build
npm run preview
```

## Xem nhanh không cần build

Mở `preview.html` qua một web server tĩnh bất kỳ (cần server vì trình duyệt chặn `fetch` file local):

```bash
npx serve .
# rồi mở http://localhost:3000/preview.html
```

File này load thẳng các `.vue` trong `src/` bằng `vue3-sfc-loader` (từ CDN), không cần cài đặt.

## Cấu trúc

```
cnttshop-vue/
├── index.html              # entry cho Vite
├── preview.html            # xem nhanh không build (CDN)
├── vite.config.js
├── package.json
└── src/
    ├── main.js             # khởi tạo app
    ├── App.vue             # layout gốc + chuyển route
    ├── style.css           # reset, font, keyframes
    ├── store.js            # state + actions dùng chung (reactive)
    ├── data/products.js    # dữ liệu sản phẩm + helper tính giá
    ├── components/
    │   ├── AppHeader.vue
    │   ├── AppFooter.vue
    │   ├── ProductCard.vue
    │   ├── ToastMessage.vue
    │   └── LoadingOverlay.vue
    └── views/
        ├── HomeView.vue
        ├── CategoryView.vue
        ├── DetailView.vue
        └── CartView.vue
```

## Ghi chú

- "Định tuyến" dùng `state.route` đơn giản trong store (không cần vue-router). Có thể nâng cấp lên vue-router / Pinia khi cần.
- Toàn bộ trạng thái (giỏ hàng, bộ lọc, theme, route) nằm trong `src/store.js`.
- Theme accent (cyan / magenta) và sáng/tối đổi qua header.
