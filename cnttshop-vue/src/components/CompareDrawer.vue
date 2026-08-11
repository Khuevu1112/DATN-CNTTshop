<script setup>
/**
 * Sidebar so sánh cấu hình — trượt từ phải, tối đa 5 cột (xem MAX_COMPARE).
 *
 * Khác trang /so-sanh cũ ở chỗ: mở đè lên trang đang xem nên khách không mất ngữ cảnh, và
 * số cột TĂNG DẦN theo số cấu hình được thêm thay vì cố định 2 cột A/B.
 *
 * Mỗi ô thông số được chấm điểm (xem data/compareRank.js) để chỉ ra cấu hình nào mạnh hơn:
 * ▲ xanh = mạnh nhất hàng, ▼ đỏ = yếu nhất, — cam = tương đương.
 */
import { ref, computed, watch } from 'vue';
import { state, actions, accent, MAX_COMPARE } from '../store.js';
import { fetchProductBySlug, fetchPcBuildDetail, fetchProducts } from '../api.js';
import { chamDiem, soSanhO, KY_HIEU, goiY, phanLoaiHuong } from '../data/compareRank.js';

const chiTiet = ref({}); // key -> { items: [{key,label,name}], totalPrice }
const dangTai = ref(false);
const goiYThem = ref([]);
const tuKhoaThem = ref('');

const CANONICAL = [
  { key: 'CPU', label: 'CPU' },
  { key: 'MAINBOARD', label: 'Mainboard' },
  { key: 'RAM', label: 'RAM' },
  { key: 'GPU', label: 'Card đồ hoạ' },
  { key: 'SSD', label: 'Ổ cứng' },
  { key: 'HDD', label: 'Ổ HDD' },
  { key: 'PSU', label: 'Nguồn' },
  { key: 'COOLER', label: 'Tản nhiệt' },
  { key: 'CASE', label: 'Vỏ case' },
  { key: 'MONITOR', label: 'Màn hình' },
  { key: 'MOUSE', label: 'Chuột' },
  { key: 'KEYBOARD', label: 'Bàn phím' },
];
const ALIAS = {
  CPU: 'CPU',
  MAINBOARD: 'MAINBOARD', Mainboard: 'MAINBOARD',
  RAM: 'RAM',
  GPU: 'GPU', 'Card đồ họa': 'GPU', 'Card đồ hoạ': 'GPU',
  SSD: 'SSD', 'Ổ cứng': 'SSD',
  HDD: 'HDD',
  PSU: 'PSU', Nguồn: 'PSU',
  CASE: 'CASE', Case: 'CASE', 'Vỏ case': 'CASE',
  CPU_COOLER: 'COOLER', Cooler: 'COOLER', 'Tản nhiệt': 'COOLER',
  MONITOR: 'MONITOR', Monitor: 'MONITOR',
  Mouse: 'MOUSE', Keyboard: 'KEYBOARD',
};

const fmt = (n) => (n == null ? '—' : Number(n).toLocaleString('vi-VN') + '₫');

async function taiChiTiet(item) {
  if (chiTiet.value[item.key]) return;
  try {
    if (item.kind === 'build') {
      const d = await fetchPcBuildDetail(item.id);
      chiTiet.value[item.key] = {
        totalPrice: d.totalPrice,
        items: (d.items || []).map((it) => ({
          key: ALIAS[it.componentType] || String(it.componentType || '').toUpperCase(),
          label: it.componentType,
          name: it.productName + (it.quantity > 1 ? ' x' + it.quantity : ''),
        })),
      };
    } else {
      const d = await fetchProductBySlug(item.slug);
      chiTiet.value[item.key] = {
        totalPrice: item.price,
        items: (d.specs || []).map((s) => ({
          key: ALIAS[s.key] || String(s.key || '').toUpperCase(),
          label: s.key,
          name: s.value,
        })),
      };
    }
  } catch (e) {
    chiTiet.value[item.key] = { totalPrice: item.price, items: [] };
  }
}

async function taiTatCa() {
  dangTai.value = true;
  try {
    await Promise.all(state.compareItems.map(taiChiTiet));
  } finally {
    dangTai.value = false;
  }
}
watch(() => state.compareItems.map((i) => i.key).join('|'), () => {
  if (state.compareOpen) taiTatCa();
});
watch(() => state.compareOpen, (mo) => {
  if (mo) taiTatCa();
});

/** Các hàng thông số: gộp khoá chuẩn (CPU/GPU/…) trước, thông số tự do của sản phẩm sau. */
const hangs = computed(() => {
  const chuan = [];
  const tuDo = new Map();
  state.compareItems.forEach((it) => {
    (chiTiet.value[it.key]?.items || []).forEach((sp) => {
      const c = CANONICAL.find((x) => x.key === sp.key);
      if (c) {
        if (!chuan.includes(c.key)) chuan.push(c.key);
      } else if (!tuDo.has(sp.label)) {
        tuDo.set(sp.label, sp.label);
      }
    });
  });
  const ds = CANONICAL.filter((c) => chuan.includes(c.key)).map((c) => ({ key: c.key, label: c.label, chuan: true }));
  tuDo.forEach((label, k) => ds.push({ key: k, label, chuan: false }));
  return ds;
});

function giaTriO(itemKey, hang) {
  const ds = chiTiet.value[itemKey]?.items || [];
  const found = hang.chuan
    ? ds.find((s) => s.key === hang.key)
    : ds.find((s) => s.label === hang.label);
  return found?.name || null;
}

/** Điểm + xếp hạng từng ô trong 1 hàng, tính 1 lần rồi tra cứu để không chấm lại mỗi lần render. */
const bangXep = computed(() => {
  const kq = {};
  hangs.value.forEach((hang) => {
    const diems = state.compareItems.map((it) => {
      const gt = giaTriO(it.key, hang);
      return { key: it.key, diem: gt ? chamDiem(hang.chuan ? hang.key : hang.label, gt) : null };
    });
    const coDiem = diems.filter((d) => d.diem != null).map((d) => d.diem);
    const max = coDiem.length ? Math.max(...coDiem) : null;
    const min = coDiem.length ? Math.min(...coDiem) : null;
    // Chỉ 1 cấu hình có dữ liệu thì không có gì để so — đừng gắn mũi tên gây hiểu nhầm.
    const duLieuDu = coDiem.length >= 2;
    kq[hang.key] = {};
    diems.forEach((d) => {
      kq[hang.key][d.key] = duLieuDu ? soSanhO(d.diem, max, min) : null;
    });
  });
  return kq;
});

/** Tổng điểm mỗi cấu hình — dùng để gắn nhãn "Hiệu năng cao nhất" / "Đáng tiền nhất". */
const nhanHuong = computed(() => {
  const ds = state.compareItems.map((it) => {
    const items = chiTiet.value[it.key]?.items || [];
    const tongDiem = items.reduce((s, sp) => {
      const d = chamDiem(sp.key, sp.name);
      return s + (d && d > 0 ? d : 0);
    }, 0);
    return { key: it.key, tongDiem, totalPrice: chiTiet.value[it.key]?.totalPrice || it.price || 0 };
  });
  return phanLoaiHuong(ds);
});

/** Đề xuất lấy theo cấu hình mạnh nhất đang so sánh. */
const deXuat = computed(() => {
  if (!state.compareItems.length) return [];
  const manhKey = Object.keys(nhanHuong.value).find((k) => nhanHuong.value[k].text === 'Hiệu năng cao nhất')
    || state.compareItems[0].key;
  const items = chiTiet.value[manhKey]?.items || [];
  if (!items.length) return [];
  // Cấu hình có đủ CPU + GPU + RAM coi như thiết bị hoàn chỉnh (PC/laptop); ít hơn thì đang
  // so sánh linh kiện rời nên đổi sang gợi ý tương thích.
  const coDu = ['CPU', 'GPU', 'RAM'].every((k) => items.some((i) => i.key === k));
  return goiY(items, coDu);
});

const MAU_DE_XUAT = {
  canh_bao: '#ef4444',
  tuong_thich: '#38bdf8',
  nang_cap: '#f59e0b',
  thiet_bi: '#22c55e',
};

async function timThem() {
  try {
    const ds = await fetchProducts({ categorySlug: 'pc-may-tinh-ban' });
    const q = tuKhoaThem.value.trim().toLowerCase();
    goiYThem.value = ds
      .filter((p) => !state.compareItems.some((i) => i.key === 'product-' + p.id))
      .filter((p) => !q || p.name.toLowerCase().includes(q))
      .slice(0, 8);
  } catch (e) {
    goiYThem.value = [];
  }
}
watch(tuKhoaThem, timThem);

function themCauHinh(p) {
  actions.addCompare({
    key: 'product-' + p.id, kind: 'product', id: p.id, slug: p.slug,
    name: p.name, price: p.price, image: p.imageUrl || p.thumbnail,
  });
  timThem();
}
</script>

<template>
  <div v-if="state.compareOpen" class="cmp-mask" @click.self="actions.closeCompare()">
    <aside class="cmp-drawer">
      <header class="cmp-head">
        <div>
          <div class="cmp-title">So sánh cấu hình</div>
          <div class="cmp-sub">{{ state.compareItems.length }}/{{ MAX_COMPARE }} cấu hình</div>
        </div>
        <div style="display: flex; gap: 8px">
          <button v-if="state.compareItems.length" class="cmp-btn" @click="actions.clearCompare()">Xoá hết</button>
          <button class="cmp-btn" @click="actions.closeCompare()">✕</button>
        </div>
      </header>

      <div class="cmp-body">
        <!-- Thêm cấu hình -->
        <section class="cmp-add">
          <input
            v-model="tuKhoaThem"
            class="cmp-search"
            type="search"
            placeholder="Tìm cấu hình để thêm vào so sánh…"
            @focus="timThem"
          />
          <div v-if="goiYThem.length" class="cmp-sugg">
            <button
              v-for="p in goiYThem"
              :key="p.id"
              class="cmp-sugg-item"
              :disabled="state.compareItems.length >= MAX_COMPARE"
              @click="themCauHinh(p)"
            >
              <span style="flex: 1; text-align: left">{{ p.name }}</span>
              <span style="color: var(--muted); white-space: nowrap">{{ fmt(p.price) }}</span>
            </button>
          </div>
          <div v-if="state.compareItems.length >= MAX_COMPARE" class="cmp-note">
            Đã đạt tối đa {{ MAX_COMPARE }} cấu hình — bỏ bớt một cấu hình để thêm cái khác.
          </div>
        </section>

        <div v-if="!state.compareItems.length" class="cmp-empty">
          Chưa có cấu hình nào. Bấm “So sánh” ở trang sản phẩm hoặc tìm ở ô trên để thêm.
        </div>

        <template v-else>
          <div v-if="dangTai" class="cmp-empty">Đang tải thông số…</div>

          <!-- Bảng: số cột tăng dần theo số cấu hình -->
          <div v-else class="cmp-scroll">
            <table class="cmp-table">
              <thead>
                <tr>
                  <th class="cmp-rowhead">Thông số</th>
                  <th v-for="it in state.compareItems" :key="it.key" class="cmp-colhead">
                    <button class="cmp-remove" title="Bỏ khỏi so sánh" @click="actions.removeCompare(it.key)">✕</button>
                    <div class="cmp-name">{{ it.name }}</div>
                    <!-- Biến thể là thứ phân biệt 2 cột cùng một sản phẩm (16GB vs 32GB…). -->
                    <div v-if="it.bienThe" class="cmp-variant">{{ it.bienThe }}</div>
                    <div class="cmp-price" :style="{ color: accent }">{{ fmt(chiTiet[it.key]?.totalPrice ?? it.price) }}</div>
                    <span
                      v-if="nhanHuong[it.key]"
                      class="cmp-tag"
                      :style="{ color: nhanHuong[it.key].mau, borderColor: nhanHuong[it.key].mau }"
                    >{{ nhanHuong[it.key].text }}</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="hang in hangs" :key="hang.key">
                  <td class="cmp-rowhead">{{ hang.label }}</td>
                  <td v-for="it in state.compareItems" :key="it.key" class="cmp-cell">
                    <template v-if="giaTriO(it.key, hang)">
                      <span
                        v-if="bangXep[hang.key]?.[it.key]"
                        class="cmp-arrow"
                        :style="{ color: KY_HIEU[bangXep[hang.key][it.key]].mau }"
                        :title="KY_HIEU[bangXep[hang.key][it.key]].nhan"
                      >{{ KY_HIEU[bangXep[hang.key][it.key]].mui }}</span>
                      {{ giaTriO(it.key, hang) }}
                    </template>
                    <span v-else class="cmp-none">—</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Chú thích ký hiệu -->
          <div class="cmp-legend">
            <span :style="{ color: KY_HIEU.hon.mau }">▲ Mạnh hơn</span>
            <span :style="{ color: KY_HIEU.bang.mau }">— Tương đương</span>
            <span :style="{ color: KY_HIEU.kem.mau }">▼ Yếu hơn</span>
          </div>

          <!-- Đề xuất tương thích / thiết bị phù hợp -->
          <section v-if="deXuat.length" class="cmp-advice">
            <div class="cmp-advice-title">Gợi ý cho bạn</div>
            <div v-for="(g, i) in deXuat" :key="i" class="cmp-advice-row" :style="{ borderLeftColor: MAU_DE_XUAT[g.loai] }">
              {{ g.text }}
            </div>
          </section>
        </template>
      </div>
    </aside>
  </div>
</template>

<style scoped>
.cmp-mask {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 300;
  display: flex;
  justify-content: flex-end;
}
.cmp-drawer {
  width: min(980px, 96vw);
  height: 100%;
  background: var(--bg, #0b1622);
  border-left: 1px solid rgba(var(--line-rgb), 0.18);
  display: flex;
  flex-direction: column;
  font-family: 'Plus Jakarta Sans', sans-serif;
  animation: cmpIn 0.22s ease;
}
@keyframes cmpIn { from { transform: translateX(30px); opacity: 0.4 } to { transform: none; opacity: 1 } }

.cmp-head {
  flex: none;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 16px 20px;
  border-bottom: 1px solid rgba(var(--line-rgb), 0.14);
}
.cmp-title { font-size: 16px; font-weight: 800; color: var(--text); }
.cmp-sub { font-size: 12px; color: var(--muted); margin-top: 2px; }
.cmp-btn {
  height: 34px;
  padding: 0 14px;
  border-radius: 9px;
  border: 1px solid rgba(var(--line-rgb), 0.2);
  background: transparent;
  color: var(--muted2);
  font-size: 13px;
  font-family: inherit;
  cursor: pointer;
}
.cmp-btn:hover { border-color: var(--acc, #c6ff4a); color: var(--text); }

.cmp-body { flex: 1; overflow-y: auto; padding: 16px 20px 40px; }

.cmp-add { margin-bottom: 16px; }
.cmp-search {
  width: 100%;
  height: 38px;
  padding: 0 12px;
  border-radius: 10px;
  border: 1px solid rgba(var(--line-rgb), 0.18);
  background: var(--card2);
  color: var(--text);
  font-size: 13px;
  font-family: inherit;
}
.cmp-sugg { margin-top: 8px; display: flex; flex-direction: column; gap: 6px; }
.cmp-sugg-item {
  display: flex;
  gap: 10px;
  align-items: center;
  padding: 9px 12px;
  border-radius: 9px;
  border: 1px solid rgba(var(--line-rgb), 0.14);
  background: var(--card);
  color: var(--text);
  font-size: 12.8px;
  font-family: inherit;
  cursor: pointer;
}
.cmp-sugg-item:hover:not(:disabled) { border-color: var(--acc, #c6ff4a); }
.cmp-sugg-item:disabled { opacity: 0.45; cursor: default; }
.cmp-note { margin-top: 8px; font-size: 12px; color: var(--muted); }
.cmp-empty { padding: 40px 12px; text-align: center; color: var(--muted); font-size: 13.5px; }

.cmp-scroll { overflow-x: auto; }
.cmp-table { width: 100%; border-collapse: collapse; min-width: 460px; }
.cmp-table th, .cmp-table td { border-bottom: 1px solid rgba(var(--line-rgb), 0.12); }
.cmp-rowhead {
  width: 132px;
  min-width: 118px;
  padding: 11px 10px;
  text-align: left;
  font-size: 12.2px;
  font-weight: 700;
  color: var(--muted);
  vertical-align: top;
}
.cmp-colhead {
  position: relative;
  min-width: 168px;
  padding: 12px 10px 14px;
  text-align: left;
  vertical-align: top;
}
.cmp-name { font-size: 13.2px; font-weight: 700; color: var(--text); line-height: 1.35; padding-right: 20px; }
.cmp-variant { font-size: 11.5px; color: var(--muted); margin-top: 3px; }
.cmp-price { font-size: 13px; font-weight: 700; margin-top: 4px; }
.cmp-tag {
  display: inline-block;
  margin-top: 6px;
  font-size: 10.5px;
  font-weight: 700;
  padding: 2px 8px;
  border-radius: 20px;
  border: 1px solid;
}
.cmp-remove {
  position: absolute;
  top: 8px;
  right: 6px;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  border: none;
  background: var(--card2);
  color: var(--muted);
  font-size: 11px;
  cursor: pointer;
}
.cmp-remove:hover { color: var(--sale, #ff5d7a); }
.cmp-cell { padding: 11px 10px; font-size: 12.6px; color: var(--muted2); line-height: 1.5; vertical-align: top; }
.cmp-arrow { font-size: 12px; font-weight: 700; margin-right: 5px; }
.cmp-none { color: var(--muted); }

.cmp-legend { display: flex; gap: 18px; flex-wrap: wrap; margin-top: 14px; font-size: 11.8px; font-weight: 700; }

.cmp-advice { margin-top: 22px; }
.cmp-advice-title { font-size: 13.5px; font-weight: 800; color: var(--text); margin-bottom: 10px; }
.cmp-advice-row {
  border-left: 3px solid var(--muted);
  background: var(--card);
  border-radius: 0 10px 10px 0;
  padding: 11px 14px;
  margin-bottom: 8px;
  font-size: 12.8px;
  color: var(--muted2);
  line-height: 1.55;
}
</style>
