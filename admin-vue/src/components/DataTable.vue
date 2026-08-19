<script setup>
import { ref, computed, watch, onMounted, onBeforeUnmount } from 'vue';

/**
 * Bảng dữ liệu dùng chung cho toàn bộ Admin Console, có BỘ LỌC TỪNG CỘT kiểu Excel/Google Sheet.
 *
 * Vì sao gom thành một component: trước đây mỗi trang tự viết <table> riêng và tự chế bộ lọc
 * (Đơn hàng lọc theo tab trạng thái, Sản phẩm có 3 ô select, phần lớn trang còn lại không lọc
 * được gì) — muốn lọc theo một cột bất kỳ thì phải sửa code trang đó. Nay mọi bảng dùng chung
 * một cơ chế: bấm phễu ở đầu cột -> sắp xếp, tìm trong danh sách giá trị, tích/bỏ tích từng
 * giá trị, thêm khoảng min–max cho cột số/ngày. Nhiều cột lọc cùng lúc thì giao nhau (VÀ),
 * đúng như Excel.
 *
 * columns: [{
 *   key,               // khoá trong object dòng
 *   label,             // nhãn hiển thị ở đầu cột
 *   align,             // 'left' | 'right' | 'center'
 *   width,             // css width tuỳ chọn
 *   kieu,              // 'text' (mặc định) | 'so' | 'ngay' — quyết định cách sắp xếp + có ô min–max hay không
 *   loc,               // false = cột này không có phễu (VD cột nút thao tác)
 *   value: (row) => v, // giá trị dùng để LỌC/SẮP XẾP (mặc định row[key])
 *   text:  (row) => s, // chuỗi hiển thị trong danh sách giá trị của phễu (mặc định value)
 * }]
 *
 * Ô của mỗi cột vẽ bằng slot `#o-<key>` (nhận { row, value }); không có slot thì in text().
 */
const props = defineProps({
  columns: { type: Array, required: true },
  rows: { type: Array, required: true },
  rowKey: { type: String, default: 'id' },
  // Từ khoá tìm kiếm chung (thường lấy từ ô tìm kiếm trên thanh tiêu đề). Quét mọi cột.
  timKiem: { type: String, default: '' },
  clickDuoc: { type: Boolean, default: false },
  trong: { type: String, default: 'Không có dữ liệu' },
  // Ẩn chân bảng khi bảng nằm trong khối đã có tổng kết riêng.
  hienChan: { type: Boolean, default: true },
  /**
   * 'bang' = vẽ <table> (mặc định).
   * 'the'  = KHÔNG vẽ bảng: chỉ vẽ thanh lọc rồi trả danh sách đã lọc qua slot #the.
   *          Dùng cho các màn hình vốn là thẻ chứ không phải bảng (Đổi trả, Lịch hẹn, Thu cũ) —
   *          ở đó mỗi bản ghi có ảnh minh chứng + nút thao tác, ép vào bảng phẳng là mất hết
   *          công dụng. Bộ lọc thì vẫn phải có, và phải giống hệt bảng để người dùng chỉ cần
   *          học một lần.
   */
  cheDo: { type: String, default: 'bang' },
});
const emit = defineEmits(['row-click']);

// Bộ lọc đang áp: { [key]: { chon: Set<string>|null, tu: string, den: string } }
// chon = null nghĩa là "không lọc theo danh sách giá trị" (khác với Set rỗng = không chọn gì).
const boLoc = ref({});
const sapXep = ref({ key: null, chieu: 1 });
const phexMo = ref(null);      // key của cột đang mở phễu
const timTrongPhex = ref('');
const viTriPhex = ref({ left: '0px', top: '0px' });

function giaTri(col, row) {
  return col.value ? col.value(row) : row[col.key];
}
function chuoi(col, row) {
  const v = giaTri(col, row);
  if (col.text) return col.text(row);
  if (v === null || v === undefined || v === '') return '(trống)';
  return String(v);
}

/** So sánh theo kiểu cột: số và ngày phải so theo giá trị, không phải theo chữ. */
function khoaSapXep(col, row) {
  const v = giaTri(col, row);
  if (col.kieu === 'so') return Number(v) || 0;
  if (col.kieu === 'ngay') return v ? new Date(v).getTime() || 0 : 0;
  return String(v ?? '').toLowerCase();
}

function boDau(s) {
  return String(s ?? '')
    .toLowerCase()
    .normalize('NFD')
    .replace(new RegExp('[\\u0300-\\u036f]', 'g'), '')
    .replace(/đ/g, 'd');
}

/** Dòng có khớp mọi bộ lọc TRỪ cột đang xét không? Danh sách giá trị trong phễu của một cột
 * phải phản ánh các bộ lọc khác đang bật (giống Excel), nếu không sẽ hiện cả những giá trị mà
 * chọn vào cũng ra 0 dòng. */
function khopTru(row, tru) {
  for (const col of props.columns) {
    if (col.key === tru) continue;
    const f = boLoc.value[col.key];
    if (!f) continue;
    if (f.chon && !f.chon.has(chuoi(col, row))) return false;
    if (f.tu !== '' || f.den !== '') {
      const n = col.kieu === 'ngay' ? new Date(giaTri(col, row)).getTime() : Number(giaTri(col, row));
      if (f.tu !== '' && n < moc(col, f.tu)) return false;
      if (f.den !== '' && n > moc(col, f.den)) return false;
    }
  }
  return true;
}
function moc(col, raw) {
  return col.kieu === 'ngay' ? new Date(raw).getTime() : Number(raw);
}

const dongSauTimKiem = computed(() => {
  const q = boDau(props.timKiem).trim();
  if (!q) return props.rows;
  return props.rows.filter((row) =>
    props.columns.some((c) => boDau(chuoi(c, row)).includes(q)),
  );
});

const dongDaLoc = computed(() => {
  let ds = dongSauTimKiem.value.filter((row) => khopTru(row, null));
  const s = sapXep.value;
  if (s.key) {
    const col = props.columns.find((c) => c.key === s.key);
    if (col) {
      ds = ds.slice().sort((a, b) => {
        const x = khoaSapXep(col, a);
        const y = khoaSapXep(col, b);
        if (x < y) return -1 * s.chieu;
        if (x > y) return 1 * s.chieu;
        return 0;
      });
    }
  }
  return ds;
});

/** Danh sách giá trị hiện trong phễu của cột đang mở, kèm số dòng — đúng kiểu Excel. */
const giaTriTrongPhex = computed(() => {
  const key = phexMo.value;
  if (!key) return [];
  const col = props.columns.find((c) => c.key === key);
  if (!col) return [];
  const dem = new Map();
  for (const row of dongSauTimKiem.value) {
    if (!khopTru(row, key)) continue;
    const t = chuoi(col, row);
    dem.set(t, (dem.get(t) || 0) + 1);
  }
  const q = boDau(timTrongPhex.value).trim();
  let ds = [...dem.entries()].map(([text, n]) => ({ text, n }));
  if (q) ds = ds.filter((x) => boDau(x.text).includes(q));
  // Cột số/ngày xếp theo giá trị; còn lại xếp theo bảng chữ cái, "(trống)" luôn xuống cuối.
  ds.sort((a, b) => {
    if (a.text === '(trống)') return 1;
    if (b.text === '(trống)') return -1;
    if (col.kieu === 'so') return (Number(a.text.replace(/[^\d.-]/g, '')) || 0) - (Number(b.text.replace(/[^\d.-]/g, '')) || 0);
    return a.text.localeCompare(b.text, 'vi');
  });
  return ds;
});

function dangLoc(key) {
  const f = boLoc.value[key];
  return !!f && (f.chon !== null || f.tu !== '' || f.den !== '');
}
const soCotDangLoc = computed(() => props.columns.filter((c) => dangLoc(c.key)).length);

function bangLoc(key) {
  if (!boLoc.value[key]) boLoc.value[key] = { chon: null, tu: '', den: '' };
  return boLoc.value[key];
}

function moPhex(col, e) {
  if (col.loc === false) return;
  if (phexMo.value === col.key) {
    phexMo.value = null;
    return;
  }
  phexMo.value = col.key;
  timTrongPhex.value = '';
  bangLoc(col.key);
  // Bám mép trái đầu cột, lật sang trái nếu tràn màn hình.
  const r = e.currentTarget.getBoundingClientRect();
  const RONG = 268;
  const left = r.left + RONG > window.innerWidth ? Math.max(8, window.innerWidth - RONG - 8) : r.left;
  viTriPhex.value = { left: left + 'px', top: r.bottom + 4 + 'px' };
}

function daChon(key, text) {
  const f = boLoc.value[key];
  return !f || f.chon === null || f.chon.has(text);
}
function toggleGiaTri(key, text) {
  const f = bangLoc(key);
  // Lần đầu bỏ tích: khởi tạo từ TẤT CẢ giá trị đang hiện rồi bỏ đúng cái vừa bấm.
  if (f.chon === null) f.chon = new Set(giaTriTrongPhex.value.map((x) => x.text));
  if (f.chon.has(text)) f.chon.delete(text);
  else f.chon.add(text);
  boLoc.value = { ...boLoc.value };
}
const chonHetTrongPhex = computed(() => {
  const f = boLoc.value[phexMo.value];
  if (!f || f.chon === null) return true;
  return giaTriTrongPhex.value.every((x) => f.chon.has(x.text));
});
function toggleChonHet() {
  const key = phexMo.value;
  const f = bangLoc(key);
  if (chonHetTrongPhex.value) f.chon = new Set();
  else f.chon = new Set(giaTriTrongPhex.value.map((x) => x.text));
  boLoc.value = { ...boLoc.value };
}

function datSapXep(key, chieu) {
  sapXep.value = { key, chieu };
  phexMo.value = null;
}
function xoaLocCot(key) {
  delete boLoc.value[key];
  boLoc.value = { ...boLoc.value };
  if (sapXep.value.key === key) sapXep.value = { key: null, chieu: 1 };
  phexMo.value = null;
}
function xoaHetLoc() {
  boLoc.value = {};
  sapXep.value = { key: null, chieu: 1 };
  phexMo.value = null;
}
defineExpose({ xoaHetLoc, dongDaLoc });

// Dữ liệu nguồn đổi (đổi trang, tải lại) -> bỏ lọc cũ để không còn phễu trỏ vào giá trị đã biến mất.
watch(() => props.columns, xoaHetLoc);

function dongPhexNgoai(e) {
  if (!phexMo.value) return;
  if (e.target.closest?.('.dt-pop') || e.target.closest?.('.dt-funnel')) return;
  phexMo.value = null;
}
function onEsc(e) {
  if (e.key === 'Escape') phexMo.value = null;
}
onMounted(() => {
  document.addEventListener('mousedown', dongPhexNgoai);
  document.addEventListener('keydown', onEsc);
});
onBeforeUnmount(() => {
  document.removeEventListener('mousedown', dongPhexNgoai);
  document.removeEventListener('keydown', onEsc);
});
</script>

<template>
  <div>
    <!-- Băng tóm tắt: chỉ hiện khi thật sự đang lọc, để bảng không lọc trông vẫn gọn -->
    <div v-if="soCotDangLoc" class="dt-bar">
      <i class="bi bi-funnel-fill"></i>
      Đang lọc theo {{ soCotDangLoc }} cột · {{ dongDaLoc.length }}/{{ rows.length }} dòng
      <button class="dt-clear" @click="xoaHetLoc">Xoá tất cả bộ lọc</button>
    </div>

    <!-- Chế độ THẺ: thay hàng tiêu đề bảng bằng một dãy chip, mỗi chip là một trường lọc.
         Phễu bật lên y hệt chế độ bảng nên thao tác không khác gì nhau. -->
    <div v-if="cheDo === 'the'" class="dt-chips">
      <span class="dt-chips-label"><i class="bi bi-funnel"></i> Lọc theo</span>
      <button
        v-for="c in columns.filter((x) => x.loc !== false)"
        :key="c.key"
        class="dt-chip"
        :class="{ on: dangLoc(c.key) || sapXep.key === c.key }"
        @click.stop="moPhex(c, $event)"
      >
        {{ c.label }}
        <i
          class="bi"
          :class="
            sapXep.key === c.key
              ? sapXep.chieu === 1
                ? 'bi-sort-down-alt'
                : 'bi-sort-up-alt'
              : dangLoc(c.key)
                ? 'bi-funnel-fill'
                : 'bi-chevron-down'
          "
        ></i>
      </button>
      <span class="dt-chips-count">{{ dongDaLoc.length }}/{{ rows.length }}</span>
    </div>

    <template v-if="cheDo === 'the'">
      <slot name="the" :rows="dongDaLoc" />
      <div v-if="!dongDaLoc.length" class="dt-empty" style="border-radius: 12px; background: var(--card)">
        {{ rows.length ? 'Không bản ghi nào khớp bộ lọc đang chọn.' : trong }}
      </div>
    </template>

    <div v-else style="overflow-x: auto">
      <table class="dt">
        <thead>
          <tr>
            <th
              v-for="c in columns"
              :key="c.key"
              :style="{ textAlign: c.align || 'left', width: c.width }"
            >
              <span class="dt-th">
                <span>{{ c.label }}</span>
                <button
                  v-if="c.loc !== false"
                  class="dt-funnel"
                  :class="{ on: dangLoc(c.key) || sapXep.key === c.key }"
                  :title="'Lọc / sắp xếp theo ' + c.label"
                  @click.stop="moPhex(c, $event)"
                >
                  <i
                    class="bi"
                    :class="
                      sapXep.key === c.key
                        ? sapXep.chieu === 1
                          ? 'bi-sort-down-alt'
                          : 'bi-sort-up-alt'
                        : dangLoc(c.key)
                          ? 'bi-funnel-fill'
                          : 'bi-funnel'
                    "
                  ></i>
                </button>
              </span>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="!dongDaLoc.length">
            <td :colspan="columns.length" class="dt-empty">
              {{ rows.length ? 'Không dòng nào khớp bộ lọc đang chọn.' : trong }}
            </td>
          </tr>
          <tr
            v-for="row in dongDaLoc"
            :key="row[rowKey]"
            :class="{ 'dt-click': clickDuoc }"
            @click="clickDuoc && emit('row-click', row)"
          >
            <td v-for="c in columns" :key="c.key" :style="{ textAlign: c.align || 'left' }">
              <slot :name="'o-' + c.key" :row="row" :value="giaTri(c, row)">
                {{ chuoi(c, row) }}
              </slot>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="hienChan && rows.length && cheDo !== 'the'" class="dt-foot">
      Hiển thị <b>{{ dongDaLoc.length }}</b> / {{ rows.length }} dòng
    </div>

    <!-- ===== Phễu lọc (Teleport ra body để không bị overflow của bảng cắt mất) ===== -->
    <Teleport to="body">
      <div v-if="phexMo" class="dt-pop" :style="viTriPhex">
        <button class="dt-sort" @click="datSapXep(phexMo, 1)">
          <i class="bi bi-sort-down-alt"></i>
          Sắp xếp {{ columns.find((c) => c.key === phexMo)?.kieu === 'so' ? 'nhỏ → lớn' : 'A → Z' }}
        </button>
        <button class="dt-sort" @click="datSapXep(phexMo, -1)">
          <i class="bi bi-sort-up-alt"></i>
          Sắp xếp {{ columns.find((c) => c.key === phexMo)?.kieu === 'so' ? 'lớn → nhỏ' : 'Z → A' }}
        </button>

        <!-- Khoảng min–max: chỉ có nghĩa với cột số/ngày -->
        <template v-if="['so', 'ngay'].includes(columns.find((c) => c.key === phexMo)?.kieu)">
          <div class="dt-sep"></div>
          <div class="dt-range">
            <input
              class="fld"
              :type="columns.find((c) => c.key === phexMo)?.kieu === 'ngay' ? 'date' : 'number'"
              placeholder="Từ"
              :value="bangLoc(phexMo).tu"
              @input="bangLoc(phexMo).tu = $event.target.value; boLoc = { ...boLoc }"
            />
            <span>–</span>
            <input
              class="fld"
              :type="columns.find((c) => c.key === phexMo)?.kieu === 'ngay' ? 'date' : 'number'"
              placeholder="Đến"
              :value="bangLoc(phexMo).den"
              @input="bangLoc(phexMo).den = $event.target.value; boLoc = { ...boLoc }"
            />
          </div>
        </template>

        <div class="dt-sep"></div>
        <input class="fld dt-search" v-model="timTrongPhex" placeholder="Tìm trong danh sách…" />

        <label class="dt-item dt-all">
          <input type="checkbox" :checked="chonHetTrongPhex" @change="toggleChonHet" />
          <span>(Chọn tất cả)</span>
          <b>{{ giaTriTrongPhex.length }}</b>
        </label>

        <div class="dt-list">
          <div v-if="!giaTriTrongPhex.length" class="dt-none">Không có giá trị nào</div>
          <label v-for="g in giaTriTrongPhex" :key="g.text" class="dt-item">
            <input type="checkbox" :checked="daChon(phexMo, g.text)" @change="toggleGiaTri(phexMo, g.text)" />
            <span :title="g.text">{{ g.text }}</span>
            <b>{{ g.n }}</b>
          </label>
        </div>

        <div class="dt-sep"></div>
        <div class="dt-actions">
          <button class="dt-btn" @click="xoaLocCot(phexMo)">Xoá lọc cột này</button>
          <button class="dt-btn dt-btn-acc" @click="phexMo = null">Xong</button>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<style scoped>
.dt {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.dt thead tr {
  background: var(--card2);
}
.dt th {
  padding: 9px 14px;
  font-size: 11px;
  font-weight: 600;
  color: var(--muted);
  text-transform: uppercase;
  letter-spacing: 0.4px;
  white-space: nowrap;
}
.dt-th {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}
.dt-funnel {
  border: none;
  background: transparent;
  color: var(--muted);
  cursor: pointer;
  padding: 2px;
  border-radius: 5px;
  line-height: 1;
  font-size: 11px;
  opacity: 0.55;
  transition: opacity 0.12s, color 0.12s;
}
.dt-funnel:hover {
  opacity: 1;
  background: var(--hover);
}
/* Cột đang lọc/đang sắp xếp phải nhìn ra ngay — Excel cũng đổi icon phễu như vậy */
.dt-funnel.on {
  opacity: 1;
  color: var(--acc);
}
.dt td {
  padding: 11px 14px;
  border-top: 1px solid var(--line);
  color: var(--text);
  vertical-align: middle;
}
.dt-click {
  cursor: pointer;
}
.dt-click:hover {
  background: var(--hover);
}
.dt-empty {
  text-align: center;
  padding: 34px 14px !important;
  color: var(--muted);
  font-size: 12.5px;
}
.dt-foot {
  padding: 9px 14px;
  border-top: 1px solid var(--line);
  font-size: 11.5px;
  color: var(--muted);
}
.dt-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 14px;
  background: color-mix(in srgb, var(--acc) 12%, transparent);
  border-bottom: 1px solid var(--line);
  font-size: 12px;
  font-weight: 600;
  color: var(--acc);
}
.dt-chips {
  display: flex;
  align-items: center;
  gap: 7px;
  flex-wrap: wrap;
  margin-bottom: 14px;
}
.dt-chips-label {
  font-size: 11.5px;
  font-weight: 600;
  color: var(--muted);
  display: inline-flex;
  align-items: center;
  gap: 5px;
}
.dt-chip {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  height: 30px;
  padding: 0 11px;
  border-radius: 8px;
  border: 1px solid var(--line2);
  background: var(--card);
  color: var(--muted2);
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  font-family: inherit;
}
.dt-chip:hover {
  background: var(--hover);
}
.dt-chip.on {
  border-color: var(--acc);
  color: var(--acc);
  background: color-mix(in srgb, var(--acc) 12%, transparent);
}
.dt-chip i {
  font-size: 10px;
}
.dt-chips-count {
  margin-left: auto;
  font-size: 11.5px;
  color: var(--muted);
}

.dt-clear {
  margin-left: auto;
  border: 1px solid currentColor;
  background: transparent;
  color: inherit;
  border-radius: 7px;
  padding: 3px 10px;
  font-size: 11.5px;
  font-weight: 600;
  cursor: pointer;
  font-family: inherit;
}
</style>

<style>
/* Không scoped: phễu được Teleport ra <body> nên nằm ngoài phạm vi scope của component. */
.dt-pop {
  position: fixed;
  z-index: 400;
  width: 268px;
  background: var(--card2);
  border: 1px solid var(--line2);
  border-radius: 11px;
  box-shadow: 0 18px 46px rgba(0, 0, 0, 0.45);
  padding: 6px;
  font-family: 'Plus Jakarta Sans', sans-serif;
}
.dt-pop .dt-sort {
  display: flex;
  align-items: center;
  gap: 8px;
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
.dt-pop .dt-sort:hover {
  background: var(--hover);
}
.dt-pop .dt-sep {
  height: 1px;
  background: var(--line);
  margin: 5px 2px;
}
.dt-pop .dt-search {
  width: 100%;
  height: 32px;
  margin-bottom: 5px;
}
.dt-pop .dt-range {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 0 2px 4px;
}
.dt-pop .dt-range .fld {
  height: 30px;
  min-width: 0;
  flex: 1;
  font-size: 12px;
}
.dt-pop .dt-range span {
  color: var(--muted);
  font-size: 12px;
}
.dt-pop .dt-list {
  max-height: 208px;
  overflow-y: auto;
}
.dt-pop .dt-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 5px 9px;
  border-radius: 6px;
  font-size: 12.5px;
  color: var(--text);
  cursor: pointer;
}
.dt-pop .dt-item:hover {
  background: var(--hover);
}
.dt-pop .dt-item span {
  flex: 1;
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.dt-pop .dt-item b {
  flex: none;
  font-size: 11px;
  color: var(--muted);
  font-weight: 600;
}
.dt-pop .dt-item input {
  accent-color: var(--acc);
  flex: none;
}
.dt-pop .dt-all {
  font-weight: 600;
  border-bottom: 1px solid var(--line);
  border-radius: 6px 6px 0 0;
}
.dt-pop .dt-none {
  padding: 14px 9px;
  text-align: center;
  font-size: 12px;
  color: var(--muted);
}
.dt-pop .dt-actions {
  display: flex;
  gap: 6px;
}
.dt-pop .dt-btn {
  flex: 1;
  height: 31px;
  border-radius: 7px;
  border: 1px solid var(--line2);
  background: transparent;
  color: var(--muted2);
  font-size: 11.5px;
  font-weight: 600;
  cursor: pointer;
  font-family: inherit;
}
.dt-pop .dt-btn:hover {
  background: var(--hover);
}
.dt-pop .dt-btn-acc {
  background: var(--acc);
  border-color: var(--acc);
  color: var(--acc-ink);
}
</style>
