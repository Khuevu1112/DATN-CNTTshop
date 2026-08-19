<template>
  <div class="pos">
    <header class="topbar">
      <div class="brand">
        <div class="logo">P</div>
        <div class="name">Tra cứu &amp; Bảo hành</div>
      </div>
      <div class="actions">
        <button class="ghost" @click="$router.push('/')">← Về bán hàng</button>
        <button class="ghost" @click="logout">Đăng xuất</button>
      </div>
    </header>

    <div class="wrap">
      <div class="find">
        <input
          ref="oInput"
          v-model="tuKhoa"
          @keydown.enter.prevent="tra"
          class="find-inp"
          placeholder="Số điện thoại khách · Mã đơn hàng (DH…) · Serial trên tem máy"
        />
        <button class="find-btn" :disabled="dangTra" @click="tra">
          {{ dangTra ? 'Đang tra…' : 'Tra cứu' }}
        </button>
      </div>
      <div v-if="loi" class="loi">{{ loi }}</div>

      <div v-if="!kq && !loi" class="huong-dan">
        <div class="hd-icon">🔎</div>
        <div class="hd-t">Tra thông tin khách đang đứng trước quầy</div>
        <div class="hd-s">
          Nhập một trong ba thứ: số điện thoại khách, mã đơn hàng trên hoá đơn, hoặc số serial dán
          trên máy. Màn hình sẽ hiện toàn bộ đơn hàng, phiếu bảo hành và việc còn dang dở của khách.
        </div>
      </div>

      <template v-if="kq">
        <!-- Thẻ khách -->
        <section class="the khach">
          <div class="kh-ten">{{ kq.khach.hoTen || 'Khách chưa đặt tên' }}</div>
          <div class="kh-sub">{{ kq.khach.soDienThoai || '—' }}</div>
          <div class="kh-chip-row">
            <span class="chip">Hạng {{ kq.khach.hangThanhVien }}</span>
            <span v-if="kq.khach.phanTramGiamHang" class="chip acc">
              Giảm {{ kq.khach.phanTramGiamHang }}% mọi đơn
            </span>
            <span class="chip">🪙 {{ kq.khach.xuHienCo }} Xu CT</span>
          </div>
        </section>

        <div class="tabs">
          <button :class="{ on: tab === 'don' }" @click="tab = 'don'">
            Đơn hàng <b v-if="kq.donHang.length">{{ kq.donHang.length }}</b>
          </button>
          <button :class="{ on: tab === 'bh' }" @click="tab = 'bh'">
            Bảo hành <b v-if="kq.baoHanh.length">{{ kq.baoHanh.length }}</b>
          </button>
          <button :class="{ on: tab === 'viec' }" @click="tab = 'viec'">
            Đang xử lý <b v-if="kq.viecDangXuLy.length">{{ kq.viecDangXuLy.length }}</b>
          </button>
        </div>

        <!-- ĐƠN HÀNG -->
        <template v-if="tab === 'don'">
          <div v-if="!kq.donHang.length" class="trong">Khách chưa có đơn hàng nào.</div>
          <section v-for="d in kq.donHang" :key="d.id" class="the">
            <div class="hang">
              <div>
                <div class="ma">{{ d.maDonHang }}</div>
                <div class="phu">{{ ngayGio(d.thoiGian) }} · {{ d.kenhBan }}</div>
              </div>
              <div class="phai">
                <div class="tien">{{ fmt(d.tongTien) }}</div>
                <span class="tt" :style="{ background: mauNen(d.trangThai), color: mau(d.trangThai) }">
                  {{ d.nhanTrangThai }}
                </span>
              </div>
            </div>
            <div class="mota">{{ d.moTaTrangThai }}</div>
            <div class="phu">
              {{ d.tenSanPhamDauTien }}<span v-if="d.soMatHang > 1"> +{{ d.soMatHang - 1 }} mặt hàng khác</span>
              <span v-if="d.trangThaiThanhToan"> · {{ d.trangThaiThanhToan }}</span>
            </div>
          </section>
        </template>

        <!-- BẢO HÀNH -->
        <template v-else-if="tab === 'bh'">
          <div v-if="!kq.baoHanh.length" class="trong">
            Khách chưa có phiếu bảo hành nào. Phiếu được tạo tự động khi đơn hàng giao xong.
          </div>
          <section v-for="b in kq.baoHanh" :key="b.id" class="the">
            <div class="hang">
              <div>
                <div class="ma">{{ b.maBaoHanh }}</div>
                <div class="phu">{{ b.tenSanPham || '—' }}<span v-if="b.serial"> · SN {{ b.serial }}</span></div>
              </div>
              <div class="phai">
                <span class="tt" :style="{ background: mauNenBh(b.trangThai), color: mauBh(b.trangThai) }">
                  {{ b.nhanTrangThai }}
                </span>
                <div v-if="b.trangThai === 'active'" class="phu" style="margin-top: 4px">
                  còn {{ b.soNgayConLai }} ngày
                </div>
              </div>
            </div>
            <div class="phu">{{ ngay(b.ngayBatDau) }} → {{ ngay(b.ngayKetThuc) }}</div>

            <!-- Các lần đã gửi sửa -->
            <div v-if="b.yeuCau.length" class="ycs">
              <div v-for="y in b.yeuCau" :key="y.id" class="yc">
                <div>
                  <div class="yc-mo">{{ y.moTaLoi }}</div>
                  <div class="phu">{{ y.hinhThuc }} · gửi {{ ngayGio(y.taoLuc) }}</div>
                </div>
                <span class="tt nho">{{ y.nhanTrangThai }}</span>
              </div>
            </div>

            <button v-if="b.trangThai === 'active'" class="nut-bh" @click="moTaoYeuCau(b)">
              + Nhận máy bảo hành
            </button>
          </section>
        </template>

        <!-- VIỆC ĐANG XỬ LÝ -->
        <template v-else>
          <div v-if="!kq.viecDangXuLy.length" class="trong">Khách không có việc nào đang xử lý.</div>
          <section v-for="(v, i) in kq.viecDangXuLy" :key="i" class="the">
            <div class="hang">
              <div>
                <div class="ma">{{ v.loai }} · {{ v.ma }}</div>
                <div class="phu">{{ v.tieuDe }} · {{ ngayGio(v.thoiGian) }}</div>
              </div>
              <span class="tt nho">{{ v.nhanTrangThai }}</span>
            </div>
          </section>
        </template>
      </template>
    </div>

    <!-- ===== Nhận máy bảo hành tại quầy ===== -->
    <div v-if="formBh" class="mask" @click.self="formBh = null">
      <div class="modal">
        <div class="m-head">
          <div>
            <div class="m-t">Nhận máy bảo hành</div>
            <div class="phu">{{ formBh.maBaoHanh }} · {{ formBh.tenSanPham }}</div>
          </div>
          <button class="m-x" @click="formBh = null">×</button>
        </div>
        <div class="m-body">
          <label>
            <span>Khách mô tả lỗi *</span>
            <textarea v-model="moTaLoi" rows="4" class="ta" placeholder="VD: máy tự tắt nguồn khi chơi game, màn hình có sọc dọc…"></textarea>
          </label>
          <label>
            <span>Hình thức</span>
            <select v-model="hinhThuc" class="sel">
              <option value="cua_hang">Khách để máy lại cửa hàng</option>
              <option value="tan_noi">Kỹ thuật tới tận nơi (phụ phí 150.000đ)</option>
            </select>
          </label>
          <label v-if="hinhThuc === 'cua_hang'">
            <span>Trung tâm tiếp nhận *</span>
            <select v-model="centerId" class="sel">
              <option value="">— Chọn trung tâm —</option>
              <option v-for="c in trungTam" :key="c.id" :value="c.id">{{ c.ten }}</option>
            </select>
          </label>
          <div v-if="loiBh" class="loi" style="margin-top: 12px">{{ loiBh }}</div>
        </div>
        <div class="m-foot">
          <button class="ghost" @click="formBh = null">Huỷ</button>
          <button class="find-btn" :disabled="dangGui" @click="guiYeuCau">
            {{ dangGui ? 'Đang gửi…' : 'Tiếp nhận máy' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import api, { apiMessage, fmt } from '../lib/api'

/**
 * Màn hình TRA CỨU & BẢO HÀNH tại quầy.
 *
 * POS trước đây chỉ có màn hình bán hàng, nên mọi câu hỏi ngoài "thanh toán bao nhiêu" đều phải
 * chuyển sang Admin Console (tài khoản khác, máy khác). Màn hình này trả lời tại chỗ ba nhóm việc
 * hay gặp nhất ở quầy: đơn hàng tới đâu, máy còn bảo hành không, việc đang xử lý xong chưa — và
 * cho phép TIẾP NHẬN MÁY bảo hành luôn thay vì bảo khách tự lên web đặt.
 */
const router = useRouter()

const tuKhoa = ref('')
const kq = ref(null)
const loi = ref('')
const dangTra = ref(false)
const tab = ref('don')
const oInput = ref(null)

onMounted(() => nextTick(() => oInput.value?.focus()))

async function tra() {
  const q = tuKhoa.value.trim()
  if (!q) return
  loi.value = ''
  dangTra.value = true
  try {
    const { data } = await api.get('/pos/tra-cuu', { params: { q } })
    kq.value = data
    tab.value = 'don'
  } catch (e) {
    kq.value = null
    loi.value = apiMessage(e)
  } finally {
    dangTra.value = false
  }
}

// ===== Nhận máy bảo hành =====
const formBh = ref(null)
const moTaLoi = ref('')
const hinhThuc = ref('cua_hang')
const centerId = ref('')
const trungTam = ref([])
const loiBh = ref('')
const dangGui = ref(false)

async function moTaoYeuCau(b) {
  formBh.value = b
  moTaLoi.value = ''
  hinhThuc.value = 'cua_hang'
  centerId.value = ''
  loiBh.value = ''
  if (!trungTam.value.length) {
    try {
      const { data } = await api.get('/pos/service-centers')
      trungTam.value = data
    } catch (e) {
      trungTam.value = []
    }
  }
}

async function guiYeuCau() {
  loiBh.value = ''
  if (!moTaLoi.value.trim()) {
    loiBh.value = 'Nhập mô tả lỗi khách báo.'
    return
  }
  if (hinhThuc.value === 'cua_hang' && !centerId.value) {
    loiBh.value = 'Chọn trung tâm tiếp nhận máy.'
    return
  }
  dangGui.value = true
  try {
    await api.post('/pos/warranty-requests', {
      warrantyId: formBh.value.id,
      moTaLoi: moTaLoi.value.trim(),
      hinhThuc: hinhThuc.value,
      centerId: hinhThuc.value === 'cua_hang' ? Number(centerId.value) : null,
    })
    formBh.value = null
    await tra() // nạp lại để thấy yêu cầu vừa tạo trong danh sách
    tab.value = 'bh'
  } catch (e) {
    loiBh.value = apiMessage(e)
  } finally {
    dangGui.value = false
  }
}

function logout() {
  localStorage.removeItem('pos_token')
  localStorage.removeItem('pos_user')
  router.push('/login')
}

const ngay = (d) => (d ? new Date(d).toLocaleDateString('vi-VN') : '—')
const ngayGio = (d) =>
  d ? new Date(d).toLocaleString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }) : '—'

// Màu trạng thái đơn: xanh = xong, vàng = đang chạy, đỏ = kết thúc bất thường.
const MAU_DON = {
  pending: '#f5a524', confirmed: '#38bdf8', processing: '#38bdf8', shipped: '#a855f7',
  delivered: '#22c55e', cancelled: '#ef4444', returned: '#f5a524', refunded: '#94a3b8',
}
const mau = (s) => MAU_DON[s] || '#94a3b8'
const mauNen = (s) => `color-mix(in srgb, ${mau(s)} 18%, transparent)`
const MAU_BH = { active: '#22c55e', expired: '#94a3b8', void: '#ef4444' }
const mauBh = (s) => MAU_BH[s] || '#94a3b8'
const mauNenBh = (s) => `color-mix(in srgb, ${mauBh(s)} 18%, transparent)`
</script>

<style scoped>
.pos { min-height: 100vh; background: #0f1115; color: #e8eaee; display: flex; flex-direction: column; }
.topbar {
  display: flex; align-items: center; justify-content: space-between;
  padding: 12px 20px; background: #161922; border-bottom: 1px solid #232735;
}
.brand { display: flex; align-items: center; gap: 11px; }
.logo {
  width: 34px; height: 34px; border-radius: 9px; background: #c6ff4a; color: #101114;
  display: flex; align-items: center; justify-content: center; font-weight: 800;
}
.name { font-size: 16px; font-weight: 700; }
.actions { display: flex; gap: 9px; }
.ghost {
  height: 36px; padding: 0 14px; border-radius: 9px; border: 1px solid #2c3143;
  background: transparent; color: #aeb4c4; font-size: 13px; cursor: pointer; font-family: inherit;
}
.ghost:hover { background: #1c2030; }

.wrap { flex: 1; max-width: 860px; width: 100%; margin: 0 auto; padding: 22px 20px 60px; }

.find { display: flex; gap: 10px; }
.find-inp {
  flex: 1; height: 50px; padding: 0 16px; border-radius: 11px;
  border: 1px solid #2c3143; background: #161922; color: #e8eaee; font-size: 15px; font-family: inherit;
}
.find-inp:focus { outline: none; border-color: #c6ff4a; }
.find-btn {
  height: 50px; padding: 0 24px; border-radius: 11px; border: none;
  background: #c6ff4a; color: #101114; font-size: 14px; font-weight: 700; cursor: pointer; font-family: inherit;
}
.find-btn:disabled { opacity: 0.55; cursor: default; }

.loi {
  margin-top: 14px; padding: 12px 15px; border-radius: 10px;
  background: rgba(239, 68, 68, 0.12); border: 1px solid rgba(239, 68, 68, 0.34);
  color: #fca5a5; font-size: 13.5px; line-height: 1.55;
}

.huong-dan { margin-top: 60px; text-align: center; color: #7b8296; }
.hd-icon { font-size: 40px; margin-bottom: 12px; }
.hd-t { font-size: 16px; font-weight: 600; color: #aeb4c4; margin-bottom: 8px; }
.hd-s { font-size: 13.5px; line-height: 1.6; max-width: 460px; margin: 0 auto; }

.the {
  margin-top: 12px; background: #161922; border: 1px solid #232735;
  border-radius: 13px; padding: 15px 17px;
}
.khach { margin-top: 20px; }
.kh-ten { font-size: 19px; font-weight: 700; }
.kh-sub { font-size: 13.5px; color: #7b8296; margin-top: 2px; }
.kh-chip-row { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 11px; }
.chip {
  font-size: 12px; font-weight: 600; padding: 4px 11px; border-radius: 20px;
  background: #1e2231; color: #aeb4c4;
}
.chip.acc { background: rgba(198, 255, 74, 0.15); color: #c6ff4a; }

.tabs { display: flex; gap: 8px; margin-top: 22px; }
.tabs button {
  height: 36px; padding: 0 16px; border-radius: 9px; border: 1px solid #2c3143;
  background: transparent; color: #7b8296; font-size: 13px; font-weight: 600;
  cursor: pointer; font-family: inherit;
}
.tabs button.on { background: #c6ff4a; border-color: #c6ff4a; color: #101114; }
.tabs b { margin-left: 5px; font-size: 11.5px; }

.hang { display: flex; align-items: flex-start; justify-content: space-between; gap: 14px; }
.phai { text-align: right; flex: none; }
.ma { font-size: 14.5px; font-weight: 700; color: #c6ff4a; }
.phu { font-size: 12.5px; color: #7b8296; margin-top: 3px; line-height: 1.5; }
.tien { font-size: 15px; font-weight: 700; }
.tt {
  display: inline-block; font-size: 11.5px; font-weight: 700;
  padding: 3px 10px; border-radius: 20px; margin-top: 4px;
}
.tt.nho { background: #1e2231; color: #aeb4c4; }
.mota { font-size: 13px; color: #aeb4c4; line-height: 1.6; margin-top: 9px; }

.ycs { margin-top: 12px; border-top: 1px solid #232735; padding-top: 10px; }
.yc {
  display: flex; align-items: flex-start; justify-content: space-between; gap: 12px;
  padding: 7px 0;
}
.yc-mo { font-size: 13px; color: #e8eaee; }
.nut-bh {
  margin-top: 12px; height: 36px; padding: 0 16px; border-radius: 9px;
  border: 1px solid #c6ff4a; background: rgba(198, 255, 74, 0.1); color: #c6ff4a;
  font-size: 13px; font-weight: 700; cursor: pointer; font-family: inherit;
}

.trong {
  margin-top: 14px; padding: 34px 18px; text-align: center; color: #7b8296;
  font-size: 13.5px; border: 1px dashed #2c3143; border-radius: 12px; line-height: 1.6;
}

.mask {
  position: fixed; inset: 0; background: rgba(0, 0, 0, 0.62);
  display: flex; align-items: center; justify-content: center; padding: 24px; z-index: 200;
}
.modal { background: #161922; border: 1px solid #2c3143; border-radius: 14px; width: 100%; max-width: 520px; }
.m-head {
  display: flex; align-items: flex-start; justify-content: space-between; gap: 14px;
  padding: 16px 18px; border-bottom: 1px solid #232735;
}
.m-t { font-size: 16px; font-weight: 700; }
.m-x {
  width: 30px; height: 30px; border-radius: 8px; border: 1px solid #2c3143;
  background: transparent; color: #aeb4c4; font-size: 18px; cursor: pointer; line-height: 1;
}
.m-body { padding: 18px; display: flex; flex-direction: column; gap: 13px; }
.m-body label { display: flex; flex-direction: column; gap: 6px; }
.m-body label > span { font-size: 12px; color: #7b8296; font-weight: 600; }
.ta, .sel {
  width: 100%; padding: 10px 12px; border-radius: 9px; border: 1px solid #2c3143;
  background: #0f1115; color: #e8eaee; font-size: 13.5px; font-family: inherit; resize: vertical;
}
.sel { height: 40px; }
.m-foot { display: flex; justify-content: flex-end; gap: 9px; padding: 14px 18px; border-top: 1px solid #232735; }
.m-foot .find-btn { height: 38px; padding: 0 18px; font-size: 13px; }
</style>
