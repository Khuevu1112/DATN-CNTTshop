<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getProducts, getCategories } from '../api/catalog'
import { formatPrice } from '../utils/catMeta'
import ProductCard from '../components/ProductCard.vue'

const route = useRoute()
const router = useRouter()
const products = ref([])
const categories = ref([])
const loading = ref(true)
const page = ref(1)
const perPage = 12

const categorySlug = computed(() => route.params.slug || null)
const currentCategory = computed(() => categories.value.find(c => c.slug === categorySlug.value))
const title = computed(() =>
  currentCategory.value ? currentCategory.value.name
    : (route.query.keyword ? `Kết quả cho "${route.query.keyword}"` : 'Tất cả sản phẩm'))

const filters = reactive({ categories: [], priceMax: 70000000, sort: 'pop' })

getCategories().then(c => (categories.value = c)).catch(() => {})

async function load() {
  loading.value = true
  try {
    products.value = await getProducts({
      categorySlug: categorySlug.value || undefined,
      keyword: route.query.keyword || undefined
    })
  } catch (e) { products.value = [] } finally { loading.value = false }
}

function discPct(p) {
  if (!p.originalPrice || !p.price || p.originalPrice <= p.price) return 0
  return Math.round((1 - p.price / p.originalPrice) * 100)
}

const displayed = computed(() => {
  let list = products.value.filter(p => p.price == null || p.price <= filters.priceMax)
  if (filters.categories.length) list = list.filter(p => filters.categories.includes(p.categoryName))
  list = [...list]
  switch (filters.sort) {
    case 'low':  list.sort((a, b) => (a.price || 0) - (b.price || 0)); break
    case 'high': list.sort((a, b) => (b.price || 0) - (a.price || 0)); break
    case 'disc': list.sort((a, b) => discPct(b) - discPct(a)); break
  }
  return list
})
const totalPages = computed(() => Math.max(1, Math.ceil(displayed.value.length / perPage)))
const paged = computed(() => displayed.value.slice((page.value - 1) * perPage, page.value * perPage))

function toggleCat(name) {
  const i = filters.categories.indexOf(name)
  if (i >= 0) filters.categories.splice(i, 1); else filters.categories.push(name)
}

watch(() => route.fullPath, () => {
  page.value = 1
  filters.categories.splice(0)
  filters.priceMax = route.query.max ? Number(route.query.max) : 70000000
  load()
}, { immediate: true })
watch(() => displayed.value.length, () => { if (page.value > totalPages.value) page.value = 1 })
</script>

<template>
  <div class="crumb">
    <a @click="router.push('/')">Trang chủ</a><span class="sep">/</span><span style="color:var(--ink-soft)">{{ title }}</span>
  </div>
  <div class="list-head">
    <h1>{{ title }}</h1>
    <span class="count">{{ displayed.length }} sản phẩm</span>
  </div>

  <div class="list-grid">
    <!-- BỘ LỌC -->
    <aside class="filter-aside">
      <div class="eyebrow">BỘ LỌC</div>

      <div class="filter-block">
        <label>Sắp xếp</label>
        <select v-model="filters.sort" class="filter-select">
          <option value="pop">Phổ biến nhất</option>
          <option value="low">Giá thấp → cao</option>
          <option value="high">Giá cao → thấp</option>
          <option value="disc">Giảm giá nhiều</option>
        </select>
      </div>

      <div v-if="!categorySlug && categories.length" class="filter-block">
        <label>Danh mục</label>
        <div v-for="c in categories" :key="c.id" class="filter-opt" @click="toggleCat(c.name)">
          <span class="box" :class="{ on: filters.categories.includes(c.name) }"></span>
          <span>{{ c.name }}</span>
        </div>
      </div>

      <div class="filter-block">
        <label>Giá tối đa: <span class="text-acc" style="font-weight:600">{{ formatPrice(filters.priceMax) }}</span></label>
        <input class="range" type="range" min="2000000" max="70000000" step="500000" v-model.number="filters.priceMax">
      </div>
    </aside>

    <!-- LƯỚI -->
    <div>
      <div v-if="loading" class="text-center py-5">
        <div class="load-ring" style="margin:0 auto"><div class="ring"></div><div class="core"></div></div>
      </div>

      <div v-else-if="displayed.length === 0" class="empty-box">
        <div style="font-size:34px;margin-bottom:12px">🔍</div>
        <div style="font-size:15px;color:#cfdceb">Không tìm thấy sản phẩm phù hợp</div>
        <div style="font-size:13px;margin-top:6px">Thử bỏ bớt bộ lọc hoặc tăng mức giá.</div>
      </div>

      <template v-else>
        <div class="pgrid">
          <ProductCard v-for="p in paged" :key="p.id" :product="p" />
        </div>
        <div v-if="totalPages > 1" class="pager">
          <button :disabled="page === 1" @click="page--">‹</button>
          <button v-for="n in totalPages" :key="n" :class="{ active: n === page }" @click="page = n">{{ n }}</button>
          <button :disabled="page === totalPages" @click="page++">›</button>
        </div>
      </template>
    </div>
  </div>
</template>
