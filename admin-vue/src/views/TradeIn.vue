<template>
  <div style="animation: fadeUp 0.35s ease">
    <!-- Lọc theo trạng thái -->
    <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 10px 14px; display: flex; align-items: center; gap: 8px; margin-bottom: 14px; flex-wrap: wrap">
      <button
        v-for="f in FILTERS" :key="f[0]"
        @click="loc = f[0]; tai()"
        :style="{
          background: loc === f[0] ? 'var(--acc)' : 'transparent',
          color: loc === f[0] ? 'var(--acc-ink)' : 'var(--muted)',
          borderColor: loc === f[0] ? 'var(--acc)' : 'var(--line)',
        }"
        style="height: 32px; padding: 0 14px; border: 1px solid; border-radius: 8px; font-size: 12.5px; font-weight: 600; cursor: pointer; font-family: inherit"
      >
        {{ f[1] }}
      </button>
      <div style="flex: 1"></div>
      <span class="mono" style="font-size: 11.5px; color: var(--muted)">{{ ds.length }} yêu cầu</span>
    </div>

    <div v-if="loading" style="padding: 40px; text-align: center; color: var(--muted)">Đang tải...</div>
    <div v-else-if="!ds.length" style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 40px; text-align: center; color: var(--muted); font-size: 13px">
      Không có yêu cầu nào.
    </div>

    <!-- Chế độ THẺ của DataTable: giữ nguyên thẻ định giá (ảnh hiện trạng + các bước xử lý),
         nhưng lọc/sắp xếp được y hệt các bảng khác qua dãy chip phía trên. -->
    <DataTable v-else che-do="the" :columns="cols" :rows="ds" trong="Chưa có yêu cầu thu cũ nào.">
      <template #the="{ rows }">
    <div style="display: flex; flex-direction: column; gap: 12px">
      <div v-for="y in rows" :key="y.id" style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 16px 18px">
        <div style="display: flex; align-items: flex-start; gap: 14px; flex-wrap: wrap">
          <!-- Ảnh hiện trạng -->
          <div style="display: flex; gap: 6px; flex: none">
            <img
              v-for="(a, i) in y.anh" :key="i" :src="resolveImageUrl(a)"
              @click="anhPhongTo = resolveImageUrl(a)"
              style="width: 64px; height: 64px; object-fit: cover; border-radius: 8px; background: var(--card2); cursor: zoom-in"
            />
            <div v-if="!y.anh.length" style="width: 64px; height: 64px; border-radius: 8px; background: var(--card2); display: flex; align-items: center; justify-content: center; color: var(--muted)">—</div>
          </div>

          <!-- Thông tin máy -->
          <div style="flex: 1; min-width: 220px">
            <div style="display: flex; align-items: center; gap: 9px; flex-wrap: wrap">
              <span style="font-size: 14.5px; font-weight: 700; color: var(--text)">{{ y.model }}</span>
              <span
                :style="{ background: mauNen(y.trangThai), color: mauChu(y.trangThai) }"
                style="font-size: 10.5px; font-weight: 700; padding: 3px 9px; border-radius: 20px"
              >{{ y.nhanTrangThai }}</span>
            </div>
            <div style="font-size: 12px; color: var(--muted); margin-top: 4px">
              {{ y.hang || '—' }} · {{ nhanLoai(y.loaiThietBi) }} · {{ nhanTinhTrang(y.tinhTrangKhai) }}
              <span v-if="y.namMua"> · mua {{ y.namMua }}</span>
            </div>
            <div style="font-size: 12px; color: var(--muted2); margin-top: 4px">
              <b>{{ y.tenKhach }}</b> · {{ y.soDienThoaiKhach || '—' }}
              · gửi {{ new Date(y.createdAt).toLocaleDateString('vi-VN') }}
            </div>
            <div v-if="y.moTa" style="font-size: 12px; color: var(--muted); margin-top: 5px; line-height: 1.5">
              “{{ y.moTa }}”
            </div>
          </div>

          <!-- Giá -->
          <div style="flex: none; text-align: right; min-width: 130px">
            <div v-if="y.giaTamTinh" style="font-size: 12px; color: var(--muted)">
              Tạm tính<br />
              <b class="mono" style="font-size: 14px; color: var(--text)">{{ tien(y.giaTamTinh) }}</b>
            </div>
            <div v-if="y.giaChot" style="font-size: 12px; color: var(--muted); margin-top: 6px">
              Chốt<br />
              <b class="mono" style="font-size: 16px; color: var(--acc)">{{ tien(y.giaChot) }}</b>
            </div>
          </div>
        </div>

        <div v-if="y.ghiChuKtv" style="font-size: 12px; color: var(--muted2); margin-top: 10px; padding: 8px 11px; background: var(--card2); border-radius: 8px">
          Ghi chú kỹ thuật: {{ y.ghiChuKtv }}
        </div>

        <div v-if="loi[y.id]" style="font-size: 12px; color: #ff5b5b; margin-top: 10px">{{ loi[y.id] }}</div>

        <!-- Hành động theo đúng bước hiện tại — service chặn lại lần nữa nếu nhảy cóc -->
        <div style="display: flex; gap: 8px; margin-top: 12px; flex-wrap: wrap; align-items: center">
          <template v-if="y.trangThai === 'cho_dinh_gia'">
            <input v-model="nhap[y.id]" type="number" placeholder="Giá tạm tính" class="ti-inp" />
            <input v-model="ghiChu[y.id]" placeholder="Ghi chú (không bắt buộc)" class="ti-inp" style="flex: 1; min-width: 160px" />
            <button class="ti-primary" @click="baoGia(y)">Báo giá tạm tính</button>
            <button class="ti-ghost" @click="doiTt(y, 'tu_choi_thu')">Từ chối thu</button>
          </template>

          <template v-else-if="y.trangThai === 'da_bao_gia'">
            <span style="font-size: 12px; color: var(--muted)">Đang chờ khách xác nhận mức giá.</span>
          </template>

          <template v-else-if="y.trangThai === 'khach_dong_y'">
            <span style="font-size: 12px; color: var(--muted); flex: 1">Khách đã đồng ý — chờ mang máy tới.</span>
            <button class="ti-primary" @click="doiTt(y, 'da_nhan_may')">Đã nhận máy</button>
          </template>

          <template v-else-if="y.trangThai === 'da_nhan_may'">
            <input v-model="nhap[y.id]" type="number" placeholder="Giá chốt sau kiểm tra" class="ti-inp" />
            <input v-model="ghiChu[y.id]" placeholder="Tình trạng thực tế" class="ti-inp" style="flex: 1; min-width: 160px" />
            <button class="ti-primary" @click="chotGia(y)">Chốt giá</button>
            <button class="ti-ghost" @click="doiTt(y, 'tu_choi_thu')">Từ chối thu</button>
          </template>

          <template v-else-if="y.trangThai === 'da_kiem_tra'">
            <span style="font-size: 12px; color: var(--muted); flex: 1">
              Đã chốt {{ tien(y.giaChot) }} — cấp tín dụng để khách dùng mua hàng.
            </span>
            <button class="ti-primary" @click="capTinDung(y)">Cấp tín dụng</button>
          </template>

          <template v-else-if="y.trangThai === 'da_cap_tin_dung'">
            <span style="font-size: 12px; color: #22d39a">
              ✓ Đã cấp {{ tien(y.creditSoTien) }} tín dụng
              <span v-if="y.creditTrangThai === 'da_dung'" style="color: var(--muted)"> · khách đã dùng</span>
            </span>
          </template>

          <template v-else>
            <span style="font-size: 12px; color: var(--muted)">Yêu cầu đã kết thúc.</span>
          </template>
        </div>
      </div>
    </div>
      </template>
    </DataTable>

    <!-- Phóng to ảnh: kỹ thuật cần soi kỹ vết xước trước khi định giá -->
    <Teleport to="body">
      <div
        v-if="anhPhongTo" @click="anhPhongTo = null"
        style="position: fixed; inset: 0; background: rgba(0,0,0,.8); display: flex; align-items: center; justify-content: center; z-index: 300; padding: 24px; cursor: zoom-out"
      >
        <img :src="anhPhongTo" style="max-width: 92vw; max-height: 92vh; border-radius: 12px" />
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { resolveImageUrl } from '../api/http';
import DataTable from '../components/DataTable.vue';

// Trường lọc cho chế độ thẻ — cùng phễu Excel như các bảng khác (xem components/DataTable.vue).
const cols = [
  { key: 'model', label: 'Máy', text: (y) => [y.hang, y.model].filter(Boolean).join(' ') || '—' },
  { key: 'loaiThietBi', label: 'Loại thiết bị' },
  { key: 'tenKhach', label: 'Khách hàng', text: (y) => y.tenKhach || y.soDienThoaiKhach || '—' },
  { key: 'tinhTrangKhai', label: 'Tình trạng khai' },
  { key: 'namMua', label: 'Năm mua', kieu: 'so', text: (y) => (y.namMua ? String(y.namMua) : '—') },
  { key: 'giaTamTinh', label: 'Giá tạm tính', kieu: 'so', text: (y) => tien(y.giaTamTinh) },
  { key: 'giaChot', label: 'Giá chốt', kieu: 'so', text: (y) => tien(y.giaChot) },
  { key: 'trangThai', label: 'Trạng thái', text: (y) => y.nhanTrangThai || y.trangThai },
  { key: 'createdAt', label: 'Ngày gửi', kieu: 'ngay' },
];
import {
  getTradeIns, baoGiaTradeIn, chotGiaTradeIn, capTinDungTradeIn, doiTrangThaiTradeIn,
} from '../api/admin';

// Thu cũ đổi mới — màn hình định giá của nhân viên.
// Nguyên tắc: giá TẠM TÍNH báo theo ảnh, giá CHỐT chỉ điền sau khi cầm máy thật. Tín dụng chỉ
// phát ở bước cuối cùng, theo giá chốt (xem TradeInService).

const FILTERS = [
  ['', 'Tất cả'],
  ['cho_dinh_gia', 'Chờ định giá'],
  ['khach_dong_y', 'Chờ nhận máy'],
  ['da_nhan_may', 'Đang kiểm tra'],
  ['da_kiem_tra', 'Chờ cấp tín dụng'],
];

const ds = ref([]);
const loading = ref(false);
const loc = ref('');
const nhap = reactive({});
const ghiChu = reactive({});
const loi = reactive({});
const anhPhongTo = ref(null);

const tien = (n) => (Number(n) || 0).toLocaleString('vi-VN') + '₫';

const nhanLoai = (v) => ({ laptop: 'Laptop', pc: 'PC', man_hinh: 'Màn hình', linh_kien: 'Linh kiện' }[v] || v);
const nhanTinhTrang = (v) => ({
  moi_90: 'Như mới', tot: 'Còn tốt', trung_binh: 'Trung bình', can_sua: 'Cần sửa',
}[v] || v);

function mauNen(tt) {
  if (tt === 'da_cap_tin_dung') return 'rgba(34,211,154,.15)';
  if (['tu_choi_thu', 'khach_tu_choi', 'huy_yeu_cau'].includes(tt)) return 'var(--line)';
  if (['da_bao_gia', 'da_kiem_tra'].includes(tt)) return 'rgba(255,180,59,.15)';
  return 'rgba(198,255,74,.15)';
}
function mauChu(tt) {
  if (tt === 'da_cap_tin_dung') return '#22d39a';
  if (['tu_choi_thu', 'khach_tu_choi', 'huy_yeu_cau'].includes(tt)) return 'var(--muted)';
  if (['da_bao_gia', 'da_kiem_tra'].includes(tt)) return '#ffb43b';
  return 'var(--acc)';
}

/** Lỗi nghiệp vụ backend trả về nằm trong response.data.message (axios) — đọc sai chỗ sẽ hiện
 * "Request failed with status code 400" thay vì câu giải thích thật. */
function thongBaoLoi(e, mac) {
  return e?.response?.data?.message || e?.message || mac;
}

async function tai() {
  loading.value = true;
  try {
    ds.value = await getTradeIns(loc.value || undefined);
  } catch (e) {
    ds.value = [];
  } finally {
    loading.value = false;
  }
}

function capNhat(dto) {
  const i = ds.value.findIndex((x) => x.id === dto.id);
  // Đang lọc theo trạng thái: bản ghi vừa đổi bước sẽ rơi khỏi bộ lọc -> tải lại cho khớp.
  if (loc.value) { tai(); return; }
  if (i >= 0) ds.value[i] = dto;
}

async function baoGia(y) {
  loi[y.id] = '';
  const gia = Number(nhap[y.id]);
  if (!gia || gia <= 0) { loi[y.id] = 'Nhập giá tạm tính lớn hơn 0'; return; }
  try {
    capNhat(await baoGiaTradeIn(y.id, { giaTamTinh: gia, ghiChu: ghiChu[y.id] || null }));
    nhap[y.id] = ''; ghiChu[y.id] = '';
  } catch (e) {
    loi[y.id] = thongBaoLoi(e, 'Báo giá thất bại');
  }
}

async function chotGia(y) {
  loi[y.id] = '';
  const gia = Number(nhap[y.id]);
  if (!gia || gia <= 0) { loi[y.id] = 'Nhập giá chốt lớn hơn 0'; return; }
  try {
    capNhat(await chotGiaTradeIn(y.id, { giaChot: gia, ghiChu: ghiChu[y.id] || null }));
    nhap[y.id] = ''; ghiChu[y.id] = '';
  } catch (e) {
    loi[y.id] = thongBaoLoi(e, 'Chốt giá thất bại');
  }
}

async function capTinDung(y) {
  loi[y.id] = '';
  if (!window.confirm(`Cấp ${tien(y.giaChot)} tín dụng cho khách? Sau bước này khách dùng được ngay để mua hàng.`)) return;
  try {
    capNhat(await capTinDungTradeIn(y.id));
  } catch (e) {
    loi[y.id] = thongBaoLoi(e, 'Cấp tín dụng thất bại');
  }
}

async function doiTt(y, tt) {
  loi[y.id] = '';
  if (tt === 'tu_choi_thu' && !window.confirm('Từ chối thu máy này?')) return;
  try {
    capNhat(await doiTrangThaiTradeIn(y.id, tt, ghiChu[y.id] || null));
    ghiChu[y.id] = '';
  } catch (e) {
    loi[y.id] = thongBaoLoi(e, 'Đổi trạng thái thất bại');
  }
}

onMounted(tai);
</script>

<style scoped>
.ti-inp {
  height: 36px;
  padding: 0 11px;
  background: var(--bg);
  border: 1px solid var(--line);
  border-radius: 8px;
  color: var(--text);
  font-size: 12.5px;
  font-family: inherit;
  width: 150px;
}
.ti-primary {
  height: 36px;
  padding: 0 16px;
  border: none;
  background: var(--acc);
  color: var(--acc-ink);
  border-radius: 8px;
  font-size: 12.5px;
  font-weight: 700;
  cursor: pointer;
  font-family: inherit;
}
.ti-ghost {
  height: 36px;
  padding: 0 14px;
  border: 1px solid var(--line);
  background: transparent;
  color: var(--muted);
  border-radius: 8px;
  font-size: 12.5px;
  font-weight: 600;
  cursor: pointer;
  font-family: inherit;
}
.ti-ghost:hover { color: #ff5b5b; border-color: #ff5b5b; }
</style>
