// ===== Catalog data — NẠP TỪ BACKEND (REST /api), giữ nguyên shape mà UI đang dùng =====
import { reactive } from 'vue';
import {
  fetchCategories,
  fetchProducts,
  fetchProductBySlug,
  fetchBestsellers,
} from '../api.js';

// Mỗi màu accent có 1 bản riêng cho chế độ sáng — bản dark (lime/magenta rực) quá
// nhạt/chói nếu giữ nguyên trên nền trắng, nên tối màu lại để đủ tương phản.
export const accents = {
  dark: { cyan: '#c6ff4a', magenta: '#ff45e0' },
  light: { cyan: '#4d7a1a', magenta: '#c2185b' },
};

// Reactive — sẽ được điền sau khi gọi loadCatalog()
export const catMeta = reactive({}); // slug -> { vn, en, hue }
export const products = reactive([]); // danh sách sản phẩm (đã map về shape của UI)

// 9 danh mục linh kiện chi tiết (database/18_pc_build_categories.sql) — gộp chung vào 1
// mega-menu ngang "Linh kiện máy tính" (kiểu TTGShop). Dùng chung cho mega-menu ở AppHeader
// VÀ widget "luôn hiện" ở trang chủ (HomeView), để 2 nơi luôn khớp nhau.
export const COMPONENT_GROUPS_DEF = [
  {
    title: 'Bộ xử lý & bo mạch',
    items: [
      { slug: 'cpu', icon: 'bi-cpu' },
      { slug: 'mainboard', icon: 'bi-motherboard' },
      { slug: 'ram', icon: 'bi-memory' },
    ],
  },
  {
    title: 'Đồ họa & lưu trữ',
    items: [
      { slug: 'gpu', icon: 'bi-gpu-card' },
      { slug: 'ssd', icon: 'bi-device-ssd' },
      { slug: 'hdd', icon: 'bi-hdd' },
    ],
  },
  {
    title: 'Nguồn & tản nhiệt',
    items: [
      { slug: 'psu', icon: 'bi-lightning-charge' },
      { slug: 'case-may-tinh', icon: 'bi-pc-display' },
      { slug: 'tan-nhiet-cpu', icon: 'bi-wind' },
    ],
  },
];
export const COMPONENT_SLUGS = COMPONENT_GROUPS_DEF.flatMap((g) => g.items.map((it) => it.slug));
// Danh mục "Linh kiện máy tính" cũ (gộp chung, đã hết dữ liệu sau khi tách nhỏ) — ẩn khỏi nav.
export const HIDDEN_SLUGS = ['linh-kien'];

// Phân khúc theo chức năng cho từng danh mục (kiểu TTGShop) — dùng chung cho mega-menu ở
// AppHeader VÀ bộ lọc "Phân khúc" ở CategoryView, để 2 nơi luôn khớp nhau. Mỗi mục lọc theo
// từ khoá khớp trong tên sản phẩm (xem matchesQuery bên dưới) — từ khoá chọn dựa trên khảo sát
// tên sản phẩm thật đang có trong CSDL cho từng danh mục.
export const CATEGORY_SEGMENTS = [
  {
    slug: 'laptop',
    icon: 'bi-laptop',
    items: [
      // "gaming" bắt các sản phẩm có hậu tố tên chuẩn; bổ sung thêm vài dòng gaming thật
      // (Nitro/Katana/LOQ) cho 3 sản phẩm đời đầu chưa theo quy ước đặt tên đó.
      { keyword: 'gaming|nitro|katana|loq', label: 'Laptop Gaming', icon: 'bi-joystick' },
      { keyword: 'văn phòng', label: 'Laptop Văn phòng', icon: 'bi-briefcase' },
      { keyword: 'mỏng nhẹ', label: 'Laptop Mỏng nhẹ', icon: 'bi-feather' },
      // Khớp theo GPU trong specs (RTX 4060 trở lên) — chỉ khả thi sau khi sửa thứ tự spec
      // để GPU luôn có trong danh sách specs trả về (xem 28_laptop_gpu_spec_fix.sql).
      { keyword: 'rtx 4060|rtx 4070|rtx 4080|rtx 4090', label: 'Laptop Đồ họa - Hiệu năng cao', icon: 'bi-palette' },
      // Khớp theo CPU Intel Core Ultra (dòng có NPU, chuẩn "AI PC" của Intel).
      { keyword: 'core ultra', label: 'Laptop AI', icon: 'bi-cpu' },
    ],
  },
  {
    slug: 'pc-may-tinh-ban',
    icon: 'bi-pc-display-horizontal',
    items: [
      // "gaming" khớp tên (PC Gaming...) chỉ bắt được số ít — đa phần PC gaming sinh hàng loạt
      // đặt tên theo codename (Blaze/Vortex/Storm...) và ghi model GPU ngay trong tên
      // (VD "PC CNTT Ryzen Blaze R5-5600 RTX4060"), nên khớp thêm theo hậu tố GPU rời. Phải
      // loại trừ workstation/giả lập ảo hoá/full bộ vì các dòng đó cũng dùng card RTX/GTX rời
      // (nếu không loại trừ, chúng sẽ bị đếm lẫn luôn vào "PC Gaming" — đúng bug đã gặp).
      { keyword: 'gaming|rtx|gtx|gt10|rx6|rx7!workstation|giả lập|ảo hóa|full bộ', label: 'PC Gaming', icon: 'bi-joystick' },
      { keyword: 'văn phòng', label: 'PC Văn phòng', icon: 'bi-briefcase' },
      { keyword: 'đồ họa', label: 'PC Đồ họa - Studio', icon: 'bi-palette' },
      { keyword: 'full bộ', label: 'PC Full - Kèm màn hình', icon: 'bi-box-seam' },
      { keyword: 'giả lập|ảo hóa', label: 'PC Ảo hóa - Giả lập', icon: 'bi-hdd-stack' },
      { keyword: 'workstation', label: 'PC Workstation', icon: 'bi-diagram-3' },
      { keyword: 'mini|micro|slim desk', label: 'PC Mini - Gọn nhẹ', icon: 'bi-box' },
    ],
  },
  {
    slug: 'man-hinh',
    icon: 'bi-display',
    items: [
      { keyword: '75hz', label: 'Màn hình Văn phòng', icon: 'bi-window' },
      // Mở rộng theo tần số quét cao (180/240/360Hz) + tên dòng/hãng gaming thật
      // (ROG, TUF, Zowie, Mobiuz) — trước đây chỉ bắt 144/165Hz nên bỏ sót nhiều màn 240Hz+.
      {
        keyword: '144hz|165hz|180hz|240hz|360hz|odyssey|ultragear|vg27aq|rog|tuf|zowie|mobiuz',
        label: 'Màn hình Gaming',
        icon: 'bi-joystick',
      },
      { keyword: 'ultrawide', label: 'Màn hình Ultrawide', icon: 'bi-aspect-ratio' },
      { keyword: '4k|ultrasharp|viewfinity|proart', label: 'Màn hình Đồ họa', icon: 'bi-palette' },
    ],
  },
  {
    slug: 'ngoai-vi',
    icon: 'bi-keyboard',
    items: [
      { keyword: 'bàn phím', label: 'Bàn phím', icon: 'bi-keyboard' },
      { keyword: 'chuột', label: 'Chuột', icon: 'bi-mouse2' },
      { keyword: 'tai nghe', label: 'Tai nghe', icon: 'bi-headset' },
      { keyword: 'webcam|loa', label: 'Webcam & Loa', icon: 'bi-camera-video' },
    ],
  },
  {
    slug: 'phu-kien',
    icon: 'bi-bag',
    items: [
      { keyword: 'balo|túi|giá đỡ', label: 'Bảo vệ & mang theo', icon: 'bi-backpack' },
      { keyword: 'hub|cáp|sạc|wifi', label: 'Sạc & kết nối', icon: 'bi-plug' },
      { keyword: 'tai nghe|lót chuột', label: 'Âm thanh & chuột', icon: 'bi-headphones' },
    ],
  },
];

export const trust = [
  { icon: '🚚', title: 'Giao nhanh 2h', sub: 'Nội thành HN & HCM' },
  { icon: '🛡️', title: 'Bảo hành 36 tháng', sub: '1 đổi 1 tận nơi' },
  { icon: '💳', title: 'Trả góp 0%', sub: 'Duyệt nhanh 15 phút' },
  { icon: '✅', title: 'Chính hãng 100%', sub: 'Hoàn tiền nếu fake' },
];

export const fmt = (n) =>
  n == null ? '0₫' : Number(n).toLocaleString('vi-VN') + '₫';

// HAI tỉ giá TÁCH RỜI, phải khớp VND_MOI_XU_KIEM/VND_MOI_XU_TIEU bên WalletService. Dùng nhầm
// chiều là hiển thị sai tiền cho khách (chênh 10 lần). Đây chỉ là ước tính để hiển thị trước
// khi đặt hàng — số thật luôn do backend tính lại lúc thanh toán.
export const VND_MOI_XU_KIEM = 10000; // tiêu 10.000đ được 1 xu
export const VND_MOI_XU_TIEU = 1000;  // 1 xu giảm được 1.000đ

/** Số xu KIẾM ĐƯỢC khi mua món hàng giá này — dùng ở thẻ sản phẩm / giỏ hàng. */
export const silverTokensFor = (price) =>
  price == null ? 0 : Math.floor(Number(price) / VND_MOI_XU_KIEM);

// Mô tả sản phẩm: gõ "- "/"• " đầu dòng = gạch đầu dòng, dòng trống = ngắt đoạn, xuống dòng
// thường = <br>. Escape HTML trước khi dựng thẻ để tránh XSS qua v-html.
export function renderDescription(text) {
  if (!text) return '';
  const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  const paragraphs = String(text).split(/\n\s*\n/);
  return paragraphs
    .map((para) => {
      const lines = para.split('\n').filter((l) => l.trim() !== '');
      if (!lines.length) return '';
      const isBullet = (l) => /^[-•]\s+/.test(l.trim());
      if (lines.every(isBullet)) {
        return (
          '<ul style="margin:0;padding-left:18px">' +
          lines.map((l) => '<li>' + esc(l.trim().replace(/^[-•]\s+/, '')) + '</li>').join('') +
          '</ul>'
        );
      }
      return '<p style="margin:0">' + lines.map(esc).join('<br>') + '</p>';
    })
    .filter(Boolean)
    .join('<div style="height:10px"></div>');
}

// ===== Helpers (giữ nguyên hành vi cũ) =====
export const defaultSel = (p) => {
  const o = {};
  if (p && p.cfg)
    p.cfg.forEach((g) => {
      o[g.key] = 0;
    });
  return o;
};
export const priceWith = (p, sel) => {
  let t = p ? p.price : 0;
  if (p && p.cfg)
    p.cfg.forEach((g) => {
      const i = sel && sel[g.key] != null ? sel[g.key] : 0;
      t += g.ch[i] ? g.ch[i].d : 0;
    });
  return t;
};
export const cfgKey = (p, sel) => {
  if (!p || !p.cfg || !p.cfg.length) return 'p' + (p ? p.id : '');
  return (
    'p' +
    p.id +
    '|' +
    p.cfg
      .map((g) => g.key + (sel && sel[g.key] != null ? sel[g.key] : 0))
      .join('-')
  );
};
export const productById = (id) => products.find((p) => p.id === id);

/** So khớp 1 sản phẩm với chuỗi tìm kiếm — hỗ trợ nhiều từ khoá nối bằng "|" (khớp OR),
 * dùng để lọc theo tên/hãng/thông số cả ở ô tìm kiếm lẫn các mục mega-menu theo chức năng.
 * Có xét thêm p.specs (CPU/GPU/RAM...) vì nhiều model thật (VD "MSI Thin 13UC") không có
 * từ khoá phân khúc trong tên — GPU trong specs là tín hiệu đáng tin hơn để suy ra phân khúc.
 * Hỗ trợ thêm "!" để loại trừ (VD "gaming|rtx!workstation|full bộ" = khớp gaming/rtx NHƯNG
 * KHÔNG khớp nếu có workstation/full bộ) — cần vì 1 số cụm từ khoá (VD "rtx") vốn dùng để suy ra
 * PC Gaming lại trùng với PC Workstation/Ảo hoá/Full bộ (cùng dùng card RTX rời), nếu không loại
 * trừ thì các dòng đó sẽ bị đếm/lẫn luôn vào "PC Gaming". */
export function matchesQuery(p, q) {
  if (!q || !q.trim()) return true;
  const [includePart, excludePart] = q.split('!');
  const terms = includePart.toLowerCase().split('|').map((s) => s.trim()).filter(Boolean);
  const name = (p.name || '').toLowerCase();
  const brand = (p.brand || '').toLowerCase();
  const specText = (p.specs || []).map((s) => s.v || '').join(' ').toLowerCase();
  const included = terms.some((t) => name.includes(t) || brand.includes(t) || specText.includes(t));
  if (!included) return false;
  if (excludePart) {
    const excludeTerms = excludePart.toLowerCase().split('|').map((s) => s.trim()).filter(Boolean);
    if (excludeTerms.some((t) => name.includes(t) || brand.includes(t) || specText.includes(t))) return false;
  }
  return true;
}

// ===== Suy ra nhãn EN + màu hue theo tên danh mục =====
const EN = {
  Laptop: 'LAPTOPS',
  'PC & Máy tính bàn': 'DESKTOP PC',
  'Linh kiện máy tính': 'COMPONENTS',
  'Màn hình': 'MONITORS',
  'Thiết bị ngoại vi': 'GEAR',
  'Phụ kiện': 'ACCESSORIES',
  'Điện thoại': 'PHONES',
  Tablet: 'TABLETS',
};
const HUE = {
  Laptop: 210,
  'PC & Máy tính bàn': 265,
  'Linh kiện máy tính': 158,
  'Màn hình': 190,
  'Thiết bị ngoại vi': 328,
  'Phụ kiện': 328,
  'Điện thoại': 24,
  Tablet: 280,
};
const enOf = (name) => EN[name] || (name || '').split(' ')[0].toUpperCase();
const hueOf = (name) => {
  if (HUE[name] != null) return HUE[name];
  let h = 0;
  for (const c of name || '') h = (h * 31 + c.charCodeAt(0)) % 360;
  return h;
};
const slugifyKey = (s) =>
  (s || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');

let _loaded = false;

const nameToSlug = {};
function resolveCatSlug(categoryName) {
  const cat = nameToSlug[categoryName] || slugifyKey(categoryName) || 'khac';
  if (!catMeta[cat])
    catMeta[cat] = {
      vn: categoryName || 'Khác',
      en: enOf(categoryName),
      hue: hueOf(categoryName),
    };
  return cat;
}

/** Map 1 ProductSummaryDto từ backend về shape UI dùng trong toàn app. Từ khi backend trả full
 * specs/promotions/warrantyMonths ngay ở API danh sách (không chỉ trang chi tiết), card đã có đủ
 * dữ liệu cho tháp xem trước khi hover mà không cần đợi loadDetail() — cfg (option/variant) thì
 * vẫn phải đợi loadDetail như cũ vì chỉ API chi tiết mới trả. */
function mapProductDto(p) {
  const cat = resolveCatSlug(p.categoryName);
  return {
    id: p.id,
    slug: p.slug,
    cat,
    brand: p.brandName || p.categoryName || 'CNTTshop',
    name: p.name,
    price: p.price || 0,
    oldPrice: p.originalPrice || 0,
    rating: p.rating || 0,
    reviews: p.reviewCount || 0,
    soldCount: p.soldCount || 0,
    stock: p.stock ?? 0,
    badge: '',
    hue: catMeta[cat].hue,
    featured: true,
    specs: p.specs && p.specs.length
      ? p.specs.map((s) => ({ k: s.key, v: s.value }))
      : (p.chips || []).map((c) => ({ k: '', v: c })),
    promotions: p.promotions || [],
    warrantyMonths: p.warrantyMonths ?? null,
    image: p.imageUrl || null,
    cfg: null,
    _detail: false,
  };
}

/** Nạp danh mục + sản phẩm từ backend, build catMeta + products (shape UI). */
export async function loadCatalog() {
  if (_loaded) return;
  const [cats, prods] = await Promise.all([fetchCategories(), fetchProducts()]);

  cats.forEach((c) => {
    nameToSlug[c.name] = c.slug;
    catMeta[c.slug] = { vn: c.name, en: enOf(c.name), hue: hueOf(c.name) };
  });

  products.splice(0, products.length, ...prods.map(mapProductDto));
  _loaded = true;
}

export const bestsellers = reactive([]);

/** Nạp Top sản phẩm bán chạy nhất (gọi sau loadCatalog để catMeta đã sẵn). */
export async function loadBestsellers(limit = 8) {
  const prods = await fetchBestsellers(limit);
  bestsellers.splice(0, bestsellers.length, ...prods.map(mapProductDto));
}

/** Nạp chi tiết 1 sản phẩm (specs thật + cfg từ variants/options) và gộp vào object. */
export async function loadDetail(p) {
  if (!p || p._detail) return;
  const d = await fetchProductBySlug(p.slug);

  const prices = (d.variants || []).map((v) => v.price || 0);
  const basePrice = prices.length ? Math.min(...prices) : p.price;

  const cfg = (d.options || []).map((o) => ({
    key: slugifyKey(o.name) || o.name,
    label: o.name,
    linkedGroup: o.linkedGroup || null,
    ch: (o.values || []).map((val) => {
      // giá chênh lệch = (variant rẻ nhất có giá trị này) - giá gốc — độc lập thứ tự
      const matched = (d.variants || [])
        .filter((v) => v.options && v.options[o.name] === val)
        .map((v) => v.price || 0);
      const price = matched.length ? Math.min(...matched) : basePrice;
      return { l: val, d: Math.max(0, price - (basePrice || 0)) };
    }),
  }));

  p.price = basePrice;
  p.specs = (d.specs || []).map((s) => ({ k: s.key, v: s.value }));
  p.cfg = cfg.length ? cfg : null;
  p.description = d.description;
  p.promotions = d.promotions || [];
  p.images = d.images || [];
  p.bundles = (d.bundles || []).map(mapProductDto);
  p._variants = d.variants || [];
  p._detail = true;
}

/** Khớp tổ hợp option đã chọn (sel) với variantId thật từ backend — dùng để gọi API giỏ hàng. */
export function resolveVariantId(p, sel) {
  if (!p || !p._variants || !p._variants.length) return null;
  if (!p.cfg || !p.cfg.length) return p._variants[0].id;

  const chon = {};
  p.cfg.forEach((g) => {
    const idx = sel && sel[g.key] != null ? sel[g.key] : 0;
    chon[g.label] = g.ch[idx] ? g.ch[idx].l : null;
  });

  const match = p._variants.find((v) =>
    Object.entries(chon).every(([name, val]) => !v.options || v.options[name] === val),
  );
  return (match || p._variants[0]).id;
}
