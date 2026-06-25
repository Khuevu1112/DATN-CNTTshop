import { reactive } from 'vue';

export const ui = reactive({
  search: '',
  mode: localStorage.getItem('admin_mode') || 'dark',
});

export function initMode() {
  document.documentElement.setAttribute('data-mode', ui.mode);
}
export function toggleMode() {
  ui.mode = ui.mode === 'dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-mode', ui.mode);
  localStorage.setItem('admin_mode', ui.mode);
}
