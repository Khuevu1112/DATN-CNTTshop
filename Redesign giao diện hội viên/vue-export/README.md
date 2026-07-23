# SubscriptionPanel.vue

Component Vue 3 (`<script setup>`, Composition API) cho tab **Gói hội viên** — bản redesign, mỗi gói một màu riêng.

## Cách dùng

Chép `SubscriptionPanel.vue` vào `src/components/` rồi dùng trong `AccountView.vue`:

```vue
<script setup>
import SubscriptionPanel from '@/components/SubscriptionPanel.vue';

function onBuy(planKey) {
  // planKey: 'basic' | 'plus' | 'pro'
  console.log('Mua gói', planKey);
}
</script>

<template>
  <SubscriptionPanel @buy="onBuy" />
</template>
```

## Sự kiện
- `@buy="(planKey) => {}"` — phát ra khi bấm **Mua gói**.

## Font
Cần load sẵn trong project (như codebase đang dùng):
- `Be Vietnam Pro` (body)
- `Chakra Petch` (giá / eyebrow)

## Màu mỗi gói
- **Cơ bản** — xanh biển nhạt
- **Plus** — xanh lá thương hiệu (viền đậm, phổ biến)
- **Pro** — nền tối, chữ giá + nút + badge ánh kim (shimmer)

Dữ liệu gói nằm trong `plans` (computed) ở đầu file — sửa giá/tính năng ở đó.
