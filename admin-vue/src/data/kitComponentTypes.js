// Danh sách loại linh kiện dùng chung cho Mẫu cấu hình (KitTemplates.vue) VÀ nút "Thêm bộ đã
// cấu hình sẵn" trong form sản phẩm (ProductFormModal.vue) — 1 nơi định nghĩa duy nhất để 2 chỗ
// luôn khớp nhau (label ở đây cũng chính là tên khoá "Cấu hình" hiển thị trên trang sản phẩm).
export const TYPES = [
  { key: 'CPU', label: 'CPU', icon: 'bi-cpu' },
  { key: 'Mainboard', label: 'Mainboard', icon: 'bi-motherboard' },
  { key: 'RAM', label: 'RAM', icon: 'bi-memory' },
  { key: 'GPU', label: 'Card đồ họa', icon: 'bi-gpu-card' },
  { key: 'SSD', label: 'Ổ SSD', icon: 'bi-device-ssd' },
  { key: 'HDD', label: 'Ổ HDD', icon: 'bi-hdd' },
  { key: 'PSU', label: 'Nguồn', icon: 'bi-plug' },
  { key: 'Case', label: 'Vỏ case', icon: 'bi-pc' },
  { key: 'Cooler', label: 'Tản nhiệt', icon: 'bi-fan' },
  { key: 'Monitor', label: 'Màn hình', icon: 'bi-display' },
  { key: 'Mouse', label: 'Chuột', icon: 'bi-mouse' },
  { key: 'Keyboard', label: 'Bàn phím', icon: 'bi-keyboard' },
];

export function typeInfo(key) {
  return TYPES.find((t) => t.key === key) || { key, label: key, icon: 'bi-box' };
}
