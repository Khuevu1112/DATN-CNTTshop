# CNTTshop — Menu redesign (Vue 3)

Thanh menu redesign kiểu Samsung cho CNTTshop: top bar + nav mega-menu dạng lưới thẻ ảnh, cột "Khám phá", và panel **Hỗ trợ**. Giữ nguyên phong cách dark-tech, accent lime/magenta, font Chakra Petch + Plus Jakarta Sans.

## Chạy thử

```bash
npm install
npm run dev
```

Mở địa chỉ Vite in ra (mặc định http://localhost:5173).

- Rê chuột vào các mục có mũi tên ▾ để xem mega-menu.
- Bấm nút **Hỗ trợ** trên thanh trên cùng để mở panel hỗ trợ.
- 2 chấm tròn = đổi màu accent (lime / magenta). Nút ☀️/🌙 = đổi sáng/tối.

## Cấu trúc

```
vue-export/
├─ index.html            # nạp Google Fonts + bootstrap-icons (CDN)
├─ src/
│  ├─ main.js
│  ├─ style.css          # biến màu (--acc, --page, --card...) + reset + keyframe
│  ├─ App.vue            # trang demo bọc header
│  └─ components/
│     └─ AppHeader.vue   # ★ component menu đã redesign
```

## Ghép vào dự án thật

`AppHeader.vue` để dữ liệu (NAV, MENUS, SUPPORT) **tĩnh trong file** cho dễ xem. Khi ghép vào code CNTTshop của bạn:

1. Copy `src/components/AppHeader.vue` vào `src/components/` của dự án.
2. Đảm bảo đã có các biến màu trong `src/style.css` (đã sẵn trong dự án bạn) và nạp `bootstrap-icons` + 2 font.
3. Thay dữ liệu tĩnh bằng dữ liệu thật: nối `NAV`/`MENUS` với `catMeta`, `CATEGORY_SEGMENTS`, `COMPONENT_GROUPS_DEF` và gọi `actions.goCat(slug, keyword)` trong các `@click` (hiện đang là `noop`). Tương tự nối chuông/giỏ hàng/tài khoản với `store.js`.
4. `applyTheme()` đang set `--acc` + `data-mode` trên `documentElement` — trùng cơ chế với store hiện tại của bạn, có thể bỏ và dùng `actions.setTheme` / `actions.toggleMode` sẵn có.
