// ===== Lớp gọi REST API backend (Spring Boot :8080) =====
const BASE = 'http://localhost:8080/api';
export const API_ORIGIN = BASE.replace(/\/api$/, '');

/** Ảnh sản phẩm có thể là URL tương đối (do admin tải file lên, vd "/uploads/products/...")
 * hoặc URL tuyệt đối (admin dán thẳng link ngoài, vd placehold.co/Unsplash) — chỉ ghép
 * API_ORIGIN vào trường hợp đầu, giữ nguyên trường hợp sau. */
export function resolveImageUrl(url) {
  if (!url) return '';
  return /^(https?:)?\/\//i.test(url) ? url : API_ORIGIN + url;
}

function authHeaders() {
  const t = localStorage.getItem('token');
  return t ? { Authorization: 'Bearer ' + t } : {};
}

// Token hết hạn/không hợp lệ (VD phiên đăng nhập trên trình duyệt đã quá 24h) -> báo cho
// store.js (không import trực tiếp được vì store.js đã import ngược lại từ file này) để tự
// đăng xuất + mời đăng nhập lại, thay vì để mỗi trang tự treo/lỗi im lặng theo cách khác nhau.
function baoTokenHetHan(status) {
  if (status === 401) {
    window.dispatchEvent(new CustomEvent('auth:expired'));
  }
}

async function get(path) {
  const res = await fetch(BASE + path, { headers: { ...authHeaders() } });
  if (!res.ok) {
    baoTokenHetHan(res.status);
    throw new Error('HTTP ' + res.status);
  }
  return res.json();
}

// Tỉnh/Thành + Phường/Xã hiện hành (sau sáp nhập 1/7/2025) — dropdown địa chỉ, công khai.
export const fetchProvinces = () => get('/provinces');
export const fetchWards = (provinceId) => get('/provinces/' + provinceId + '/wards');

export const fetchCategories = () => get('/categories');

export const fetchProducts = (params = {}) => {
  const q = new URLSearchParams();
  if (params.categorySlug) q.set('categorySlug', params.categorySlug);
  if (params.keyword) q.set('keyword', params.keyword);
  if (params.sort) q.set('sort', params.sort);
  const qs = q.toString();
  return get('/products' + (qs ? '?' + qs : ''));
};

export const fetchProductBySlug = (slug) =>
  get('/products/' + encodeURIComponent(slug));

export const fetchBestsellers = (limit = 8) =>
  get('/products/bestsellers?limit=' + limit);

async function request(method, path, body) {
  const res = await fetch(BASE + path, {
    method,
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });
  if (!res.ok) {
    baoTokenHetHan(res.status);
    let msg = 'HTTP ' + res.status;
    try {
      const j = await res.json();
      if (j && j.message) msg = j.message;
    } catch (e) {}
    throw new Error(msg);
  }
  return res.json().catch(() => ({}));
}

const post = (path, body) => request('POST', path, body);
const put = (path, body) => request('PUT', path, body);
const del = (path) => request('DELETE', path);

// Auth (JWT)
export const login = (payload) => post('/auth/login', payload);
export const register = (payload) => post('/auth/register', payload);
export const me = () => get('/auth/me');
export const updateProfile = (payload) => put('/auth/me', payload);
export const changePassword = (payload) => put('/auth/me/password', payload);

async function meWithToken(token) {
  const res = await fetch(BASE + '/auth/me', { headers: { Authorization: 'Bearer ' + token } });
  if (!res.ok) throw new Error('HTTP ' + res.status);
  return res.json();
}
export { meWithToken };

// Liên hệ
export const submitContact = (payload) => post('/contact', payload);

// Cấu hình trả góp (kỳ hạn + lãi suất + tỷ lệ trả trước tối thiểu) — công khai, cho trang
// "Chính sách trả góp".
export const fetchInstallmentConfig = () => get('/installment/config');

// Tin tức (blog) — công khai.
export const fetchArticleCategories = () => get('/article-categories');
export const fetchArticles = (category) =>
  get('/articles' + (category ? '?category=' + encodeURIComponent(category) : ''));
export const fetchArticle = (slug) => get('/articles/' + encodeURIComponent(slug));

// Đổi trả hàng (yêu cầu đăng nhập). Gửi yêu cầu dùng multipart vì kèm video minh chứng lỗi +
// video tự mở hàng + tối đa 3 ảnh lỗi.
export const fetchMyReturns = () => get('/returns');
export async function submitReturnRequest(form, files) {
  const fd = new FormData();
  Object.entries(form).forEach(([k, v]) => {
    if (v !== null && v !== undefined && v !== '') fd.append(k, v);
  });
  if (files?.videoLoi) fd.append('videoLoi', files.videoLoi);
  if (files?.videoMoHang) fd.append('videoMoHang', files.videoMoHang);
  (files?.anh || []).forEach((a) => a && fd.append('anh', a));
  const res = await fetch(BASE + '/returns', { method: 'POST', headers: { ...authHeaders() }, body: fd });
  if (!res.ok) {
    baoTokenHetHan(res.status);
    let msg = 'HTTP ' + res.status;
    try { msg = (await res.json()).message || msg; } catch (e) { /* body rỗng */ }
    throw new Error(msg);
  }
  return res.json();
}

// ===== Trung tâm hỗ trợ =====
// Gần như toàn bộ là CÔNG KHAI: khách phải tra được trung tâm bảo hành, giá sửa chữa và FAQ
// trước cả khi có tài khoản. Chỉ "lịch hẹn của tôi" và "huỷ lịch" cần đăng nhập.
export const fetchSupportOverview = () => get('/support/tong-quan');

/** lat/lng = vị trí khách (nếu cho phép định vị) -> backend sắp xếp theo khoảng cách đường chim
 * bay. banKinhKm chỉ có tác dụng khi đã có lat/lng. */
export const fetchServiceCenters = (params = {}) => {
  const q = new URLSearchParams();
  if (params.provinceId) q.set('provinceId', params.provinceId);
  if (params.dichVu) q.set('dichVu', params.dichVu);
  if (params.q) q.set('q', params.q);
  if (params.lat != null && params.lng != null) {
    q.set('lat', params.lat);
    q.set('lng', params.lng);
    if (params.banKinhKm) q.set('banKinhKm', params.banKinhKm);
  }
  const qs = q.toString();
  return get('/support/trung-tam' + (qs ? '?' + qs : ''));
};

export const fetchWarrantyPolicies = () => get('/support/chinh-sach-bao-hanh');
export const lookupWarrantyBySerial = (serial) =>
  get('/support/tra-cuu-bao-hanh?serial=' + encodeURIComponent(serial));

export const fetchRepairPrices = (loaiThietBi) =>
  get('/support/bang-gia' + (loaiThietBi ? '?loaiThietBi=' + encodeURIComponent(loaiThietBi) : ''));
export const estimateRepairCost = (hangMucIds) => post('/support/uoc-tinh-sua-chua', { hangMucIds });

export const fetchFaq = (q) => get('/support/faq' + (q ? '?q=' + encodeURIComponent(q) : ''));
export const markFaqViewed = (id) => post('/support/faq/' + id + '/xem', {});

// Đặt lịch dịch vụ. Đặt được cả khi chưa đăng nhập (khách mang máy mua nơi khác tới sửa) —
// có token thì backend tự gắn lịch vào tài khoản.
export const fetchServiceSlots = (centerId, ngay) =>
  get('/support/khung-gio?centerId=' + centerId + '&ngay=' + ngay);
export const bookServiceAppointment = (payload) => post('/support/dat-lich', payload);
export const lookupAppointment = (maLich) =>
  get('/support/lich-hen/tra-cuu?maLich=' + encodeURIComponent(maLich));
export const fetchMyAppointments = () => get('/support/lich-hen/cua-toi');
export const cancelAppointment = (id) => post('/support/lich-hen/' + id + '/huy', {});

// Quên mật khẩu (OTP qua email)
export const forgotPasswordSendOtp = (email) => post('/auth/forgot-password/send-otp', { email });
export const forgotPasswordVerifyOtp = (email, otp) => post('/auth/forgot-password/verify-otp', { email, otp });
export const forgotPasswordReset = (email, otp, matKhauMoi, nhapLaiMatKhau) =>
  post('/auth/forgot-password/reset', { email, otp, matKhauMoi, nhapLaiMatKhau });

// Thông báo (yêu cầu đăng nhập)
export const getNotifications = () => get('/notifications');
export const getUnreadNotificationCount = () => get('/notifications/unread-count').then((r) => r.count);
export const markNotificationRead = (id) => post('/notifications/' + id + '/read');
export const markAllNotificationsRead = () => post('/notifications/read-all');

// Bảo hành (yêu cầu đăng nhập)
export const fetchMyWarranties = () => get('/warranty');
export const fetchWarrantyDetail = (id) => get('/warranty/' + id);
// Gửi yêu cầu bảo hành kèm lịch hẹn. hinhThuc: 'tan_noi' | 'cua_hang'; centerId chỉ dùng khi
// mang tới cửa hàng. Giữ tương thích lời gọi cũ (chỉ có issue) qua tham số payload gộp.
export const submitWarrantyRequest = (id, payload) =>
  post('/warranty/' + id + '/requests',
    typeof payload === 'string' ? { issue: payload } : payload);

// Đánh giá sản phẩm + giao hàng
export const fetchProductReviews = (slug) => get('/products/' + slug + '/reviews');
export const fetchReviewableItems = () => get('/reviews/reviewable');
export const fetchPurchasedItems = () => get('/purchases');
export const submitDeliveryReview = (orderId, rating, comment) =>
  post('/reviews/delivery', { orderId, rating, comment });
export async function submitProductReview(orderId, productId, rating, comment, photo1, photo2) {
  const form = new FormData();
  form.append('orderId', orderId);
  form.append('productId', productId);
  form.append('rating', rating);
  if (comment) form.append('comment', comment);
  if (photo1) form.append('photo1', photo1);
  if (photo2) form.append('photo2', photo2);
  const res = await fetch(BASE + '/reviews/product', {
    method: 'POST',
    headers: { ...authHeaders() },
    body: form,
  });
  if (!res.ok) {
    baoTokenHetHan(res.status);
    let msg = 'HTTP ' + res.status;
    try {
      const j = await res.json();
      if (j && j.message) msg = j.message;
    } catch (e) {}
    throw new Error(msg);
  }
}


// Xây dựng cấu hình PC (yêu cầu đăng nhập)
export const fetchComponentTypes = () => get('/pc-build/component-types');
export const fetchPcBuildProducts = (loai, keyword, page) =>
  get('/pc-build/products?loai=' + encodeURIComponent(loai) + '&page=' + (page || 0) + (keyword ? '&keyword=' + encodeURIComponent(keyword) : ''));
export const fetchMyPcBuilds = () => get('/pc-build');
export const createPcBuildDraft = () => post('/pc-build', {});
export const fetchPcBuildDetail = (id) => get('/pc-build/' + id);
export const addPcBuildItem = (id, variantId, componentType) => post('/pc-build/' + id + '/items', { variantId, componentType });
export const removePcBuildItem = (id, loai) => del('/pc-build/' + id + '/items/' + loai);
export const savePcBuild = (id, name, note) => put('/pc-build/' + id, { name, note });
export const deletePcBuild = (id) => del('/pc-build/' + id);
export const addPcBuildToCart = (id) => post('/pc-build/' + id + '/add-to-cart', {});

// Giỏ hàng thật (yêu cầu đăng nhập)
export const fetchCart = () => get('/cart');
export const addCartItem = (variantId, quantity) => post('/cart/items', { variantId, quantity });
export const updateCartItem = (itemId, quantity) => put('/cart/items/' + itemId, { quantity });
export const removeCartItem = (itemId) => del('/cart/items/' + itemId);

// Sổ địa chỉ (yêu cầu đăng nhập)
export const fetchAddresses = () => get('/addresses');
export const createAddress = (payload) => post('/addresses', payload);
export const updateAddress = (id, payload) => put('/addresses/' + id, payload);
export const deleteAddress = (id) => del('/addresses/' + id);
export const setDefaultAddress = (id) => put('/addresses/' + id + '/default', {});

// Tra ngược toạ độ -> địa chỉ chữ + Tỉnh/Phường, cho chế độ "chỉ cắm mốc" ở form địa chỉ — công khai.
export const reverseGeocode = (lat, lng) => get('/geocoding/reverse?lat=' + lat + '&lng=' + lng);

// Tuỳ chọn + phí giao hàng theo Phường (hoả tốc/thường trong Hải Phòng, hoặc đơn vị vận chuyển
// ngoài Hải Phòng) — công khai. lat/lng = điểm đã cắm của địa chỉ: có thì phí nội thành Hải
// Phòng tính theo quãng đường thật từ kho, không có thì backend dùng bảng phí phẳng cũ.
export const fetchShippingOptions = (wardId, lat, lng) => {
  const q = ['wardId=' + wardId];
  if (lat != null && lng != null) q.push('lat=' + lat, 'lng=' + lng);
  return get('/shipping/options?' + q.join('&'));
};

// Thanh toán + đặt hàng (yêu cầu đăng nhập)
export const fetchPaymentMethods = () => get('/payment-methods');
export const placeOrder = (addressId, paymentMethodCode, cartItemIds, couponCode, xuSuDung, shippingOptionCode, tradeInCreditId) =>
  post('/orders', { addressId, paymentMethodCode, cartItemIds, couponCode, xuSuDung, shippingOptionCode, tradeInCreditId });
export const applyCoupon = (code, subtotal) => post('/coupons/apply', { code, subtotal });
export const fetchMyOrders = () => get('/orders');
export const fetchOrderDetail = (id) => get('/orders/' + id);
export const cancelOrder = (id, reason) => post('/orders/' + id + '/cancel', { reason: reason || '' });

// Xu CT (yêu cầu đăng nhập)
export const fetchWallet = () => get('/wallet');
export const fetchWalletTransactions = () => get('/wallet/transactions');

// Thu cũ đổi mới. Gửi yêu cầu dùng multipart vì có ảnh hiện trạng máy (tối đa 4 ảnh).
export async function guiYeuCauThuCu(form, files) {
  const fd = new FormData();
  Object.entries(form).forEach(([k, v]) => {
    if (v !== null && v !== undefined && v !== '') fd.append(k, v);
  });
  (files || []).forEach((f) => f && fd.append('anh', f));
  const res = await fetch(BASE + '/trade-in', { method: 'POST', headers: { ...authHeaders() }, body: fd });
  if (!res.ok) {
    baoTokenHetHan(res.status);
    let msg = 'HTTP ' + res.status;
    try { msg = (await res.json()).message || msg; } catch (e) { /* body rỗng */ }
    throw new Error(msg);
  }
  return res.json();
}
export const fetchYeuCauThuCu = () => get('/trade-in');
export const phanHoiBaoGiaThuCu = (id, dongY) => post('/trade-in/' + id + '/phan-hoi?dongY=' + dongY, {});
export const fetchTinDungThuCu = () => get('/trade-in/credits');

// Chương trình thành viên — bậc + tiến độ thăng cấp tính từ tổng xu đã tích luỹ (yêu cầu đăng nhập)
export const fetchMembership = () => get('/membership');

// Gói hội viên trả phí "CNTT Care" — TÁCH RỜI hạng thành viên ở trên. Bảng gói công khai; trạng
// thái/mua gói cần đăng nhập. buySubscription trả { redirectUrl } để chuyển hướng cổng VNPay.
export const fetchSubscriptionPlans = () => get('/subscription/plans');
export const fetchMySubscription = () => get('/subscription/me');
export const buySubscription = (planCode, paymentMethodCode) =>
  post('/subscription/buy', { planCode, paymentMethodCode });

// Flash sale. fetchFlashSale() công khai, trả null khi không có đợt nào đang chạy. Nhóm /admin
// đi qua quyền "coupons" (Quản lý khuyến mãi) — lưu là lưu BẢN NHÁP, phải publish mới ra với khách.
export const fetchFlashSale = () => get('/flash-sale');
export const fetchFlashSaleAdmin = () => get('/flash-sale/admin');
export const createFlashSale = (payload) => post('/flash-sale/admin', payload);
export const updateFlashSale = (id, payload) => put('/flash-sale/admin/' + id, payload);
export const publishFlashSale = (id) => post('/flash-sale/admin/' + id + '/publish', {});
export const unpublishFlashSale = (id) => post('/flash-sale/admin/' + id + '/unpublish', {});
export const searchProductsForSale = (q) => get('/flash-sale/admin/products?q=' + encodeURIComponent(q));

// Trang khuyến mãi: đổi thưởng + điểm danh (yêu cầu đăng nhập)
export const fetchRedemptionCatalog = () => get('/redemption/catalog');
export const redeemCoupon = (redemptionItemId) => post('/redemption/redeem-coupon', { redemptionItemId });
export const redeemGift = (redemptionItemId, addressId) => post('/redemption/redeem-gift', { redemptionItemId, addressId });
export const fetchMyCoupons = () => get('/redemption/my-coupons');
export const fetchCheckinStatus = () => get('/checkin');
export const doCheckin = () => post('/checkin', {});

export async function uploadPaymentProof(paymentId, file) {
  const form = new FormData();
  form.append('image', file);
  const res = await fetch(BASE + '/payments/' + paymentId + '/upload-proof', {
    method: 'POST',
    headers: { ...authHeaders() },
    body: form,
  });
  if (!res.ok) {
    baoTokenHetHan(res.status);
    let msg = 'HTTP ' + res.status;
    try {
      const j = await res.json();
      if (j && j.message) msg = j.message;
    } catch (e) {}
    throw new Error(msg);
  }
  return res.json();
}
