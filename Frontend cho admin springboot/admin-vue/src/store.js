import { reactive } from 'vue';

export const ui = reactive({ search: '', mode: 'dark' });

export function initMode() {
  document.documentElement.setAttribute('data-mode', ui.mode);
}
export function toggleMode() {
  ui.mode = ui.mode === 'dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-mode', ui.mode);
}
