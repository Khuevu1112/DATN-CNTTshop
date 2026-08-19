// Data layer — nạp dữ liệu thật từ backend (/api/admin/*), không còn dùng dữ liệu mẫu.
import { reactive } from 'vue';
import {
  getAdminProducts,
  getAdminOrders,
  getAdminCustomers,
  getAdminCoupons,
  getCategories,
  getStaffAccounts,
} from '../api/admin';
import { API_ORIGIN } from '../api/http';

export const money = (n) => n.toLocaleString('vi-VN') + '₫';

// Ô nhập tiền: hiện dấu chấm phân cách hàng nghìn khi gõ (24.990.000) nhưng lưu số thuần trong
// state — input phải để type="text" vì <input type="number"> không cho hiển thị dấu chấm.
export function fmtMoneyInput(n) {
  if (n === null || n === undefined || n === '') return '';
  return Number(n).toLocaleString('vi-VN');
}
export function parseMoneyInput(str) {
  const digits = String(str).replace(/[^\d]/g, '');
  return digits === '' ? null : Number(digits);
}
export function short(n) {
  if (n >= 1e9)
    return (n / 1e9).toFixed(n >= 1e10 ? 0 : 1).replace('.0', '') + ' tỷ';
  if (n >= 1e6)
    return (n / 1e6).toFixed(n >= 1e7 ? 0 : 1).replace('.0', '') + 'tr';
  if (n >= 1e3) return Math.round(n / 1e3) + 'k';
  return n + '';
}
export const grad = (h) =>
  'linear-gradient(135deg,hsl(' + h + ' 45% 22%),hsl(' + h + ' 55% 12%))';
export const gradText = (h) => 'hsl(' + h + ' 70% 75%)';
export const gradAvatar = (h) =>
  'linear-gradient(135deg,hsl(' + h + ' 50% 40%),hsl(' + h + ' 60% 26%))';
export const gradCat = (h) =>
  'linear-gradient(135deg,hsl(' + h + ' 50% 22%),hsl(' + h + ' 60% 11%))';
export const initials = (name) =>
  name
    .split(' ')
    .slice(-2)
    .map((w) => w[0])
    .join('')
    .toUpperCase();

/** slug -> { label, hue }, nạp thật từ /api/categories trong loadAdminData(). */
export const CATS = reactive({});
const HUE_PALETTE = [210, 265, 150, 190, 32, 330, 24, 280, 60, 120];
function applyCategories(categories) {
  categories.forEach((c, i) => {
    CATS[c.slug] = { label: c.name, hue: HUE_PALETTE[i % HUE_PALETTE.length] };
  });
}
export const STATUS = {
  pending: { label: 'Chờ xác nhận', color: '#ffb43b' },
  confirmed: { label: 'Đã xác nhận', color: '#00e5ff' },
  processing: { label: 'Đang xử lý', color: '#7aa2ff' },
  shipped: { label: 'Đang giao', color: '#a855f7' },
  delivered: { label: 'Hoàn tất', color: '#22d39a' },
  cancelled: { label: 'Đã huỷ', color: '#ff3b5c' },
  // Hai mốc CUỐI khác nhau: "Hoàn hàng" = hàng đã về kho nhưng TIỀN CHƯA TRẢ;
  // "Hoàn tiền" = đã chuyển tiền lại cho khách (chỉ tới được sau Hoàn hàng).
  returned: { label: 'Hoàn hàng', color: '#f59e0b' },
  refunded: { label: 'Hoàn tiền', color: '#94a3b8' },
};
const stBgOf = (c) => 'color-mix(in srgb,' + c + ' 16%, transparent)';

/** Ngưỡng cảnh báo "sắp hết hàng" (tồn <= mức này). PHẢI khớp NGUONG_SAP_HET bên
 * cnttshop-vue/src/data/products.js — hai bên nói khác nhau thì admin thấy "còn hàng" trong khi
 * trang khách đã hiện "sắp hết". */
export const NGUONG_SAP_HET = 5;

export const PRODUCTS = reactive([]);
export const ORDERS = reactive([]);
export const CUSTOMERS = reactive([]);
export const STAFF_ACCOUNTS = reactive([]);
export const COUPONS = reactive([]);

export const RM = {
  customer: { label: 'Khách hàng', color: '#7aa2ff' },
  admin: { label: 'Quản trị', color: '#ff3b5c' },
  ke_toan: { label: 'Kế toán', color: '#ffb43b' },
  kho: { label: 'Kho', color: '#22d39a' },
  ky_thuat: { label: 'Kỹ thuật', color: '#00e5ff' },
  cskh: { label: 'CSKH', color: '#a855f7' },
  giao_hang: { label: 'Giao hàng', color: '#38bdf8' },
  kinh_doanh: { label: 'Kinh doanh', color: '#fb7185' },
};

function tagOf(s) {
  return (
    (s || '')
      .replace(/[^A-Za-z0-9]/g, '')
      .slice(0, 3)
      .toUpperCase() || 'SKU'
  );
}
function fmtDateTime(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  const p = (n) => String(n).padStart(2, '0');
  return `${p(d.getDate())}/${p(d.getMonth() + 1)} ${p(d.getHours())}:${p(d.getMinutes())}`;
}
function fmtMonthYear(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  return `${String(d.getMonth() + 1).padStart(2, '0')}/${d.getFullYear()}`;
}
function fmtDateFull(iso) {
  if (!iso) return 'Không giới hạn';
  const d = new Date(iso);
  const p = (n) => String(n).padStart(2, '0');
  return `${p(d.getDate())}/${p(d.getMonth() + 1)}/${d.getFullYear()}`;
}

function mapProduct(p) {
  const catSlug = p.categorySlug;
  const meta = CATS[catSlug] || { label: p.categoryName, hue: 200 };
  const price = Number(p.price || 0);
  const oldp = Number(p.originalPrice || 0);
  return {
    id: p.id,
    name: p.name,
    catSlug,
    cat: meta.label,
    hue: meta.hue,
    brand: p.brandName || p.categoryName || 'CNTTshop',
    tag: tagOf(p.brandName || p.name),
    sku: p.sku,
    price,
    oldp,
    stock: Number(p.stock || 0),
    spec: p.spec || '',
    imageUrl: p.imageUrl || '',
    active: !!p.isActive,
    priceFmt: money(price),
    oldFmt: oldp ? money(oldp) : '',
    disc: oldp ? Math.round((1 - price / oldp) * 100) : 0,
  };
}

function mapOrder(o) {
  const meta = STATUS[o.status] || { label: o.status, color: '#7d818a' };
  const total = Number(o.total || 0);
  return {
    id: o.id,
    code: o.code,
    customer: o.customerName,
    email: o.customerEmail,
    total,
    totalFmt: money(total),
    st: o.status,
    stLabel: meta.label,
    stColor: meta.color,
    stBg: stBgOf(meta.color),
    date: fmtDateTime(o.createdAt),
    createdAtRaw: o.createdAt, // bản thô để DataTable sắp xếp/lọc theo khoảng ngày
    item: o.itemSummary,
    init: initials(o.customerName || '?'),
    paymentMethod: o.paymentMethod,
    paymentStatus: o.paymentStatus,
    proofImage: o.proofImage ? API_ORIGIN + o.proofImage : '',
  };
}

function mapCustomer(c, i) {
  const meta = RM[c.role] || { label: c.role, color: '#7aa2ff' };
  const spent = Number(c.totalSpent || 0);
  return {
    id: c.id,
    name: c.name,
    email: c.email,
    phone: c.phone,
    role: c.role,
    roleLabel: meta.label,
    roleColor: meta.color,
    roleBg: stBgOf(meta.color),
    init: initials(c.name || '?'),
    orders: Number(c.orderCount || 0),
    spent,
    spentFmt: money(spent),
    joined: fmtMonthYear(c.joinedAt),
    joinedRaw: c.joinedAt, // bản thô để DataTable sắp xếp/lọc theo khoảng ngày
    active: !!c.isActive,
    hue: [210, 265, 150, 190, 32, 330][i % 6],
  };
}

const COUPON_STATUS = {
  active: { label: 'Đang chạy', color: 'var(--green)' },
  expired: { label: 'Hết hạn', color: 'var(--sale)' },
  paused: { label: 'Tạm dừng', color: 'var(--muted)' },
};

function mapCoupon(c) {
  const isPercent = c.discountType === 'percent';
  const used = Number(c.usedCount || 0);
  const max = c.maxUses;
  const min = Number(c.minOrderValue || 0);
  const isExpired = c.expiresAt && new Date(c.expiresAt) < new Date();
  const status = isExpired ? 'expired' : c.isActive ? 'active' : 'paused';
  const meta = COUPON_STATUS[status];
  return {
    id: c.id,
    code: c.code,
    type: isPercent ? 'Phần trăm' : 'Tiền mặt',
    typeColor: isPercent ? 'var(--acc)' : '#a855f7',
    value: isPercent
      ? Number(c.discountValue) + '%' + (c.maxDiscountAmount ? ` (tối đa ${money(Number(c.maxDiscountAmount))})` : '')
      : money(Number(c.discountValue)),
    min: min > 0 ? money(min) : 'Không',
    // Bản SỐ/NGÀY thô của các cột đã format — DataTable cần chúng để sắp xếp và lọc khoảng
    // min–max cho đúng (so chuỗi "1.000.000₫" với "900.000₫" sẽ ra sai thứ tự).
    giaTriSo: Number(c.discountValue || 0),
    donToiThieuSo: min,
    hetHanLuc: c.expiresAt || null,
    used: max ? used + '/' + max : used + '',
    daDungSo: used,
    usedPct: max ? Math.round((used / max) * 100) + '%' : '—',
    exp: fmtDateFull(c.expiresAt),
    xuCost: c.xuCost || null,
    stackable: !!c.stackable,
    exclusiveGroup: c.exclusiveGroup || null,
    status,
    stText: meta.label,
    stColor: meta.color,
    stBg: 'color-mix(in srgb,' + meta.color + ' 16%,transparent)',
  };
}

/** Nạp lại riêng danh sách sản phẩm — gọi sau khi thêm/sửa/xoá sản phẩm trong admin. */
export async function refreshAdminProducts() {
  const products = await getAdminProducts();
  PRODUCTS.splice(0, PRODUCTS.length, ...products.map(mapProduct));
}

/** Nạp lại riêng danh sách đơn hàng — gọi sau khi cập nhật trạng thái đơn. */
export async function refreshAdminOrders() {
  const orders = await getAdminOrders();
  ORDERS.splice(0, ORDERS.length, ...orders.map(mapOrder));
}

/** Nạp lại riêng danh sách coupon — gọi sau khi tạo/xoá coupon. */
export async function refreshAdminCoupons() {
  const coupons = await getAdminCoupons();
  COUPONS.splice(0, COUPONS.length, ...coupons.map(mapCoupon));
}

/** Nạp lại riêng danh mục — gọi sau khi thêm danh mục mới. */
export async function refreshAdminCategories() {
  applyCategories(await getCategories());
}

/** Nạp danh sách tài khoản nhân viên — chỉ admin có quyền, KHÔNG gọi trong loadAdminData()
 *  vì mọi phòng ban khác đều bị 422 ở endpoint này (Promise.all sẽ hỏng cả batch). */
export async function refreshStaffAccounts() {
  const staff = await getStaffAccounts();
  STAFF_ACCOUNTS.splice(0, STAFF_ACCOUNTS.length, ...staff.map(mapCustomer));
}

let _loaded = false;
/** Nạp toàn bộ dữ liệu admin (danh mục/sản phẩm/đơn hàng/khách hàng/khuyến mãi) từ backend, gọi 1 lần. */
export async function loadAdminData() {
  if (_loaded) return;
  _loaded = true;
  try {
    const [categories, products, orders, customers, coupons] = await Promise.all([
      getCategories(),
      getAdminProducts(),
      getAdminOrders(),
      getAdminCustomers(),
      getAdminCoupons(),
    ]);
    applyCategories(categories);
    PRODUCTS.splice(0, PRODUCTS.length, ...products.map(mapProduct));
    ORDERS.splice(0, ORDERS.length, ...orders.map(mapOrder));
    CUSTOMERS.splice(0, CUSTOMERS.length, ...customers.map(mapCustomer));
    COUPONS.splice(0, COUPONS.length, ...coupons.map(mapCoupon));
  } catch (e) {
    _loaded = false;
    throw e;
  }
}

export const NAV_GROUPS = [
  {
    title: 'Tổng quan',
    items: [
      ['dashboard', 'Bảng điều khiển', 'bi-grid-1x2-fill'],
      ['analytics', 'Phân tích', 'bi-graph-up-arrow'],
      ['cashflow', 'Dòng tiền', 'bi-cash-stack'],
    ],
  },
  {
    title: 'Bán hàng',
    items: [
      ['orders', 'Đơn hàng', 'bi-receipt'],
      ['products', 'Sản phẩm', 'bi-box-seam'],
      ['goods-receipts', 'Nhập kho', 'bi-box-arrow-in-down'],
      ['kit-templates', 'Mẫu cấu hình', 'bi-diagram-3'],
      ['trade-in', 'Thu cũ đổi mới', 'bi-arrow-repeat'],
    ],
  },
  {
    title: 'Khách hàng',
    items: [
      ['customers', 'Quản lý tài khoản', 'bi-people'],
      ['contacts', 'Liên hệ', 'bi-envelope-paper'],
      ['warranty', 'Bảo hành', 'bi-shield-check'],
      ['service-appointments', 'Lịch hẹn dịch vụ', 'bi-calendar-check'],
      ['returns', 'Đổi trả hàng', 'bi-arrow-return-left'],
      ['support-content', 'Nội dung hỗ trợ', 'bi-life-preserver'],
    ],
  },
  {
    title: 'Marketing',
    items: [
      ['coupons', 'Khuyến mãi', 'bi-ticket-perforated'],
      ['articles', 'Tin tức', 'bi-newspaper'],
      ['shipping', 'Phí giao hàng', 'bi-truck'],
    ],
  },
];

// ---- sparkline / area helpers (dashboard scale) ----
export function buildSpark(arr) {
  const max = Math.max(...arr),
    min = Math.min(...arr),
    w = 120,
    h = 34;
  return arr
    .map((v, i) => {
      const x = (i / (arr.length - 1)) * w;
      const y = h - 2 - ((v - min) / (max - min || 1)) * (h - 6);
      return (i ? 'L' : 'M') + x.toFixed(1) + ' ' + y.toFixed(1);
    })
    .join(' ');
}
export function buildArea(arr, line) {
  const max = Math.max(...arr),
    min = 0,
    w = 560,
    h = 200;
  const pts = arr.map((v, i) => {
    const x = (i / (arr.length - 1)) * w;
    const y = h - 8 - ((v - min) / (max - min || 1)) * (h - 24);
    return [x, y];
  });
  const d = pts
    .map((p, i) => (i ? 'L' : 'M') + p[0].toFixed(1) + ' ' + p[1].toFixed(1))
    .join(' ');
  return line ? d : d + ' L' + w + ' ' + h + ' L0 ' + h + ' Z';
}

// ---- analytics chart geometry ----
export const CHART = { W: 860, H: 320, padL: 50, padR: 18, padT: 14, padB: 32 };
const plotW = CHART.W - CHART.padL - CHART.padR,
  plotH = CHART.H - CHART.padT - CHART.padB;
export const X = (i, n) => CHART.padL + (i / (n - 1)) * plotW;
export const Y = (v, max) => CHART.padT + plotH - (v / max) * plotH;
export const PLOT_BOTTOM = CHART.padT + plotH;
export function statusBreak() {
  const total = ORDERS.length;
  return [
    'delivered',
    'shipped',
    'processing',
    'confirmed',
    'pending',
    'cancelled',
    'returned',
    'refunded',
  ]
    .map((k) => {
      const cnt = ORDERS.filter((o) => o.st === k).length;
      return {
        label: STATUS[k].label,
        color: STATUS[k].color,
        count: cnt + '',
        pct: Math.round((cnt / total) * 100) + '%',
        show: cnt > 0,
      };
    })
    .filter((s) => s.show);
}
