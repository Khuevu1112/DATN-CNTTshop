/* ===========================================================================
 * Hằng số dùng chung cho khu vực Trung tâm hỗ trợ.
 *
 * Mã nhóm thiết bị phải KHỚP CHÍNH XÁC với giá trị lưu trong CSDL (cột SERVICE_CENTER.dich_vu,
 * REPAIR_PRICE.loai_thiet_bi, SERVICE_APPOINTMENT.loai_thiet_bi — xem 66_support_center.sql).
 * Đổi mã ở đây mà không chạy migration tương ứng sẽ làm bộ lọc trung tâm im lặng trả về rỗng.
 * =========================================================================== */

// "Máy in" và "Thiết bị mạng" đã gộp vào "Thiết bị ngoại vi" (mã ngoai_vi) — xem migration
// database/67_support_adjust.sql. Dữ liệu cũ trong CSDL đã được chuyển mã tương ứng, nên chỉ cần
// bỏ hai mã cũ ở đây là mọi bộ lọc/tab tự cập nhật theo.
export const LOAI_THIET_BI = [
  { ma: 'laptop', ten: 'Laptop', icon: '💻' },
  { ma: 'pc', ten: 'PC / Máy bàn', icon: '🖥️' },
  { ma: 'man_hinh', ten: 'Màn hình', icon: '🖵' },
  { ma: 'linh_kien', ten: 'Linh kiện lẻ', icon: '🔧' },
  { ma: 'ngoai_vi', ten: 'Thiết bị ngoại vi', icon: '🖱️' },
];

export const tenLoaiThietBi = (ma) =>
  LOAI_THIET_BI.find((l) => l.ma === ma)?.ten || ma;

export const iconLoaiThietBi = (ma) =>
  LOAI_THIET_BI.find((l) => l.ma === ma)?.icon || '🔩';

/** Bán kính tìm kiếm quanh vị trí khách. Chỉ có tác dụng khi khách cho phép định vị — không có
 * toạ độ thì backend bỏ qua tham số này. */
export const BAN_KINH = [
  { km: 10, nhan: '~10 km' },
  { km: 20, nhan: '~20 km' },
  { km: 30, nhan: '~30 km' },
  { km: 50, nhan: '~50 km' },
];

export const nhanTrangThaiLich = {
  cho_xac_nhan: { nhan: 'Chờ xác nhận', mau: 'var(--muted2)' },
  da_xac_nhan: { nhan: 'Đã xác nhận', mau: 'var(--green)' },
  dang_xu_ly: { nhan: 'Đang xử lý', mau: 'var(--acc, #c6ff4a)' },
  hoan_thanh: { nhan: 'Hoàn thành', mau: 'var(--green)' },
  khach_khong_den: { nhan: 'Khách không đến', mau: 'var(--sale)' },
  da_huy: { nhan: 'Đã huỷ', mau: 'var(--sale)' },
};

/** Ngày ISO (yyyy-mm-dd) — dùng cho input[type=date] và tham số API. */
export const isoDate = (d) => {
  const x = d instanceof Date ? d : new Date(d);
  const p = (n) => String(n).padStart(2, '0');
  return `${x.getFullYear()}-${p(x.getMonth() + 1)}-${p(x.getDate())}`;
};

export const ngayVN = (iso) => {
  if (!iso) return '';
  const [y, m, d] = String(iso).slice(0, 10).split('-');
  return `${d}/${m}/${y}`;
};
