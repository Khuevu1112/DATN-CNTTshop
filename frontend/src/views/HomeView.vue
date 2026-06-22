<script setup>
import { ref, computed, onMounted } from 'vue'
import { getCategories, getProducts } from '../api/catalog'
import { catEn, catHue } from '../utils/catMeta'
import ProductCard from '../components/ProductCard.vue'

const categories = ref([])
const products = ref([])
const loading = ref(true)

const tiles = computed(() => categories.value.slice(0, 5))
const featured = computed(() => products.value.slice(0, 10))

const trust = [
  { ico: '🚚', t: 'Giao hàng toàn quốc', s: 'Đóng gói chống sốc' },
  { ico: '🛡️', t: 'Bảo hành tới 36 tháng', s: '1 đổi 1 trong 30 ngày' },
  { ico: '⚡', t: 'Trả góp 0%', s: 'Duyệt nhanh qua thẻ' },
  { ico: '🎧', t: 'Hỗ trợ 24/7', s: 'Hotline 1900 1903' }
]

onMounted(async () => {
  try {
    const [c, p] = await Promise.all([getCategories(), getProducts()])
    categories.value = c; products.value = p
  } catch (e) { console.error(e) } finally { loading.value = false }
})
</script>

<template>
  <!-- HERO -->
  <section class="hero">
    <div class="hero-blob"></div>
    <div class="hero-grid">
      <div>
        <div class="eyebrow">CNTTSHOP // BUILD YOUR POWER</div>
        <h1>Sức mạnh<br>không giới hạn.</h1>
        <p>PC Gaming dựng sẵn, laptop RTX & linh kiện chính hãng. Test kỹ trước khi giao, bảo hành tới 36 tháng, trả góp 0%.</p>
        <div style="display:flex; gap:12px; flex-wrap:wrap">
          <router-link to="/products" class="btn-acc">Mua PC Gaming →</router-link>
          <router-link to="/products" class="btn-ghost">Xem Laptop</router-link>
        </div>
        <div class="hero-stats">
          <div><div class="num">12K+</div><div class="lbl">Đơn đã giao</div></div>
          <div><div class="num">4.9★</div><div class="lbl">Đánh giá khách</div></div>
          <div><div class="num">36th</div><div class="lbl">Bảo hành tối đa</div></div>
        </div>
      </div>
      <div class="hero-art"><div class="big">PC BUILD</div></div>
    </div>
  </section>

  <!-- CATEGORY TILES -->
  <section class="cat-tiles">
    <router-link v-for="c in tiles" :key="c.id" :to="`/category/${c.slug}`" class="cat-tile"
                 :style="{ '--ph': catHue(c.name) }">
      <div class="en">{{ catEn(c.name) }}</div>
      <div class="vn">{{ c.name }}</div>
      <div class="more">Xem ngay →</div>
    </router-link>
  </section>

  <!-- FEATURED -->
  <div class="sec-head">
    <div>
      <div class="eyebrow">BEST SELLERS</div>
      <h2>Sản phẩm bán chạy</h2>
    </div>
    <router-link to="/products" class="btn-ghost" style="padding:9px 18px">Xem tất cả</router-link>
  </div>

  <div v-if="loading" class="text-center py-5"><div class="load-ring" style="margin:0 auto"><div class="ring"></div><div class="core"></div></div></div>

  <template v-else>
    <div v-if="featured.length" class="pgrid">
      <ProductCard v-for="p in featured" :key="p.id" :product="p" />
    </div>
    <div v-else class="empty-box">Chưa có sản phẩm nào hiển thị. Hãy thêm sản phẩm (is_active = 1) ở trang quản trị.</div>

    <!-- PROMO -->
    <section class="promo-band" @click="$router.push('/products')">
      <div>
        <div class="eyebrow">CNTT BUILD SERVICE</div>
        <h2>PC dựng sẵn — bật là chiến</h2>
        <p>Đi dây gọn gàng, test stress 24h, cài sẵn Windows & driver. Đổi cấu hình theo nhu cầu.</p>
      </div>
      <div class="cta">Khám phá build →</div>
    </section>

    <!-- TRUST -->
    <section class="trust">
      <div v-for="(t, i) in trust" :key="i" class="trust-item">
        <div class="ico">{{ t.ico }}</div>
        <div><div class="t">{{ t.t }}</div><div class="s">{{ t.s }}</div></div>
      </div>
    </section>
  </template>
</template>
