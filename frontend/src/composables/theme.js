export const ACCENTS = [
  { key: 'cyan',    color: '#00e5ff', title: 'Cyan' },
  { key: 'magenta', color: '#ff45e0', title: 'Magenta' }
]

export function applyAccent(color) {
  document.documentElement.style.setProperty('--acc', color)
  localStorage.setItem('accent', color)
}
export function initAccent() {
  const c = localStorage.getItem('accent')
  if (c) document.documentElement.style.setProperty('--acc', c)
}

// ===== Chế độ Sáng / Tối =====
export function getMode() {
  return localStorage.getItem('mode') || 'dark'
}
export function applyMode(mode) {
  document.documentElement.setAttribute('data-mode', mode)
  localStorage.setItem('mode', mode)
}
export function initMode() {
  applyMode(getMode())
}
export function toggleMode() {
  const next = getMode() === 'light' ? 'dark' : 'light'
  applyMode(next)
  return next
}
