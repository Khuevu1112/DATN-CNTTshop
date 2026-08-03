import { reactive, computed } from 'vue';
import router from './router/index.js';
import {
  accents,
  products,
  productById,
  defaultSel,
  priceWith,
  loadCatalog,
  loadDetail,
  loadBestsellers,
  resolveVariantId,
} from './data/products.js';
import {
  login as apiLogin,
  register as apiRegister,
  meWithToken,
  updateProfile as apiUpdateProfile,
  fetchCart,
  addCartItem,
  updateCartItem,
  removeCartItem,
  getNotifications,
  getUnreadNotificationCount,
  markNotificationRead as apiMarkNotificationRead,
  markAllNotificationsRead as apiMarkAllNotificationsRead,
} from './api.js';

// ===== Đọc query string cổng thanh toán (Stripe) / OAuth2 trả về trước khi dọn URL =====
const _initialParams = new URLSearchParams(window.location.search);
const _returnOrderId = _initialParams.get('orderId');
const _returnPayment = _initialParams.get('payment');
const _oauthToken = _initialParams.get('oauthToken');
const _oauthError = _initialParams.get('oauthError');
if (_returnOrderId || _returnPayment || _oauthToken || _oauthError) {
  window.history.replaceState({}, '', window.location.pathname);
}

// ===== Global reactive store (shared singleton) =====
export const state = reactive({
  selId: null,
  cfgSel: {},
  // Danh mục đang chọn trong widget "luôn hiện" ở trang chủ (thay cho dropdown hover) —
  // 'components' = Linh kiện máy tính, hoặc 1 trong 5 slug của CATEGORY_SEGMENTS.
  homeWidgetCat: 'components',
  cart: [], // CartItemDto[] thật từ backend
  cartSubtotal: 0,
  selectedCartItemIds: [], // id các dòng giỏ hàng được tick chọn để thanh toán (CartView → Checkout)
  brandFilter: [],
  segmentKeyword: '', // '' = không lọc phân khúc, khác rỗng = từ khoá matchesQuery (xem CATEGORY_SEGMENTS)
  // ===== Bộ lọc riêng cho PC & Máy tính bàn (thay bộ lọc Thương hiệu chung — PC nào cũng là
  // CNTTshop) — xem CategoryView.vue. =====
  pcCpuVendor: '', // '' | 'AMD' | 'Intel'
  pcCpuSeries: '', // '' | 'X3D'/'G'/'X'/'Standard' (AMD) hoặc 'F'/'K'/'KS'/'Standard' (Intel)
  pcCaseBrand: [],
  pcMainboardBrand: [],
  pcCoolerBrand: [],
  sort: 'pop',
  priceMin: 0,
  priceMax: 70000000,
  minRating: 0, // 0 = không lọc, 3/4/5 = từ N sao trở lên
  inStockOnly: false,
  onlyDeal: false, // true = chỉ hiện sản phẩm đang có ưu đãi/giảm giá (oldPrice > price)
  onlyBestseller: false, // true = chỉ sản phẩm bán chạy (soldCount > 0, dữ liệu đơn hàng thật)
  monSize: [], // lọc màn hình theo kích thước (giá trị spec "Kích thước")
  monReso: [], // lọc màn hình theo độ phân giải (giá trị spec "Độ phân giải")
  theme: localStorage.getItem('theme') || 'cyan',
  mode: localStorage.getItem('mode') || 'dark',
  q: '',
  toast: '',
  loading: false,
  loadingMsg: 'Đang tải...',
  // ===== Đăng nhập =====
  user: JSON.parse(localStorage.getItem('user') || 'null'),
  token: localStorage.getItem('token') || '',
  loginPrev: { name: 'home' },
  // ===== Kết quả thanh toán (Stripe redirect về) =====
  returnOrderId: _returnOrderId ? Number(_returnOrderId) : null,
  returnPaymentStatus: _returnPayment,
  // ===== Thông báo (đơn hàng, bảo hành...) — dùng chung cho nút chuông ở header và
  // danh sách trong Quản lý tài khoản để 2 nơi luôn khớp nhau =====
  notifications: [],
  unreadNotifCount: 0,
});

// CSS đọc màu theo [data-mode] trên <html> (xem style.css) — set ngay khi tải trang
// để tránh nháy sáng/tối trước khi Vue mount.
document.documentElement.setAttribute('data-mode', state.mode);

let _toastTimer = null;

// ===== Nạp catalog từ backend khi khởi động (route 'detail' cần await trước khi
// productById() có dữ liệu, xem router.beforeEach bên dưới) =====
state.loading = true;
state.loadingMsg = 'Đang tải dữ liệu...';
const catalogReady = loadCatalog()
  .then(() => loadBestsellers())
  .catch(() => {});
catalogReady.finally(() => {
  state.loading = false;
});

// ===== Điều hướng thật qua vue-router: overlay loading mô phỏng UX cũ, cộng thêm
// đồng bộ segmentKeyword/selId theo route để nút Back/Forward + link chia sẻ
// (deep link) hoạt động đúng, không chỉ riêng điều hướng bằng click trong app. Riêng danh mục
// (cat) CategoryView.vue đọc thẳng route.params.cat qua useRoute(), không mirror qua state nữa =====
const LOAD_MSG = {
  home: 'Đang về trang chủ...',
  category: 'Đang tải sản phẩm...',
  detail: 'Đang tải chi tiết...',
  cart: 'Đang mở giỏ hàng...',
  checkout: 'Đang mở trang thanh toán...',
  orders: 'Đang tải đơn hàng của bạn...',
  warranty: 'Đang tải bảo hành của bạn...',
  'order-review': 'Đang mở đánh giá đơn hàng...',
  contact: 'Đang tải trang liên hệ...',
  compare: 'Đang tải trang so sánh...',
  pcbuild: 'Đang tải trình xây dựng cấu hình...',
  account: 'Đang tải tài khoản của bạn...',
  promotions: 'Đang tải trang khuyến mãi...',
};

let _hideTimer = null;

router.beforeEach(async (to, from) => {
  // Điều hướng đầu tiên khi tải trang (F5/mở link trực tiếp) đã có overlay riêng
  // ("Đang tải dữ liệu...") ở trên — không chồng thêm overlay ở đây.
  const isFirstNav = from.matched.length === 0;
  // Đăng nhập mở/đóng tức thì như popup, không cần overlay loading.
  const skipOverlay = isFirstNav || to.name === 'login' || from.name === 'login';

  clearTimeout(_hideTimer);
  if (!skipOverlay) {
    state.loading = true;
    state.loadingMsg = LOAD_MSG[to.name] || 'Đang tải...';
  }

  if (to.name === 'category') {
    state.brandFilter = [];
    state.q = '';
    state.priceMin = 0;
    state.priceMax = 70000000;
    state.minRating = 0;
    state.inStockOnly = false;
    // Đọc từ query để link ngoài (VD nút "Xem thêm Ưu đãi" ở Flash Sale, hoặc các mục "Khám phá"
    // trên menu) mở thẳng trang danh mục đã bật sẵn bộ lọc. deal=1 -> chỉ hàng đang giảm;
    // sold=1 -> chỉ hàng bán chạy (sắp theo lượt bán); priceMax -> trần giá (VD laptop ≤20tr).
    state.onlyDeal = to.query.deal === '1';
    state.onlyBestseller = to.query.sold === '1';
    // Mặc định sắp theo lượt bán khi vào bằng bộ lọc bán chạy, trừ khi query chỉ định sort khác.
    state.sort = to.query.sort || (to.query.sold === '1' ? 'sold' : 'pop');
    state.segmentKeyword = to.query.seg || '';
    state.priceMax = to.query.priceMax ? Number(to.query.priceMax) : 70000000;
    state.monSize = [];
    state.monReso = [];
    state.pcCpuVendor = '';
    state.pcCpuSeries = '';
    state.pcCaseBrand = [];
    state.pcMainboardBrand = [];
    state.pcCoolerBrand = [];
  } else if (to.name === 'detail') {
    await catalogReady;
    const id = Number(to.params.id);
    const p = productById(id);
    if (!p) return { name: 'home' };
    if (!p._detail) await Promise.resolve(loadDetail(p)).catch(() => {});
    state.selId = id;
    state.cfgSel = defaultSel(p);
  }
  return true;
});

router.afterEach((to, from) => {
  clearTimeout(_hideTimer);
  if (from.matched.length === 0 || to.name === 'login' || from.name === 'login') return;
  _hideTimer = setTimeout(() => {
    state.loading = false;
  }, 380);
});

export const actions = {
  goHome: () => router.push({ name: 'home' }),
  goCart: () => router.push({ name: 'cart' }),
  goCheckout: () => {
    if (!state.cart.length) {
      actions.showToast('Giỏ hàng đang trống');
      return;
    }
    if (!state.selectedCartItemIds.length) {
      actions.showToast('Vui lòng chọn ít nhất 1 sản phẩm để thanh toán');
      return;
    }
    router.push({ name: 'checkout' });
  },
  goOrders: () => router.push({ name: 'orders' }),
  goOrderResult: () => router.push({ name: 'order-result' }),
  goCat: (cat, keyword) =>
    router.push({
      name: 'category',
      params: { cat: cat || 'all' },
      query: keyword ? { seg: keyword } : {},
    }),
  // Điều hướng danh mục kèm bộ lọc cho các mục "Khám phá" trên menu. opts: { seg, sold, priceMax,
  // sort }. Store watch route sẽ đọc các query này để bật sẵn đúng bộ lọc.
  goCatFilter: (cat, opts = {}) => {
    const query = {};
    if (opts.seg) query.seg = opts.seg;
    if (opts.sold) query.sold = '1';
    if (opts.priceMax) query.priceMax = String(opts.priceMax);
    if (opts.sort) query.sort = opts.sort;
    return router.push({ name: 'category', params: { cat: cat || 'all' }, query });
  },
  goCatAll: () => actions.goCat('all'),
  // Mở trang tất cả danh mục đã bật sẵn bộ lọc ưu đãi + sắp theo mức giảm nhiều nhất. Store
  // watch route sẽ đọc deal/sort từ query (xem trên) để đồng bộ state — nút "Xem thêm Ưu đãi"
  // ở Flash Sale banner dùng action này.
  goDeals: () => router.push({ name: 'category', params: { cat: 'all' }, query: { deal: '1', sort: 'disc' } }),
  goCatPC: () => actions.goCat('pc-may-tinh-ban'),
  goCatLap: () => actions.goCat('laptop'),
  goContact: () => router.push({ name: 'contact' }),
  goPromotions: () => router.push({ name: 'promotions' }),
  goWarranty: () => router.push({ name: 'warranty' }),
  goCompare: () => router.push({ name: 'compare' }),
  goPcBuild: () => router.push({ name: 'pcbuild' }),
  goAccount: () => router.push({ name: 'account' }),

  // ===== Trung tâm hỗ trợ =====
  // goWarranty ở trên là phiếu bảo hành CỦA TÔI (cần đăng nhập); goWarrantyInfo dưới đây là
  // trang chính sách + tra cứu theo serial, công khai. Hai thứ khác nhau, đừng gộp.
  goSupport: () => router.push({ name: 'support' }),
  goServiceCenters: () => router.push({ name: 'service-centers' }),
  goWarrantyInfo: () => router.push({ name: 'warranty-info' }),
  goRepairPrice: () => router.push({ name: 'repair-price' }),
  // Vào thẳng phần "Combo sửa chữa" trên trang bảng giá — dùng query để trang tự cuộn tới đúng
  // khối, thay vì bắt khách kéo tay xuống.
  goRepairPriceCombo: () => router.push({ name: 'repair-price', query: { combo: '1' } }),
  goFaq: () => router.push({ name: 'faq' }),
  // FAQ mở thẳng một danh mục (VD 'ky_thuat') hoặc với từ khoá tìm sẵn — dùng cho các mục
  // "Khám phá" kiểu "Tần số quét là gì?", "Kiểm tra tương thích linh kiện".
  goFaqCat: (ma) => router.push({ name: 'faq', query: ma ? { cat: ma } : {} }),
  goFaqSearch: (q) => router.push({ name: 'faq', query: q ? { q } : {} }),
  // Hai trang chính sách công khai nối từ menu Khám phá.
  goInstallmentPolicy: () => router.push({ name: 'installment-policy' }),
  goCommitment: () => router.push({ name: 'commitment' }),
  goReturnPolicy: () => router.push({ name: 'return-policy' }),
  // Tin tức / blog.
  goNews: (category) => router.push({ name: 'news', query: category ? { c: category } : {} }),
  goArticle: (slug) => router.push({ name: 'article', params: { slug } }),
  // Mở Trung tâm hỗ trợ và cuộn tới khối "Chat với kỹ thuật viên / tư vấn viên".
  goSupportChat: () => router.push({ name: 'support', query: { chat: '1' } }),
  goAppointments: () => router.push({ name: 'appointments' }),
  // "Gọi điện thoại" / "Gửi email" trên menu Hỗ trợ đưa thẳng tới đúng thẻ trên trang Liên hệ
  // (hotline / email) và làm nổi nó lên, thay vì chỉ mở trang rồi để khách tự tìm.
  goContactHotline: () => router.push({ name: 'contact', query: { focus: 'hotline' } }),
  goContactEmail: () => router.push({ name: 'contact', query: { focus: 'email' } }),

  // Điều hướng tới trang chi tiết — việc nạp dữ liệu thật (specs + cfg) đã chuyển vào
  // router.beforeEach ở trên, dùng chung cho cả click trong app lẫn Back/Forward/F5.
  goDetail: (id) => router.push({ name: 'detail', params: { id } }),

  // ===== Đăng nhập =====
  openLogin: () => {
    const cur = router.currentRoute.value;
    if (cur.name !== 'login') {
      state.loginPrev = { name: cur.name || 'home', params: { ...cur.params }, query: { ...cur.query } };
    }
    router.push({ name: 'login' });
  },
  closeLogin: () => {
    router.push(state.loginPrev || { name: 'home' });
  },
  register: async (payload) => {
    await apiRegister(payload);
  },
  login: async (username, password) => {
    const data = await apiLogin({ username, password });
    state.user = data.user || { email: username };
    state.token = data.token || '';
    localStorage.setItem('token', state.token);
    localStorage.setItem('user', JSON.stringify(state.user));
    router.push(state.loginPrev || { name: 'home' });
    actions.showToast('Đăng nhập thành công');
    actions.refreshCart();
    actions.refreshUnreadNotifCount();
  },
  updateProfile: async (payload) => {
    const updated = await apiUpdateProfile(payload);
    state.user = updated;
    localStorage.setItem('user', JSON.stringify(state.user));
    actions.showToast('Đã cập nhật thông tin cá nhân');
  },
  logout: () => {
    state.user = null;
    state.token = '';
    state.cart = [];
    state.cartSubtotal = 0;
    state.notifications = [];
    state.unreadNotifCount = 0;
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    actions.showToast('Đã đăng xuất');
  },

  setTheme: (t) => {
    state.theme = t;
    localStorage.setItem('theme', t);
  },
  toggleMode: () => {
    state.mode = state.mode === 'light' ? 'dark' : 'light';
    document.documentElement.setAttribute('data-mode', state.mode);
    localStorage.setItem('mode', state.mode);
  },
  setCfg: (groupKey, idx) => {
    state.cfgSel = { ...state.cfgSel, [groupKey]: idx };
  },

  showToast: (msg) => {
    state.toast = msg;
    clearTimeout(_toastTimer);
    _toastTimer = setTimeout(() => {
      state.toast = '';
    }, 1900);
  },

  // ===== Giỏ hàng thật (backend) =====
  refreshCart: async () => {
    if (!state.token) return;
    try {
      const c = await fetchCart();
      state.cart = c.items;
      state.cartSubtotal = c.subtotal;
      // Mặc định tick chọn sẵn mọi dòng mới xuất hiện trong giỏ, giữ nguyên lựa chọn cũ
      // (bỏ tick 1 dòng rồi refresh giỏ không tự tick lại dòng đó).
      const known = new Set(state.selectedCartItemIds);
      c.items.forEach((i) => {
        if (!known.has(i.id)) state.selectedCartItemIds.push(i.id);
      });
    } catch (e) {
      // chưa đăng nhập / lỗi mạng -> bỏ qua, không chặn UI
    }
  },
  toggleCartItemSelected: (id) => {
    const idx = state.selectedCartItemIds.indexOf(id);
    if (idx === -1) state.selectedCartItemIds.push(id);
    else state.selectedCartItemIds.splice(idx, 1);
  },
  setAllCartItemsSelected: (selected) => {
    state.selectedCartItemIds = selected ? state.cart.map((c) => c.id) : [];
  },

  // ===== Thông báo =====
  refreshUnreadNotifCount: async () => {
    if (!state.token) return;
    try {
      state.unreadNotifCount = await getUnreadNotificationCount();
    } catch (e) {
      // im lặng, không làm phiền người dùng nếu lỗi mạng tạm thời
    }
  },
  loadNotifications: async () => {
    if (!state.token) return;
    try {
      state.notifications = await getNotifications();
    } catch (e) {
      /* im lặng */
    }
  },
  markNotificationRead: async (n) => {
    if (n.isRead) return;
    try {
      await apiMarkNotificationRead(n.id);
      n.isRead = true;
      actions.refreshUnreadNotifCount();
    } catch (e) {
      /* im lặng */
    }
  },
  markAllNotificationsRead: async () => {
    try {
      await apiMarkAllNotificationsRead();
      state.notifications.forEach((n) => {
        n.isRead = true;
      });
      state.unreadNotifCount = 0;
    } catch (e) {
      /* im lặng */
    }
  },

  addToCart: async (id, sel) => {
    if (!state.token) {
      actions.showToast('Vui lòng đăng nhập để thêm vào giỏ');
      actions.openLogin();
      return;
    }
    const p = productById(id);
    if (!p) return;
    try {
      if (!p._detail) await loadDetail(p);
      const useSel = sel || defaultSel(p);
      const variantId = resolveVariantId(p, useSel);
      if (!variantId) {
        actions.showToast('Sản phẩm hiện không khả dụng');
        return;
      }
      await addCartItem(variantId, 1);
      await actions.refreshCart();
      actions.showToast('Đã thêm "' + p.name + '" vào giỏ');
    } catch (e) {
      actions.showToast(e?.message || 'Có lỗi khi thêm vào giỏ');
    }
  },
  inc: async (itemId) => {
    const item = state.cart.find((x) => x.id === itemId);
    if (!item) return;
    try {
      await updateCartItem(itemId, item.quantity + 1);
      await actions.refreshCart();
    } catch (e) {
      actions.showToast(e?.message || 'Có lỗi khi cập nhật giỏ hàng');
    }
  },
  dec: async (itemId) => {
    const item = state.cart.find((x) => x.id === itemId);
    if (!item) return;
    const qty = Math.max(1, item.quantity - 1);
    try {
      await updateCartItem(itemId, qty);
      await actions.refreshCart();
    } catch (e) {
      actions.showToast(e?.message || 'Có lỗi khi cập nhật giỏ hàng');
    }
  },
  removeLine: async (itemId) => {
    try {
      await removeCartItem(itemId);
      const idx = state.selectedCartItemIds.indexOf(itemId);
      if (idx !== -1) state.selectedCartItemIds.splice(idx, 1);
      await actions.refreshCart();
    } catch (e) {
      actions.showToast(e?.message || 'Có lỗi khi xóa sản phẩm');
    }
  },

  setQ: (v) => {
    state.q = v;
  },
  onSearchEnter: () => actions.goCat('all'),
  setSort: (v) => {
    state.sort = v;
  },
  setPriceMin: (v) => {
    state.priceMin = Number(v);
  },
  setPriceMax: (v) => {
    state.priceMax = Number(v);
  },
  setMinRating: (v) => {
    state.minRating = state.minRating === Number(v) ? 0 : Number(v);
  },
  toggleInStockOnly: () => {
    state.inStockOnly = !state.inStockOnly;
  },
  toggleOnlyDeal: () => {
    state.onlyDeal = !state.onlyDeal;
  },
  toggleOnlyBestseller: () => {
    state.onlyBestseller = !state.onlyBestseller;
  },
  toggleMonSize: (s) => {
    state.monSize = state.monSize.includes(s)
      ? state.monSize.filter((x) => x !== s)
      : state.monSize.concat(s);
  },
  toggleMonReso: (r) => {
    state.monReso = state.monReso.includes(r)
      ? state.monReso.filter((x) => x !== r)
      : state.monReso.concat(r);
  },
  toggleBrand: (b) => {
    state.brandFilter = state.brandFilter.includes(b)
      ? state.brandFilter.filter((x) => x !== b)
      : state.brandFilter.concat(b);
  },
  setSegment: (keyword) => {
    state.segmentKeyword = state.segmentKeyword === keyword ? '' : keyword;
  },
  setPcCpuVendor: (vendor) => {
    state.pcCpuVendor = state.pcCpuVendor === vendor ? '' : vendor;
    state.pcCpuSeries = ''; // đổi hãng thì bỏ luôn lựa chọn dòng chip cũ (khác hãng không còn hợp lệ)
  },
  setPcCpuSeries: (series) => {
    state.pcCpuSeries = state.pcCpuSeries === series ? '' : series;
  },
  togglePcCaseBrand: (b) => {
    state.pcCaseBrand = state.pcCaseBrand.includes(b)
      ? state.pcCaseBrand.filter((x) => x !== b)
      : state.pcCaseBrand.concat(b);
  },
  togglePcMainboardBrand: (b) => {
    state.pcMainboardBrand = state.pcMainboardBrand.includes(b)
      ? state.pcMainboardBrand.filter((x) => x !== b)
      : state.pcMainboardBrand.concat(b);
  },
  togglePcCoolerBrand: (b) => {
    state.pcCoolerBrand = state.pcCoolerBrand.includes(b)
      ? state.pcCoolerBrand.filter((x) => x !== b)
      : state.pcCoolerBrand.concat(b);
  },
  clearFilters: () => {
    state.brandFilter = [];
    state.segmentKeyword = '';
    state.priceMin = 0;
    state.priceMax = 70000000;
    state.minRating = 0;
    state.inStockOnly = false;
    state.onlyDeal = false;
    state.onlyBestseller = false;
    state.monSize = [];
    state.monReso = [];
    state.pcCpuVendor = '';
    state.pcCpuSeries = '';
    state.pcCaseBrand = [];
    state.pcMainboardBrand = [];
    state.pcCoolerBrand = [];
    state.sort = 'pop';
  },
};

// ===== Shared computeds =====
export const accent = computed(() => accents[state.mode]?.[state.theme] || accents.dark.cyan);
export const cartCount = computed(() =>
  state.cart.reduce((a, c) => a + c.quantity, 0),
);

// Vẫn giữ themeStyle cho vài chỗ cần màu tính bằng JS (gradient nền trang, computed
// trong <script>) — các giá trị khớp với biến CSS cùng tên trong style.css để nhất
// quán (ink=--text, inkSoft=--muted2, pageBg=--page nhưng bản dark có thêm gradient
// trang trí thay vì màu phẳng).
export const themeStyle = computed(() => ({
  pageBg:
    state.mode === 'light'
      ? '#f0f0f0'
      : 'radial-gradient(1200px 600px at 80% -10%, #1c1e22 0%, #101114 55%)',
  ink: state.mode === 'light' ? '#18181b' : '#f2f3f5',
  inkSoft: state.mode === 'light' ? '#3a3a3d' : '#aeb2ba',
}));

export { products, priceWith };

// ===== Xử lý kết quả đăng nhập Google/Facebook (redirect toàn trang từ backend) =====
if (_oauthToken) {
  meWithToken(_oauthToken)
    .then((user) => {
      state.token = _oauthToken;
      state.user = user;
      localStorage.setItem('token', _oauthToken);
      localStorage.setItem('user', JSON.stringify(user));
      actions.showToast('Đăng nhập thành công');
      actions.refreshCart();
      actions.refreshUnreadNotifCount();
    })
    .catch(() => actions.showToast('Đăng nhập mạng xã hội thất bại, vui lòng thử lại'));
} else if (_oauthError) {
  actions.showToast(_oauthError);
}

// ===== Cổng thanh toán redirect về kèm ?orderId=...&payment=... -> nhảy thẳng tới trang kết quả =====
if (_returnOrderId || _returnPayment) {
  router.replace({ name: 'order-result' });
}

actions.refreshCart();
actions.refreshUnreadNotifCount();
setInterval(() => actions.refreshUnreadNotifCount(), 30000);

// ===== Token hết hạn/không hợp lệ (báo từ api.js, xem baoTokenHetHan) -> tự đăng xuất + mời
// đăng nhập lại, tránh mỗi trang tự treo/lỗi im lặng theo cách khác nhau khi gặp 401. Nhiều
// request cùng lúc có thể cùng bắn sự kiện này — logout() gọi lặp lại vô hại nên không cần
// chặn trùng. =====
window.addEventListener('auth:expired', () => {
  if (!state.token) return; // đã đăng xuất rồi (hoặc chưa từng đăng nhập) -> bỏ qua
  actions.logout();
  actions.showToast('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
  actions.openLogin();
});
