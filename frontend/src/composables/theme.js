export const ACCENTS = [
  { key: 'cyan',    color: '#00e5ff', title: 'Cyan' },
  { key: 'magenta', color: '#ff45e0', title: 'Magenta' },
  { key: 'volt',    color: '#c6ff3d', title: 'Volt' }
]

export function applyAccent(color) {
  document.documentElement.style.setProperty('--acc', color)
  localStorage.setItem('accent', color)
}

export function initAccent() {
  const c = localStorage.getItem('accent')
  if (c) document.documentElement.style.setProperty('--acc', c)
}
