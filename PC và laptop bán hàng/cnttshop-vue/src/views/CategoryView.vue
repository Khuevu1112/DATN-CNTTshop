<script setup>
import { computed } from 'vue'
import { catMeta, fmt } from '../data/products.js'
import { state, actions, accent, products } from '../store.js'
import ProductCard from '../components/ProductCard.vue'

const catTitle = computed(() => state.cat === 'all' ? 'Tất cả sản phẩm' : catMeta[state.cat].vn)

const base = computed(() => products.filter(p => state.cat === 'all' ? true : p.cat === state.cat))

const allBrands = computed(() => base.value.map(p => p.brand).filter((v, i, a) => a.indexOf(v) === i))

const sorters = {
  pop:  (a, b) => b.rating - a.rating,
  low:  (a, b) => a.price - b.price,
  high: (a, b) => b.price - a.price,
  disc: (a, b) => ((b.oldPrice ? b.oldPrice - b.price : 0) - (a.oldPrice ? a.oldPrice - a.price : 0))
}

const list = computed(() => {
  let l = base.value.slice()
  if (state.q.trim()) {
    const q = state.q.toLowerCase()
    l = l.filter(p => p.name.toLowerCase().includes(q) || p.brand.toLowerCase().includes(q))
  }
  if (state.brandFilter.length) l = l.filter(p => state.brandFilter.includes(p.brand))
  l = l.filter(p => p.price <= state.priceMax)
  return l.sort(sorters[state.sort] || sorters.pop)
})

const brands = computed(() => allBrands.value.map(b => ({
  name: b, active: state.brandFilter.includes(b)
})))

const priceMaxText = computed(() => fmt(state.priceMax))
</script>

<template>
  <main style="max-width:1800px; margin:0 auto; padding:24px 24px 70px;">
    <div style="font-size:12.5px; color:#7e98b6; margin-bottom:14px;"><span @click="actions.goHome" style="cursor:pointer;">Trang chủ</span> <span style="color:#4a627e;">/</span> <span style="color:#cfdceb;">{{ catTitle }}</span></div>
    <div style="display:flex; align-items:baseline; gap:12px; margin-bottom:22px;">
      <h1 style="font-family:'Be Vietnam Pro',sans-serif; font-weight:700; font-size:28px; margin:0;">{{ catTitle }}</h1>
      <span style="font-size:13px; color:#7e98b6;">{{ list.length }} sản phẩm</span>
    </div>
    <div style="display:grid; grid-template-columns:248px 1fr; gap:26px; align-items:start;">
      <!-- filters -->
      <aside style="position:sticky; top:130px; background:#0a2138; border:1px solid rgba(120,170,230,0.12); border-radius:14px; padding:20px;">
        <div :style="{ color: accent }" style="font-family:'Chakra Petch',sans-serif; font-size:11px; letter-spacing:2px; font-weight:600; margin-bottom:14px;">BỘ LỌC</div>
        <div style="margin-bottom:22px;">
          <label style="display:block; font-size:12.5px; color:#9fb6d2; margin-bottom:8px;">Sắp xếp</label>
          <select :value="state.sort" @change="actions.setSort($event.target.value)" style="width:100%; height:40px; padding:0 12px; border-radius:10px; background:#0c2742; color:#e8f1fc; border:1px solid rgba(120,170,230,0.2); font-family:'Be Vietnam Pro',sans-serif; font-size:13px; cursor:pointer;">
            <option value="pop">Phổ biến nhất</option>
            <option value="low">Giá thấp → cao</option>
            <option value="high">Giá cao → thấp</option>
            <option value="disc">Giảm giá nhiều</option>
          </select>
        </div>
        <div style="margin-bottom:22px;">
          <label style="display:block; font-size:12.5px; color:#9fb6d2; margin-bottom:10px;">Thương hiệu</label>
          <div style="display:flex; flex-direction:column; gap:9px;">
            <div v-for="b in brands" :key="b.name" @click="actions.toggleBrand(b.name)" style="display:flex; align-items:center; gap:10px; cursor:pointer;">
              <span :style="{ background: b.active ? accent : 'transparent' }" style="width:18px; height:18px; border-radius:5px; border:1px solid rgba(120,170,230,0.3); display:flex; align-items:center; justify-content:center; flex:none;">
                <span v-if="b.active" style="color:#04121f; font-size:12px; font-weight:700;">✓</span>
              </span>
              <span style="font-size:13px; color:#d3e0ef;">{{ b.name }}</span>
            </div>
          </div>
        </div>
        <div>
          <label style="display:block; font-size:12.5px; color:#9fb6d2; margin-bottom:8px;">Giá tối đa: <span :style="{ color: accent }" style="font-weight:600;">{{ priceMaxText }}</span></label>
          <input type="range" min="2000000" max="70000000" step="500000" :value="state.priceMax" @input="actions.setPriceMax($event.target.value)" :style="{ accentColor: accent }" style="width:100%; cursor:pointer;" />
        </div>
      </aside>
      <!-- grid -->
      <div>
        <div v-if="list.length" style="display:grid; grid-template-columns:repeat(auto-fill,minmax(220px,1fr)); gap:18px;">
          <ProductCard v-for="p in list" :key="p.id" :p="p" @open="actions.goDetail" @add="actions.addToCart" />
        </div>
        <div v-else style="padding:70px 20px; text-align:center; color:#7e98b6; background:#0a2138; border-radius:14px; border:1px solid rgba(120,170,230,0.12);">
          <div style="font-size:34px; margin-bottom:12px;">🔍</div>
          <div style="font-size:15px; color:#cfdceb;">Không tìm thấy sản phẩm phù hợp</div>
          <div style="font-size:13px; margin-top:6px;">Thử bỏ bớt bộ lọc hoặc tăng mức giá.</div>
        </div>
      </div>
    </div>
  </main>
</template>
