<script setup>
/**
 * Trang Tin tức & thông báo — bố cục 3 cột kiểu trang tin (tham khảo Samsung Support Newsalert
 * cho phần lọc/danh sách và VnExpress cho khối "xem nhiều / mới nhất" bên phải):
 *
 *   [ bộ lọc ]  [ bài nổi bật + lưới card ]  [ tin nổi bật / tin mới nhất ]
 *
 * Hai sidebar đều sticky nên khi cuộn danh sách dài, bộ lọc và tin nổi bật vẫn nằm trong tầm
 * mắt. Màn hẹp thì xếp dọc: nội dung chính lên trước, hai sidebar xuống dưới.
 */
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
const soHien = ref(6); // "Xem thêm" nạp dần thay vì phân trang số trang
const MOI_LAN = 6;

async function tai() {
  dangTai.value = true;
  soHien.value = MOI_LAN;
  try {
    // Luôn tải TOÀN BỘ bài rồi lọc phía client: hai sidebar cần dữ liệu của mọi danh mục
    // (tin nổi bật / mới nhất không đổi theo bộ lọc đang chọn), nếu gọi API theo danh mục thì
    // chúng sẽ trống rỗng mỗi khi khách lọc.
    articles.value = await fetchArticles();
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
watch(() => route.query.c, (v) => { catChon.value = v || ''; soHien.value = MOI_LAN; });
watch([tuKhoa, sapXep], () => { soHien.value = MOI_LAN; });

function datLai() {
  tuKhoa.value = '';
  sapXep.value = 'moi_nhat';
  if (catChon.value) chonCat('');
}
const coLoc = computed(() => !!catChon.value || !!tuKhoa.value.trim() || sapXep.value !== 'moi_nhat');

const moiNhatTruoc = (ds) =>
  [...ds].sort((x, y) => new Date(y.publishedAt || 0) - new Date(x.publishedAt || 0));

// ===== Cột giữa =====
// Bài hero chỉ hiện khi KHÔNG lọc gì — đang tìm kiếm mà vẫn chèn một bài to không liên quan
// lên đầu thì gây nhiễu.
const hero = computed(() => (!coLoc.value ? moiNhatTruoc(articles.value).find((a) => a.noiBat) : null));

const daLoc = computed(() => {
  const q = tuKhoa.value.trim().toLowerCase();
  let ds = articles.value.filter((a) => a !== hero.value);
  if (catChon.value) ds = ds.filter((a) => a.maDanhMuc === catChon.value);
  if (q) {
    ds = ds.filter((a) =>
      (a.tieuDe || '').toLowerCase().includes(q) || (a.tomTat || '').toLowerCase().includes(q),
    );
  }
  if (sapXep.value === 'a_z') {
    return [...ds].sort((x, y) => (x.tieuDe || '').localeCompare(y.tieuDe || '', 'vi'));
  }
  if (sapXep.value === 'xem_nhieu') {
    return [...ds].sort((x, y) => (y.luotXem || 0) - (x.luotXem || 0));
  }
  return moiNhatTruoc(ds);
});
const hienThi = computed(() => daLoc.value.slice(0, soHien.value));
const conNua = computed(() => daLoc.value.length > soHien.value);

// ===== Sidebar phải — không phụ thuộc bộ lọc đang chọn =====
const tinNoiBat = computed(() =>
  moiNhatTruoc(articles.value.filter((a) => a.noiBat && a !== hero.value)).slice(0, 5),
);
const tinMoiNhat = computed(() =>
  moiNhatTruoc(articles.value).filter((a) => a !== hero.value).slice(0, 5),
);

// ===== Sidebar trái =====
const demTheoCat = (ma) => (ma ? articles.value.filter((a) => a.maDanhMuc === ma).length : articles.value.length);
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
  <main class="nw-page">
    <!-- Breadcrumb -->
    <nav class="nw-crumb">
      <button @click="actions.goHome()">Trang chủ</button>
      <span>›</span>
      <button @click="actions.goSupport()">Hỗ trợ</button>
      <span>›</span>
      <span class="cur">Tin tức &amp; thông báo</span>
    </nav>

    <header class="nw-hd">
      <h1 class="sp-h1" style="margin-bottom: 8px">Tin tức &amp; <span :style="{ color: accent }">thông báo</span></h1>
      <p>Review phần cứng, hướng dẫn build PC, thông báo cập nhật sản phẩm và các chương trình ưu đãi mới nhất.</p>
    </header>

    <div class="nw-grid3">
      <!-- ═══ SIDEBAR TRÁI: bộ lọc ═══ -->
      <aside class="nw-side nw-left">
        <section class="nw-box">
          <div class="nw-box-title">Danh mục</div>
          <button
            class="nw-cat"
            :class="{ on: !catChon }"
            @click="chonCat('')"
          >
            <span>Tất cả</span><b>{{ demTheoCat('') }}</b>
          </button>
          <button
            v-for="c in cats"
            :key="c.ma"
            class="nw-cat"
            :class="{ on: catChon === c.ma }"
            @click="chonCat(c.ma)"
          >
            <span>{{ c.ten }}</span><b>{{ demTheoCat(c.ma) }}</b>
          </button>
        </section>

        <section class="nw-box">
          <div class="nw-box-title">Tìm kiếm</div>
          <input v-model="tuKhoa" class="nw-search" type="search" placeholder="Từ khoá tiêu đề…" />

          <div class="nw-box-title" style="margin-top: 16px">Sắp xếp</div>
          <label v-for="o in [
            { v: 'moi_nhat', t: 'Mới nhất' },
            { v: 'xem_nhieu', t: 'Xem nhiều nhất' },
            { v: 'a_z', t: 'Tiêu đề A → Z' },
          ]" :key="o.v" class="nw-radio">
            <input type="radio" :value="o.v" v-model="sapXep" />
            <span>{{ o.t }}</span>
          </label>

          <button class="nw-reset" :disabled="!coLoc" @click="datLai">Đặt lại bộ lọc</button>
        </section>
      </aside>

      <!-- ═══ CỘT GIỮA: bài nổi bật + lưới card ═══ -->
      <section class="nw-main">
        <div v-if="dangTai" class="sp-card sp-empty">Đang tải…</div>
        <div v-else-if="!articles.length" class="sp-card sp-empty">Chưa có bài viết nào.</div>

        <template v-else>
          <!-- Bài nổi bật -->
          <button v-if="hero" class="nw-hero" @click="actions.goArticle(hero.slug)">
            <div class="nw-hero-img" :style="{ backgroundImage: `url(${resolveImageUrl(hero.thumbnail)})` }">
              <span class="nw-badge nw-badge-hot">Nổi bật</span>
            </div>
            <div class="nw-hero-body">
              <div class="nw-hero-title">{{ hero.tieuDe }}</div>
              <div class="nw-hero-excerpt">{{ hero.tomTat }}</div>
              <div class="nw-meta">{{ hero.tenDanhMuc }} · {{ ngayVN(hero.publishedAt) }} · {{ hero.luotXem }} lượt xem</div>
            </div>
          </button>

          <div class="nw-count">
            <b>{{ daLoc.length }}</b> bài viết<span v-if="catChon"> trong mục “{{ tenCat }}”</span>
          </div>

          <div v-if="!hienThi.length" class="sp-card sp-empty">Không tìm thấy bài viết khớp từ khoá.</div>

          <!-- Lưới card -->
          <div v-else class="nw-cards">
            <button v-for="a in hienThi" :key="a.id" class="nw-card" @click="actions.goArticle(a.slug)">
              <div class="nw-card-img" :style="{ backgroundImage: `url(${resolveImageUrl(a.thumbnail)})` }">
                <span class="nw-badge">{{ a.tenDanhMuc }}</span>
              </div>
              <div class="nw-card-body">
                <div class="nw-card-title">{{ a.tieuDe }}</div>
                <div class="nw-card-excerpt">{{ a.tomTat }}</div>
                <div class="nw-meta nw-card-meta">{{ ngayVN(a.publishedAt) }} · {{ a.luotXem }} lượt xem</div>
              </div>
            </button>
          </div>

          <div v-if="conNua" style="display: flex; justify-content: center; margin-top: 24px">
            <button class="nw-more" @click="soHien += MOI_LAN">Xem thêm</button>
          </div>
        </template>
      </section>

      <!-- ═══ SIDEBAR PHẢI: tin nổi bật + tin mới nhất ═══ -->
      <aside class="nw-side nw-right">
        <section v-if="tinNoiBat.length" class="nw-box">
          <div class="nw-box-title">Tin nổi bật</div>
          <button
            v-for="(a, i) in tinNoiBat"
            :key="a.id"
            class="nw-rank"
            @click="actions.goArticle(a.slug)"
          >
            <span class="nw-rank-no" :style="{ color: accent }">{{ i + 1 }}</span>
            <span class="nw-rank-body">
              <span class="nw-rank-title">{{ a.tieuDe }}</span>
              <span class="nw-meta">{{ a.luotXem }} lượt xem</span>
            </span>
          </button>
        </section>

        <section v-if="tinMoiNhat.length" class="nw-box">
          <div class="nw-box-title">Tin mới nhất</div>
          <button
            v-for="a in tinMoiNhat"
            :key="a.id"
            class="nw-latest"
            @click="actions.goArticle(a.slug)"
          >
            <span
              class="nw-latest-thumb"
              :style="a.thumbnail ? { backgroundImage: `url(${resolveImageUrl(a.thumbnail)})` } : {}"
            ></span>
            <span class="nw-latest-body">
              <span class="nw-latest-title">{{ a.tieuDe }}</span>
              <span class="nw-meta">{{ ngayVN(a.publishedAt) }}</span>
            </span>
          </button>
        </section>
      </aside>
    </div>
  </main>
</template>

<style scoped>
.nw-page { max-width: 1360px; margin: 0 auto; padding: 20px 24px 72px; }

.nw-crumb {
  display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
  font-size: 12.5px; color: var(--muted); margin-bottom: 16px;
}
.nw-crumb button { background: none; border: none; padding: 0; font: inherit; color: var(--muted); cursor: pointer; }
.nw-crumb button:hover { color: var(--acc, #c6ff4a); }
.nw-crumb .cur { color: var(--text); font-weight: 600; }

.nw-hd { margin-bottom: 22px; }
.nw-hd p { font-size: 14.5px; color: var(--muted2); max-width: 680px; line-height: 1.65; margin: 0; }

/* 3 cột: bộ lọc | nội dung | tin nổi bật */
.nw-grid3 { display: grid; grid-template-columns: 218px minmax(0, 1fr) 292px; gap: 24px; align-items: start; }
.nw-side { display: flex; flex-direction: column; gap: 16px; position: sticky; top: 92px; }

.nw-box {
  background: var(--card);
  border: 1px solid rgba(var(--line-rgb), 0.14);
  border-radius: 14px;
  padding: 16px;
}
.nw-box-title {
  font-family: 'Chakra Petch', sans-serif;
  font-size: 11.5px; letter-spacing: 1.2px; font-weight: 700;
  color: var(--muted); text-transform: uppercase; margin-bottom: 12px;
}

/* --- Bộ lọc --- */
.nw-cat {
  display: flex; align-items: center; justify-content: space-between; gap: 10px;
  width: 100%; padding: 8px 10px; margin-bottom: 4px;
  border: none; border-radius: 9px; background: transparent; cursor: pointer;
  font-family: inherit; font-size: 13px; color: var(--muted2); text-align: left;
  transition: background 0.14s, color 0.14s;
}
.nw-cat b { font-size: 11.5px; color: var(--muted); font-weight: 700; }
.nw-cat:hover { background: var(--card2); color: var(--text); }
.nw-cat.on { background: color-mix(in srgb, var(--acc, #c6ff4a) 14%, transparent); color: var(--acc, #c6ff4a); font-weight: 700; }
.nw-cat.on b { color: inherit; }

.nw-search {
  width: 100%; height: 36px; padding: 0 12px;
  border-radius: 9px; border: 1px solid rgba(var(--line-rgb), 0.18);
  background: var(--card2); color: var(--text); font-size: 13px; font-family: inherit;
}
.nw-radio {
  display: flex; align-items: center; gap: 9px; padding: 6px 2px;
  font-size: 13px; color: var(--muted2); cursor: pointer;
}
.nw-radio input { accent-color: var(--acc, #c6ff4a); cursor: pointer; }
.nw-reset {
  width: 100%; height: 36px; margin-top: 14px;
  border-radius: 9px; border: 1px solid rgba(var(--line-rgb), 0.18);
  background: transparent; color: var(--muted2); font-size: 12.5px; font-family: inherit; cursor: pointer;
}
.nw-reset:disabled { opacity: 0.4; cursor: default; }
.nw-reset:not(:disabled):hover { border-color: var(--acc, #c6ff4a); color: var(--text); }

/* --- Cột giữa --- */
.nw-main { min-width: 0; }
.nw-count { font-size: 12.5px; color: var(--muted); margin-bottom: 14px; }
.nw-count b { color: var(--text); }

.nw-badge {
  position: absolute; top: 10px; left: 10px;
  font-size: 10.8px; font-weight: 700; color: #fff;
  background: rgba(0, 0, 0, 0.6); border-radius: 20px; padding: 3px 10px;
}
.nw-badge-hot { background: var(--acc, #c6ff4a); color: var(--acc-ink, #10240a); }

.nw-hero {
  display: block; width: 100%; text-align: left; padding: 0;
  background: var(--card); border: 1px solid rgba(var(--line-rgb), 0.14);
  border-radius: 16px; overflow: hidden; cursor: pointer; margin-bottom: 22px;
  font-family: 'Plus Jakarta Sans', sans-serif;
  transition: border-color 0.16s, transform 0.16s;
}
.nw-hero:hover { border-color: var(--acc, #c6ff4a); transform: translateY(-2px); }
.nw-hero-img { position: relative; height: 300px; background-size: cover; background-position: center; background-color: var(--card2); }
.nw-hero-body { padding: 20px 22px; display: flex; flex-direction: column; gap: 8px; }
.nw-hero-title { font-family: 'Chakra Petch', sans-serif; font-weight: 800; font-size: 23px; color: var(--text); line-height: 1.25; }
.nw-hero-excerpt { font-size: 13.5px; color: var(--muted2); line-height: 1.6; }

.nw-cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(258px, 1fr)); gap: 18px; }
.nw-card {
  display: flex; flex-direction: column; text-align: left; padding: 0;
  background: var(--card); border: 1px solid rgba(var(--line-rgb), 0.14);
  border-radius: 14px; overflow: hidden; cursor: pointer;
  font-family: 'Plus Jakarta Sans', sans-serif;
  transition: border-color 0.16s, transform 0.16s;
}
.nw-card:hover { border-color: var(--acc, #c6ff4a); transform: translateY(-2px); }
.nw-card-img { position: relative; height: 158px; background-size: cover; background-position: center; background-color: var(--card2); }
.nw-card-body { padding: 14px 16px; display: flex; flex-direction: column; flex: 1; gap: 7px; }
.nw-card-title {
  font-size: 14.5px; font-weight: 700; color: var(--text); line-height: 1.4;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}
.nw-card-excerpt {
  font-size: 12.6px; color: var(--muted2); line-height: 1.55;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}
.nw-card-meta { margin-top: auto; padding-top: 4px; }
.nw-meta { font-size: 11.5px; color: var(--muted); }

.nw-more {
  height: 42px; padding: 0 34px;
  border-radius: 11px; border: 1px solid rgba(var(--line-rgb), 0.2);
  background: transparent; color: var(--text);
  font-size: 13.5px; font-weight: 700; font-family: inherit; cursor: pointer;
  transition: border-color 0.15s;
}
.nw-more:hover { border-color: var(--acc, #c6ff4a); }

/* --- Sidebar phải --- */
.nw-rank {
  display: flex; gap: 11px; width: 100%; padding: 9px 4px;
  background: none; border: none; cursor: pointer; text-align: left;
  font-family: 'Plus Jakarta Sans', sans-serif;
  border-bottom: 1px solid rgba(var(--line-rgb), 0.1);
}
.nw-rank:last-child { border-bottom: none; }
.nw-rank-no { flex: none; font-family: 'Chakra Petch', sans-serif; font-weight: 800; font-size: 19px; line-height: 1.2; width: 20px; }
.nw-rank-body { display: flex; flex-direction: column; gap: 3px; min-width: 0; }
.nw-rank-title {
  font-size: 12.9px; font-weight: 600; color: var(--text); line-height: 1.42;
  display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden;
}
.nw-rank:hover .nw-rank-title { color: var(--acc, #c6ff4a); }

.nw-latest {
  display: flex; gap: 11px; width: 100%; padding: 9px 4px;
  background: none; border: none; cursor: pointer; text-align: left;
  font-family: 'Plus Jakarta Sans', sans-serif;
  border-bottom: 1px solid rgba(var(--line-rgb), 0.1);
}
.nw-latest:last-child { border-bottom: none; }
.nw-latest-thumb {
  flex: none; width: 62px; height: 46px; border-radius: 8px;
  background-color: var(--card2); background-size: cover; background-position: center;
}
.nw-latest-body { display: flex; flex-direction: column; gap: 4px; min-width: 0; }
.nw-latest-title {
  font-size: 12.7px; font-weight: 600; color: var(--text); line-height: 1.4;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}
.nw-latest:hover .nw-latest-title { color: var(--acc, #c6ff4a); }

/* Màn hẹp: bỏ dần sidebar, nội dung chính luôn lên trước */
@media (max-width: 1180px) {
  .nw-grid3 { grid-template-columns: 200px minmax(0, 1fr); }
  .nw-right { grid-column: 1 / -1; position: static; flex-direction: row; flex-wrap: wrap; }
  .nw-right .nw-box { flex: 1; min-width: 280px; }
}
@media (max-width: 860px) {
  .nw-grid3 { grid-template-columns: 1fr; }
  .nw-left { position: static; order: 2; flex-direction: row; flex-wrap: wrap; }
  .nw-left .nw-box { flex: 1; min-width: 260px; }
  .nw-main { order: 1; }
  .nw-right { order: 3; }
  .nw-hero-img { height: 210px; }
  .nw-hero-title { font-size: 19px; }
}
</style>
