<script setup>
import { ref, reactive } from 'vue';
import { actions, accent } from '../store.js';
import { submitContact } from '../api.js';

const copied = ref(false);
const PHONE = '0835 344 974';

function copyPhone() {
  navigator.clipboard.writeText('0835344974').then(() => {
    copied.value = true;
    setTimeout(() => (copied.value = false), 2000);
  });
}

const form = reactive({ fullName: '', email: '', phone: '', subject: '', message: '' });
const sending = ref(false);
const error = ref('');
const sent = ref(false);

const inputStyle =
  "width:100%; height:42px; padding:0 14px; background:var(--card2); border:1px solid rgba(var(--line-rgb),0.22); border-radius:10px; color:var(--text); font-size:13.5px; font-family:'Be Vietnam Pro', sans-serif;";
const textareaStyle =
  "width:100%; padding:12px 14px; background:var(--card2); border:1px solid rgba(var(--line-rgb),0.22); border-radius:10px; color:var(--text); font-size:13.5px; font-family:'Be Vietnam Pro', sans-serif; resize:vertical;";

async function submit() {
  error.value = '';
  if (!form.fullName.trim() || !form.email.trim() || !form.message.trim()) {
    error.value = 'Vui lòng nhập họ tên, email và nội dung cần hỗ trợ.';
    return;
  }
  sending.value = true;
  try {
    await submitContact({ ...form });
    sent.value = true;
    form.fullName = form.email = form.phone = form.subject = form.message = '';
    actions.showToast('Đã gửi yêu cầu hỗ trợ, CNTTShop sẽ liên hệ lại sớm nhất!');
  } catch (e) {
    error.value = e && e.message && !e.message.startsWith('HTTP')
      ? e.message
      : 'Gửi yêu cầu thất bại, vui lòng thử lại.';
  } finally {
    sending.value = false;
  }
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
        border: 1px solid rgba(var(--line-rgb), 0.2);
        color: var(--muted);
        border-radius: 9px;
        padding: 8px 14px;
        font-size: 13px;
        cursor: pointer;
        margin-bottom: 32px;
        font-family: 'Be Vietnam Pro', sans-serif;
        transition: border-color 0.15s, color 0.15s;
      "
      onmouseover="this.style.borderColor='var(--acc,#c6ff4a)';this.style.color='var(--acc,#c6ff4a)'"
      onmouseout="this.style.borderColor='rgba(var(--line-rgb),0.2)';this.style.color='var(--muted)'"
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
          color: var(--acc, #c6ff4a);
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
          color: var(--text);
        "
      >
        Liên hệ<br />
        <span :style="{ color: accent }">CNTTShop</span>
      </h1>
      <p
        style="
          font-size: 15px;
          color: var(--muted2);
          max-width: 560px;
          line-height: 1.65;
          margin: 0;
        "
      >
        Chuyên gia sẵn sàng tư vấn cấu hình phù hợp ngân sách — hoàn toàn miễn
        phí. Quét QR để nhắn Zalo ngay, hoặc gửi yêu cầu hỗ trợ bên dưới.
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
          background: var(--card);
          border: 1px solid rgba(var(--line-rgb), 0.16);
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

        <div
          style="
            position: relative;
            width: 200px;
            height: 200px;
            border-radius: 14px;
            overflow: hidden;
            border: 3px solid rgba(var(--line-rgb), 0.18);
            background: #fff;
          "
        >
          <img
            src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=https://zalo.me/0835344974&bgcolor=ffffff&color=081a2d&margin=8"
            alt="QR Zalo CNTTShop"
            style="width: 100%; height: 100%; display: block; object-fit: cover"
          />
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
            color: var(--muted);
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
            <rect width="40" height="40" rx="8" fill="white" fill-opacity="0.2" />
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
        <!-- Form gửi yêu cầu hỗ trợ -->
        <div
          style="
            background: var(--card);
            border: 1px solid rgba(var(--line-rgb), 0.12);
            border-radius: 14px;
            padding: 20px 22px;
          "
        >
          <div
            style="
              font-family: 'Chakra Petch', sans-serif;
              font-size: 13px;
              font-weight: 700;
              color: var(--text);
              margin-bottom: 4px;
            "
          >
            Gửi yêu cầu hỗ trợ
          </div>
          <p style="font-size: 12.5px; color: var(--muted); margin: 0 0 14px">
            Điền thông tin bên dưới, CNTTShop sẽ phản hồi qua email trong 24 giờ.
          </p>

          <div v-if="sent" style="background: color-mix(in srgb, var(--green) 12%, transparent); border: 1px solid color-mix(in srgb, var(--green) 30%, transparent); color: var(--green); border-radius: 10px; padding: 12px 14px; font-size: 13px; margin-bottom: 14px">
            ✓ Đã gửi thành công! Cảm ơn bạn đã liên hệ.
          </div>
          <div v-if="error" style="background: rgba(var(--sale-rgb),0.12); border: 1px solid rgba(var(--sale-rgb),0.3); color: var(--sale); border-radius: 10px; padding: 12px 14px; font-size: 13px; margin-bottom: 14px">
            {{ error }}
          </div>

          <form @submit.prevent="submit" style="display: flex; flex-direction: column; gap: 12px">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px">
              <input :style="inputStyle" v-model="form.fullName" placeholder="Họ và tên *" />
              <input :style="inputStyle" v-model="form.email" type="email" placeholder="Email *" />
            </div>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px">
              <input :style="inputStyle" v-model="form.phone" placeholder="Số điện thoại" />
              <input :style="inputStyle" v-model="form.subject" placeholder="Chủ đề (vd: Tư vấn cấu hình PC)" />
            </div>
            <textarea :style="textareaStyle" v-model="form.message" rows="4" placeholder="Nội dung cần hỗ trợ *"></textarea>
            <button
              type="submit"
              :disabled="sending"
              :style="{
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: '8px',
                background: accent, color: 'var(--acc-ink)', border: 'none', borderRadius: '11px',
                height: '44px', fontFamily: 'Be Vietnam Pro, sans-serif', fontWeight: '700',
                fontSize: '14px', cursor: sending ? 'default' : 'pointer', opacity: sending ? 0.7 : 1,
              }"
            >
              {{ sending ? 'Đang gửi...' : 'Gửi yêu cầu →' }}
            </button>
          </form>
        </div>

        <!-- Hotline -->
        <div
          style="
            display: flex;
            align-items: center;
            gap: 16px;
            background: var(--card);
            border: 1px solid rgba(var(--line-rgb), 0.12);
            border-radius: 14px;
            padding: 18px 20px;
          "
        >
          <div style="font-size: 24px; flex: none">📞</div>
          <div style="flex: 1">
            <div style="font-size: 11.5px; color: var(--muted); margin-bottom: 4px; font-weight: 500">
              Hotline hỗ trợ
            </div>
            <div style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 18px; color: var(--text)">
              {{ PHONE }}
            </div>
            <div style="font-size: 12px; color: var(--muted); margin-top: 3px">
              Miễn phí · 8:00 – 22:00 mỗi ngày
            </div>
          </div>
          <button
            @click="copyPhone"
            :style="{
              border: copied ? '1px solid var(--green)' : '1px solid rgba(var(--line-rgb),0.2)',
              color: copied ? 'var(--green)' : 'var(--muted2)',
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
            {{ copied ? '✓ Đã sao chép' : 'Sao chép' }}
          </button>
        </div>

        <!-- Messenger -->
        <div
          style="
            display: flex;
            align-items: center;
            gap: 16px;
            background: var(--card);
            border: 1px solid rgba(var(--line-rgb), 0.12);
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
            <div style="font-size: 11.5px; color: var(--muted); margin-bottom: 4px; font-weight: 500">
              Messenger
            </div>
            <div style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 18px; color: var(--text)">
              CNTTShop
            </div>
            <div style="font-size: 12px; color: var(--muted); margin-top: 3px">
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

        <!-- Email -->
        <div
          style="
            display: flex;
            align-items: center;
            gap: 16px;
            background: var(--card);
            border: 1px solid rgba(var(--line-rgb), 0.12);
            border-radius: 14px;
            padding: 18px 20px;
          "
        >
          <div style="font-size: 24px; flex: none">✉️</div>
          <div>
            <div style="font-size: 11.5px; color: var(--muted); margin-bottom: 4px; font-weight: 500">
              Email hỗ trợ
            </div>
            <div style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 18px; color: var(--text)">
              cskh@cnttshop.vn
            </div>
            <div style="font-size: 12px; color: var(--muted); margin-top: 3px">
              Phản hồi trong 24 giờ
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
              color: var(--green);
              font-weight: 600;
              margin-bottom: 14px;
            "
          >
            CAM KẾT CỦA CNTTSHOP
          </div>
          <ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 10px">
            <li style="font-size: 13.5px; color: var(--muted2); line-height: 1.5">
              🎯 Tư vấn đúng nhu cầu, không ép mua
            </li>
            <li style="font-size: 13.5px; color: var(--muted2); line-height: 1.5">
              💰 Báo giá minh bạch, không phí ẩn
            </li>
            <li style="font-size: 13.5px; color: var(--muted2); line-height: 1.5">
              🔧 Hỗ trợ kỹ thuật sau bán hàng miễn phí
            </li>
            <li style="font-size: 13.5px; color: var(--muted2); line-height: 1.5">
              🛡️ Bảo hành chính hãng tới 36 tháng
            </li>
          </ul>
        </div>
      </div>
    </div>
  </main>
</template>
