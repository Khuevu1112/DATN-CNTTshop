<script setup>
import { ref, computed, onMounted } from 'vue';
import { actions, accent } from '../store.js';
import {
  fetchComponentTypes, fetchPcBuildProducts, fetchMyPcBuilds, createPcBuildDraft,
  fetchPcBuildDetail, addPcBuildItem, removePcBuildItem, savePcBuild, deletePcBuild, addPcBuildToCart,
} from '../api.js';

const loading = ref(true);
const componentTypes = ref([]);
const myBuilds = ref([]);
const build = ref(null); // cấu hình đang chỉnh sửa, null = đang xem danh sách
const activeType = ref('CPU');
const browseProducts = ref([]);
const browseKeyword = ref('');
const browsePage = ref(0);
const browseTotalPages = ref(0);
const browseLoading = ref(false);
const nameDraft = ref('');
const noteDraft = ref('');
const saving = ref(false);
const error = ref('');

const fmt = (n) => (n == null ? '—' : Number(n).toLocaleString('vi-VN') + '₫');

async function loadList() {
  loading.value = true;
  try {
    [componentTypes.value, myBuilds.value] = await Promise.all([fetchComponentTypes(), fetchMyPcBuilds()]);
  } finally {
    loading.value = false;
  }
}

function itemFor(type) {
  return build.value?.items.find((i) => i.componentType === type) || null;
}

async function loadBrowse() {
  browseLoading.value = true;
  try {
    const r = await fetchPcBuildProducts(activeType.value, browseKeyword.value, browsePage.value);
    browseProducts.value = r.items;
    browseTotalPages.value = r.totalPages;
  } finally {
    browseLoading.value = false;
  }
}

async function selectType(type) {
  activeType.value = type;
  browsePage.value = 0;
  browseKeyword.value = '';
  await loadBrowse();
}

async function startNewBuild() {
  error.value = '';
  build.value = await createPcBuildDraft();
  nameDraft.value = build.value.name;
  noteDraft.value = build.value.note || '';
  await selectType('CPU');
}

async function openBuild(id) {
  build.value = await fetchPcBuildDetail(id);
  nameDraft.value = build.value.name;
  noteDraft.value = build.value.note || '';
  await selectType('CPU');
}

function backToList() {
  build.value = null;
  loadList();
}

async function pickProduct(p) {
  if (!p.variantId) return;
  error.value = '';
  try {
    build.value = await addPcBuildItem(build.value.id, p.variantId, activeType.value);
  } catch (e) {
    error.value = e?.message || 'Có lỗi khi thêm linh kiện';
  }
}

async function removeSlot(type) {
  build.value = await removePcBuildItem(build.value.id, type);
}

async function saveBuild() {
  saving.value = true;
  error.value = '';
  try {
    build.value = await savePcBuild(build.value.id, nameDraft.value, noteDraft.value);
    actions.showToast('Đã lưu cấu hình');
  } catch (e) {
    error.value = e?.message || 'Lưu thất bại';
  } finally {
    saving.value = false;
  }
}

async function removeBuild(id) {
  if (!window.confirm('Xoá cấu hình này?')) return;
  await deletePcBuild(id);
  await loadList();
}

async function addAllToCart() {
  try {
    await addPcBuildToCart(build.value.id);
    actions.showToast('Đã thêm toàn bộ linh kiện vào giỏ hàng');
    actions.goCart();
  } catch (e) {
    error.value = e?.message || 'Có lỗi khi thêm vào giỏ';
  }
}

onMounted(loadList);
</script>

<template>
  <main style="max-width: 1100px; margin: 0 auto; padding: 24px 24px 64px">
    <button
      @click="build ? backToList() : actions.goHome()"
      style="display: inline-flex; align-items: center; gap: 6px; background: transparent; border: 1px solid rgba(var(--line-rgb),0.2); color: var(--muted); border-radius: 9px; padding: 8px 14px; font-size: 13px; cursor: pointer; margin-bottom: 28px; font-family: 'Be Vietnam Pro', sans-serif"
    >
      ← {{ build ? 'Quay lại danh sách cấu hình' : 'Quay lại trang chủ' }}
    </button>

    <div style="font-family: 'Chakra Petch', sans-serif; font-size: 11px; letter-spacing: 2.5px; color: var(--acc,#c6ff4a); font-weight: 600; margin-bottom: 12px">
      XÂY DỰNG CẤU HÌNH PC
    </div>

    <div v-if="loading" style="color: var(--muted); padding: 40px; text-align: center">Đang tải...</div>

    <!-- Danh sách cấu hình đã lưu -->
    <div v-else-if="!build">
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px">
        <h1 style="font-family: 'Be Vietnam Pro', sans-serif; font-weight: 800; font-size: 30px; margin: 0; color: var(--text)">
          Cấu hình PC của tôi
        </h1>
        <button
          @click="startNewBuild"
          :style="{ background: accent }"
          style="border: none; border-radius: 10px; height: 44px; padding: 0 20px; color: var(--acc-ink); font-weight: 700; cursor: pointer"
        >
          + Tạo cấu hình mới
        </button>
      </div>

      <div v-if="!myBuilds.length" style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 40px; text-align: center; color: var(--muted)">
        Bạn chưa có cấu hình PC nào. Bấm "Tạo cấu hình mới" để bắt đầu.
      </div>
      <div v-else style="display: flex; flex-direction: column; gap: 12px">
        <div v-for="b in myBuilds" :key="b.id"
          style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 18px 20px; display: flex; justify-content: space-between; align-items: center">
          <div @click="openBuild(b.id)" style="cursor: pointer; flex: 1">
            <div style="font-size: 14.5px; font-weight: 700; color: var(--text)">{{ b.name }}</div>
            <div style="font-size: 12px; color: var(--muted); margin-top: 4px">{{ b.itemCount }} linh kiện · {{ fmt(b.totalPrice) }}</div>
          </div>
          <button @click="removeBuild(b.id)" style="background: transparent; border: 1px solid rgba(var(--sale-rgb),0.3); color: var(--sale); border-radius: 8px; padding: 8px 12px; cursor: pointer; font-size: 12px">
            Xoá
          </button>
        </div>
      </div>
    </div>

    <!-- Builder -->
    <div v-else style="display: grid; grid-template-columns: 1fr 320px; gap: 20px; align-items: start">
      <div>
        <!-- Tabs loại linh kiện -->
        <div style="display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 16px">
          <button
            v-for="t in componentTypes" :key="t.key" @click="selectType(t.key)"
            style="padding: 8px 13px; border-radius: 9px; font-size: 12px; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 6px"
            :style="{
              border: '1px solid ' + (activeType === t.key ? accent : 'rgba(var(--line-rgb),0.2)'),
              background: activeType === t.key ? 'color-mix(in srgb, ' + accent + ' 12%, transparent)' : 'var(--card)',
              color: activeType === t.key ? accent : 'var(--muted2)',
            }"
          >
            <i :class="'bi ' + t.icon"></i> {{ t.label }}
            <span v-if="itemFor(t.key)" style="color: var(--green)">✓</span>
          </button>
        </div>

        <!-- Sản phẩm hiện đang chọn cho slot này -->
        <div v-if="itemFor(activeType)" style="background: rgba(43,212,126,0.08); border: 1px solid rgba(43,212,126,0.3); border-radius: 12px; padding: 14px 16px; margin-bottom: 14px; display: flex; justify-content: space-between; align-items: center">
          <div>
            <div style="font-size: 12px; color: var(--green); margin-bottom: 3px">Đã chọn</div>
            <div style="font-size: 13.5px; color: var(--text); font-weight: 600">{{ itemFor(activeType).productName }}</div>
            <div style="font-size: 13px; color: var(--acc,#c6ff4a); margin-top: 3px">{{ fmt(itemFor(activeType).price) }}</div>
          </div>
          <button @click="removeSlot(activeType)" style="background: transparent; border: 1px solid rgba(var(--sale-rgb),0.3); color: var(--sale); border-radius: 8px; padding: 8px 12px; cursor: pointer; font-size: 12px">
            Bỏ chọn
          </button>
        </div>

        <!-- Tìm sản phẩm -->
        <input
          v-model="browseKeyword" @keyup.enter="browsePage = 0; loadBrowse()"
          placeholder="Tìm linh kiện..."
          style="width: 100%; height: 42px; padding: 0 14px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 10px; color: var(--text); font-size: 13.5px; margin-bottom: 12px; box-sizing: border-box"
        />

        <div v-if="browseLoading" style="color: var(--muted); padding: 20px; text-align: center">Đang tải...</div>
        <div v-else-if="!browseProducts.length" style="color: var(--muted); padding: 20px; text-align: center; font-size: 13px">
          Không có sản phẩm phù hợp.
        </div>
        <div v-else style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px">
          <div
            v-for="p in browseProducts" :key="p.productId" @click="pickProduct(p)"
            style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 12px; padding: 14px; cursor: pointer"
          >
            <div style="font-size: 13px; color: var(--text); font-weight: 600; margin-bottom: 6px">{{ p.name }}</div>
            <div style="font-size: 13px; color: var(--acc,#c6ff4a); font-weight: 700">{{ fmt(p.price) }}</div>
            <div style="font-size: 11px; color: var(--muted); margin-top: 4px">Còn {{ p.stock }}</div>
          </div>
        </div>
        <div v-if="browseTotalPages > 1" style="display: flex; gap: 8px; margin-top: 14px; justify-content: center">
          <button v-for="i in browseTotalPages" :key="i" @click="browsePage = i - 1; loadBrowse()"
            style="width: 32px; height: 32px; border-radius: 8px; cursor: pointer"
            :style="{ border: '1px solid ' + (browsePage === i - 1 ? accent : 'rgba(var(--line-rgb),0.2)'), background: browsePage === i - 1 ? 'color-mix(in srgb, ' + accent + ' 12%, transparent)' : 'var(--card)', color: 'var(--text)' }">
            {{ i }}
          </button>
        </div>
      </div>

      <!-- Tóm tắt -->
      <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 14px; padding: 20px; position: sticky; top: 100px">
        <div style="font-size: 13.5px; font-weight: 700; color: var(--text); margin-bottom: 14px">Tóm tắt cấu hình</div>

        <input v-model="nameDraft" placeholder="Tên cấu hình"
          style="width: 100%; height: 38px; padding: 0 12px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 13px; margin-bottom: 10px; box-sizing: border-box" />
        <textarea v-model="noteDraft" rows="2" placeholder="Ghi chú (tuỳ chọn)"
          style="width: 100%; padding: 10px 12px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 12.5px; margin-bottom: 14px; box-sizing: border-box; resize: vertical"></textarea>

        <div v-for="item in build.items" :key="item.componentType" style="display: flex; justify-content: space-between; padding: 6px 0; font-size: 12px">
          <span style="color: var(--muted)">{{ item.componentLabel }}</span>
          <span style="color: var(--muted2)">{{ fmt(item.price) }}</span>
        </div>

        <div style="display: flex; justify-content: space-between; padding-top: 10px; margin-top: 10px; border-top: 1px solid rgba(var(--line-rgb),0.14); font-size: 15px; font-weight: 700">
          <span style="color: var(--text)">Tổng cộng</span>
          <span style="color: var(--acc,#c6ff4a)">{{ fmt(build.totalPrice) }}</span>
        </div>

        <div v-if="build.warnings.length" style="margin-top: 12px; font-size: 11.5px; color: var(--amber)">
          <div v-for="(w, i) in build.warnings" :key="i">⚠ {{ w }}</div>
        </div>
        <div v-if="error" style="margin-top: 10px; font-size: 12px; color: var(--sale)">{{ error }}</div>

        <button @click="saveBuild" :disabled="saving"
          style="width: 100%; height: 42px; border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 10px; background: transparent; color: var(--text); font-weight: 600; cursor: pointer; margin-top: 16px">
          {{ saving ? 'Đang lưu...' : 'Lưu cấu hình' }}
        </button>
        <button @click="addAllToCart" :disabled="!build.items.length"
          :style="{ background: accent, opacity: build.items.length ? 1 : 0.5 }"
          style="width: 100%; height: 44px; border: none; border-radius: 10px; color: var(--acc-ink); font-weight: 700; cursor: pointer; margin-top: 10px">
          Thêm tất cả vào giỏ hàng
        </button>
      </div>
    </div>
  </main>
</template>
