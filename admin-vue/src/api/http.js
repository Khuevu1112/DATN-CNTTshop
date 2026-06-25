import axios from 'axios'

const http = axios.create({ baseURL: 'http://localhost:8080/api' })

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
