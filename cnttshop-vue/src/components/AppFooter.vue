<script setup>
import { state, accent } from '../store.js';
import AppLogo from './AppLogo.vue';
</script>

<template>
  <footer
    style="border-top: 1px solid rgba(var(--line-rgb), 0.12); background: var(--page)"
  >
    <div
      style="
        max-width: 1800px;
        margin: 0 auto;
        padding: 40px 24px;
        display: grid;
        grid-template-columns: 1.5fr 1fr 1fr 1fr;
        gap: 30px;
      "
    >
      <div>
        <div
          style="
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 14px;
          "
        >
          <AppLogo :size="24" :on-light="state.mode === 'light'" :accent-color="accent" />
          <div
            style="
              font-family: 'Chakra Petch', sans-serif;
              font-weight: 700;
              font-size: 18px;
            "
          >
            CNTT<span :style="{ color: accent }">shop</span>
          </div>
        </div>
        <p
          style="
            font-size: 13px;
            color: var(--muted);
            line-height: 1.6;
            margin: 0;
            max-width: 280px;
          "
        >
          Hệ thống bán lẻ PC Gaming, laptop & linh kiện chính hãng. Build theo
          yêu cầu, bảo hành tận tâm.
        </p>
      </div>
      <div>
        <div style="font-weight: 600; font-size: 13.5px; margin-bottom: 12px">
          Sản phẩm
        </div>
        <div
          style="
            display: flex;
            flex-direction: column;
            gap: 9px;
            font-size: 13px;
            color: var(--muted);
          "
        >
          <span>Laptop Gaming</span><span>PC dựng sẵn</span
          ><span>Linh kiện</span><span>Màn hình</span>
        </div>
      </div>
      <div>
        <div style="font-weight: 600; font-size: 13.5px; margin-bottom: 12px">
          Hỗ trợ
        </div>
        <div
          style="
            display: flex;
            flex-direction: column;
            gap: 9px;
            font-size: 13px;
            color: var(--muted);
          "
        >
          <span>Bảo hành</span><span>Trả góp 0%</span><span>Giao hàng</span
          ><span>Đổi trả</span>
        </div>
      </div>
      <div>
        <div style="font-weight: 600; font-size: 13.5px; margin-bottom: 12px">
          Liên hệ
        </div>
        <div
          style="
            display: flex;
            flex-direction: column;
            gap: 9px;
            font-size: 13px;
            color: var(--muted);
          "
        >
          <span>Hotline: 1900 1903</span><span>cskh@cnttshop.vn</span
          ><span>118 Cát Bi, Hải An, Hải Phòng</span>
        </div>
      </div>
    </div>
    <div
      style="
        border-top: 1px solid rgba(var(--line-rgb), 0.08);
        padding: 18px 24px;
        text-align: center;
        font-size: 12px;
        color: var(--muted);
      "
    >
      © 2026 CNTTshop · Vue prototype · Made with care
    </div>
  </footer>
</template>
