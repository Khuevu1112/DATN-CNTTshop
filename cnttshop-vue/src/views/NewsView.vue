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
const trang = ref(1);
const MOI_TRANG = 9;

async function tai() {
  dangTai.value = true;
  trang.value = 1;
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

// Bài nổi bật (chỉ khi xem "Tất cả", trang 1) — 1 bài lớn lên đầu.
const noiBat = computed(() => (!catChon.value ? articles.value.find((a) => a.noiBat) : null));
const conLai = computed(() => articles.value.filter((a) => a !== noiBat.value));

const soTrang = computed(() => Math.max(1, Math.ceil(conLai.value.length / MOI_TRANG)));
const trangHienThi = computed(() =>
  conLai.value.slice((trang.value - 1) * MOI_TRANG, trang.value * MOI_TRANG),
);
function doiTrang(p) {
  trang.value = p;
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

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
  <main style="max-width: 1180px; margin: 0 auto; padding: 24px 24px 72px">
    <button class="sp-back" @click="actions.goHome()">← Trang chủ</button>

    <div style="margin-bottom: 22px">
      <div class="sp-eyebrow">TIN TỨC</div>
      <h1 class="sp-h1">Tin tức &amp; <span :style="{ color: accent }">kiến thức</span></h1>
      <p style="font-size: 14.5px; color: var(--muted2); max-width: 640px; line-height: 1.65; margin: 0">
        Review phần cứng, hướng dẫn build PC, tin công nghệ và các chương trình ưu đãi mới nhất.
      </p>
    </div>

    <!-- Tabs danh mục -->
    <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 24px">
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

    <div v-if="dangTai" class="sp-card sp-empty">Đang tải…</div>
    <div v-else-if="!articles.length" class="sp-card sp-empty">Chưa có bài viết nào trong mục này.</div>

    <template v-else>
      <!-- Bài nổi bật -->
      <button v-if="noiBat && trang === 1" class="nw-feature" @click="actions.goArticle(noiBat.slug)">
        <div class="nw-feature-img" :style="{ backgroundImage: `url(${resolveImageUrl(noiBat.thumbnail)})` }"></div>
        <div class="nw-feature-body">
          <span class="nw-cat" :style="{ color: accent }">{{ noiBat.tenDanhMuc }}</span>
          <div class="nw-feature-title">{{ noiBat.tieuDe }}</div>
          <div class="nw-feature-excerpt">{{ noiBat.tomTat }}</div>
          <div class="nw-meta">{{ ngayVN(noiBat.publishedAt) }} · {{ noiBat.tacGia }} · {{ noiBat.luotXem }} lượt xem</div>
        </div>
      </button>

      <!-- Lưới bài -->
      <div class="nw-grid">
        <button v-for="a in trangHienThi" :key="a.id" class="nw-card" @click="actions.goArticle(a.slug)">
          <div class="nw-thumb" :style="{ backgroundImage: `url(${resolveImageUrl(a.thumbnail)})` }">
            <span class="nw-cat-badge">{{ a.tenDanhMuc }}</span>
          </div>
          <div style="padding: 14px 16px; display: flex; flex-direction: column; flex: 1">
            <div class="nw-title">{{ a.tieuDe }}</div>
            <div class="nw-excerpt">{{ a.tomTat }}</div>
            <div class="nw-meta" style="margin-top: auto; padding-top: 10px">
              {{ ngayVN(a.publishedAt) }} · {{ a.luotXem }} lượt xem
            </div>
          </div>
        </button>
      </div>

      <!-- Phân trang -->
      <div v-if="soTrang > 1" style="display: flex; justify-content: center; gap: 8px; margin-top: 28px">
        <button
          v-for="p in soTrang"
          :key="p"
          class="sp-chip"
          :class="{ active: trang === p }"
          @click="doiTrang(p)"
        >
          {{ p }}
        </button>
      </div>
    </template>
  </main>
</template>

<style scoped>
.nw-feature {
  display: grid;
  grid-template-columns: 1.1fr 1fr;
  gap: 0;
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
.nw-feature-body { padding: 26px 28px; display: flex; flex-direction: column; gap: 8px; }
.nw-feature-title { font-family: 'Chakra Petch', sans-serif; font-weight: 800; font-size: 22px; color: var(--text); line-height: 1.25; }
.nw-feature-excerpt { font-size: 13.5px; color: var(--muted2); line-height: 1.6; }

.nw-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 18px;
}
.nw-card {
  display: flex;
  flex-direction: column;
  text-align: left;
  background: var(--card);
  border: 1px solid rgba(var(--line-rgb), 0.14);
  border-radius: 14px;
  overflow: hidden;
  cursor: pointer;
  font-family: 'Plus Jakarta Sans', sans-serif;
  transition: border-color 0.16s, transform 0.16s;
}
.nw-card:hover { border-color: var(--acc, #c6ff4a); transform: translateY(-2px); }
.nw-thumb { position: relative; height: 170px; background-size: cover; background-position: center; background-color: var(--card2); }
.nw-cat-badge {
  position: absolute; top: 10px; left: 10px;
  font-size: 11px; font-weight: 600; color: #fff;
  background: rgba(0, 0, 0, 0.55); border-radius: 20px; padding: 3px 10px;
}
.nw-cat { font-family: 'Chakra Petch', sans-serif; font-size: 11px; letter-spacing: 1.5px; font-weight: 700; }
.nw-title { font-size: 15px; font-weight: 700; color: var(--text); line-height: 1.4; margin-bottom: 8px; }
.nw-excerpt {
  font-size: 12.7px; color: var(--muted2); line-height: 1.55;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}
.nw-meta { font-size: 11.5px; color: var(--muted); }

@media (max-width: 720px) {
  .nw-feature { grid-template-columns: 1fr; }
  .nw-feature-img { min-height: 180px; }
}
</style>
