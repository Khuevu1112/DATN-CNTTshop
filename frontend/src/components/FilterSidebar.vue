<script setup>
const props = defineProps({
  categories: { type: Array, default: () => [] },
  filters: { type: Object, required: true },
  showCategories: { type: Boolean, default: true }
})

const presets = [
  { key: '0-5',   label: 'Dưới 5 triệu',  min: 0,        max: 5000000 },
  { key: '5-10',  label: '5 – 10 triệu',  min: 5000000,  max: 10000000 },
  { key: '10-20', label: '10 – 20 triệu', min: 10000000, max: 20000000 },
  { key: '20-40', label: '20 – 40 triệu', min: 20000000, max: 40000000 },
  { key: '40+',   label: 'Trên 40 triệu', min: 40000000, max: null }
]

function pickPreset(p) {
  if (props.filters.pricePreset === p.key) { clearPrice(); return }
  props.filters.pricePreset = p.key
  props.filters.priceMin = p.min
  props.filters.priceMax = p.max
}
function onCustom() { props.filters.pricePreset = '' }
function clearPrice() { props.filters.pricePreset = ''; props.filters.priceMin = null; props.filters.priceMax = null }
function toggleCat(name) {
  const arr = props.filters.categories
  const i = arr.indexOf(name)
  if (i >= 0) arr.splice(i, 1); else arr.push(name)
}
function clearAll() { props.filters.categories.splice(0); clearPrice() }
</script>

<template>
  <div class="side-card">
    <div class="side-card-head"><i class="bi bi-funnel-fill me-2"></i>Bộ lọc sản phẩm</div>

    <div v-if="showCategories && categories.length" class="filter-group">
      <div class="filter-title">Danh mục</div>
      <label v-for="c in categories" :key="c.id" class="filter-opt">
        <input type="checkbox" :checked="filters.categories.includes(c.name)" @change="toggleCat(c.name)">
        <span>{{ c.name }}</span>
      </label>
    </div>

    <div class="filter-group">
      <div class="filter-title">Khoảng giá</div>
      <label v-for="p in presets" :key="p.key" class="filter-opt">
        <input type="radio" name="price" :checked="filters.pricePreset === p.key" @click="pickPreset(p)">
        <span>{{ p.label }}</span>
      </label>
      <div class="price-inputs">
        <input class="form-control form-control-sm" type="number" min="0" placeholder="Từ"
               v-model.number="filters.priceMin" @input="onCustom">
        <span>—</span>
        <input class="form-control form-control-sm" type="number" min="0" placeholder="Đến"
               v-model.number="filters.priceMax" @input="onCustom">
      </div>
    </div>

    <div class="filter-group">
      <button class="btn btn-outline-navy btn-sm w-100" @click="clearAll">
        <i class="bi bi-x-circle me-1"></i>Xoá bộ lọc
      </button>
    </div>
  </div>

  <div class="side-card">
    <div class="promo-card promo-a">
      <h5 class="mb-1">Trả góp 0%</h5>
      <p class="small mb-0">Duyệt nhanh qua thẻ tín dụng & công ty tài chính.</p>
    </div>
  </div>
</template>
