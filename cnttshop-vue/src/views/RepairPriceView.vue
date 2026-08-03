<script setup>
import { ref, computed, onMounted, watch, nextTick } from 'vue';
import { useRoute } from 'vue-router';
import { actions, accent } from '../store.js';
import { fetchRepairPrices, estimateRepairCost } from '../api.js';
import { LOAI_THIET_BI, tenLoaiThietBi } from '../data/supportMeta.js';
import { fmt } from '../data/products.js';

const bangGia = ref([]);
const dangTai = ref(true);
const loaiChon = ref('laptop');
const tuKhoa = ref('');

// Combo sửa chữa — các gói đóng sẵn, bán kèm mức tiết kiệm so với làm lẻ. Là nội dung marketing
// cố định (như điều kiện bảo hành ở trang Thông tin bảo hành), không lấy từ CSDL: các gói này
// hiếm khi đổi và không cần một màn hình admin riêng để bảo trì. "Từ" = giá khởi điểm, giá chốt
// vẫn do kỹ thuật báo sau khi kiểm máy như mọi hạng mục khác.
const COMBOS = [
  {
    icon: '🖥️',
    ten: 'Màn hình + Case',
    badge: 'Tiết kiệm 15%',
    mo: 'Bộ đôi cho khách dùng PC để bàn cần làm sạch và kiểm tra tổng thể.',
    gom: ['Vệ sinh màn hình + kiểm tra điểm chết', 'Vệ sinh case + tra keo tản nhiệt CPU', 'Kiểm tra nguồn & nhiệt độ', 'Đi lại dây gọn gàng'],
    giaTu: 550000,
  },
  {
    icon: '🧰',
    ten: 'Full Case',
    badge: 'Bán chạy',
    mo: 'Bảo dưỡng toàn diện thùng máy, trả lại hiệu năng như mới.',
    gom: ['Vệ sinh toàn bộ linh kiện', 'Thay keo tản nhiệt cao cấp', 'Kiểm tra & tối ưu luồng gió', 'Test ổn định trước khi bàn giao'],
    giaTu: 650000,
  },
  {
    icon: '💻',
    ten: 'Laptop + Phụ kiện',
    badge: 'Tặng túi chống sốc',
    mo: 'Gói chăm sóc laptop trọn gói kèm quà phụ kiện.',
    gom: ['Vệ sinh laptop + tra keo', 'Kiểm tra pin & bộ sạc', 'Cài đặt hệ điều hành + driver', 'Tặng túi chống sốc'],
    giaTu: 500000,
  },
  {
    icon: '🎮',
    ten: 'Combo Game thủ',
    badge: 'Hiệu năng',
    mo: 'Tối ưu nhiệt và hiệu năng cho dàn máy chơi game.',
    gom: ['Vệ sinh + keo tản nhiệt cao cấp', 'Kiểm tra VGA & nhiệt độ tải nặng', 'Tối ưu luồng gió trong case', 'Test benchmark ổn định'],
    giaTu: 750000,
  },
  {
    icon: '🖱️',
    ten: 'Combo Văn phòng',
    badge: 'Tiết kiệm 20%',
    mo: 'Sẵn sàng cho một góc làm việc gọn gàng, chạy mượt.',
    gom: ['Vệ sinh PC + màn hình', 'Cấu hình mạng & máy in', 'Cài phần mềm văn phòng', 'Kiểm tra tổng thể'],
    giaTu: 450000,
  },
  {
    icon: '⚡',
    ten: 'Nâng cấp SSD + RAM',
    badge: 'Nhanh gấp đôi',
    mo: 'Lên đời tốc độ mà giữ nguyên dữ liệu. Chưa gồm giá linh kiện.',
    gom: ['Công lắp SSD + RAM', 'Chuyển dữ liệu / ghost Windows', 'Tối ưu khởi động', 'Kiểm tra ổn định'],
    giaTu: 300000,
  },
];

// Menu Hỗ trợ có thể vào thẳng khối combo (store.goRepairPriceCombo -> ?combo=1). Cuộn tới khi
// trang mở với query đó; watch để bấm lại lúc đã ở trang này vẫn cuộn.
const route = useRoute();
const comboEl = ref(null);
function cuonToiCombo() {
  if (!route.query.combo) return;
  nextTick(() => comboEl.value?.scrollIntoView({ behavior: 'smooth', block: 'start' }));
}

// Tối đa 2 hạng mục — cùng giới hạn với backend (SupportService.SO_HANG_MUC_TOI_DA). Chọn nhiều
// hơn thì con số cộng dồn xa rời thực tế và biến "tham khảo" thành "báo giá sai".
const TOI_DA = 2;
const daChon = ref([]);
const uocTinh = ref(null);
const dangTinh = ref(false);
const loi = ref('');

const danhSachLoc = computed(() => {
  const k = tuKhoa.value.trim().toLowerCase();
  return bangGia.value.filter((g) => {
    if (g.loaiThietBi !== loaiChon.value) return false;
    if (!k) return true;
    return (g.tenLoi + ' ' + (g.ghiChu || '')).toLowerCase().includes(k);
  });
});

function toggle(g) {
  const i = daChon.value.findIndex((x) => x.id === g.id);
  if (i >= 0) {
    daChon.value.splice(i, 1);
  } else {
    if (daChon.value.length >= TOI_DA) {
      loi.value = `Chỉ chọn được tối đa ${TOI_DA} hạng mục. Bỏ bớt một mục để chọn mục khác.`;
      setTimeout(() => (loi.value = ''), 3200);
      return;
    }
    daChon.value.push(g);
  }
  uocTinh.value = null;
  tinh();
}

const daChonId = computed(() => daChon.value.map((x) => x.id));

async function tinh() {
  if (!daChon.value.length) {
    uocTinh.value = null;
    return;
  }
  dangTinh.value = true;
  try {
    uocTinh.value = await estimateRepairCost(daChonId.value);
  } catch (e) {
    loi.value = e?.message || 'Không tính được chi phí ước tính.';
    uocTinh.value = null;
  } finally {
    dangTinh.value = false;
  }
}

function xoaHet() {
  daChon.value = [];
  uocTinh.value = null;
}

function doiLoai(ma) {
  loaiChon.value = ma;
  // Không xoá lựa chọn khi đổi tab: khách hoàn toàn có thể sửa laptop lẫn màn hình cùng lúc,
  // và giỏ ước tính vẫn hiện đủ ở dưới nên không bị mất dấu.
}

/** Hiển thị một con số hay một khoảng, tuỳ hạng mục có giá cận trên hay không. */
function hienGia(g) {
  if (g.giaDen != null && Number(g.giaDen) > Number(g.giaTu)) {
    return fmt(g.giaTu) + ' – ' + fmt(g.giaDen);
  }
  return fmt(g.giaTu);
}

onMounted(async () => {
  try {
    bangGia.value = await fetchRepairPrices();
  } catch (e) {
    bangGia.value = [];
  } finally {
    dangTai.value = false;
  }
  cuonToiCombo();
});
watch(() => route.query.combo, cuonToiCombo);
</script>

<template>
  <main style="max-width: 1120px; margin: 0 auto; padding: 24px 24px 72px">
    <button class="sp-back" @click="actions.goSupport()">← Trung tâm hỗ trợ</button>

    <div style="margin-bottom: 26px">
      <div class="sp-eyebrow">BẢNG GIÁ SỬA CHỮA</div>
      <h1 class="sp-h1">
        Ước tính chi phí<br /><span :style="{ color: accent }">trước khi mang máy tới</span>
      </h1>
      <p style="font-size: 14.5px; color: var(--muted2); max-width: 640px; line-height: 1.65; margin: 0">
        Chọn loại thiết bị và tối đa {{ TOI_DA }} hạng mục cần sửa để xem khoảng chi phí dự kiến.
        CNTTShop nhận sửa cả máy mua ở nơi khác.
      </p>
    </div>

    <!-- Combo sửa chữa (item 8) -->
    <section ref="comboEl" style="margin-bottom: 34px; scroll-margin-top: 110px">
      <div style="display: flex; align-items: baseline; justify-content: space-between; gap: 12px; margin-bottom: 4px">
        <h2 class="sp-h2" style="margin: 0">Combo sửa chữa</h2>
      </div>
      <p style="font-size: 13px; color: var(--muted2); margin: 0 0 18px; max-width: 640px; line-height: 1.6">
        Gói đóng sẵn nhiều hạng mục, tiết kiệm hơn làm lẻ. Giá "từ" là khởi điểm — kỹ thuật báo
        giá chốt sau khi kiểm máy.
      </p>

      <div class="rp-combos">
        <div v-for="c in COMBOS" :key="c.ten" class="rp-combo">
          <div style="display: flex; align-items: flex-start; justify-content: space-between; gap: 10px">
            <div style="font-size: 30px">{{ c.icon }}</div>
            <span v-if="c.badge" class="sp-pill" :style="{ color: accent }" style="font-size: 10.5px">
              {{ c.badge }}
            </span>
          </div>
          <div
            style="
              font-family: 'Chakra Petch', sans-serif;
              font-weight: 700;
              font-size: 17px;
              color: var(--text);
              margin: 14px 0 6px;
            "
          >
            {{ c.ten }}
          </div>
          <div style="font-size: 12.7px; color: var(--muted2); line-height: 1.55; margin-bottom: 14px">
            {{ c.mo }}
          </div>
          <ul style="list-style: none; padding: 0; margin: 0 0 16px; display: flex; flex-direction: column; gap: 8px; flex: 1">
            <li v-for="(g, i) in c.gom" :key="i" style="font-size: 12.6px; color: var(--muted2); line-height: 1.5; padding-left: 20px; position: relative">
              <span :style="{ color: accent }" style="position: absolute; left: 0; font-weight: 700">✓</span>
              {{ g }}
            </li>
          </ul>
          <div style="display: flex; align-items: flex-end; justify-content: space-between; gap: 10px; margin-top: auto">
            <div>
              <div style="font-size: 11px; color: var(--muted)">Chỉ từ</div>
              <div
                style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 20px"
                :style="{ color: accent }"
              >
                {{ fmt(c.giaTu) }}
              </div>
            </div>
            <button class="sp-btn-acc" style="height: 38px; font-size: 13px" @click="actions.goServiceCenters()">
              Đặt lịch
            </button>
          </div>
        </div>
      </div>
    </section>

    <!-- Chọn loại thiết bị -->
    <div style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 17px; color: var(--text); margin-bottom: 14px">
      Hoặc chọn từng hạng mục lẻ
    </div>
    <div style="display: flex; gap: 9px; flex-wrap: wrap; margin-bottom: 18px">
      <button
        v-for="l in LOAI_THIET_BI"
        :key="l.ma"
        class="sp-chip"
        :class="{ active: loaiChon === l.ma }"
        @click="doiLoai(l.ma)"
      >
        {{ l.icon }} {{ l.ten }}
      </button>
    </div>

    <input
      v-model="tuKhoa"
      class="sp-input"
      style="max-width: 340px; margin-bottom: 20px"
      placeholder="Lọc theo tên lỗi, vd: màn hình, pin…"
    />

    <div v-if="loi" class="sp-alert err">{{ loi }}</div>

    <div style="display: grid; grid-template-columns: 1fr 288px; gap: 22px; align-items: start" class="rp-body">
      <!-- Bảng giá -->
      <div class="sp-card" style="overflow: hidden">
        <div style="overflow-x: auto">
          <table class="rp-table">
            <thead>
              <tr>
                <th style="width: 40px"></th>
                <th style="min-width: 210px">Hạng mục</th>
                <th style="width: 120px; text-align: right">Linh kiện</th>
                <th style="width: 105px; text-align: right">Tiền công</th>
                <th style="width: 170px; text-align: right">Tổng dự kiến</th>
                <th style="width: 110px">Thời gian</th>
                <th style="width: 90px; text-align: center">BH</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="g in danhSachLoc"
                :key="g.id"
                class="rp-row"
                :class="{ active: daChonId.includes(g.id) }"
                @click="toggle(g)"
              >
                <td style="text-align: center">
                  <span class="rp-check" :class="{ on: daChonId.includes(g.id) }">
                    {{ daChonId.includes(g.id) ? '✓' : '' }}
                  </span>
                </td>
                <td>
                  <div style="font-weight: 600; color: var(--text); font-size: 13.2px">{{ g.tenLoi }}</div>
                  <div v-if="g.ghiChu" style="font-size: 11.8px; color: var(--muted); margin-top: 3px">
                    {{ g.ghiChu }}
                  </div>
                </td>
                <td style="text-align: right; color: var(--muted2)">
                  {{ Number(g.giaLinhKien) > 0 ? fmt(g.giaLinhKien) : '—' }}
                </td>
                <td style="text-align: right; color: var(--muted2)">{{ fmt(g.tienCong) }}</td>
                <td style="text-align: right; font-weight: 700; color: var(--text); white-space: nowrap">
                  {{ hienGia(g) }}
                </td>
                <td style="color: var(--muted2); font-size: 12.3px">{{ g.thoiGianDuKien || '—' }}</td>
                <td style="text-align: center; color: var(--muted2); font-size: 12.3px">
                  {{ g.baoHanhThang > 0 ? g.baoHanhThang + ' tháng' : '—' }}
                </td>
              </tr>
              <tr v-if="dangTai">
                <td colspan="7" class="sp-empty">Đang tải bảng giá…</td>
              </tr>
              <tr v-else-if="!danhSachLoc.length">
                <td colspan="7" class="sp-empty">
                  Chưa có hạng mục nào cho {{ tenLoaiThietBi(loaiChon) }}{{ tuKhoa ? ' khớp từ khoá đã nhập' : '' }}.<br />
                  Gọi hotline 0835 344 974 để được báo giá riêng.
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Giỏ ước tính -->
      <div style="position: sticky; top: 120px; display: flex; flex-direction: column; gap: 14px">
        <div class="sp-card" style="padding: 22px 22px">
          <div
            style="
              display: flex;
              align-items: baseline;
              justify-content: space-between;
              margin-bottom: 14px;
            "
          >
            <h2 class="sp-h2" style="margin: 0">Chi phí ước tính</h2>
            <button
              v-if="daChon.length"
              @click="xoaHet"
              style="
                background: transparent;
                border: none;
                color: var(--muted);
                font-size: 11.5px;
                cursor: pointer;
                font-family: 'Plus Jakarta Sans', sans-serif;
              "
            >
              Xoá hết
            </button>
          </div>

          <div v-if="!daChon.length" style="font-size: 13px; color: var(--muted); line-height: 1.6">
            Chọn hạng mục ở bảng bên trái (tối đa {{ TOI_DA }}) để xem khoảng chi phí dự kiến.
          </div>

          <template v-else>
            <div style="display: flex; flex-direction: column; gap: 10px; margin-bottom: 16px">
              <div
                v-for="g in daChon"
                :key="g.id"
                style="
                  display: flex;
                  align-items: flex-start;
                  justify-content: space-between;
                  gap: 10px;
                  padding-bottom: 10px;
                  border-bottom: 1px solid rgba(var(--line-rgb), 0.1);
                "
              >
                <div style="flex: 1">
                  <div style="font-size: 12.8px; color: var(--text); font-weight: 600; line-height: 1.4">
                    {{ g.tenLoi }}
                  </div>
                  <div style="font-size: 11.3px; color: var(--muted); margin-top: 3px">
                    {{ tenLoaiThietBi(g.loaiThietBi) }}
                  </div>
                </div>
                <button
                  @click="toggle(g)"
                  style="
                    background: transparent;
                    border: none;
                    color: var(--muted);
                    cursor: pointer;
                    font-size: 13px;
                    padding: 0 2px;
                  "
                >
                  ✕
                </button>
              </div>
            </div>

            <div v-if="dangTinh" style="font-size: 12.5px; color: var(--muted)">Đang tính…</div>
            <div v-else-if="uocTinh">
              <div style="font-size: 11.5px; color: var(--muted); margin-bottom: 6px">
                TỔNG DỰ KIẾN
              </div>
              <div
                style="
                  font-family: 'Chakra Petch', sans-serif;
                  font-weight: 700;
                  font-size: 21px;
                  line-height: 1.3;
                "
                :style="{ color: accent }"
              >
                <template v-if="Number(uocTinh.tongDen) > Number(uocTinh.tongTu)">
                  {{ fmt(uocTinh.tongTu) }}<br />– {{ fmt(uocTinh.tongDen) }}
                </template>
                <template v-else>{{ fmt(uocTinh.tongTu) }}</template>
              </div>
              <div
                v-if="uocTinh.thoiGianDuKien"
                style="font-size: 12.3px; color: var(--muted2); margin-top: 8px"
              >
                Thời gian dự kiến: {{ uocTinh.thoiGianDuKien }}
              </div>
            </div>

            <button
              class="sp-btn-acc"
              style="width: 100%; margin-top: 18px"
              @click="actions.goServiceCenters()"
            >
              Đặt lịch mang máy tới →
            </button>
          </template>
        </div>

        <!-- Miễn trừ: bắt buộc phải nói rõ, giá thật chỉ chốt được sau khi kiểm máy -->
        <div class="sp-alert info" style="margin: 0">
          <b style="color: var(--text)">Lưu ý quan trọng.</b> Bảng giá trên chỉ mang tính chất tham
          khảo. Chi phí thật do kỹ thuật báo lại sau khi kiểm tra máy trực tiếp, và luôn được hỏi ý
          bạn trước khi tiến hành sửa.
        </div>

        <div class="sp-card" style="padding: 18px 20px">
          <div style="font-size: 12.5px; color: var(--muted2); line-height: 1.65">
            Máy còn bảo hành có thể được sửa <b style="color: var(--green)">miễn phí</b>.
            <a href="#" @click.prevent="actions.goWarrantyInfo()" :style="{ color: accent }">
              Tra cứu thời hạn bảo hành →
            </a>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<style scoped>
.rp-combos {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 16px;
}
.rp-combo {
  display: flex;
  flex-direction: column;
  background: var(--card);
  border: 1px solid rgba(var(--line-rgb), 0.14);
  border-radius: 16px;
  padding: 22px 22px;
  transition: border-color 0.16s, transform 0.16s;
}
.rp-combo:hover {
  border-color: var(--acc, #c6ff4a);
  transform: translateY(-2px);
}

.rp-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.rp-table th {
  text-align: left;
  padding: 13px 14px;
  font-family: 'Chakra Petch', sans-serif;
  font-size: 11.2px;
  letter-spacing: 0.5px;
  color: var(--muted);
  font-weight: 600;
  background: var(--card2);
  border-bottom: 1px solid rgba(var(--line-rgb), 0.12);
  white-space: nowrap;
}
.rp-table td {
  padding: 13px 14px;
  border-bottom: 1px solid rgba(var(--line-rgb), 0.08);
  vertical-align: middle;
}
.rp-table tbody tr:last-child td {
  border-bottom: none;
}

.rp-row {
  cursor: pointer;
  transition: background 0.14s;
}
.rp-row:hover {
  background: var(--card2);
}
.rp-row.active {
  background: color-mix(in srgb, var(--acc, #c6ff4a) 9%, transparent);
}

.rp-check {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 19px;
  height: 19px;
  border-radius: 6px;
  border: 1.5px solid rgba(var(--line-rgb), 0.3);
  font-size: 11px;
  font-weight: 700;
  color: transparent;
  transition: all 0.14s;
}
.rp-check.on {
  background: var(--acc, #c6ff4a);
  border-color: var(--acc, #c6ff4a);
  color: var(--acc-ink);
}

@media (max-width: 960px) {
  .rp-body {
    grid-template-columns: 1fr !important;
  }
}
</style>
