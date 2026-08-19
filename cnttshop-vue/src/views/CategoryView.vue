<script setup>
import { computed, reactive, ref, watch } from 'vue';
import { useRoute } from 'vue-router';
import { catMeta, fmt, matchesQuery, matchesSearch, CATEGORY_SEGMENTS, COMPONENT_SLUGS } from '../data/products.js';
import { state, actions, accent, products } from '../store.js';
import ProductCard from '../components/ProductCard.vue';

const route = useRoute();
// Đọc thẳng từ route thay vì qua state.cat (mirror do router.beforeEach set) — tránh mọi
// khả năng lệch pha giữa lúc guard chạy và lúc component đọc, dù đến từ trang nào trước đó.
const cat = computed(() => route.params.cat || 'all');

// "linh-kien" là danh mục GỘP: gom mọi danh mục linh kiện con (cpu/gpu/ram/...) vào một trang —
// dùng cho mục "Linh kiện bán chạy" trên menu Khám phá, vì mỗi loại linh kiện vốn là một danh
// mục riêng, không có trang "linh kiện" chung.
const isComponentGroup = computed(() => cat.value === 'linh-kien');

const catTitle = computed(() =>
  cat.value === 'all'
    ? 'Tất cả sản phẩm'
    : isComponentGroup.value
      ? 'Linh kiện máy tính'
      : catMeta[cat.value]?.vn || 'Sản phẩm',
);

const base = computed(() =>
  products.filter((p) =>
    cat.value === 'all'
      ? true
      : isComponentGroup.value
        ? COMPONENT_SLUGS.includes(p.cat)
        : p.cat === cat.value),
);

const allBrands = computed(() =>
  base.value.map((p) => p.brand).filter((v, i, a) => a.indexOf(v) === i),
);

// ===== Bộ lọc riêng cho PC & Máy tính bàn — PC nào cũng thuộc brand CNTTshop (tự lắp ráp) nên
// bộ lọc "Thương hiệu" chung vô nghĩa ở danh mục này; thay bằng lọc theo cấu hình thật: hãng CPU
// + dòng chip, và thương hiệu case/mainboard/tản nhiệt đi kèm. =====
const isPcCategory = computed(() => cat.value === 'pc-may-tinh-ban');

function specVal(p, key) {
  const s = (p.specs || []).find((x) => x.k === key);
  return s ? s.v : '';
}
function cpuVendorOf(v) {
  return /AMD/i.test(v) ? 'AMD' : 'Intel';
}
// Hậu tố tên CPU desktop thật (không phải U/H — đó là hậu tố laptop): AMD có G (có iGPU)/X (xung
// cao)/X3D (3D V-Cache) ; Intel có F (không iGPU)/K (mở khoá ép xung)/KS (ép xung đỉnh).
// Dùng /AMD/ (không neo ^) để không bị lệch nếu spec_value lỡ có tiền tố thừa (vd "CPU AMD ...").
function cpuSeriesOf(v) {
  if (/AMD/i.test(v)) {
    if (/X3D/i.test(v)) return 'X3D';
    if (/\dG$/i.test(v)) return 'G';
    if (/\dX$/i.test(v)) return 'X';
    return 'Standard';
  }
  if (/KS$/i.test(v)) return 'KS';
  if (/K$/i.test(v)) return 'K';
  if (/F$/i.test(v)) return 'F';
  return 'Standard';
}
const CPU_SERIES_LABEL = {
  AMD: { X3D: 'X3D — 3D V-Cache', X: 'X — xung cao', G: 'G — có iGPU', Standard: 'Tiêu chuẩn' },
  Intel: { KS: 'KS — ép xung đỉnh', K: 'K — mở khoá ép xung', F: 'F — không iGPU', Standard: 'Tiêu chuẩn' },
};
const COOLER_BRAND_PREFIXES = ['DeepCool', 'ID-Cooling', 'Cooler Master', 'Thermalright'];
function coolerBrandOf(v) {
  return COOLER_BRAND_PREFIXES.find((b) => v.startsWith(b)) || v; // "Tản nhiệt zin theo CPU" giữ nguyên
}
function mainboardBrandOf(v) {
  return v.split(' ')[0] || v; // "ASUS B760" -> "ASUS"
}

const pcCpuVendors = computed(() => {
  if (!isPcCategory.value) return [];
  const set = new Set();
  base.value.forEach((p) => { const c = specVal(p, 'CPU'); if (c) set.add(cpuVendorOf(c)); });
  return [...set];
});
const pcCpuSeriesOptions = computed(() => {
  if (!isPcCategory.value || !state.pcCpuVendor) return [];
  const set = new Set();
  base.value.forEach((p) => {
    const c = specVal(p, 'CPU');
    if (c && cpuVendorOf(c) === state.pcCpuVendor) set.add(cpuSeriesOf(c));
  });
  return [...set].map((key) => ({ key, label: CPU_SERIES_LABEL[state.pcCpuVendor][key] || key }));
});
const pcCaseBrands = computed(() => {
  if (!isPcCategory.value) return [];
  const set = new Set();
  base.value.forEach((p) => { const v = specVal(p, 'Vỏ case'); if (v) set.add(v); });
  return [...set].sort();
});
const pcMainboardBrands = computed(() => {
  if (!isPcCategory.value) return [];
  const set = new Set();
  base.value.forEach((p) => { const v = specVal(p, 'Mainboard'); if (v) set.add(mainboardBrandOf(v)); });
  return [...set].sort();
});
const pcCoolerBrands = computed(() => {
  if (!isPcCategory.value) return [];
  const set = new Set();
  base.value.forEach((p) => { const v = specVal(p, 'Tản nhiệt'); if (v) set.add(coolerBrandOf(v)); });
  return [...set].sort();
});

// ===== Bộ lọc riêng cho Màn hình: Kích thước + Độ phân giải (đọc thẳng từ spec_value thật) =====
const isMonitorCategory = computed(() => cat.value === 'man-hinh');
// Sắp kích thước theo số inch tăng dần thay vì chữ cái ("24 inch" < "27 inch" < "32 inch").
const soInch = (v) => { const m = String(v).match(/\d+(\.\d+)?/); return m ? parseFloat(m[0]) : 0; };
const monSizeOptions = computed(() => {
  if (!isMonitorCategory.value) return [];
  const set = new Set();
  base.value.forEach((p) => { const v = specVal(p, 'Kích thước'); if (v) set.add(v); });
  return [...set].sort((a, b) => soInch(a) - soInch(b));
});
const monResoOptions = computed(() => {
  if (!isMonitorCategory.value) return [];
  const set = new Set();
  base.value.forEach((p) => { const v = specVal(p, 'Độ phân giải'); if (v) set.add(v); });
  return [...set].sort();
});

// Phân khúc theo chức năng (chỉ hiện với danh mục có định nghĩa sẵn — xem CATEGORY_SEGMENTS),
// mỗi mục kèm số lượng sản phẩm khớp để ẩn phân khúc rỗng.
const currentSegments = computed(() => {
  const def = CATEGORY_SEGMENTS.find((d) => d.slug === cat.value);
  if (!def) return [];
  return def.items
    .map((it) => ({
      keyword: it.keyword,
      label: it.label,
      icon: it.icon,
      count: base.value.filter((p) => matchesQuery(p, it.keyword)).length,
    }))
    .filter((it) => it.count > 0);
});

// Danh mục càng nghiên cứu càng nhiều phân khúc (VD PC lên tới 5) — chỉ hiện sẵn 3, còn
// lại gấp gọn sau nút "Xem thêm" để sidebar không quá dài.
const SEGMENT_COLLAPSE_AT = 3;
const segmentExpanded = ref(false);
const visibleSegments = computed(() =>
  segmentExpanded.value ? currentSegments.value : currentSegments.value.slice(0, SEGMENT_COLLAPSE_AT),
);
watch(cat, () => {
  segmentExpanded.value = false;
});

// % giảm của 1 sản phẩm (0 nếu không có ưu đãi) — dùng cho cả sort lẫn lọc "chỉ ưu đãi".
const phanTramGiam = (p) =>
  p.oldPrice && p.oldPrice > p.price ? (p.oldPrice - p.price) / p.oldPrice : 0;

const sorters = {
  pop: (a, b) => b.rating - a.rating,
  low: (a, b) => a.price - b.price,
  high: (a, b) => b.price - a.price,
  disc: (a, b) => phanTramGiam(b) - phanTramGiam(a),     // ưu đãi nhiều → ít
  discAsc: (a, b) => phanTramGiam(a) - phanTramGiam(b),  // ưu đãi ít → nhiều
  sold: (a, b) => (b.soldCount || 0) - (a.soldCount || 0), // bán chạy nhất (dữ liệu đơn thật)
};

// Danh sách sau khi lọc theo mọi tiêu chí TRỪ thương hiệu — dùng để đếm số lượng sp/thương hiệu
// (đếm dựa trên các bộ lọc khác đang áp dụng, không tính chính bộ lọc thương hiệu).
const filteredExceptBrand = computed(() => {
  let l = base.value.slice();
  // Câu tìm kiếm tự do của khách dùng matchesSearch (mọi từ là điều kiện VÀ, bỏ dấu), KHÁC với
  // từ khoá phân khúc bên dưới vốn có cú pháp |/+/! riêng — xem data/products.js.
  if (state.q.trim()) {
    l = l.filter((p) => matchesSearch(p, state.q));
  }
  if (state.segmentKeyword) {
    l = l.filter((p) => matchesQuery(p, state.segmentKeyword));
  }
  l = l.filter((p) => p.price >= state.priceMin && p.price <= state.priceMax);
  if (state.minRating) l = l.filter((p) => p.rating >= state.minRating);
  if (state.inStockOnly) l = l.filter((p) => p.stock > 0);
  if (state.onlyDeal) l = l.filter((p) => p.oldPrice && p.oldPrice > p.price);
  if (state.onlyBestseller) l = l.filter((p) => (p.soldCount || 0) > 0);
  if (isMonitorCategory.value) {
    if (state.monSize.length) l = l.filter((p) => state.monSize.includes(specVal(p, 'Kích thước')));
    if (state.monReso.length) l = l.filter((p) => state.monReso.includes(specVal(p, 'Độ phân giải')));
  }
  if (isPcCategory.value) {
    if (state.pcCpuVendor) l = l.filter((p) => cpuVendorOf(specVal(p, 'CPU')) === state.pcCpuVendor);
    if (state.pcCpuSeries) l = l.filter((p) => cpuSeriesOf(specVal(p, 'CPU')) === state.pcCpuSeries);
    if (state.pcCaseBrand.length) l = l.filter((p) => state.pcCaseBrand.includes(specVal(p, 'Vỏ case')));
    if (state.pcMainboardBrand.length) l = l.filter((p) => state.pcMainboardBrand.includes(mainboardBrandOf(specVal(p, 'Mainboard'))));
    if (state.pcCoolerBrand.length) l = l.filter((p) => state.pcCoolerBrand.includes(coolerBrandOf(specVal(p, 'Tản nhiệt'))));
  }
  return l;
});

const list = computed(() => {
  let l = filteredExceptBrand.value;
  if (state.brandFilter.length)
    l = l.filter((p) => state.brandFilter.includes(p.brand));
  return l.slice().sort(sorters[state.sort] || sorters.pop);
});

const brands = computed(() =>
  allBrands.value.map((b) => ({
    name: b,
    active: state.brandFilter.includes(b),
    count: filteredExceptBrand.value.filter((p) => p.brand === b).length,
  })),
);

const priceMinText = computed(() => fmt(state.priceMin));
const priceMaxText = computed(() => fmt(state.priceMax));
const hasActiveFilters = computed(
  () =>
    state.brandFilter.length > 0 ||
    state.segmentKeyword !== '' ||
    state.priceMin > 0 ||
    state.priceMax < 70000000 ||
    state.minRating > 0 ||
    state.inStockOnly ||
    state.onlyDeal ||
    state.onlyBestseller ||
    state.monSize.length > 0 ||
    state.monReso.length > 0 ||
    state.sort !== 'pop' ||
    state.pcCpuVendor !== '' ||
    state.pcCpuSeries !== '' ||
    state.pcCaseBrand.length > 0 ||
    state.pcMainboardBrand.length > 0 ||
    state.pcCoolerBrand.length > 0,
);

// Chưa lọc gì (kể cả tìm kiếm) và danh mục có phân khúc định nghĩa sẵn -> hiện theo từng
// khối phân khúc (kiểu "Laptop Gaming" rồi sản phẩm bên dưới) giống trang chủ, thay vì 1
// lưới phẳng — dễ khám phá hơn khi mới vào danh mục. Hễ áp bộ lọc/tìm kiếm nào thì quay
// về lưới phẳng đã lọc (gộp mọi phân khúc) cho dễ so sánh kết quả.
const showSections = computed(() => currentSegments.value.length > 0 && !hasActiveFilters.value && !state.q.trim());
const sections = computed(() =>
  currentSegments.value.map((seg) => ({
    keyword: seg.keyword,
    label: seg.label,
    icon: seg.icon,
    count: seg.count,
    items: base.value.filter((p) => matchesQuery(p, seg.keyword)).slice().sort(sorters.pop),
  })),
);

// Ref tới từng hàng cuộn ngang theo phân khúc, dùng cho nút mũi tên trái/phải (giống HomeView.vue).
const rowEls = reactive({});
function setRowEl(keyword, el) {
  if (el) rowEls[keyword] = el;
}
function scrollRow(keyword, dir) {
  const el = rowEls[keyword];
  if (!el) return;
  el.scrollBy({ left: dir * el.clientWidth * 0.85, behavior: 'smooth' });
}
</script>

<template>
  <main style="max-width: 1800px; margin: 0 auto; padding: 24px 24px 70px">
    <div style="font-size: 12.5px; color: var(--muted); margin-bottom: 14px">
      <span @click="actions.goHome" style="cursor: pointer">Trang chủ</span>
      <span style="color: var(--muted)">/</span>
      <span style="color: var(--muted2)">{{ catTitle }}</span>
    </div>
    <div
      style="
        display: flex;
        align-items: baseline;
        gap: 12px;
        margin-bottom: 22px;
      "
    >
      <h1
        style="
          font-family: 'Plus Jakarta Sans', sans-serif;
          font-weight: 700;
          font-size: 28px;
          margin: 0;
        "
      >
        {{ catTitle }}
      </h1>
      <span style="font-size: 13px; color: var(--muted)"
        >{{ list.length }} sản phẩm</span
      >
    </div>
    <div
      v-if="currentSegments.length"
      style="
        display: flex;
        align-items: center;
        gap: 10px;
        flex-wrap: wrap;
        margin-bottom: 22px;
        padding: 14px 16px;
        background: var(--card);
        border: 1px solid rgba(var(--line-rgb), 0.12);
        border-radius: 12px;
      "
    >
      <span
        :style="{ color: accent }"
        style="
          font-family: 'Chakra Petch', sans-serif;
          font-size: 11px;
          letter-spacing: 1.5px;
          font-weight: 700;
          text-transform: uppercase;
          flex: none;
          margin-right: 2px;
        "
        >Phân khúc</span
      >
      <button
        v-for="seg in currentSegments"
        :key="seg.keyword"
        type="button"
        @click="actions.setSegment(seg.keyword)"
        :style="{
          background: state.segmentKeyword === seg.keyword ? accent : 'var(--card2)',
          color: state.segmentKeyword === seg.keyword ? 'var(--acc-ink)' : 'var(--muted2)',
          border: '1px solid ' + (state.segmentKeyword === seg.keyword ? accent : 'rgba(var(--line-rgb), 0.18)'),
        }"
        style="
          display: flex;
          align-items: center;
          gap: 6px;
          padding: 8px 14px;
          border-radius: 20px;
          font-size: 12.5px;
          font-weight: 600;
          cursor: pointer;
          font-family: 'Plus Jakarta Sans', sans-serif;
          white-space: nowrap;
          transition: background 0.18s ease, color 0.18s ease, border-color 0.18s ease;
        "
      >
        <i :class="'bi ' + seg.icon" style="font-size: 12px"></i>
        {{ seg.label }}
        <span style="font-size: 11px; opacity: 0.75">{{ seg.count }}</span>
      </button>
    </div>
    <div
      style="
        display: grid;
        grid-template-columns: 248px 1fr;
        gap: 26px;
        align-items: start;
      "
    >
      <!-- filters -->
      <aside
        style="
          position: sticky;
          top: 130px;
          max-height: calc(100vh - 150px);
          overflow-y: auto;
          background: var(--card);
          border: 1px solid rgba(var(--line-rgb), 0.12);
          border-radius: 14px;
          padding: 20px;
        "
      >
        <div
          style="
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 14px;
          "
        >
          <div
            :style="{ color: accent }"
            style="
              font-family: 'Chakra Petch', sans-serif;
              font-size: 11px;
              letter-spacing: 2px;
              font-weight: 600;
            "
          >
            BỘ LỌC
          </div>
          <button
            v-if="hasActiveFilters"
            @click="actions.clearFilters"
            style="
              background: transparent;
              border: none;
              color: var(--sale);
              font-size: 11.5px;
              cursor: pointer;
              padding: 0;
            "
          >
            Xóa bộ lọc
          </button>
        </div>
        <div v-if="currentSegments.length" style="margin-bottom: 22px">
          <label
            style="
              display: block;
              font-size: 12.5px;
              color: var(--muted2);
              margin-bottom: 10px;
            "
            >Phân khúc</label
          >
          <TransitionGroup tag="div" name="seg-item" style="display: flex; flex-direction: column; gap: 6px">
            <div
              v-for="seg in visibleSegments"
              :key="seg.keyword"
              @click="actions.setSegment(seg.keyword)"
              style="display: flex; align-items: center; gap: 9px; padding: 8px 9px; border-radius: 9px; cursor: pointer; transition: background 0.15s ease, color 0.15s ease"
              :style="{
                background: state.segmentKeyword === seg.keyword ? 'color-mix(in srgb, ' + accent + ' 14%, transparent)' : 'transparent',
                color: state.segmentKeyword === seg.keyword ? 'var(--text)' : 'var(--muted2)',
              }"
            >
              <i :class="'bi ' + seg.icon" :style="{ color: state.segmentKeyword === seg.keyword ? accent : 'var(--muted)' }" style="font-size: 14px; width: 16px; text-align: center; flex: none"></i>
              <span style="font-size: 13px; flex: 1">{{ seg.label }}</span>
              <span style="font-size: 11.5px; color: var(--muted)">{{ seg.count }}</span>
            </div>
          </TransitionGroup>
          <button
            v-if="currentSegments.length > SEGMENT_COLLAPSE_AT"
            type="button"
            @click="segmentExpanded = !segmentExpanded"
            :style="{ color: accent }"
            style="
              display: flex;
              align-items: center;
              gap: 4px;
              margin-top: 6px;
              padding: 6px 9px;
              background: transparent;
              border: none;
              font-size: 12.5px;
              font-weight: 600;
              cursor: pointer;
              font-family: 'Plus Jakarta Sans', sans-serif;
            "
          >
            {{ segmentExpanded ? 'Thu gọn' : 'Xem thêm (' + (currentSegments.length - SEGMENT_COLLAPSE_AT) + ')' }}
            <i :class="'bi ' + (segmentExpanded ? 'bi-chevron-up' : 'bi-chevron-down')" style="font-size: 10px"></i>
          </button>
        </div>
        <div style="margin-bottom: 22px">
          <label
            style="
              display: block;
              font-size: 12.5px;
              color: var(--muted2);
              margin-bottom: 8px;
            "
            >Sắp xếp</label
          >
          <select
            :value="state.sort"
            @change="actions.setSort($event.target.value)"
            style="
              width: 100%;
              height: 40px;
              padding: 0 12px;
              border-radius: 10px;
              background: var(--card2);
              color: var(--text);
              border: 1px solid rgba(var(--line-rgb), 0.2);
              font-family: 'Plus Jakarta Sans', sans-serif;
              font-size: 13px;
              cursor: pointer;
            "
          >
            <option value="pop">Phổ biến nhất</option>
            <option value="sold">Bán chạy nhất</option>
            <option value="low">Giá thấp → cao</option>
            <option value="high">Giá cao → thấp</option>
            <option value="disc">Ưu đãi nhiều → ít</option>
            <option value="discAsc">Ưu đãi ít → nhiều</option>
          </select>
        </div>
        <div v-if="!isPcCategory" style="margin-bottom: 22px">
          <label
            style="
              display: block;
              font-size: 12.5px;
              color: var(--muted2);
              margin-bottom: 10px;
            "
            >Thương hiệu</label
          >
          <div style="display: flex; flex-direction: column; gap: 9px">
            <div
              v-for="b in brands"
              :key="b.name"
              @click="actions.toggleBrand(b.name)"
              style="
                display: flex;
                align-items: center;
                gap: 10px;
                cursor: pointer;
              "
            >
              <span
                class="filter-checkbox"
                :style="{ background: b.active ? accent : 'transparent' }"
                style="
                  width: 18px;
                  height: 18px;
                  border-radius: 5px;
                  border: 1px solid rgba(var(--line-rgb), 0.3);
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  flex: none;
                "
              >
                <Transition name="check-pop">
                <span
                  v-if="b.active"
                  style="color: var(--acc-ink); font-size: 12px; font-weight: 700"
                  >✓</span
                >
                </Transition>
              </span>
              <span style="font-size: 13px; color: var(--muted2); flex: 1">{{ b.name }}</span>
              <span style="font-size: 11.5px; color: var(--muted)">{{ b.count }}</span>
            </div>
          </div>
        </div>

        <!-- Bộ lọc riêng cho PC & Máy tính bàn: hãng CPU + dòng chip, thay cho Thương hiệu chung -->
        <div v-if="isPcCategory && pcCpuVendors.length" style="margin-bottom: 22px">
          <label style="display: block; font-size: 12.5px; color: var(--muted2); margin-bottom: 10px">Hãng CPU</label>
          <div
            :style="{ marginBottom: pcCpuSeriesOptions.length ? '10px' : '0' }"
            style="display: flex; gap: 8px"
          >
            <button
              v-for="v in pcCpuVendors"
              :key="v"
              type="button"
              @click="actions.setPcCpuVendor(v)"
              :style="{
                background: state.pcCpuVendor === v ? accent : 'var(--card2)',
                color: state.pcCpuVendor === v ? 'var(--acc-ink)' : 'var(--muted2)',
              }"
              style="flex: 1; height: 36px; border: none; border-radius: 9px; font-size: 13px; font-weight: 600; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif; transition: background 0.15s ease, color 0.15s ease"
            >
              {{ v }}
            </button>
          </div>
          <div v-if="pcCpuSeriesOptions.length" style="display: flex; flex-direction: column; gap: 4px">
            <div
              v-for="s in pcCpuSeriesOptions"
              :key="s.key"
              @click="actions.setPcCpuSeries(s.key)"
              style="display: flex; align-items: center; gap: 9px; padding: 7px 9px; border-radius: 9px; cursor: pointer"
              :style="{
                background: state.pcCpuSeries === s.key ? 'color-mix(in srgb, ' + accent + ' 14%, transparent)' : 'transparent',
                color: state.pcCpuSeries === s.key ? 'var(--text)' : 'var(--muted2)',
              }"
            >
              <span
                class="filter-checkbox"
                :style="{ background: state.pcCpuSeries === s.key ? accent : 'transparent' }"
                style="width: 16px; height: 16px; border-radius: 4px; border: 1px solid rgba(var(--line-rgb), 0.3); flex: none; display: flex; align-items: center; justify-content: center"
              >
                <Transition name="check-pop"><span v-if="state.pcCpuSeries === s.key" style="color: var(--acc-ink); font-size: 10px; font-weight: 700">✓</span></Transition>
              </span>
              <span style="font-size: 12.5px">{{ s.label }}</span>
            </div>
          </div>
        </div>
        <div v-if="isPcCategory && pcMainboardBrands.length" style="margin-bottom: 22px">
          <label style="display: block; font-size: 12.5px; color: var(--muted2); margin-bottom: 10px">Mainboard</label>
          <div style="display: flex; flex-direction: column; gap: 9px">
            <div
              v-for="b in pcMainboardBrands"
              :key="b"
              @click="actions.togglePcMainboardBrand(b)"
              style="display: flex; align-items: center; gap: 10px; cursor: pointer"
            >
              <span
                class="filter-checkbox"
                :style="{ background: state.pcMainboardBrand.includes(b) ? accent : 'transparent' }"
                style="width: 18px; height: 18px; border-radius: 5px; border: 1px solid rgba(var(--line-rgb), 0.3); display: flex; align-items: center; justify-content: center; flex: none"
              >
                <Transition name="check-pop"><span v-if="state.pcMainboardBrand.includes(b)" style="color: var(--acc-ink); font-size: 12px; font-weight: 700">✓</span></Transition>
              </span>
              <span style="font-size: 13px; color: var(--muted2); flex: 1">{{ b }}</span>
            </div>
          </div>
        </div>
        <div v-if="isPcCategory && pcCaseBrands.length" style="margin-bottom: 22px">
          <label style="display: block; font-size: 12.5px; color: var(--muted2); margin-bottom: 10px">Vỏ case</label>
          <div style="display: flex; flex-direction: column; gap: 9px">
            <div
              v-for="b in pcCaseBrands"
              :key="b"
              @click="actions.togglePcCaseBrand(b)"
              style="display: flex; align-items: center; gap: 10px; cursor: pointer"
            >
              <span
                class="filter-checkbox"
                :style="{ background: state.pcCaseBrand.includes(b) ? accent : 'transparent' }"
                style="width: 18px; height: 18px; border-radius: 5px; border: 1px solid rgba(var(--line-rgb), 0.3); display: flex; align-items: center; justify-content: center; flex: none"
              >
                <Transition name="check-pop"><span v-if="state.pcCaseBrand.includes(b)" style="color: var(--acc-ink); font-size: 12px; font-weight: 700">✓</span></Transition>
              </span>
              <span style="font-size: 13px; color: var(--muted2); flex: 1">{{ b }}</span>
            </div>
          </div>
        </div>
        <div v-if="isPcCategory && pcCoolerBrands.length" style="margin-bottom: 22px">
          <label style="display: block; font-size: 12.5px; color: var(--muted2); margin-bottom: 10px">Tản nhiệt</label>
          <div style="display: flex; flex-direction: column; gap: 9px">
            <div
              v-for="b in pcCoolerBrands"
              :key="b"
              @click="actions.togglePcCoolerBrand(b)"
              style="display: flex; align-items: center; gap: 10px; cursor: pointer"
            >
              <span
                class="filter-checkbox"
                :style="{ background: state.pcCoolerBrand.includes(b) ? accent : 'transparent' }"
                style="width: 18px; height: 18px; border-radius: 5px; border: 1px solid rgba(var(--line-rgb), 0.3); display: flex; align-items: center; justify-content: center; flex: none"
              >
                <Transition name="check-pop"><span v-if="state.pcCoolerBrand.includes(b)" style="color: var(--acc-ink); font-size: 12px; font-weight: 700">✓</span></Transition>
              </span>
              <span style="font-size: 13px; color: var(--muted2); flex: 1">{{ b }}</span>
            </div>
          </div>
        </div>
        <!-- Bộ lọc riêng cho Màn hình: Kích thước + Độ phân giải -->
        <div v-if="isMonitorCategory && monSizeOptions.length" style="margin-bottom: 22px">
          <label style="display: block; font-size: 12.5px; color: var(--muted2); margin-bottom: 10px">Kích thước</label>
          <div style="display: flex; flex-direction: column; gap: 9px">
            <div
              v-for="s in monSizeOptions"
              :key="s"
              @click="actions.toggleMonSize(s)"
              style="display: flex; align-items: center; gap: 10px; cursor: pointer"
            >
              <span
                class="filter-checkbox"
                :style="{ background: state.monSize.includes(s) ? accent : 'transparent' }"
                style="width: 18px; height: 18px; border-radius: 5px; border: 1px solid rgba(var(--line-rgb), 0.3); display: flex; align-items: center; justify-content: center; flex: none"
              >
                <Transition name="check-pop"><span v-if="state.monSize.includes(s)" style="color: var(--acc-ink); font-size: 12px; font-weight: 700">✓</span></Transition>
              </span>
              <span style="font-size: 13px; color: var(--muted2); flex: 1">{{ s }}</span>
            </div>
          </div>
        </div>
        <div v-if="isMonitorCategory && monResoOptions.length" style="margin-bottom: 22px">
          <label style="display: block; font-size: 12.5px; color: var(--muted2); margin-bottom: 10px">Độ phân giải</label>
          <div style="display: flex; flex-direction: column; gap: 9px">
            <div
              v-for="rs in monResoOptions"
              :key="rs"
              @click="actions.toggleMonReso(rs)"
              style="display: flex; align-items: center; gap: 10px; cursor: pointer"
            >
              <span
                class="filter-checkbox"
                :style="{ background: state.monReso.includes(rs) ? accent : 'transparent' }"
                style="width: 18px; height: 18px; border-radius: 5px; border: 1px solid rgba(var(--line-rgb), 0.3); display: flex; align-items: center; justify-content: center; flex: none"
              >
                <Transition name="check-pop"><span v-if="state.monReso.includes(rs)" style="color: var(--acc-ink); font-size: 12px; font-weight: 700">✓</span></Transition>
              </span>
              <span style="font-size: 13px; color: var(--muted2); flex: 1">{{ rs }}</span>
            </div>
          </div>
        </div>
        <div style="margin-bottom: 22px">
          <label
            style="
              display: block;
              font-size: 12.5px;
              color: var(--muted2);
              margin-bottom: 8px;
            "
            >Đánh giá</label
          >
          <div style="display: flex; flex-direction: column; gap: 8px">
            <div
              v-for="r in [5, 4, 3]"
              :key="r"
              @click="actions.setMinRating(r)"
              style="
                display: flex;
                align-items: center;
                gap: 8px;
                cursor: pointer;
                padding: 6px 8px;
                border-radius: 8px;
                transition: background 0.15s ease;
              "
              :style="{
                background: state.minRating === r ? 'color-mix(in srgb, ' + accent + ' 12%, transparent)' : 'transparent',
              }"
            >
              <span style="color: #ffcf4d; font-size: 12.5px">{{ '★'.repeat(r) }}<span style="color: var(--muted)">{{ '★'.repeat(5 - r) }}</span></span>
              <span style="font-size: 12.5px; color: var(--muted2)">trở lên</span>
            </div>
          </div>
        </div>
        <div style="margin-bottom: 12px">
          <label
            @click="actions.toggleOnlyDeal"
            style="display: flex; align-items: center; gap: 10px; cursor: pointer"
          >
            <span
              class="filter-checkbox"
              :style="{ background: state.onlyDeal ? accent : 'transparent' }"
              style="width: 18px; height: 18px; border-radius: 5px; border: 1px solid rgba(var(--line-rgb), 0.3); display: flex; align-items: center; justify-content: center; flex: none"
            >
              <Transition name="check-pop">
              <span v-if="state.onlyDeal" style="color: var(--acc-ink); font-size: 12px; font-weight: 700">✓</span>
              </Transition>
            </span>
            <span style="font-size: 13px; color: var(--muted2)">🏷️ Chỉ chương trình ưu đãi</span>
          </label>
        </div>
        <div style="margin-bottom: 12px">
          <label
            @click="actions.toggleOnlyBestseller"
            style="display: flex; align-items: center; gap: 10px; cursor: pointer"
          >
            <span
              class="filter-checkbox"
              :style="{ background: state.onlyBestseller ? accent : 'transparent' }"
              style="width: 18px; height: 18px; border-radius: 5px; border: 1px solid rgba(var(--line-rgb), 0.3); display: flex; align-items: center; justify-content: center; flex: none"
            >
              <Transition name="check-pop">
              <span v-if="state.onlyBestseller" style="color: var(--acc-ink); font-size: 12px; font-weight: 700">✓</span>
              </Transition>
            </span>
            <span style="font-size: 13px; color: var(--muted2)">🔥 Chỉ sản phẩm bán chạy</span>
          </label>
        </div>
        <div style="margin-bottom: 22px">
          <label
            @click="actions.toggleInStockOnly"
            style="
              display: flex;
              align-items: center;
              gap: 10px;
              cursor: pointer;
            "
          >
            <span
              class="filter-checkbox"
              :style="{ background: state.inStockOnly ? accent : 'transparent' }"
              style="
                width: 18px;
                height: 18px;
                border-radius: 5px;
                border: 1px solid rgba(var(--line-rgb), 0.3);
                display: flex;
                align-items: center;
                justify-content: center;
                flex: none;
              "
            >
              <Transition name="check-pop">
              <span
                v-if="state.inStockOnly"
                style="color: var(--acc-ink); font-size: 12px; font-weight: 700"
                >✓</span
              >
              </Transition>
            </span>
            <span style="font-size: 13px; color: var(--muted2)">Chỉ hiện còn hàng</span>
          </label>
        </div>
        <div>
          <label
            style="
              display: block;
              font-size: 12.5px;
              color: var(--muted2);
              margin-bottom: 8px;
            "
            >Giá tối thiểu:
            <span :style="{ color: accent }" style="font-weight: 600">{{
              priceMinText
            }}</span></label
          >
          <input
            type="range"
            min="0"
            max="70000000"
            step="500000"
            :value="state.priceMin"
            @input="actions.setPriceMin($event.target.value)"
            :style="{ accentColor: accent }"
            style="width: 100%; cursor: pointer; margin-bottom: 16px"
          />
          <label
            style="
              display: block;
              font-size: 12.5px;
              color: var(--muted2);
              margin-bottom: 8px;
            "
            >Giá tối đa:
            <span :style="{ color: accent }" style="font-weight: 600">{{
              priceMaxText
            }}</span></label
          >
          <input
            type="range"
            min="2000000"
            max="70000000"
            step="500000"
            :value="state.priceMax"
            @input="actions.setPriceMax($event.target.value)"
            :style="{ accentColor: accent }"
            style="width: 100%; cursor: pointer"
          />
        </div>
      </aside>
      <!-- grid -->
      <!-- min-width:0 BẮT BUỘC: cột nội dung là grid item "1fr", mặc định min-width:auto = min-content,
           nên hàng sản phẩm cuộn ngang (.cat-row-scroll) đẩy cột rộng ra thay vì cuộn trong nó ->
           cả trang bị tràn ngang. min-width:0 cho cột co lại đúng khung, để overflow-x:auto hoạt động. -->
      <div style="min-width: 0">
        <!-- Theo phân khúc: mỗi khối 1 tiêu đề + hàng sản phẩm cuộn ngang, giống trang chủ -->
        <div v-if="showSections" style="display: flex; flex-direction: column; gap: 34px">
          <section v-for="sec in sections" :key="sec.keyword">
            <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 16px">
              <i :class="'bi ' + sec.icon" :style="{ color: accent }" style="font-size: 18px"></i>
              <h2 style="font-family: 'Plus Jakarta Sans', sans-serif; font-weight: 700; font-size: 18px; margin: 0">{{ sec.label }}</h2>
              <span style="font-size: 13px; color: var(--muted)">{{ sec.count }} sản phẩm</span>
              <div style="flex: 1"></div>
              <button
                type="button"
                @click="actions.setSegment(sec.keyword)"
                :style="{ color: accent }"
                style="background: transparent; border: none; font-size: 13px; font-weight: 600; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif; flex: none"
              >
                Xem tất cả »
              </button>
            </div>
            <div style="position: relative">
              <button
                class="cat-row-nav cat-row-nav--prev"
                type="button"
                aria-label="Xem sản phẩm trước"
                @click="scrollRow(sec.keyword, -1)"
              >
                ‹
              </button>
              <div
                :ref="(el) => setRowEl(sec.keyword, el)"
                class="cat-row-scroll"
                style="display: flex; gap: 16px; overflow-x: auto; padding: 8px 2px 6px; margin: -8px -2px 0"
              >
                <div v-for="p in sec.items" :key="p.id" style="flex: none; width: 220px">
                  <ProductCard :p="p" @open="actions.goDetail" @add="actions.addToCart" />
                </div>
              </div>
              <button
                class="cat-row-nav cat-row-nav--next"
                type="button"
                aria-label="Xem sản phẩm tiếp theo"
                @click="scrollRow(sec.keyword, 1)"
              >
                ›
              </button>
            </div>
          </section>
        </div>
        <div
          v-else-if="list.length"
          style="
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 18px;
          "
        >
          <ProductCard
            v-for="p in list"
            :key="p.id"
            :p="p"
            @open="actions.goDetail"
            @add="actions.addToCart"
          />
        </div>
        <div
          v-else
          style="
            padding: 70px 20px;
            text-align: center;
            color: var(--muted);
            background: var(--card);
            border-radius: 14px;
            border: 1px solid rgba(var(--line-rgb), 0.12);
          "
        >
          <div style="font-size: 34px; margin-bottom: 12px">🔍</div>
          <div style="font-size: 15px; color: var(--muted2)">
            Không tìm thấy sản phẩm phù hợp
          </div>
          <div style="font-size: 13px; margin-top: 6px">
            Thử bỏ bớt bộ lọc hoặc tăng mức giá.
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<style scoped>

.cat-row-scroll {
  scrollbar-width: none;
}
.cat-row-scroll::-webkit-scrollbar {
  display: none;
}
.cat-row-nav {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 38px;
  height: 38px;
  border-radius: 50%;
  border: 1px solid rgba(var(--line-rgb), 0.22);
  background: var(--card);
  color: var(--text);
  font-size: 19px;
  line-height: 1;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
  z-index: 2;
  transition: transform 0.15s ease, border-color 0.15s ease, color 0.15s ease;
}
.cat-row-nav:hover {
  border-color: var(--acc);
  color: var(--acc);
  transform: translateY(-50%) scale(1.08);
}
.cat-row-nav--prev {
  left: -16px;
}
.cat-row-nav--next {
  right: -16px;
}

/* "Xem thêm (N)" phân khúc — các dòng mới hiện ra trượt/mờ dần thay vì bật thẳng ra. */
.seg-item-enter-active,
.seg-item-leave-active {
  transition: opacity 0.18s ease, transform 0.18s ease;
}
.seg-item-enter-from,
.seg-item-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}
.seg-item-leave-active {
  position: absolute;
}
</style>
