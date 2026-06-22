import axios from 'axios'

/**
 * Axios instance trỏ tới Spring Boot REST API (cổng 8080).
 */
const http = axios.create({
  baseURL: 'http://localhost:8080/api',
  headers: { 'Content-Type': 'application/json' }
})

// Tự gắn JWT (nếu đã đăng nhập) vào mọi request
http.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

export default http
