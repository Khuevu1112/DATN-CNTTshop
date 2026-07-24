<script setup>
import { reactive, ref, computed } from 'vue'
import { trust } from '../data/products.js'
import { state, actions, accent, themeStyle } from '../store.js'
import { forgotPasswordSendOtp, forgotPasswordVerifyOtp, forgotPasswordReset } from '../api.js'

const tab = reactive({ v: 'login' })
const login = reactive({ id: '', pw: '', remember: true, showPw: false })
const reg = reactive({ name: '', id: '', pw: '', pw2: '', agree: false, showPw: false })
const loginLoading = ref(false)
const loginError = ref('')
const regLoading = ref(false)
const regError = ref('')

const isLight = computed(() => state.mode === 'light')
const ink = computed(() => themeStyle.value.ink)
const inkSoft = computed(() => themeStyle.value.inkSoft)
const cardBg = computed(() => isLight.value ? '#f7f9fb' : 'var(--card)')
const cardBorder = computed(() => isLight.value ? 'rgba(14,34,54,0.10)' : 'rgba(var(--line-rgb),0.14)')
const inputBg = computed(() => isLight.value ? '#ffffff' : 'var(--card2)')
const inputBorder = computed(() => isLight.value ? 'rgba(14,34,54,0.16)' : 'rgba(var(--line-rgb),0.2)')

const pillWrapStyle = computed(() => ({
  background: inputBg.value,
  borderColor: inputBorder.value,
  '--tab-ink': inkSoft.value,
  '--acc': accent.value
}))

function friendlyError(e, fallback) {
  return e && e.message && !e.message.startsWith('HTTP') ? e.message : fallback
}

async function submitLogin() {
  loginError.value = ''
  if (!login.id.trim() || !login.pw.trim()) { loginError.value = 'Vui lòng nhập đầy đủ thông tin đăng nhập'; return }
  loginLoading.value = true
  try {
    await actions.login(login.id.trim(), login.pw)
  } catch (e) {
    loginError.value = friendlyError(e, 'Đăng nhập thất bại. Vui lòng kiểm tra tài khoản / mật khẩu.')
  } finally {
    loginLoading.value = false
  }
}

async function submitRegister() {
  regError.value = ''
  if (!reg.name.trim() || !reg.id.trim() || !reg.pw.trim()) { regError.value = 'Vui lòng nhập đầy đủ thông tin'; return }
  if (reg.pw !== reg.pw2) { regError.value = 'Mật khẩu xác nhận không khớp'; return }
  if (!reg.agree) { regError.value = 'Vui lòng đồng ý điều khoản sử dụng'; return }
  regLoading.value = true
  try {
    await actions.register({ hoTen: reg.name.trim(), email: reg.id.trim(), soDienThoai: '', matKhau: reg.pw, reMatKhau: reg.pw2 })
    actions.showToast('Tạo tài khoản thành công! Vui lòng đăng nhập.')
    login.id = reg.id.trim()
    tab.v = 'login'
  } catch (e) {
    regError.value = friendlyError(e, 'Tạo tài khoản thất bại. Vui lòng thử lại.')
  } finally {
    regLoading.value = false
  }
}

function socialLogin(provider) {
  window.location.href = 'http://localhost:8080/oauth2/authorization/' + provider
}

// ===== Quên mật khẩu (OTP qua email) — thay cho placeholder "gọi hotline" =====
const fp = reactive({ step: null, email: '', otp: '', pw: '', pw2: '', error: '', loading: false })
const forgotStepIndex = computed(() => ({ email: 0, otp: 1, reset: 2 })[fp.step] ?? -1)

function openForgot() {
  fp.step = 'email'; fp.error = ''
}
function backToLogin() {
  fp.step = null; fp.error = ''
}
async function fpSendOtp() {
  fp.error = ''
  if (!fp.email.trim()) { fp.error = 'Vui lòng nhập email'; return }
  fp.loading = true
  try {
    await forgotPasswordSendOtp(fp.email.trim())
    fp.step = 'otp'
  } catch (e) {
    fp.error = friendlyError(e, 'Gửi mã thất bại')
  } finally {
    fp.loading = false
  }
}
async function fpVerifyOtp() {
  fp.error = ''
  if (!fp.otp.trim()) { fp.error = 'Vui lòng nhập mã OTP'; return }
  fp.loading = true
  try {
    await forgotPasswordVerifyOtp(fp.email.trim(), fp.otp.trim())
    fp.step = 'reset'
  } catch (e) {
    fp.error = friendlyError(e, 'Mã xác nhận không hợp lệ')
  } finally {
    fp.loading = false
  }
}
async function fpResetPassword() {
  fp.error = ''
  if (!fp.pw || fp.pw.length < 6) { fp.error = 'Mật khẩu phải có ít nhất 6 ký tự'; return }
  if (fp.pw !== fp.pw2) { fp.error = 'Mật khẩu nhập lại không khớp'; return }
  fp.loading = true
  try {
    await forgotPasswordReset(fp.email.trim(), fp.otp.trim(), fp.pw, fp.pw2)
    actions.showToast('Đổi mật khẩu thành công, vui lòng đăng nhập')
    login.id = fp.email
    fp.step = null; fp.email = ''; fp.otp = ''; fp.pw = ''; fp.pw2 = ''
  } catch (e) {
    fp.error = friendlyError(e, 'Đổi mật khẩu thất bại')
  } finally {
    fp.loading = false
  }
}
</script>

<template>
  <div style="min-height:100vh; display:flex; flex-direction:column;">
    <!-- split layout -->
    <div style="flex:1; display:grid; grid-template-columns:1.15fr 1fr; align-items:stretch;">

      <!-- LEFT — brand panel (always dark, always light text) -->
      <aside :style="{ boxShadow: '0 0 110px -10px color-mix(in srgb, ' + accent + ' 40%, transparent)' }" style="position:relative; overflow:hidden; margin:28px; border-radius:28px; background:linear-gradient(150deg,#1e2024 0%, #101114 75%); display:flex; flex-direction:column; justify-content:center; padding:64px 64px; min-height:520px;">
        <div :style="{ background: 'radial-gradient(circle, color-mix(in srgb, ' + accent + ' 36%, transparent), transparent 65%)' }" style="position:absolute; top:-100px; left:-60px; width:380px; height:380px; border-radius:50%; filter:blur(24px); animation:floatBlob 9s ease-in-out infinite; pointer-events:none;"></div>
        <div style="position:relative; max-width:460px;">
          <div :style="{ color: accent }" style="font-family:'Chakra Petch',sans-serif; font-size:12px; letter-spacing:3px; font-weight:600; margin-bottom:18px;">CNTTSHOP // THÀNH VIÊN</div>
          <h1 style="font-family:'Plus Jakarta Sans',sans-serif; font-weight:800; font-size:44px; line-height:1.1; margin:0 0 18px; letter-spacing:-1px; color:#fff;">Chào mừng<br />trở lại.</h1>
          <p style="margin:0 0 36px; font-size:15px; line-height:1.65; color:rgba(255,255,255,0.72); max-width:400px;">Đăng nhập để theo dõi đơn hàng, tích điểm thành viên và nhận ưu đãi riêng dành cho khách hàng CNTTshop.</p>
          <div style="display:flex; flex-direction:column; gap:16px; margin-bottom:40px;">
            <div v-for="(t, i) in trust" :key="i" style="display:flex; align-items:center; gap:13px;">
              <div style="font-size:20px;">{{ t.icon }}</div>
              <div><div style="font-weight:700; font-size:14px; color:#fff;">{{ t.title }}</div><div style="font-size:12px; color:rgba(255,255,255,0.55);">{{ t.sub }}</div></div>
            </div>
          </div>
          <div style="display:flex; gap:30px; padding-top:28px; border-top:1px solid rgba(255,255,255,0.14);">
            <div><div style="font-family:'Chakra Petch',sans-serif; font-weight:700; font-size:22px; color:#fff;">12K+</div><div style="font-size:11px; color:rgba(255,255,255,0.55);">Đơn đã giao</div></div>
            <div><div style="font-family:'Chakra Petch',sans-serif; font-weight:700; font-size:22px; color:#fff;">4.9★</div><div style="font-size:11px; color:rgba(255,255,255,0.55);">Đánh giá khách</div></div>
            <div><div style="font-family:'Chakra Petch',sans-serif; font-weight:700; font-size:22px; color:#fff;">36th</div><div style="font-size:11px; color:rgba(255,255,255,0.55);">Bảo hành tối đa</div></div>
          </div>
        </div>
      </aside>

      <!-- RIGHT — auth card -->
      <section style="display:flex; align-items:center; justify-content:center; padding:48px 56px;">
        <div :style="{ background: cardBg, borderColor: cardBorder }" style="width:100%; max-width:460px; border:1px solid; border-radius:22px; padding:44px 40px;">

          <!-- tabs (ẩn khi đang ở luồng quên mật khẩu) -->
          <div v-if="!fp.step" :style="pillWrapStyle" style="position:relative; display:flex; gap:4px; padding:5px; border-radius:14px; border:1px solid; margin-bottom:32px;">
            <div class="lp-tab-highlight" :style="{ left: tab.v === 'login' ? '5px' : 'calc(50% + 2px)' }" style="position:absolute; top:5px; bottom:5px; width:calc(50% - 7px); border-radius:10px; background:var(--acc,#c6ff4a); z-index:0;"></div>
            <button @click="tab.v = 'login'" :style="{ color: tab.v === 'login' ? 'var(--acc-ink)' : undefined }" class="lp-tab-btn">Đăng nhập</button>
            <button @click="tab.v = 'register'" :style="{ color: tab.v === 'register' ? 'var(--acc-ink)' : undefined }" class="lp-tab-btn">Đăng ký</button>
          </div>

          <!-- LOGIN FORM -->
          <form v-if="!fp.step && tab.v === 'login'" @submit.prevent="submitLogin">
            <h2 :style="{ color: ink }" style="font-family:'Plus Jakarta Sans',sans-serif; font-weight:700; font-size:26px; margin:0 0 8px;">Đăng nhập tài khoản</h2>
            <p :style="{ color: inkSoft }" style="font-size:13.5px; margin:0 0 20px;">Nhập thông tin để tiếp tục mua sắm.</p>

            <div v-if="loginError" style="background:rgba(var(--sale-rgb),0.12); border:1px solid rgba(var(--sale-rgb),0.3); color:var(--sale); padding:11px 13px; border-radius:10px; font-size:13px; margin-bottom:18px;">{{ loginError }}</div>

            <label :style="{ color: inkSoft }" style="display:block; font-size:13px; font-weight:600; margin-bottom:8px;">Email hoặc số điện thoại</label>
            <input v-model="login.id" type="text" placeholder="vd: 0912 345 678" :style="{ background: inputBg, borderColor: inputBorder, color: ink }" class="lp-input" style="width:100%; height:54px; padding:0 16px; border-radius:12px; border:1px solid; font-size:15px; font-family:'Plus Jakarta Sans',sans-serif; margin-bottom:20px;" />

            <label :style="{ color: inkSoft }" style="display:block; font-size:13px; font-weight:600; margin-bottom:8px;">Mật khẩu</label>
            <div style="position:relative; margin-bottom:16px;">
              <input v-model="login.pw" :type="login.showPw ? 'text' : 'password'" placeholder="Nhập mật khẩu" :style="{ background: inputBg, borderColor: inputBorder, color: ink }" class="lp-input" style="width:100%; height:54px; padding:0 48px 0 16px; border-radius:12px; border:1px solid; font-size:15px; font-family:'Plus Jakarta Sans',sans-serif;" />
              <button type="button" @click="login.showPw = !login.showPw" :style="{ color: inkSoft }" style="position:absolute; right:14px; top:50%; transform:translateY(-50%); background:transparent; border:none; cursor:pointer; font-size:16px;">{{ login.showPw ? '🙈' : '👁️' }}</button>
            </div>

            <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:28px;">
              <label style="display:flex; align-items:center; gap:9px; cursor:pointer;">
                <input v-model="login.remember" type="checkbox" :style="{ accentColor: accent }" style="width:18px; height:18px; cursor:pointer;" />
                <span :style="{ color: inkSoft }" style="font-size:13px;">Ghi nhớ đăng nhập</span>
              </label>
              <a href="#" @click.prevent="openForgot" :style="{ color: accent }" style="font-size:13px; font-weight:600; text-decoration:none;">Quên mật khẩu?</a>
            </div>

            <button type="submit" :disabled="loginLoading" :style="{ background: accent, boxShadow: '0 12px 28px color-mix(in srgb, ' + accent + ' 38%, transparent)' }" class="lp-submit" style="width:100%; height:56px; border:none; border-radius:13px; color:var(--acc-ink); font-family:'Plus Jakarta Sans',sans-serif; font-weight:700; font-size:16px; cursor:pointer;">{{ loginLoading ? 'Đang xử lý...' : 'Đăng nhập' }}</button>

            <div style="display:flex; align-items:center; gap:14px; margin:28px 0;">
              <div :style="{ background: inputBorder }" style="flex:1; height:1px;"></div>
              <span :style="{ color: inkSoft }" style="font-size:12.5px;">hoặc tiếp tục với</span>
              <div :style="{ background: inputBorder }" style="flex:1; height:1px;"></div>
            </div>

            <div style="display:flex; flex-direction:column; gap:12px;">
              <button type="button" @click="socialLogin('google')" :style="{ background: inputBg, borderColor: inputBorder, color: ink }" class="lp-social" style="height:52px; border-radius:12px; border:1px solid; display:flex; align-items:center; justify-content:center; gap:10px; cursor:pointer; font-family:'Plus Jakarta Sans',sans-serif; font-weight:600; font-size:14px;">
                <span style="width:22px; height:22px; border-radius:50%; background:#4285F4; color:#fff; font-family:'Chakra Petch',sans-serif; font-weight:700; font-size:12px; display:flex; align-items:center; justify-content:center;">G</span> Tiếp tục với Google
              </button>
              <button type="button" @click="socialLogin('facebook')" :style="{ background: inputBg, borderColor: inputBorder, color: ink }" class="lp-social" style="height:52px; border-radius:12px; border:1px solid; display:flex; align-items:center; justify-content:center; gap:10px; cursor:pointer; font-family:'Plus Jakarta Sans',sans-serif; font-weight:600; font-size:14px;">
                <span style="width:22px; height:22px; border-radius:50%; background:#1877F2; color:#fff; font-family:'Chakra Petch',sans-serif; font-weight:700; font-size:12px; display:flex; align-items:center; justify-content:center;">f</span> Tiếp tục với Facebook
              </button>
            </div>

            <p :style="{ color: inkSoft }" style="text-align:center; font-size:13.5px; margin:28px 0 0;">Chưa có tài khoản? <a href="#" @click.prevent="tab.v = 'register'" :style="{ color: accent }" style="font-weight:700; text-decoration:none;">Đăng ký ngay</a></p>
          </form>

          <!-- REGISTER FORM -->
          <form v-else-if="!fp.step" @submit.prevent="submitRegister">
            <h2 :style="{ color: ink }" style="font-family:'Plus Jakarta Sans',sans-serif; font-weight:700; font-size:26px; margin:0 0 8px;">Tạo tài khoản mới</h2>
            <p :style="{ color: inkSoft }" style="font-size:13.5px; margin:0 0 20px;">Chỉ mất chưa đầy 1 phút.</p>

            <div v-if="regError" style="background:rgba(var(--sale-rgb),0.12); border:1px solid rgba(var(--sale-rgb),0.3); color:var(--sale); padding:11px 13px; border-radius:10px; font-size:13px; margin-bottom:18px;">{{ regError }}</div>

            <label :style="{ color: inkSoft }" style="display:block; font-size:13px; font-weight:600; margin-bottom:8px;">Họ và tên</label>
            <input v-model="reg.name" type="text" placeholder="Nguyễn Văn A" :style="{ background: inputBg, borderColor: inputBorder, color: ink }" class="lp-input" style="width:100%; height:54px; padding:0 16px; border-radius:12px; border:1px solid; font-size:15px; font-family:'Plus Jakarta Sans',sans-serif; margin-bottom:18px;" />

            <label :style="{ color: inkSoft }" style="display:block; font-size:13px; font-weight:600; margin-bottom:8px;">Email</label>
            <input v-model="reg.id" type="email" placeholder="vd: ban@email.com" :style="{ background: inputBg, borderColor: inputBorder, color: ink }" class="lp-input" style="width:100%; height:54px; padding:0 16px; border-radius:12px; border:1px solid; font-size:15px; font-family:'Plus Jakarta Sans',sans-serif; margin-bottom:18px;" />

            <div style="display:grid; grid-template-columns:1fr 1fr; gap:14px; margin-bottom:18px;">
              <div>
                <label :style="{ color: inkSoft }" style="display:block; font-size:13px; font-weight:600; margin-bottom:8px;">Mật khẩu</label>
                <input v-model="reg.pw" :type="reg.showPw ? 'text' : 'password'" placeholder="Tối thiểu 8 ký tự" :style="{ background: inputBg, borderColor: inputBorder, color: ink }" class="lp-input" style="width:100%; height:54px; padding:0 16px; border-radius:12px; border:1px solid; font-size:15px; font-family:'Plus Jakarta Sans',sans-serif;" />
              </div>
              <div>
                <label :style="{ color: inkSoft }" style="display:block; font-size:13px; font-weight:600; margin-bottom:8px;">Xác nhận</label>
                <input v-model="reg.pw2" :type="reg.showPw ? 'text' : 'password'" placeholder="Nhập lại mật khẩu" :style="{ background: inputBg, borderColor: inputBorder, color: ink }" class="lp-input" style="width:100%; height:54px; padding:0 16px; border-radius:12px; border:1px solid; font-size:15px; font-family:'Plus Jakarta Sans',sans-serif;" />
              </div>
            </div>

            <label style="display:flex; align-items:center; gap:9px; cursor:pointer; margin-bottom:26px;">
              <input v-model="reg.agree" type="checkbox" :style="{ accentColor: accent }" style="width:18px; height:18px; cursor:pointer; flex:none;" />
              <span :style="{ color: inkSoft }" style="font-size:13px;">Tôi đồng ý với Điều khoản sử dụng &amp; Chính sách bảo mật</span>
            </label>

            <button type="submit" :disabled="regLoading" :style="{ background: accent, boxShadow: '0 12px 28px color-mix(in srgb, ' + accent + ' 38%, transparent)' }" class="lp-submit" style="width:100%; height:56px; border:none; border-radius:13px; color:var(--acc-ink); font-family:'Plus Jakarta Sans',sans-serif; font-weight:700; font-size:16px; cursor:pointer;">{{ regLoading ? 'Đang xử lý...' : 'Tạo tài khoản' }}</button>

            <div style="display:flex; align-items:center; gap:14px; margin:28px 0;">
              <div :style="{ background: inputBorder }" style="flex:1; height:1px;"></div>
              <span :style="{ color: inkSoft }" style="font-size:12.5px;">hoặc tiếp tục với</span>
              <div :style="{ background: inputBorder }" style="flex:1; height:1px;"></div>
            </div>

            <div style="display:flex; flex-direction:column; gap:12px;">
              <button type="button" @click="socialLogin('google')" :style="{ background: inputBg, borderColor: inputBorder, color: ink }" class="lp-social" style="height:52px; border-radius:12px; border:1px solid; display:flex; align-items:center; justify-content:center; gap:10px; cursor:pointer; font-family:'Plus Jakarta Sans',sans-serif; font-weight:600; font-size:14px;">
                <span style="width:22px; height:22px; border-radius:50%; background:#4285F4; color:#fff; font-family:'Chakra Petch',sans-serif; font-weight:700; font-size:12px; display:flex; align-items:center; justify-content:center;">G</span> Tiếp tục với Google
              </button>
              <button type="button" @click="socialLogin('facebook')" :style="{ background: inputBg, borderColor: inputBorder, color: ink }" class="lp-social" style="height:52px; border-radius:12px; border:1px solid; display:flex; align-items:center; justify-content:center; gap:10px; cursor:pointer; font-family:'Plus Jakarta Sans',sans-serif; font-weight:600; font-size:14px;">
                <span style="width:22px; height:22px; border-radius:50%; background:#1877F2; color:#fff; font-family:'Chakra Petch',sans-serif; font-weight:700; font-size:12px; display:flex; align-items:center; justify-content:center;">f</span> Tiếp tục với Facebook
              </button>
            </div>

            <p :style="{ color: inkSoft }" style="text-align:center; font-size:13.5px; margin:28px 0 0;">Đã có tài khoản? <a href="#" @click.prevent="tab.v = 'login'" :style="{ color: accent }" style="font-weight:700; text-decoration:none;">Đăng nhập</a></p>
          </form>

          <!-- QUÊN MẬT KHẨU (OTP qua email) -->
          <div v-else>
            <div style="display:flex; align-items:center; gap:8px; margin-bottom:26px;">
              <span v-for="i in 3" :key="i" :style="{ background: i - 1 <= forgotStepIndex ? accent : inputBorder }" style="height:4px; flex:1; border-radius:2px;"></span>
            </div>

            <div v-if="fp.error" style="background:rgba(var(--sale-rgb),0.12); border:1px solid rgba(var(--sale-rgb),0.3); color:var(--sale); padding:11px 13px; border-radius:10px; font-size:13px; margin-bottom:18px;">{{ fp.error }}</div>

            <template v-if="fp.step === 'email'">
              <h2 :style="{ color: ink }" style="font-family:'Plus Jakarta Sans',sans-serif; font-weight:700; font-size:24px; margin:0 0 8px;">Quên mật khẩu</h2>
              <p :style="{ color: inkSoft }" style="font-size:13.5px; margin:0 0 22px;">Nhập email đã đăng ký, chúng tôi sẽ gửi mã xác nhận.</p>
              <form @submit.prevent="fpSendOtp">
                <label :style="{ color: inkSoft }" style="display:block; font-size:13px; font-weight:600; margin-bottom:8px;">Email tài khoản</label>
                <input v-model="fp.email" type="email" placeholder="email@gmail.com" :style="{ background: inputBg, borderColor: inputBorder, color: ink }" class="lp-input" style="width:100%; height:54px; padding:0 16px; border-radius:12px; border:1px solid; font-size:15px; font-family:'Plus Jakarta Sans',sans-serif; margin-bottom:22px;" />
                <button type="submit" :disabled="fp.loading" :style="{ background: accent }" class="lp-submit" style="width:100%; height:56px; border:none; border-radius:13px; color:var(--acc-ink); font-family:'Plus Jakarta Sans',sans-serif; font-weight:700; font-size:16px; cursor:pointer;">{{ fp.loading ? 'Đang gửi...' : 'Gửi mã xác nhận' }}</button>
              </form>
            </template>

            <template v-else-if="fp.step === 'otp'">
              <h2 :style="{ color: ink }" style="font-family:'Plus Jakarta Sans',sans-serif; font-weight:700; font-size:24px; margin:0 0 8px;">Nhập mã xác nhận</h2>
              <p :style="{ color: inkSoft }" style="font-size:13.5px; margin:0 0 22px;">Mã OTP đã gửi tới <b :style="{ color: ink }">{{ fp.email }}</b> (hiệu lực 5 phút).</p>
              <form @submit.prevent="fpVerifyOtp">
                <label :style="{ color: inkSoft }" style="display:block; font-size:13px; font-weight:600; margin-bottom:8px;">Mã 6 số</label>
                <input v-model="fp.otp" type="text" maxlength="6" placeholder="000000" :style="{ background: inputBg, borderColor: inputBorder, color: ink }" class="lp-input" style="width:100%; height:54px; padding:0 16px; border-radius:12px; border:1px solid; font-size:18px; font-family:'Chakra Petch',monospace; text-align:center; letter-spacing:6px; margin-bottom:22px;" />
                <button type="submit" :disabled="fp.loading" :style="{ background: accent }" class="lp-submit" style="width:100%; height:56px; border:none; border-radius:13px; color:var(--acc-ink); font-family:'Plus Jakarta Sans',sans-serif; font-weight:700; font-size:16px; cursor:pointer;">{{ fp.loading ? 'Đang xác nhận...' : 'Xác nhận' }}</button>
              </form>
            </template>

            <template v-else-if="fp.step === 'reset'">
              <h2 :style="{ color: ink }" style="font-family:'Plus Jakarta Sans',sans-serif; font-weight:700; font-size:24px; margin:0 0 8px;">Đặt mật khẩu mới</h2>
              <p :style="{ color: inkSoft }" style="font-size:13.5px; margin:0 0 22px;">Tạo mật khẩu mới cho tài khoản của bạn.</p>
              <form @submit.prevent="fpResetPassword">
                <label :style="{ color: inkSoft }" style="display:block; font-size:13px; font-weight:600; margin-bottom:8px;">Mật khẩu mới</label>
                <input v-model="fp.pw" type="password" placeholder="••••••••" :style="{ background: inputBg, borderColor: inputBorder, color: ink }" class="lp-input" style="width:100%; height:54px; padding:0 16px; border-radius:12px; border:1px solid; font-size:15px; font-family:'Plus Jakarta Sans',sans-serif; margin-bottom:14px;" />
                <label :style="{ color: inkSoft }" style="display:block; font-size:13px; font-weight:600; margin-bottom:8px;">Nhập lại mật khẩu mới</label>
                <input v-model="fp.pw2" type="password" placeholder="••••••••" :style="{ background: inputBg, borderColor: inputBorder, color: ink }" class="lp-input" style="width:100%; height:54px; padding:0 16px; border-radius:12px; border:1px solid; font-size:15px; font-family:'Plus Jakarta Sans',sans-serif; margin-bottom:22px;" />
                <button type="submit" :disabled="fp.loading" :style="{ background: accent }" class="lp-submit" style="width:100%; height:56px; border:none; border-radius:13px; color:var(--acc-ink); font-family:'Plus Jakarta Sans',sans-serif; font-weight:700; font-size:16px; cursor:pointer;">{{ fp.loading ? 'Đang lưu...' : 'Đổi mật khẩu' }}</button>
              </form>
            </template>

            <p style="text-align:center; margin:22px 0 0;"><a href="#" @click.prevent="backToLogin" :style="{ color: inkSoft }" style="font-size:12.5px; text-decoration:none;">← Quay lại đăng nhập</a></p>
          </div>

        </div>
      </section>
    </div>
  </div>
</template>

<style scoped>
.lp-input:focus { outline: none; border-color: var(--acc, #c6ff4a) !important; }
.lp-submit:hover { filter: brightness(1.06); }
.lp-submit:disabled { opacity: .65; cursor: default; }
.lp-social:hover { filter: brightness(1.12); }
.lp-tab-btn {
  position: relative;
  z-index: 1;
  flex: 1;
  height: 46px;
  border: none;
  border-radius: 10px;
  font-family: 'Plus Jakarta Sans', sans-serif;
  font-weight: 700;
  font-size: 14.5px;
  cursor: pointer;
  background: transparent;
  color: var(--tab-ink, var(--muted2));
  transition: color 0.25s ease;
}
.lp-tab-highlight {
  transition: left 0.32s cubic-bezier(.4, 0, .2, 1);
}
@keyframes floatBlob {
  0%, 100% { transform: translate(0, 0); }
  50% { transform: translate(24px, 18px); }
}
</style>
