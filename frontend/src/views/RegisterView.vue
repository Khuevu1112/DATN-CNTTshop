<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const auth = useAuthStore()

const form = reactive({ hoTen: '', email: '', soDienThoai: '', matKhau: '', reMatKhau: '' })
const error = ref('')
const loading = ref(false)

async function submit() {
  error.value = ''
  if (!form.hoTen || !form.email || !form.matKhau) {
    error.value = 'Vui lòng nhập đầy đủ họ tên, email và mật khẩu.'
    return
  }
  if (form.matKhau !== form.reMatKhau) {
    error.value = 'Mật khẩu nhập lại không khớp.'
    return
  }
  loading.value = true
  try {
    await auth.register({ ...form })
    router.push({ path: '/login', query: { registered: '1' } })
  } catch (e) {
    error.value = e?.response?.data?.message || 'Đăng ký thất bại. Vui lòng thử lại.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="auth-page">
    <div class="auth-card">
      <div class="auth-head">
        <i class="bi bi-pc-display-horizontal"></i><span>CNTTShop</span>
      </div>

      <div class="p-4">
        <h4 class="fw-bold text-navy mb-1">Tạo tài khoản</h4>
        <p class="text-muted small mb-4">Đăng ký để mua sắm nhanh hơn.</p>

        <div v-if="error" class="alert alert-danger py-2">{{ error }}</div>

        <form @submit.prevent="submit">
          <div class="mb-3">
            <label class="form-label fw-semibold">Họ và tên</label>
            <input v-model="form.hoTen" type="text" class="form-control" placeholder="Nguyễn Văn A">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Email</label>
            <input v-model="form.email" type="email" class="form-control" placeholder="email@gmail.com">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Số điện thoại</label>
            <input v-model="form.soDienThoai" type="text" class="form-control" placeholder="09xxxxxxxx">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Mật khẩu</label>
            <input v-model="form.matKhau" type="password" class="form-control" placeholder="••••••••">
          </div>
          <div class="mb-4">
            <label class="form-label fw-semibold">Nhập lại mật khẩu</label>
            <input v-model="form.reMatKhau" type="password" class="form-control" placeholder="••••••••">
          </div>

          <button class="btn btn-navy w-100 py-2 fw-semibold" :disabled="loading">
            <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
            Đăng ký
          </button>
        </form>

        <p class="text-center text-muted small mt-4 mb-0">
          Đã có tài khoản?
          <router-link to="/login" class="fw-semibold text-decoration-none">Đăng nhập</router-link>
        </p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.auth-page { display: flex; justify-content: center; padding: 24px 0; }
.auth-card {
  width: 100%; max-width: 430px; background: #fff;
  border-radius: 14px; overflow: hidden;
  box-shadow: 0 10px 30px rgba(8, 26, 45, .12);
}
.auth-head {
  background: linear-gradient(90deg, #081a2d, #032e5d);
  color: #fff; text-align: center; padding: 22px;
  font-size: 1.4rem; font-weight: 700;
}
.auth-head i { margin-right: 6px; }
</style>
