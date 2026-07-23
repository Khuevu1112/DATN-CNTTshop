import { defineStore } from 'pinia';
import { getMyPermissions } from '../api/admin';

export const usePermissionsStore = defineStore('permissions', {
  state: () => ({
    isAdmin: false,
    grants: {}, // { featureKey: [permKey, ...] }
    loaded: false,
  }),

  getters: {
    // Có BẤT KỲ quyền nào trên feature là vào được trang/thấy nav — khớp quy tắc PermissionAspect
    // phía backend cho action=VIEW (kể cả chỉ có "perform"/"limited" cũng đủ để vào).
    canAccess: (s) => (featureKey) => {
      if (s.isAdmin) return true;
      return !!(s.grants[featureKey] && s.grants[featureKey].length > 0);
    },
    // Kiểm tra 1 quyền cụ thể (VD hiện nút "Xoá" chỉ khi có "delete" hoặc "full").
    hasPerm: (s) => (featureKey, permKey) => {
      if (s.isAdmin) return true;
      const perms = s.grants[featureKey] || [];
      return perms.includes('full') || perms.includes(permKey);
    },
  },

  actions: {
    async load() {
      const data = await getMyPermissions();
      this.isAdmin = data.isAdmin;
      this.grants = data.grants || {};
      this.loaded = true;
    },
    reset() {
      this.isAdmin = false;
      this.grants = {};
      this.loaded = false;
    },
  },
});
