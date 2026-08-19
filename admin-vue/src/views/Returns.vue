<template>
  <div style="animation: fadeUp 0.35s ease">
    <!-- Lọc trạng thái + tạo yêu cầu hộ khách -->
    <div style="display: flex; gap: 8px; flex-wrap: wrap; align-items: center; margin-bottom: 16px">
      <button
        v-for="t in TABS"
        :key="t.ma"
        class="tab-chip"
        :class="{ active: loc === t.ma }"
        @click="doiLoc(t.ma)"
      >
        {{ t.ten }}
        <span class="mono" style="font-size: 10.5px; padding: 0 6px; border-radius: 8px; background: var(--card2); color: var(--muted)">
          {{ demTheoTrangThai(t.ma) }}
        </span>
      </button>
      <button class="btn-ghost" style="margin-left: auto" @click="moFormTao">+ Tạo yêu cầu hộ khách</button>
    </div>

    <!-- Form CSKH tự khởi tạo: tra mã đơn -> chọn dòng sản phẩm -> tạo -->
    <div v-if="formMo" style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 18px 20px; margin-bottom: 16px">
      <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px">
        <b style="font-size: 14px">Tạo yêu cầu đổi/trả hộ khách</b>
        <button class="btn-ghost" style="height: 30px; padding: 0 12px" @click="dongFormTao">Đóng</button>
      </div>

      <div style="display: flex; gap: 9px; flex-wrap: wrap; align-items: center; margin-bottom: 12px">
        <input
          v-model="form.maDon"
          class="fld"
          style="flex: 1; min-width: 200px; height: 38px"
          placeholder="Mã đơn hàng (vd DH250811ABCD)"
          @keyup.enter="traCuu"
        />
        <button class="btn-ghost" :disabled="dangTraCuu || !form.maDon" @click="traCuu">
          {{ dangTraCuu ? 'Đang tra...' : 'Tra cứu đơn' }}
        </button>
      </div>

      <div v-if="loiForm" style="font-size: 12.5px; color: var(--danger, #ff5d7a); margin-bottom: 12px">{{ loiForm }}</div>

      <template v-if="don">
        <div style="font-size: 12.5px; color: var(--muted2); margin-bottom: 10px">
          Khách: <b style="color: var(--text)">{{ don.hoTen }}</b> · {{ don.email }}
          <span v-if="don.dienThoai"> · {{ don.dienThoai }}</span>
        </div>

        <div style="font-size: 12.5px; color: var(--muted2); margin-bottom: 6px">Sản phẩm cần đổi/trả</div>
        <div style="display: flex; flex-direction: column; gap: 8px; margin-bottom: 12px">
          <label
            v-for="sp in don.sanPham"
            :key="sp.orderItemId"
            style="display: flex; align-items: center; gap: 10px; padding: 10px 12px; background: var(--card2); border-radius: 10px; cursor: pointer"
          >
            <input type="radio" :value="sp.orderItemId" v-model="form.orderItemId" style="accent-color: var(--acc)" />
            <span style="flex: 1; font-size: 13px">
              {{ sp.tenSanPham }}
              <span class="mono" style="font-size: 11px; color: var(--muted)"> · {{ sp.sku }}</span>
            </span>
            <span style="font-size: 12px; color: var(--muted)">đã mua ×{{ sp.soLuong }}</span>
          </label>
        </div>

        <div style="display: flex; gap: 9px; flex-wrap: wrap; margin-bottom: 12px">
          <select v-model="form.lyDo" class="fld" style="height: 38px; min-width: 200px">
            <option value="loi_nsx">Lỗi nhà sản xuất</option>
            <option value="giao_sai">Giao sai mẫu / cấu hình</option>
            <option value="khong_dung_mo_ta">Không đúng mô tả</option>
            <option value="khac">Lý do khác</option>
          </select>
          <input
            v-model.number="form.soLuong"
            type="number"
            min="1"
            class="fld"
            style="width: 150px; height: 38px"
            placeholder="Số lượng"
          />
        </div>

        <textarea
          v-model="form.noiDung"
          class="fld"
          rows="3"
          style="width: 100%; padding: 10px 12px; margin-bottom: 12px"
          placeholder="Mô tả tình trạng máy / lý do khách đổi trả"
        ></textarea>

        <button class="btn-ghost" :disabled="dangTao || !form.noiDung" @click="taoYeuCau">
          {{ dangTao ? 'Đang tạo...' : 'Tạo yêu cầu' }}
        </button>
      </template>
    </div>

    <div v-if="loading" class="spin"></div>

    <div v-else-if="!danhSach.length" style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 48px 20px; text-align: center; color: var(--muted); font-size: 13.5px">
      Chưa có yêu cầu đổi trả nào{{ loc ? ' ở trạng thái này' : '' }}.
    </div>

    <!-- Chế độ THẺ của DataTable: mỗi yêu cầu vẫn là một thẻ đầy đủ (có ảnh/video minh chứng và
         nút xử lý), nhưng vẫn lọc/sắp xếp được y hệt các bảng khác qua dãy chip phía trên. -->
    <DataTable
      v-else
      che-do="the"
      :columns="cols"
      :rows="danhSach"
      trong="Chưa có yêu cầu đổi trả nào."
    >
      <template #the="{ rows }">
    <div style="display: flex; flex-direction: column; gap: 12px">
      <div v-for="r in rows" :key="r.id" style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 18px 20px">
        <div style="display: flex; align-items: flex-start; justify-content: space-between; gap: 14px; flex-wrap: wrap; margin-bottom: 12px">
          <div>
            <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap">
              <span class="mono" style="font-size: 14px; font-weight: 700; color: var(--acc)">{{ r.maYeuCau }}</span>
              <span class="badge" :style="badge(r.trangThai)">{{ r.nhanTrangThai }}</span>
              <span class="badge" style="background: var(--card2); color: var(--muted2)">
                {{ r.kenhMua === 'online' ? 'Mua online' : 'Tại cửa hàng' }}
              </span>
              <span v-if="r.taoBoiAdmin" class="badge" style="background: var(--card2); color: var(--muted2)">CSKH tạo</span>
              <span v-if="r.daHoanKho" class="badge" :style="badge('hoan_tat')">Đã hoàn kho</span>
            </div>
            <div style="font-size: 12px; color: var(--muted); margin-top: 6px">
              {{ r.hoTen }} · {{ r.email }}<span v-if="r.dienThoai"> · {{ r.dienThoai }}</span> · {{ fmtDateTime(r.createdAt) }}
            </div>
          </div>
          <div v-if="r.maDon" style="font-size: 12px; color: var(--muted2)">Đơn: <b style="color: var(--text)">{{ r.maDon }}</b></div>
        </div>

        <div style="font-size: 12.5px; color: var(--muted2); margin-bottom: 6px">
          Lý do: <b style="color: var(--text)">{{ nhanLyDo(r.lyDo) }}</b>
        </div>
        <div style="padding: 12px 14px; background: var(--card2); border-radius: 10px; font-size: 13px; color: var(--text); line-height: 1.6; white-space: pre-wrap; margin-bottom: 12px">
          {{ r.noiDung }}
        </div>

        <!-- Minh chứng -->
        <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 12px">
          <a v-if="r.videoLoi" :href="resolveImageUrl(r.videoLoi)" target="_blank" rel="noopener" class="ev-chip">🎬 Video lỗi</a>
          <a v-if="r.videoMoHang" :href="resolveImageUrl(r.videoMoHang)" target="_blank" rel="noopener" class="ev-chip">📦 Video mở hàng</a>
          <a v-for="(a, i) in r.anhLoi" :key="i" :href="resolveImageUrl(a)" target="_blank" rel="noopener" class="ev-chip">🖼️ Ảnh {{ i + 1 }}</a>
          <span v-if="!r.videoLoi && !r.videoMoHang && !r.anhLoi.length" style="font-size: 12px; color: var(--muted)">Không có minh chứng đính kèm</span>
        </div>

        <div v-if="r.ghiChuCskh" style="font-size: 12.5px; color: var(--muted2); margin-bottom: 12px">
          <b style="color: var(--text)">Ghi chú CSKH:</b> {{ r.ghiChuCskh }}
        </div>

        <!-- Chuyển trạng thái -->
        <div v-if="buoc(r.trangThai).length" style="display: flex; gap: 9px; flex-wrap: wrap; align-items: center">
          <input v-model="ghiChu[r.id]" class="fld" style="flex: 1; min-width: 220px; height: 38px" placeholder="Ghi chú gửi khách (tuỳ chọn)" />
          <button v-for="b in buoc(r.trangThai)" :key="b" class="btn-ghost" :disabled="dangLuu === r.id" @click="doiTrangThai(r, b)">
            {{ NHAN[b] }}
          </button>
        </div>
        <div v-else style="font-size: 12px; color: var(--muted)">Yêu cầu đã kết thúc.</div>
      </div>
    </div>
      </template>
    </DataTable>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getReturns, updateReturnStatus, lookupOrderForReturn, createReturn } from '../api/admin'
import { resolveImageUrl } from '../api/http'
import DataTable from '../components/DataTable.vue'

// Trường lọc cho chế độ thẻ — cùng phễu Excel như các bảng khác (xem components/DataTable.vue).
const cols = [
  { key: 'maYeuCau', label: 'Mã yêu cầu' },
  { key: 'hoTen', label: 'Khách hàng', text: (r) => r.hoTen || r.email || '—' },
  { key: 'maDon', label: 'Mã đơn', text: (r) => r.maDon || '—' },
  { key: 'tenSanPham', label: 'Sản phẩm', text: (r) => r.tenSanPham || '—' },
  { key: 'kenhMua', label: 'Kênh mua', text: (r) => (r.kenhMua === 'online' ? 'Online' : 'Tại cửa hàng') },
  { key: 'lyDo', label: 'Lý do', text: (r) => r.lyDo || '—' },
  { key: 'trangThai', label: 'Trạng thái', text: (r) => r.nhanTrangThai || r.trangThai },
  { key: 'createdAt', label: 'Ngày gửi', kieu: 'ngay' },
]

const danhSach = ref([])
const tatCa = ref([])
const loading = ref(true)
const loc = ref('')
const ghiChu = ref({})
const dangLuu = ref(null)

// ===== CSKH tự khởi tạo yêu cầu hộ khách =====
const formMo = ref(false)
const don = ref(null)
const loiForm = ref('')
const dangTraCuu = ref(false)
const dangTao = ref(false)
const form = ref({ maDon: '', orderItemId: null, lyDo: 'loi_nsx', noiDung: '', soLuong: 1 })

function moFormTao() {
  formMo.value = true
}
function dongFormTao() {
  formMo.value = false
  don.value = null
  loiForm.value = ''
  form.value = { maDon: '', orderItemId: null, lyDo: 'loi_nsx', noiDung: '', soLuong: 1 }
}

async function traCuu() {
  dangTraCuu.value = true
  loiForm.value = ''
  don.value = null
  try {
    const kq = await lookupOrderForReturn(form.value.maDon.trim())
    don.value = kq
    // Đơn 1 sản phẩm thì chọn sẵn cho nhanh, khỏi bắt CSKH bấm thêm 1 lần.
    if (kq.sanPham?.length === 1) {
      form.value.orderItemId = kq.sanPham[0].orderItemId
      form.value.soLuong = kq.sanPham[0].soLuong || 1
    } else {
      form.value.orderItemId = null
    }
  } catch (e) {
    loiForm.value = e?.response?.data?.message || 'Không tra cứu được đơn hàng này.'
  } finally {
    dangTraCuu.value = false
  }
}

async function taoYeuCau() {
  dangTao.value = true
  loiForm.value = ''
  try {
    await createReturn({
      maDon: form.value.maDon.trim(),
      orderItemId: form.value.orderItemId,
      lyDo: form.value.lyDo,
      noiDung: form.value.noiDung,
      soLuong: form.value.soLuong,
    })
    dongFormTao()
    await tai()
  } catch (e) {
    loiForm.value = e?.response?.data?.message || 'Không tạo được yêu cầu.'
  } finally {
    dangTao.value = false
  }
}

const TABS = [
  { ma: '', ten: 'Tất cả' },
  { ma: 'cho_xu_ly', ten: 'Chờ xử lý' },
  { ma: 'dang_xu_ly', ten: 'Đang xử lý' },
  { ma: 'chap_nhan', ten: 'Chấp nhận' },
  { ma: 'tu_choi', ten: 'Từ chối' },
  { ma: 'hoan_tat', ten: 'Hoàn tất' },
]
const NHAN = { dang_xu_ly: 'Bắt đầu xử lý', chap_nhan: 'Chấp nhận', tu_choi: 'Từ chối', hoan_tat: 'Hoàn tất' }
// Khớp LUONG trong ReturnRequestService.
const LUONG = {
  cho_xu_ly: ['dang_xu_ly', 'tu_choi'],
  dang_xu_ly: ['chap_nhan', 'tu_choi'],
  chap_nhan: ['hoan_tat'],
}
const buoc = (tt) => LUONG[tt] || []
const LY_DO = { loi_nsx: 'Lỗi nhà sản xuất', giao_sai: 'Giao sai mẫu / cấu hình', khong_dung_mo_ta: 'Không đúng mô tả', khac: 'Lý do khác' }
const nhanLyDo = (v) => LY_DO[v] || (v || '—')

function badge(tt) {
  const mau = {
    cho_xu_ly: 'var(--muted2)', dang_xu_ly: 'var(--acc)',
    chap_nhan: 'var(--ok, #2bd47e)', tu_choi: 'var(--danger, #ff5d7a)', hoan_tat: 'var(--ok, #2bd47e)',
  }[tt] || 'var(--muted2)'
  return { background: `color-mix(in srgb, ${mau} 14%, transparent)`, color: mau }
}
const fmtDateTime = (iso) => (iso ? new Date(iso).toLocaleString('vi-VN') : '')

function demTheoTrangThai(ma) {
  if (!ma) return tatCa.value.length
  return tatCa.value.filter((r) => r.trangThai === ma).length
}

async function tai() {
  loading.value = true
  try {
    tatCa.value = await getReturns()
    apDungLoc()
  } catch (e) {
    tatCa.value = []
    danhSach.value = []
  } finally {
    loading.value = false
  }
}
function apDungLoc() {
  danhSach.value = loc.value ? tatCa.value.filter((r) => r.trangThai === loc.value) : tatCa.value
}
function doiLoc(ma) { loc.value = ma; apDungLoc() }

async function doiTrangThai(r, tt) {
  if (tt === 'tu_choi' && !confirm(`Từ chối yêu cầu ${r.maYeuCau}?`)) return
  dangLuu.value = r.id
  try {
    await updateReturnStatus(r.id, tt, ghiChu.value[r.id] || '')
    ghiChu.value[r.id] = ''
    await tai()
  } catch (e) {
    alert(e?.response?.data?.message || 'Không đổi được trạng thái.')
  } finally {
    dangLuu.value = null
  }
}

onMounted(tai)
</script>

<style scoped>
.tab-chip {
  display: inline-flex; align-items: center; gap: 7px;
  background: var(--card); border: 1px solid var(--line); color: var(--muted2);
  border-radius: 999px; padding: 7px 15px; font-size: 12.7px; cursor: pointer; transition: all 0.15s;
}
.tab-chip:hover { border-color: var(--acc); color: var(--text); }
.tab-chip.active { background: color-mix(in srgb, var(--acc) 14%, transparent); border-color: var(--acc); color: var(--acc); font-weight: 600; }
.btn-ghost {
  background: transparent; border: 1px solid var(--line); color: var(--muted2);
  border-radius: 9px; height: 38px; padding: 0 15px; font-size: 12.7px; cursor: pointer; transition: all 0.15s; white-space: nowrap;
}
.btn-ghost:hover:not(:disabled) { border-color: var(--acc); color: var(--acc); }
.btn-ghost:disabled { opacity: 0.5; cursor: default; }
.ev-chip {
  font-size: 12px; color: var(--muted2); background: var(--card2); border: 1px solid var(--line);
  border-radius: 8px; padding: 6px 11px; text-decoration: none;
}
.ev-chip:hover { border-color: var(--acc); color: var(--acc); }
</style>
