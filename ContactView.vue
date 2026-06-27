<script setup>
import { ref } from "vue";
import { actions, accent } from "../store.js";

const copied = ref(false);
const PHONE = "0835 344 974";

function copyPhone() {
  navigator.clipboard.writeText("0835344974").then(() => {
    copied.value = true;
    setTimeout(() => (copied.value = false), 2000);
  });
}
</script>

<template>
  <main style="max-width: 1100px; margin: 0 auto; padding: 24px 24px 64px">
    <!-- Back -->
    <button
      @click="actions.goHome()"
      style="
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: transparent;
        border: 1px solid rgba(120, 170, 230, 0.2);
        color: #7e98b6;
        border-radius: 9px;
        padding: 8px 14px;
        font-size: 13px;
        cursor: pointer;
        margin-bottom: 32px;
        font-family: 'Be Vietnam Pro', sans-serif;
        transition: border-color 0.15s, color 0.15s;
      "
      onmouseover="this.style.borderColor='var(--acc,#00e5ff)';this.style.color='var(--acc,#00e5ff)'"
      onmouseout="this.style.borderColor='rgba(120,170,230,0.2)';this.style.color='#7e98b6'"
    >
      ← Quay lại trang chủ
    </button>

    <!-- Header -->
    <div style="margin-bottom: 36px">
      <div
        style="
          font-family: 'Chakra Petch', sans-serif;
          font-size: 11px;
          letter-spacing: 2.5px;
          color: var(--acc, #00e5ff);
          font-weight: 600;
          margin-bottom: 12px;
        "
      >
        HỖ TRỢ &amp; TƯ VẤN
      </div>
      <h1
        style="
          font-family: 'Be Vietnam Pro', sans-serif;
          font-weight: 800;
          font-size: 40px;
          line-height: 1.15;
          margin: 0 0 14px;
          color: #e8f1fc;
        "
      >
        Liên hệ<br />
        <span :style="{ color: accent }">CNTTShop</span>
      </h1>
      <p
        style="
          font-size: 15px;
          color: #a9c0dc;
          max-width: 560px;
          line-height: 1.65;
          margin: 0;
        "
      >
        Chuyên gia sẵn sàng tư vấn cấu hình phù hợp ngân sách — hoàn toàn miễn
        phí. Quét QR để nhắn Zalo ngay.
      </p>
    </div>

    <!-- Body -->
    <div
      style="
        display: grid;
        grid-template-columns: 300px 1fr;
        gap: 28px;
        align-items: start;
      "
    >
      <!-- QR Card -->
      <div
        style="
          background: #0a2138;
          border: 1px solid rgba(120, 170, 230, 0.16);
          border-radius: 18px;
          padding: 24px;
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 16px;
          position: sticky;
          top: 130px;
        "
      >
        <!-- Label Zalo -->
        <div
          style="
            display: flex;
            align-items: center;
            gap: 8px;
            font-family: 'Chakra Petch', sans-serif;
            font-weight: 600;
            font-size: 13px;
            color: #0068ff;
            letter-spacing: 1px;
          "
        >
          <svg width="20" height="20" viewBox="0 0 40 40" fill="none">
            <rect width="40" height="40" rx="8" fill="#0068FF" />
            <path
              d="M20 8C13.373 8 8 12.925 8 19c0 3.52 1.8 6.67 4.625 8.762L11.5 32l4.5-2.25C17.25 30.25 18.6 30.5 20 30.5c6.627 0 12-4.925 12-11s-5.373-11.5-12-11.5z"
              fill="white"
            />
          </svg>
          Zalo Official
        </div>

        <!-- QR Box -->
        <div
          style="
            position: relative;
            width: 200px;
            height: 200px;
            border-radius: 14px;
            overflow: hidden;
            border: 3px solid rgba(120, 170, 230, 0.18);
            background: #fff;
          "
        >
          <img
            src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=https://zalo.me/0835344974&bgcolor=ffffff&color=081a2d&margin=8"
            alt="QR Zalo CNTTShop"
            style="width: 100%; height: 100%; display: block; object-fit: cover"
          />
          <!-- Logo giữa QR -->
          <div
            style="
              position: absolute;
              top: 50%;
              left: 50%;
              transform: translate(-50%, -50%);
              background: white;
              border-radius: 8px;
              padding: 4px;
              display: flex;
              align-items: center;
              justify-content: center;
              box-shadow: 0 2px 8px rgba(0, 0, 0, 0.18);
            "
          >
            <svg width="28" height="28" viewBox="0 0 40 40" fill="none">
              <rect width="40" height="40" rx="6" fill="#0068FF" />
              <path
                d="M20 8C13.373 8 8 12.925 8 19c0 3.52 1.8 6.67 4.625 8.762L11.5 32l4.5-2.25C17.25 30.25 18.6 30.5 20 30.5c6.627 0 12-4.925 12-11s-5.373-11.5-12-11.5z"
                fill="white"
              />
            </svg>
          </div>
        </div>

        <p
          style="
            font-size: 12px;
            color: #7e98b6;
            text-align: center;
            margin: 0;
            line-height: 1.5;
          "
        >
          Mở Zalo → Quét mã → Nhắn tin tư vấn
        </p>

        <a
          href="https://zalo.me/0835344974"
          target="_blank"
          rel="noopener"
          style="
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #0068ff;
            color: #fff;
            border-radius: 12px;
            padding: 12px 24px;
            font-family: 'Be Vietnam Pro', sans-serif;
            font-weight: 700;
            font-size: 14px;
            text-decoration: none;
            width: 100%;
            justify-content: center;
            box-shadow: 0 8px 22px rgba(0, 104, 255, 0.3);
          "
        >
          <svg width="18" height="18" viewBox="0 0 40 40" fill="none">
            <rect
              width="40"
              height="40"
              rx="8"
              fill="white"
              fill-opacity="0.2"
            />
            <path
              d="M20 8C13.373 8 8 12.925 8 19c0 3.52 1.8 6.67 4.625 8.762L11.5 32l4.5-2.25C17.25 30.25 18.6 30.5 20 30.5c6.627 0 12-4.925 12-11s-5.373-11.5-12-11.5z"
              fill="white"
            />
          </svg>
          Mở Zalo ngay
        </a>
      </div>

      <!-- Info Panel -->
      <div style="display: flex; flex-direction: column; gap: 14px">
        <!-- Hotline -->
        <div
          style="
            display: flex;
            align-items: center;
            gap: 16px;
            background: #0a2138;
            border: 1px solid rgba(120, 170, 230, 0.12);
            border-radius: 14px;
            padding: 18px 20px;
          "
        >
          <div style="font-size: 24px; flex: none">📞</div>
          <div style="flex: 1">
            <div
              style="
                font-size: 11.5px;
                color: #7e98b6;
                margin-bottom: 4px;
                font-weight: 500;
              "
            >
              Hotline hỗ trợ
            </div>
            <div
              style="
                font-family: 'Chakra Petch', sans-serif;
                font-weight: 700;
                font-size: 18px;
                color: #e8f1fc;
              "
            >
              {{ PHONE }}
            </div>
            <div style="font-size: 12px; color: #7e98b6; margin-top: 3px">
              Miễn phí · 8:00 – 22:00 mỗi ngày
            </div>
          </div>
          <button
            @click="copyPhone"
            :style="{
              border: copied
                ? '1px solid #2bd47e'
                : '1px solid rgba(120,170,230,0.2)',
              color: copied ? '#2bd47e' : '#9fb6d2',
            }"
            style="
              flex: none;
              background: transparent;
              border-radius: 8px;
              padding: 6px 12px;
              font-size: 12px;
              cursor: pointer;
              font-family: 'Be Vietnam Pro', sans-serif;
              transition: all 0.2s;
              white-space: nowrap;
            "
          >
            {{ copied ? "✓ Đã sao chép" : "Sao chép" }}
          </button>
        </div>

        <!-- Chat -->
        <div
          style="
            display: flex;
            align-items: center;
            gap: 16px;
            background: #0a2138;
            border: 1px solid rgba(120, 170, 230, 0.12);
            border-radius: 14px;
            padding: 18px 20px;
          "
        >
          <div style="font-size: 24px; flex: none">💬</div>
          <!-- Messenger -->
          <div
            style="
              display: flex;
              align-items: center;
              gap: 16px;
              background: #0a2138;
              border: 1px solid rgba(120, 170, 230, 0.12);
              border-radius: 14px;
              padding: 18px 20px;
            "
          >
            <div
              style="
                width: 44px;
                height: 44px;
                border-radius: 12px;
                flex: none;
                background: linear-gradient(135deg, #00b2ff, #006aff, #7b1fff);
                display: flex;
                align-items: center;
                justify-content: center;
              "
            >
              <svg width="24" height="24" viewBox="0 0 24 24" fill="white">
                <path
                  d="M12 2C6.36 2 2 6.13 2 11.7c0 2.9 1.19 5.44 3.14 7.22.16.14.26.34.26.56l.05 1.75c.02.56.6.92 1.1.68l1.95-.86c.17-.07.35-.09.52-.05.64.18 1.31.27 2 .27 5.64 0 10-4.13 10-9.7C22 6.13 17.64 2 12 2zm5.5 7.5l-2.9 4.6c-.46.73-1.45.91-2.14.4L10.5 12.7a.6.6 0 00-.72 0l-2.84 2.16c-.38.29-.87-.17-.61-.58l2.9-4.6c.46-.73 1.45-.91 2.14-.4l1.96 1.8a.6.6 0 00.72 0l2.84-2.16c.38-.29.87.17.61.58z"
                />
              </svg>
            </div>
            <div style="flex: 1">
              <div
                style="
                  font-size: 11.5px;
                  color: #7e98b6;
                  margin-bottom: 4px;
                  font-weight: 500;
                "
              >
                Messenger
              </div>
              <div
                style="
                  font-family: 'Chakra Petch', sans-serif;
                  font-weight: 700;
                  font-size: 18px;
                  color: #e8f1fc;
                "
              >
                CNTTShop
              </div>
              <div style="font-size: 12px; color: #7e98b6; margin-top: 3px">
                Phản hồi trong vòng 5 phút
              </div>
            </div>

            <a
              href="https://www.facebook.com/tuan.anh.269469"
              target="_blank"
              rel="noopener"
              style="
                flex: none;
                display: inline-flex;
                align-items: center;
                gap: 6px;
                background: linear-gradient(135deg, #006aff, #7b1fff);
                color: #fff;
                border-radius: 9px;
                padding: 8px 14px;
                font-family: 'Be Vietnam Pro', sans-serif;
                font-weight: 700;
                font-size: 12.5px;
                text-decoration: none;
                box-shadow: 0 4px 14px rgba(0, 106, 255, 0.35);
                white-space: nowrap;
              "
            >
              Nhắn tin →
            </a>
          </div>
        </div>

        <!-- Email -->
        <div
          style="
            display: flex;
            align-items: center;
            gap: 16px;
            background: #0a2138;
            border: 1px solid rgba(120, 170, 230, 0.12);
            border-radius: 14px;
            padding: 18px 20px;
          "
        >
          <div style="font-size: 24px; flex: none">✉️</div>
          <div>
            <div
              style="
                font-size: 11.5px;
                color: #7e98b6;
                margin-bottom: 4px;
                font-weight: 500;
              "
            >
              Email hỗ trợ
            </div>
            <div
              style="
                font-family: 'Chakra Petch', sans-serif;
                font-weight: 700;
                font-size: 18px;
                color: #e8f1fc;
              "
            >
              cskh@cnttshop.vn
            </div>
            <div style="font-size: 12px; color: #7e98b6; margin-top: 3px">
              Phản hồi trong 24 giờ
            </div>
          </div>
        </div>

        <!-- Showroom -->
        <div
          style="
            display: flex;
            align-items: center;
            gap: 16px;
            background: #0a2138;
            border: 1px solid rgba(120, 170, 230, 0.12);
            border-radius: 14px;
            padding: 18px 20px;
          "
        >
          <div style="font-size: 24px; flex: none">📍</div>
          <div>
            <div
              style="
                font-size: 11.5px;
                color: #7e98b6;
                margin-bottom: 4px;
                font-weight: 500;
              "
            >
              Showroom
            </div>
            <div
              style="
                font-family: 'Chakra Petch', sans-serif;
                font-weight: 700;
                font-size: 18px;
                color: #e8f1fc;
              "
            >
              Hà Nội &amp; TP.HCM
            </div>
            <div style="font-size: 12px; color: #7e98b6; margin-top: 3px">
              Thứ 2 – Chủ nhật · 9:00 – 21:00
            </div>
          </div>
        </div>

        <!-- Cam kết -->
        <div
          style="
            background: linear-gradient(135deg, #0a2c1e, #061a0e);
            border: 1px solid rgba(0, 197, 126, 0.2);
            border-radius: 14px;
            padding: 20px 24px;
          "
        >
          <div
            style="
              font-family: 'Chakra Petch', sans-serif;
              font-size: 11px;
              letter-spacing: 2px;
              color: #2bd47e;
              font-weight: 600;
              margin-bottom: 14px;
            "
          >
            CAM KẾT CỦA CNTTSHOP
          </div>
          <ul
            style="
              list-style: none;
              padding: 0;
              margin: 0;
              display: flex;
              flex-direction: column;
              gap: 10px;
            "
          >
            <li style="font-size: 13.5px; color: #a9c0dc; line-height: 1.5">
              🎯 Tư vấn đúng nhu cầu, không ép mua
            </li>
            <li style="font-size: 13.5px; color: #a9c0dc; line-height: 1.5">
              💰 Báo giá minh bạch, không phí ẩn
            </li>
            <li style="font-size: 13.5px; color: #a9c0dc; line-height: 1.5">
              🔧 Hỗ trợ kỹ thuật sau bán hàng miễn phí
            </li>
            <li style="font-size: 13.5px; color: #a9c0dc; line-height: 1.5">
              🛡️ Bảo hành chính hãng tới 36 tháng
            </li>
          </ul>
        </div>
      </div>
    </div>
  </main>
</template>
