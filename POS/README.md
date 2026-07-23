# POS Bán hàng — Frontend (Vue 3 + Vite)

Bám theo API backend tại `http://localhost:8080/api`.

## Chạy

```bash
npm install
npm run dev
```

Mở http://localhost:5175 (CORS đã mở sẵn ở backend).

Đổi host backend: copy `.env.example` → `.env` rồi sửa `VITE_API_BASE` / `VITE_ASSET_BASE`.

## Cấu trúc

- `src/lib/api.js` — axios instance: gắn `Authorization: Bearer <token>`, đọc lỗi từ `err.response.data.message`, `imgUrl()` ghép `ASSET_BASE` vào `/uploads/...`, tự logout khi 401.
- `src/lib/bus.js` — `BroadcastChannel('pos')` đồng bộ màn hình phụ (cùng origin, tức thì, không polling).
- `src/router.js` — route guard: chưa có token → về `/login`.
- `src/views/Login.vue` — `POST /auth/login`, lưu token.
- `src/views/Sales.vue` — màn hình bán hàng chính (quét/tìm, giỏ hàng, tra khách, coupon, Xu, thanh toán, chốt đơn F9, modal + in hoá đơn 80mm).
- `src/views/Display.vue` — màn hình phụ hướng khách (`/display`, không nav, chữ to).

## Màn hình phụ

Ở màn hình bán hàng bấm **“Màn hình khách ↗”** để mở tab `/display` (kéo sang màn hình thứ 2). Hai tab cùng origin nói chuyện qua `BroadcastChannel`.

## Ghi chú giả định (chỉnh nếu backend khác)

- Field đăng nhập gửi `{ tenDangNhap, matKhau }`.
- `POST /coupons/apply` gửi `{ maCoupon, tienHang }`; số giảm cuối cùng vẫn do server tính lúc chốt đơn.
- QR dựng từ `urlThanhToan` qua api.qrserver.com (cần internet lúc chạy).
