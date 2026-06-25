<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';

const router = useRouter();
const auth = useAuthStore();
const username = ref('');
const password = ref('');
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
    await auth.login(username.value.trim(), password.value);
    router.push('/');
  } catch (e) {
    error.value =
      e?.response?.data?.message ||
      e?.message ||
      'Đăng nhập thất bại. Kiểm tra tài khoản / mật khẩu.';
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <div class="login-page">
    <div class="login-card">
      <div class="login-head">
        <div class="logo"></div>
        <div class="name">CNTT<span>shop</span></div>
        <div class="sub">ADMIN CONSOLE</div>
      </div>
      <div class="login-body">
        <div v-if="error" class="alert-err">{{ error }}</div>
        <form @submit.prevent="submit">
          <label>Email hoặc số điện thoại</label>
          <input
            v-model="username"
            class="fld"
            placeholder="admin@gmail.com"
            autocomplete="username"
          />
          <label>Mật khẩu</label>
          <input
            v-model="password"
            class="fld"
            type="password"
            placeholder="••••••••"
            autocomplete="current-password"
          />
          <button class="btn-acc" :disabled="loading">
            {{ loading ? 'Đang đăng nhập...' : 'Đăng nhập' }}
          </button>
        </form>
      </div>
    </div>
  </div>
</template>
