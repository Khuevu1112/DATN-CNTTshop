import { defineStore } from 'pinia';
import http from '../api/http';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('admin_token') || '',
    user: JSON.parse(localStorage.getItem('admin_user') || 'null'),
  }),

  getters: {
    isAuthenticated: (s) => !!s.token,
    displayName: (s) => s.user?.fullName || s.user?.email || 'Quản trị viên',
  },

  actions: {
    async login(username, password) {
      const { data } = await http.post('/auth/login', { username, password });
      const role = (data.user?.role || '').toLowerCase();
      if (role !== 'admin' && role !== 'staff') {
        throw new Error(
          'Tài khoản này không có quyền truy cập trang quản trị.',
        );
      }
      this.token = data.token;
      this.user = data.user;
      localStorage.setItem('admin_token', this.token);
      localStorage.setItem('admin_user', JSON.stringify(this.user));
    },
    logout() {
      this.token = '';
      this.user = null;
      localStorage.removeItem('admin_token');
      localStorage.removeItem('admin_user');
    },
  },
});
