<script setup>
import { ref, reactive, computed, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { getProductBySlug } from '../api/catalog';
import { catHue, catEn, formatPrice } from '../utils/catMeta';

const route = useRoute();
const router = useRouter();
const product = ref(null);
const loading = ref(true);
const mainImage = ref(null);
const selectedOptions = reactive({});

const hue = computed(() => catHue(product.value?.categoryName));
const ghost = computed(() => catEn(product.value?.categoryName));

const selectedVariant = computed(() => {
  const p = product.value;
  if (!p || !p.variants?.length) return null;
  if (!p.options?.length)
    return p.variants.find((v) => v.isDefault) || p.variants[0];
  return (
    p.variants.find((v) =>
      p.options.every((o) => v.options?.[o.name] === selectedOptions[o.name]),
    ) || null
  );
});
const discountPct = computed(() => {
  const v = selectedVariant.value;
  if (!v || !v.originalPrice || !v.price || v.originalPrice <= v.price)
    return 0;
  return Math.round((1 - v.price / v.originalPrice) * 100);
});

async function load() {
  loading.value = true;
  product.value = null;
  Object.keys(selectedOptions).forEach((k) => delete selectedOptions[k]);
  try {
    const p = await getProductBySlug(route.params.slug);
    product.value = p;
    const base = p.variants?.find((v) => v.isDefault) || p.variants?.[0];
    if (p.options?.length)
      p.options.forEach((o) => {
        selectedOptions[o.name] = base?.options?.[o.name] ?? o.values[0];
      });
    mainImage.value =
      p.images?.find((i) => i.isPrimary)?.url || p.images?.[0]?.url || null;
  } catch (e) {
    product.value = null;
  } finally {
    loading.value = false;
  }
}

function buy() {
  /* TODO: nối API giỏ hàng + JWT */
}

watch(() => route.params.slug, load, { immediate: true });
</script>

<template>
  <div v-if="loading" class="text-center py-5">
    <div class="load-ring" style="margin: 0 auto">
      <div class="ring"></div>
      <div class="core"></div>
    </div>
  </div>

  <div v-else-if="!product" class="empty-box">
    Không tìm thấy sản phẩm.
    <router-link to="/products" class="text-acc"
      >Quay lại danh sách</router-link
    >
  </div>

  <template v-else>
    <div class="crumb">
      <a @click="router.push('/')">Trang chủ</a><span class="sep">/</span>
      <span style="color: var(--ink-soft)">{{ product.categoryName }}</span
      ><span class="sep">/</span>
      <span style="color: var(--ink-soft)">{{ product.name }}</span>
    </div>

    <div class="detail-grid">
      <!-- GALLERY -->
      <div class="gal">
        <div class="gal-main" :style="{ '--ph': hue }">
          <img v-if="mainImage" :src="mainImage" :alt="product.name" />
          <div
            v-else
            class="big"
            style="
              font-family: 'Chakra Petch';
              font-weight: 700;
              font-size: 42px;
              letter-spacing: 2px;
              color: hsl(var(--ph) 70% 75% / 0.2);
            "
          >
            {{ ghost }}
          </div>
        </div>
        <div v-if="product.images?.length" class="gal-thumbs">
          <div
            v-for="(img, i) in product.images.slice(0, 4)"
            :key="i"
            class="gal-thumb"
            :style="{ '--ph': hue }"
            @click="mainImage = img.url"
          >
            <img :src="img.url" :alt="product.name" />
          </div>
        </div>
      </div>

      <!-- INFO -->
      <div class="detail-info">
        <div class="brand-lbl">{{ product.categoryName }}</div>
        <h1>{{ product.name }}</h1>
        <div style="margin-bottom: 18px">
          <span
            v-if="(selectedVariant?.stock ?? 0) > 0"
            style="color: #2bd47e; font-size: 13px; font-weight: 600"
            >● Còn hàng ({{ selectedVariant.stock }})</span
          >
          <span v-else style="color: #ff5d7a; font-size: 13px; font-weight: 600"
            >● Tạm hết hàng</span
          >
        </div>

        <div class="price-box">
          <div
            style="
              display: flex;
              align-items: baseline;
              gap: 12px;
              flex-wrap: wrap;
            "
          >
            <span class="now">{{ formatPrice(selectedVariant?.price) }}</span>
            <span v-if="discountPct > 0" class="old">{{
              formatPrice(selectedVariant.originalPrice)
            }}</span>
            <span v-if="discountPct > 0" class="disc">-{{ discountPct }}%</span>
          </div>
          <div style="font-size: 12.5px; color: var(--muted); margin-top: 8px">
            Trả góp 0% lãi suất qua thẻ tín dụng & công ty tài chính.
          </div>
        </div>

        <p
          style="
            font-size: 14px;
            line-height: 1.65;
            color: var(--ink-soft);
            margin: 0 0 22px;
            white-space: pre-line;
          "
        >
          {{ product.description || 'Đang cập nhật mô tả.' }}
        </p>

        <!-- TÙY CHỌN CẤU HÌNH (variant thật) -->
        <div v-if="product.options?.length" class="cfg-box">
          <div class="eyebrow">TÙY CHỌN CẤU HÌNH</div>
          <div v-for="o in product.options" :key="o.name" class="cfg-group">
            <div class="lbl">{{ o.name }}</div>
            <div class="cfg-choices">
              <div
                v-for="val in o.values"
                :key="val"
                class="cfg-choice"
                :class="{ on: selectedOptions[o.name] === val }"
                @click="selectedOptions[o.name] = val"
              >
                {{ val }}
              </div>
            </div>
          </div>
        </div>

        <div style="display: flex; gap: 14px; margin-bottom: 24px">
          <button
            class="btn-ghost"
            style="flex:1;height:54px;text-dark"
            :disabled="!selectedVariant"
            @click="buy"
          >
            Thêm vào giỏ
          </button>
          <button
            class="btn-acc"
            style="flex: 1; height: 54px"
            :disabled="!selectedVariant"
            @click="buy"
          >
            Mua ngay
          </button>
        </div>

        <div v-if="product.specs?.length" class="spec-table">
          <div class="head">THÔNG SỐ KỸ THUẬT</div>
          <div v-for="(s, i) in product.specs" :key="i" class="spec-row">
            <div class="k">{{ s.key }}</div>
            <div class="v">{{ s.value }}</div>
          </div>
        </div>
      </div>
    </div>
  </template>
</template>
