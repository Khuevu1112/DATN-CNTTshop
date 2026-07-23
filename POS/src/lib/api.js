import axios from 'axios'
import router from '../router'

export const ASSET_BASE = import.meta.env.VITE_ASSET_BASE || 'http://localhost:8080'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE || 'http://localhost:8080/api'
})

// Gắn token vào mọi request
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('pos_token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// 401 = token sai/hết hạn. 403 = đăng nhập được nhưng KHÔNG có quyền POS.
//
// Phải xử lý cả 403: màn hình đăng nhập đã chặn tài khoản không có quyền, nhưng token lưu sẵn
// từ trước lúc có kiểm tra đó (hoặc bị đặt tay vào localStorage) vẫn lọt qua router guard.
// Backend luôn chặn ở API, nên bắt 403 tại đây là chốt chặn cuối: đá thẳng về màn hình đăng
// nhập thay vì để người không phận sự ngồi trước màn hình bán hàng mà mọi nút đều báo lỗi.
api.interceptors.response.use(
  (res) => res,
  (err) => {
    const st = err.response && err.response.status
    if (st === 401 || st === 403) {
      localStorage.removeItem('pos_token')
      localStorage.removeItem('pos_user')
      if (router.currentRoute.value.path !== '/login') {
        router.push({ path: '/login', query: st === 403 ? { loi: 'khong-co-quyen' } : {} })
      }
    }
    return Promise.reject(err)
  }
)

// Backend trả { message: "..." } -> đọc đúng chỗ
export function apiMessage(err) {
  return (err && err.response && err.response.data && err.response.data.message) || (err && err.message) || 'Đã xảy ra lỗi'
}

// imageUrl trả /uploads/... -> phải ghép host vào trước
export function imgUrl(u) {
  if (!u) return ''
  return /^https?:/i.test(u) ? u : ASSET_BASE + u
}

export function fmt(n) {
  return (Math.round(Number(n) || 0)).toLocaleString('vi-VN') + ' ₫'
}

export function qrFor(url) {
  return 'https://api.qrserver.com/v1/create-qr-code/?size=440x440&data=' + encodeURIComponent(url)
}

export default api
