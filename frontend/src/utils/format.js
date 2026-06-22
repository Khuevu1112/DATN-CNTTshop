export function formatPrice(v) {
  if (v == null) return '0 ₫'
  return new Intl.NumberFormat('vi-VN').format(v) + ' ₫'
}

export function formatDate(v) {
  if (!v) return ''
  return new Date(v).toLocaleDateString('vi-VN')
}
