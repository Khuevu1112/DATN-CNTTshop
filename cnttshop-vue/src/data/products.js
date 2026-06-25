// ===== Catalog data — NẠP TỪ BACKEND (REST /api), giữ nguyên shape mà UI đang dùng =====
import { reactive } from 'vue';
import { fetchCategories, fetchProducts, fetchProductBySlug } from '../api.js';

export const accents = { cyan: '#00e5ff', magenta: '#ff45e0' };

// Reactive — sẽ được điền sau khi gọi loadCatalog()
export const catMeta = reactive({}); // slug -> { vn, en, hue }
export const products = reactive([]); // danh sách sản phẩm (đã map về shape của UI)

export const trust = [
  { icon: '🚚', title: 'Giao nhanh 2h', sub: 'Nội thành HN & HCM' },
  { icon: '🛡️', title: 'Bảo hành 36 tháng', sub: '1 đổi 1 tận nơi' },
  { icon: '💳', title: 'Trả góp 0%', sub: 'Duyệt nhanh 15 phút' },
  { icon: '✅', title: 'Chính hãng 100%', sub: 'Hoàn tiền nếu fake' },
];

export const fmt = (n) =>
  n == null ? '0₫' : Number(n).toLocaleString('vi-VN') + '₫';

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

/** Nạp danh mục + sản phẩm từ backend, build catMeta + products (shape UI). */
export async function loadCatalog() {
  if (_loaded) return;
  const [cats, prods] = await Promise.all([fetchCategories(), fetchProducts()]);

  const nameToSlug = {};
  cats.forEach((c) => {
    nameToSlug[c.name] = c.slug;
    catMeta[c.slug] = { vn: c.name, en: enOf(c.name), hue: hueOf(c.name) };
  });

  const mapped = prods.map((p) => {
    const cat =
      nameToSlug[p.categoryName] || slugifyKey(p.categoryName) || 'khac';
    if (!catMeta[cat])
      catMeta[cat] = {
        vn: p.categoryName || 'Khác',
        en: enOf(p.categoryName),
        hue: hueOf(p.categoryName),
      };
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
      badge: '',
      hue: catMeta[cat].hue,
      featured: true,
      specs: (p.chips || []).map((c) => ({ k: '', v: c })),
      cfg: null,
      _detail: false,
    };
  });

  products.splice(0, products.length, ...mapped);
  _loaded = true;
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
  p._detail = true;
}
