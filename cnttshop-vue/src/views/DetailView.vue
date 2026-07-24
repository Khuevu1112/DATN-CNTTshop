<script setup>
import { computed, ref, watch } from 'vue';
import {
  catMeta,
  fmt,
  productById,
  priceWith,
  products,
  silverTokensFor,
  renderDescription,
} from '../data/products.js';
import { state, actions, accent } from '../store.js';
import { fetchProductReviews, API_ORIGIN, resolveImageUrl } from '../api.js';
import { flyToCart } from '../flyToCart.js';
import ProductCard from '../components/ProductCard.vue';

const sp = computed(() => productById(state.selId));

const reviews = ref([]);
const reviewsLoading = ref(true);
const selectedImageIdx = ref(0);
watch(
  () => sp.value?.slug,
  async (slug) => {
    selectedImageIdx.value = 0;
    if (!slug) return;
    reviewsLoading.value = true;
    try {
      reviews.value = await fetchProductReviews(slug);
    } finally {
      reviewsLoading.value = false;
    }
  },
  { immediate: true },
);
function fmtReviewDate(iso) {
  const d = new Date(iso);
  return `${String(d.getDate()).padStart(2, '0')}/${String(d.getMonth() + 1).padStart(2, '0')}/${d.getFullYear()}`;
}

const live = computed(() => (sp.value ? priceWith(sp.value, state.cfgSel) : 0));
const upgraded = computed(() => sp.value && live.value !== sp.value.price);

// Nhóm cùng linkedGroup = bị khoá cặp: chỉ những tổ hợp admin đã thật sự tạo biến thể mới hợp
// lệ. Chọn 1 giá trị ở nhóm này -> nhóm khoá cặp còn lại chỉ còn bấm được giá trị nào từng đi
// cùng trong ít nhất 1 biến thể thật (không hiện chọn được tổ hợp không tồn tại).
function isCfgChoiceAvailable(allGroups, variants, group, choiceLabel) {
  if (!group.linkedGroup) return true;
  const siblings = allGroups.filter((g) => g.linkedGroup === group.linkedGroup && g.key !== group.key);
  if (!siblings.length) return true;
  return variants.some((v) => {
    if (!v.options || v.options[group.label] !== choiceLabel) return false;
    return siblings.every((sib) => {
      const selIdx = state.cfgSel[sib.key] || 0;
      const selLabel = sib.ch[selIdx]?.l;
      return !v.options || v.options[sib.label] === selLabel;
    });
  });
}

const cfgGroups = computed(() => {
  if (!sp.value) return [];
  const allGroups = sp.value.cfg || [];
  const variants = sp.value._variants || [];
  return allGroups.map((g) => ({
    key: g.key,
    label: g.label,
    linkedGroup: g.linkedGroup,
    choices: g.ch.map((c, idx) => {
      const on = (state.cfgSel[g.key] || 0) === idx;
      const available = isCfgChoiceAvailable(allGroups, variants, g, c.l);
      return {
        idx,
        label: c.l,
        deltaText: c.d === 0 ? 'Tiêu chuẩn' : '+' + fmt(c.d),
        bdr: on ? accent.value : 'rgba(var(--line-rgb),0.18)',
        bg: on
          ? 'color-mix(in srgb, ' + accent.value + ' 14%, transparent)'
          : 'var(--card2)',
        lblColor: on ? 'var(--text)' : 'var(--muted2)',
        dColor: on ? accent.value : 'var(--muted)',
        disabled: !available,
      };
    }),
  }));
});

/** Chọn 1 giá trị cấu hình; nếu nhóm bị khoá cặp khiến lựa chọn hiện tại của nhóm kia không còn
 * hợp lệ nữa, tự động nhảy sang giá trị đầu tiên còn hợp lệ của nhóm đó thay vì để kẹt ở tổ hợp
 * không tồn tại (không có biến thể tương ứng -> giá/kho sẽ sai). */
function onPickCfg(groupKey, choiceIdx) {
  actions.setCfg(groupKey, choiceIdx);
  if (!sp.value) return;
  const allGroups = sp.value.cfg || [];
  const group = allGroups.find((g) => g.key === groupKey);
  if (!group || !group.linkedGroup) return;
  const siblings = allGroups.filter((g) => g.linkedGroup === group.linkedGroup && g.key !== groupKey);
  if (!siblings.length) return;
  const variants = sp.value._variants || [];
  const chosenLabel = group.ch[choiceIdx]?.l;
  siblings.forEach((sib) => {
    const curIdx = state.cfgSel[sib.key] || 0;
    const curLabel = sib.ch[curIdx]?.l;
    const stillValid = variants.some(
      (v) => v.options && v.options[group.label] === chosenLabel && v.options[sib.label] === curLabel,
    );
    if (stillValid) return;
    const firstValidIdx = sib.ch.findIndex((c) =>
      variants.some((v) => v.options && v.options[group.label] === chosenLabel && v.options[sib.label] === c.l),
    );
    if (firstValidIdx !== -1) actions.setCfg(sib.key, firstValidIdx);
  });
}

const specRows = computed(() => {
  if (!sp.value) return [];
  return sp.value.specs.map((r) => {
    const g = (sp.value.cfg || []).find((x) => x.label === r.k);
    return g ? { k: r.k, v: g.ch[state.cfgSel[g.key] || 0].l } : r;
  });
});

const detail = computed(() => {
  if (!sp.value) return null;
  const p = sp.value;
  return {
    brand: p.brand,
    name: p.name,
    hue: p.hue,
    catEn: catMeta[p.cat]?.en || '',
    catVn: catMeta[p.cat]?.vn || '',
    ratingText: (p.rating || 0).toFixed(1),
    reviews: p.reviews,
    desc:
      p.description ||
      'Sản phẩm chính hãng phân phối tại CNTTshop, bảo hành 24–36 tháng. Hỗ trợ trả góp 0%, giao hàng toàn quốc và lắp đặt miễn phí khu vực nội thành.',
    hasCfg: (p.cfg || []).length > 0,
    priceText: fmt(live.value),
    oldText: !upgraded.value && p.oldPrice ? fmt(p.oldPrice) : '',
    discount:
      !upgraded.value && p.oldPrice
        ? '-' + Math.round((1 - p.price / p.oldPrice) * 100) + '%'
        : '',
    installText: fmt(Math.round(live.value / 12 / 1000) * 1000),
    tokenText: '+' + silverTokensFor(live.value) + ' Xu CT',
    images: (p.images || [])
      .slice()
      .sort((a, b) => (b.isPrimary ? 1 : 0) - (a.isPrimary ? 1 : 0)),
  };
});

const mainImageUrl = computed(() => {
  const imgs = detail.value?.images || [];
  const img = imgs[selectedImageIdx.value] || imgs[0];
  return img ? resolveImageUrl(img.url) : '';
});

const descHtml = computed(() => renderDescription(detail.value?.desc || ''));

const related = computed(() => {
  if (!sp.value) return [];
  return products
    .filter((x) => x.cat === sp.value.cat && x.id !== sp.value.id)
    .slice(0, 4);
});

const promotions = computed(() => (sp.value && sp.value.promotions) || []);
const bundles = computed(() => (sp.value && sp.value.bundles) || []);

function onAdd(e) {
  flyToCart(e.currentTarget, mainImageUrl.value);
  actions.addToCart(sp.value.id, state.cfgSel);
}
async function onBuy() {
  await actions.addToCart(sp.value.id, state.cfgSel);
  actions.goCart();
}
</script>

<template>
  <main
    v-if="detail"
    style="max-width: 1800px; margin: 0 auto; padding: 24px 24px 70px"
  >
    <div style="font-size: 12.5px; color: var(--muted); margin-bottom: 18px">
      <span @click="actions.goHome" style="cursor: pointer">Trang chủ</span>
      <span style="color: var(--muted)">/</span>
      <span style="color: var(--muted2)">{{ detail.catVn }}</span>
      <span style="color: var(--muted)">/</span>
      <span style="color: var(--muted2)">{{ detail.name }}</span>
    </div>
    <div
      style="
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 36px;
        align-items: start;
      "
    >
      <!-- gallery -->
      <div style="position: sticky; top: 130px">
        <div
          :style="{ '--ph': detail.hue }"
          style="
            position: relative;
            aspect-ratio: 1/1;
            border-radius: 18px;
            overflow: hidden;
            background: linear-gradient(
              140deg,
              hsl(var(--ph) 45% 17%),
              hsl(var(--ph) 58% 9%)
            );
            border: 1px solid rgba(var(--line-rgb), 0.18);
            display: flex;
            align-items: center;
            justify-content: center;
          "
        >
          <Transition name="img-crossfade">
          <img
            v-if="mainImageUrl"
            :key="mainImageUrl"
            :src="mainImageUrl"
            :alt="detail.name"
            style="position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover"
          />
          <div v-else style="position: absolute; inset: 0; display: flex; align-items: center; justify-content: center">
            <div
              style="
                position: absolute;
                inset: 0;
                background: repeating-linear-gradient(
                  125deg,
                  rgba(255, 255, 255, 0.04) 0 2px,
                  transparent 2px 14px
                );
              "
            ></div>
            <div style="text-align: center">
              <div
                style="
                  font-family: 'Chakra Petch', sans-serif;
                  font-weight: 700;
                  font-size: 42px;
                  letter-spacing: 2px;
                  color: hsl(var(--ph) 70% 75% / 0.2);
                "
              >
                {{ detail.catEn }}
              </div>
              <div
                style="
                  font-family: 'Chakra Petch', monospace;
                  font-size: 10px;
                  letter-spacing: 2px;
                  color: rgba(200, 225, 255, 0.3);
                  margin-top: 6px;
                "
              >
                [ ẢNH SẢN PHẨM ]
              </div>
            </div>
          </div>
          </Transition>
        </div>
        <div
          v-if="detail.images.length > 1"
          style="
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            margin-top: 10px;
          "
        >
          <div
            v-for="(img, n) in detail.images"
            :key="img.url"
            @click="selectedImageIdx = n"
            :style="{ borderColor: selectedImageIdx === n ? accent : 'rgba(var(--line-rgb), 0.14)', transform: selectedImageIdx === n ? 'scale(1.04)' : 'scale(1)' }"
            style="
              aspect-ratio: 1/1;
              border-radius: 10px;
              overflow: hidden;
              border: 1px solid;
              cursor: pointer;
              transition: border-color 0.2s ease, transform 0.15s ease;
            "
          >
            <img :src="resolveImageUrl(img.url)" :alt="detail.name" style="width: 100%; height: 100%; object-fit: cover" />
          </div>
        </div>
      </div>
      <!-- info -->
      <div>
        <div
          :style="{ color: accent }"
          style="
            font-family: 'Chakra Petch', sans-serif;
            font-size: 11px;
            letter-spacing: 2px;
            font-weight: 600;
          "
        >
          {{ detail.brand }}
        </div>
        <h1
          style="
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-weight: 700;
            font-size: 30px;
            line-height: 1.25;
            margin: 8px 0 12px;
          "
        >
          {{ detail.name }}
        </h1>
        <div
          style="
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 20px;
          "
        >
          <span style="color: #ffcf4d; font-size: 13px"
            >★
            <span style="color: var(--text); font-weight: 600">{{
              detail.ratingText
            }}</span></span
          >
          <span style="color: var(--muted); font-size: 13px"
            >{{ detail.reviews }} đánh giá</span
          >
          <span style="color: var(--green); font-size: 13px; font-weight: 600"
            >● Còn hàng</span
          >
        </div>
        <div
          style="
            background: var(--card);
            border: 1px solid rgba(var(--line-rgb), 0.14);
            border-radius: 14px;
            padding: 20px;
            margin-bottom: 20px;
          "
        >
          <div style="display: flex; align-items: baseline; gap: 12px">
            <span
              :style="{ color: accent }"
              style="
                font-family: 'Chakra Petch', sans-serif;
                font-weight: 700;
                font-size: 34px;
              "
              >{{ detail.priceText }}</span
            >
            <span
              v-if="detail.oldText"
              style="
                font-size: 15px;
                color: var(--muted);
                text-decoration: line-through;
              "
              >{{ detail.oldText }}</span
            >
            <span
              v-if="detail.discount"
              style="
                font-family: 'Chakra Petch', sans-serif;
                font-weight: 700;
                font-size: 12px;
                background: #ff3b5c;
                color: #fff;
                padding: 4px 8px;
                border-radius: 6px;
              "
              >{{ detail.discount }}</span
            >
          </div>
          <div style="font-size: 12.5px; color: var(--muted); margin-top: 8px">
            Trả góp chỉ từ
            <span style="color: var(--muted2)">{{ detail.installText }}</span
            >/tháng · 0% lãi suất
          </div>
          <div style="font-size: 12.5px; color: #d9b34a; font-weight: 600; margin-top: 6px">
            🪙 {{ detail.tokenText }} khi mua sản phẩm này
          </div>
        </div>
        <div
          style="
            font-size: 14px;
            line-height: 1.65;
            color: var(--muted2);
            margin: 0 0 22px;
          "
          v-html="descHtml"
        ></div>

        <ul
          v-if="promotions.length"
          style="
            list-style: none;
            padding: 14px 18px;
            margin: 0 0 22px;
            background: rgba(0, 197, 126, 0.08);
            border: 1px solid rgba(0, 197, 126, 0.22);
            border-radius: 12px;
            display: flex;
            flex-direction: column;
            gap: 8px;
          "
        >
          <li
            v-for="(pr, i) in promotions"
            :key="i"
            style="font-size: 13px; color: #8ecfb0; display: flex; gap: 8px"
          >
            <span style="color: var(--green)">🎁</span> {{ pr }}
          </li>
        </ul>

        <div
          v-if="detail.hasCfg"
          style="
            margin-bottom: 24px;
            background: var(--card);
            border: 1px solid rgba(var(--line-rgb), 0.14);
            border-radius: 14px;
            padding: 18px 18px 20px;
          "
        >
          <div
            :style="{ color: accent }"
            style="
              font-family: 'Chakra Petch', sans-serif;
              font-size: 11px;
              letter-spacing: 2px;
              font-weight: 600;
              margin-bottom: 16px;
            "
          >
            TÙY CHỌN CẤU HÌNH
          </div>
          <div style="display: flex; flex-direction: column; gap: 16px">
            <div v-for="g in cfgGroups" :key="g.key">
              <div
                style="font-size: 12.5px; color: var(--muted2); margin-bottom: 9px"
              >
                {{ g.label }}
              </div>
              <div style="display: flex; flex-wrap: wrap; gap: 10px">
                <div
                  v-for="ch in g.choices"
                  :key="ch.idx"
                  @click="!ch.disabled && onPickCfg(g.key, ch.idx)"
                  :style="{
                    border: '1px solid ' + ch.bdr,
                    background: ch.bg,
                    opacity: ch.disabled ? 0.35 : 1,
                    cursor: ch.disabled ? 'not-allowed' : 'pointer',
                  }"
                  :title="ch.disabled ? 'Không có tổ hợp phù hợp với lựa chọn hiện tại' : ''"
                  style="
                    border-radius: 11px;
                    padding: 10px 14px;
                    min-width: 128px;
                    transition:
                      border-color 0.15s,
                      background 0.15s;
                  "
                >
                  <div
                    :style="{ color: ch.lblColor }"
                    style="font-size: 13px; font-weight: 600"
                  >
                    {{ ch.label }}
                  </div>
                  <div
                    :style="{ color: ch.dColor }"
                    style="font-size: 11.5px; font-weight: 600; margin-top: 3px"
                  >
                    {{ ch.deltaText }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div
          style="
            display: flex;
            gap: 14px;
            align-items: center;
            margin-bottom: 24px;
          "
        >
          <button
            @click="onAdd"
            :style="{
              border: '1px solid ' + accent,
              background: 'color-mix(in srgb, ' + accent + ' 14%, transparent)',
              color: accent,
            }"
            style="
              flex: 1;
              height: 54px;
              border-radius: 13px;
              font-family: 'Plus Jakarta Sans', sans-serif;
              font-weight: 700;
              font-size: 15px;
              cursor: pointer;
            "
          >
            Thêm vào giỏ
          </button>
          <button
            @click="onBuy"
            :style="{
              background: accent,
              boxShadow:
                '0 10px 26px color-mix(in srgb, ' +
                accent +
                ' 38%, transparent)',
            }"
            style="
              flex: 1;
              height: 54px;
              border: none;
              border-radius: 13px;
              color: var(--acc-ink);
              font-family: 'Plus Jakarta Sans', sans-serif;
              font-weight: 700;
              font-size: 15px;
              cursor: pointer;
            "
          >
            Mua ngay
          </button>
        </div>

        <div
          style="
            background: var(--card);
            border: 1px solid rgba(var(--line-rgb), 0.12);
            border-radius: 14px;
            overflow: hidden;
          "
        >
          <div
            :style="{ color: accent }"
            style="
              padding: 14px 18px;
              font-family: 'Chakra Petch', sans-serif;
              font-size: 11px;
              letter-spacing: 2px;
              font-weight: 600;
              border-bottom: 1px solid rgba(var(--line-rgb), 0.1);
            "
          >
            THÔNG SỐ KỸ THUẬT
          </div>
          <div
            v-for="(row, i) in specRows"
            :key="i"
            style="
              display: flex;
              padding: 12px 18px;
              border-bottom: 1px solid rgba(var(--line-rgb), 0.07);
              font-size: 13.5px;
            "
          >
            <div style="width: 42%; color: var(--muted)">{{ row.k }}</div>
            <div style="flex: 1; color: var(--text); font-weight: 500">
              {{ row.v }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- đánh giá từ khách hàng -->
    <section style="margin-top: 50px">
      <h2
        style="
          font-family: 'Plus Jakarta Sans', sans-serif;
          font-weight: 700;
          font-size: 22px;
          margin: 0 0 18px;
        "
      >
        Đánh giá từ khách hàng ({{ reviews.length }})
      </h2>
      <div v-if="reviewsLoading" style="color: var(--muted); padding: 20px 0">Đang tải...</div>
      <div
        v-else-if="!reviews.length"
        style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 40px 20px; text-align: center; color: var(--muted)"
      >
        Chưa có đánh giá nào cho sản phẩm này.
      </div>
      <div v-else style="display: flex; flex-direction: column; gap: 14px">
        <div
          v-for="r in reviews" :key="r.id"
          style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 18px 20px"
        >
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; flex-wrap: wrap; gap: 6px">
            <div style="display: flex; align-items: center; gap: 10px">
              <span style="font-size: 13.5px; font-weight: 600; color: var(--text)">{{ r.reviewerName }}</span>
              <span
                v-if="r.isVerified"
                style="font-size: 10.5px; color: var(--green,#22d39a); background: color-mix(in srgb, var(--green,#22d39a) 14%, transparent); padding: 2px 8px; border-radius: 20px"
              >
                ✓ Đã mua hàng
              </span>
            </div>
            <span style="font-size: 11px; color: var(--muted)">{{ fmtReviewDate(r.createdAt) }}</span>
          </div>
          <div style="margin-bottom: 8px">
            <span
              v-for="i in 5" :key="i"
              :style="{ color: i <= r.rating ? '#ffb43b' : 'var(--muted)' }"
              style="font-size: 14px"
              >★</span
            >
          </div>
          <div v-if="r.comment" style="font-size: 13px; color: var(--muted2); line-height: 1.6">{{ r.comment }}</div>
          <div v-if="r.photo1Url || r.photo2Url" style="display: flex; gap: 8px; margin-top: 10px">
            <a v-if="r.photo1Url" :href="API_ORIGIN + r.photo1Url" target="_blank" rel="noopener">
              <img :src="resolveImageUrl(r.photo1Url)" alt="Ảnh đánh giá" style="width: 84px; height: 84px; object-fit: cover; border-radius: 9px; cursor: zoom-in" />
            </a>
            <a v-if="r.photo2Url" :href="API_ORIGIN + r.photo2Url" target="_blank" rel="noopener">
              <img :src="resolveImageUrl(r.photo2Url)" alt="Ảnh đánh giá" style="width: 84px; height: 84px; object-fit: cover; border-radius: 9px; cursor: zoom-in" />
            </a>
          </div>
        </div>
      </div>
    </section>

    <!-- mua kèm -->
    <section v-if="bundles.length" style="margin-top: 50px">
      <h2
        style="
          font-family: 'Plus Jakarta Sans', sans-serif;
          font-weight: 700;
          font-size: 22px;
          margin: 0 0 18px;
        "
      >
        Thường được mua kèm
      </h2>
      <div
        style="
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
          gap: 18px;
        "
      >
        <ProductCard
          v-for="p in bundles"
          :key="p.id"
          :p="p"
          @open="actions.goDetail"
          @add="actions.addToCart"
        />
      </div>
    </section>

    <!-- related -->
    <section style="margin-top: 50px">
      <h2
        style="
          font-family: 'Plus Jakarta Sans', sans-serif;
          font-weight: 700;
          font-size: 22px;
          margin: 0 0 18px;
        "
      >
        Sản phẩm liên quan
      </h2>
      <div
        style="
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
          gap: 18px;
        "
      >
        <ProductCard
          v-for="p in related"
          :key="p.id"
          :p="p"
          @open="actions.goDetail"
          @add="actions.addToCart"
        />
      </div>
    </section>
  </main>
</template>

<style scoped>

.img-crossfade-enter-active,
.img-crossfade-leave-active {
  transition: opacity 0.25s ease;
}
.img-crossfade-enter-from,
.img-crossfade-leave-to {
  opacity: 0;
}
</style>
