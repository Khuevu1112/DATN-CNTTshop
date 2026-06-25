<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { catHue, catEn, formatPrice } from '../utils/catMeta'

const props = defineProps({ product: { type: Object, required: true } })
const router = useRouter()

const hue = computed(() => catHue(props.product.categoryName))
const ghost = computed(() => catEn(props.product.categoryName))
const eyebrow = computed(() => props.product.brandName || props.product.categoryName)
const discountPct = computed(() => {
  const p = props.product
  if (!p.originalPrice || !p.price || p.originalPrice <= p.price) return 0
  return Math.round((1 - p.price / p.originalPrice) * 100)
})

function goDetail() { router.push(`/product/${props.product.slug}`) }
function onAdd() { router.push(`/product/${props.product.slug}`) }
</script>

<template>
  <div class="pcard" :style="{ '--ph': hue }" @click="goDetail">
    <div class="pcard-img">
      <span v-if="discountPct > 0" class="badge-hot">-{{ discountPct }}%</span>
      <img v-if="product.imageUrl" :src="product.imageUrl" :alt="product.name">
      <span v-else class="ph-text">{{ ghost }}</span>
    </div>

    <div class="pcard-body">
      <div class="pcard-brand">{{ eyebrow }}</div>
      <div class="pcard-name">{{ product.name }}</div>

      <div class="pcard-chips" v-if="product.chips && product.chips.length">
        <span class="chip" v-for="(c, i) in product.chips" :key="i">{{ c }}</span>
      </div>

      <div class="pcard-rating" v-if="product.reviewCount">
        ★ <b>{{ product.rating?.toFixed(1) }}</b>
        <span class="rcount">({{ product.reviewCount }})</span>
      </div>

      <div class="pcard-foot">
        <div>
          <div class="pcard-price">{{ formatPrice(product.price) }}</div>
          <div v-if="discountPct > 0" class="pcard-old">{{ formatPrice(product.originalPrice) }}</div>
        </div>
        <button class="pcard-add" title="Xem / thêm" @click.stop="onAdd">+</button>
      </div>
    </div>
  </div>
</template>
