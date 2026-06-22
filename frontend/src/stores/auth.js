import { defineStore } from 'pinia'
import { login as apiLogin, register as apiRegister } from '../api/auth'

/**
 * Quản lý trạng thái đăng nhập. Lưu token + user vào localStorage
 * để giữ phiên khi reload (bước sau sẽ nối với JWT backend).
 */
export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('token') || '',
    user: JSON.parse(localStorage.getItem('user') || 'null')
  }),

  getters: {
    isAuthenticated: (s) => !!s.token,
    isAdmin: (s) => s.user?.role === 'admin' || s.user?.role === 'staff'
  },

  actions: {
    async login(username, password) {
      const data = await apiLogin({ username, password })
      this.token = data.token
      this.user = data.user
      localStorage.setItem('token', data.token)
      localStorage.setItem('user', JSON.stringify(data.user))
      return data
    },

    async register(payload) {
      return await apiRegister(payload)
    },

    logout() {
      this.token = ''
      this.user = null
      localStorage.removeItem('token')
      localStorage.removeItem('user')
    }
  }
})
