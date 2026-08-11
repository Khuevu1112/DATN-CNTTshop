<script setup>
import { ref, watch, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { actions, accent } from '../store.js';
import { fetchArticle, fetchArticles, resolveImageUrl } from '../api.js';
import { ngayVN } from '../data/supportMeta.js';

const route = useRoute();
const bai = ref(null);
const khac = ref([]);
const truoc = ref(null);
const ke = ref(null);
const dangTai = ref(true);
const loi = ref('');

async function tai(slug) {
  dangTai.value = true;
  loi.value = '';
  bai.value = null;
  truoc.value = null;
  ke.value = null;
  try {
    bai.value = await fetchArticle(slug);
    // Vài bài cùng danh mục để đọc tiếp (bỏ chính bài đang xem).
    const ds = await fetchArticles(bai.value.maDanhMuc).catch(() => []);
    khac.value = ds.filter((a) => a.slug !== slug).slice(0, 3);

    // Điều hướng bài trước / bài kế trong cùng danh mục, xếp theo ngày đăng mới nhất trước.
    const theoNgay = [...ds].sort((x, y) => new Date(y.publishedAt || 0) - new Date(x.publishedAt || 0));
    const i = theoNgay.findIndex((a) => a.slug === slug);
    if (i > -1) {
      truoc.value = theoNgay[i - 1] || null; // mới hơn
      ke.value = theoNgay[i + 1] || null; // cũ hơn
    }
  } catch (e) {
    loi.value = 'Không tìm thấy bài viết hoặc bài chưa được xuất bản.';
  } finally {
    dangTai.value = false;
  }
}

function chiaSe() {
  const url = window.location.href;
  if (navigator.share) {
    navigator.share({ title: bai.value?.tieuDe, url }).catch(() => {});
  } else {
    navigator.clipboard?.writeText(url);
  }
}

watch(() => route.params.slug, (s) => s && tai(s));
onMounted(() => tai(route.params.slug));
</script>

<template>
  <main style="max-width: 820px; margin: 0 auto; padding: 20px 24px 72px">
    <div v-if="dangTai" class="sp-card sp-empty">Đang tải…</div>
    <div v-else-if="loi" class="sp-card sp-empty">{{ loi }}</div>

    <template v-else-if="bai">
      <!-- Breadcrumb -->
      <nav class="art-crumb">
        <button @click="actions.goHome()">Trang chủ</button>
        <span>›</span>
        <button @click="actions.goNews()">Tin tức &amp; thông báo</button>
        <span>›</span>
        <button @click="actions.goNews(bai.maDanhMuc)">{{ bai.tenDanhMuc }}</button>
      </nav>

      <h1 style="font-family: 'Plus Jakarta Sans', sans-serif; font-weight: 800; font-size: 30px; line-height: 1.2; color: var(--text); margin: 0 0 14px">
        {{ bai.tieuDe }}
      </h1>

      <!-- Metadata dạng bảng: danh mục / ngày đăng tách bạch, dễ quét -->
      <div class="art-meta">
        <div><span>Danh mục</span><b>{{ bai.tenDanhMuc }}</b></div>
        <div><span>Ngày đăng</span><b>{{ ngayVN(bai.publishedAt) }}</b></div>
        <div v-if="bai.tacGia"><span>Tác giả</span><b>{{ bai.tacGia }}</b></div>
        <div><span>Lượt xem</span><b>{{ bai.luotXem }}</b></div>
      </div>

      <img
        v-if="bai.thumbnail"
        :src="resolveImageUrl(bai.thumbnail)"
        :alt="bai.tieuDe"
        style="width: 100%; border-radius: 14px; margin-bottom: 26px; display: block"
      />

      <!-- Thân bài do admin soạn (HTML). Nội dung nội bộ, không phải input người dùng cuối. -->
      <article class="art-body" v-html="bai.noiDung"></article>

      <div class="art-actions">
        <button class="art-btn" @click="chiaSe">Chia sẻ bài viết</button>
        <button class="art-btn" @click="actions.goNews(bai.maDanhMuc)">Xem tất cả mục {{ bai.tenDanhMuc }}</button>
      </div>

      <!-- Điều hướng bài trước / bài kế trong cùng danh mục -->
      <div v-if="truoc || ke" class="art-nav">
        <button v-if="truoc" class="art-nav-item" @click="actions.goArticle(truoc.slug)">
          <span class="art-nav-lbl">← Bài mới hơn</span>
          <span class="art-nav-title">{{ truoc.tieuDe }}</span>
        </button>
        <span v-else></span>
        <button v-if="ke" class="art-nav-item art-nav-right" @click="actions.goArticle(ke.slug)">
          <span class="art-nav-lbl">Bài cũ hơn →</span>
          <span class="art-nav-title">{{ ke.tieuDe }}</span>
        </button>
      </div>

      <!-- Bài khác cùng danh mục -->
      <div v-if="khac.length" style="margin-top: 36px; border-top: 1px solid rgba(var(--line-rgb), 0.12); padding-top: 24px">
        <h2 class="sp-h2">Bài viết liên quan</h2>
        <div style="display: flex; flex-direction: column; gap: 10px">
          <button
            v-for="a in khac"
            :key="a.id"
            @click="actions.goArticle(a.slug)"
            class="art-other"
          >
            <span style="flex: 1; text-align: left">{{ a.tieuDe }}</span>
            <span style="font-size: 11.5px; color: var(--muted); white-space: nowrap">{{ ngayVN(a.publishedAt) }}</span>
          </button>
        </div>
      </div>
    </template>
  </main>
</template>

<style scoped>
.art-crumb {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12.5px;
  color: var(--muted);
  margin-bottom: 18px;
  flex-wrap: wrap;
}
.art-crumb button {
  background: none;
  border: none;
  padding: 0;
  font: inherit;
  color: var(--muted);
  cursor: pointer;
}
.art-crumb button:hover { color: var(--acc, #c6ff4a); }

.art-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 10px 28px;
  padding: 14px 16px;
  margin-bottom: 24px;
  background: var(--card);
  border: 1px solid rgba(var(--line-rgb), 0.14);
  border-radius: 12px;
}
.art-meta > div { display: flex; flex-direction: column; gap: 3px; }
.art-meta span { font-size: 11px; color: var(--muted); letter-spacing: 0.3px; }
.art-meta b { font-size: 13px; color: var(--text); font-weight: 700; }

.art-actions { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 30px; }
.art-btn {
  height: 38px;
  padding: 0 18px;
  border-radius: 10px;
  border: 1px solid rgba(var(--line-rgb), 0.2);
  background: transparent;
  color: var(--text);
  font-size: 13px;
  font-weight: 600;
  font-family: inherit;
  cursor: pointer;
  transition: border-color 0.15s;
}
.art-btn:hover { border-color: var(--acc, #c6ff4a); }

.art-nav {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-top: 26px;
}
.art-nav-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
  text-align: left;
  background: var(--card);
  border: 1px solid rgba(var(--line-rgb), 0.14);
  border-radius: 12px;
  padding: 14px 16px;
  cursor: pointer;
  font-family: 'Plus Jakarta Sans', sans-serif;
  transition: border-color 0.15s;
}
.art-nav-item:hover { border-color: var(--acc, #c6ff4a); }
.art-nav-right { text-align: right; align-items: flex-end; }
.art-nav-lbl { font-size: 11.5px; color: var(--muted); }
.art-nav-title {
  font-size: 13.5px; font-weight: 700; color: var(--text); line-height: 1.4;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}

@media (max-width: 620px) {
  .art-nav { grid-template-columns: 1fr; }
  .art-nav-right { text-align: left; align-items: flex-start; }
}

.art-body {
  font-size: 15px;
  color: var(--text);
  line-height: 1.75;
}
.art-body :deep(p) { margin: 0 0 16px; color: var(--muted2); }
.art-body :deep(h2),
.art-body :deep(h3) { font-family: 'Chakra Petch', sans-serif; color: var(--text); margin: 26px 0 12px; }
.art-body :deep(h3) { font-size: 18px; }
.art-body :deep(strong) { color: var(--text); }
.art-body :deep(img) { max-width: 100%; border-radius: 10px; margin: 12px 0; }
.art-body :deep(ul),
.art-body :deep(ol) { margin: 0 0 16px; padding-left: 22px; color: var(--muted2); }
.art-body :deep(a) { color: var(--acc, #c6ff4a); }

.art-other {
  display: flex;
  align-items: center;
  gap: 14px;
  width: 100%;
  background: var(--card);
  border: 1px solid rgba(var(--line-rgb), 0.14);
  border-radius: 11px;
  padding: 14px 16px;
  cursor: pointer;
  font-size: 13.5px;
  font-weight: 600;
  color: var(--text);
  font-family: 'Plus Jakarta Sans', sans-serif;
  transition: border-color 0.15s;
}
.art-other:hover { border-color: var(--acc, #c6ff4a); }
</style>
