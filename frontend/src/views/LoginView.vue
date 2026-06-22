<script setup>
import { ref } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from '../stores/auth';

const router = useRouter();
const route = useRoute();
const auth = useAuthStore();

const username = ref('');
const password = ref('');
const showPassword = ref(false);
const error = ref('');
const loading = ref(false);

const justRegistered = route.query.registered === '1';

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
      'Đăng nhập thất bại. Vui lòng kiểm tra tài khoản / mật khẩu.';
  } finally {
    loading.value = false;
  }
}

// Hàm quay lại trang trước đó
function goBack() {
  if (window.history.length > 1) {
    router.back();
  } else {
    router.push('/'); // Quay về trang chủ nếu không có lịch sử duyệt
  }
}
</script>

<template>
  <!-- 1. Bắt sự kiện click vào vùng ngoài (auth-page) -->
  <div class="auth-page" @click="goBack">
    <!-- 2. Thêm @click.stop để ngăn chặn việc tắt khi nhấn vào bên trong card -->
    <div class="auth-card" @click.stop>
      <div class="auth-head">
        <i class="bi bi-pc-display-horizontal"></i><span>CNTTShop</span>
      </div>

      <div class="p-4">
        <h4 class="fw-bold text-navy mb-1">Đăng nhập</h4>
        <p class="text-muted small mb-4">Chào mừng bạn quay lại!</p>

        <div v-if="justRegistered" class="alert alert-success py-2">
          Đăng ký thành công, vui lòng đăng nhập.
        </div>
        <div v-if="error" class="alert alert-danger py-2">{{ error }}</div>

        <form @submit.prevent="submit">
          <div class="mb-3">
            <label class="form-label fw-semibold text-dark"
              >Email hoặc số điện thoại</label
            >
            <div class="input-group">
              <span class="input-group-text"><i class="bi bi-person"></i></span>
              <input
                v-model="username"
                type="text"
                class="form-control"
                placeholder="vd: email@gmail.com"
                autocomplete="username"
              />
            </div>
          </div>

          <div class="mb-2">
            <label class="form-label fw-semibold text-dark">Mật khẩu</label>
            <div class="input-group">
              <span class="input-group-text"><i class="bi bi-lock"></i></span>
              <input
                v-model="password"
                :type="showPassword ? 'text' : 'password'"
                class="form-control"
                placeholder="••••••••"
                autocomplete="current-password"
              />
              <button
                class="btn btn-outline-secondary"
                type="button"
                @click="showPassword = !showPassword"
              >
                <i :class="showPassword ? 'bi bi-eye-slash' : 'bi bi-eye'"></i>
              </button>
            </div>
          </div>

          <div class="d-flex justify-content-end mb-3">
            <router-link
              to="/forgot-password"
              class="small text-decoration-none"
            >
              Quên mật khẩu?
            </router-link>
          </div>

          <button
            class="btn btn-navy w-100 py-2 fw-semibold"
            :disabled="loading"
          >
            <span
              v-if="loading"
              class="spinner-border spinner-border-sm me-1"
            ></span>
            Đăng nhập
          </button>
        </form>

        <p class="text-center text-muted small mt-4 mb-0">
          Chưa có tài khoản?
          <router-link to="/register" class="fw-semibold text-decoration-none"
            >Đăng ký ngay</router-link
          >
        </p>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 3. Cập nhật CSS lớp phủ ngoài để phủ kín màn hình và bắt sự kiện click */
.auth-page {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center; /* Căn giữa form theo chiều dọc */
  background: rgba(
    0,
    0,
    0,
    0.4
  ); /* Bạn có thể điều chỉnh độ mờ tối của nền tại đây */
  z-index: 9999;
  padding: 24px 0;
}

.auth-card {
  width: 100%;
  max-width: 430px;
  background: #fff;
  border-radius: 14px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(8, 26, 45, 0.12);
}

.auth-head {
  background: linear-gradient(90deg, #081a2d, #032e5d);
  color: #fff;
  text-align: center;
  padding: 22px;
  font-size: 1.4rem;
  font-weight: 700;
}

.auth-head i {
  margin-right: 6px;
}
</style>
