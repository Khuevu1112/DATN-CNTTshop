<template>
  <div class="wrap">
    <div class="card">
      <div class="head">
        <div class="logo">P</div>
        <div>
          <div class="t">POS Bán hàng</div>
          <div class="s">Đăng nhập để tiếp tục</div>
        </div>
      </div>

      <label>Tài khoản</label>
      <input class="field" v-model="acc" placeholder="tên đăng nhập" />

      <label>Mật khẩu</label>
      <input class="field" type="password" v-model="pass" placeholder="••••••••" @keydown.enter="doLogin" />

      <div v-if="err" class="err">{{ err }}</div>

      <button class="submit" :disabled="loading" @click="doLogin">
        {{ loading ? 'Đang đăng nhập…' : 'Đăng nhập' }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api, { apiMessage } from '../lib/api'

const router = useRouter()
const route = useRoute()
const acc = ref('')
const pass = ref('')
// Bị interceptor đá ra giữa chừng vì mất quyền -> nói rõ lý do, tránh cảnh người dùng bị văng
// về màn hình đăng nhập mà không hiểu chuyện gì xảy ra.
const err = ref(route.query.loi === 'khong-co-quyen'
  ? 'Phiên làm việc đã kết thúc: tài khoản không có quyền bán hàng tại quầy.'
  : '')
const loading = ref(false)

async function doLogin() {
  if (loading.value) return
  loading.value = true
  err.value = ''
  try {
    // Backend nhận đúng tên trường username/password (xem AuthDtos.LoginRequest) — gửi
    // tenDangNhap/matKhau sẽ bị map thành null và luôn đăng nhập thất bại.
    const { data } = await api.post('/auth/login', { username: acc.value, password: pass.value })
    const token = data && (data.token || data.accessToken || data.jwt || (data.data && (data.data.token || data.data.accessToken)))
    if (!token) throw new Error('Không nhận được token từ máy chủ')

    // Lưu token TRƯỚC để lời gọi kiểm quyền ngay bên dưới có Authorization header.
    localStorage.setItem('pos_token', token)

    // Chặn theo QUYỀN, không chỉ theo "đã đăng nhập". Trước đây chỉ cần có token là vào được
    // màn hình bán hàng — nghĩa là cả tài khoản KHÁCH HÀNG lẫn nhân viên phòng ban không liên
    // quan (kế toán, kho, kỹ thuật...) đều mở được giao diện quầy. Backend vẫn chặn ở API nên
    // không mất dữ liệu, nhưng người không phận sự thấy được toàn bộ màn hình bán hàng và mọi
    // thao tác đều báo lỗi 403 khó hiểu.
    let duocVao = false
    try {
      const { data: q } = await api.get('/admin/permissions/me')
      // Admin bỏ qua mọi kiểm tra quyền (xem PermissionAspect) nên isAdmin=true là vào được.
      duocVao = !!(q && (q.isAdmin || (q.grants && Array.isArray(q.grants.pos) && q.grants.pos.length)))
    } catch (e) {
      // 403 ở đây = tài khoản khách hàng (không thuộc nhóm nhân viên) -> chắc chắn không được vào.
      duocVao = false
    }

    if (!duocVao) {
      localStorage.removeItem('pos_token')
      throw new Error('Tài khoản này không có quyền bán hàng tại quầy. Liên hệ quản trị viên để được cấp quyền POS.')
    }

    if (data.user) localStorage.setItem('pos_user', JSON.stringify(data.user))
    router.push('/')
  } catch (e) {
    err.value = apiMessage(e)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.wrap { min-height: 100vh; display: flex; align-items: center; justify-content: center; background: #101114; padding: 24px; }
.card { width: 100%; max-width: 380px; background: var(--card); border-radius: 14px; padding: 34px 30px; box-shadow: 0 20px 60px rgba(0,0,0,.4); }
.head { display: flex; align-items: center; gap: 11px; margin-bottom: 24px; }
.logo { width: 40px; height: 40px; border-radius: 9px; background: var(--acc); display: flex; align-items: center; justify-content: center; color: var(--acc-ink); font-weight: 800; font-size: 20px; }
.t { font-weight: 700; font-size: 17px; }
.s { font-size: 12px; color: var(--muted); }
label { display: block; font-size: 12px; font-weight: 600; color: var(--muted); margin: 14px 0 6px; }
.card > label:first-of-type { margin-top: 0; }
.err { color: var(--sale); font-size: 13px; margin-top: 8px; }
.submit { width: 100%; height: 46px; margin-top: 18px; border: none; border-radius: 9px; background: var(--acc); color: var(--acc-ink); font-size: 15px; font-weight: 700; }
.submit:disabled { opacity: .6; }
</style>
