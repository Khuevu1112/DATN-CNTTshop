<script setup>
import { reactive, ref } from 'vue';
import { actions } from '../store.js';

const form = reactive({
  hoTen: '',
  email: '',
  soDienThoai: '',
  matKhau: '',
  reMatKhau: '',
});
const error = ref('');
const loading = ref(false);

async function submit() {
  error.value = '';
  if (!form.hoTen || !form.email || !form.matKhau) {
    error.value = 'Vui lòng nhập đầy đủ họ tên, email và mật khẩu.';
    return;
  }
  if (form.matKhau !== form.reMatKhau) {
    error.value = 'Mật khẩu nhập lại không khớp.';
    return;
  }
  loading.value = true;
  try {
    await actions.register({ ...form });
    actions.showToast('Đăng ký thành công, vui lòng đăng nhập');
    actions.openLogin();
  } catch (e) {
    error.value =
      e && e.message && !e.message.startsWith('HTTP')
        ? e.message
        : 'Đăng ký thất bại. Vui lòng thử lại.';
  } finally {
    loading.value = false;
  }
}

const inputStyle =
  'width:100%; height:42px; padding:0 14px; border:1px solid #d4dbe5; border-radius:10px; font-size:14px; margin-bottom:12px; box-sizing:border-box; color:#0e2236;';
</script>

<template>
  <div
    @click="actions.closeRegister"
    style="
      position: fixed;
      inset: 0;
      z-index: 9999;
      display: flex;
      align-items: center;
      justify-content: center;
      background: rgba(0, 0, 0, 0.55);
      backdrop-filter: blur(3px);
      padding: 24px;
    "
  >
    <div
      @click.stop
      style="
        width: 100%;
        max-width: 440px;
        background: #fff;
        border-radius: 14px;
        overflow: hidden;
        box-shadow: 0 14px 44px rgba(0, 0, 0, 0.55);
        max-height: 92vh;
        overflow-y: auto;
      "
    >
      <div
        style="
          background: linear-gradient(90deg, #081a2d, #032e5d);
          color: #fff;
          text-align: center;
          padding: 20px;
          font-size: 1.35rem;
          font-weight: 700;
          font-family: 'Be Vietnam Pro', sans-serif;
        "
      >
        🖥️ CNTTShop
      </div>

      <div style="padding: 24px 26px">
        <h4
          style="
            font-weight: 700;
            color: #032e5d;
            margin: 0 0 4px;
            font-family: 'Be Vietnam Pro', sans-serif;
          "
        >
          Tạo tài khoản
        </h4>
        <p style="color: #6b7785; font-size: 13px; margin: 0 0 16px">
          Đăng ký để mua sắm nhanh hơn.
        </p>

        <div
          v-if="error"
          style="
            background: #fde8e8;
            color: #b71c1c;
            padding: 10px 12px;
            border-radius: 8px;
            font-size: 13px;
            margin-bottom: 14px;
          "
        >
          {{ error }}
        </div>

        <form @submit.prevent="submit">
          <label
            style="
              display: block;
              font-weight: 600;
              font-size: 13px;
              color: #0e2236;
              margin-bottom: 6px;
            "
            >Họ và tên</label
          >
          <input
            v-model="form.hoTen"
            type="text"
            placeholder="Nguyễn Văn A"
            :style="inputStyle"
          />

          <label
            style="
              display: block;
              font-weight: 600;
              font-size: 13px;
              color: #0e2236;
              margin-bottom: 6px;
            "
            >Email</label
          >
          <input
            v-model="form.email"
            type="email"
            placeholder="email@gmail.com"
            :style="inputStyle"
          />

          <label
            style="
              display: block;
              font-weight: 600;
              font-size: 13px;
              color: #0e2236;
              margin-bottom: 6px;
            "
            >Số điện thoại</label
          >
          <input
            v-model="form.soDienThoai"
            type="text"
            placeholder="09xxxxxxxx"
            :style="inputStyle"
          />

          <label
            style="
              display: block;
              font-weight: 600;
              font-size: 13px;
              color: #0e2236;
              margin-bottom: 6px;
            "
            >Mật khẩu</label
          >
          <input
            v-model="form.matKhau"
            type="password"
            placeholder="••••••••"
            :style="inputStyle"
          />

          <label
            style="
              display: block;
              font-weight: 600;
              font-size: 13px;
              color: #0e2236;
              margin-bottom: 6px;
            "
            >Nhập lại mật khẩu</label
          >
          <input
            v-model="form.reMatKhau"
            type="password"
            placeholder="••••••••"
            :style="inputStyle"
          />

          <button
            type="submit"
            :disabled="loading"
            style="
              width: 100%;
              height: 46px;
              margin-top: 6px;
              border: none;
              border-radius: 10px;
              background: #032e5d;
              color: #fff;
              font-weight: 700;
              font-size: 14.5px;
              cursor: pointer;
              font-family: 'Be Vietnam Pro', sans-serif;
            "
          >
            {{ loading ? 'Đang xử lý...' : 'Đăng ký' }}
          </button>
        </form>

        <p
          style="
            text-align: center;
            color: #6b7785;
            font-size: 13px;
            margin: 16px 0 0;
          "
        >
          Đã có tài khoản?
          <a
            href="#"
            @click.prevent="actions.openLogin"
            style="font-weight: 700; color: #032e5d; text-decoration: none"
            >Đăng nhập</a
          >
        </p>
      </div>
    </div>
  </div>
</template>
