<template>
  <div class="pos">
    <!-- HEADER -->
    <header class="topbar">
      <div class="brand">
        <div class="logo">P</div>
        <div class="name">POS Bán hàng</div>
      </div>
      <div class="actions">
        <button class="ghost" @click="moUuDai">🎁 Ưu đãi</button>
        <button class="ghost" @click="$router.push('/tra-cuu')">🔎 Tra cứu &amp; Bảo hành</button>
        <button class="ghost" @click="openDisplay">Màn hình khách ↗</button>
        <button class="ghost" @click="logout">Đăng xuất</button>
      </div>
    </header>

    <div class="body">
      <!-- LEFT: search + cart -->
      <div class="left">
        <div class="search-wrap">
          <input
            ref="searchEl"
            class="search"
            v-model="query"
            @input="onQuery"
            @keydown.enter.prevent="onEnter"
            @keydown.esc="showResults = false"
            placeholder="Quét mã vạch hoặc tìm sản phẩm / SKU…  (Enter để thêm)"
          />
          <div v-if="showResults && results.length" class="dropdown">
            <div v-for="r in results" :key="r.variantId" class="res" @click="addProduct(r)">
              <div class="thumb" :style="{ backgroundImage: `url(${imgUrl(r.imageUrl)})` }"></div>
              <div class="res-info">
                <div class="res-name">{{ r.productName }}</div>
                <div class="res-sub">SKU {{ r.sku }} · Tồn {{ r.stock }}</div>
              </div>
              <div class="res-price">{{ fmt(r.gia) }}</div>
            </div>
          </div>
          <div v-else-if="searched && query.trim() && !results.length" class="dropdown empty">
            Không tìm thấy sản phẩm.
          </div>
        </div>

        <div class="cart">
          <div class="cart-head">
            <div>Sản phẩm</div>
            <div class="c">Số lượng</div>
            <div class="r">Đơn giá</div>
            <div class="r">Thành tiền</div>
            <div></div>
          </div>
          <div class="cart-body">
            <div v-if="!cart.length" class="cart-empty">
              <div class="ce-t">Giỏ hàng trống</div>
              <div class="ce-s">Quét mã hoặc tìm sản phẩm để bắt đầu</div>
            </div>
            <div v-for="it in cart" :key="it.variantId" class="row">
              <div class="prod">
                <div class="thumb" :style="{ backgroundImage: `url(${imgUrl(it.imageUrl)})` }"></div>
                <div class="prod-info">
                  <div class="prod-name">{{ it.productName }}</div>
                  <div class="prod-sub">SKU {{ it.sku }} · Tồn {{ it.stock }}</div>
                </div>
              </div>
              <div class="qty">
                <button class="step" @click="changeQty(it.variantId, -1)">−</button>
                <div class="qn tnum">{{ it.soLuong }}</div>
                <button class="step" @click="changeQty(it.variantId, 1)">+</button>
              </div>
              <div class="r tnum muted">{{ fmt(it.gia) }}</div>
              <div class="r tnum bold">{{ fmt(it.gia * it.soLuong) }}</div>
              <div class="c"><button class="del" @click="removeItem(it.variantId)">✕</button></div>
            </div>
          </div>
        </div>
      </div>

      <!-- RIGHT: customer / discounts / payment / summary -->
      <aside class="right">
        <!-- Khách hàng -->
        <div>
          <div class="section-label">Khách hàng</div>
          <input class="field" v-model="phone" @input="onPhone" inputmode="numeric" placeholder="Số điện thoại khách" />
          <div v-if="custErr" class="mini-err">{{ custErr }}</div>

          <div v-if="customer && !customer.moi" class="cust-box">
            <div class="cust-top">
              <div class="cust-name">{{ customer.hoTen }}</div>
              <div class="cust-tier">{{ customer.hangThanhVien }}</div>
            </div>
            <div class="cust-meta">
              <div><b>{{ customer.xuHienCo || 0 }}</b> Xu</div>
              <div>Giảm hạng <b>{{ customer.phanTramGiamHang || 0 }}%</b></div>
            </div>
          </div>
          <div v-else-if="customer && customer.moi" class="cust-new">
            <div class="new-lbl">Khách mới — nhập tên để tạo khi chốt đơn</div>
            <input class="field" v-model="newName" placeholder="Họ tên khách" />
          </div>
        </div>

        <!-- Khuyến mãi -->
        <div>
          <div class="section-label">Khuyến mãi</div>
          <div class="coupon">
            <input class="field upper" v-model="couponCode" placeholder="Mã coupon" />
            <button class="apply" @click="applyCoupon">Áp dụng</button>
          </div>
          <div v-if="couponMsg" class="mini" :style="{ color: couponOk ? 'var(--green)' : 'var(--sale)' }">{{ couponMsg }}</div>

          <div class="xu-row">
            <div class="xu-lbl">Dùng Xu <span class="dim">(tối đa {{ xuMax }})</span></div>
            <input class="xu-input tnum" type="number" min="0" :max="xuMax" v-model.number="xu" @input="clampXu" />
          </div>
          <div class="dim sm">1 Xu = 1.000đ</div>
        </div>

        <!-- Thanh toán -->
        <div>
          <div class="section-label">Thanh toán</div>
          <div class="pm">
            <button
              v-for="m in methods"
              :key="m.ma"
              class="pm-btn"
              :class="{ on: payment === m.ma }"
              @click="payment = m.ma"
            >{{ m.ten }}</button>
          </div>
        </div>

        <!-- Tổng kết -->
        <div class="summary">
          <div class="sum-row"><span>Tiền hàng</span><span class="tnum">{{ fmt(t.tienHang) }}</span></div>
          <div v-if="t.memberGiam > 0" class="sum-row green"><span>Giảm hạng {{ t.pct }}%</span><span class="tnum">−{{ fmt(t.memberGiam) }}</span></div>
          <div v-if="t.couponGiam > 0" class="sum-row green"><span>Coupon</span><span class="tnum">−{{ fmt(t.couponGiam) }}</span></div>
          <div v-if="t.xuGiam > 0" class="sum-row green"><span>Dùng {{ xu }} Xu</span><span class="tnum">−{{ fmt(t.xuGiam) }}</span></div>
          <div class="divider"></div>
          <div class="total-row"><span>Tổng thanh toán</span><span class="total tnum">{{ fmt(t.tong) }}</span></div>
          <div class="dim sm end">Số tiền cuối cùng do máy chủ xác nhận</div>
        </div>

        <div v-if="placeErr" class="mini-err">{{ placeErr }}</div>

        <button class="checkout" :disabled="!canCheckout" @click="placeOrder">
          {{ placing ? 'Đang xử lý…' : 'Chốt đơn  (F9)' }}
        </button>
      </aside>
    </div>

    <!-- INVOICE MODAL -->
    <div v-if="invoice" class="modal">
      <div class="inv">
        <div class="inv-head">
          <div class="inv-title"><span>✓</span> Chốt đơn thành công</div>
          <div class="inv-sub">Mã đơn {{ invoice.maDonHang }} · {{ invoice.thoiGian }}</div>
        </div>
        <div class="inv-body">
          <div v-if="invPending" class="pending">
            <div class="pending-lbl">Quét QR để thanh toán</div>
            <div class="qr" :style="{ backgroundImage: `url(${qrFor(invoice.urlThanhToan)})` }"></div>
            <button class="paid" @click="markPaid">Khách đã thanh toán</button>
          </div>
          <div class="inv-line"><span class="muted">Khách</span><b>{{ invoice.tenKhach }} · {{ invoice.soDienThoai }}</b></div>
          <div class="inv-line"><span class="muted">Thanh toán</span><b>{{ invoice.phuongThucThanhToan }} · {{ invoice.trangThaiThanhToan }}</b></div>
          <div class="inv-line"><span class="muted">Xu nhận được</span><b class="blue">+{{ invoice.xuNhanDuoc }}</b></div>
          <div class="divider"></div>
          <div v-for="(l, i) in invoice.dongHang" :key="i" class="inv-line">
            <span>{{ l.tenSanPham }} <span class="muted">×{{ l.soLuong }}</span></span>
            <span class="tnum">{{ fmt(l.thanhTien) }}</span>
          </div>
          <div class="divider"></div>
          <div class="inv-line muted"><span>Tiền hàng</span><span class="tnum">{{ fmt(invoice.tienHang) }}</span></div>
          <div class="inv-line green"><span>Giảm giá</span><span class="tnum">−{{ fmt(invoice.tienGiamGia) }}</span></div>
          <div class="total-row big"><span>Tổng</span><span class="total tnum">{{ fmt(invoice.tongTien) }}</span></div>
        </div>
        <div class="inv-foot">
          <button class="print" @click="printInvoice">In hoá đơn</button>
          <button class="new" @click="newSale">Đơn mới</button>
        </div>
      </div>
    </div>

    <!-- HOÁ ĐƠN IN 80mm -->
    <div id="print-invoice" v-if="invoice">
      <div style="text-align:center;margin-bottom:6px">
        <div style="font-size:15px;font-weight:bold">POS SHOP</div>
        <div style="font-size:10px">HOÁ ĐƠN BÁN HÀNG</div>
      </div>
      <div style="font-size:10px;border-top:1px dashed #000;border-bottom:1px dashed #000;padding:4px 0;margin-bottom:4px">
        <div>Mã đơn: {{ invoice.maDonHang }}</div>
        <div>Thời gian: {{ invoice.thoiGian }}</div>
        <div>Khách: {{ invoice.tenKhach }} - {{ invoice.soDienThoai }}</div>
      </div>
      <div v-for="(l, i) in invoice.dongHang" :key="i" style="font-size:11px;margin-bottom:2px">
        <div>{{ l.tenSanPham }}</div>
        <div style="display:flex;justify-content:space-between">
          <span>{{ l.soLuong }} x {{ fmt(l.donGia) }}</span><span>{{ fmt(l.thanhTien) }}</span>
        </div>
      </div>
      <div style="border-top:1px dashed #000;margin-top:4px;padding-top:4px;font-size:11px">
        <div style="display:flex;justify-content:space-between"><span>Tiền hàng</span><span>{{ fmt(invoice.tienHang) }}</span></div>
        <div style="display:flex;justify-content:space-between"><span>Giảm giá</span><span>-{{ fmt(invoice.tienGiamGia) }}</span></div>
        <div style="display:flex;justify-content:space-between;font-weight:bold;font-size:13px;margin-top:2px"><span>TỔNG</span><span>{{ fmt(invoice.tongTien) }}</span></div>
        <div style="display:flex;justify-content:space-between;margin-top:2px"><span>TT</span><span>{{ invoice.phuongThucThanhToan }} - {{ invoice.trangThaiThanhToan }}</span></div>
        <div style="display:flex;justify-content:space-between"><span>Xu nhận</span><span>+{{ invoice.xuNhanDuoc }}</span></div>
      </div>
      <div style="text-align:center;font-size:10px;margin-top:8px;border-top:1px dashed #000;padding-top:6px">Cảm ơn quý khách!</div>
    </div>

    <!-- ===== Thanh ưu đãi bên phải: ẩn sẵn, trượt ra khi bấm nút "Ưu đãi" ===== -->
    <div v-if="uuDaiMo" class="uud-backdrop" @click="uuDaiMo = false"></div>
    <aside class="uud" :class="{ open: uuDaiMo }">
      <div class="uud-head">
        <span>Ưu đãi &amp; Khuyến mãi</span>
        <button class="uud-x" @click="uuDaiMo = false" aria-label="Đóng">×</button>
      </div>

      <div class="uud-tabs">
        <button :class="{ on: uuDaiTab === 'khuyenMai' }" @click="uuDaiTab = 'khuyenMai'">
          Khuyến mãi <b v-if="uuDai.khuyenMai.length">{{ uuDai.khuyenMai.length }}</b>
        </button>
        <button :class="{ on: uuDaiTab === 'tangKem' }" @click="uuDaiTab = 'tangKem'">
          Tặng kèm <b v-if="uuDai.tangKem.length">{{ uuDai.tangKem.length }}</b>
        </button>
        <button :class="{ on: uuDaiTab === 'coupon' }" @click="uuDaiTab = 'coupon'">
          Coupon <b v-if="uuDai.coupon.length">{{ uuDai.coupon.length }}</b>
        </button>
        <button :class="{ on: uuDaiTab === 'chuongTrinh' }" @click="uuDaiTab = 'chuongTrinh'">
          Chương trình
        </button>
      </div>

      <div class="uud-body">
        <div v-if="uuDaiLoading" class="uud-empty">Đang tải...</div>

        <template v-else-if="uuDaiTab === 'khuyenMai'">
          <div v-if="!uuDai.khuyenMai.length" class="uud-empty">
            Sản phẩm trong đơn chưa có chương trình khuyến mãi nào.
          </div>
          <div v-for="(k, i) in uuDai.khuyenMai" :key="i" class="uud-card">
            <div class="uud-sp">{{ k.tenSanPham }}</div>
            <div class="uud-nd">🎯 {{ k.noiDung }}</div>
          </div>
        </template>

        <template v-else-if="uuDaiTab === 'tangKem'">
          <div v-if="!uuDai.tangKem.length" class="uud-empty">
            Sản phẩm trong đơn chưa có hàng tặng kèm.
          </div>
          <div v-for="(t, i) in uuDai.tangKem" :key="i" class="uud-card">
            <div class="uud-sp">{{ t.tenSanPhamChinh }}</div>
            <div class="uud-tk">
              <img v-if="t.imageUrl" :src="imgUrl(t.imageUrl)" class="uud-img" />
              <div style="flex:1;min-width:0">
                <div class="uud-nd">🎁 {{ t.tenSanPhamTang }}</div>
                <div v-if="t.gia" class="uud-gia tnum">Trị giá {{ fmt(t.gia) }}</div>
              </div>
            </div>
          </div>
        </template>

        <template v-else-if="uuDaiTab === 'coupon'">
          <div v-if="!uuDai.coupon.length" class="uud-empty">Không có mã giảm giá nào đang chạy.</div>
          <div v-for="c in uuDai.coupon" :key="c.ma" class="uud-card uud-cp" @click="dungCoupon(c.ma)">
            <div class="uud-ma tnum">{{ c.ma }}</div>
            <div class="uud-nd">
              Giảm {{ c.loaiGiam === 'percent' ? c.giaTriGiam + '%' : fmt(c.giaTriGiam) }}
              <span v-if="c.donToiThieu > 0"> · đơn từ {{ fmt(c.donToiThieu) }}</span>
            </div>
            <div class="uud-gia">
              <span v-if="c.soLuotConLai != null">Còn {{ c.soLuotConLai }} lượt</span>
              <span v-else>Không giới hạn lượt</span>
              · Bấm để áp mã
            </div>
          </div>
        </template>

        <!-- ===== Chương trình ở tầm cửa hàng ===== -->
        <template v-else>
          <!-- Flash Sale đang chạy -->
          <div class="uud-nhom">⚡ Flash Sale</div>
          <div v-if="!uuDai.flashSale" class="uud-empty">Hiện không có đợt Flash Sale nào đang chạy.</div>
          <template v-else>
            <div class="uud-card">
              <div class="uud-sp">{{ uuDai.flashSale.tieuDe || 'Flash Sale' }}</div>
              <div class="uud-gia">Kết thúc {{ gioNgay(uuDai.flashSale.ketThucLuc) }}</div>
            </div>
            <div v-for="it in uuDai.flashSale.sanPham" :key="it.variantId" class="uud-card">
              <div class="uud-nd">{{ it.tenSanPham }}</div>
              <div class="uud-gia tnum">
                <b style="color:#c6ff4a">{{ fmt(it.giaSale) }}</b>
                <s style="margin-left:6px">{{ fmt(it.giaGoc) }}</s>
                <span v-if="it.phanTramGiam"> · -{{ it.phanTramGiam }}%</span>
                <span v-if="it.soLuongConLai != null"> · còn {{ it.soLuongConLai }}</span>
              </div>
            </div>
          </template>

          <!-- Hạng thành viên tích luỹ -->
          <div class="uud-nhom">🏅 Hạng thành viên (tích luỹ theo chi tiêu)</div>
          <div v-for="h in uuDai.hangThanhVien" :key="h.ten" class="uud-card">
            <div class="uud-sp">{{ h.ten }}</div>
            <div class="uud-nd">{{ h.moTa }}</div>
            <div class="uud-gia tnum" v-if="h.mucChiToiThieu > 0">Đạt khi đã mua từ {{ fmt(h.mucChiToiThieu) }}</div>
          </div>

          <!-- Gói hội viên trả phí -->
          <div class="uud-nhom">💳 Gói CNTT Care (trả phí)</div>
          <div v-if="!uuDai.goiHoiVien.length" class="uud-empty">Chưa mở bán gói nào.</div>
          <div v-for="g in uuDai.goiHoiVien" :key="g.ma" class="uud-card">
            <div class="uud-sp">{{ g.ten }}</div>
            <div class="uud-gia tnum">{{ fmt(g.gia) }} / {{ g.soThang }} tháng</div>
            <div v-for="(q, i) in g.quyenLoi" :key="i" class="uud-nd">· {{ q }}</div>
          </div>

          <!-- Trả góp -->
          <div class="uud-nhom">🧾 Trả góp</div>
          <div v-if="!uuDai.traGop.length" class="uud-empty">Chưa mở kỳ hạn trả góp nào.</div>
          <div v-for="t in uuDai.traGop" :key="t.soThang" class="uud-card">
            <div class="uud-nd">
              {{ t.soThang }} tháng ·
              <b>{{ Number(t.laiSuatNam) === 0 ? 'lãi suất 0%' : 'lãi ' + t.laiSuatNam + '%/năm' }}</b>
            </div>
          </div>
        </template>
      </div>
    </aside>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import api, { apiMessage, imgUrl, fmt, qrFor } from '../lib/api'
import { kenh } from '../lib/bus'

const router = useRouter()
const searchEl = ref(null)

// ---- state ----
const query = ref('')
const results = ref([])
const showResults = ref(false)
const searched = ref(false)
const cart = ref([])

const phone = ref('')
const customer = ref(null)
const custErr = ref('')
const newName = ref('')

const methods = ref([{ ma: 'cash', ten: 'Tiền mặt' }, { ma: 'vnpay', ten: 'VNPay' }])
const payment = ref('cash')

const couponCode = ref('')
const couponInfo = ref(null)
const couponMsg = ref('')
const couponOk = ref(false)
const xu = ref(0)

const placing = ref(false)
const placeErr = ref('')
const invoice = ref(null)

let searchTimer, custTimer

// ---- computed ----
const xuMax = computed(() => (customer.value && customer.value.xuHienCo) || 0)
const tienHang = () => cart.value.reduce((s, c) => s + (c.gia || 0) * c.soLuong, 0)

const t = computed(() => {
  const c = customer.value
  const th = tienHang()
  const pct = (c && !c.moi && c.phanTramGiamHang) ? c.phanTramGiamHang : 0
  const memberGiam = Math.round(th * pct / 100)
  const xuGiam = (xu.value || 0) * 1000
  const couponGiam = couponInfo.value ? couponInfo.value.giamGia : 0
  const giam = memberGiam + xuGiam + couponGiam
  return { tienHang: th, pct, memberGiam, xuGiam, couponGiam, tong: Math.max(0, th - giam) }
})

const canCheckout = computed(() => {
  if (!cart.value.length || placing.value) return false
  if (!phone.value.trim()) return false
  const hasName = customer.value && !customer.value.moi ? true : !!newName.value.trim()
  return hasName
})

const invPending = computed(() => {
  const inv = invoice.value
  return !!(inv && payment.value === 'vnpay' && inv.urlThanhToan &&
    !/(da_?thanh_?toan|paid|success|thanh_?cong)/i.test(String(inv.trangThaiThanhToan || '')))
})

// ---- search / scan ----
function onQuery() {
  clearTimeout(searchTimer)
  if (!query.value.trim()) { results.value = []; showResults.value = false; searched.value = false; return }
  const v = query.value
  searchTimer = setTimeout(() => doSearch(v), 180)
}
async function doSearch(v) {
  if (v !== query.value) return
  try {
    const { data } = await api.get('/pos/products', { params: { q: v.trim() } })
    if (v !== query.value) return
    const arr = Array.isArray(data) ? data : []
    // quét mã vạch: đúng 1 kết quả khớp SKU chính xác -> auto thêm
    if (arr.length === 1 && arr[0].sku && String(arr[0].sku).toLowerCase() === v.trim().toLowerCase()) {
      addProduct(arr[0]); return
    }
    results.value = arr; showResults.value = arr.length > 0; searched.value = true
  } catch (e) {
    results.value = []; showResults.value = false; searched.value = true
  }
}
function onEnter() {
  if (results.value.length) addProduct(results.value[0])
}
function focusSearch() {
  nextTick(() => { if (searchEl.value) searchEl.value.focus() })
}

// ---- cart ----
function addProduct(p) {
  const i = cart.value.findIndex(c => c.variantId === p.variantId)
  if (i >= 0) {
    const max = p.stock || cart.value[i].stock || 9999
    cart.value[i].soLuong = Math.min(cart.value[i].soLuong + 1, max)
  } else {
    cart.value.push({ variantId: p.variantId, productId: p.productId, productName: p.productName, sku: p.sku, imageUrl: p.imageUrl, gia: p.gia, stock: p.stock, soLuong: 1 })
  }
  query.value = ''; results.value = []; showResults.value = false; searched.value = false
  focusSearch(); broadcast()
}
function changeQty(variantId, d) {
  const i = cart.value.findIndex(c => c.variantId === variantId)
  if (i < 0) return
  const q = cart.value[i].soLuong + d
  const max = cart.value[i].stock || 9999
  if (q <= 0) cart.value.splice(i, 1)
  else cart.value[i].soLuong = Math.min(q, max)
  broadcast()
}
function removeItem(variantId) {
  cart.value = cart.value.filter(c => c.variantId !== variantId)
  broadcast()
}

// ---- customer ----
function onPhone() {
  customer.value = null; custErr.value = ''; newName.value = ''; xu.value = 0
  clearTimeout(custTimer)
  const v = phone.value
  if (v.replace(/\D/g, '').length >= 9) custTimer = setTimeout(() => lookupCustomer(v), 350)
  else broadcast()
}
async function lookupCustomer(v) {
  if (v !== phone.value) return
  try {
    const { data } = await api.get('/pos/customer', { params: { phone: v.trim() } })
    if (v !== phone.value) return
    customer.value = data; custErr.value = ''; xu.value = 0
    couponInfo.value = null; couponMsg.value = ''
    broadcast()
  } catch (e) {
    customer.value = null; custErr.value = apiMessage(e)
  }
}

// ---- discounts ----
async function applyCoupon() {
  const code = couponCode.value.trim()
  if (!code) return
  try {
    // Backend nhận { code, subtotal } và trả { code, discountType, discountValue, discountAmount }
    // — xem CouponDtos. Gửi/đọc sai tên trường thì mã luôn báo không hợp lệ hoặc giảm ra 0đ.
    const { data } = await api.post('/coupons/apply', { code, subtotal: tienHang() })
    const giam = Number((data && data.discountAmount) || 0)
    couponInfo.value = { giamGia: giam }; couponOk.value = true
    couponMsg.value = giam > 0 ? ('Áp dụng coupon: −' + fmt(giam)) : 'Đã áp dụng coupon'
    broadcast()
  } catch (e) {
    couponInfo.value = null; couponOk.value = false; couponMsg.value = apiMessage(e)
  }
}
function clampXu() {
  let v = parseInt(xu.value, 10); if (isNaN(v) || v < 0) v = 0
  xu.value = Math.min(v, xuMax.value)
  broadcast()
}

// ---- Thanh ưu đãi bên phải (ẩn, trượt ra khi bấm) ----
// Nhân viên hay bị khách hỏi "máy này có khuyến mãi gì / tặng gì / có mã giảm nào" ngay giữa lúc
// đang quét hàng. Gom 3 mục vào một thanh trượt để tra tại chỗ, không phải rời màn hình bán hàng.
const uuDaiMo = ref(false)
const uuDaiTab = ref('khuyenMai')
// Bốn mục sau (flashSale/hangThanhVien/goiHoiVien/traGop) là chương trình ở tầm CỬA HÀNG, không
// gắn với sản phẩm trong đơn — nhân viên phải đọc được cho khách ngay tại quầy. Xem PosService.uuDai.
const uuDai = ref({
  khuyenMai: [], tangKem: [], coupon: [],
  flashSale: null, hangThanhVien: [], goiHoiVien: [], traGop: [],
})
const uuDaiLoading = ref(false)

const gioNgay = (d) =>
  d ? new Date(d).toLocaleString('vi-VN', { hour: '2-digit', minute: '2-digit', day: '2-digit', month: '2-digit' }) : '—'

async function taiUuDai() {
  uuDaiLoading.value = true
  try {
    // Khuyến mãi/tặng kèm gắn theo sản phẩm nên gửi kèm các mặt hàng đang có trong đơn;
    // đơn trống thì backend vẫn trả danh sách coupon.
    const ids = cart.value.map(c => c.variantId)
    const { data } = await api.get('/pos/offers', {
      params: { variantIds: ids },
      paramsSerializer: { indexes: null }
    })
    uuDai.value = data || { khuyenMai: [], tangKem: [], coupon: [] }
  } catch (e) {
    uuDai.value = { khuyenMai: [], tangKem: [], coupon: [] }
  } finally {
    uuDaiLoading.value = false
  }
}

function moUuDai() {
  uuDaiMo.value = !uuDaiMo.value
  if (uuDaiMo.value) taiUuDai()
}

/** Bấm mã coupon trong thanh bên -> điền thẳng vào ô mã ở khu thanh toán, đỡ gõ tay sai. */
function dungCoupon(ma) {
  couponCode.value = ma
  uuDaiMo.value = false
  applyCoupon()
}

// ---- broadcast tới màn hình phụ ----
function broadcast() {
  if (invoice.value) return
  kenh.postMessage({
    loai: 'cap-nhat',
    disp: {
      trangThai: cart.value.length ? 'ban' : 'cho',
      dongHang: cart.value.map(c => ({ tenSanPham: c.productName, soLuong: c.soLuong, thanhTien: (c.gia || 0) * c.soLuong })),
      tongTien: t.value.tong, xuNhanDuoc: 0, qr: ''
    }
  })
}
function sendDisp(disp) { kenh.postMessage({ loai: 'cap-nhat', disp }) }

// ---- checkout ----
async function placeOrder() {
  if (!canCheckout.value) return
  placing.value = true; placeErr.value = ''
  const hoTen = customer.value && !customer.value.moi ? customer.value.hoTen : newName.value.trim()
  const body = {
    soDienThoai: phone.value.trim(),
    hoTen,
    dongHang: cart.value.map(c => ({ variantId: c.variantId, soLuong: c.soLuong })),
    maPhuongThucThanhToan: payment.value,
    maCoupon: couponCode.value.trim() || undefined,
    soXuMuonDung: xu.value || 0
  }
  try {
    const { data: inv } = await api.post('/pos/orders', body)
    invoice.value = inv
    const paid = /(da_?thanh_?toan|paid|success|thanh_?cong)/i.test(String(inv.trangThaiThanhToan || ''))
    if (payment.value === 'vnpay' && inv.urlThanhToan && !paid) {
      sendDisp({ trangThai: 'cho-thanh-toan', dongHang: [], tongTien: inv.tongTien, xuNhanDuoc: inv.xuNhanDuoc, qr: qrFor(inv.urlThanhToan) })
    } else {
      sendDisp({ trangThai: 'xong', dongHang: [], tongTien: inv.tongTien, xuNhanDuoc: inv.xuNhanDuoc, qr: '' })
    }
  } catch (e) {
    placeErr.value = apiMessage(e)
  } finally {
    placing.value = false
  }
}
function markPaid() {
  const inv = invoice.value
  if (inv) sendDisp({ trangThai: 'xong', dongHang: [], tongTien: inv.tongTien, xuNhanDuoc: inv.xuNhanDuoc, qr: '' })
}
function printInvoice() { window.print() }
function newSale() {
  cart.value = []; customer.value = null; phone.value = ''; newName.value = ''
  couponCode.value = ''; couponInfo.value = null; couponMsg.value = ''; xu.value = 0
  query.value = ''; results.value = []; showResults.value = false
  invoice.value = null; placeErr.value = ''
  sendDisp({ trangThai: 'cho', dongHang: [], tongTien: 0, xuNhanDuoc: 0, qr: '' })
  focusSearch()
}

function openDisplay() {
  window.open(window.location.origin + window.location.pathname + '#/display', 'pos-display', 'noopener')
}
function logout() {
  localStorage.removeItem('pos_token')
  router.push('/login')
}

// ---- payment methods ----
async function loadMethods() {
  try {
    const { data } = await api.get('/payment-methods')
    const arr = Array.isArray(data) ? data : (data && data.data) || []
    const norm = arr
      .map(m => ({
        ma: (m.ma || m.code || m.maPhuongThuc || m.maPhuongThucThanhToan || m.key || '').toLowerCase(),
        ten: m.ten || m.name || m.tenPhuongThuc || m.tenPhuongThucThanhToan || ''
      }))
      .filter(m => m.ma === 'cash' || m.ma === 'vnpay')
    if (norm.length) {
      methods.value = norm
      if (!norm.some(m => m.ma === payment.value)) payment.value = norm[0].ma
    }
  } catch (e) { /* giữ mặc định cash/vnpay */ }
}

// ---- lifecycle ----
function onKey(e) {
  if (e.key === 'F9') { e.preventDefault(); if (canCheckout.value && !invoice.value) placeOrder() }
}
function onBusMsg(ev) {
  const m = ev.data || {}
  if (m.loai === 'xin') broadcast() // màn hình phụ vừa mở -> gửi trạng thái hiện tại
}

onMounted(() => {
  loadMethods()
  focusSearch()
  broadcast()
  window.addEventListener('keydown', onKey)
  kenh.addEventListener('message', onBusMsg)
})
onUnmounted(() => {
  window.removeEventListener('keydown', onKey)
  kenh.removeEventListener('message', onBusMsg)
})
</script>

<style scoped>
.pos { height: 100vh; display: flex; flex-direction: column; }

.topbar { flex: none; display: flex; align-items: center; justify-content: space-between; padding: 10px 18px; background: #101114; color: #f2f3f5; }
.brand { display: flex; align-items: center; gap: 10px; }
.logo { width: 30px; height: 30px; border-radius: 7px; background: var(--acc); display: flex; align-items: center; justify-content: center; font-weight: 800; }
.name { font-weight: 700; letter-spacing: .3px; }
.actions { display: flex; gap: 8px; }
.ghost { height: 34px; padding: 0 13px; border: 1px solid rgba(255,255,255,.25); border-radius: 8px; background: transparent; color: #fff; font-size: 13px; font-weight: 600; }

.body { flex: 1; display: flex; min-height: 0; }

/* LEFT */
.left { flex: 1; min-width: 0; display: flex; flex-direction: column; padding: 16px 18px; gap: 14px; overflow: auto; }
.search-wrap { position: relative; flex: none; }
.search { width: 100%; height: 52px; padding: 0 16px; border: 1.5px solid var(--line); border-radius: 11px; font-size: 16px; background: var(--card); outline: none; box-shadow: 0 1px 2px rgba(0,0,0,.04); }
.search:focus { border-color: var(--acc); }
.dropdown { position: absolute; left: 0; right: 0; top: 58px; z-index: 20; background: var(--card); border: 1px solid var(--line); border-radius: 11px; box-shadow: 0 16px 40px rgba(0,0,0,.16); max-height: 340px; overflow: auto; }
.dropdown.empty { padding: 16px; font-size: 14px; color: var(--muted); }
.res { display: flex; align-items: center; gap: 12px; padding: 10px 13px; cursor: pointer; border-bottom: 1px solid var(--line); }
.res:hover { background: var(--card2); }
.res-info { flex: 1; min-width: 0; }
.res-name { font-size: 14px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.res-sub { font-size: 12px; color: var(--muted); }
.res-price { font-size: 14px; font-weight: 700; color: var(--acc); }
.thumb { width: 44px; height: 44px; border-radius: 8px; background: var(--card2) center/cover no-repeat; flex: none; border: 1px solid var(--line); }

.cart { flex: 1; min-height: 0; background: var(--card); border: 1px solid var(--line); border-radius: 12px; display: flex; flex-direction: column; overflow: hidden; }
.cart-head, .row { display: grid; grid-template-columns: 1fr 132px 120px 120px 40px; gap: 8px; align-items: center; }
.cart-head { flex: none; padding: 12px 16px; border-bottom: 1px solid var(--line); font-size: 11px; font-weight: 700; color: var(--muted); letter-spacing: .4px; text-transform: uppercase; }
.cart-body { flex: 1; overflow: auto; }
.cart-empty { height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; color: var(--muted); gap: 6px; padding: 40px; }
.ce-t { font-size: 15px; font-weight: 600; }
.ce-s { font-size: 13px; }
.row { padding: 11px 16px; border-bottom: 1px solid var(--line); }
.prod { display: flex; align-items: center; gap: 11px; min-width: 0; }
.prod-info { min-width: 0; }
.prod-name { font-size: 14px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.prod-sub { font-size: 12px; color: var(--muted); }
.qty { display: flex; align-items: center; justify-content: center; gap: 6px; }
.step { width: 30px; height: 30px; border: 1px solid var(--line); border-radius: 8px; background: var(--card); font-size: 18px; line-height: 1; color: var(--text); }
.qn { min-width: 30px; text-align: center; font-size: 15px; font-weight: 700; }
.r { text-align: right; font-size: 14px; }
.c { text-align: center; }
.muted { color: var(--muted2); }
.bold { font-weight: 700; }
.del { width: 30px; height: 30px; border: none; border-radius: 8px; background: transparent; color: var(--sale); font-size: 16px; }

/* RIGHT */
.right { width: 400px; flex: none; border-left: 1px solid var(--line); background: var(--card); overflow: auto; padding: 16px 18px; display: flex; flex-direction: column; gap: 16px; }
.mini-err { color: var(--sale); font-size: 13px; margin-top: 6px; }
.mini { font-size: 12px; margin-top: 6px; }
.sm { font-size: 11px; }
.dim { color: var(--muted); font-weight: 400; }

.cust-box { margin-top: 10px; background: var(--card2); border: 1px solid var(--line); border-radius: 10px; padding: 12px 13px; }
.cust-top { display: flex; align-items: center; justify-content: space-between; }
.cust-name { font-size: 15px; font-weight: 700; }
.cust-tier { font-size: 11px; font-weight: 700; color: var(--acc); background: color-mix(in srgb, var(--acc) 22%, transparent); padding: 3px 9px; border-radius: 20px; }
.cust-meta { display: flex; gap: 16px; margin-top: 8px; font-size: 13px; color: var(--muted2); }
.cust-meta b { color: var(--text); }
.cust-new { margin-top: 10px; }
.new-lbl { font-size: 12px; color: var(--green); font-weight: 600; margin-bottom: 6px; }

.coupon { display: flex; gap: 8px; }
.coupon .field { flex: 1; height: 42px; }
.upper { text-transform: uppercase; }
.apply { height: 42px; padding: 0 16px; border: 1.5px solid var(--acc); border-radius: 9px; background: var(--card); color: var(--acc); font-size: 14px; font-weight: 700; }
.xu-row { display: flex; align-items: center; justify-content: space-between; margin-top: 12px; }
.xu-lbl { font-size: 14px; font-weight: 600; }
.xu-input { width: 96px; height: 38px; padding: 0 11px; border: 1.5px solid var(--line); border-radius: 9px; font-size: 15px; text-align: right; outline: none; }

.pm { display: flex; gap: 8px; }
.pm-btn { flex: 1; height: 44px; border-radius: 10px; font-size: 14px; font-weight: 700; border: 1.5px solid var(--line); background: var(--card); color: var(--muted2); }
.pm-btn.on { border-color: var(--acc); background: var(--acc); color: var(--acc-ink); }

.summary { background: var(--card2); border: 1px solid var(--line); border-radius: 12px; padding: 14px 15px; }
.sum-row { display: flex; justify-content: space-between; font-size: 14px; color: var(--muted2); margin-bottom: 8px; }
.sum-row.green { color: var(--green); }
.divider { height: 1px; background: var(--line); margin: 6px 0 10px; }
.total-row { display: flex; align-items: baseline; justify-content: space-between; }
.total-row > span:first-child { font-size: 15px; font-weight: 700; }
.total { font-size: 24px; font-weight: 800; color: var(--acc); }
.end { text-align: right; margin-top: 4px; }

.checkout { width: 100%; height: 54px; border: none; border-radius: 12px; font-size: 17px; font-weight: 800; color: #fff; background: var(--green); }
.checkout:disabled { background: var(--line2); color: var(--muted); cursor: not-allowed; }

/* MODAL */
.modal { position: fixed; inset: 0; z-index: 60; background: rgba(10,12,18,.55); display: flex; align-items: center; justify-content: center; padding: 24px; }
.inv { width: 100%; max-width: 460px; max-height: 90vh; overflow: auto; background: var(--card); border-radius: 16px; box-shadow: 0 30px 80px rgba(0,0,0,.4); }
.inv-head { padding: 22px 24px; border-bottom: 1px solid var(--line); }
.inv-title { display: flex; align-items: center; gap: 8px; font-size: 18px; font-weight: 800; color: var(--green); }
.inv-sub { font-size: 13px; color: var(--muted); margin-top: 2px; }
.inv-body { padding: 18px 24px; }
.inv-line { display: flex; justify-content: space-between; font-size: 14px; margin-bottom: 6px; }
.inv-line.green { color: var(--green); }
.blue { color: var(--acc); }
.total-row.big > span:first-child { font-size: 16px; font-weight: 800; }
.total-row.big .total { font-size: 22px; }
.pending { display: flex; flex-direction: column; align-items: center; gap: 10px; padding: 6px 0 14px; }
.pending-lbl { font-size: 13px; color: var(--muted); font-weight: 600; }
.pending .qr { width: 220px; height: 220px; background: var(--card) center/contain no-repeat; border: 1px solid var(--line); border-radius: 10px; }
.paid { height: 40px; padding: 0 18px; border: none; border-radius: 9px; background: var(--green); color: #fff; font-weight: 700; font-size: 14px; }
.inv-foot { padding: 14px 24px 22px; display: flex; gap: 10px; }
.print { flex: 1; height: 46px; border: 1.5px solid var(--text); border-radius: 10px; background: var(--card); color: var(--text); font-weight: 700; font-size: 15px; }
.new { flex: 1; height: 46px; border: none; border-radius: 10px; background: var(--acc); color: var(--acc-ink); font-weight: 700; font-size: 15px; }

/* ===== Thanh ưu đãi bên phải ===== */
.uud-backdrop { position: fixed; inset: 0; background: rgba(0,0,0,.35); z-index: 40; }
.uud {
  position: fixed; top: 0; right: 0; height: 100vh; width: 380px; max-width: 92vw;
  background: var(--card); border-left: 1px solid var(--line);
  box-shadow: -14px 0 34px rgba(0,0,0,.18);
  display: flex; flex-direction: column; z-index: 41;
  /* Ẩn hẳn ra ngoài mép phải, trượt vào khi mở — không dùng v-if để giữ được hiệu ứng trượt. */
  transform: translateX(100%); transition: transform .28s cubic-bezier(.4,0,.2,1);
}
.uud.open { transform: translateX(0); }
.uud-head {
  flex: none; display: flex; align-items: center; justify-content: space-between;
  padding: 16px 18px; border-bottom: 1px solid var(--line);
  font-size: 15px; font-weight: 700; color: var(--text);
}
.uud-x { border: none; background: transparent; font-size: 24px; line-height: 1; color: var(--muted); padding: 0 4px; }
.uud-x:hover { color: var(--text); }
.uud-tabs { flex: none; display: flex; gap: 6px; padding: 10px 14px; border-bottom: 1px solid var(--line); }
.uud-tabs button {
  flex: 1; height: 34px; border: 1px solid var(--line); border-radius: 8px;
  background: transparent; color: var(--muted); font-size: 12px; font-weight: 600;
}
.uud-tabs button.on { background: var(--acc); border-color: var(--acc); color: var(--acc-ink); }
.uud-tabs b { font-weight: 800; }
.uud-body { flex: 1; overflow: auto; padding: 12px 14px; display: flex; flex-direction: column; gap: 10px; }
.uud-nhom {
  font-size: 12px;
  font-weight: 700;
  color: #c6ff4a;
  letter-spacing: .3px;
  margin: 16px 0 8px;
}
.uud-nhom:first-child { margin-top: 0; }
.uud-empty { padding: 30px 10px; text-align: center; color: var(--muted); font-size: 12.5px; line-height: 1.6; }
.uud-card { background: var(--card2); border: 1px solid var(--line); border-radius: 10px; padding: 12px 13px; }
.uud-sp { font-size: 11px; color: var(--muted); margin-bottom: 5px; }
.uud-nd { font-size: 13px; color: var(--text); font-weight: 600; line-height: 1.45; }
.uud-tk { display: flex; align-items: center; gap: 10px; }
.uud-img { width: 42px; height: 42px; object-fit: contain; background: var(--card); border-radius: 7px; flex: none; }
.uud-gia { font-size: 11px; color: var(--muted); margin-top: 4px; }
.uud-cp { cursor: pointer; transition: border-color .15s ease, transform .15s ease; }
.uud-cp:hover { border-color: var(--acc); transform: translateY(-1px); }
.uud-ma { font-size: 16px; font-weight: 800; color: var(--acc); letter-spacing: .5px; margin-bottom: 3px; }
</style>
