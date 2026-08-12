<script setup>
/**
 * Sidebar so sánh cấu hình — trượt từ phải, tối đa 5 cột (xem MAX_COMPARE).
 *
 * Giao diện theo bản redesign "Compare Drawer Redesign": nền xám trung tính (KHÔNG phải tông
 * xanh lam như bản đầu), hai chế độ xem Bảng/Thẻ, cột "Thông số" ghim trái khi cuộn ngang.
 * Bảng màu lấy nguyên từ redesign, chọn theo state.mode của app thay vì thêm nút Tối/Sáng
 * riêng trong drawer — app đã có công tắc theme toàn cục, hai nguồn điều khiển sẽ đá nhau.
 *
 * Mở đè lên trang đang xem nên khách không mất ngữ cảnh, và số cột TĂNG DẦN theo số cấu hình
 * được thêm thay vì cố định 2 cột A/B như trang /so-sanh cũ.
 *
 * Mỗi ô thông số được chấm điểm (xem data/compareRank.js) để chỉ ra cấu hình nào mạnh hơn:
 * ▲ xanh = mạnh nhất hàng, ▼ đỏ = yếu nhất, — cam = tương đương.
 */
import { ref, computed, watch } from 'vue';
import { state, actions, accent, MAX_COMPARE } from '../store.js';
import { fetchProductBySlug, fetchPcBuildDetail, fetchProducts, resolveImageUrl } from '../api.js';
import {
  chamDiem, soSanhO, KY_HIEU, goiY, phanLoaiHuong, CANONICAL, ALIAS_SPEC as ALIAS,
} from '../data/compareRank.js';

const chiTiet = ref({}); // key -> { items: [{key,label,name}], totalPrice }
const dangTai = ref(false);
const goiYThem = ref([]);
const tuKhoaThem = ref('');
const cheDo = ref('bang'); // bang | the

const fmt = (n) => (n == null ? '—' : Number(n).toLocaleString('vi-VN') + '₫');

// Bảng màu lấy nguyên từ redesign — tông xám trung tính, không pha xanh lam.
const DARK = {
  '--cmp-aside': 'radial-gradient(1200px 600px at 80% -10%, rgb(28, 30, 34) 0%, rgb(16, 17, 20) 55%)',
  '--cmp-card': 'rgb(28, 30, 34)',
  '--cmp-card2': 'rgb(36, 38, 42)',
  '--cmp-card-alt': 'rgb(22, 24, 28)',
  '--cmp-border': 'rgba(255,255,255,0.1)',
  '--cmp-divider': 'rgba(255,255,255,0.06)',
  '--cmp-text': '#eef3f8',
  '--cmp-muted': '#8b95a0',
  '--cmp-muted2': '#c3c9d1',
  '--cmp-stripe': 'repeating-linear-gradient(135deg, rgb(36,38,42), rgb(36,38,42) 6px, rgb(44,46,50) 6px, rgb(44,46,50) 12px)',
  '--cmp-overlay': 'rgba(0,0,0,0.55)',
};
const LIGHT = {
  '--cmp-aside': 'radial-gradient(1200px 600px at 80% -10%, #ffffff 0%, #f2f3f5 55%)',
  '--cmp-card': '#ffffff',
  '--cmp-card2': '#f2f3f5',
  '--cmp-card-alt': '#f7f8f9',
  '--cmp-border': 'rgba(0,0,0,0.1)',
  '--cmp-divider': 'rgba(0,0,0,0.07)',
  '--cmp-text': '#1a1d21',
  '--cmp-muted': '#767b81',
  '--cmp-muted2': '#3d4247',
  '--cmp-stripe': 'repeating-linear-gradient(135deg, #eef0f2, #eef0f2 6px, #e3e5e8 6px, #e3e5e8 12px)',
  '--cmp-overlay': 'rgba(0,0,0,0.3)',
};
const bienMau = computed(() => (state.mode === 'light' ? LIGHT : DARK));

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

// Icon tròn theo loại gợi ý, đúng như redesign.
const KIEU_DE_XUAT = {
  canh_bao: { icon: '!', color: '#ef4444', bg: 'rgba(239,68,68,0.15)' },
  nang_cap: { icon: '↑', color: '#f59e0b', bg: 'rgba(245,158,11,0.15)' },
  tuong_thich: { icon: '✓', color: '#38bdf8', bg: 'rgba(56,189,248,0.15)' },
  thiet_bi: { icon: '★', color: '#22c55e', bg: 'rgba(34,197,94,0.15)' },
};

async function timThem() {
  try {
    const ds = await fetchProducts({ categorySlug: 'pc-may-tinh-ban' });
    const q = tuKhoaThem.value.trim().toLowerCase();
    goiYThem.value = ds
      .filter((p) => !state.compareItems.some((i) => i.key.startsWith('product-' + p.id)))
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

/** Thông số của 1 cấu hình cho chế độ xem Thẻ. */
function thongSoThe(itemKey) {
  return hangs.value
    .map((h) => ({
      label: h.label,
      value: giaTriO(itemKey, h),
      xep: bangXep.value[h.key]?.[itemKey] || null,
    }))
    .filter((x) => x.value);
}
</script>

<template>
  <div v-if="state.compareOpen" class="cmp-mask" :style="bienMau" @click.self="actions.closeCompare()">
    <aside class="cmp-drawer">
      <header class="cmp-head">
        <div>
          <div class="cmp-title">So sánh cấu hình</div>
          <div class="cmp-sub">{{ state.compareItems.length }}/{{ MAX_COMPARE }} cấu hình</div>
        </div>
        <div class="cmp-head-tools">
          <div class="cmp-seg">
            <button :class="{ on: cheDo === 'bang' }" :style="cheDo === 'bang' ? { background: accent, color: '#04121f' } : {}" @click="cheDo = 'bang'">Bảng</button>
            <button :class="{ on: cheDo === 'the' }" :style="cheDo === 'the' ? { background: accent, color: '#04121f' } : {}" @click="cheDo = 'the'">Thẻ</button>
          </div>
          <button v-if="state.compareItems.length" class="cmp-btn" @click="actions.clearCompare()">Xoá hết</button>
          <button class="cmp-btn cmp-btn-x" @click="actions.closeCompare()">✕</button>
        </div>
      </header>

      <div class="cmp-body">
        <!-- Tìm & thêm cấu hình. Danh sách gợi ý chỉ bung ra khi khách rê chuột vào vùng này
             hoặc đang gõ; bình thường ẩn đi cho gọn (dùng :hover/:focus-within thay vì state
             JS để rê từ ô tìm xuống danh sách không bị mất). -->
        <section class="cmp-add" :class="{ 'co-tu-khoa': tuKhoaThem.trim().length > 0 }">
          <div class="cmp-search-wrap">
            <span class="cmp-search-ic"></span>
            <input
              v-model="tuKhoaThem"
              class="cmp-search"
              type="search"
              placeholder="Tìm cấu hình để thêm vào so sánh…"
              @focus="timThem"
              @mouseenter="timThem"
            />
          </div>
          <div v-if="goiYThem.length" class="cmp-sugg">
            <button
              v-for="p in goiYThem"
              :key="p.id"
              class="cmp-sugg-item"
              :disabled="state.compareItems.length >= MAX_COMPARE"
              @click="themCauHinh(p)"
            >
              <span style="flex: 1">{{ p.name }}</span>
              <span class="cmp-sugg-price">{{ fmt(p.price) }}</span>
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

          <!-- ═══ Chế độ BẢNG: số cột tăng dần theo số cấu hình ═══ -->
          <div v-else-if="cheDo === 'bang'" class="cmp-tablewrap">
            <table class="cmp-table">
              <thead>
                <tr>
                  <th class="cmp-rowhead cmp-sticky">Thông số</th>
                  <th v-for="it in state.compareItems" :key="it.key" class="cmp-colhead">
                    <button class="cmp-remove" title="Bỏ khỏi so sánh" @click="actions.removeCompare(it.key)">✕</button>
                    <div
                      class="cmp-thumb"
                      :style="it.image ? { backgroundImage: `url(${resolveImageUrl(it.image)})`, backgroundSize: 'cover', backgroundPosition: 'center' } : {}"
                    >
                      <span v-if="!it.image">ảnh sản phẩm</span>
                    </div>
                    <div class="cmp-name">{{ it.name }}</div>
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
                  <td class="cmp-rowhead cmp-sticky">{{ hang.label }}</td>
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

          <!-- ═══ Chế độ THẺ: mỗi cấu hình 1 thẻ, cuộn ngang ═══ -->
          <div v-else class="cmp-cards">
            <div v-for="it in state.compareItems" :key="it.key" class="cmp-card">
              <div class="cmp-card-head">
                <button class="cmp-remove" title="Bỏ khỏi so sánh" @click="actions.removeCompare(it.key)">✕</button>
                <div
                  class="cmp-thumb cmp-thumb-lg"
                  :style="it.image ? { backgroundImage: `url(${resolveImageUrl(it.image)})`, backgroundSize: 'cover', backgroundPosition: 'center' } : {}"
                >
                  <span v-if="!it.image">ảnh sản phẩm</span>
                </div>
                <div class="cmp-name">{{ it.name }}</div>
                <div v-if="it.bienThe" class="cmp-variant">{{ it.bienThe }}</div>
                <div class="cmp-price" :style="{ color: accent }">{{ fmt(chiTiet[it.key]?.totalPrice ?? it.price) }}</div>
                <span
                  v-if="nhanHuong[it.key]"
                  class="cmp-tag"
                  :style="{ color: nhanHuong[it.key].mau, borderColor: nhanHuong[it.key].mau }"
                >{{ nhanHuong[it.key].text }}</span>
              </div>
              <div class="cmp-card-specs">
                <div v-for="sp in thongSoThe(it.key)" :key="sp.label" class="cmp-spec">
                  <span class="cmp-spec-label">{{ sp.label }}</span>
                  <span class="cmp-spec-val">
                    <span v-if="sp.xep" class="cmp-arrow" :style="{ color: KY_HIEU[sp.xep].mau }">{{ KY_HIEU[sp.xep].mui }}</span>
                    {{ sp.value }}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- Chú thích ký hiệu -->
          <div v-if="!dangTai" class="cmp-legend">
            <span :style="{ color: KY_HIEU.hon.mau }">▲ Mạnh hơn</span>
            <span :style="{ color: KY_HIEU.bang.mau }">— Tương đương</span>
            <span :style="{ color: KY_HIEU.kem.mau }">▼ Yếu hơn</span>
          </div>

          <!-- Đề xuất tương thích / thiết bị phù hợp -->
          <section v-if="deXuat.length && !dangTai" class="cmp-advice">
            <div class="cmp-advice-title">Gợi ý cho bạn</div>
            <div v-for="(g, i) in deXuat" :key="i" class="cmp-advice-row">
              <span
                class="cmp-advice-ic"
                :style="{ background: (KIEU_DE_XUAT[g.loai] || KIEU_DE_XUAT.tuong_thich).bg, color: (KIEU_DE_XUAT[g.loai] || KIEU_DE_XUAT.tuong_thich).color }"
              >{{ (KIEU_DE_XUAT[g.loai] || KIEU_DE_XUAT.tuong_thich).icon }}</span>
              <span class="cmp-advice-text">{{ g.text }}</span>
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
  background: var(--cmp-overlay);
  z-index: 300;
  display: flex;
  justify-content: flex-end;
}
.cmp-drawer {
  width: min(1100px, 96%);
  height: 100%;
  background: var(--cmp-aside);
  border-left: 1px solid var(--cmp-border);
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
  padding: 20px 26px;
  border-bottom: 1px solid var(--cmp-border);
}
.cmp-title { font-size: 18px; font-weight: 800; color: var(--cmp-text); }
.cmp-sub { font-size: 12.5px; color: var(--cmp-muted); margin-top: 3px; }
.cmp-head-tools { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }

.cmp-seg {
  display: flex;
  background: var(--cmp-card2);
  border: 1px solid var(--cmp-border);
  border-radius: 10px;
  padding: 3px;
}
.cmp-seg button {
  height: 30px;
  padding: 0 14px;
  border: none;
  border-radius: 7px;
  background: transparent;
  color: var(--cmp-muted2);
  font-size: 12.5px;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
}

.cmp-btn {
  height: 36px;
  padding: 0 14px;
  border-radius: 9px;
  border: 1px solid var(--cmp-border);
  background: transparent;
  color: var(--cmp-muted2);
  font-size: 13px;
  font-family: inherit;
  cursor: pointer;
}
.cmp-btn:hover { border-color: var(--acc, #c6ff4a); color: var(--cmp-text); }
.cmp-btn-x { width: 36px; padding: 0; font-size: 14px; }

.cmp-body { flex: 1; overflow-y: auto; padding: 20px 26px 44px; }

/* --- Tìm & thêm cấu hình --- */
.cmp-add { margin-bottom: 20px; position: relative; }
.cmp-search-wrap { position: relative; }
/* Kính lúp vẽ bằng CSS (vòng tròn + cán) — khỏi kéo thêm bộ icon chỉ vì một hình. */
.cmp-search-ic {
  position: absolute;
  left: 14px;
  top: 50%;
  transform: translateY(-50%);
  width: 13px;
  height: 13px;
  border: 1.6px solid var(--cmp-muted);
  border-radius: 50%;
  pointer-events: none;
}
.cmp-search-ic::after {
  content: '';
  position: absolute;
  left: 9px;
  top: 11px;
  width: 7px;
  height: 1.6px;
  background: var(--cmp-muted);
  transform: rotate(45deg);
  transform-origin: left center;
}
.cmp-search {
  width: 100%;
  height: 42px;
  padding: 0 14px 0 38px;
  border-radius: 10px;
  border: 1px solid var(--cmp-border);
  background: var(--cmp-card2);
  color: var(--cmp-text);
  font-size: 13.5px;
  font-family: inherit;
  outline: none;
}

/* Ẩn mặc định; bung ra khi rê chuột vào vùng tìm kiếm, khi con trỏ đang ở trong ô,
   hoặc khi đã gõ từ khoá. */
.cmp-sugg {
  display: none;
  margin-top: 8px;
  flex-direction: column;
  gap: 6px;
}
.cmp-add:hover .cmp-sugg,
.cmp-add:focus-within .cmp-sugg,
.cmp-add.co-tu-khoa .cmp-sugg { display: flex; }

.cmp-sugg-item {
  display: flex;
  gap: 10px;
  align-items: center;
  width: 100%;
  padding: 10px 12px;
  border-radius: 9px;
  border: 1px solid var(--cmp-border);
  background: var(--cmp-card);
  color: var(--cmp-text);
  font-size: 12.8px;
  font-family: inherit;
  text-align: left;
  cursor: pointer;
}
.cmp-sugg-item:hover:not(:disabled) { border-color: var(--acc, #c6ff4a); }
.cmp-sugg-item:disabled { opacity: 0.45; cursor: default; }
.cmp-sugg-price { color: var(--cmp-muted); white-space: nowrap; }
.cmp-note { margin-top: 8px; font-size: 12px; color: var(--cmp-muted); }
.cmp-empty { padding: 60px 12px; text-align: center; color: var(--cmp-muted); font-size: 13.5px; }

/* --- Chế độ Bảng --- */
.cmp-tablewrap { overflow-x: auto; border-radius: 12px; border: 1px solid var(--cmp-border); }
.cmp-table { width: 100%; border-collapse: collapse; min-width: 620px; }
.cmp-rowhead {
  width: 140px;
  min-width: 130px;
  padding: 14px 12px;
  text-align: left;
  font-size: 12.2px;
  font-weight: 700;
  color: var(--cmp-muted);
  vertical-align: top;
  border-bottom: 1px solid var(--cmp-divider);
}
/* Cột thông số ghim trái để cuộn ngang vẫn biết đang xem chỉ tiêu nào. */
.cmp-sticky { position: sticky; left: 0; z-index: 2; background: var(--cmp-card); }
thead .cmp-sticky { background: var(--cmp-card2); border-bottom: 1px solid var(--cmp-border); }

.cmp-colhead {
  position: relative;
  min-width: 200px;
  padding: 14px 14px 16px;
  text-align: left;
  vertical-align: top;
  background: var(--cmp-card-alt);
  border-bottom: 1px solid var(--cmp-border);
}
.cmp-thumb {
  width: 100%;
  height: 64px;
  border-radius: 8px;
  background: var(--cmp-stripe);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 10px;
  font-family: ui-monospace, monospace;
  font-size: 10px;
  color: var(--cmp-muted);
  overflow: hidden;
}
.cmp-thumb-lg { height: 80px; margin-bottom: 12px; }
.cmp-name { font-size: 13.5px; font-weight: 700; color: var(--cmp-text); line-height: 1.35; padding-right: 18px; }
.cmp-variant { font-size: 11.5px; color: var(--cmp-muted); margin-top: 3px; }
.cmp-price { font-size: 13px; font-weight: 700; margin-top: 6px; }
.cmp-tag {
  display: inline-block;
  margin-top: 7px;
  font-size: 10.5px;
  font-weight: 700;
  padding: 2px 9px;
  border-radius: 20px;
  border: 1px solid;
}
.cmp-remove {
  position: absolute;
  top: 10px;
  right: 8px;
  width: 22px;
  height: 22px;
  border-radius: 50%;
  border: none;
  background: var(--cmp-card2);
  color: var(--cmp-muted);
  font-size: 11px;
  cursor: pointer;
  z-index: 1;
}
.cmp-remove:hover { color: var(--sale, #ff5d7a); }
.cmp-cell {
  padding: 12px 14px;
  font-size: 12.8px;
  color: var(--cmp-muted2);
  line-height: 1.5;
  vertical-align: top;
  border-bottom: 1px solid var(--cmp-divider);
}
.cmp-arrow { font-size: 10px; font-weight: 800; margin-right: 6px; }
.cmp-none { color: var(--cmp-muted); }

/* --- Chế độ Thẻ --- */
.cmp-cards { display: flex; gap: 16px; overflow-x: auto; padding-bottom: 4px; }
.cmp-card {
  flex: none;
  width: 280px;
  border-radius: 12px;
  border: 1px solid var(--cmp-border);
  background: var(--cmp-card-alt);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.cmp-card-head { padding: 16px; position: relative; border-bottom: 1px solid var(--cmp-divider); }
.cmp-card-specs { padding: 6px 16px 14px; display: flex; flex-direction: column; }
.cmp-spec {
  display: flex;
  justify-content: space-between;
  gap: 10px;
  padding: 9px 0;
  border-bottom: 1px solid var(--cmp-divider);
  font-size: 12.4px;
}
.cmp-spec:last-child { border-bottom: none; }
.cmp-spec-label { color: var(--cmp-muted); flex: none; width: 88px; }
.cmp-spec-val {
  color: var(--cmp-muted2);
  text-align: right;
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 2px;
}

.cmp-legend { display: flex; gap: 20px; flex-wrap: wrap; margin-top: 18px; font-size: 11.8px; font-weight: 700; }

/* --- Gợi ý --- */
.cmp-advice { margin-top: 24px; }
.cmp-advice-title { font-size: 13.5px; font-weight: 800; color: var(--cmp-text); margin-bottom: 10px; }
.cmp-advice-row {
  display: flex;
  gap: 12px;
  align-items: flex-start;
  padding: 10px 4px;
  font-size: 12.8px;
  color: var(--cmp-muted2);
  line-height: 1.55;
}
.cmp-advice-ic {
  flex: none;
  width: 22px;
  height: 22px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  font-weight: 800;
}
.cmp-advice-text { padding-top: 2px; }
</style>
