<script setup>
import { ref, watch, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { actions, accent } from '../store.js';
import { fetchArticle, fetchArticles, resolveImageUrl } from '../api.js';
import { ngayVN } from '../data/supportMeta.js';

const route = useRoute();
const bai = ref(null);
const khac = ref([]);
const dangTai = ref(true);
const loi = ref('');

async function tai(slug) {
  dangTai.value = true;
  loi.value = '';
  bai.value = null;
  try {
    bai.value = await fetchArticle(slug);
    // Vài bài cùng danh mục để đọc tiếp (bỏ chính bài đang xem).
    const ds = await fetchArticles(bai.value.maDanhMuc).catch(() => []);
    khac.value = ds.filter((a) => a.slug !== slug).slice(0, 3);
  } catch (e) {
    loi.value = 'Không tìm thấy bài viết hoặc bài chưa được xuất bản.';
  } finally {
    dangTai.value = false;
  }
}

watch(() => route.params.slug, (s) => s && tai(s));
onMounted(() => tai(route.params.slug));
</script>

<template>
  <main style="max-width: 820px; margin: 0 auto; padding: 24px 24px 72px">
    <button class="sp-back" @click="actions.goNews()">← Tất cả tin tức</button>

    <div v-if="dangTai" class="sp-card sp-empty">Đang tải…</div>
    <div v-else-if="loi" class="sp-card sp-empty">{{ loi }}</div>

    <template v-else-if="bai">
      <div class="sp-eyebrow" style="cursor: pointer" @click="actions.goNews(bai.maDanhMuc)">{{ bai.tenDanhMuc }}</div>
      <h1 style="font-family: 'Plus Jakarta Sans', sans-serif; font-weight: 800; font-size: 30px; line-height: 1.2; color: var(--text); margin: 8px 0 12px">
        {{ bai.tieuDe }}
      </h1>
      <div style="font-size: 12.5px; color: var(--muted); margin-bottom: 22px">
        {{ ngayVN(bai.publishedAt) }} · {{ bai.tacGia }} · {{ bai.luotXem }} lượt xem
      </div>

      <img
        v-if="bai.thumbnail"
        :src="resolveImageUrl(bai.thumbnail)"
        :alt="bai.tieuDe"
        style="width: 100%; border-radius: 14px; margin-bottom: 24px; display: block"
      />

      <!-- Thân bài do admin soạn (HTML). Nội dung nội bộ, không phải input người dùng cuối. -->
      <article class="art-body" v-html="bai.noiDung"></article>

      <!-- Bài khác cùng danh mục -->
      <div v-if="khac.length" style="margin-top: 40px; border-top: 1px solid rgba(var(--line-rgb), 0.12); padding-top: 24px">
        <h2 class="sp-h2">Bài viết khác</h2>
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
