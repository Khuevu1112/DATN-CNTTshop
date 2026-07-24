<script setup>
import { ref, reactive, onMounted, computed, watch } from 'vue';
import { useRoute } from 'vue-router';
import { state, actions, accent } from '../store.js';
import { fmt } from '../data/products.js';
import {
  fetchAddresses, createAddress, updateAddress, deleteAddress, setDefaultAddress,
  forgotPasswordSendOtp, forgotPasswordVerifyOtp, forgotPasswordReset,
  fetchMyOrders, fetchOrderDetail,
  fetchWarrantyDetail, submitWarrantyRequest,
  fetchWallet, fetchWalletTransactions, fetchMembership,
  fetchMyCoupons, fetchProvinces, fetchWards, reverseGeocode,
  fetchPurchasedItems, submitProductReview,
} from '../api.js';
import MapPicker from '../components/MapPicker.vue';
import MembershipProgress from '../components/MembershipProgress.vue';
import TradeInPanel from '../components/TradeInPanel.vue';
import SubscriptionPanel from '../components/SubscriptionPanel.vue';
import OrderDetailCard from '../components/OrderDetailCard.vue';
import MyCouponTickets from '../components/MyCouponTickets.vue';
import ReviewWizardModal from '../components/ReviewWizardModal.vue';
import StarRatingInput from '../components/StarRatingInput.vue';

const route = useRoute();
const activeTab = ref(
  route.name === 'orders' || route.name === 'order-review' ? 'orders'
    : route.name === 'warranty' ? 'warranty' : 'profile',
);

// Wizard đánh giá (xác nhận nhận hàng -> đánh giá giao hàng -> đánh giá sản phẩm) — mở khi vào
// route /tai-khoan/don-hang/:id/danh-gia (bấm thông báo "đã giao hàng") hoặc từ tab Sản phẩm đã mua.
// Bump để remount SubscriptionPanel (nạp lại trạng thái gói) sau khi VNPay redirect về báo
// mua gói thành công.
const subPanelKey = ref(0);

const reviewWizardOrderId = ref(null);
function openReviewWizard(id) {
  reviewWizardOrderId.value = id;
}
function closeReviewWizard() {
  reviewWizardOrderId.value = null;
  if (route.name === 'order-review') actions.goOrders();
}
function checkRouteOpensReviewWizard() {
  if (route.name === 'order-review' && route.params.id) {
    openReviewWizard(Number(route.params.id));
  }
}

function fmtDate(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  return `${String(d.getDate()).padStart(2, '0')}/${String(d.getMonth() + 1).padStart(2, '0')}/${d.getFullYear()}`;
}
function fmtDateTime(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  return `${fmtDate(iso)} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
}

function doLogout() {
  actions.logout();
  actions.goHome();
}

function timeAgo(iso) {
  const diffMs = Date.now() - new Date(iso).getTime();
  const min = Math.floor(diffMs / 60000);
  if (min < 1) return 'vừa xong';
  if (min < 60) return min + ' phút trước';
  const hour = Math.floor(min / 60);
  if (hour < 24) return hour + ' giờ trước';
  return Math.floor(hour / 24) + ' ngày trước';
}

// ===== Tab "Cá nhân": hồ sơ + địa chỉ + đổi mật khẩu =====
const loading = ref(true);
const addresses = ref([]);
const showAddressForm = ref(false);
const editingAddressId = ref(null); // null = đang thêm mới, có giá trị = đang sửa địa chỉ đó
const editingIsDefault = ref(false);
const savingProfile = ref(false);
const savingAddress = ref(false);

const profile = reactive({ hoTen: '', soDienThoai: '' });
const addressForm = reactive({
  tenNguoiNhan: '', soDienThoai: '', diaChiCuThe: '', provinceId: null, wardId: null,
});
const provinces = ref([]);
const wardsForForm = ref([]);
const loadingWards = ref(false);

async function ensureProvincesLoaded() {
  if (provinces.value.length) return;
  try {
    provinces.value = await fetchProvinces();
  } catch (e) {
    provinces.value = [];
  }
}

async function loadWardsForForm(provinceId) {
  addressForm.wardId = null;
  wardsForForm.value = [];
  if (!provinceId) return;
  loadingWards.value = true;
  try {
    wardsForForm.value = await fetchWards(provinceId);
  } catch (e) {
    wardsForForm.value = [];
  } finally {
    loadingWards.value = false;
  }
}

async function onFormProvinceChange() {
  await loadWardsForForm(addressForm.provinceId);
}

// ===== Cắm mốc bản đồ — BẮT BUỘC với mọi địa chỉ lưu qua đây. Hai chế độ:
//   'nhap'    = gõ địa chỉ rồi cắm mốc xác nhận đúng chỗ
//   'mocDiem' = chỉ thả ghim, tự tra ngược ra đường + Tỉnh/Phường (khách vẫn sửa lại được)
const cheDoNhap = ref('nhap');
const toaDo = ref(null); // { lat, lng }
const dangTraNguoc = ref(false);
const goiYDiaChi = ref('');

async function onPinMoved({ lat, lng }) {
  dangTraNguoc.value = true;
  goiYDiaChi.value = '';
  try {
    const kq = await reverseGeocode(lat, lng);
    goiYDiaChi.value = kq.diaChiDayDu || '';
    if (cheDoNhap.value !== 'mocDiem') return;

    // CHỈ điền phần địa chỉ cấp đường. Tỉnh/Phường cố ý KHÔNG tự điền: dữ liệu OpenStreetMap
    // phần lớn còn mang tên hành chính TRƯỚC sáp nhập 1/7/2025, khớp bừa sang bảng chuẩn hoá
    // của dự án sẽ chọn sai phường mà khách không biết, kéo theo sai phí ship và sai địa chỉ.
    // Backend đã đảm bảo có mô tả vị trí kể cả khi thiếu số nhà (xem GeocodingService), nên
    // điền dứt khoát — khách chọn 'chỉ cắm mốc' không phải gõ tay ô này nữa.
    if (kq.diaChiCuThe) addressForm.diaChiCuThe = kq.diaChiCuThe;
    else if (kq.diaChiDayDu) addressForm.diaChiCuThe = kq.diaChiDayDu;
  } catch (e) {
    // Tra ngược chỉ là tiện ích — hỏng thì khách tự chọn Tỉnh/Phường, không chặn luồng.
  } finally {
    dangTraNguoc.value = false;
  }
}

function resetProfileForm() {
  profile.hoTen = state.user?.fullName || '';
  profile.soDienThoai = state.user?.phone || '';
}

async function loadProfile() {
  loading.value = true;
  resetProfileForm();
  try {
    addresses.value = await fetchAddresses();
  } catch (e) {
    addresses.value = [];
  } finally {
    loading.value = false;
  }
}

async function saveProfile() {
  if (!profile.hoTen.trim()) {
    actions.showToast('Vui lòng nhập họ tên');
    return;
  }
  savingProfile.value = true;
  try {
    await actions.updateProfile({ hoTen: profile.hoTen.trim(), soDienThoai: profile.soDienThoai.trim() });
  } catch (e) {
    actions.showToast('Cập nhật thất bại, vui lòng thử lại');
  } finally {
    savingProfile.value = false;
  }
}

async function openAddressForm(address = null) {
  editingAddressId.value = address ? address.id : null;
  editingIsDefault.value = address ? !!address.isDefault : false;
  addressForm.tenNguoiNhan = address?.tenNguoiNhan || state.user?.fullName || '';
  addressForm.soDienThoai = address?.soDienThoai || state.user?.phone || '';
  addressForm.diaChiCuThe = address?.diaChiCuThe || '';
  addressForm.provinceId = address?.provinceId || null;
  addressForm.wardId = null;
  wardsForForm.value = [];
  // Địa chỉ cũ chưa từng cắm mốc -> toaDo null, khách buộc phải cắm trước khi lưu lại được.
  toaDo.value = address?.latitude != null && address?.longitude != null
    ? { lat: Number(address.latitude), lng: Number(address.longitude) }
    : null;
  cheDoNhap.value = 'nhap';
  goiYDiaChi.value = '';
  showAddressForm.value = true;
  await ensureProvincesLoaded();
  if (address?.provinceId) {
    await loadWardsForForm(address.provinceId);
    addressForm.wardId = address.wardId || null;
  }
}
function closeAddressForm() {
  showAddressForm.value = false;
  editingAddressId.value = null;
}

async function saveAddress() {
  if (!addressForm.tenNguoiNhan.trim()) { actions.showToast('Vui lòng nhập tên người nhận'); return; }
  if (!addressForm.soDienThoai.trim()) { actions.showToast('Vui lòng nhập số điện thoại'); return; }
  if (!addressForm.provinceId || !addressForm.wardId) {
    actions.showToast('Vui lòng chọn Tỉnh/Thành và Phường/Xã');
    return;
  }
  if (!addressForm.diaChiCuThe.trim()) {
    actions.showToast('Vui lòng nhập số nhà/đường (hoặc cắm mốc để tự điền từ bản đồ)');
    return;
  }
  if (!toaDo.value) {
    actions.showToast('Vui lòng cắm mốc vị trí giao hàng trên bản đồ');
    return;
  }
  savingAddress.value = true;
  try {
    const payload = {
      ...addressForm,
      isDefault: editingAddressId.value ? editingIsDefault.value : !addresses.value.length,
      latitude: toaDo.value.lat,
      longitude: toaDo.value.lng,
    };
    if (editingAddressId.value) {
      await updateAddress(editingAddressId.value, payload);
    } else {
      await createAddress(payload);
    }
    addresses.value = await fetchAddresses();
    closeAddressForm();
    actions.showToast('Đã lưu địa chỉ');
  } catch (e) {
    actions.showToast('Lưu địa chỉ thất bại, vui lòng thử lại');
  } finally {
    savingAddress.value = false;
  }
}

async function removeAddress(id) {
  if (!window.confirm('Xoá địa chỉ này?')) return;
  try {
    await deleteAddress(id);
    addresses.value = await fetchAddresses();
    actions.showToast('Đã xoá địa chỉ');
  } catch (e) {
    actions.showToast(e?.message && !e.message.startsWith('HTTP') ? e.message : 'Xoá địa chỉ thất bại');
  }
}

async function makeDefaultAddress(id) {
  try {
    await setDefaultAddress(id);
    addresses.value = await fetchAddresses();
  } catch (e) {
    actions.showToast('Cập nhật thất bại, vui lòng thử lại');
  }
}

// ===== Xu CT: số dư + sổ giao dịch (kiếm được khi mua hàng, dùng ở trang khuyến mãi hoặc
// giảm trực tiếp vào bill lúc thanh toán) =====
const xuBalance = ref(0);
const walletTransactions = ref([]);
const walletLoading = ref(true);
const WALLET_TX_TYPE_LABEL = {
  earn: 'Tích lũy', redeem: 'Đổi thưởng', spend: 'Dùng giảm giá', adjust: 'Điều chỉnh',
};

// Hạng thành viên (Đồng/Bạc/Vàng/Kim cương) — xét theo TỔNG xu đã tích luỹ, không phải số dư
// hiện có, nên khác với xuBalance ở trên. Tải chung 1 lượt với ví vì cùng nằm ở cột phải.
const membership = ref(null);

async function loadWallet() {
  walletLoading.value = true;
  try {
    const [w, tx, ms] = await Promise.all([fetchWallet(), fetchWalletTransactions(), fetchMembership()]);
    xuBalance.value = w.balance;
    walletTransactions.value = tx;
    membership.value = ms;
  } catch (e) {
    // im lặng — không chặn phần còn lại của trang cá nhân
  } finally {
    walletLoading.value = false;
  }
}

// ===== "Mã giảm giá của tôi" — coupon đã đổi bằng Xu CT ở trang khuyến mãi, hiển thị dạng vé
// xé ngay dưới danh sách địa chỉ (component dùng chung với CheckoutView, xem
// components/MyCouponTickets.vue — tự quản lý trạng thái "đã xé"/modal xác nhận). =====
const myCoupons = ref([]);
const myCouponsLoading = ref(true);

async function loadMyCoupons() {
  myCouponsLoading.value = true;
  try {
    myCoupons.value = await fetchMyCoupons();
  } catch (e) {
    myCoupons.value = [];
  } finally {
    myCouponsLoading.value = false;
  }
}

// ===== Đổi mật khẩu — ẩn mặc định, chỉ đổi được sau khi xác minh mã gửi tới email
// (dùng chung API "quên mật khẩu" — không cần nhập mật khẩu hiện tại). Chỉ áp dụng cho
// tài khoản tự tạo, tài khoản Google/Facebook không có mật khẩu nội bộ để đổi. =====
const pw = reactive({ step: null, otp: '', pw: '', pw2: '', error: '', loading: false });

async function pwOpen() {
  pw.error = '';
  pw.loading = true;
  try {
    await forgotPasswordSendOtp(state.user.email);
    pw.step = 'otp';
    actions.showToast('Đã gửi mã xác nhận tới email của bạn');
  } catch (e) {
    actions.showToast(e?.message && !e.message.startsWith('HTTP') ? e.message : 'Gửi mã thất bại');
  } finally {
    pw.loading = false;
  }
}
async function pwResend() {
  pw.error = '';
  pw.loading = true;
  try {
    await forgotPasswordSendOtp(state.user.email);
    actions.showToast('Đã gửi lại mã xác nhận');
  } catch (e) {
    pw.error = e?.message && !e.message.startsWith('HTTP') ? e.message : 'Gửi mã thất bại';
  } finally {
    pw.loading = false;
  }
}
async function pwVerify() {
  pw.error = '';
  if (!pw.otp.trim()) {
    pw.error = 'Vui lòng nhập mã OTP';
    return;
  }
  pw.loading = true;
  try {
    await forgotPasswordVerifyOtp(state.user.email, pw.otp.trim());
    pw.step = 'reset';
  } catch (e) {
    pw.error = e?.message && !e.message.startsWith('HTTP') ? e.message : 'Mã xác nhận không hợp lệ';
  } finally {
    pw.loading = false;
  }
}
async function pwReset() {
  pw.error = '';
  if (!pw.pw || pw.pw.length < 6) {
    pw.error = 'Mật khẩu phải có ít nhất 6 ký tự';
    return;
  }
  if (pw.pw !== pw.pw2) {
    pw.error = 'Mật khẩu nhập lại không khớp';
    return;
  }
  pw.loading = true;
  try {
    await forgotPasswordReset(state.user.email, pw.otp.trim(), pw.pw, pw.pw2);
    actions.showToast('Đã đổi mật khẩu thành công');
    pwCancel();
  } catch (e) {
    pw.error = e?.message && !e.message.startsWith('HTTP') ? e.message : 'Đổi mật khẩu thất bại';
  } finally {
    pw.loading = false;
  }
}
function pwCancel() {
  pw.step = null;
  pw.otp = '';
  pw.pw = '';
  pw.pw2 = '';
  pw.error = '';
}

// ===== Tab "Đơn hàng của tôi" =====
const ordersLoading = ref(true);
const orders = ref([]);
const orderDetail = ref(null);
const ORDER_STATUS_LABEL = {
  pending: 'Chờ xác nhận', confirmed: 'Đã xác nhận', processing: 'Đang xử lý',
  shipped: 'Đang giao', delivered: 'Đã giao', cancelled: 'Đã hủy', refunded: 'Đã hoàn tiền',
};

async function loadOrders() {
  ordersLoading.value = true;
  try {
    orders.value = await fetchMyOrders();
  } finally {
    ordersLoading.value = false;
  }
}

// Widget theo dõi tiến trình đơn hàng (đơn còn đang xử lý) — hiện ở tab "Cá nhân", dưới phần
// địa chỉ, trên mã giảm giá.
const TRACK_STEPS = ['pending', 'confirmed', 'processing', 'shipped', 'delivered'];
const TRACK_STEP_LABELS = ['Chờ xác nhận', 'Đã xác nhận', 'Đóng gói', 'Đang giao', 'Đã giao'];
const activeOrders = computed(() =>
  orders.value.filter((o) => ['pending', 'confirmed', 'processing', 'shipped'].includes(o.status)),
);
const trackStepIndex = (status) => TRACK_STEPS.indexOf(status);
function goToOrderDetail(id) {
  selectTab('orders');
  openOrderDetail(id);
}
async function openOrderDetail(id) {
  orderDetail.value = await fetchOrderDetail(id);
}
function backToOrderList() {
  orderDetail.value = null;
  loadOrders();
}

// ===== Tab "Sản phẩm đã mua" (5:3 — trái: danh sách sản phẩm; phải: đánh giá + bảo hành) =====
const purchasesLoading = ref(true);
const purchasedItems = ref([]);
const selectedPurchaseId = ref(null);
const purchaseReviewForms = ref({});

const warrantyDetail = ref(null);
const warrantyIssue = ref('');
const warrantySending = ref(false);
const warrantyError = ref('');
const wStatusLabels = { active: 'Còn hạn', expired: 'Hết hạn', void: 'Vô hiệu' };
const wStatusColors = { active: 'var(--green)', expired: 'var(--muted)', void: 'var(--sale)' };
const wReqLabels = { pending: 'Chờ tiếp nhận', accepted: 'Đã tiếp nhận', processing: 'Đang xử lý', resolved: 'Đã hoàn thành', rejected: 'Từ chối' };
const wReqColors = { pending: 'var(--amber)', accepted: 'var(--acc, #c6ff4a)', processing: '#a855f7', resolved: 'var(--green)', rejected: 'var(--sale)' };

async function loadPurchasedItems() {
  purchasesLoading.value = true;
  try {
    purchasedItems.value = await fetchPurchasedItems();
    if (!selectedPurchaseId.value && purchasedItems.value.length) {
      selectPurchase(purchasedItems.value[0]);
    }
  } finally {
    purchasesLoading.value = false;
  }
}

const selectedPurchase = computed(() =>
  purchasedItems.value.find((it) => it.orderItemId === selectedPurchaseId.value) || null,
);

function selectPurchase(item) {
  selectedPurchaseId.value = item.orderItemId;
  if (!purchaseReviewForms.value[item.orderItemId]) {
    purchaseReviewForms.value[item.orderItemId] = { rating: 0, comment: '', photo1: null, photo2: null, saving: false };
  }
  warrantyDetail.value = null;
  warrantyError.value = '';
  if (item.warrantyId) openWarrantyDetail(item.warrantyId);
}

function onPurchasePhotoChange(orderItemId, slot, e) {
  const file = e.target.files?.[0] || null;
  purchaseReviewForms.value[orderItemId][slot] = file;
}

async function submitPurchaseReview(item) {
  const form = purchaseReviewForms.value[item.orderItemId];
  if (!form.rating) {
    actions.showToast('Vui lòng chọn số sao đánh giá');
    return;
  }
  form.saving = true;
  try {
    await submitProductReview(item.orderId, item.productId, form.rating, form.comment.trim() || null, form.photo1, form.photo2);
    actions.showToast('Đã gửi đánh giá "' + item.productName + '"');
    await loadPurchasedItems();
  } catch (e) {
    actions.showToast(e?.message || 'Có lỗi khi gửi đánh giá');
  } finally {
    form.saving = false;
  }
}

async function openWarrantyDetail(id) {
  warrantyDetail.value = await fetchWarrantyDetail(id);
  warrantyIssue.value = '';
}
async function submitWarrantyReq() {
  warrantyError.value = '';
  if (!warrantyIssue.value.trim()) {
    warrantyError.value = 'Vui lòng mô tả sự cố cần bảo hành';
    return;
  }
  warrantySending.value = true;
  try {
    warrantyDetail.value = await submitWarrantyRequest(warrantyDetail.value.id, warrantyIssue.value.trim());
    warrantyIssue.value = '';
    actions.showToast('Đã gửi yêu cầu bảo hành');
  } catch (e) {
    warrantyError.value = e?.message && !e.message.startsWith('HTTP') ? e.message : 'Gửi yêu cầu thất bại';
  } finally {
    warrantySending.value = false;
  }
}

function selectTab(tab) {
  activeTab.value = tab;
  if (tab === 'orders' && !orders.value.length) loadOrders();
  if (tab === 'warranty' && !purchasedItems.value.length) loadPurchasedItems();
}

// Route đổi mà component không remount (đã đứng sẵn trên AccountView, vd bấm
// "📦 Đơn hàng"/"🛡️ Bảo hành" ở header) — đồng bộ lại tab đang chọn theo route mới.
watch(
  () => route.name,
  (name) => {
    if (name === 'orders') selectTab('orders');
    else if (name === 'order-review') { selectTab('orders'); checkRouteOpensReviewWizard(); }
    else if (name === 'warranty') selectTab('warranty');
    else if (name === 'account') selectTab('profile');
  },
);

const TOPUP_RESULT_MSG = {
  success: 'Nạp ví thành công!',
  failed: 'Nạp ví thất bại, vui lòng thử lại',
  'gateway-not-configured': 'Cổng thanh toán thẻ chưa sẵn sàng, vui lòng thử lại sau',
};

// VNPay redirect về sau khi mua gói hội viên (?subscription=success|failed|...).
const SUB_RESULT_MSG = {
  success: 'Kích hoạt gói hội viên thành công!',
  failed: 'Thanh toán gói hội viên thất bại, vui lòng thử lại',
  'invalid-signature': 'Giao dịch không hợp lệ, vui lòng thử lại',
  'already-processed': 'Giao dịch này đã được xử lý',
};

onMounted(() => {
  loadProfile();
  loadWallet();
  loadMyCoupons();
  loadOrders(); // cần cho widget "Theo dõi đơn hàng" ở tab Cá nhân, không chỉ riêng tab Đơn hàng
  if (activeTab.value === 'warranty') loadPurchasedItems();
  checkRouteOpensReviewWizard();
  actions.loadNotifications();

  // Stripe redirect về sau khi nạp ví (?topup=success|failed) -> báo kết quả + dọn URL.
  const topupStatus = new URLSearchParams(window.location.search).get('topup');
  if (topupStatus) {
    actions.showToast(TOPUP_RESULT_MSG[topupStatus] || 'Đã xử lý lượt nạp ví');
    window.history.replaceState({}, '', window.location.pathname);
    if (topupStatus === 'success') loadWallet();
  }

  // VNPay redirect về sau khi mua gói hội viên -> mở tab Gói hội viên + báo kết quả + dọn URL.
  const subStatus = new URLSearchParams(window.location.search).get('subscription');
  if (subStatus) {
    activeTab.value = 'membership';
    subPanelKey.value++; // remount panel để nạp lại trạng thái gói vừa kích hoạt
    actions.showToast(SUB_RESULT_MSG[subStatus] || 'Đã xử lý giao dịch gói hội viên');
    window.history.replaceState({}, '', window.location.pathname);
  }
});
</script>

<template>
  <main style="max-width: 1320px; margin: 0 auto; padding: 24px 24px 64px">
    <button
      @click="actions.goHome"
      style="display: inline-flex; align-items: center; gap: 6px; background: transparent; color: var(--muted2); border: 1px solid rgba(var(--line-rgb), 0.2); border-radius: 9px; padding: 8px 14px; font-size: 13px; cursor: pointer; margin-bottom: 28px; font-family: 'Plus Jakarta Sans', sans-serif"
    >
      ← Quay lại trang chủ
    </button>

    <div style="font-family: 'Chakra Petch', sans-serif; font-size: 11px; letter-spacing: 2.5px; color: var(--acc,#c6ff4a); font-weight: 600; margin-bottom: 12px">
      TÀI KHOẢN
    </div>
    <h1 style="font-family: 'Plus Jakarta Sans', sans-serif; font-weight: 800; font-size: 34px; margin: 0 0 24px; color: var(--text)">
      Quản lý tài khoản
    </h1>

    <div v-if="!state.user" style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 60px 20px; text-align: center; color: var(--muted)">
      <div style="font-size: 14px; color: var(--muted2); margin-bottom: 14px">Bạn cần đăng nhập để xem trang này.</div>
      <button @click="actions.openLogin" :style="{ background: accent }" style="height: 42px; padding: 0 22px; border: none; border-radius: 10px; color: var(--acc-ink); font-weight: 700; font-size: 13.5px; cursor: pointer">Đăng nhập</button>
    </div>

    <div v-else style="display: flex; flex-direction: column; gap: 20px">
      <!-- Thanh tab ngang -->
      <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 8px; display: flex; align-items: center; gap: 6px; overflow-x: auto">
        <div
          @click="selectTab('profile')"
          :style="{
            color: activeTab === 'profile' ? 'var(--acc-ink)' : 'var(--muted2)',
            background: activeTab === 'profile' ? accent : 'transparent',
            fontWeight: activeTab === 'profile' ? 700 : 500,
          }"
          style="display: flex; align-items: center; gap: 8px; padding: 10px 16px; border-radius: 9px; font-size: 13.5px; cursor: pointer; white-space: nowrap"
        >
          <span style="font-size: 15px">👤</span> Cá nhân
        </div>
        <div
          @click="selectTab('orders')"
          :style="{
            color: activeTab === 'orders' ? 'var(--acc-ink)' : 'var(--muted2)',
            background: activeTab === 'orders' ? accent : 'transparent',
            fontWeight: activeTab === 'orders' ? 700 : 500,
          }"
          style="display: flex; align-items: center; gap: 8px; padding: 10px 16px; border-radius: 9px; font-size: 13.5px; cursor: pointer; white-space: nowrap"
        >
          <span style="font-size: 15px">📦</span> Đơn hàng của tôi
        </div>
        <div
          @click="selectTab('warranty')"
          :style="{
            color: activeTab === 'warranty' ? 'var(--acc-ink)' : 'var(--muted2)',
            background: activeTab === 'warranty' ? accent : 'transparent',
            fontWeight: activeTab === 'warranty' ? 700 : 500,
          }"
          style="display: flex; align-items: center; gap: 8px; padding: 10px 16px; border-radius: 9px; font-size: 13.5px; cursor: pointer; white-space: nowrap"
        >
          <span style="font-size: 15px">🧾</span> Sản phẩm đã mua
        </div>
        <div
          @click="selectTab('membership')"
          :style="{
            color: activeTab === 'membership' ? 'var(--acc-ink)' : 'var(--muted2)',
            background: activeTab === 'membership' ? accent : 'transparent',
            fontWeight: activeTab === 'membership' ? 700 : 500,
          }"
          style="display: flex; align-items: center; gap: 8px; padding: 10px 16px; border-radius: 9px; font-size: 13.5px; cursor: pointer; white-space: nowrap"
        >
          <span style="font-size: 15px">⭐</span> Gói hội viên
        </div>
        <div style="flex: 1"></div>
        <div
          @click="doLogout"
          style="display: flex; align-items: center; gap: 8px; padding: 10px 16px; border-radius: 9px; font-size: 13.5px; font-weight: 500; color: var(--sale); cursor: pointer; white-space: nowrap"
        >
          <span style="font-size: 15px">🚪</span> Đăng xuất
        </div>
      </div>

      <!-- Hạng thành viên: nổi bật thành băng ngang đầu trang -->
      <MembershipProgress v-if="activeTab === 'profile' && !walletLoading" variant="hero" :data="membership" />

      <!-- ===== TAB Gói hội viên (CNTT Care) — gói dịch vụ trả phí, tách rời hạng tích luỹ ===== -->
      <SubscriptionPanel v-if="activeTab === 'membership'" :key="subPanelKey" />

      <!-- ===== TAB Cá nhân: hồ sơ + địa chỉ (trái) / ví + thông báo (phải) ===== -->
      <div v-if="activeTab === 'profile'" style="display: grid; grid-template-columns: 3fr 2fr; gap: 20px; align-items: start">
      <div style="display: flex; flex-direction: column; gap: 16px">
        <div v-if="loading" style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 60px; text-align: center; color: var(--muted)">
          Đang tải...
        </div>
        <template v-else>
          <!-- Header hồ sơ -->
          <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 22px; display: flex; align-items: center; gap: 16px">
            <div
              :style="{ background: 'linear-gradient(135deg, ' + accent + ', #1c1d21)' }"
              style="width: 58px; height: 58px; border-radius: 14px; flex: none; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 20px; color: var(--acc-ink)"
            >
              {{ (state.user.fullName || state.user.email || '?').trim().charAt(0).toUpperCase() }}
            </div>
            <div>
              <div style="font-size: 17px; font-weight: 700; color: var(--text)">{{ state.user.fullName || 'Chưa cập nhật tên' }}</div>
              <div style="font-size: 12.5px; color: var(--muted); margin-top: 3px">{{ state.user.email }}</div>
            </div>
          </div>

          <!-- Thông tin cá nhân: tên / số điện thoại / email -->
          <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 22px">
            <div style="font-size: 14px; font-weight: 700; color: var(--text); margin-bottom: 16px">Thông tin cá nhân</div>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px">
              <div>
                <label style="display: block; font-size: 12px; color: var(--muted2); margin-bottom: 7px">Họ và tên</label>
                <input v-model="profile.hoTen" placeholder="Họ và tên"
                  style="width: 100%; height: 42px; padding: 0 13px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 13.5px; font-family: 'Plus Jakarta Sans', sans-serif" />
              </div>
              <div>
                <label style="display: block; font-size: 12px; color: var(--muted2); margin-bottom: 7px">Số điện thoại</label>
                <input v-model="profile.soDienThoai" placeholder="Số điện thoại"
                  style="width: 100%; height: 42px; padding: 0 13px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 13.5px; font-family: 'Plus Jakarta Sans', sans-serif" />
              </div>
            </div>
            <div style="margin-bottom: 18px">
              <label style="display: block; font-size: 12px; color: var(--muted2); margin-bottom: 7px">Email (Gmail)</label>
              <input :value="state.user.email" disabled
                style="width: 100%; height: 42px; padding: 0 13px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 9px; color: var(--muted); font-size: 13.5px; font-family: 'Plus Jakarta Sans', sans-serif; cursor: not-allowed" />
            </div>
            <button
              @click="saveProfile" :disabled="savingProfile"
              :style="{ background: accent, opacity: savingProfile ? 0.7 : 1 }"
              style="height: 42px; padding: 0 22px; border: none; border-radius: 10px; color: var(--acc-ink); font-weight: 700; font-size: 13.5px; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif"
            >
              {{ savingProfile ? 'Đang lưu...' : 'Lưu thay đổi' }}
            </button>
          </div>

          <!-- Địa chỉ — hỗ trợ nhiều địa chỉ, sửa/xoá/đặt mặc định từng cái -->
          <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 22px">
            <div style="font-size: 14px; font-weight: 700; color: var(--text); margin-bottom: 16px">Địa chỉ ({{ addresses.length }})</div>

            <div v-if="!addresses.length && !showAddressForm" style="font-size: 13.5px; color: var(--muted); margin-bottom: 14px">
              Bạn chưa thêm địa chỉ nào.
            </div>

            <div v-if="addresses.length" style="display: flex; flex-direction: column; gap: 10px; margin-bottom: 14px">
              <div
                v-for="a in addresses" :key="a.id"
                style="border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 10px; padding: 14px; display: flex; justify-content: space-between; align-items: flex-start; gap: 10px"
              >
                <div style="font-size: 13.5px; color: var(--muted2); line-height: 1.6">
                  <div style="font-weight: 600; color: var(--text)">
                    {{ a.tenNguoiNhan }} · {{ a.soDienThoai }}
                    <span v-if="a.isDefault" style="margin-left: 6px; font-size: 10.5px; background: var(--acc,#c6ff4a); color: var(--acc-ink); padding: 2px 7px; border-radius: 10px; font-weight: 700">MẶC ĐỊNH</span>
                  </div>
                  <div style="margin-top: 4px; color: var(--muted2)">{{ a.diaChiDayDu }}</div>
                </div>
                <div style="display: flex; gap: 6px; flex: none; flex-wrap: wrap; justify-content: flex-end">
                  <button
                    @click="openAddressForm(a)"
                    style="background: transparent; border: 1px solid rgba(var(--line-rgb),0.25); color: var(--muted2); border-radius: 8px; padding: 6px 11px; font-size: 12px; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif"
                  >Sửa</button>
                  <button
                    v-if="!a.isDefault"
                    @click="makeDefaultAddress(a.id)"
                    style="background: transparent; border: 1px solid rgba(var(--line-rgb),0.25); color: var(--muted2); border-radius: 8px; padding: 6px 11px; font-size: 12px; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif"
                  >Đặt mặc định</button>
                  <button
                    @click="removeAddress(a.id)"
                    style="background: transparent; border: 1px solid rgba(var(--sale-rgb),0.3); color: var(--sale); border-radius: 8px; padding: 6px 11px; font-size: 12px; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif"
                  >Xoá</button>
                </div>
              </div>
            </div>

            <button
              v-if="!showAddressForm"
              @click="openAddressForm(null)"
              style="background: transparent; border: 1px dashed rgba(var(--line-rgb),0.3); color: var(--muted2); border-radius: 9px; padding: 9px 14px; cursor: pointer; font-size: 12.5px; font-family: 'Plus Jakarta Sans', sans-serif"
            >
              + Thêm địa chỉ mới
            </button>

            <Transition name="dropdown-fade">
            <div v-if="showAddressForm" style="margin-top: 12px; display: grid; grid-template-columns: 1fr 1fr; gap: 12px">
              <!-- Chọn cách nhập: gõ địa chỉ rồi xác nhận bằng mốc, hoặc chỉ thả ghim và để hệ
                   thống tự tra ngược ra địa chỉ chữ -->
              <div style="grid-column: 1 / -1; display: flex; gap: 8px">
                <button
                  type="button" @click="cheDoNhap = 'nhap'"
                  :style="{ borderColor: cheDoNhap === 'nhap' ? accent : 'rgba(var(--line-rgb),0.2)', color: cheDoNhap === 'nhap' ? 'var(--text)' : 'var(--muted2)' }"
                  style="flex: 1; height: 38px; border: 1px solid; background: transparent; border-radius: 9px; font-size: 12.5px; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif"
                >
                  Nhập địa chỉ + cắm mốc
                </button>
                <button
                  type="button" @click="cheDoNhap = 'mocDiem'"
                  :style="{ borderColor: cheDoNhap === 'mocDiem' ? accent : 'rgba(var(--line-rgb),0.2)', color: cheDoNhap === 'mocDiem' ? 'var(--text)' : 'var(--muted2)' }"
                  style="flex: 1; height: 38px; border: 1px solid; background: transparent; border-radius: 9px; font-size: 12.5px; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif"
                >
                  Cắm mốc + chọn Tỉnh/Phường
                </button>
              </div>

              <input v-model="addressForm.tenNguoiNhan" placeholder="Tên người nhận"
                style="height: 42px; padding: 0 13px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 13.5px" />
              <input v-model="addressForm.soDienThoai" placeholder="Số điện thoại"
                style="height: 42px; padding: 0 13px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 13.5px" />
              <input v-model="addressForm.diaChiCuThe" :placeholder="cheDoNhap === 'mocDiem' ? 'Số nhà, đường (tự điền từ bản đồ)' : 'Số nhà, đường'"
                style="grid-column: 1 / -1; height: 42px; padding: 0 13px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 13.5px" />
              <select v-model.number="addressForm.provinceId" @change="onFormProvinceChange"
                style="height: 42px; padding: 0 13px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 13.5px; cursor: pointer">
                <option :value="null" disabled>Tỉnh/Thành phố</option>
                <option v-for="p in provinces" :key="p.id" :value="p.id">{{ p.name }}</option>
              </select>
              <select v-model.number="addressForm.wardId" :disabled="!addressForm.provinceId || loadingWards"
                style="height: 42px; padding: 0 13px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 13.5px; cursor: pointer">
                <option :value="null" disabled>{{ loadingWards ? 'Đang tải...' : 'Phường/Xã' }}</option>
                <option v-for="w in wardsForForm" :key="w.id" :value="w.id">{{ w.name }}</option>
              </select>
              <!-- Cắm mốc bắt buộc: phí giao nội thành Hải Phòng tính theo quãng đường thật từ
                   kho tới đúng điểm này, và shipper dùng nó để tìm nhà -->
              <div style="grid-column: 1 / -1">
                <MapPicker v-model="toaDo" @reverse="onPinMoved" />
                <div v-if="dangTraNguoc" style="font-size: 11.5px; color: var(--muted); margin-top: 6px">
                  Đang tra địa chỉ từ vị trí đã cắm...
                </div>
                <div v-else-if="goiYDiaChi" style="font-size: 11.5px; color: var(--muted2); margin-top: 6px; line-height: 1.5">
                  Vị trí đã cắm: {{ goiYDiaChi }}
                </div>
              </div>

              <div style="grid-column: 1 / -1; display: flex; gap: 10px; margin-top: 4px">
                <button
                  @click="saveAddress" :disabled="savingAddress"
                  :style="{ background: accent, opacity: savingAddress ? 0.7 : 1 }"
                  style="height: 40px; padding: 0 20px; border: none; border-radius: 9px; color: var(--acc-ink); font-weight: 700; font-size: 13px; cursor: pointer"
                >
                  {{ savingAddress ? 'Đang lưu...' : (editingAddressId ? 'Lưu thay đổi' : 'Thêm địa chỉ') }}
                </button>
                <button
                  @click="closeAddressForm"
                  style="height: 40px; padding: 0 18px; border: 1px solid rgba(var(--line-rgb),0.22); background: transparent; border-radius: 9px; color: var(--muted2); font-size: 13px; cursor: pointer"
                >
                  Hủy
                </button>
              </div>
            </div>
            </Transition>
          </div>

          <!-- Theo dõi tiến trình đơn hàng đang xử lý — dưới địa chỉ, trên mã giảm giá -->
          <div v-if="activeOrders.length" style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 22px">
            <div style="font-size: 14px; font-weight: 700; color: var(--text); margin-bottom: 18px">Theo dõi đơn hàng ({{ activeOrders.length }})</div>
            <div style="display: flex; flex-direction: column; gap: 20px">
              <div
                v-for="o in activeOrders" :key="o.id"
                @click="goToOrderDetail(o.id)"
                style="cursor: pointer"
              >
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px">
                  <span style="font-size: 13px; font-weight: 600; color: var(--text)">{{ o.orderCode }}</span>
                  <span :style="{ color: accent }" style="font-size: 11.5px; font-weight: 600">{{ ORDER_STATUS_LABEL[o.status] }}</span>
                </div>
                <div style="display: flex; align-items: flex-start">
                  <template v-for="(label, idx) in TRACK_STEP_LABELS" :key="idx">
                    <div style="display: flex; flex-direction: column; align-items: center; gap: 6px; flex: none; width: 56px">
                      <div
                        :style="{
                          background: idx <= trackStepIndex(o.status) ? accent : 'var(--card2)',
                          color: idx <= trackStepIndex(o.status) ? 'var(--acc-ink)' : 'var(--muted)',
                        }"
                        style="width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 10.5px; font-weight: 700"
                      >
                        {{ idx <= trackStepIndex(o.status) ? '✓' : idx + 1 }}
                      </div>
                      <span
                        :style="{ color: idx <= trackStepIndex(o.status) ? 'var(--muted2)' : 'var(--muted)' }"
                        style="font-size: 9.5px; text-align: center; line-height: 1.3"
                      >{{ label }}</span>
                    </div>
                    <div
                      v-if="idx < TRACK_STEP_LABELS.length - 1"
                      :style="{ background: idx < trackStepIndex(o.status) ? accent : 'rgba(var(--line-rgb),0.16)' }"
                      style="flex: 1; height: 2px; margin-top: 10px"
                    ></div>
                  </template>
                </div>
              </div>
            </div>
          </div>

          <!-- Mã giảm giá của tôi — coupon đã đổi bằng Xu CT ở trang khuyến mãi, dạng vé xé -->
          <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 22px">
            <MyCouponTickets :coupons="myCoupons" :loading="myCouponsLoading" />
          </div>
        </template>
      </div>

      <div v-if="!loading" style="display: flex; flex-direction: column; gap: 16px; position: sticky; top: 100px">
        <!-- Thu cũ đổi mới: gửi máy, theo dõi định giá, xem tín dụng đã nhận -->
        <TradeInPanel />

        <!-- Xu CT -->
        <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 22px">
          <div style="font-size: 14px; font-weight: 700; color: var(--text); margin-bottom: 16px">🪙 Xu CT</div>

          <div v-if="walletLoading" style="text-align: center; padding: 20px 0; color: var(--muted); font-size: 13px">Đang tải...</div>
          <template v-else>
            <div style="background: var(--card2); border-radius: 10px; padding: 16px; text-align: center; margin-bottom: 16px">
              <div style="font-size: 26px; font-weight: 700; color: #d9b34a">{{ xuBalance }}</div>
              <div style="font-size: 11px; color: var(--muted2); margin-top: 3px">Xu hiện có</div>
            </div>
            <div style="font-size: 12px; color: var(--muted2); margin-bottom: 16px; line-height: 1.6">
              Kiếm Xu CT khi mua hàng (10.000đ = 1 xu), mỗi xu giảm được 1.000đ. Dùng xu ở
              <a href="#" @click.prevent="actions.goPromotions" :style="{ color: accent }" style="text-decoration: none">trang khuyến mãi</a>
              để đổi coupon/quà, hoặc giảm thẳng vào bill ngay lúc thanh toán.
            </div>

            <div style="font-size: 12.5px; font-weight: 600; color: var(--muted2); margin-bottom: 8px">Lịch sử giao dịch</div>
            <div v-if="!walletTransactions.length" style="font-size: 12.5px; color: var(--muted); padding: 10px 0">Chưa có giao dịch nào.</div>
            <div v-else style="display: flex; flex-direction: column; gap: 8px; max-height: 220px; overflow-y: auto">
              <div v-for="t in walletTransactions" :key="t.id" style="display: flex; justify-content: space-between; font-size: 12px; padding: 8px 10px; background: var(--card2); border-radius: 8px">
                <div>
                  <div style="color: var(--text)">{{ WALLET_TX_TYPE_LABEL[t.type] || t.type }}</div>
                  <div style="color: var(--muted); margin-top: 2px; font-size: 11px">{{ fmtDateTime(t.createdAt) }}</div>
                </div>
                <div :style="{ color: t.amount >= 0 ? 'var(--green)' : 'var(--sale)' }" style="font-weight: 700; align-self: center">
                  {{ t.amount >= 0 ? '+' : '' }}{{ t.amount }} xu
                </div>
              </div>
            </div>
          </template>
        </div>

        <!-- Thông báo -->
        <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 22px">
          <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px">
            <div style="font-size: 14px; font-weight: 700; color: var(--text)">Thông báo</div>
            <button
              v-if="state.unreadNotifCount"
              @click="actions.markAllNotificationsRead"
              :style="{ color: accent }"
              style="background: none; border: none; font-size: 12.5px; font-weight: 600; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif"
            >
              Đánh dấu đã đọc hết
            </button>
          </div>
          <div v-if="!state.notifications.length" style="text-align: center; padding: 30px 0; color: var(--muted); font-size: 13px">
            Bạn chưa có thông báo nào.
          </div>
          <div v-else style="display: flex; flex-direction: column; gap: 4px; max-height: 360px; overflow-y: auto; padding-right: 2px">
            <div
              v-for="n in state.notifications"
              :key="n.id"
              @click="actions.markNotificationRead(n)"
              style="display: flex; gap: 12px; padding: 12px; border-radius: 10px; cursor: pointer"
              :style="{ background: n.isRead ? 'transparent' : 'color-mix(in srgb, ' + accent + ' 7%, transparent)' }"
            >
              <span
                style="width: 7px; height: 7px; border-radius: 50%; flex: none; margin-top: 6px"
                :style="{ background: n.isRead ? 'transparent' : accent }"
              ></span>
              <div style="flex: 1; min-width: 0">
                <div style="font-size: 13.5px; font-weight: 600; color: var(--text)">{{ n.title }}</div>
                <div style="font-size: 12.5px; color: var(--muted2); margin-top: 3px; line-height: 1.4">{{ n.message }}</div>
                <div style="font-size: 11.5px; color: var(--muted); margin-top: 5px">{{ timeAgo(n.createdAt) }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Đổi mật khẩu — ẩn mặc định, chỉ tài khoản tự tạo mới có (Google/Facebook không có
        mật khẩu nội bộ). Xác minh qua mã gửi tới email, không cần nhập mật khẩu hiện tại. -->
        <div v-if="state.user.authProvider === 'local'" style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 22px">
          <div style="font-size: 14px; font-weight: 700; color: var(--text); margin-bottom: 16px">Đổi mật khẩu</div>

          <template v-if="pw.step === null">
            <div style="font-size: 13px; color: var(--muted2); margin-bottom: 16px; line-height: 1.6">
              Để bảo mật, đổi mật khẩu cần xác minh qua mã gửi tới email
              <b style="color: var(--text)">{{ state.user.email }}</b>.
            </div>
            <button
              @click="pwOpen" :disabled="pw.loading"
              :style="{ background: accent, opacity: pw.loading ? 0.7 : 1 }"
              style="height: 42px; padding: 0 22px; border: none; border-radius: 10px; color: var(--acc-ink); font-weight: 700; font-size: 13.5px; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif"
            >
              {{ pw.loading ? 'Đang gửi mã...' : 'Đổi mật khẩu' }}
            </button>
          </template>

          <template v-else>
            <div v-if="pw.error" style="background: rgba(var(--sale-rgb),0.12); border: 1px solid rgba(var(--sale-rgb),0.3); color: var(--sale); border-radius: 10px; padding: 10px 14px; font-size: 12.5px; margin-bottom: 14px">
              {{ pw.error }}
            </div>

            <template v-if="pw.step === 'otp'">
              <div style="font-size: 13px; color: var(--muted2); margin-bottom: 14px; line-height: 1.6">
                Mã xác nhận đã gửi tới <b style="color: var(--text)">{{ state.user.email }}</b> (hiệu lực 5 phút).
              </div>
              <input
                v-model="pw.otp" maxlength="6" placeholder="000000"
                style="width: 100%; height: 46px; padding: 0 13px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 18px; font-family: 'Chakra Petch', monospace; text-align: center; letter-spacing: 6px"
              />
              <div style="display: flex; gap: 10px; margin-top: 14px">
                <button
                  @click="pwVerify" :disabled="pw.loading"
                  :style="{ background: accent, opacity: pw.loading ? 0.7 : 1 }"
                  style="height: 40px; padding: 0 18px; border: none; border-radius: 9px; color: var(--acc-ink); font-weight: 700; font-size: 13px; cursor: pointer"
                >
                  {{ pw.loading ? 'Đang xác nhận...' : 'Xác nhận' }}
                </button>
                <button
                  @click="pwCancel"
                  style="height: 40px; padding: 0 16px; border: 1px solid rgba(var(--line-rgb),0.22); background: transparent; border-radius: 9px; color: var(--muted2); font-size: 13px; cursor: pointer"
                >
                  Hủy
                </button>
              </div>
              <a href="#" @click.prevent="pwResend" :style="{ color: accent }" style="display: inline-block; margin-top: 12px; font-size: 12.5px; text-decoration: none">Gửi lại mã</a>
            </template>

            <template v-else-if="pw.step === 'reset'">
              <div style="display: flex; flex-direction: column; gap: 12px; margin-bottom: 14px">
                <div>
                  <label style="display: block; font-size: 12px; color: var(--muted2); margin-bottom: 7px">Mật khẩu mới</label>
                  <input v-model="pw.pw" type="password" placeholder="Ít nhất 6 ký tự"
                    style="width: 100%; height: 42px; padding: 0 13px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 13.5px; font-family: 'Plus Jakarta Sans', sans-serif" />
                </div>
                <div>
                  <label style="display: block; font-size: 12px; color: var(--muted2); margin-bottom: 7px">Nhập lại mật khẩu mới</label>
                  <input v-model="pw.pw2" type="password" placeholder="Nhập lại mật khẩu mới"
                    style="width: 100%; height: 42px; padding: 0 13px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 13.5px; font-family: 'Plus Jakarta Sans', sans-serif" />
                </div>
              </div>
              <div style="display: flex; gap: 10px">
                <button
                  @click="pwReset" :disabled="pw.loading"
                  :style="{ background: accent, opacity: pw.loading ? 0.7 : 1 }"
                  style="height: 42px; padding: 0 22px; border: none; border-radius: 10px; color: var(--acc-ink); font-weight: 700; font-size: 13.5px; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif"
                >
                  {{ pw.loading ? 'Đang lưu...' : 'Đổi mật khẩu' }}
                </button>
                <button
                  @click="pwCancel"
                  style="height: 42px; padding: 0 18px; border: 1px solid rgba(var(--line-rgb),0.22); background: transparent; border-radius: 10px; color: var(--muted2); font-size: 13.5px; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif"
                >
                  Hủy
                </button>
              </div>
            </template>
          </template>
        </div>
      </div>
      </div>

      <div v-if="activeTab === 'orders'" style="display: flex; flex-direction: column; gap: 16px">
        <div v-if="ordersLoading" style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 60px; text-align: center; color: var(--muted)">
          Đang tải...
        </div>
        <template v-else-if="orderDetail">
          <button
            @click="backToOrderList"
            style="align-self: flex-start; display: inline-flex; align-items: center; gap: 6px; background: transparent; border: 1px solid rgba(var(--line-rgb),0.2); color: var(--muted); border-radius: 9px; padding: 7px 12px; font-size: 12.5px; cursor: pointer; margin-bottom: 4px"
          >
            ← Quay lại danh sách đơn hàng
          </button>
          <OrderDetailCard :order="orderDetail" @updated="() => openOrderDetail(orderDetail.id)" />
        </template>
        <template v-else>
          <div v-if="!orders.length" style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 50px; text-align: center; color: var(--muted)">
            Bạn chưa có đơn hàng nào.
          </div>
          <div v-else style="display: flex; flex-direction: column; gap: 12px">
            <div v-for="o in orders" :key="o.id" @click="openOrderDetail(o.id)"
              style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 16px 20px; cursor: pointer; display: flex; justify-content: space-between; align-items: center">
              <div>
                <div style="font-size: 13.5px; font-weight: 700; color: var(--text)">{{ o.orderCode }}</div>
                <div style="font-size: 12px; color: var(--muted); margin-top: 4px">{{ o.itemCount }} sản phẩm · {{ new Date(o.createdAt).toLocaleDateString('vi-VN') }}</div>
              </div>
              <div style="text-align: right">
                <div style="font-size: 14px; font-weight: 700; color: var(--acc,#c6ff4a)">{{ Number(o.totalAmount).toLocaleString('vi-VN') }}₫</div>
                <div style="font-size: 11px; color: var(--muted2); margin-top: 4px">{{ ORDER_STATUS_LABEL[o.status] || o.status }}</div>
              </div>
            </div>
          </div>
        </template>
      </div>

      <div v-if="activeTab === 'warranty'">
        <div v-if="purchasesLoading" style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 60px; text-align: center; color: var(--muted)">
          Đang tải...
        </div>
        <div v-else-if="!purchasedItems.length" style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 50px; text-align: center; color: var(--muted)">
          Bạn chưa có sản phẩm nào đã giao để đánh giá/bảo hành.
        </div>
        <div v-else style="display: grid; grid-template-columns: 5fr 3fr; gap: 16px; align-items: start">
          <!-- Trái (5): danh sách sản phẩm đã mua -->
          <div style="display: flex; flex-direction: column; gap: 10px">
            <div
              v-for="it in purchasedItems" :key="it.orderItemId"
              @click="selectPurchase(it)"
              style="border-radius: 14px; padding: 16px 18px; cursor: pointer; display: flex; justify-content: space-between; align-items: center; border: 1px solid"
              :style="{
                background: selectedPurchaseId === it.orderItemId ? 'color-mix(in srgb, ' + accent + ' 10%, var(--card))' : 'var(--card)',
                borderColor: selectedPurchaseId === it.orderItemId ? accent : 'rgba(var(--line-rgb),0.14)',
              }"
            >
              <div style="min-width: 0">
                <div style="font-size: 14px; font-weight: 600; color: var(--text)">{{ it.productName }}</div>
                <div style="font-size: 11.5px; color: var(--muted); margin-top: 4px">Đơn {{ it.orderCode }}</div>
              </div>
              <div style="display: flex; flex-direction: column; gap: 5px; align-items: flex-end; flex: none; margin-left: 10px">
                <span
                  style="font-size: 10.5px; font-weight: 600; padding: 3px 9px; border-radius: 20px"
                  :style="{
                    background: 'color-mix(in srgb,' + (it.reviewed ? 'var(--green)' : (it.reviewEligible ? accent : 'var(--muted)')) + ' 16%, transparent)',
                    color: it.reviewed ? 'var(--green)' : (it.reviewEligible ? accent : 'var(--muted)'),
                  }"
                >
                  {{ it.reviewed ? '✓ Đã đánh giá' : (it.reviewEligible ? 'Chưa đánh giá' : 'Hết hạn đánh giá') }}
                </span>
                <span
                  v-if="it.warrantyStatus"
                  style="font-size: 10.5px; font-weight: 600; padding: 3px 9px; border-radius: 20px"
                  :style="{ background: 'color-mix(in srgb,' + (wStatusColors[it.warrantyStatus] || 'var(--muted)') + ' 16%, transparent)', color: wStatusColors[it.warrantyStatus] || 'var(--muted)' }"
                >
                  🛡️ {{ wStatusLabels[it.warrantyStatus] || it.warrantyStatus }}
                </span>
              </div>
            </div>
          </div>

          <!-- Phải (3): đánh giá + bảo hành cho sản phẩm đang chọn -->
          <div v-if="selectedPurchase" style="display: flex; flex-direction: column; gap: 16px; position: sticky; top: 100px">
            <!-- Đánh giá -->
            <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 18px">
              <div style="font-size: 13.5px; font-weight: 700; color: var(--text); margin-bottom: 12px">Đánh giá sản phẩm</div>

              <div v-if="selectedPurchase.reviewed" style="font-size: 12.5px; color: var(--green,#22d39a)">✓ Bạn đã đánh giá sản phẩm này.</div>
              <div v-else-if="!selectedPurchase.reviewEligible" style="font-size: 12.5px; color: var(--muted)">Đã hết hạn 14 ngày đánh giá cho sản phẩm này.</div>
              <template v-else-if="purchaseReviewForms[selectedPurchase.orderItemId]">
                <StarRatingInput v-model="purchaseReviewForms[selectedPurchase.orderItemId].rating" :size="24" />
                <textarea
                  v-model="purchaseReviewForms[selectedPurchase.orderItemId].comment"
                  rows="3" placeholder="Chia sẻ trải nghiệm của bạn về sản phẩm (không bắt buộc)"
                  style="width: 100%; margin-top: 10px; padding: 10px 12px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.2); border-radius: 9px; color: var(--text); font-size: 12.5px; font-family: 'Plus Jakarta Sans', sans-serif; resize: vertical"
                ></textarea>
                <div style="display: flex; gap: 10px; margin-top: 8px; font-size: 11.5px; color: var(--muted2)">
                  <label style="display: flex; align-items: center; gap: 4px; cursor: pointer">
                    📷 Ảnh 1
                    <input type="file" accept="image/*" style="display: none" @change="onPurchasePhotoChange(selectedPurchase.orderItemId, 'photo1', $event)" />
                    <span v-if="purchaseReviewForms[selectedPurchase.orderItemId].photo1" style="color: var(--acc,#c6ff4a)">✓</span>
                  </label>
                  <label style="display: flex; align-items: center; gap: 4px; cursor: pointer">
                    📷 Ảnh 2
                    <input type="file" accept="image/*" style="display: none" @change="onPurchasePhotoChange(selectedPurchase.orderItemId, 'photo2', $event)" />
                    <span v-if="purchaseReviewForms[selectedPurchase.orderItemId].photo2" style="color: var(--acc,#c6ff4a)">✓</span>
                  </label>
                </div>
                <button
                  @click="submitPurchaseReview(selectedPurchase)" :disabled="purchaseReviewForms[selectedPurchase.orderItemId].saving"
                  :style="{ background: accent, opacity: purchaseReviewForms[selectedPurchase.orderItemId].saving ? 0.7 : 1 }"
                  style="margin-top: 10px; height: 38px; padding: 0 18px; border: none; border-radius: 9px; color: var(--acc-ink); font-weight: 700; font-size: 12.5px; cursor: pointer"
                >
                  {{ purchaseReviewForms[selectedPurchase.orderItemId].saving ? 'Đang gửi...' : 'Gửi đánh giá' }}
                </button>
              </template>
            </div>

            <!-- Bảo hành -->
            <div v-if="warrantyDetail" style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 18px">
              <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 10px">
                <div style="font-size: 13.5px; font-weight: 700; color: var(--text)">Bảo hành</div>
                <span
                  style="font-size: 10.5px; font-weight: 600; padding: 3px 9px; border-radius: 20px"
                  :style="{ background: 'color-mix(in srgb,' + (wStatusColors[warrantyDetail.status] || 'var(--muted)') + ' 16%, transparent)', color: wStatusColors[warrantyDetail.status] || 'var(--muted)' }"
                >
                  {{ wStatusLabels[warrantyDetail.status] || warrantyDetail.status }}
                </span>
              </div>
              <div style="font-size: 12px; color: var(--muted2); margin-bottom: 14px">
                Hiệu lực: {{ fmtDate(warrantyDetail.startDate) }} → {{ fmtDate(warrantyDetail.endDate) }}
                <span v-if="warrantyDetail.serialNumber"> · Serial: {{ warrantyDetail.serialNumber }}</span>
              </div>

              <div v-if="warrantyError" style="background: rgba(var(--sale-rgb),0.12); border: 1px solid rgba(var(--sale-rgb),0.3); color: var(--sale); border-radius: 9px; padding: 9px 12px; font-size: 12.5px; margin-bottom: 10px">
                {{ warrantyError }}
              </div>
              <textarea
                v-model="warrantyIssue" rows="2" placeholder="Mô tả sự cố cần bảo hành..."
                style="width: 100%; padding: 10px 12px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 12.5px; font-family: 'Plus Jakarta Sans', sans-serif; resize: vertical; margin-bottom: 10px"
              ></textarea>
              <button
                @click="submitWarrantyReq" :disabled="warrantySending"
                :style="{ background: accent, opacity: warrantySending ? 0.7 : 1 }"
                style="border: none; border-radius: 9px; height: 38px; padding: 0 18px; color: var(--acc-ink); font-weight: 700; font-size: 12.5px; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif"
              >
                {{ warrantySending ? 'Đang gửi...' : 'Gửi yêu cầu bảo hành' }}
              </button>

              <div style="font-size: 12px; font-weight: 600; color: var(--muted2); margin-top: 16px; margin-bottom: 8px">
                Yêu cầu đã gửi ({{ warrantyDetail.requests.length }})
              </div>
              <div v-if="!warrantyDetail.requests.length" style="color: var(--muted); font-size: 12px">Chưa có yêu cầu nào.</div>
              <div
                v-for="r in warrantyDetail.requests" :key="r.id"
                style="border: 1px solid rgba(var(--line-rgb),0.12); border-radius: 10px; padding: 10px 12px; margin-bottom: 8px"
              >
                <div style="display: flex; justify-content: space-between; align-items: center">
                  <span style="font-size: 12px; color: var(--text)">{{ r.issueDescription }}</span>
                  <span
                    style="font-size: 10px; font-weight: 600; padding: 2px 8px; border-radius: 20px; flex: none; margin-left: 8px"
                    :style="{ background: 'color-mix(in srgb,' + (wReqColors[r.requestStatus] || 'var(--muted)') + ' 16%, transparent)', color: wReqColors[r.requestStatus] || 'var(--muted)' }"
                  >
                    {{ wReqLabels[r.requestStatus] || r.requestStatus }}
                  </span>
                </div>
                <div style="font-size: 11px; color: var(--muted); margin-top: 5px">{{ fmtDateTime(r.createdAt) }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <ReviewWizardModal :order-id="reviewWizardOrderId" @close="closeReviewWizard" />
  </main>
</template>
