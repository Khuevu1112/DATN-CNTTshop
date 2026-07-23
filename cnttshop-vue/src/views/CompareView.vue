<script setup>
import { ref, computed, onMounted } from 'vue';
import { actions, accent, state } from '../store.js';
import { fetchProducts, fetchProductBySlug, fetchMyPcBuilds, fetchPcBuildDetail } from '../api.js';

const loading = ref(true);
const storeConfigs = ref([]); // ProductSummaryDto[] (danh mục "pc-may-tinh-ban" — PC build sẵn của cửa hàng)
const myConfigs = ref([]); // PcBuildSummaryDto[]
const detailCache = ref({}); // 'store-<id>' | 'my-<id>' -> { id, name, totalPrice, sourceLabel, items }
const hoveredKey = ref(null);
const selectedKeys = ref([]); // tối đa 2, thứ tự = [A, B]

const COL_B = '#ff45e0';

const CANONICAL = [
  { key: 'CPU', label: 'CPU', icon: 'bi-cpu' },
  { key: 'MAINBOARD', label: 'Mainboard', icon: 'bi-motherboard' },
  { key: 'RAM', label: 'RAM', icon: 'bi-memory' },
  { key: 'GPU', label: 'Card đồ họa', icon: 'bi-gpu-card' },
  { key: 'SSD', label: 'Ổ cứng', icon: 'bi-device-ssd' },
  { key: 'HDD', label: 'Ổ HDD', icon: 'bi-hdd' },
  { key: 'PSU', label: 'Nguồn', icon: 'bi-lightning-charge' },
  { key: 'CASE', label: 'Vỏ case', icon: 'bi-pc-display' },
  { key: 'COOLER', label: 'Tản nhiệt', icon: 'bi-wind' },
  { key: 'MONITOR', label: 'Màn hình', icon: 'bi-display' },
  { key: 'MOUSE', label: 'Chuột', icon: 'bi-mouse' },
  { key: 'KEYBOARD', label: 'Bàn phím', icon: 'bi-keyboard' },
];
// PC build sẵn (thông số dạng text tự do trên PRODUCT_SPEC) và cấu hình tự tạo (mã loại linh
// kiện cố định của PcBuild) dùng 2 kiểu ký hiệu khác nhau — quy về 1 bộ khoá chung để gióng hàng.
const ALIAS = {
  CPU: 'CPU',
  MAINBOARD: 'MAINBOARD', Mainboard: 'MAINBOARD',
  RAM: 'RAM',
  GPU: 'GPU', 'Card đồ họa': 'GPU',
  SSD: 'SSD', 'Ổ cứng': 'SSD',
  HDD: 'HDD',
  PSU: 'PSU', 'Nguồn': 'PSU',
  CASE: 'CASE', Case: 'CASE',
  CPU_COOLER: 'COOLER', Cooler: 'COOLER',
  MONITOR: 'MONITOR', Monitor: 'MONITOR',
  Mouse: 'MOUSE',
  Keyboard: 'KEYBOARD',
};
function canonicalOf(type) {
  const key = ALIAS[type] || String(type || '').toUpperCase();
  return CANONICAL.find((c) => c.key === key) || { key, label: type, icon: 'bi-box' };
}

const fmt = (n) => (n == null ? '—' : Number(n).toLocaleString('vi-VN') + '₫');

/** PC build sẵn: thông số chỉ là text mô tả (spec_key/spec_value), không có giá riêng từng linh kiện. */
function normalizeProductSpecs(detail) {
  return (detail.specs || []).map((s) => ({
    ...canonicalOf(s.key),
    name: s.value,
    price: null,
  }));
}
/** Cấu hình tự tạo: mỗi linh kiện là 1 variant thật, có giá riêng. */
function normalizePcBuildItems(detail) {
  return (detail.items || []).map((it) => ({
    ...canonicalOf(it.componentType),
    name: it.productName + (it.quantity > 1 ? ' x' + it.quantity : ''),
    price: (it.price || 0) * (it.quantity || 1),
  }));
}

async function load() {
  loading.value = true;
  try {
    const [products, builds] = await Promise.all([
      fetchProducts({ categorySlug: 'pc-may-tinh-ban' }),
      state.token ? fetchMyPcBuilds().catch(() => []) : Promise.resolve([]),
    ]);
    storeConfigs.value = products;
    myConfigs.value = builds;

    const jobs = [];
    products.forEach((p) => {
      jobs.push(
        fetchProductBySlug(p.slug).then((d) => {
          detailCache.value['store-' + p.id] = {
            id: p.id, name: p.name, totalPrice: p.price,
            sourceLabel: 'PC build sẵn của cửa hàng', items: normalizeProductSpecs(d),
          };
        }),
      );
    });
    builds.forEach((b) => {
      jobs.push(
        fetchPcBuildDetail(b.id).then((d) => {
          detailCache.value['my-' + b.id] = {
            id: b.id, name: b.name, totalPrice: d.totalPrice,
            sourceLabel: 'Cấu hình của bạn', items: normalizePcBuildItems(d),
          };
        }),
      );
    });
    await Promise.all(jobs);
  } finally {
    loading.value = false;
  }
}
onMounted(load);

function toggleSelect(key) {
  const idx = selectedKeys.value.indexOf(key);
  if (idx >= 0) {
    selectedKeys.value = selectedKeys.value.filter((k) => k !== key);
    return;
  }
  const next = selectedKeys.value.slice();
  if (next.length >= 2) next.shift();
  next.push(key);
  selectedKeys.value = next;
}
function colorOf(key) {
  const idx = selectedKeys.value.indexOf(key);
  if (idx === 0) return accent.value;
  if (idx === 1) return COL_B;
  return null;
}
function badgeOf(key) {
  const idx = selectedKeys.value.indexOf(key);
  return idx === 0 ? 'A' : idx === 1 ? 'B' : '';
}

const configA = computed(() => (selectedKeys.value[0] ? detailCache.value[selectedKeys.value[0]] : null));
const configB = computed(() => (selectedKeys.value[1] ? detailCache.value[selectedKeys.value[1]] : null));

const compareRows = computed(() => {
  if (!configA.value && !configB.value) return [];
  const present = new Set([
    ...((configA.value?.items || []).map((i) => i.key)),
    ...((configB.value?.items || []).map((i) => i.key)),
  ]);
  return CANONICAL.filter((c) => present.has(c.key)).map((c) => ({
    ...c,
    a: configA.value?.items.find((i) => i.key === c.key),
    b: configB.value?.items.find((i) => i.key === c.key),
  }));
});
</script>

<template>
  <main style="max-width: 1320px; margin: 0 auto; padding: 24px 24px 64px">
    <button
      @click="actions.goHome"
      style="display: inline-flex; align-items: center; gap: 6px; background: transparent; border: 1px solid rgba(var(--line-rgb),0.2); color: var(--muted); border-radius: 9px; padding: 8px 14px; font-size: 13px; cursor: pointer; margin-bottom: 28px; font-family: 'Be Vietnam Pro', sans-serif"
    >
      ← Quay lại trang chủ
    </button>

    <div style="font-family: 'Chakra Petch', sans-serif; font-size: 11px; letter-spacing: 2.5px; color: var(--acc,#c6ff4a); font-weight: 600; margin-bottom: 12px">
      SO SÁNH CẤU HÌNH
    </div>
    <h1 style="font-family: 'Be Vietnam Pro', sans-serif; font-weight: 800; font-size: 34px; margin: 0 0 24px; color: var(--text)">
      So sánh cấu hình PC
    </h1>

    <div v-if="loading" style="color: var(--muted); padding: 60px; text-align: center">Đang tải...</div>

    <div v-else style="display: grid; grid-template-columns: 3fr 4fr; gap: 20px; align-items: start">
      <!-- ===== TRÁI: danh sách chọn ===== -->
      <div style="display: flex; flex-direction: column; gap: 16px">
        <!-- Nửa trên: PC build sẵn của cửa hàng -->
        <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 16px">
          <div style="font-size: 12px; font-weight: 700; color: var(--text); margin-bottom: 12px; display: flex; align-items: center; gap: 7px">
            <i class="bi bi-shop"></i> Cấu hình cửa hàng
          </div>
          <div v-if="!storeConfigs.length" style="font-size: 12.5px; color: var(--muted); padding: 10px 0">Chưa có PC build sẵn nào.</div>
          <div style="display: flex; flex-direction: column; gap: 8px; max-height: 300px; overflow-y: auto">
            <div
              v-for="p in storeConfigs" :key="'store-' + p.id"
              @click="toggleSelect('store-' + p.id)"
              @mouseenter="hoveredKey = 'store-' + p.id" @mouseleave="hoveredKey = null"
              style="position: relative; padding: 10px 12px; border-radius: 10px; cursor: pointer"
              :style="{
                border: '1px solid ' + (colorOf('store-' + p.id) || 'rgba(var(--line-rgb),0.16)'),
                background: colorOf('store-' + p.id) ? 'color-mix(in srgb, ' + colorOf('store-' + p.id) + ' 10%, transparent)' : 'var(--card2)',
              }"
            >
              <div style="display: flex; justify-content: space-between; align-items: center; gap: 8px">
                <span style="font-size: 13px; color: var(--text); font-weight: 600">{{ p.name }}</span>
                <span v-if="badgeOf('store-' + p.id)" :style="{ background: colorOf('store-' + p.id) }" style="width: 20px; height: 20px; border-radius: 50%; color: var(--acc-ink); font-size: 11px; font-weight: 700; display: flex; align-items: center; justify-content: center; flex: none">{{ badgeOf('store-' + p.id) }}</span>
              </div>
              <div style="font-size: 11.5px; color: var(--muted); margin-top: 4px">{{ fmt(p.price) }}</div>

              <!-- Xem trước khi hover -->
              <div v-if="hoveredKey === 'store-' + p.id && detailCache['store-' + p.id]"
                style="position: absolute; top: 0; left: 100%; margin-left: 10px; width: 260px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.25); border-radius: 12px; padding: 12px; z-index: 40; box-shadow: 0 14px 34px rgba(0,0,0,0.5)">
                <div style="font-size: 12.5px; font-weight: 700; color: var(--text); margin-bottom: 8px">{{ p.name }}</div>
                <div v-for="it in detailCache['store-' + p.id].items" :key="it.key" style="display: flex; justify-content: space-between; gap: 8px; font-size: 11.5px; color: var(--muted2); padding: 3px 0">
                  <span><i :class="'bi ' + it.icon" style="margin-right: 5px; color: var(--muted)"></i>{{ it.label }}: {{ it.name }}</span>
                </div>
                <div v-if="!detailCache['store-' + p.id].items.length" style="font-size: 11.5px; color: var(--muted)">Chưa có thông số chi tiết.</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Nửa dưới: cấu hình tự tạo -->
        <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 16px">
          <div style="font-size: 12px; font-weight: 700; color: var(--text); margin-bottom: 12px; display: flex; align-items: center; gap: 7px">
            <i class="bi bi-person-gear"></i> Cấu hình tự tạo
          </div>

          <div v-if="!state.token" style="text-align: center; padding: 20px 10px">
            <div style="font-size: 12.5px; color: var(--muted2); margin-bottom: 12px">Đăng nhập để so sánh cấu hình của riêng bạn.</div>
            <button @click="actions.openLogin" :style="{ background: accent }" style="height: 36px; padding: 0 16px; border: none; border-radius: 9px; color: var(--acc-ink); font-weight: 700; font-size: 12.5px; cursor: pointer">Đăng nhập</button>
          </div>
          <div v-else-if="!myConfigs.length" style="text-align: center; padding: 20px 10px">
            <div style="font-size: 12.5px; color: var(--muted2); margin-bottom: 12px">Bạn chưa có cấu hình nào. Tạo ngay!</div>
            <button @click="actions.goPcBuild" :style="{ background: accent }" style="height: 36px; padding: 0 16px; border: none; border-radius: 9px; color: var(--acc-ink); font-weight: 700; font-size: 12.5px; cursor: pointer">Xây dựng cấu hình</button>
          </div>
          <div v-else style="display: flex; flex-direction: column; gap: 8px; max-height: 300px; overflow-y: auto">
            <div
              v-for="b in myConfigs" :key="'my-' + b.id"
              @click="toggleSelect('my-' + b.id)"
              @mouseenter="hoveredKey = 'my-' + b.id" @mouseleave="hoveredKey = null"
              style="position: relative; padding: 10px 12px; border-radius: 10px; cursor: pointer"
              :style="{
                border: '1px solid ' + (colorOf('my-' + b.id) || 'rgba(var(--line-rgb),0.16)'),
                background: colorOf('my-' + b.id) ? 'color-mix(in srgb, ' + colorOf('my-' + b.id) + ' 10%, transparent)' : 'var(--card2)',
              }"
            >
              <div style="display: flex; justify-content: space-between; align-items: center; gap: 8px">
                <span style="font-size: 13px; color: var(--text); font-weight: 600">{{ b.name }}</span>
                <span v-if="badgeOf('my-' + b.id)" :style="{ background: colorOf('my-' + b.id) }" style="width: 20px; height: 20px; border-radius: 50%; color: var(--acc-ink); font-size: 11px; font-weight: 700; display: flex; align-items: center; justify-content: center; flex: none">{{ badgeOf('my-' + b.id) }}</span>
              </div>
              <div style="font-size: 11.5px; color: var(--muted); margin-top: 4px">{{ b.itemCount }} linh kiện · {{ fmt(b.totalPrice) }}</div>

              <div v-if="hoveredKey === 'my-' + b.id && detailCache['my-' + b.id]"
                style="position: absolute; top: 0; left: 100%; margin-left: 10px; width: 260px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.25); border-radius: 12px; padding: 12px; z-index: 40; box-shadow: 0 14px 34px rgba(0,0,0,0.5)">
                <div style="font-size: 12.5px; font-weight: 700; color: var(--text); margin-bottom: 8px">{{ b.name }}</div>
                <div v-for="it in detailCache['my-' + b.id].items" :key="it.key" style="display: flex; justify-content: space-between; gap: 8px; font-size: 11.5px; color: var(--muted2); padding: 3px 0">
                  <span><i :class="'bi ' + it.icon" style="margin-right: 5px; color: var(--muted)"></i>{{ it.name }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

      </div>

      <!-- ===== PHẢI: bảng so sánh chi tiết ===== -->
      <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; overflow: hidden; min-height: 300px">
        <div v-if="!configA && !configB" style="padding: 70px 20px; text-align: center; color: var(--muted)">
          <div style="font-size: 30px; margin-bottom: 12px">⚖️</div>
          <div style="font-size: 14px; color: var(--muted2)">Chọn 2 cấu hình bên trái để so sánh</div>
        </div>
        <div v-else-if="!configB" style="padding: 70px 20px; text-align: center; color: var(--muted)">
          <div style="font-size: 14px; color: var(--muted2)">Đã chọn <b :style="{ color: accent }">{{ configA.name }}</b></div>
          <div style="font-size: 13px; margin-top: 6px">Chọn thêm 1 cấu hình nữa để so sánh.</div>
        </div>
        <table v-else style="width: 100%; border-collapse: collapse; font-size: 13px">
          <thead>
            <tr>
              <th style="padding: 16px; text-align: left; border-bottom: 1px solid rgba(var(--line-rgb),0.14); width: 140px"></th>
              <th style="padding: 16px; text-align: left; border-bottom: 1px solid rgba(var(--line-rgb),0.14)">
                <div style="display: flex; align-items: center; gap: 8px">
                  <span :style="{ background: accent }" style="width: 20px; height: 20px; border-radius: 50%; color: var(--acc-ink); font-size: 11px; font-weight: 700; display: flex; align-items: center; justify-content: center; flex: none">A</span>
                  <div>
                    <div style="font-size: 13.5px; font-weight: 700; color: var(--text)">{{ configA.name }}</div>
                    <div style="font-size: 10.5px; color: var(--muted)">{{ configA.sourceLabel }}</div>
                  </div>
                </div>
              </th>
              <th style="padding: 16px; text-align: left; border-bottom: 1px solid rgba(var(--line-rgb),0.14)">
                <div style="display: flex; align-items: center; gap: 8px">
                  <span :style="{ background: COL_B }" style="width: 20px; height: 20px; border-radius: 50%; color: var(--acc-ink); font-size: 11px; font-weight: 700; display: flex; align-items: center; justify-content: center; flex: none">B</span>
                  <div>
                    <div style="font-size: 13.5px; font-weight: 700; color: var(--text)">{{ configB.name }}</div>
                    <div style="font-size: 10.5px; color: var(--muted)">{{ configB.sourceLabel }}</div>
                  </div>
                </div>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in compareRows" :key="row.key" style="border-top: 1px solid rgba(var(--line-rgb),0.08)">
              <td style="padding: 12px 16px; color: var(--muted); font-weight: 600; font-size: 12.5px">
                <i :class="'bi ' + row.icon" style="margin-right: 6px; color: var(--acc,#c6ff4a)"></i>{{ row.label }}
              </td>
              <td style="padding: 12px 16px; color: var(--text)">
                <template v-if="row.a">{{ row.a.name }}<span v-if="row.a.price != null" :style="{ color: row.b && row.b.price != null && row.a.price < row.b.price ? 'var(--green,#22d39a)' : 'var(--muted)', fontWeight: row.b && row.b.price != null && row.a.price < row.b.price ? 700 : 400 }"> — {{ fmt(row.a.price) }}</span></template>
                <span v-else style="color: var(--muted)">—</span>
              </td>
              <td style="padding: 12px 16px; color: var(--text)">
                <template v-if="row.b">{{ row.b.name }}<span v-if="row.b.price != null" :style="{ color: row.a && row.a.price != null && row.b.price < row.a.price ? 'var(--green,#22d39a)' : 'var(--muted)', fontWeight: row.a && row.a.price != null && row.b.price < row.a.price ? 700 : 400 }"> — {{ fmt(row.b.price) }}</span></template>
                <span v-else style="color: var(--muted)">—</span>
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr style="border-top: 1px solid rgba(var(--line-rgb),0.14); background: var(--card2)">
              <td style="padding: 14px 16px; font-weight: 700; color: var(--text)">Tổng giá</td>
              <td style="padding: 14px 16px; font-weight: 700; font-size: 15px; display: flex; align-items: center; gap: 8px" :style="{ color: accent }">
                {{ fmt(configA.totalPrice) }}
                <span v-if="configA.totalPrice < configB.totalPrice" style="font-size: 10px; font-weight: 700; color: var(--acc-ink); background: var(--green,#22d39a); padding: 2px 7px; border-radius: 20px">RẺ HƠN</span>
              </td>
              <td style="padding: 14px 16px; font-weight: 700; font-size: 15px; display: flex; align-items: center; gap: 8px" :style="{ color: COL_B }">
                {{ fmt(configB.totalPrice) }}
                <span v-if="configB.totalPrice < configA.totalPrice" style="font-size: 10px; font-weight: 700; color: var(--acc-ink); background: var(--green,#22d39a); padding: 2px 7px; border-radius: 20px">RẺ HƠN</span>
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  </main>
</template>
