<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { storeToRefs } from 'pinia'
import { getCategories } from '../api/catalog'
import { useAuthStore } from '../stores/auth'
import { ACCENTS, applyAccent } from '../composables/theme'

const categories = ref([])
const keyword = ref('')
const router = useRouter()
const auth = useAuthStore()
const { isAuthenticated, user } = storeToRefs(auth)

onMounted(async () => {
  try { categories.value = await getCategories() } catch (e) { console.error(e) }
})

function search() {
  router.push({ name: 'products', query: keyword.value ? { keyword: keyword.value } : {} })
}
function logout() { auth.logout(); router.push('/') }
</script>

<template>
  <header class="site-header">
    <div class="wrap hdr-top">
      <router-link to="/" class="brand">
        <span class="brand-logo"></span>
        <span class="brand-text">CNTT<span>shop</span></span>
      </router-link>

      <form class="hsearch" @submit.prevent="search">
        <span style="color:#5f7a9c;font-size:15px">⌕</span>
        <input v-model="keyword" type="text" placeholder="Tìm laptop, PC, RTX 4070, CPU...">
      </form>

      <div style="flex:1"></div>

      <div class="theme-dots">
        <button v-for="a in ACCENTS" :key="a.key" :title="a.title"
                :style="{ background: a.color }" @click="applyAccent(a.color)"></button>
      </div>

      <router-link to="/cart" class="hact">🛒 <span class="d-none d-sm-inline">Giỏ hàng</span></router-link>

      <a v-if="!isAuthenticated" href="#" class="hact" @click.prevent="router.push('/login')">
        <i class="bi bi-person"></i><span class="d-none d-sm-inline">Đăng nhập</span>
      </a>
      <div v-else class="dropdown">
        <a href="#" class="hact dropdown-toggle" data-bs-toggle="dropdown">
          <i class="bi bi-person-circle"></i><span class="d-none d-sm-inline">{{ user?.fullName || 'Tài khoản' }}</span>
        </a>
        <ul class="dropdown-menu dropdown-menu-end shadow">
          <li><router-link class="dropdown-item" to="/account">Tài khoản của tôi</router-link></li>
          <li><router-link class="dropdown-item" to="/orders">Đơn hàng của tôi</router-link></li>
          <li><hr class="dropdown-divider"></li>
          <li><button class="dropdown-item text-danger" @click="logout">Đăng xuất</button></li>
        </ul>
      </div>
    </div>

    <nav class="nav-bar">
      <div class="wrap nav-inner">
        <router-link to="/products" class="nav-link">Tất cả</router-link>
        <router-link v-for="c in categories" :key="c.id" :to="`/category/${c.slug}`" class="nav-link">
          {{ c.name }}
        </router-link>
        <div style="flex:1"></div>
        <span class="nav-promo">⚡ Trả góp 0%</span>
      </div>
    </nav>
  </header>
</template>
