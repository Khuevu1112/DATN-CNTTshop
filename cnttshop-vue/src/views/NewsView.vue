<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { actions, accent } from '../store.js';
import { fetchArticles, fetchArticleCategories, resolveImageUrl } from '../api.js';
import { ngayVN } from '../data/supportMeta.js';

const route = useRoute();
const cats = ref([]);
const articles = ref([]);
const dangTai = ref(true);
const catChon = ref(route.query.c || '');
const tuKhoa = ref('');
const sapXep = ref('moi_nhat'); // moi_nhat | a_z | xem_nhieu
const soHien = ref(8); // "Xem thêm" nạp dần thay vì phân trang số trang
const MOI_LAN = 8;

async function tai() {
  dangTai.value = true;
  soHien.value = MOI_LAN;
  try {
    articles.value = await fetchArticles(catChon.value || undefined);
  } catch (e) {
    articles.value = [];
  } finally {
    dangTai.value = false;
  }
}

function chonCat(ma) {
  catChon.value = ma;
  actions.goNews(ma || undefined); // đồng bộ URL để chia sẻ / F5 giữ đúng danh mục
}
watch(() => route.query.c, (v) => { catChon.value = v || ''; tai(); });
// Đổi từ khoá / cách sắp xếp thì trả danh sách về lượt hiển thị đầu, tránh đang ở "xem thêm"
// lần 3 mà kết quả mới chỉ có 2 bài.
watch([tuKhoa, sapXep], () => { soHien.value = MOI_LAN; });

function datLai() {
  tuKhoa.value = '';
  sapXep.value = 'moi_nhat';
  if (catChon.value) chonCat('');
}
const coLoc = computed(() => !!catChon.value || !!tuKhoa.value.trim() || sapXep.value !== 'moi_nhat');

// Bài nổi bật (chỉ khi xem "Tất cả", không lọc gì) — 1 bài lớn lên đầu.
const noiBat = computed(() => (!coLoc.value ? articles.value.find((a) => a.noiBat) : null));

const daLoc = computed(() => {
  const q = tuKhoa.value.trim().toLowerCase();
  let ds = articles.value.filter((a) => a !== noiBat.value);
  if (q) {
    ds = ds.filter((a) =>
      (a.tieuDe || '').toLowerCase().includes(q) || (a.tomTat || '').toLowerCase().includes(q),
    );
  }
  const sorted = [...ds];
  if (sapXep.value === 'a_z') {
    sorted.sort((x, y) => (x.tieuDe || '').localeCompare(y.tieuDe || '', 'vi'));
  } else if (sapXep.value === 'xem_nhieu') {
    sorted.sort((x, y) => (y.luotXem || 0) - (x.luotXem || 0));
  } else {
    sorted.sort((x, y) => new Date(y.publishedAt || 0) - new Date(x.publishedAt || 0));
  }
  return sorted;
});
const hienThi = computed(() => daLoc.value.slice(0, soHien.value));
const conNua = computed(() => daLoc.value.length > soHien.value);

const tenCat = computed(() => cats.value.find((c) => c.ma === catChon.value)?.ten || 'Tất cả');

onMounted(async () => {
  try {
    cats.value = await fetchArticleCategories();
  } catch (e) {
    cats.value = [];
  }
  tai();
});
</script>

<template>
  <main style="max-width: 1100px; margin: 0 auto; padding: 20px 24px 72px">
    <!-- Breadcrumb -->
    <nav class="nw-crumb">
      <button @click="actions.goHome()">Trang chủ</button>
      <span>›</span>
      <button @click="actions.goSupport()">Hỗ trợ</button>
      <span>›</span>
      <span class="cur">Tin tức &amp; thông báo</span>
    </nav>

    <div style="margin-bottom: 26px">
      <h1 class="sp-h1" style="margin-bottom: 10px">Tin tức &amp; <span :style="{ color: accent }">thông báo</span></h1>
      <p style="font-size: 14.5px; color: var(--muted2); max-width: 680px; line-height: 1.65; margin: 0">
        Review phần cứng, hướng dẫn build PC, thông báo cập nhật sản phẩm và các chương trình ưu đãi mới nhất.
      </p>
    </div>

    <!-- Bộ lọc: danh mục + tìm kiếm + sắp xếp -->
    <section class="nw-filter">
      <div class="nw-filter-row">
        <span class="nw-filter-label">Danh mục</span>
        <div class="nw-chips">
          <button class="sp-chip" :class="{ active: !catChon }" @click="chonCat('')">Tất cả</button>
          <button
            v-for="c in cats"
            :key="c.ma"
            class="sp-chip"
            :class="{ active: catChon === c.ma }"
            @click="chonCat(c.ma)"
          >
            {{ c.ten }}
          </button>
        </div>
      </div>

      <div class="nw-filter-row">
        <span class="nw-filter-label">Tìm kiếm</span>
        <div class="nw-tools">
          <input v-model="tuKhoa" class="nw-search" type="search" placeholder="Nhập từ khoá tiêu đề bài viết…" />
          <select v-model="sapXep" class="nw-sort">
            <option value="moi_nhat">Mới nhất</option>
            <option value="a_z">Tiêu đề A → Z</option>
            <option value="xem_nhieu">Xem nhiều nhất</option>
          </select>
          <button class="nw-reset" :disabled="!coLoc" @click="datLai">Đặt lại</button>
        </div>
      </div>
    </section>

    <div v-if="dangTai" class="sp-card sp-empty">Đang tải…</div>
    <div v-else-if="!articles.length" class="sp-card sp-empty">Chưa có bài viết nào trong mục này.</div>

    <template v-else>
      <!-- Bài nổi bật -->
      <button v-if="noiBat" class="nw-feature" @click="actions.goArticle(noiBat.slug)">
        <div class="nw-feature-img" :style="{ backgroundImage: `url(${resolveImageUrl(noiBat.thumbnail)})` }"></div>
        <div class="nw-feature-body">
          <span class="nw-badge nw-badge-hot">Nổi bật</span>
          <div class="nw-feature-title">{{ noiBat.tieuDe }}</div>
          <div class="nw-feature-excerpt">{{ noiBat.tomTat }}</div>
          <div class="nw-meta">{{ noiBat.tenDanhMuc }} · {{ ngayVN(noiBat.publishedAt) }} · {{ noiBat.luotXem }} lượt xem</div>
        </div>
      </button>

      <div class="nw-count">
        {{ daLoc.length }} bài viết<span v-if="catChon"> trong mục “{{ tenCat }}”</span>
      </div>

      <!-- Danh sách dọc: mỗi bài 1 hàng, quét mắt nhanh theo tiêu đề -->
      <div v-if="!hienThi.length" class="sp-card sp-empty">Không tìm thấy bài viết khớp từ khoá.</div>
      <ul v-else class="nw-list">
        <li v-for="a in hienThi" :key="a.id">
          <button class="nw-row" @click="actions.goArticle(a.slug)">
            <div
              v-if="a.thumbnail"
              class="nw-row-thumb"
              :style="{ backgroundImage: `url(${resolveImageUrl(a.thumbnail)})` }"
            ></div>
            <div class="nw-row-body">
              <span class="nw-badge">{{ a.tenDanhMuc }}</span>
              <div class="nw-row-title">{{ a.tieuDe }}</div>
              <div class="nw-row-excerpt">{{ a.tomTat }}</div>
              <div class="nw-meta">{{ ngayVN(a.publishedAt) }} · {{ a.luotXem }} lượt xem</div>
            </div>
            <span class="nw-row-cta" :style="{ color: accent }">Xem chi tiết →</span>
          </button>
        </li>
      </ul>

      <div v-if="conNua" style="display: flex; justify-content: center; margin-top: 26px">
        <button class="nw-more" @click="soHien += MOI_LAN">Xem thêm</button>
      </div>
    </template>
  </main>
</template>

<style scoped>
.nw-crumb {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12.5px;
  color: var(--muted);
  margin-bottom: 18px;
  flex-wrap: wrap;
}
.nw-crumb button {
  background: none;
  border: none;
  padding: 0;
  font: inherit;
  color: var(--muted);
  cursor: pointer;
}
.nw-crumb button:hover { color: var(--acc, #c6ff4a); }
.nw-crumb .cur { color: var(--text); font-weight: 600; }

.nw-filter {
  background: var(--card);
  border: 1px solid rgba(var(--line-rgb), 0.14);
  border-radius: 14px;
  padding: 16px 18px;
  margin-bottom: 24px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}
.nw-filter-row { display: flex; gap: 14px; align-items: flex-start; }
.nw-filter-label {
  flex: none;
  width: 82px;
  padding-top: 7px;
  font-size: 12px;
  font-weight: 700;
  color: var(--muted);
  letter-spacing: 0.4px;
}
.nw-chips { display: flex; gap: 8px; flex-wrap: wrap; flex: 1; }
.nw-tools { display: flex; gap: 8px; flex-wrap: wrap; flex: 1; }
.nw-search {
  flex: 1;
  min-width: 200px;
  height: 36px;
  padding: 0 12px;
  border-radius: 9px;
  border: 1px solid rgba(var(--line-rgb), 0.18);
  background: var(--card2);
  color: var(--text);
  font-size: 13px;
  font-family: inherit;
}
.nw-sort {
  height: 36px;
  padding: 0 10px;
  border-radius: 9px;
  border: 1px solid rgba(var(--line-rgb), 0.18);
  background: var(--card2);
  color: var(--text);
  font-size: 13px;
  font-family: inherit;
  cursor: pointer;
}
.nw-reset {
  height: 36px;
  padding: 0 16px;
  border-radius: 9px;
  border: 1px solid rgba(var(--line-rgb), 0.18);
  background: transparent;
  color: var(--muted2);
  font-size: 13px;
  font-family: inherit;
  cursor: pointer;
}
.nw-reset:disabled { opacity: 0.45; cursor: default; }
.nw-reset:not(:disabled):hover { border-color: var(--acc, #c6ff4a); color: var(--text); }

.nw-count { font-size: 12.5px; color: var(--muted); margin-bottom: 12px; }

.nw-badge {
  align-self: flex-start;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.3px;
  color: var(--muted2);
  background: var(--card2);
  border-radius: 20px;
  padding: 3px 10px;
}
.nw-badge-hot { color: var(--acc-ink, #10240a); background: var(--acc, #c6ff4a); }

.nw-feature {
  display: grid;
  grid-template-columns: 1.1fr 1fr;
  width: 100%;
  text-align: left;
  background: var(--card);
  border: 1px solid rgba(var(--line-rgb), 0.14);
  border-radius: 16px;
  overflow: hidden;
  cursor: pointer;
  margin-bottom: 22px;
  font-family: 'Plus Jakarta Sans', sans-serif;
  transition: border-color 0.16s, transform 0.16s;
}
.nw-feature:hover { border-color: var(--acc, #c6ff4a); transform: translateY(-2px); }
.nw-feature-img { min-height: 240px; background-size: cover; background-position: center; background-color: var(--card2); }
.nw-feature-body { padding: 26px 28px; display: flex; flex-direction: column; gap: 9px; }
.nw-feature-title { font-family: 'Chakra Petch', sans-serif; font-weight: 800; font-size: 22px; color: var(--text); line-height: 1.25; }
.nw-feature-excerpt { font-size: 13.5px; color: var(--muted2); line-height: 1.6; }

.nw-list { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; }
.nw-list li + li { border-top: 1px solid rgba(var(--line-rgb), 0.12); }
.nw-row {
  display: flex;
  align-items: center;
  gap: 18px;
  width: 100%;
  text-align: left;
  background: none;
  border: none;
  padding: 18px 12px;
  cursor: pointer;
  font-family: 'Plus Jakarta Sans', sans-serif;
  transition: background 0.15s;
}
.nw-row:hover { background: var(--card); }
.nw-row:hover .nw-row-title { color: var(--acc, #c6ff4a); }
.nw-row-thumb {
  flex: none;
  width: 132px;
  height: 84px;
  border-radius: 10px;
  background-size: cover;
  background-position: center;
  background-color: var(--card2);
}
.nw-row-body { flex: 1; min-width: 0; display: flex; flex-direction: column; gap: 6px; }
.nw-row-title { font-size: 15.5px; font-weight: 700; color: var(--text); line-height: 1.4; transition: color 0.15s; }
.nw-row-excerpt {
  font-size: 12.8px; color: var(--muted2); line-height: 1.55;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}
.nw-row-cta { flex: none; font-size: 12.5px; font-weight: 700; white-space: nowrap; }
.nw-meta { font-size: 11.5px; color: var(--muted); }

.nw-more {
  height: 42px;
  padding: 0 34px;
  border-radius: 11px;
  border: 1px solid rgba(var(--line-rgb), 0.2);
  background: transparent;
  color: var(--text);
  font-size: 13.5px;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
  transition: border-color 0.15s;
}
.nw-more:hover { border-color: var(--acc, #c6ff4a); }

@media (max-width: 860px) {
  .nw-filter-row { flex-direction: column; gap: 8px; }
  .nw-filter-label { width: auto; padding-top: 0; }
}
@media (max-width: 720px) {
  .nw-feature { grid-template-columns: 1fr; }
  .nw-feature-img { min-height: 180px; }
  .nw-row { flex-wrap: wrap; gap: 12px; }
  .nw-row-thumb { width: 100px; height: 66px; }
  .nw-row-cta { display: none; }
}
</style>
