<script setup>
/**
 * Bảng "Sản phẩm yêu thích" (kiểu Steam wishlist) — dùng làm một tab trong trang Tài khoản.
 *
 * Tách khỏi WishlistView để phần bảng dùng chung được, không phải chép đôi: view cũ ở
 * /yeu-thich giờ chỉ còn là redirect sang tab này (giữ cho link cũ đã chia sẻ ra ngoài).
 *
 * Dữ liệu lấy từ state.wishlistItems (nạp sẵn khi đăng nhập — xem store.refreshWishlist),
 * chỉ tải lại nếu chưa có.
 */
import { onMounted } from 'vue';
import { state, actions } from '../store.js';
import { fmt } from '../data/products.js';
import { resolveImageUrl } from '../api.js';

onMounted(() => {
  if (state.user && !state.wishlistItems.length) actions.refreshWishlist();
});

function boYeuThich(item) {
  actions.removeWishlistItem(item.productId);
}
</script>

<template>
  <div>
    <div v-if="!state.wishlistItems.length" class="sp-card sp-empty">
      Bạn chưa yêu thích sản phẩm nào.<br />
      Bấm biểu tượng <span style="color: var(--sale)">♥</span> ở trang chi tiết sản phẩm để thêm vào đây.<br />
      <button class="sp-btn-acc" style="margin-top: 16px" @click="actions.goCatAll()">Khám phá sản phẩm</button>
    </div>

    <div v-else class="sp-card" style="overflow: hidden">
      <div style="padding: 14px 16px; font-size: 12.5px; color: var(--muted2); border-bottom: 1px solid rgba(var(--line-rgb), 0.1)">
        CNTTShop sẽ báo qua email khi sản phẩm trong danh sách này giảm giá.
      </div>
      <div style="overflow-x: auto">
        <table class="wl-table">
          <thead>
            <tr>
              <th style="width: 48px">STT</th>
              <th style="min-width: 260px">Tên sản phẩm</th>
              <th style="width: 150px; text-align: right">Giá tiền</th>
              <th style="width: 100px; text-align: center">Số lượng</th>
              <th style="width: 220px"></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(w, idx) in state.wishlistItems" :key="w.id">
              <td class="mono" style="color: var(--muted)">{{ idx + 1 }}</td>
              <td>
                <button class="wl-product" @click="actions.goDetail(w.productId)">
                  <div
                    class="wl-thumb"
                    :style="w.anh ? { backgroundImage: `url(${resolveImageUrl(w.anh)})` } : {}"
                  ></div>
                  <span class="wl-name">{{ w.tenSanPham }}</span>
                </button>
              </td>
              <td style="text-align: right">
                <div style="font-weight: 700; color: var(--text)">{{ fmt(w.gia) }}</div>
                <div
                  v-if="w.giaGoc && Number(w.giaGoc) > Number(w.gia)"
                  style="font-size: 11.5px; color: var(--muted); text-decoration: line-through"
                >
                  {{ fmt(w.giaGoc) }}
                </div>
              </td>
              <td style="text-align: center; color: var(--muted2)">
                <span v-if="w.tonKho > 0">{{ w.tonKho }}</span>
                <span v-else style="color: var(--sale)">Hết hàng</span>
              </td>
              <td>
                <div style="display: flex; gap: 8px; justify-content: flex-end">
                  <button
                    class="sp-btn-acc"
                    style="height: 36px; font-size: 12.5px; padding: 0 14px"
                    :disabled="!w.tonKho"
                    @click="actions.addWishlistItemToCart(w)"
                  >
                    + Giỏ hàng
                  </button>
                  <button class="wl-remove" title="Bỏ yêu thích" @click="boYeuThich(w)">✕</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<style scoped>
.wl-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.wl-table th {
  text-align: left;
  padding: 13px 16px;
  font-family: 'Chakra Petch', sans-serif;
  font-size: 11.3px;
  letter-spacing: 0.5px;
  color: var(--muted);
  font-weight: 600;
  background: var(--card2);
  border-bottom: 1px solid rgba(var(--line-rgb), 0.12);
  white-space: nowrap;
}
.wl-table td {
  padding: 12px 16px;
  border-bottom: 1px solid rgba(var(--line-rgb), 0.08);
  vertical-align: middle;
}
.wl-table tbody tr:last-child td {
  border-bottom: none;
}
.wl-table tbody tr:hover {
  background: var(--card2);
}

.wl-product {
  display: flex;
  align-items: center;
  gap: 12px;
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 0;
  text-align: left;
  font-family: 'Plus Jakarta Sans', sans-serif;
}
.wl-thumb {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  background-color: var(--card2);
  background-size: cover;
  background-position: center;
  flex: none;
}
.wl-name {
  font-size: 13.3px;
  font-weight: 600;
  color: var(--text);
  line-height: 1.4;
}
.wl-product:hover .wl-name {
  color: var(--acc, #c6ff4a);
}

.wl-remove {
  width: 36px;
  height: 36px;
  border-radius: 9px;
  border: 1px solid rgba(var(--line-rgb), 0.2);
  background: transparent;
  color: var(--muted);
  cursor: pointer;
  font-size: 13px;
  flex: none;
  transition: all 0.15s;
}
.wl-remove:hover {
  border-color: var(--sale);
  color: var(--sale);
}
</style>
