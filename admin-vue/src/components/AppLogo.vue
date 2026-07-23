<script setup>
defineProps({
  size: { type: Number, default: 30 },
  // true nếu logo đặt trên nền sáng (icon màu navy) — mặc định icon màu trắng cho nền tối
  onLight: { type: Boolean, default: false },
});
</script>

<template>
  <svg
    :width="Math.round((size * 116) / 90)"
    :height="size"
    viewBox="0 0 116 90"
    xmlns="http://www.w3.org/2000/svg"
    style="flex: none; display: block"
  >
    <!-- Màn hình -->
    <rect x="18" y="76" width="26" height="6" rx="3" :fill="onLight ? '#18181b' : '#f7f9fc'" />
    <rect x="27" y="48" width="8" height="28" :fill="onLight ? '#18181b' : '#f7f9fc'" />
    <rect x="4" y="8" width="56" height="40" rx="7" :fill="onLight ? '#18181b' : '#f7f9fc'" />
    <rect x="9" y="13" width="46" height="30" rx="3" fill="var(--acc)" opacity="0.2" />
    <!-- Case (vỏ máy tính) -->
    <rect x="76" y="78" width="6" height="4" rx="1" :fill="onLight ? '#18181b' : '#f7f9fc'" />
    <rect x="94" y="78" width="6" height="4" rx="1" :fill="onLight ? '#18181b' : '#f7f9fc'" />
    <rect x="72" y="8" width="36" height="70" rx="9" :fill="onLight ? '#18181b' : '#f7f9fc'" />
    <rect x="72" y="22" width="36" height="2.5" :fill="onLight ? '#f7f9fc' : '#101114'" />
    <circle cx="90" cy="15" r="3.2" fill="var(--acc)" />
    <rect x="80" y="48" width="20" height="2" rx="1" :fill="onLight ? '#f7f9fc' : '#101114'" opacity="0.45" />
    <rect x="80" y="55" width="20" height="2" rx="1" :fill="onLight ? '#f7f9fc' : '#101114'" opacity="0.45" />
    <rect x="80" y="62" width="20" height="2" rx="1" :fill="onLight ? '#f7f9fc' : '#101114'" opacity="0.45" />
  </svg>
</template>
