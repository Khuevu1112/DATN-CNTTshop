<script setup>
import { ref, computed, watch } from 'vue';
import { actions, accent } from '../store.js';
import { fetchOrderDetail, fetchReviewableItems, submitDeliveryReview, submitProductReview } from '../api.js';
import StarRatingInput from './StarRatingInput.vue';

const props = defineProps({
  orderId: { type: Number, default: null },
});
const emit = defineEmits(['close']);

// step: 'confirm' (đã nhận hàng chưa) -> 'delivery' (đánh giá giao hàng) -> 'products' (đánh giá
// từng sản phẩm) -> 'done'
const step = ref('confirm');
const loading = ref(false);
const order = ref(null);
const items = ref([]); // ReviewableItemDto[] của riêng đơn này (đã lọc, chỉ còn sản phẩm chưa đánh giá)

const deliveryRating = ref(0);
const deliveryComment = ref('');
const savingDelivery = ref(false);

const productForms = ref({}); // orderItemId/productId -> { rating, comment, photo1, photo2, saving, done }

async function open(orderId) {
  step.value = 'confirm';
  loading.value = true;
  order.value = null;
  items.value = [];
  deliveryRating.value = 0;
  deliveryComment.value = '';
  productForms.value = {};
  try {
    const [detail, reviewable] = await Promise.all([fetchOrderDetail(orderId), fetchReviewableItems()]);
    order.value = detail;
    const mine = reviewable.filter((it) => it.orderId === orderId);
    items.value = mine;
    for (const it of mine) {
      productForms.value[it.productId] = { rating: 0, comment: '', photo1: null, photo2: null, saving: false, done: false };
    }
  } finally {
    loading.value = false;
  }
}

watch(
  () => props.orderId,
  (id) => {
    if (id) open(id);
  },
  { immediate: true },
);

function close() {
  emit('close');
}

function chuaNhanHang() {
  close();
  actions.goContact();
}

const deliveryAlreadyDone = computed(() => items.value.length && items.value[0].deliveryReviewed);

function daNhanHang() {
  step.value = deliveryAlreadyDone.value ? 'products' : 'delivery';
}

async function submitDelivery() {
  if (!deliveryRating.value) {
    actions.showToast('Vui lòng chọn số sao đánh giá');
    return;
  }
  savingDelivery.value = true;
  try {
    await submitDeliveryReview(props.orderId, deliveryRating.value, deliveryComment.value.trim() || null);
    step.value = 'products';
  } catch (e) {
    actions.showToast(e?.message || 'Có lỗi khi gửi đánh giá giao hàng');
  } finally {
    savingDelivery.value = false;
  }
}
function skipDelivery() {
  step.value = 'products';
}

function onPhotoChange(productId, slot, e) {
  const file = e.target.files?.[0] || null;
  productForms.value[productId][slot] = file;
}

async function submitOneProduct(it) {
  const form = productForms.value[it.productId];
  if (!form.rating) {
    actions.showToast('Vui lòng chọn số sao đánh giá');
    return;
  }
  form.saving = true;
  try {
    await submitProductReview(it.orderId, it.productId, form.rating, form.comment.trim() || null, form.photo1, form.photo2);
    form.done = true;
    actions.showToast('Đã gửi đánh giá "' + it.productName + '"');
  } catch (e) {
    actions.showToast(e?.message || 'Có lỗi khi gửi đánh giá sản phẩm');
  } finally {
    form.saving = false;
  }
}

const allProductsDone = computed(() => items.value.every((it) => productForms.value[it.productId]?.done));
</script>

<template>
  <Teleport to="body">
    <div v-if="orderId" style="position: fixed; inset: 0; background: rgba(0,0,0,0.6); display: flex; align-items: center; justify-content: center; z-index: 300; padding: 20px">
      <div style="background: var(--card); border: 1px solid rgba(var(--line-rgb),0.18); border-radius: 16px; padding: 26px; max-width: 460px; width: 100%; max-height: 85vh; overflow-y: auto">
        <div v-if="loading" style="text-align: center; padding: 30px 0; color: var(--muted)">Đang tải...</div>

        <template v-else>
          <!-- Bước 1: xác nhận đã nhận hàng -->
          <div v-if="step === 'confirm'" style="text-align: center">
            <div style="font-size: 34px; margin-bottom: 12px">📦</div>
            <div style="font-size: 15.5px; font-weight: 700; color: var(--text); margin-bottom: 8px">
              Bạn đã nhận được đơn hàng {{ order?.orderCode }} chưa?
            </div>
            <div style="font-size: 12.5px; color: var(--muted2); margin-bottom: 22px">
              Nếu chưa nhận được hàng, vui lòng liên hệ để chúng tôi hỗ trợ ngay.
            </div>
            <div style="display: flex; gap: 10px">
              <button
                @click="chuaNhanHang"
                style="flex: 1; height: 44px; border: 1px solid rgba(var(--line-rgb),0.22); background: transparent; border-radius: 10px; color: var(--muted2); font-size: 13px; cursor: pointer"
              >
                Chưa nhận được
              </button>
              <button
                @click="daNhanHang"
                :style="{ background: accent }"
                style="flex: 1; height: 44px; border: none; border-radius: 10px; color: var(--acc-ink); font-weight: 700; font-size: 13px; cursor: pointer"
              >
                Đã nhận được hàng
              </button>
            </div>
          </div>

          <!-- Bước 2: đánh giá giao hàng -->
          <div v-else-if="step === 'delivery'">
            <div style="font-size: 15px; font-weight: 700; color: var(--text); margin-bottom: 4px">Đánh giá giao hàng</div>
            <div style="font-size: 12px; color: var(--muted2); margin-bottom: 18px">
              {{ order?.shippingOptionLabel || 'Đơn vị giao hàng' }}
            </div>
            <div style="display: flex; justify-content: center; margin-bottom: 16px">
              <StarRatingInput v-model="deliveryRating" :size="30" />
            </div>
            <textarea
              v-model="deliveryComment"
              rows="3"
              placeholder="Cảm nhận của bạn về quá trình giao hàng (không bắt buộc)"
              style="width: 100%; padding: 10px 12px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; color: var(--text); font-size: 13px; font-family: 'Plus Jakarta Sans', sans-serif; resize: vertical; margin-bottom: 14px"
            ></textarea>
            <div style="display: flex; gap: 10px">
              <button
                @click="skipDelivery"
                style="flex: none; height: 42px; padding: 0 16px; border: 1px solid rgba(var(--line-rgb),0.22); background: transparent; border-radius: 9px; color: var(--muted2); font-size: 13px; cursor: pointer"
              >
                Bỏ qua
              </button>
              <button
                @click="submitDelivery" :disabled="savingDelivery"
                :style="{ background: accent, opacity: savingDelivery ? 0.7 : 1 }"
                style="flex: 1; height: 42px; border: none; border-radius: 9px; color: var(--acc-ink); font-weight: 700; font-size: 13px; cursor: pointer"
              >
                {{ savingDelivery ? 'Đang gửi...' : 'Gửi đánh giá' }}
              </button>
            </div>
          </div>

          <!-- Bước 3: đánh giá từng sản phẩm -->
          <div v-else-if="step === 'products'">
            <div style="font-size: 15px; font-weight: 700; color: var(--text); margin-bottom: 4px">Đánh giá sản phẩm</div>
            <div style="font-size: 12px; color: var(--muted2); margin-bottom: 16px">
              Bạn có 14 ngày kể từ khi nhận hàng để đánh giá. Ảnh: tối đa 2 ảnh/sản phẩm.
            </div>

            <div v-if="!items.length" style="text-align: center; padding: 20px 0; color: var(--muted); font-size: 13px">
              Bạn đã đánh giá hết sản phẩm trong đơn này rồi.
            </div>

            <div v-else style="display: flex; flex-direction: column; gap: 16px; margin-bottom: 18px">
              <div
                v-for="it in items" :key="it.productId"
                style="border: 1px solid rgba(var(--line-rgb),0.14); border-radius: 12px; padding: 14px"
              >
                <div style="font-size: 13.5px; font-weight: 600; color: var(--text); margin-bottom: 10px">{{ it.productName }}</div>

                <template v-if="!productForms[it.productId].done">
                  <StarRatingInput v-model="productForms[it.productId].rating" :size="22" />
                  <textarea
                    v-model="productForms[it.productId].comment"
                    rows="2"
                    placeholder="Chia sẻ trải nghiệm của bạn về sản phẩm (không bắt buộc)"
                    style="width: 100%; margin-top: 8px; padding: 8px 10px; background: var(--card2); border: 1px solid rgba(var(--line-rgb),0.2); border-radius: 8px; color: var(--text); font-size: 12.5px; font-family: 'Plus Jakarta Sans', sans-serif; resize: vertical"
                  ></textarea>
                  <div style="display: flex; gap: 8px; margin-top: 8px; font-size: 11.5px; color: var(--muted2)">
                    <label style="display: flex; align-items: center; gap: 4px; cursor: pointer">
                      📷 Ảnh 1
                      <input type="file" accept="image/*" style="display: none" @change="onPhotoChange(it.productId, 'photo1', $event)" />
                      <span v-if="productForms[it.productId].photo1" style="color: var(--acc,#c6ff4a)">✓</span>
                    </label>
                    <label style="display: flex; align-items: center; gap: 4px; cursor: pointer">
                      📷 Ảnh 2
                      <input type="file" accept="image/*" style="display: none" @change="onPhotoChange(it.productId, 'photo2', $event)" />
                      <span v-if="productForms[it.productId].photo2" style="color: var(--acc,#c6ff4a)">✓</span>
                    </label>
                  </div>
                  <button
                    @click="submitOneProduct(it)" :disabled="productForms[it.productId].saving"
                    :style="{ background: accent, opacity: productForms[it.productId].saving ? 0.7 : 1 }"
                    style="margin-top: 10px; height: 36px; padding: 0 16px; border: none; border-radius: 8px; color: var(--acc-ink); font-weight: 700; font-size: 12.5px; cursor: pointer"
                  >
                    {{ productForms[it.productId].saving ? 'Đang gửi...' : 'Gửi đánh giá' }}
                  </button>
                </template>
                <div v-else style="font-size: 12.5px; color: var(--green,#22d39a)">✓ Đã gửi đánh giá</div>
              </div>
            </div>

            <button
              @click="close"
              :style="{ background: allProductsDone || !items.length ? accent : 'transparent' }"
              style="width: 100%; height: 42px; border: 1px solid rgba(var(--line-rgb),0.22); border-radius: 9px; font-weight: 700; font-size: 13px; cursor: pointer"
              :class="{}"
            >
              <span :style="{ color: allProductsDone || !items.length ? 'var(--acc-ink)' : 'var(--muted2)' }">
                {{ allProductsDone || !items.length ? 'Hoàn tất' : 'Đóng (có thể đánh giá sau)' }}
              </span>
            </button>
          </div>
        </template>
      </div>
    </div>
  </Teleport>
</template>
