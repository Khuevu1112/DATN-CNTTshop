<template>
  <div style="animation: fadeUp 0.35s ease">
    <!-- Số liệu nhanh -->
    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 16px">
      <div
        v-for="s in stats"
        :key="s.label"
        style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 16px 18px"
      >
        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px">
          <i class="bi" :class="s.icon" :style="{ color: s.color, fontSize: '14px' }"></i>
          <span style="font-size: 12px; color: var(--muted)">{{ s.label }}</span>
        </div>
        <div class="mono" style="font-size: 21px; font-weight: 700; color: var(--text); line-height: 1">
          {{ s.value }}
        </div>
      </div>
    </div>

    <!-- Lọc trạng thái -->
    <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 16px">
      <button
        v-for="t in TABS"
        :key="t.ma"
        class="tab-chip"
        :class="{ active: loc === t.ma }"
        @click="doiLoc(t.ma)"
      >
        {{ t.ten }}
        <span
          class="mono"
          style="font-size: 10.5px; padding: 0 6px; border-radius: 8px; background: var(--card2); color: var(--muted)"
        >
          {{ demTheoTrangThai(t.ma) }}
        </span>
      </button>
    </div>

    <div v-if="loading" class="spin"></div>

    <div
      v-else-if="!danhSach.length"
      style="
        background: var(--card);
        border: 1px solid var(--line);
        border-radius: 14px;
        padding: 48px 20px;
        text-align: center;
        color: var(--muted);
        font-size: 13.5px;
      "
    >
      Chưa có lịch hẹn nào{{ loc ? ' ở trạng thái này' : '' }}.
    </div>

    <!-- Danh sách -->
    <!-- Chế độ THẺ của DataTable: giữ nguyên thẻ lịch hẹn (mô tả dài + nút xử lý theo bước),
         nhưng lọc/sắp xếp được y hệt các bảng khác qua dãy chip phía trên. -->
    <DataTable v-else che-do="the" :columns="cols" :rows="danhSach" trong="Chưa có lịch hẹn nào.">
      <template #the="{ rows }">
    <div style="display: flex; flex-direction: column; gap: 12px">
      <div
        v-for="l in rows"
        :key="l.id"
        style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 18px 20px"
      >
        <div
          style="
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 14px;
            flex-wrap: wrap;
            margin-bottom: 14px;
          "
        >
          <div>
            <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap">
              <span class="mono" style="font-size: 14px; font-weight: 700; color: var(--acc)">
                {{ l.maLich }}
              </span>
              <span class="badge" :style="badgeStyle(l.trangThai)">{{ l.nhanTrangThai }}</span>
              <span
                v-if="l.warrantyId"
                class="badge"
                style="background: color-mix(in srgb, var(--ok, #2bd47e) 14%, transparent); color: var(--ok, #2bd47e)"
              >
                Có phiếu bảo hành
              </span>
            </div>
            <div style="font-size: 12px; color: var(--muted); margin-top: 6px">
              Đặt lúc {{ fmtDateTime(l.createdAt) }}
            </div>
          </div>

          <div style="text-align: right">
            <div style="font-size: 15px; font-weight: 700; color: var(--text)">
              {{ fmtDate(l.ngayHen) }} · {{ l.khungGio }}
            </div>
            <div style="font-size: 12px; color: var(--muted); margin-top: 3px">{{ l.tenTrungTam }}</div>
          </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px">
          <div>
            <div class="kv"><span>Khách</span><b>{{ l.hoTen }}</b></div>
            <div class="kv"><span>Điện thoại</span><b>{{ l.dienThoai }}</b></div>
            <div v-if="l.email" class="kv"><span>Email</span><b>{{ l.email }}</b></div>
          </div>
          <div>
            <div class="kv"><span>Thiết bị</span><b>{{ tenLoai(l.loaiThietBi) }}</b></div>
            <div v-if="l.model" class="kv"><span>Model</span><b>{{ l.model }}</b></div>
            <div class="kv"><span>Trung tâm</span><b>{{ l.diaChiTrungTam }}</b></div>
          </div>
        </div>

        <div
          style="
            padding: 12px 14px;
            background: var(--card2);
            border-radius: 10px;
            font-size: 13px;
            color: var(--text);
            line-height: 1.6;
            white-space: pre-wrap;
            margin-bottom: 12px;
          "
        >
          <b style="color: var(--muted2); font-size: 11.5px; display: block; margin-bottom: 5px">
            TÌNH TRẠNG KHÁCH MÔ TẢ
          </b>
          {{ l.moTaLoi }}
        </div>

        <div v-if="l.ghiChuKtv" style="font-size: 12.5px; color: var(--muted2); margin-bottom: 12px">
          <b style="color: var(--text)">Ghi chú KTV:</b> {{ l.ghiChuKtv }}
        </div>

        <div
          v-if="l.trangThai === 'hoan_thanh'"
          style="font-size: 12.5px; color: var(--muted2); margin-bottom: 12px"
        >
          <b style="color: var(--text)">Chi phí:</b>
          <span v-if="l.chiPhi != null && Number(l.chiPhi) > 0"> {{ fmtTien(l.chiPhi) }}</span>
          <span v-else style="color: var(--ok, #2bd47e)"> Miễn phí (bảo hành)</span>
        </div>

        <!-- Chuyển trạng thái. Chỉ hiện bước hợp lệ kế tiếp — backend cũng chặn nhảy cóc, nhưng
             hiện nút rồi báo lỗi khi bấm là thiết kế tồi. -->
        <div v-if="buocTiepTheo(l.trangThai).length" style="display: flex; gap: 9px; flex-wrap: wrap; align-items: center">
          <input
            v-model="ghiChu[l.id]"
            class="fld"
            style="flex: 1; min-width: 200px; height: 38px"
            placeholder="Ghi chú (tuỳ chọn, khách sẽ nhận được thông báo này)"
          />
          <!-- Ô chi phí chỉ hiện khi bước kế tiếp có "hoàn thành" — đây là lúc ghi vào lịch sử
               bảo hành. Để trống = ca miễn phí (bảo hành trong hạn). -->
          <input
            v-if="buocTiepTheo(l.trangThai).includes('hoan_thanh')"
            v-model="chiPhi[l.id]"
            type="number"
            min="0"
            class="fld"
            style="width: 160px; height: 38px"
            placeholder="Chi phí (đ)"
          />
          <button
            v-for="b in buocTiepTheo(l.trangThai)"
            :key="b"
            class="btn-ghost"
            :disabled="dangLuu === l.id"
            @click="doiTrangThai(l, b)"
          >
            {{ NHAN[b] }}
          </button>
        </div>
        <div v-else style="font-size: 12px; color: var(--muted)">
          Lịch hẹn đã kết thúc, không còn bước xử lý nào.
        </div>
      </div>
    </div>
      </template>
    </DataTable>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { getServiceAppointments, updateAppointmentStatus } from '../api/admin';
import DataTable from '../components/DataTable.vue';

// Trường lọc cho chế độ thẻ — cùng phễu Excel như các bảng khác (xem components/DataTable.vue).
const cols = [
  { key: 'maLich', label: 'Mã lịch' },
  { key: 'hoTen', label: 'Khách hàng', text: (l) => l.hoTen + (l.dienThoai ? ' · ' + l.dienThoai : '') },
  { key: 'tenTrungTam', label: 'Trung tâm' },
  { key: 'loaiThietBi', label: 'Thiết bị', text: (l) => tenLoai(l.loaiThietBi) },
  { key: 'ngayHen', label: 'Ngày hẹn', kieu: 'ngay' },
  { key: 'khungGio', label: 'Khung giờ', text: (l) => l.khungGio || '—' },
  { key: 'trangThai', label: 'Trạng thái', text: (l) => l.nhanTrangThai || l.trangThai },
  { key: 'chiPhi', label: 'Chi phí', kieu: 'so', text: (l) => (l.chiPhi != null ? Number(l.chiPhi).toLocaleString('vi-VN') + '₫' : 'Miễn phí') },
];

const danhSach = ref([]);
const tatCa = ref([]);
const loading = ref(true);
const loc = ref('');
const ghiChu = ref({});
const chiPhi = ref({});
const dangLuu = ref(null);

const fmtTien = (n) => (n == null ? '—' : Number(n).toLocaleString('vi-VN') + 'đ');

const TABS = [
  { ma: '', ten: 'Tất cả' },
  { ma: 'cho_xac_nhan', ten: 'Chờ xác nhận' },
  { ma: 'da_xac_nhan', ten: 'Đã xác nhận' },
  { ma: 'dang_xu_ly', ten: 'Đang xử lý' },
  { ma: 'hoan_thanh', ten: 'Hoàn thành' },
  { ma: 'da_huy', ten: 'Đã huỷ' },
];

const NHAN = {
  da_xac_nhan: 'Xác nhận lịch',
  dang_xu_ly: 'Bắt đầu xử lý',
  hoan_thanh: 'Hoàn thành',
  khach_khong_den: 'Khách không đến',
  da_huy: 'Huỷ lịch',
};

// Phải khớp LUONG_HOP_LE trong ServiceAppointmentService — sai lệch thì nút hiện ra nhưng bấm
// vào backend từ chối.
const LUONG = {
  cho_xac_nhan: ['da_xac_nhan', 'da_huy'],
  da_xac_nhan: ['dang_xu_ly', 'khach_khong_den', 'da_huy'],
  dang_xu_ly: ['hoan_thanh', 'da_huy'],
};
const buocTiepTheo = (tt) => LUONG[tt] || [];

const LOAI = {
  laptop: 'Laptop',
  pc: 'PC / Máy bàn',
  man_hinh: 'Màn hình',
  linh_kien: 'Linh kiện lẻ',
  ngoai_vi: 'Thiết bị ngoại vi',
};
const tenLoai = (m) => LOAI[m] || m;

const stats = computed(() => [
  {
    label: 'Chờ xác nhận',
    value: demTheoTrangThai('cho_xac_nhan'),
    icon: 'bi-hourglass-split',
    color: 'var(--warn, #f5a524)',
  },
  {
    label: 'Đang xử lý',
    value: demTheoTrangThai('dang_xu_ly'),
    icon: 'bi-tools',
    color: 'var(--acc)',
  },
  {
    label: 'Hôm nay',
    value: tatCa.value.filter((l) => l.ngayHen === homNay() && l.trangThai !== 'da_huy').length,
    icon: 'bi-calendar-day',
    color: 'var(--acc)',
  },
  {
    label: 'Tổng lịch hẹn',
    value: tatCa.value.length,
    icon: 'bi-calendar-check',
    color: 'var(--muted2)',
  },
]);

function homNay() {
  const d = new Date();
  const p = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`;
}

function demTheoTrangThai(ma) {
  if (!ma) return tatCa.value.length;
  return tatCa.value.filter((l) => l.trangThai === ma).length;
}

function badgeStyle(tt) {
  const mau = {
    cho_xac_nhan: 'var(--warn, #f5a524)',
    da_xac_nhan: 'var(--ok, #2bd47e)',
    dang_xu_ly: 'var(--acc)',
    hoan_thanh: 'var(--ok, #2bd47e)',
    khach_khong_den: 'var(--danger, #ff5d7a)',
    da_huy: 'var(--danger, #ff5d7a)',
  }[tt] || 'var(--muted2)';
  return { background: `color-mix(in srgb, ${mau} 14%, transparent)`, color: mau };
}

const fmtDate = (iso) => {
  if (!iso) return '';
  const [y, m, d] = String(iso).slice(0, 10).split('-');
  return `${d}/${m}/${y}`;
};
const fmtDateTime = (iso) => (iso ? new Date(iso).toLocaleString('vi-VN') : '');

async function tai() {
  loading.value = true;
  try {
    // Luôn nạp toàn bộ để đếm số ở tab và ô thống kê; lọc hiển thị ở phía client. Số lịch hẹn
    // của một shop không đủ lớn để phải phân trang, và cách này tránh 6 lần gọi API chỉ để đếm.
    tatCa.value = await getServiceAppointments();
    apDungLoc();
  } catch (e) {
    tatCa.value = [];
    danhSach.value = [];
  } finally {
    loading.value = false;
  }
}

function apDungLoc() {
  danhSach.value = loc.value ? tatCa.value.filter((l) => l.trangThai === loc.value) : tatCa.value;
}

function doiLoc(ma) {
  loc.value = ma;
  apDungLoc();
}

async function doiTrangThai(l, trangThaiMoi) {
  if (trangThaiMoi === 'da_huy' && !confirm(`Huỷ lịch hẹn ${l.maLich}?`)) return;
  dangLuu.value = l.id;
  try {
    // Chi phí chỉ gửi kèm khi hoàn thành — con số này đi vào lịch sử bảo hành của khách.
    const cp = trangThaiMoi === 'hoan_thanh' && chiPhi.value[l.id] ? Number(chiPhi.value[l.id]) : null;
    await updateAppointmentStatus(l.id, trangThaiMoi, ghiChu.value[l.id] || '', cp);
    ghiChu.value[l.id] = '';
    chiPhi.value[l.id] = '';
    await tai();
  } catch (e) {
    alert(e?.response?.data?.message || 'Không đổi được trạng thái lịch hẹn.');
  } finally {
    dangLuu.value = null;
  }
}

onMounted(tai);
</script>

<style scoped>
.kv {
  display: flex;
  gap: 12px;
  font-size: 12.6px;
  padding: 4px 0;
}
.kv span {
  color: var(--muted);
  flex: none;
  width: 92px;
}
.kv b {
  color: var(--text);
  font-weight: 600;
  flex: 1;
  line-height: 1.5;
}

.tab-chip {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  background: var(--card);
  border: 1px solid var(--line);
  color: var(--muted2);
  border-radius: 999px;
  padding: 7px 15px;
  font-size: 12.7px;
  cursor: pointer;
  transition: all 0.15s;
}
.tab-chip:hover {
  border-color: var(--acc);
  color: var(--text);
}
.tab-chip.active {
  background: color-mix(in srgb, var(--acc) 14%, transparent);
  border-color: var(--acc);
  color: var(--acc);
  font-weight: 600;
}

.btn-ghost {
  background: transparent;
  border: 1px solid var(--line);
  color: var(--muted2);
  border-radius: 9px;
  height: 38px;
  padding: 0 15px;
  font-size: 12.7px;
  cursor: pointer;
  transition: all 0.15s;
  white-space: nowrap;
}
.btn-ghost:hover:not(:disabled) {
  border-color: var(--acc);
  color: var(--acc);
}
.btn-ghost:disabled {
  opacity: 0.5;
  cursor: default;
}
</style>
