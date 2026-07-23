<template>
  <div
    @click="$emit('close')"
    style="position: fixed; inset: 0; background: rgba(2, 8, 18, 0.6); backdrop-filter: blur(2px); z-index: 70; display: flex; align-items: center; justify-content: center; padding: 24px"
  >
    <div
      @click.stop
      style="width: 100%; max-width: 640px; max-height: 88vh; background: var(--bg); border: 1px solid var(--line2); border-radius: 16px; display: flex; flex-direction: column; box-shadow: 0 20px 60px rgba(0, 0, 0, 0.45)"
    >
      <div style="display: flex; align-items: center; justify-content: space-between; padding: 18px 22px; border-bottom: 1px solid var(--line); flex: none">
        <div style="font-size: 15px; font-weight: 700; color: var(--text)">Nhập kho / Điều chỉnh kho</div>
        <button @click="$emit('close')" style="width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--line2); background: var(--card); color: var(--text); cursor: pointer">
          <i class="bi bi-x-lg" style="font-size: 13px"></i>
        </button>
      </div>

      <div style="display: flex; gap: 8px; padding: 12px 22px 0; flex: none">
        <button
          @click="tab = 'create'"
          :style="{ background: tab === 'create' ? 'var(--acc)' : 'var(--card)', color: tab === 'create' ? 'var(--acc-ink)' : 'var(--muted2)' }"
          style="height: 34px; padding: 0 14px; border-radius: 9px 9px 0 0; border: none; font-size: 12.5px; font-weight: 600; cursor: pointer"
        >
          Tạo phiếu
        </button>
        <button
          @click="tab = 'history'"
          :style="{ background: tab === 'history' ? 'var(--acc)' : 'var(--card)', color: tab === 'history' ? 'var(--acc-ink)' : 'var(--muted2)' }"
          style="height: 34px; padding: 0 14px; border-radius: 9px 9px 0 0; border: none; font-size: 12.5px; font-weight: 600; cursor: pointer"
        >
          Lịch sử
        </button>
      </div>

      <div style="flex: 1; overflow-y: auto; padding: 20px 22px">
        <template v-if="tab === 'create'">
          <label class="lbl">Sản phẩm *</label>
          <div v-if="selectedVariant" style="display: flex; align-items: center; justify-content: space-between; gap: 10px; background: var(--card); border: 1px solid var(--line2); border-radius: 9px; padding: 10px 12px">
            <div style="min-width: 0">
              <div style="font-size: 13px; font-weight: 600; color: var(--text)">{{ selectedVariant.productName }}</div>
              <div class="mono" style="font-size: 11px; color: var(--muted); margin-top: 2px">{{ selectedVariant.sku }} · Tồn hiện tại: {{ selectedVariant.stock }}</div>
            </div>
            <button @click="selectedVariant = null" class="rm" title="Đổi sản phẩm"><i class="bi bi-arrow-repeat"></i></button>
          </div>
          <div v-else style="position: relative">
            <input class="fld" v-model="search" @input="onSearchInput" placeholder="Gõ tên sản phẩm hoặc SKU..." />
            <div v-if="searchResults.length" style="position: absolute; top: 42px; left: 0; right: 0; z-index: 5; background: var(--bg); border: 1px solid var(--line2); border-radius: 9px; max-height: 200px; overflow-y: auto; box-shadow: 0 10px 26px rgba(0,0,0,.35)">
              <div
                v-for="r in searchResults"
                :key="r.variantId"
                @click="pickVariant(r)"
                style="display: flex; align-items: center; justify-content: space-between; padding: 9px 11px; font-size: 12.5px; color: var(--text); cursor: pointer; border-bottom: 1px solid var(--line)"
              >
                <span>{{ r.productName }}</span>
                <span class="mono" style="color: var(--muted); font-size: 11px">{{ r.sku }} · Tồn: {{ r.stock }}</span>
              </div>
            </div>
          </div>

          <label class="lbl">Loại phiếu</label>
          <div style="display: flex; border: 1px solid var(--line2); border-radius: 8px; overflow: hidden; width: fit-content">
            <button @click="form.reason = 'nhap_hang'" :style="segStyle(form.reason === 'nhap_hang')" style="padding: 7px 15px; border: none; font-size: 12.5px; font-weight: 600; cursor: pointer">Nhập hàng</button>
            <button @click="form.reason = 'dieu_chinh'" :style="segStyle(form.reason === 'dieu_chinh')" style="padding: 7px 15px; border: none; font-size: 12.5px; font-weight: 600; cursor: pointer">Điều chỉnh kho</button>
          </div>

          <div v-if="form.reason === 'dieu_chinh'" style="margin-top: 10px; display: flex; border: 1px solid var(--line2); border-radius: 8px; overflow: hidden; width: fit-content">
            <button @click="adjustDirection = 'increase'" :style="segStyle(adjustDirection === 'increase')" style="padding: 7px 15px; border: none; font-size: 12.5px; font-weight: 600; cursor: pointer">+ Tăng</button>
            <button @click="adjustDirection = 'decrease'" :style="segStyle(adjustDirection === 'decrease')" style="padding: 7px 15px; border: none; font-size: 12.5px; font-weight: 600; cursor: pointer">− Giảm</button>
          </div>

          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 4px">
            <div>
              <label class="lbl">{{ form.reason === 'nhap_hang' ? 'Số lượng nhập' : 'Số lượng thay đổi' }} *</label>
              <input class="fld" type="number" min="1" v-model.number="form.changeQty" placeholder="VD: 10" />
            </div>
            <div>
              <label class="lbl">Giá vốn / đơn vị</label>
              <input class="fld" type="text" inputmode="numeric" :value="fmtMoneyInput(form.unitCost)" @input="form.unitCost = parseMoneyInput($event.target.value)" placeholder="Không bắt buộc" />
            </div>
          </div>

          <label class="lbl">Ghi chú</label>
          <textarea class="fld" v-model="form.note" rows="2" placeholder="VD: Nhập từ NCC ABC, hoá đơn #123" style="padding: 10px 14px; resize: vertical"></textarea>

          <div v-if="error" class="alert-err" style="margin-top: 12px">{{ error }}</div>
        </template>

        <template v-else>
          <div v-if="historyLoading" style="padding: 30px; text-align: center; color: var(--muted); font-size: 13px">Đang tải...</div>
          <div v-else-if="!history.length" style="padding: 30px; text-align: center; color: var(--muted); font-size: 13px">Chưa có phiếu nhập/điều chỉnh nào.</div>
          <div v-else style="display: flex; flex-direction: column; gap: 8px">
            <div v-for="h in history" :key="h.id" style="background: var(--card); border: 1px solid var(--line); border-radius: 10px; padding: 10px 12px">
              <div style="display: flex; align-items: center; justify-content: space-between; gap: 10px">
                <div style="min-width: 0">
                  <div style="font-size: 12.5px; font-weight: 600; color: var(--text); white-space: nowrap; overflow: hidden; text-overflow: ellipsis">{{ h.productName }}</div>
                  <div class="mono" style="font-size: 10.5px; color: var(--muted); margin-top: 2px">{{ h.sku }} · {{ h.createdAt }} · {{ h.createdByName || 'N/A' }}</div>
                </div>
                <span class="mono" style="font-size: 14px; font-weight: 700; white-space: nowrap" :style="{ color: h.changeQty > 0 ? 'var(--green)' : 'var(--sale)' }">
                  {{ h.changeQty > 0 ? '+' : '' }}{{ h.changeQty }}
                </span>
              </div>
              <div style="display: flex; align-items: center; gap: 8px; margin-top: 6px; font-size: 11px">
                <span style="padding: 2px 8px; border-radius: 20px; background: var(--card2); color: var(--muted2)">{{ h.reason === 'nhap_hang' ? 'Nhập hàng' : 'Điều chỉnh' }}</span>
                <span v-if="h.unitCost" class="mono" style="color: var(--muted)">Giá vốn: {{ money(h.unitCost) }}</span>
                <span style="color: var(--muted)">Tồn sau: {{ h.stockAfter }}</span>
              </div>
              <div v-if="h.note" style="font-size: 11.5px; color: var(--muted2); margin-top: 5px">{{ h.note }}</div>
            </div>
          </div>
        </template>
      </div>

      <div v-if="tab === 'create'" style="display: flex; justify-content: flex-end; gap: 10px; padding: 16px 22px; border-top: 1px solid var(--line); flex: none">
        <button @click="$emit('close')" class="btn-ghost">Đóng</button>
        <button
          @click="submit"
          :disabled="saving"
          :style="{ opacity: saving ? 0.6 : 1 }"
          style="height: 42px; padding: 0 22px; border-radius: 10px; border: none; background: var(--acc); color: var(--acc-ink); font-weight: 700; font-size: 13px; cursor: pointer"
        >
          {{ saving ? 'Đang lưu...' : 'Lưu phiếu' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, watch, onMounted } from 'vue';
import { money, fmtMoneyInput, parseMoneyInput } from '../data/adminData';
import {
  searchStockVariants, createStockMovement, getRecentStockMovements, getStockMovementsByVariant,
} from '../api/admin';

const props = defineProps({ initialSearchTerm: { type: String, default: '' } });
const emit = defineEmits(['close', 'saved']);

const tab = ref('create');
const search = ref('');
const searchResults = ref([]);
const selectedVariant = ref(null);
let searchTimer = null;

const form = reactive({ reason: 'nhap_hang', changeQty: null, unitCost: null, note: '' });
const adjustDirection = ref('increase');
const saving = ref(false);
const error = ref('');

const history = ref([]);
const historyLoading = ref(false);

function segStyle(active) {
  return active ? 'background:var(--acc);color:var(--acc-ink);' : 'background:var(--card);color:var(--muted2);';
}

function onSearchInput() {
  clearTimeout(searchTimer);
  const kw = search.value.trim();
  if (!kw) { searchResults.value = []; return; }
  searchTimer = setTimeout(async () => {
    searchResults.value = await searchStockVariants(kw);
  }, 280);
}
function pickVariant(v) {
  selectedVariant.value = v;
  search.value = '';
  searchResults.value = [];
}

async function loadHistory() {
  historyLoading.value = true;
  try {
    history.value = selectedVariant.value
      ? await getStockMovementsByVariant(selectedVariant.value.variantId)
      : await getRecentStockMovements(50);
  } finally {
    historyLoading.value = false;
  }
}
watch(tab, (t) => { if (t === 'history') loadHistory(); });

async function submit() {
  error.value = '';
  if (!selectedVariant.value) { error.value = 'Vui lòng chọn sản phẩm'; return; }
  if (!form.changeQty) { error.value = 'Vui lòng nhập số lượng'; return; }
  const signedQty =
    form.reason === 'nhap_hang'
      ? Math.abs(form.changeQty)
      : adjustDirection.value === 'decrease'
        ? -Math.abs(form.changeQty)
        : Math.abs(form.changeQty);

  saving.value = true;
  try {
    const result = await createStockMovement({
      variantId: selectedVariant.value.variantId,
      changeQty: signedQty,
      reason: form.reason,
      unitCost: form.unitCost,
      note: form.note,
    });
    selectedVariant.value.stock = result.stockAfter;
    emit('saved');
    form.changeQty = null;
    form.unitCost = null;
    form.note = '';
  } catch (e) {
    error.value = e.response?.data?.message || 'Có lỗi khi lưu phiếu';
  } finally {
    saving.value = false;
  }
}

onMounted(async () => {
  if (props.initialSearchTerm) {
    search.value = props.initialSearchTerm;
    searchResults.value = await searchStockVariants(props.initialSearchTerm);
  }
});
</script>

<style scoped>
.lbl {
  display: block;
  font-size: 12px;
  font-weight: 600;
  color: var(--muted2);
  margin: 14px 0 6px;
}
.rm {
  flex: none;
  width: 34px;
  height: 34px;
  border-radius: 8px;
  border: 1px solid var(--line2);
  background: var(--card);
  color: var(--muted2);
  cursor: pointer;
}
.btn-ghost {
  height: 42px;
  padding: 0 18px;
  border-radius: 10px;
  border: 1px solid var(--line2);
  background: var(--card);
  color: var(--text);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
}
</style>
