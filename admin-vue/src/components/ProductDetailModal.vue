<template>
  <div
    @click="$emit('close')"
    style="
      position: fixed;
      inset: 0;
      background: rgba(2, 8, 18, 0.55);
      backdrop-filter: blur(2px);
      z-index: 60;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 24px;
      animation: fadeUp 0.2s ease;
    "
  >
    <div
      @click.stop
      style="
        width: 100%;
        max-width: 1150px;
        max-height: 90vh;
        background: var(--bg);
        border: 1px solid var(--line2);
        border-radius: 16px;
        z-index: 61;
        display: flex;
        flex-direction: column;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.45);
        animation: fadeUp 0.25s ease;
      "
    >
      <div
        style="
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 18px 22px;
          border-bottom: 1px solid var(--line);
          flex: none;
        "
      >
        <div style="font-size: 14px; font-weight: 600; color: var(--text)">Chi tiết sản phẩm</div>
        <button
          @click="$emit('close')"
          style="width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--line2); background: var(--card); color: var(--text); cursor: pointer"
        >
          <i class="bi bi-x-lg" style="font-size: 13px"></i>
        </button>
      </div>

      <div v-if="loading" class="spin" style="margin: 40px auto"></div>

      <div v-else-if="d" style="flex: 1; overflow-y: auto; padding: 22px">
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 30px; align-items: start">
          <!-- gallery -->
          <div>
            <div
              :style="{ '--ph': hue }"
              style="
                position: relative;
                aspect-ratio: 1/1;
                border-radius: 16px;
                overflow: hidden;
                background: linear-gradient(140deg, hsl(var(--ph) 45% 17%), hsl(var(--ph) 58% 9%));
                border: 1px solid var(--line2);
                display: flex;
                align-items: center;
                justify-content: center;
              "
            >
              <img v-if="mainImageUrl" :src="mainImageUrl" :alt="d.name" style="position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover" />
              <div v-else style="font-family: monospace; font-size: 11px; color: rgba(200,225,255,0.35)">[ CHƯA CÓ ẢNH ]</div>
            </div>
            <div v-if="sortedImages.length > 1" style="display: grid; grid-template-columns: repeat(5, 1fr); gap: 8px; margin-top: 8px">
              <div
                v-for="(img, n) in sortedImages"
                :key="img.id || n"
                @click="selectedImgIdx = n"
                :style="{ borderColor: selectedImgIdx === n ? 'var(--acc)' : 'var(--line2)' }"
                style="aspect-ratio: 1/1; border-radius: 8px; overflow: hidden; border: 1px solid; cursor: pointer"
              >
                <img :src="resolveImageUrl(img.url)" style="width: 100%; height: 100%; object-fit: cover" />
              </div>
            </div>
          </div>

          <!-- info -->
          <div>
            <div style="font-size: 11px; letter-spacing: 1px; color: var(--acc); font-weight: 600; text-transform: uppercase">{{ brandName }}</div>
            <div style="font-size: 20px; font-weight: 700; color: var(--text); margin: 6px 0 10px; line-height: 1.3">{{ d.name }}</div>

            <div style="background: var(--card); border: 1px solid var(--line); border-radius: 12px; padding: 14px; margin-bottom: 14px">
              <div class="mono" style="font-size: 22px; font-weight: 700; color: var(--acc)">{{ priceRangeText }}</div>
              <div style="font-size: 11.5px; color: var(--muted); margin-top: 4px">{{ d.variants.length }} biến thể · tổng kho {{ totalStock }}</div>
            </div>

            <div v-if="d.description" class="desc-render" style="font-size: 13px; color: var(--muted2); line-height: 1.6; margin-bottom: 14px" v-html="renderDescription(d.description)"></div>

            <div v-if="d.promotions.length" style="background: color-mix(in srgb, var(--green) 10%, transparent); border: 1px solid color-mix(in srgb, var(--green) 25%, transparent); border-radius: 10px; padding: 10px 12px; margin-bottom: 14px; display: flex; flex-direction: column; gap: 5px">
              <div v-for="(pr, i) in d.promotions" :key="i" style="font-size: 12.5px; color: var(--green); display: flex; gap: 7px">
                <span>🎁</span><span>{{ pr.content }}</span>
              </div>
            </div>

            <div v-if="d.options.length" style="margin-bottom: 14px">
              <div class="sec-title">Tuỳ chọn cấu hình</div>
              <div v-for="o in d.options" :key="o.id || o.optionName" style="margin-bottom: 8px">
                <div style="font-size: 12px; color: var(--muted); margin-bottom: 4px">
                  {{ o.optionName }}
                  <span v-if="o.linkedGroup" style="color: var(--acc)">(khoá cặp)</span>
                </div>
                <div style="display: flex; flex-wrap: wrap; gap: 6px">
                  <span v-for="v in o.values" :key="v.id || v.value" style="font-size: 11.5px; padding: 3px 9px; border-radius: 20px; background: var(--card2); color: var(--muted2)">
                    {{ v.value }}<template v-if="v.priceExtra">&nbsp;(+{{ money(v.priceExtra) }})</template>
                  </span>
                </div>
              </div>
            </div>

            <div v-if="d.specs.length" style="margin-bottom: 14px">
              <div class="sec-title">Cấu hình</div>
              <div style="background: var(--card); border: 1px solid var(--line); border-radius: 10px; overflow: hidden">
                <div v-for="(s, i) in d.specs" :key="i" style="display: flex; padding: 9px 12px; font-size: 12.5px" :style="{ borderTop: i ? '1px solid var(--line)' : 'none' }">
                  <span style="width: 40%; color: var(--muted)">{{ s.specKey }}</span>
                  <span style="flex: 1; color: var(--text)">{{ s.specValue }}</span>
                </div>
              </div>
            </div>

            <div style="margin-bottom: 6px">
              <div class="sec-title">Biến thể (giá / kho)</div>
              <div style="background: var(--card); border: 1px solid var(--line); border-radius: 10px; overflow: hidden">
                <div v-for="(v, i) in d.variants" :key="v.id || i" style="display: flex; align-items: center; gap: 10px; padding: 8px 12px; font-size: 12px" :style="{ borderTop: i ? '1px solid var(--line)' : 'none' }">
                  <span class="mono" style="color: var(--muted); flex: 1">{{ v.sku }}</span>
                  <span class="mono" style="color: var(--text); font-weight: 600">{{ money(v.price) }}</span>
                  <span class="mono" style="color: var(--muted2)">Kho: {{ v.stock }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div style="display: flex; justify-content: flex-end; gap: 10px; padding: 16px 22px; border-top: 1px solid var(--line); flex: none">
        <button
          @click="$emit('edit', productId)"
          style="flex: 1; max-width: 220px; height: 42px; border-radius: 10px; border: none; background: var(--acc); color: var(--acc-ink); font-weight: 700; font-size: 13px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 7px"
        >
          <i class="bi bi-pencil-square"></i> Chỉnh sửa
        </button>
        <button
          @click="onDelete"
          style="width: 42px; height: 42px; border-radius: 10px; border: 1px solid var(--line2); background: var(--card); color: var(--sale); font-size: 15px; cursor: pointer"
        >
          <i class="bi bi-trash3"></i>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue';
import { getAdminProductDetail, deleteAdminProduct } from '../api/admin';
import { resolveImageUrl } from '../api/http';
import { PRODUCTS } from '../data/adminData';

const props = defineProps({ productId: { type: Number, required: true } });
const emit = defineEmits(['close', 'edit', 'deleted']);

const loading = ref(false);
const d = ref(null);
const selectedImgIdx = ref(0);

async function load() {
  loading.value = true;
  selectedImgIdx.value = 0;
  try {
    d.value = await getAdminProductDetail(props.productId);
  } finally {
    loading.value = false;
  }
}
watch(() => props.productId, load, { immediate: true });

const listEntry = computed(() => PRODUCTS.find((p) => p.id === props.productId));
const hue = computed(() => listEntry.value?.hue || 200);
const brandName = computed(() => listEntry.value?.brand || 'CNTTshop');
const sortedImages = computed(() => (d.value?.images || []).slice().sort((a, b) => (b.isPrimary ? 1 : 0) - (a.isPrimary ? 1 : 0)));
const mainImageUrl = computed(() => {
  const img = sortedImages.value[selectedImgIdx.value] || sortedImages.value[0];
  return img ? resolveImageUrl(img.url) : '';
});

function money(n) {
  return (Number(n) || 0).toLocaleString('vi-VN') + '₫';
}
const priceRangeText = computed(() => {
  const prices = (d.value?.variants || []).map((v) => Number(v.price) || 0);
  if (!prices.length) return '—';
  const min = Math.min(...prices), max = Math.max(...prices);
  return min === max ? money(min) : money(min) + ' – ' + money(max);
});
const totalStock = computed(() => (d.value?.variants || []).reduce((a, v) => a + (Number(v.stock) || 0), 0));

// Đồng bộ đúng quy ước với DetailView.vue phía USER: gõ "- "/"• " đầu dòng = gạch đầu dòng,
// dòng trống = ngắt đoạn, xuống dòng thường = <br>. Escape HTML trước để tránh XSS qua v-html.
function renderDescription(text) {
  const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  const paragraphs = String(text).split(/\n\s*\n/);
  return paragraphs
    .map((para) => {
      const lines = para.split('\n').filter((l) => l.trim() !== '');
      if (!lines.length) return '';
      const isBullet = (l) => /^[-•]\s+/.test(l.trim());
      if (lines.every(isBullet)) {
        return '<ul style="margin:0;padding-left:18px">' +
          lines.map((l) => '<li>' + esc(l.trim().replace(/^[-•]\s+/, '')) + '</li>').join('') +
          '</ul>';
      }
      return '<p style="margin:0">' + lines.map(esc).join('<br>') + '</p>';
    })
    .filter(Boolean)
    .join('<div style="height:10px"></div>');
}

async function onDelete() {
  if (!d.value) return;
  if (!window.confirm(`Xoá sản phẩm "${d.value.name}"? Nếu sản phẩm đã có đơn hàng, hệ thống sẽ tự ẩn thay vì xoá hẳn.`)) return;
  try {
    const res = await deleteAdminProduct(props.productId);
    emit('deleted');
    if (!res.hardDeleted) {
      window.alert('Sản phẩm đã có đơn hàng nên được ẩn đi (không hiển thị ở cửa hàng) thay vì xoá hẳn.');
    }
  } catch (e) {
    window.alert(e.response?.data?.message || 'Có lỗi khi xoá sản phẩm');
  }
}
</script>

<style scoped>
.sec-title {
  font-size: 11px;
  font-weight: 600;
  color: var(--muted);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 8px;
}
</style>
