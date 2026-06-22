// Màu (hue) + nhãn EN trang trí cho từng danh mục (dùng cho card/tile/placeholder ảnh)
const HUE = {
  'Laptop': 210, 'PC & Máy tính bàn': 265, 'Linh kiện máy tính': 158,
  'Màn hình': 190, 'Thiết bị ngoại vi': 328, 'Phụ kiện': 328,
  'Điện thoại': 24, 'Tablet': 280
}
const EN = {
  'Laptop': 'LAPTOPS', 'PC & Máy tính bàn': 'DESKTOP PC', 'Linh kiện máy tính': 'COMPONENTS',
  'Màn hình': 'MONITORS', 'Thiết bị ngoại vi': 'GEAR', 'Phụ kiện': 'ACCESSORIES',
  'Điện thoại': 'PHONES', 'Tablet': 'TABLETS'
}

export function catHue(name) {
  if (HUE[name] != null) return HUE[name]
  let h = 0
  for (const c of (name || '')) h = (h * 31 + c.charCodeAt(0)) % 360
  return h
}
export function catEn(name) {
  return EN[name] || (name || 'CNTT').split(' ')[0].toUpperCase()
}
export function formatPrice(v) {
  if (v == null) return 'Liên hệ'
  return new Intl.NumberFormat('vi-VN').format(v) + '₫'
}
