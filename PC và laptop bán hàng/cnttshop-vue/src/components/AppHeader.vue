<script setup>
import { computed } from 'vue'
import { catMeta } from '../data/products.js'
import { state, actions, accent, cartCount } from '../store.js'

const navItems = computed(() => {
  const items = [{ label: 'Trang chủ', onClick: actions.goHome, active: state.route === 'home' }]
  Object.keys(catMeta).forEach(k => {
    items.push({
      label: catMeta[k].vn,
      onClick: () => actions.goCat(k),
      active: state.route === 'category' && state.cat === k
    })
  })
  return items
})

const modeIcon = computed(() => state.mode === 'light' ? '🌙' : '☀️')

function onSearchKey(e) { if (e.key === 'Enter') actions.onSearchEnter() }
</script>

<template>
  <header style="position:sticky; top:0; z-index:50; backdrop-filter:blur(14px); background:rgba(7,18,33,0.84); border-bottom:1px solid rgba(120,170,230,0.14);">
    <div style="max-width:1800px; margin:0 auto; padding:14px 24px; display:flex; align-items:center; gap:22px;">
      <div @click="actions.goHome" style="display:flex; align-items:center; gap:11px; cursor:pointer; flex:none;">
        <div :style="{ background: 'linear-gradient(135deg, ' + accent + ', #0b4f9e)', boxShadow: '0 0 18px color-mix(in srgb, ' + accent + ' 55%, transparent)' }" style="width:30px; height:30px; transform:rotate(45deg); border-radius:7px;"></div>
        <div style="font-family:'Chakra Petch',sans-serif; font-weight:700; font-size:20px; letter-spacing:0.5px; line-height:1;">CNTT<span :style="{ color: accent }">shop</span></div>
      </div>
      <div style="flex:1; max-width:520px; display:flex; align-items:center; gap:9px; background:#0a2138; border:1px solid rgba(120,170,230,0.18); border-radius:11px; padding:0 14px; height:42px;">
        <span style="color:#5f7a9c; font-size:15px;">⌕</span>
        <input :value="state.q" @input="actions.setQ($event.target.value)" @keydown="onSearchKey" placeholder="Tìm laptop, PC, RTX 4070, CPU..." style="flex:1; background:transparent; border:none; color:#e8f1fc; font-size:13.5px; font-family:'Be Vietnam Pro',sans-serif;" />
      </div>
      <div style="flex:1;"></div>
      <div style="display:flex; align-items:center; gap:6px; flex:none; padding:0 4px;">
        <button @click="actions.setTheme('cyan')" title="Cyan" style="width:16px; height:16px; border-radius:50%; border:1px solid rgba(255,255,255,0.25); background:#00e5ff; cursor:pointer; padding:0;"></button>
        <button @click="actions.setTheme('magenta')" title="Magenta" style="width:16px; height:16px; border-radius:50%; border:1px solid rgba(255,255,255,0.25); background:#ff45e0; cursor:pointer; padding:0;"></button>
      </div>
      <button @click="actions.toggleMode" title="Đổi giao diện sáng / tối" style="flex:none; width:42px; height:42px; border-radius:11px; border:1px solid rgba(120,170,230,0.2); background:#0a2138; color:#e8f1fc; cursor:pointer; font-size:18px; line-height:1; display:flex; align-items:center; justify-content:center;">{{ modeIcon }}</button>
      <button @click="actions.goCart" :style="{ background: 'color-mix(in srgb, ' + accent + ' 12%, #0a2138)' }" style="position:relative; flex:none; height:42px; display:flex; align-items:center; gap:9px; padding:0 16px; border-radius:11px; border:1px solid rgba(120,170,230,0.2); color:#e8f1fc; cursor:pointer; font-family:'Be Vietnam Pro',sans-serif; font-weight:600; font-size:13.5px;">
        <span style="font-size:17px;">🛒</span> Giỏ hàng
        <span v-if="cartCount > 0" :style="{ background: accent }" style="position:absolute; top:-7px; right:-7px; min-width:20px; height:20px; padding:0 5px; border-radius:10px; color:#04121f; font-family:'Chakra Petch',sans-serif; font-weight:700; font-size:11px; display:flex; align-items:center; justify-content:center;">{{ cartCount }}</span>
      </button>
    </div>
    <nav style="border-top:1px solid rgba(120,170,230,0.08);">
      <div style="max-width:1800px; margin:0 auto; padding:0 24px; display:flex; align-items:center; gap:4px; height:46px; overflow-x:auto;">
        <div v-for="(item, i) in navItems" :key="i" @click="item.onClick" :style="{ color: item.active ? '#ffffff' : '#9fb6d2' }" style="position:relative; height:46px; display:flex; align-items:center; padding:0 14px; cursor:pointer; white-space:nowrap; font-size:13.5px; font-weight:500;">
          {{ item.label }}
          <span v-if="item.active" :style="{ background: accent, boxShadow: '0 0 10px ' + accent }" style="position:absolute; left:14px; right:14px; bottom:0; height:2px;"></span>
        </div>
        <div style="flex:1;"></div>
        <div style="display:flex; align-items:center; gap:7px; color:#ff5d7a; font-size:12.5px; font-weight:600; white-space:nowrap;"><span style="font-size:14px;">⚡</span> Trả góp 0%</div>
      </div>
    </nav>
  </header>
</template>
