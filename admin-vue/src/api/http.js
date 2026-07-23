import axios from 'axios'

export const API_ORIGIN = 'http://localhost:8080'
const http = axios.create({ baseURL: API_ORIGIN + '/api' })

// Ảnh có thể là URL tương đối (tải file lên -> "/uploads/products/...") hoặc URL tuyệt đối
// (admin dán thẳng link ngoài) — chỉ ghép API_ORIGIN vào trường hợp đầu.
export function resolveImageUrl(url) {
  if (!url) return ''
  return /^(https?:)?\/\//i.test(url) ? url : API_ORIGIN + url
}

// Gắn JWT admin vào mọi request
http.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token')
  if (token) config.headers.Authorization = 'Bearer ' + token
  return config
})

// 401/403 -> token hết hạn hoặc không đủ quyền -> về trang đăng nhập
http.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response && (err.response.status === 401 || err.response.status === 403)) {
      localStorage.removeItem('admin_token')
      localStorage.removeItem('admin_user')
      if (location.pathname !== '/login') location.href = '/login'
    }
    return Promise.reject(err)
  }
)

export default http
