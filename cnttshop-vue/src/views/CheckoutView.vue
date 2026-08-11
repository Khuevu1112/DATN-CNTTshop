<script setup>
import { ref, computed, onMounted } from 'vue';
import { fmt, VND_MOI_XU_TIEU } from '../data/products.js';
import { state, actions, accent } from '../store.js';
import {
  fetchAddresses, createAddress, fetchPaymentMethods, placeOrder, applyCoupons, fetchWallet,
  fetchProvinces, fetchWards, fetchShippingOptions, fetchMyCoupons, fetchMembership, reverseGeocode, fetchTinDungThuCu,
} from '../api.js';
import MapPicker from '../components/MapPicker.vue';
import MyCouponTickets from '../components/MyCouponTickets.vue';

const loading = ref(true);
const addresses = ref([]);
const selectedAddressId = ref(null);
const paymentMethods = ref([]);
const selectedMethod = ref('cod');
const showNewAddress = ref(false);
const placing = ref(false);
const error = ref('');

const couponInput = ref('');
// Danh sách mã ĐANG áp dụng — mỗi phần tử: { code, discountType, discountValue, maxDiscountAmount,
// stackable, discountAmount }. Nguồn sự thật LUÔN là kết quả trả về từ backend (/coupons/apply-multi)
// sau mỗi lần thêm/bớt mã, không tự tính ở client — backend mới là nơi áp đúng quy tắc cộng
// dồn/loại trừ + giới hạn giảm tối đa.
const appliedCoupons = ref([]);
const couponTotalDiscount = ref(0);
const myCoupons = ref([]);
const myCouponsLoading = ref(true);
const couponLoading = ref(false);
const couponError = ref('');

const xuBalance = ref(0);
const useXu = ref(false);
const xuInput = ref(0);

const form = ref({
  tenNguoiNhan: '', soDienThoai: '', diaChiCuThe: '',
  provinceId: null, wardId: null, isDefault: false,
});
const provinces = ref([]);
const wardsForForm = ref([]);
const loadingWards = ref(false);

// Cắm mốc bản đồ — BẮT BUỘC với mọi địa chỉ mới. Hai chế độ nhập:
//   'nhap' = gõ địa chỉ rồi cắm mốc xác nhận đúng chỗ;
//   'mocDiem' = chỉ thả ghim, hệ thống tự tra ngược ra đường/Tỉnh/Phường (khách vẫn sửa được).
const cheDoNhap = ref('nhap');
const toaDo = ref(null); // { lat, lng }
const dangTraNguoc = ref(false);
const goiYDiaChi = ref('');

/** Toạ độ đổi ở chế độ "chỉ cắm mốc" -> tự điền lại các ô địa chỉ từ kết quả tra ngược. Chế độ
 * nhập tay thì không đụng vào những gì khách đã gõ, chỉ hiện gợi ý để đối chiếu. */
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
    if (kq.diaChiCuThe) form.value.diaChiCuThe = kq.diaChiCuThe;
    else if (kq.diaChiDayDu) form.value.diaChiCuThe = kq.diaChiDayDu;
  } catch (e) {
    // Tra ngược chỉ là tiện ích — hỏng thì khách tự chọn Tỉnh/Phường, không chặn luồng.
  } finally {
    dangTraNguoc.value = false;
  }
}

async function taiWardChoTinh(provinceId) {
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
  form.value.wardId = null;
  wardsForForm.value = [];
  if (!form.value.provinceId) return;
  await taiWardChoTinh(form.value.provinceId);
}

// Chỉ thanh toán các dòng đã tick chọn ở CartView, không phải toàn bộ giỏ hàng.
const selectedLines = computed(() =>
  state.cart.filter((c) => state.selectedCartItemIds.includes(c.id)),
);
const selectedSubtotal = computed(() =>
  selectedLines.value.reduce((sum, c) => sum + c.lineTotal, 0),
);
const subtotalText = computed(() => fmt(selectedSubtotal.value));

// Tuỳ chọn giao hàng theo Phường của địa chỉ đang chọn (hoả tốc/thường trong Hải Phòng, hoặc 1
// trong 5 đơn vị vận chuyển ngoài Hải Phòng) — xem ShippingService bên backend.
const shippingOptions = ref([]);
const shippingScope = ref(null); // 'hai_phong' | 'carrier' | null (chưa xác định được)
const selectedShippingCode = ref(null);
const shippingLoading = ref(false);
// Quãng đường thật từ kho tới điểm cắm — backend chỉ trả khi giao nội thành Hải Phòng VÀ địa chỉ
// đã có mốc; null thì phí đang lấy theo bảng phẳng cũ nên không hiện số km.
const shippingDistanceKm = ref(null);
const shippingFee = computed(() => {
  const opt = shippingOptions.value.find((o) => o.code === selectedShippingCode.value);
  return opt ? opt.fee : 30000;
});

async function loadShippingOptions() {
  const addr = addresses.value.find((a) => a.id === selectedAddressId.value);
  if (!addr?.wardId) {
    shippingOptions.value = [];
    shippingScope.value = null;
    selectedShippingCode.value = null;
    return;
  }
  shippingLoading.value = true;
  try {
    const result = await fetchShippingOptions(addr.wardId, addr.latitude, addr.longitude);
    shippingScope.value = result.scope;
    shippingOptions.value = result.options;
    shippingDistanceKm.value = result.khoangCachKm;
    selectedShippingCode.value = result.options[0]?.code || null;
  } catch (e) {
    shippingOptions.value = [];
    shippingScope.value = null;
    shippingDistanceKm.value = null;
    selectedShippingCode.value = null;
  } finally {
    shippingLoading.value = false;
  }
}

function selectAddress(id) {
  selectedAddressId.value = id;
  loadShippingOptions();
}

const couponDiscount = computed(() => couponTotalDiscount.value);
const appliedCodes = computed(() => appliedCoupons.value.map((c) => c.code));

// Ưu đãi hạng thành viên: giảm % thẳng trên tiền hàng, áp tự động không cần nhập mã. Phải khớp
// công thức với MembershipTier.tienGiamTheoBac bên backend (làm tròn nửa lên) vì backend mới là
// nơi chốt số tiền thật. Phí ship đã được backend trừ sẵn trong shippingOptions[].fee.
const membership = ref(null);
const memberDiscountPct = computed(() => membership.value?.bacHienTai?.phanTramGiamDon || 0);
const memberDiscount = computed(() =>
  Math.round((selectedSubtotal.value * memberDiscountPct.value) / 100),
);

// Nhãn giải thích vì sao phí ship rẻ hơn niêm yết, hiện ngay dưới danh sách tuỳ chọn giao hàng.
const memberBadge = computed(() => {
  const t = membership.value?.bacHienTai;
  if (!t) return '';
  if (shippingScope.value === 'hai_phong') {
    return t.mienPhiNoiThanh ? 'Hạng ' + t.name + ': miễn phí giao hàng nội thành' : '';
  }
  if (shippingScope.value === 'carrier' && t.phanTramGiamPhiLienTinh) {
    return 'Hạng ' + t.name + ': giảm ' + t.phanTramGiamPhiLienTinh + '% phí giao liên tỉnh';
  }
  return '';
});

// ===== Tín dụng thu cũ =====
// Trừ vào phần CÒN PHẢI TRẢ (gồm cả phí ship) chứ không phải tiền hàng, vì đây là tiền shop nợ
// khách chứ không phải khuyến mãi. Backend chốt lại số thật (xem OrderService).
const dsTinDung = ref([]);
const tinDungChon = ref(null);

const tinDungDungDuoc = computed(() =>
  dsTinDung.value.filter((c) => c.dungDuoc && selectedSubtotal.value >= Number(c.donToiThieu || 0)),
);
const tinDungGiam = computed(() => {
  const c = dsTinDung.value.find((x) => x.id === tinDungChon.value);
  if (!c) return 0;
  const conPhaiTra = selectedSubtotal.value + shippingFee.value - memberDiscount.value
    - couponDiscount.value - xuDiscount.value;
  return Math.min(Number(c.soTien || 0), Math.max(0, conPhaiTra));
});

// Xu chỉ giảm được tối đa phần tiền hàng còn lại sau khi trừ hạng + coupon — khớp với cách
// backend tính (xem OrderService.datHangTuGioHang), tránh hiện số vượt quá thực tế áp dụng được.
const maxXuUsable = computed(() =>
  Math.min(
    xuBalance.value,
    Math.max(0, Math.floor((selectedSubtotal.value - memberDiscount.value - couponDiscount.value) / VND_MOI_XU_TIEU)),
  ),
);
const xuDiscount = computed(() => (useXu.value ? Math.min(xuInput.value || 0, maxXuUsable.value) * VND_MOI_XU_TIEU : 0));
const discountAmount = computed(() => memberDiscount.value + couponDiscount.value + xuDiscount.value);
const totalText = computed(() =>
  fmt(Math.max(0, selectedSubtotal.value + shippingFee.value - discountAmount.value - tinDungGiam.value)));

function toggleUseXu() {
  useXu.value = !useXu.value;
  if (useXu.value && !xuInput.value) xuInput.value = maxXuUsable.value;
}

// Gọi backend tính lại TOÀN BỘ danh sách mã (nguồn sự thật duy nhất — cộng dồn/loại trừ và giới
// hạn giảm tối đa đều do CouponService quyết định, client không tự suy ra). Nếu backend báo lỗi
// (mã không hợp lệ / không tương thích với mã đang có), NÉM LẠI lỗi cho caller và KHÔNG đụng tới
// appliedCoupons/couponTotalDiscount hiện tại — giữ nguyên trạng thái trước đó, tránh "mất trắng"
// các mã đã áp thành công chỉ vì 1 mã mới bị xung đột.
async function recomputeCoupons(codes) {
  couponError.value = '';
  if (!codes.length) {
    appliedCoupons.value = [];
    couponTotalDiscount.value = 0;
    return;
  }
  couponLoading.value = true;
  try {
    const result = await applyCoupons(codes, selectedSubtotal.value);
    appliedCoupons.value = result.coupons;
    couponTotalDiscount.value = result.totalDiscountAmount;
  } catch (e) {
    couponError.value = e?.message && !e.message.startsWith('HTTP')
      ? e.message : 'Mã giảm giá không hợp lệ hoặc không tương thích';
    throw e;
  } finally {
    couponLoading.value = false;
  }
}

// Gõ tay + bấm "Áp dụng" — thêm mã mới vào danh sách đang có.
async function onApplyCoupon() {
  couponError.value = '';
  const ma = couponInput.value.trim().toUpperCase();
  if (!ma) {
    couponError.value = 'Vui lòng nhập mã giảm giá';
    return;
  }
  if (appliedCodes.value.includes(ma)) {
    couponError.value = 'Mã này đã được áp dụng rồi';
    return;
  }
  try {
    await recomputeCoupons([...appliedCodes.value, ma]);
    couponInput.value = '';
  } catch (e) {
    // couponError đã được set trong recomputeCoupons — không cần làm gì thêm.
  }
}

// Gỡ 1 mã khỏi danh sách (giữ nguyên các mã còn lại).
async function removeCoupon(code) {
  try {
    await recomputeCoupons(appliedCodes.value.filter((c) => c !== code));
  } catch (e) {
    // Bỏ bớt mã hiếm khi gây lỗi tương thích, nhưng nếu có thì giữ nguyên trạng thái cũ.
  }
}

// Bấm/chọn 1 "vé" từ danh sách "Mã giảm giá của tôi" -> TỰ ĐỘNG kích hoạt ngay (thêm vào danh
// sách đang áp), không cần gõ tay hay xác nhận thêm bước nào.
async function onTicketApply(coupon) {
  if (appliedCodes.value.includes(coupon.code)) return;
  try {
    await recomputeCoupons([...appliedCodes.value, coupon.code]);
  } catch (e) {
    // Lỗi (vd không tương thích với mã đang chọn) đã hiển thị qua couponError.
  }
}
// Bấm lại vào 1 "vé" đang áp dụng -> bỏ chọn (toggle off).
async function onTicketRemove(coupon) {
  await removeCoupon(coupon.code);
}

async function load() {
  loading.value = true;
  myCouponsLoading.value = true;
  try {
    const [addr, methods, wallet, prov, ms] = await Promise.all([
      fetchAddresses(), fetchPaymentMethods(), fetchWallet(), fetchProvinces(), fetchMembership(),
    ]);
    fetchTinDungThuCu().then((tc) => { dsTinDung.value = tc; }).catch(() => { dsTinDung.value = []; });
    addresses.value = addr;
    paymentMethods.value = methods;
    xuBalance.value = wallet.balance;
    provinces.value = prov;
    membership.value = ms;
    fetchMyCoupons().then((c) => { myCoupons.value = c; }).catch(() => { myCoupons.value = []; }).finally(() => { myCouponsLoading.value = false; });
    if (addresses.value.length) {
      const def = addresses.value.find((a) => a.isDefault) || addresses.value[0];
      selectedAddressId.value = def.id;
      await loadShippingOptions();
    } else {
      showNewAddress.value = true;
    }
  } finally {
    loading.value = false;
  }
}

async function saveNewAddress() {
  error.value = '';
  if (!form.value.provinceId || !form.value.wardId) {
    error.value = 'Vui lòng chọn Tỉnh/Thành và Phường/Xã';
    return;
  }
  if (!toaDo.value) {
    error.value = 'Vui lòng cắm mốc vị trí giao hàng trên bản đồ';
    return;
  }
  try {
    const a = await createAddress({
      ...form.value, latitude: toaDo.value.lat, longitude: toaDo.value.lng,
    });
    addresses.value.push(a);
    selectedAddressId.value = a.id;
    showNewAddress.value = false;
    await loadShippingOptions();
  } catch (e) {
    error.value = e?.message || 'Có lỗi khi lưu địa chỉ';
  }
}

async function submit() {
  if (!selectedAddressId.value) {
    error.value = 'Vui lòng chọn địa chỉ giao hàng';
    return;
  }
  error.value = '';
  placing.value = true;
  // Dùng lại overlay loading toàn trang có sẵn (đã dùng cho mọi lượt chuyển trang) thay vì tự
  // vẽ 1 spinner riêng cho bước này — đặt đơn hàng cũng là 1 khoảng chờ mạng thật, cùng bản chất.
  state.loading = true;
  state.loadingMsg = 'Đang xử lý đơn hàng...';
  try {
    const xuToUse = useXu.value ? Math.min(xuInput.value || 0, maxXuUsable.value) : 0;
    const result = await placeOrder(selectedAddressId.value, selectedMethod.value, state.selectedCartItemIds, appliedCodes.value, xuToUse, selectedShippingCode.value, tinDungChon.value);
    await actions.refreshCart();
    if (result.redirectUrl) {
      // Stripe Checkout chỉ hỗ trợ redirect toàn trang, không nhúng iframe. Hàng trong giỏ
      // chưa bị xoá lúc này (chỉ xoá khi thanh toán thành công, xem OrderService), nên nếu
      // huỷ giữa chừng và quay lại giỏ hàng thì sản phẩm vẫn còn nguyên.
      window.location.href = result.redirectUrl;
      return;
    }
    state.returnOrderId = result.order.id;
    state.returnPaymentStatus = null;
    actions.goOrderResult();
  } catch (e) {
    error.value = e?.message || 'Đặt hàng thất bại';
  } finally {
    placing.value = false;
    state.loading = false;
  }
}

onMounted(load);
</script>

<template>
  <main style="max-width: 1100px; margin: 0 auto; padding: 24px 24px 64px">
    <button
      @click="actions.goCart"
      style="display: inline-flex; align-items: center; gap: 6px; background: transparent; border: 1px solid rgba(var(--line-rgb),0.2); color: var(--muted); border-radius: 9px; padding: 8px 14px; font-size: 13px; cursor: pointer; margin-bottom: 28px; font-family: 'Plus Jakarta Sans', sans-serif"
    >
      ← Quay lại giỏ hàng
    </button>

    <h1 style="font-family: 'Plus Jakarta Sans', sans-serif; font-weight: 800; font-size: 30px; margin: 0 0 24px; color: var(--text)">
      Xác nhận đặt hàng
    </h1>

    <div v-if="loading" style="color: var(--muted); padding: 40px; text-align: center">Đang tải...</div>

    <div v-else style="display: grid; grid-template-columns: 1fr 360px; gap: 20px; align-items: start">
      <div style="display: flex; flex-direction: column; gap: 16px">
        <!-- Địa chỉ -->
        <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 20px">
          <div style="font-size: 13.5px; font-weight: 700; color: var(--text); margin-bottom: 14px">Địa chỉ giao hàng</div>

          <div v-for="a in addresses" :key="a.id"
            @click="selectAddress(a.id)"
            style="display: flex; gap: 10px; padding: 12px; border-radius: 10px; cursor: pointer; margin-bottom: 8px; transition: border-color 0.15s ease, background 0.15s ease"
            :style="{ border: '1px solid ' + (selectedAddressId === a.id ? accent : 'rgba(var(--line-rgb),0.16)'), background: selectedAddressId === a.id ? 'color-mix(in srgb, ' + accent + ' 6%, transparent)' : 'transparent' }">
            <input type="radio" :checked="selectedAddressId === a.id" style="margin-top: 3px" readonly />
            <div style="font-size: 13px">
              <strong style="color: var(--text)">{{ a.tenNguoiNhan }}</strong>
              <span style="color: var(--muted)"> — {{ a.soDienThoai }}</span>
              <span v-if="a.isDefault" style="margin-left: 8px; font-size: 10.5px; background: var(--acc,#c6ff4a); color: var(--acc-ink); padding: 2px 7px; border-radius: 10px; font-weight: 700">MẶC ĐỊNH</span>
              <div style="color: var(--muted2); margin-top: 3px">{{ a.diaChiDayDu }}</div>
            </div>
          </div>

          <button v-if="!showNewAddress" @click="showNewAddress = true"
            style="margin-top: 6px; background: transparent; border: 1px dashed rgba(var(--line-rgb),0.3); color: var(--muted2); border-radius: 9px; padding: 9px 14px; cursor: pointer; font-size: 12.5px">
            + Thêm địa chỉ mới
          </button>

          <Transition name="dropdown-fade">
          <div v-if="showNewAddress" style="margin-top: 12px; display: grid; grid-template-columns: 1fr 1fr; gap: 10px">
            <!-- Chọn cách nhập: gõ địa chỉ rồi xác nhận bằng mốc, hoặc chỉ thả ghim và để hệ
                 thống tự tra ngược ra địa chỉ chữ -->
            <div style="grid-column: 1 / -1; display: flex; gap: 8px">
              <button
                type="button" @click="cheDoNhap = 'nhap'"
                :style="{ borderColor: cheDoNhap === 'nhap' ? accent : 'rgba(var(--line-rgb),0.2)', color: cheDoNhap === 'nhap' ? 'var(--text)' : 'var(--muted2)' }"
                style="flex: 1; height: 36px; border: 1px solid; background: transparent; border-radius: 9px; font-size: 12.5px; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif"
              >
                Nhập địa chỉ + cắm mốc
              </button>
              <button
                type="button" @click="cheDoNhap = 'mocDiem'"
                :style="{ borderColor: cheDoNhap === 'mocDiem' ? accent : 'rgba(var(--line-rgb),0.2)', color: cheDoNhap === 'mocDiem' ? 'var(--text)' : 'var(--muted2)' }"
                style="flex: 1; height: 36px; border: 1px solid; background: transparent; border-radius: 9px; font-size: 12.5px; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif"
              >
                Cắm mốc + chọn Tỉnh/Phường
              </button>
            </div>

            <input v-model="form.tenNguoiNhan" placeholder="Tên người nhận" style="height: 40px; padding: 0 12px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 13px" />
            <input v-model="form.soDienThoai" placeholder="Số điện thoại" style="height: 40px; padding: 0 12px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 13px" />
            <input v-model="form.diaChiCuThe" :placeholder="cheDoNhap === 'mocDiem' ? 'Số nhà, đường (tự điền từ bản đồ)' : 'Số nhà, đường'" style="grid-column: 1 / -1; height: 40px; padding: 0 12px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 13px" />
            <select v-model.number="form.provinceId" @change="onFormProvinceChange"
              style="height: 40px; padding: 0 12px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 13px; cursor: pointer">
              <option :value="null" disabled>Tỉnh/Thành phố</option>
              <option v-for="p in provinces" :key="p.id" :value="p.id">{{ p.name }}</option>
            </select>
            <select v-model.number="form.wardId" :disabled="!form.provinceId || loadingWards"
              style="height: 40px; padding: 0 12px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 13px; cursor: pointer">
              <option :value="null" disabled>{{ loadingWards ? 'Đang tải...' : 'Phường/Xã' }}</option>
              <option v-for="w in wardsForForm" :key="w.id" :value="w.id">{{ w.name }}</option>
            </select>
            <!-- Cắm mốc bắt buộc: phí giao nội thành Hải Phòng tính theo quãng đường thật từ
                 kho tới đúng điểm này (xem ShippingService), và shipper dùng nó để tìm nhà -->
            <div style="grid-column: 1 / -1">
              <MapPicker v-model="toaDo" @reverse="onPinMoved" />
              <div v-if="dangTraNguoc" style="font-size: 11.5px; color: var(--muted); margin-top: 6px">
                Đang tra địa chỉ từ vị trí đã cắm...
              </div>
              <div v-else-if="goiYDiaChi" style="font-size: 11.5px; color: var(--muted2); margin-top: 6px; line-height: 1.5">
                Vị trí đã cắm: {{ goiYDiaChi }}
              </div>
            </div>

            <div style="grid-column: 1 / -1; display: flex; gap: 10px">
              <button @click="saveNewAddress" style="height: 38px; padding: 0 16px; border: none; border-radius: 9px; background: var(--acc,#c6ff4a); color: var(--acc-ink); font-weight: 700; cursor: pointer; font-size: 12.5px">Lưu địa chỉ</button>
              <button v-if="addresses.length" @click="showNewAddress = false" style="height: 38px; padding: 0 16px; border: 1px solid rgba(var(--line-rgb),0.2); border-radius: 9px; background: transparent; color: var(--muted2); cursor: pointer; font-size: 12.5px">Hủy</button>
            </div>
          </div>
          </Transition>
        </div>

        <!-- Tuỳ chọn giao hàng -->
        <div v-if="shippingLoading || shippingOptions.length" style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 20px">
          <div style="display: flex; align-items: baseline; justify-content: space-between; gap: 10px; margin-bottom: 14px">
            <div style="font-size: 13.5px; font-weight: 700; color: var(--text)">
              {{ shippingScope === 'hai_phong' ? 'Tốc độ giao hàng' : 'Đơn vị vận chuyển' }}
            </div>
            <div v-if="shippingDistanceKm != null" style="font-size: 11.5px; color: var(--muted2); flex: none">
              Cách kho {{ shippingDistanceKm }} km
            </div>
          </div>
          <div v-if="shippingLoading" style="color: var(--muted); font-size: 12.5px">Đang tải...</div>
          <div v-else v-for="o in shippingOptions" :key="o.code"
            @click="selectedShippingCode = o.code"
            style="display: flex; align-items: center; justify-content: space-between; gap: 10px; padding: 12px; border-radius: 10px; cursor: pointer; margin-bottom: 8px; transition: border-color 0.15s ease, background 0.15s ease"
            :style="{ border: '1px solid ' + (selectedShippingCode === o.code ? accent : 'rgba(var(--line-rgb),0.16)'), background: selectedShippingCode === o.code ? 'color-mix(in srgb, ' + accent + ' 6%, transparent)' : 'transparent' }">
            <div style="display: flex; align-items: center; gap: 10px">
              <input type="radio" :checked="selectedShippingCode === o.code" readonly />
              <div style="font-size: 13px">
                <span style="color: var(--text); font-weight: 600">{{ o.label }}</span>
                <div style="color: var(--muted2); font-size: 11.5px; margin-top: 2px">{{ o.eta }}</div>
              </div>
            </div>
            <!-- fee đã trừ ưu đãi hạng thành viên (backend tính, xem ShippingService) — khác
                 feeGoc thì gạch ngang giá niêm yết để khách thấy phần được giảm -->
            <span style="display: flex; align-items: baseline; gap: 7px; flex: none">
              <span v-if="o.feeGoc > o.fee" style="color: var(--muted); font-size: 11.5px; text-decoration: line-through">{{ fmt(o.feeGoc) }}</span>
              <span :style="{ color: o.feeGoc > o.fee ? 'var(--green)' : 'var(--text)' }" style="font-size: 13px; font-weight: 600">
                {{ o.fee > 0 ? fmt(o.fee) : 'Miễn phí' }}
              </span>
            </span>
          </div>
          <div v-if="memberBadge" style="font-size: 11.5px; color: var(--green); margin-top: 4px">
            ✓ {{ memberBadge }}
          </div>
        </div>

        <!-- Phương thức thanh toán -->
        <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 20px">
          <div style="font-size: 13.5px; font-weight: 700; color: var(--text); margin-bottom: 14px">Phương thức thanh toán</div>
          <div v-for="m in paymentMethods" :key="m.code"
            @click="selectedMethod = m.code"
            style="display: flex; align-items: center; gap: 10px; padding: 12px; border-radius: 10px; cursor: pointer; margin-bottom: 8px; transition: border-color 0.15s ease, background 0.15s ease"
            :style="{ border: '1px solid ' + (selectedMethod === m.code ? accent : 'rgba(var(--line-rgb),0.16)'), background: selectedMethod === m.code ? 'color-mix(in srgb, ' + accent + ' 6%, transparent)' : 'transparent' }">
            <input type="radio" :checked="selectedMethod === m.code" readonly />
            <span style="font-size: 13px; color: var(--text)">{{ m.name }}</span>
          </div>
          <div v-if="selectedMethod === 'banking'" style="font-size: 12px; color: var(--muted2); margin-top: 8px">
            Sau khi đặt hàng, bạn sẽ chuyển khoản theo thông tin hiển thị và nộp ảnh biên lai để admin đối soát.
            Đơn hàng được giữ trong vòng 24 giờ chờ thanh toán.
          </div>
          <div v-else-if="selectedMethod === 'stripe_card'" style="font-size: 12px; color: var(--muted2); margin-top: 8px">
            Bạn sẽ được chuyển tới trang thanh toán Stripe an toàn để nhập thông tin thẻ. Đơn hàng được giữ trong vòng 24 giờ chờ thanh toán.
          </div>
          <div v-else-if="selectedMethod === 'vnpay'" style="font-size: 12px; color: var(--muted2); margin-top: 8px">
            Bạn sẽ được chuyển tới trang thanh toán VNPay để quét QR/thẻ ATM nội địa/thẻ quốc tế. Đơn hàng được giữ trong vòng 24 giờ chờ thanh toán.
          </div>
        </div>
      </div>

      <!-- Tóm tắt -->
      <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 20px; position: sticky; top: 100px">
        <!-- Phần thanh toán đặt TRÊN CÙNG (trên cả mã giảm giá): số tiền phải trả và nút đặt
             hàng là thứ khách cần thấy ngay, không phải cuộn qua mã giảm giá/Xu mới tới. Các
             khối ưu đãi bên dưới vẫn cập nhật trực tiếp vào con số này. -->
        <div style="display: flex; justify-content: space-between; font-size: 13px; color: var(--muted2); margin-bottom: 8px">
          <span>Tiền hàng</span><span>{{ subtotalText }}</span>
        </div>
        <div style="display: flex; justify-content: space-between; font-size: 13px; color: var(--muted2); margin-bottom: 8px">
          <span>Phí vận chuyển</span><span>{{ fmt(shippingFee) }}</span>
        </div>
        <div v-if="memberDiscount" style="display: flex; justify-content: space-between; font-size: 13px; color: var(--green); margin-bottom: 8px">
          <span>Ưu đãi hạng {{ membership.bacHienTai.name }} ({{ memberDiscountPct }}%)</span>
          <span>-{{ fmt(memberDiscount) }}</span>
        </div>
        <div v-if="couponDiscount + xuDiscount" style="display: flex; justify-content: space-between; font-size: 13px; color: var(--green); margin-bottom: 8px">
          <span>Giảm giá</span><span>-{{ fmt(couponDiscount + xuDiscount) }}</span>
        </div>
        <div v-if="tinDungGiam" style="display: flex; justify-content: space-between; font-size: 13px; color: var(--green); margin-bottom: 8px">
          <span>Tín dụng thu cũ</span><span>-{{ fmt(tinDungGiam) }}</span>
        </div>
        <div style="display: flex; justify-content: space-between; font-size: 15px; font-weight: 700; margin-top: 10px">
          <span style="color: var(--text)">Tổng cộng</span>
          <span style="color: var(--acc,#c6ff4a)">{{ totalText }}</span>
        </div>

        <div v-if="error" style="margin-top: 12px; font-size: 12.5px; color: var(--sale)">{{ error }}</div>

        <button @click="submit" :disabled="placing"
          style="width: 100%; height: 48px; border: none; border-radius: 11px; background: var(--acc,#c6ff4a); color: var(--acc-ink); font-weight: 700; cursor: pointer; margin-top: 16px; font-size: 14px">
          {{ placing ? 'Đang xử lý...' : 'Đặt hàng' }}
        </button>

        <div style="height: 1px; background: rgba(var(--line-rgb),0.14); margin: 18px 0"></div>

        <div style="font-size: 13.5px; font-weight: 700; color: var(--text); margin-bottom: 14px">Đơn hàng của bạn</div>
        <div v-for="c in selectedLines" :key="c.id" style="display: flex; justify-content: space-between; gap: 10px; font-size: 12.5px; padding: 5px 0; color: var(--muted2)">
          <span>
            {{ c.productName }} x{{ c.quantity }}
            <!-- Cấu hình biến thể: 2 dòng cùng sản phẩm chỉ khác nhau ở đây (xem CartView). -->
            <span v-if="c.optionsText || c.sku" style="display: block; font-size: 11px; color: var(--muted)">
              {{ c.optionsText || c.sku }}
            </span>
          </span>
          <span style="white-space: nowrap">{{ fmt(c.lineTotal) }}</span>
        </div>
        <div style="height: 1px; background: rgba(var(--line-rgb),0.14); margin: 12px 0"></div>

        <!-- Mã giảm giá — cho phép chọn NHIỀU mã cùng lúc, bấm/chọn 1 vé là TỰ ĐỘNG kích hoạt
             ngay (xem MyCouponTickets: @apply/@remove toggle theo appliedCodes). -->
        <div style="margin-bottom: 12px">
          <MyCouponTickets
            :coupons="myCoupons" :loading="myCouponsLoading" :applied-codes="appliedCodes" title="" hide-when-empty
            @apply="onTicketApply" @remove="onTicketRemove"
          />
          <div style="display: flex; gap: 8px; margin-top: 8px">
            <input
              v-model="couponInput" placeholder="Nhập thêm mã giảm giá" @keyup.enter="onApplyCoupon"
              style="flex: 1; height: 38px; padding: 0 11px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 8px; color: var(--text); font-size: 12.5px; text-transform: uppercase"
            />
            <button
              @click="onApplyCoupon" :disabled="couponLoading"
              style="height: 38px; padding: 0 14px; border: 1px solid rgba(var(--line-rgb),0.22); background: transparent; border-radius: 8px; color: var(--muted2); font-size: 12px; cursor: pointer; flex: none"
            >
              {{ couponLoading ? '...' : 'Áp dụng' }}
            </button>
          </div>
          <div v-if="couponError" style="font-size: 11.5px; color: var(--sale); margin-top: 6px">{{ couponError }}</div>

          <!-- Danh sách mã đang áp dụng — gỡ từng mã riêng lẻ, các mã còn lại giữ nguyên. -->
          <div v-if="appliedCoupons.length" style="margin-top: 10px; display: flex; flex-direction: column; gap: 6px">
            <div
              v-for="c in appliedCoupons" :key="c.code"
              style="display: flex; justify-content: space-between; align-items: center; font-size: 12.5px; background: var(--card2); padding: 7px 10px; border-radius: 7px"
            >
              <span style="color: var(--green)">
                ✓ "{{ c.code }}" <span style="color: var(--muted2)">(-{{ fmt(c.discountAmount) }})</span>
              </span>
              <a href="#" @click.prevent="removeCoupon(c.code)" style="color: var(--muted); text-decoration: none; font-size: 11.5px">Gỡ</a>
            </div>
          </div>
        </div>

        <!-- Dùng Xu CT giảm trực tiếp vào bill -->
        <div v-if="xuBalance > 0" style="margin-bottom: 12px; padding: 10px; background: var(--card2); border-radius: 9px">
          <div style="display: flex; align-items: center; justify-content: space-between; gap: 8px">
            <label style="display: flex; align-items: center; gap: 8px; font-size: 12.5px; color: var(--text); cursor: pointer">
              <input type="checkbox" :checked="useXu" @change="toggleUseXu" style="accent-color: var(--acc,#c6ff4a)" />
              🪙 Dùng Xu CT giảm giá
            </label>
            <span style="font-size: 11.5px; color: var(--muted2)">Có {{ xuBalance }} xu</span>
          </div>
          <div v-if="useXu" style="display: flex; align-items: center; gap: 8px; margin-top: 8px">
            <input
              v-model.number="xuInput" type="number" min="0" :max="maxXuUsable"
              style="flex: 1; height: 34px; padding: 0 10px; background: var(--card); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 7px; color: var(--text); font-size: 12.5px"
            />
            <span style="font-size: 11.5px; color: var(--muted2); white-space: nowrap">tối đa {{ maxXuUsable }} xu</span>
          </div>
        </div>

        <!-- Tín dụng thu cũ: chỉ hiện khi khách thực sự có tín dụng dùng được cho đơn này -->
        <div v-if="tinDungDungDuoc.length" style="margin-bottom: 12px; padding: 10px; background: var(--card2); border-radius: 9px">
          <div style="font-size: 12.5px; color: var(--text); font-weight: 600; margin-bottom: 7px">♻️ Tín dụng thu cũ</div>
          <label
            v-for="c in tinDungDungDuoc" :key="c.id"
            style="display: flex; align-items: flex-start; gap: 8px; font-size: 12px; color: var(--muted2); cursor: pointer; margin-bottom: 5px"
          >
            <input type="radio" :value="c.id" v-model="tinDungChon" style="margin-top: 2px; accent-color: var(--acc,#c6ff4a)" />
            <span>
              <b style="color: var(--green)">{{ fmt(c.soTien) }}</b>
              <span v-if="c.moTaThietBi"> — {{ c.moTaThietBi }}</span>
              <span v-if="c.hetHan" style="display: block; font-size: 11px; color: var(--muted)">
                Hạn dùng {{ new Date(c.hetHan).toLocaleDateString('vi-VN') }}
              </span>
            </span>
          </label>
          <a
            v-if="tinDungChon" href="#" @click.prevent="tinDungChon = null"
            style="font-size: 11.5px; color: var(--muted); text-decoration: none"
          >Bỏ chọn</a>
          <div style="font-size: 11px; color: var(--muted); margin-top: 4px; line-height: 1.5">
            Dùng một lần, không hoàn phần dư.
          </div>
        </div>

      </div>
    </div>
  </main>
</template>
