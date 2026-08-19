<script setup>
import { ref, computed, onMounted } from 'vue';
import {
  getGoodsReceipts, getGoodsReceiptDetail, createGoodsReceipt,
  getSuppliers, createSupplier, searchStockVariants,
} from '../api/admin';
import { API_ORIGIN } from '../api/http';
import { money, fmtMoneyInput, parseMoneyInput } from '../data/adminData';
import { ui } from '../uiState';
import DataTable from '../components/DataTable.vue';

/**
 * NHẬP KHO theo chứng từ.
 *
 * Trước đây nhập kho chỉ có một modal 1-dòng (chọn 1 sản phẩm, gõ số lượng, xong) — không ghi
 * được nhà cung cấp, số hoá đơn, tổng tiền lô hàng, và không in ra được gì cho kế toán ký.
 * Màn hình này thay thế nó bằng phiếu nhập đúng nghĩa: nhiều dòng hàng, có nhà cung cấp, có
 * hoá đơn GTGT, chốt tiền hàng/VAT/tổng, và in được (xem AdminGoodsReceiptController).
 */

const TABS = [['phieu', 'Phiếu nhập kho'], ['ncc', 'Nhà cung cấp']];
const tab = ref('phieu');

const phieu = ref([]);
const nhaCungCap = ref([]);
const dangTai = ref(true);

const chiTiet = ref(null);
const dangTaiChiTiet = ref(false);

async function tai() {
  dangTai.value = true;
  try {
    const [p, n] = await Promise.all([getGoodsReceipts(), getSuppliers(true)]);
    phieu.value = p;
    nhaCungCap.value = n;
  } finally {
    dangTai.value = false;
  }
}
onMounted(tai);

async function moChiTiet(p) {
  dangTaiChiTiet.value = true;
  chiTiet.value = null;
  try {
    chiTiet.value = await getGoodsReceiptDetail(p.id);
  } finally {
    dangTaiChiTiet.value = false;
  }
}

/** Mở bản in ở tab mới. ?in=1 để trình duyệt bật luôn hộp thoại in. */
function inPhieu(id) {
  window.open(`${API_ORIGIN}/admin/goods-receipts/${id}/in?in=1`, '_blank', 'noopener');
}

// ===== Lập phiếu mới =====
const moForm = ref(false);
const luuLoi = ref('');
const dangLuu = ref(false);
const form = ref(taoFormRong());

function taoFormRong() {
  return {
    supplierId: '',
    soHoaDon: '',
    ngayHoaDon: '',
    vatPercent: 0,
    ghiChu: '',
    dongHang: [],
  };
}
function moFormMoi() {
  form.value = taoFormRong();
  luuLoi.value = '';
  moForm.value = true;
}

// Ô tìm sản phẩm để thêm dòng hàng — gọi cùng endpoint với modal điều chỉnh kho cũ.
const timSp = ref('');
const ketQuaSp = ref([]);
const dangTimSp = ref(false);
let timer = null;
function onTimSp() {
  clearTimeout(timer);
  const q = timSp.value.trim();
  if (q.length < 2) {
    ketQuaSp.value = [];
    return;
  }
  dangTimSp.value = true;
  timer = setTimeout(async () => {
    try {
      ketQuaSp.value = await searchStockVariants(q);
    } catch (e) {
      ketQuaSp.value = [];
    } finally {
      dangTimSp.value = false;
    }
  }, 280);
}

function themDong(v) {
  // Cùng một biến thể xuất hiện 2 dòng trên một phiếu thì cộng dồn thay vì tạo dòng trùng —
  // hoá đơn nhà cung cấp cũng gộp như vậy.
  const cu = form.value.dongHang.find((d) => d.variantId === v.variantId);
  if (cu) {
    cu.soLuong += 1;
  } else {
    form.value.dongHang.push({
      variantId: v.variantId,
      tenSanPham: v.productName,
      sku: v.sku,
      tonHienTai: v.stock,
      soLuong: 1,
      donGia: 0,
      ghiChu: '',
    });
  }
  timSp.value = '';
  ketQuaSp.value = [];
}
function xoaDong(i) {
  form.value.dongHang.splice(i, 1);
}

const tienHang = computed(() =>
  form.value.dongHang.reduce((a, d) => a + (Number(d.soLuong) || 0) * (Number(d.donGia) || 0), 0),
);
const tienVat = computed(() => Math.round((tienHang.value * (Number(form.value.vatPercent) || 0)) / 100));
const tongTien = computed(() => tienHang.value + tienVat.value);

async function luuPhieu() {
  luuLoi.value = '';
  if (!form.value.dongHang.length) {
    luuLoi.value = 'Phiếu nhập phải có ít nhất 1 dòng hàng.';
    return;
  }
  if (form.value.dongHang.some((d) => !d.soLuong || d.soLuong <= 0)) {
    luuLoi.value = 'Mọi dòng hàng phải có số lượng lớn hơn 0.';
    return;
  }
  dangLuu.value = true;
  try {
    const kq = await createGoodsReceipt({
      supplierId: form.value.supplierId || null,
      soHoaDon: form.value.soHoaDon || null,
      ngayHoaDon: form.value.ngayHoaDon || null,
      vatPercent: Number(form.value.vatPercent) || 0,
      ghiChu: form.value.ghiChu || null,
      dongHang: form.value.dongHang.map((d) => ({
        variantId: d.variantId,
        soLuong: Number(d.soLuong),
        donGia: Number(d.donGia) || 0,
        ghiChu: d.ghiChu || null,
      })),
    });
    moForm.value = false;
    await tai();
    chiTiet.value = kq; // mở luôn phiếu vừa lập để in
  } catch (e) {
    luuLoi.value = e.response?.data?.message || 'Không lưu được phiếu nhập.';
  } finally {
    dangLuu.value = false;
  }
}

// ===== Nhà cung cấp =====
const moFormNcc = ref(false);
const formNcc = ref({ ten: '', maSoThue: '', dienThoai: '', email: '', diaChi: '', nguoiLienHe: '', ghiChu: '' });
const luuLoiNcc = ref('');
async function luuNcc() {
  luuLoiNcc.value = '';
  if (!formNcc.value.ten.trim()) {
    luuLoiNcc.value = 'Nhập tên nhà cung cấp.';
    return;
  }
  try {
    await createSupplier({ ...formNcc.value });
    moFormNcc.value = false;
    formNcc.value = { ten: '', maSoThue: '', dienThoai: '', email: '', diaChi: '', nguoiLienHe: '', ghiChu: '' };
    await tai();
  } catch (e) {
    luuLoiNcc.value = e.response?.data?.message || 'Không lưu được nhà cung cấp.';
  }
}

const ngay = (d) => (d ? new Date(d).toLocaleDateString('vi-VN') : '—');
const ngayGio = (d) =>
  d ? new Date(d).toLocaleString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }) : '—';

// Cột cho DataTable — phễu lọc/sắp xếp kiểu Excel (xem components/DataTable.vue).
const colsPhieu = [
  { key: 'maPhieu', label: 'Số phiếu' },
  { key: 'tenNhaCungCap', label: 'Nhà cung cấp', text: (p) => p.tenNhaCungCap || '(không ghi)' },
  { key: 'soHoaDon', label: 'Số hoá đơn', text: (p) => p.soHoaDon || '—' },
  { key: 'ngayNhap', label: 'Ngày nhập', kieu: 'ngay', text: (p) => ngayGio(p.ngayNhap) },
  { key: 'soDongHang', label: 'Mặt hàng', align: 'right', kieu: 'so' },
  { key: 'tongSoLuong', label: 'Số lượng', align: 'right', kieu: 'so' },
  { key: 'tongTien', label: 'Tổng tiền', align: 'right', kieu: 'so', text: (p) => money(p.tongTien) },
  { key: 'nguoiLap', label: 'Người lập', text: (p) => p.nguoiLap || '—' },
  { key: 'thaoTac', label: '', align: 'right', loc: false },
];
const colsNcc = [
  { key: 'ten', label: 'Nhà cung cấp' },
  { key: 'maSoThue', label: 'Mã số thuế', text: (n) => n.maSoThue || '—' },
  { key: 'dienThoai', label: 'Điện thoại', text: (n) => n.dienThoai || '—' },
  { key: 'nguoiLienHe', label: 'Người liên hệ', text: (n) => n.nguoiLienHe || '—' },
  { key: 'diaChi', label: 'Địa chỉ', text: (n) => n.diaChi || '—' },
];

const thongKe = computed(() => {
  const thangNay = phieu.value.filter((p) => {
    const d = new Date(p.ngayNhap);
    const now = new Date();
    return d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear();
  });
  return [
    { label: 'Tổng số phiếu', value: String(phieu.value.length), icon: 'bi-file-earmark-text', color: 'var(--acc)' },
    { label: 'Phiếu tháng này', value: String(thangNay.length), icon: 'bi-calendar-check', color: 'var(--green)' },
    {
      label: 'Giá trị nhập tháng này',
      value: money(thangNay.reduce((a, p) => a + Number(p.tongTien || 0), 0)),
      icon: 'bi-cash-stack',
      color: 'var(--amber)',
    },
    { label: 'Nhà cung cấp', value: String(nhaCungCap.value.length), icon: 'bi-truck', color: 'var(--acc)' },
  ];
});
</script>

<template>
  <div style="animation: fadeUp 0.35s ease">
    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 16px">
      <div
        v-for="s in thongKe"
        :key="s.label"
        style="background: var(--card); border: 1px solid var(--line); border-radius: 13px; padding: 14px 16px; display: flex; align-items: center; gap: 13px"
      >
        <div
          style="width: 40px; height: 40px; border-radius: 10px; flex: none; display: flex; align-items: center; justify-content: center; font-size: 17px"
          :style="{ background: 'color-mix(in srgb,' + s.color + ' 14%, transparent)', color: s.color }"
        >
          <i class="bi" :class="s.icon"></i>
        </div>
        <div style="min-width: 0">
          <div class="mono" style="font-size: 17px; font-weight: 700; color: var(--text)">{{ s.value }}</div>
          <div style="font-size: 11.5px; color: var(--muted)">{{ s.label }}</div>
        </div>
      </div>
    </div>

    <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 14px">
      <button
        v-for="t in TABS"
        :key="t[0]"
        @click="tab = t[0]"
        :style="{
          background: tab === t[0] ? 'var(--acc)' : 'transparent',
          color: tab === t[0] ? 'var(--acc-ink)' : 'var(--muted)',
          borderColor: tab === t[0] ? 'var(--acc)' : 'var(--line2)',
        }"
        style="height: 34px; padding: 0 16px; border-radius: 9px; border: 1px solid; font-size: 12.5px; font-weight: 700; cursor: pointer; font-family: inherit"
      >
        {{ t[1] }}
      </button>
      <div style="flex: 1"></div>
      <button v-if="tab === 'phieu'" @click="moFormMoi" class="gr-primary">
        <i class="bi bi-plus-lg"></i> Lập phiếu nhập
      </button>
      <button v-else @click="moFormNcc = true" class="gr-primary">
        <i class="bi bi-plus-lg"></i> Thêm nhà cung cấp
      </button>
    </div>

    <div v-if="dangTai" style="padding: 50px; text-align: center; color: var(--muted); font-size: 13px">Đang tải...</div>

    <div v-else style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; overflow: hidden">
      <DataTable
        v-if="tab === 'phieu'"
        :columns="colsPhieu"
        :rows="phieu"
        :tim-kiem="ui.search"
        click-duoc
        trong="Chưa có phiếu nhập kho nào. Bấm “Lập phiếu nhập” để tạo phiếu đầu tiên."
        @row-click="moChiTiet"
      >
        <template #o-maPhieu="{ row: p }">
          <span class="mono" style="color: var(--acc); font-weight: 700">{{ p.maPhieu }}</span>
        </template>
        <template #o-tenNhaCungCap="{ row: p }">
          <span :style="{ color: p.tenNhaCungCap ? 'var(--text)' : 'var(--muted)' }">
            {{ p.tenNhaCungCap || '(không ghi)' }}
          </span>
        </template>
        <template #o-soHoaDon="{ row: p }">
          <span class="mono" style="font-size: 12px" :style="{ color: p.soHoaDon ? 'var(--muted2)' : 'var(--amber)' }">
            {{ p.soHoaDon || 'chưa có HĐ' }}
          </span>
        </template>
        <template #o-ngayNhap="{ row: p }">
          <span style="color: var(--muted2); font-size: 12px">{{ ngayGio(p.ngayNhap) }}</span>
        </template>
        <template #o-tongTien="{ row: p }">
          <span class="mono" style="font-weight: 700">{{ money(p.tongTien) }}</span>
        </template>
        <template #o-thaoTac="{ row: p }">
          <button @click.stop="inPhieu(p.id)" title="In phiếu nhập kho" class="gr-icon">
            <i class="bi bi-printer"></i>
          </button>
        </template>
      </DataTable>

      <DataTable
        v-else
        :columns="colsNcc"
        :rows="nhaCungCap"
        :tim-kiem="ui.search"
        trong="Chưa có nhà cung cấp nào."
      >
        <template #o-ten="{ row: n }">
          <div style="font-weight: 600; color: var(--text)">{{ n.ten }}</div>
          <div v-if="n.email" style="font-size: 11.5px; color: var(--muted); margin-top: 2px">{{ n.email }}</div>
        </template>
      </DataTable>
    </div>

    <!-- ===== Modal LẬP PHIẾU ===== -->
    <Teleport to="body">
      <div v-if="moForm" class="gr-mask" @click.self="moForm = false">
        <div class="gr-modal">
          <div class="gr-head">
            <div>
              <div style="font-size: 16px; font-weight: 700; color: var(--text)">Lập phiếu nhập kho</div>
              <div style="font-size: 12px; color: var(--muted); margin-top: 2px">
                Số phiếu sinh tự động khi lưu · hàng được cộng vào kho ngay
              </div>
            </div>
            <button class="gr-x" @click="moForm = false"><i class="bi bi-x-lg"></i></button>
          </div>

          <div class="gr-body">
            <div class="gr-grid">
              <label>
                <span>Nhà cung cấp</span>
                <select v-model="form.supplierId" class="fld">
                  <option value="">— Không ghi nhà cung cấp —</option>
                  <option v-for="n in nhaCungCap" :key="n.id" :value="n.id">{{ n.ten }}</option>
                </select>
              </label>
              <label>
                <span>Số hoá đơn GTGT</span>
                <input v-model="form.soHoaDon" class="fld" placeholder="VD: 0001234" />
              </label>
              <label>
                <span>Ngày hoá đơn</span>
                <input v-model="form.ngayHoaDon" type="date" class="fld" />
              </label>
              <label>
                <span>Thuế VAT (%)</span>
                <input v-model.number="form.vatPercent" type="number" min="0" max="100" class="fld" />
              </label>
            </div>

            <!-- Thêm dòng hàng -->
            <div class="gr-label">Dòng hàng</div>
            <div style="position: relative; margin-bottom: 10px">
              <input
                v-model="timSp"
                @input="onTimSp"
                class="fld"
                placeholder="Gõ tên sản phẩm hoặc SKU để thêm vào phiếu…"
              />
              <div v-if="ketQuaSp.length" class="gr-goiy">
                <button v-for="v in ketQuaSp" :key="v.variantId" @click="themDong(v)" class="gr-goiy-row">
                  <span style="flex: 1; min-width: 0">
                    <span style="display: block; color: var(--text)">{{ v.productName }}</span>
                    <span class="mono" style="font-size: 11px; color: var(--muted)">{{ v.sku }}</span>
                  </span>
                  <span class="mono" style="font-size: 11.5px; color: var(--muted2)">tồn {{ v.stock }}</span>
                </button>
              </div>
              <div v-else-if="dangTimSp" style="position: absolute; right: 12px; top: 11px; font-size: 11.5px; color: var(--muted)">
                đang tìm…
              </div>
            </div>

            <div v-if="!form.dongHang.length" class="gr-trong">
              Chưa có dòng hàng nào — tìm sản phẩm ở ô trên để thêm.
            </div>

            <table v-else class="gr-lines">
              <thead>
                <tr>
                  <th>Sản phẩm</th>
                  <th style="width: 78px">Tồn</th>
                  <th style="width: 92px">Số lượng</th>
                  <th style="width: 132px">Đơn giá nhập</th>
                  <th style="width: 118px">Thành tiền</th>
                  <th style="width: 40px"></th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(d, i) in form.dongHang" :key="d.variantId">
                  <td>
                    <div style="color: var(--text)">{{ d.tenSanPham }}</div>
                    <div class="mono" style="font-size: 11px; color: var(--muted)">{{ d.sku }}</div>
                  </td>
                  <td class="mono" style="text-align: center; color: var(--muted2)">{{ d.tonHienTai }}</td>
                  <td><input v-model.number="d.soLuong" type="number" min="1" class="fld fld-sm" /></td>
                  <td>
                    <input
                      :value="fmtMoneyInput(d.donGia)"
                      @input="d.donGia = parseMoneyInput($event.target.value)"
                      inputmode="numeric"
                      class="fld fld-sm"
                    />
                  </td>
                  <td class="mono" style="text-align: right; font-weight: 600; color: var(--text)">
                    {{ money((Number(d.soLuong) || 0) * (Number(d.donGia) || 0)) }}
                  </td>
                  <td>
                    <button class="gr-icon danger" @click="xoaDong(i)"><i class="bi bi-trash3"></i></button>
                  </td>
                </tr>
              </tbody>
            </table>

            <label style="display: block; margin-top: 12px">
              <span class="gr-label">Ghi chú</span>
              <input v-model="form.ghiChu" class="fld" placeholder="VD: Hàng nhập theo hợp đồng số 12/2026" />
            </label>

            <div class="gr-tong">
              <div><span>Tiền hàng</span><b class="mono">{{ money(tienHang) }}</b></div>
              <div><span>Thuế VAT ({{ form.vatPercent || 0 }}%)</span><b class="mono">{{ money(tienVat) }}</b></div>
              <div class="cuoi"><span>Tổng cộng</span><b class="mono">{{ money(tongTien) }}</b></div>
            </div>

            <div v-if="luuLoi" class="gr-loi">{{ luuLoi }}</div>
          </div>

          <div class="gr-foot">
            <button class="gr-ghost" @click="moForm = false">Huỷ</button>
            <button class="gr-primary" :disabled="dangLuu" @click="luuPhieu">
              {{ dangLuu ? 'Đang lưu…' : 'Lưu phiếu & cộng kho' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- ===== Modal CHI TIẾT PHIẾU ===== -->
    <Teleport to="body">
      <div v-if="chiTiet || dangTaiChiTiet" class="gr-mask" @click.self="chiTiet = null">
        <div class="gr-modal">
          <div v-if="dangTaiChiTiet" style="padding: 50px; text-align: center; color: var(--muted)">Đang tải…</div>
          <template v-else-if="chiTiet">
            <div class="gr-head">
              <div>
                <div class="mono" style="font-size: 16px; font-weight: 700; color: var(--acc)">{{ chiTiet.maPhieu }}</div>
                <div style="font-size: 12px; color: var(--muted); margin-top: 2px">
                  {{ ngayGio(chiTiet.ngayNhap) }} · lập bởi {{ chiTiet.nguoiLap || '—' }}
                </div>
              </div>
              <button class="gr-x" @click="chiTiet = null"><i class="bi bi-x-lg"></i></button>
            </div>

            <div class="gr-body">
              <div class="gr-grid">
                <div class="gr-kv"><span>Nhà cung cấp</span><b>{{ chiTiet.tenNhaCungCap || '(không ghi)' }}</b></div>
                <div class="gr-kv"><span>Mã số thuế</span><b>{{ chiTiet.maSoThueNcc || '—' }}</b></div>
                <div class="gr-kv"><span>Số hoá đơn</span><b>{{ chiTiet.soHoaDon || '—' }}</b></div>
                <div class="gr-kv"><span>Ngày hoá đơn</span><b>{{ ngay(chiTiet.ngayHoaDon) }}</b></div>
              </div>

              <table class="gr-lines" style="margin-top: 14px">
                <thead>
                  <tr>
                    <th>Sản phẩm</th>
                    <th style="width: 84px">Số lượng</th>
                    <th style="width: 118px">Đơn giá</th>
                    <th style="width: 122px">Thành tiền</th>
                    <th style="width: 92px">Tồn sau nhập</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="d in chiTiet.chiTiet" :key="d.id">
                    <td>
                      <div style="color: var(--text)">{{ d.tenSanPham }}</div>
                      <div class="mono" style="font-size: 11px; color: var(--muted)">{{ d.sku }}</div>
                      <div v-if="d.ghiChu" style="font-size: 11.5px; color: var(--muted2); margin-top: 2px">{{ d.ghiChu }}</div>
                    </td>
                    <td class="mono" style="text-align: center">{{ d.soLuong }}</td>
                    <td class="mono" style="text-align: right; color: var(--muted2)">{{ money(d.donGia) }}</td>
                    <td class="mono" style="text-align: right; font-weight: 600">{{ money(d.thanhTien) }}</td>
                    <td class="mono" style="text-align: center; color: var(--green)">{{ d.tonSauNhap }}</td>
                  </tr>
                </tbody>
              </table>

              <div v-if="chiTiet.ghiChu" style="margin-top: 12px; font-size: 12.5px; color: var(--muted2)">
                <b style="color: var(--text)">Ghi chú:</b> {{ chiTiet.ghiChu }}
              </div>

              <div class="gr-tong">
                <div><span>Tiền hàng</span><b class="mono">{{ money(chiTiet.tienHang) }}</b></div>
                <div><span>Thuế VAT ({{ Number(chiTiet.vatPercent) }}%)</span><b class="mono">{{ money(chiTiet.tienVat) }}</b></div>
                <div class="cuoi"><span>Tổng cộng</span><b class="mono">{{ money(chiTiet.tongTien) }}</b></div>
              </div>
            </div>

            <div class="gr-foot">
              <button class="gr-ghost" @click="chiTiet = null">Đóng</button>
              <button class="gr-primary" @click="inPhieu(chiTiet.id)">
                <i class="bi bi-printer"></i> In phiếu / Xuất PDF
              </button>
            </div>
          </template>
        </div>
      </div>
    </Teleport>

    <!-- ===== Modal NHÀ CUNG CẤP ===== -->
    <Teleport to="body">
      <div v-if="moFormNcc" class="gr-mask" @click.self="moFormNcc = false">
        <div class="gr-modal" style="max-width: 560px">
          <div class="gr-head">
            <div style="font-size: 16px; font-weight: 700; color: var(--text)">Thêm nhà cung cấp</div>
            <button class="gr-x" @click="moFormNcc = false"><i class="bi bi-x-lg"></i></button>
          </div>
          <div class="gr-body">
            <div class="gr-grid">
              <label><span>Tên nhà cung cấp *</span><input v-model="formNcc.ten" class="fld" /></label>
              <label><span>Mã số thuế</span><input v-model="formNcc.maSoThue" class="fld" /></label>
              <label><span>Điện thoại</span><input v-model="formNcc.dienThoai" class="fld" /></label>
              <label><span>Email</span><input v-model="formNcc.email" class="fld" /></label>
              <label><span>Người liên hệ</span><input v-model="formNcc.nguoiLienHe" class="fld" /></label>
              <label><span>Địa chỉ</span><input v-model="formNcc.diaChi" class="fld" /></label>
            </div>
            <div v-if="luuLoiNcc" class="gr-loi">{{ luuLoiNcc }}</div>
          </div>
          <div class="gr-foot">
            <button class="gr-ghost" @click="moFormNcc = false">Huỷ</button>
            <button class="gr-primary" @click="luuNcc">Lưu</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<style scoped>
.gr-primary {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  height: 34px;
  padding: 0 15px;
  border-radius: 9px;
  border: none;
  background: var(--acc);
  color: var(--acc-ink);
  font-size: 12.5px;
  font-weight: 700;
  cursor: pointer;
  font-family: inherit;
}
.gr-primary:disabled { opacity: 0.55; cursor: default; }
.gr-ghost {
  height: 34px;
  padding: 0 15px;
  border-radius: 9px;
  border: 1px solid var(--line2);
  background: transparent;
  color: var(--muted2);
  font-size: 12.5px;
  font-weight: 600;
  cursor: pointer;
  font-family: inherit;
}
.gr-icon {
  width: 30px;
  height: 30px;
  border-radius: 8px;
  border: 1px solid var(--line2);
  background: var(--card);
  color: var(--muted2);
  cursor: pointer;
}
.gr-icon.danger { color: var(--sale); }

.gr-mask {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.55);
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding: 34px 20px;
  z-index: 250;
  overflow-y: auto;
}
.gr-modal {
  background: var(--card);
  border: 1px solid var(--line2);
  border-radius: 15px;
  width: 100%;
  max-width: 900px;
  display: flex;
  flex-direction: column;
}
.gr-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 14px;
  padding: 17px 20px;
  border-bottom: 1px solid var(--line);
}
.gr-x {
  width: 30px;
  height: 30px;
  border-radius: 8px;
  border: 1px solid var(--line2);
  background: transparent;
  color: var(--muted2);
  cursor: pointer;
  flex: none;
}
.gr-body { padding: 18px 20px; }
.gr-foot {
  display: flex;
  justify-content: flex-end;
  gap: 9px;
  padding: 15px 20px;
  border-top: 1px solid var(--line);
}

.gr-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}
.gr-grid label { display: flex; flex-direction: column; gap: 5px; }
.gr-grid label > span,
.gr-label {
  font-size: 11px;
  font-weight: 600;
  color: var(--muted);
  text-transform: uppercase;
  letter-spacing: 0.4px;
}
.gr-label { display: block; margin: 16px 0 7px; }
.gr-kv { display: flex; flex-direction: column; gap: 3px; font-size: 13px; }
.gr-kv span { font-size: 11px; color: var(--muted); text-transform: uppercase; letter-spacing: 0.4px; }
.gr-kv b { color: var(--text); font-weight: 600; }

.gr-goiy {
  position: absolute;
  left: 0;
  right: 0;
  top: 42px;
  z-index: 5;
  background: var(--card2);
  border: 1px solid var(--line2);
  border-radius: 10px;
  max-height: 232px;
  overflow-y: auto;
  box-shadow: 0 14px 34px rgba(0, 0, 0, 0.4);
  padding: 5px;
}
.gr-goiy-row {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  padding: 7px 9px;
  border: none;
  border-radius: 7px;
  background: transparent;
  color: var(--text);
  font-size: 12.5px;
  cursor: pointer;
  text-align: left;
  font-family: inherit;
}
.gr-goiy-row:hover { background: var(--hover); }

.gr-lines { width: 100%; border-collapse: collapse; font-size: 12.5px; }
.gr-lines th {
  text-align: left;
  padding: 8px 10px;
  font-size: 10.5px;
  font-weight: 600;
  color: var(--muted);
  text-transform: uppercase;
  letter-spacing: 0.4px;
  background: var(--card2);
}
.gr-lines td { padding: 8px 10px; border-top: 1px solid var(--line); vertical-align: middle; }
.fld-sm { height: 30px; font-size: 12px; width: 100%; }

.gr-trong {
  padding: 26px;
  text-align: center;
  color: var(--muted);
  font-size: 12.5px;
  border: 1px dashed var(--line2);
  border-radius: 10px;
}

.gr-tong {
  margin-top: 16px;
  margin-left: auto;
  width: 300px;
  font-size: 13px;
}
.gr-tong > div {
  display: flex;
  justify-content: space-between;
  padding: 6px 0;
  color: var(--muted2);
}
.gr-tong > div b { color: var(--text); font-weight: 600; }
.gr-tong .cuoi {
  border-top: 1px solid var(--line);
  margin-top: 4px;
  padding-top: 10px;
  font-weight: 700;
  color: var(--text);
}
.gr-tong .cuoi b { color: var(--acc); font-size: 16px; }

.gr-loi {
  margin-top: 12px;
  padding: 10px 13px;
  border-radius: 9px;
  background: color-mix(in srgb, var(--sale) 12%, transparent);
  border: 1px solid color-mix(in srgb, var(--sale) 30%, transparent);
  color: var(--sale);
  font-size: 12.5px;
}
</style>
