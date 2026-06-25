<script setup>
import { computed } from 'vue'
import { catMeta, fmt } from '../data/products.js'
import { accent } from '../store.js'

const props = defineProps({ p: { type: Object, required: true } })
const emit = defineEmits(['open', 'add'])

const catEn = computed(() => catMeta[props.p.cat].en)
const priceText = computed(() => fmt(props.p.price))
const oldText = computed(() => props.p.oldPrice ? fmt(props.p.oldPrice) : '')
const discount = computed(() => props.p.oldPrice ? '-' + Math.round((1 - props.p.price / props.p.oldPrice) * 100) + '%' : '')
const ratingText = computed(() => props.p.rating.toFixed(1))
const chips = computed(() => props.p.specs.slice(0, 3).map(s => s.v))

const cardStyle = computed(() => ({ '--acc': accent.value, '--ph': props.p.hue }))

function onAdd(e) { e.stopPropagation(); emit('add', props.p.id) }
</script>

<template>
  <div
    class="pcard"
    :style="cardStyle"
    @click="emit('open', p.id)"
    style="cursor:pointer; background:linear-gradient(180deg,#0c2742,#0a2138); border:1px solid rgba(120,170,230,0.14); border-radius:14px; overflow:hidden; display:flex; flex-direction:column; transition:transform .18s ease, border-color .18s ease, box-shadow .18s ease; height:100%;"
  >
    <div style="position:relative; aspect-ratio:4/3; background:linear-gradient(135deg, hsl(var(--ph) 42% 16%), hsl(var(--ph) 55% 9%)); overflow:hidden; display:flex; align-items:center; justify-content:center;">
      <div style="position:absolute; inset:0; background:repeating-linear-gradient(125deg, rgba(255,255,255,0.045) 0 2px, transparent 2px 12px);"></div>
      <div style="font-family:'Chakra Petch',sans-serif; font-weight:700; font-size:34px; letter-spacing:3px; color:hsl(var(--ph) 65% 72% / 0.16);">{{ catEn }}</div>
      <div style="position:absolute; bottom:9px; left:0; right:0; text-align:center; font-family:'Chakra Petch',monospace; font-size:9px; letter-spacing:1.5px; color:rgba(200,225,255,0.30);">[ ẢNH SẢN PHẨM ]</div>
      <div v-if="p.badge" style="position:absolute; top:10px; left:10px; font-family:'Chakra Petch',sans-serif; font-weight:700; font-size:10px; letter-spacing:1px; padding:4px 8px; border-radius:6px; background:var(--acc); color:#04121f;">{{ p.badge }}</div>
      <div v-if="discount" style="position:absolute; top:10px; right:10px; font-family:'Chakra Petch',sans-serif; font-weight:700; font-size:11px; padding:4px 8px; border-radius:6px; background:#ff3b5c; color:#fff;">{{ discount }}</div>
    </div>
    <div style="padding:14px 14px 16px; display:flex; flex-direction:column; gap:9px; flex:1;">
      <div style="font-family:'Chakra Petch',sans-serif; font-size:10px; letter-spacing:1.5px; color:var(--acc); font-weight:600; text-transform:uppercase;">{{ p.brand }}</div>
      <div style="font-family:'Be Vietnam Pro',sans-serif; font-weight:600; font-size:14.5px; line-height:1.35; color:#e8f1fc; display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; min-height:39px;">{{ p.name }}</div>
      <div style="display:flex; flex-wrap:wrap; gap:5px;">
        <span v-for="(chip, i) in chips" :key="i" style="font-family:'Be Vietnam Pro',sans-serif; font-size:10.5px; color:#9fb6d2; background:rgba(120,170,230,0.08); border:1px solid rgba(120,170,230,0.12); padding:3px 7px; border-radius:5px;">{{ chip }}</span>
      </div>
      <div style="display:flex; align-items:center; gap:5px; font-size:11.5px; color:#ffcf4d;">★ <span style="color:#cfdceb; font-weight:600;">{{ ratingText }}</span><span style="color:#6e87a6;">({{ p.reviews }})</span></div>
      <div style="margin-top:auto; display:flex; align-items:flex-end; justify-content:space-between; gap:8px; padding-top:4px;">
        <div>
          <div style="font-family:'Chakra Petch',sans-serif; font-weight:700; font-size:18px; color:#ffffff;">{{ priceText }}</div>
          <div v-if="oldText" style="font-size:11px; color:#6e87a6; text-decoration:line-through;">{{ oldText }}</div>
        </div>
        <button @click="onAdd" title="Thêm vào giỏ" class="add-btn" style="flex:none; width:40px; height:40px; border:none; border-radius:10px; background:color-mix(in srgb, var(--acc) 16%, #0c2742); color:var(--acc); font-size:20px; line-height:1; cursor:pointer; display:flex; align-items:center; justify-content:center; transition:background .15s, color .15s;">+</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.pcard:hover {
  transform: translateY(-4px);
  border-color: var(--acc) !important;
  box-shadow: 0 14px 34px rgba(0,0,0,0.45), 0 0 0 1px color-mix(in srgb, var(--acc) 40%, transparent);
}
.add-btn:hover {
  background: var(--acc) !important;
  color: #04121f !important;
}
</style>
