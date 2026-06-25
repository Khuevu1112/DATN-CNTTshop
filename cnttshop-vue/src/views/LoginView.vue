<script setup>
import { ref } from 'vue';
import { actions } from '../store.js';

const username = ref('');
const password = ref('');
const showPassword = ref(false);
const error = ref('');
const loading = ref(false);

async function submit() {
  error.value = '';
  if (!username.value || !password.value) {
    error.value = 'Vui lòng nhập đầy đủ thông tin.';
    return;
  }
  loading.value = true;
  try {
    await actions.login(username.value.trim(), password.value);
  } catch (e) {
    error.value =
      e && e.message && !e.message.startsWith('HTTP')
        ? e.message
        : 'Đăng nhập thất bại. Vui lòng kiểm tra tài khoản / mật khẩu.';
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <!-- Lớp phủ: bấm ra ngoài để đóng (quay lại trang trước) -->
  <div
    @click="actions.closeLogin"
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
        max-width: 430px;
        background: #fff;
        border-radius: 14px;
        overflow: hidden;
        box-shadow: 0 14px 44px rgba(0, 0, 0, 0.55);
      "
    >
      <div
        style="
          background: linear-gradient(90deg, #081a2d, #032e5d);
          color: #fff;
          text-align: center;
          padding: 22px;
          font-size: 1.35rem;
          font-weight: 700;
          font-family: 'Be Vietnam Pro', sans-serif;
        "
      >
        🖥️ CNTTShop
      </div>

      <div style="padding: 26px">
        <h4
          style="
            font-weight: 700;
            color: #032e5d;
            margin: 0 0 4px;
            font-family: 'Be Vietnam Pro', sans-serif;
          "
        >
          Đăng nhập
        </h4>
        <p style="color: #6b7785; font-size: 13px; margin: 0 0 18px">
          Chào mừng bạn quay lại!
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
            >Email hoặc số điện thoại</label
          >
          <input
            v-model="username"
            type="text"
            placeholder="vd: email@gmail.com"
            autocomplete="username"
            style="
              width: 100%;
              height: 44px;
              padding: 0 14px;
              border: 1px solid #d4dbe5;
              border-radius: 10px;
              font-size: 14px;
              margin-bottom: 14px;
              box-sizing: border-box;
              color: #0e2236;
            "
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
          <div style="position: relative; margin-bottom: 8px">
            <input
              v-model="password"
              :type="showPassword ? 'text' : 'password'"
              placeholder="••••••••"
              autocomplete="current-password"
              style="
                width: 100%;
                height: 44px;
                padding: 0 46px 0 14px;
                border: 1px solid #d4dbe5;
                border-radius: 10px;
                font-size: 14px;
                box-sizing: border-box;
                color: #0e2236;
              "
            />
            <button
              type="button"
              @click="showPassword = !showPassword"
              style="
                position: absolute;
                right: 6px;
                top: 6px;
                width: 34px;
                height: 32px;
                border: none;
                background: transparent;
                cursor: pointer;
                font-size: 15px;
              "
            >
              {{ showPassword ? '🙈' : '👁️' }}
            </button>
          </div>

          <div style="text-align: right; margin-bottom: 16px">
            <a
              href="#"
              @click.prevent="
                actions.showToast('Tính năng quên mật khẩu sẽ bổ sung sau')
              "
              style="font-size: 12.5px; color: #032e5d; text-decoration: none"
              >Quên mật khẩu?</a
            >
          </div>

          <button
            type="submit"
            :disabled="loading"
            style="
              width: 100%;
              height: 46px;
              border: none;
              border-radius: 10px;
              background: #032e5d;
              color: #fff;
              font-weight: 700;
              font-size: 14.5px;
              cursor: pointer;
              font-family: 'Be Vietnam Pro', sans-serif;
              opacity: 1;
            "
          >
            {{ loading ? 'Đang xử lý...' : 'Đăng nhập' }}
          </button>
        </form>

        <p
          style="
            text-align: center;
            color: #6b7785;
            font-size: 13px;
            margin: 18px 0 0;
          "
        >
          Chưa có tài khoản?
          <a
            href="#"
            @click.prevent="actions.openRegister"
            style="font-weight: 700; color: #032e5d; text-decoration: none"
            >Đăng ký ngay</a
          >
        </p>
      </div>
    </div>
  </div>
</template>
