<script setup>
import { accent } from '../store.js';
</script>

<template>
  <footer
    style="border-top: 1px solid rgba(120, 170, 230, 0.12); background: #061427"
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
          <div
            :style="{
              background: 'linear-gradient(135deg, ' + accent + ', #0b4f9e)',
            }"
            style="
              width: 26px;
              height: 26px;
              transform: rotate(45deg);
              border-radius: 6px;
            "
          ></div>
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
            color: #7e98b6;
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
            color: #7e98b6;
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
            color: #7e98b6;
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
            color: #7e98b6;
          "
        >
          <span>Hotline: 1900 1903</span><span>cskh@cnttshop.vn</span
          ><span>Hà Nội · TP.HCM</span>
        </div>
      </div>
    </div>
    <div
      style="
        border-top: 1px solid rgba(120, 170, 230, 0.08);
        padding: 18px 24px;
        text-align: center;
        font-size: 12px;
        color: #5f7a9c;
      "
    >
      © 2026 CNTTshop · Vue prototype · Made with care
    </div>
  </footer>
</template>
