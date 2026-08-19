<template>
  <div
    @click="$emit('close')"
    style="
      position: fixed;
      inset: 0;
      background: rgba(2, 8, 18, 0.6);
      backdrop-filter: blur(2px);
      z-index: 70;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 24px;
    "
  >
    <div
      @click.stop
      style="
        width: 100%;
        max-width: 1300px;
        max-height: 90vh;
        background: var(--bg);
        border: 1px solid var(--line2);
        border-radius: 16px;
        display: flex;
        flex-direction: column;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.45);
        animation: fadeUp 0.2s ease;
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
        <div style="font-size: 15px; font-weight: 700; color: var(--text)">
          {{ productId ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới' }}
        </div>
        <button
          @click="$emit('close')"
          style="
            width: 32px; height: 32px; border-radius: 8px;
            border: 1px solid var(--line2); background: var(--card);
            color: var(--text); cursor: pointer;
          "
        >
          <i class="bi bi-x-lg" style="font-size: 13px"></i>
        </button>
      </div>

      <div v-if="loading" class="spin"></div>

      <div v-else style="flex: 1; overflow-y: auto; padding: 20px 22px">
        <div v-if="error" class="alert-err">{{ error }}</div>

        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 12px">
          <div>
            <label class="lbl">Tên sản phẩm *</label>
            <input class="fld" v-model="form.name" @input="onNameInput" placeholder="VD: Laptop Lenovo LOQ 15" />
          </div>
          <div>
            <label class="lbl">Slug</label>
            <input class="fld" v-model="form.slug" placeholder="tu-dong-sinh" />
          </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 12px; margin-top: 4px">
          <div>
            <label class="lbl">Danh mục *</label>
            <select class="fld" v-model="form.categoryId">
              <option :value="null" disabled>-- Chọn danh mục --</option>
              <option v-for="c in categories" :key="c.id" :value="c.id">{{ c.name }}</option>
            </select>
          </div>
          <div>
            <label class="lbl">Thương hiệu</label>
            <select class="fld" v-model="form.brandId">
              <option :value="null">-- Không chọn --</option>
              <option v-for="b in brandsForCategory" :key="b.id" :value="b.id">{{ b.name }}</option>
            </select>
          </div>
          <div>
            <label class="lbl">Trạng thái</label>
            <select class="fld" v-model="form.isActive">
              <option :value="true">Hiển thị</option>
              <option :value="false">Ẩn</option>
            </select>
          </div>
        </div>

        <!-- Mô tả: cố tình để to nhất trong form vì đây là nội dung khách xem nhiều nhất -->
        <label class="lbl">Mô tả</label>
        <textarea
          class="fld"
          v-model="form.description"
          rows="10"
          style="padding: 10px 14px; resize: vertical; min-height: 220px"
        ></textarea>
        <div style="font-size: 11px; color: var(--muted); margin: 4px 0 0">
          Gõ "- " ở đầu dòng để tạo gạch đầu dòng, nhấn Enter để xuống dòng — hiển thị đúng định dạng ở trang sản phẩm.
        </div>

        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 20px; margin-top: 18px; align-items: start">
          <!-- Cột trái: cấu hình / tuỳ chọn / ưu đãi-giảm giá -->
          <div style="min-width: 0">
            <!-- Cấu hình (thông số kỹ thuật) -->
            <div class="sec-head" style="flex-wrap: wrap; gap: 6px 14px">
              <span>Cấu hình</span>
              <span style="display: flex; gap: 14px; flex-wrap: wrap">
                <button class="add-link" @click="openTemplatePicker" style="white-space: nowrap">
                  <i class="bi bi-magic"></i> Thêm bộ đã cấu hình sẵn
                </button>
                <button class="add-link" @click="addSpec" style="white-space: nowrap"><i class="bi bi-plus"></i> Thêm tự</button>
              </span>
            </div>

            <div v-if="showTemplatePicker" style="background: var(--card); border: 1px solid var(--line2); border-radius: 10px; padding: 10px; margin-bottom: 10px">
              <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px">
                <input
                  class="fld"
                  v-model="templateSearch"
                  placeholder="Tìm mẫu cấu hình, VD: PC Gaming..."
                  style="flex: 1; min-width: 0"
                  autofocus
                />
                <button class="rm" @click="showTemplatePicker = false" title="Đóng"><i class="bi bi-x-lg"></i></button>
              </div>
              <div v-if="kitTemplatesLoading" style="font-size: 12px; color: var(--muted); padding: 8px 2px">Đang tải danh sách mẫu...</div>
              <div v-else style="max-height: 220px; overflow-y: auto; display: flex; flex-direction: column; gap: 6px">
                <div
                  v-for="t in filteredKitTemplates"
                  :key="t.id"
                  @click="applyKitTemplate(t.id)"
                  style="display: flex; align-items: center; justify-content: space-between; gap: 10px; padding: 9px 11px; border-radius: 8px; border: 1px solid var(--line); cursor: pointer; background: var(--bg)"
                >
                  <div style="min-width: 0">
                    <div style="font-size: 12.5px; font-weight: 600; color: var(--text)">{{ t.name }}</div>
                    <div style="font-size: 10.5px; color: var(--muted); margin-top: 2px">{{ t.itemCount }} linh kiện</div>
                  </div>
                  <span class="mono" style="font-size: 12px; font-weight: 700; color: var(--acc); white-space: nowrap">{{ money(t.totalSuggestedPrice) }}</span>
                </div>
                <div v-if="!filteredKitTemplates.length" style="font-size: 12px; color: var(--muted); padding: 8px 2px">Không tìm thấy mẫu cấu hình phù hợp.</div>
              </div>
            </div>

            <div class="row5">
              <label style="font-size: 12.5px; color: var(--muted2); white-space: nowrap">Bảo hành (tháng)</label>
              <input class="fld" type="number" min="0" max="120" v-model.number="form.warrantyMonths" placeholder="36" style="width: 90px" />
            </div>

            <div v-for="(s, i) in form.specs" :key="'spec' + i" class="row5">
              <input class="fld" v-model="s.specKey" placeholder="VD: CPU" style="flex: 1" />
              <input class="fld" v-model="s.specValue" placeholder="VD: Intel Core i5-13450HX" style="flex: 2" />
              <button class="rm" @click="form.specs.splice(i, 1)"><i class="bi bi-trash3"></i></button>
            </div>

            <!-- Tuỳ chọn / cấu hình (option -> variant) -->
            <div class="sec-head">
              <span>Tuỳ chọn cấu hình (sinh biến thể)</span>
              <button class="add-link" @click="addOption"><i class="bi bi-plus"></i> Thêm nhóm</button>
            </div>
            <div v-for="(o, oi) in form.options" :key="'opt' + oi"
                 style="background: var(--card); border: 1px solid var(--line); border-radius: 10px; padding: 10px; margin-bottom: 8px">
              <div class="row5" style="margin-bottom: 6px">
                <input class="fld" v-model="o.optionName" placeholder="Tên nhóm, VD: CPU" style="flex: 1" />
                <button class="rm" @click="form.options.splice(oi, 1)"><i class="bi bi-trash3"></i></button>
              </div>
              <div v-for="(val, vi) in o.values" :key="'val' + oi + '-' + vi" class="row5" style="padding-left: 16px">
                <input class="fld" v-model="val.value" placeholder="Giá trị, VD: i5-13400F" style="flex: 1" />
                <input class="fld" type="text" inputmode="numeric" :value="fmtMoneyInput(val.priceExtra)" @input="val.priceExtra = parseMoneyInput($event.target.value)" placeholder="Phụ phí" style="width: 110px" />
                <button class="rm" @click="o.values.splice(vi, 1)"><i class="bi bi-trash3"></i></button>
              </div>
              <button class="add-link" @click="o.values.push(blankValue())" style="margin-left: 16px">
                <i class="bi bi-plus"></i> Thêm giá trị
              </button>
              <div style="margin-top: 8px; padding-left: 16px; padding-top: 8px; border-top: 1px solid var(--line)">
                <label style="font-size: 11px; color: var(--muted2); display: block; margin-bottom: 4px">
                  Khoá cùng cặp với (bắt buộc đi cùng nhau — chỉ những tổ hợp bạn tự thêm mới hợp lệ)
                </label>
                <select class="fld" :value="linkedPartnerIdx(oi)" @change="setLinkedGroup(oi, $event.target.value)" style="max-width: 260px">
                  <option value="">-- Độc lập (tự do phối) --</option>
                  <option v-for="opt in otherOptionsFor(oi)" :key="opt.oj" :value="opt.oj">
                    {{ opt.o.optionName || ('Nhóm ' + (opt.oj + 1)) }}
                  </option>
                </select>
              </div>
            </div>

            <!-- Ưu đãi / Giảm giá (biến thể: giá + kho) -->
            <div class="sec-head" style="flex-wrap: wrap; gap: 6px 14px">
              <span>Ưu đãi / Giảm giá (số lượng còn) *</span>
              <span style="display: flex; gap: 14px; flex-wrap: wrap">
                <button class="add-link" @click="generateVariants" :disabled="generating" style="white-space: nowrap">
                  <i class="bi bi-lightning-charge"></i> {{ generating ? 'Đang sinh...' : 'Sinh biến thể' }}
                </button>
                <button class="add-link" @click="addVariant" style="white-space: nowrap"><i class="bi bi-plus"></i> Thêm</button>
              </span>
            </div>
            <div v-for="(v, i) in form.variants" :key="'v' + i" class="row5">
              <input class="fld" v-model="v.sku" placeholder="SKU (để trống tự sinh)" />
              <input class="fld" type="text" inputmode="numeric" :value="fmtMoneyInput(v.price)" @input="v.price = parseMoneyInput($event.target.value)" placeholder="Giá bán" />
              <input class="fld" type="text" inputmode="numeric" :value="fmtMoneyInput(v.originalPrice)" @input="v.originalPrice = parseMoneyInput($event.target.value)" placeholder="Giá gốc" />
              <!-- min="0": tồn kho âm bị backend từ chối (AdminProductService.saveVariants),
                   chặn luôn ở ô nhập để admin không phải bấm Lưu mới biết. -->
              <input class="fld" type="number" min="0" v-model.number="v.stock" placeholder="Số lượng còn" />
              <button class="rm" @click="form.variants.splice(i, 1)"><i class="bi bi-trash3"></i></button>
            </div>
          </div>

          <!-- Cột phải: ảnh / khuyến mãi / mua kèm -->
          <div style="min-width: 0">
            <!-- Ảnh -->
            <div class="sec-head">
              <span>Hình ảnh</span>
              <button class="add-link" @click="addImage"><i class="bi bi-plus"></i> Thêm</button>
            </div>
            <div v-for="(img, i) in form.images" :key="'img' + i" class="row5">
              <input class="fld" v-model="img.url" placeholder="URL ảnh" style="flex: 1; min-width: 0" />
              <label style="display:flex;align-items:center;gap:6px;font-size:12px;color:var(--muted2);white-space:nowrap">
                <input type="checkbox" :checked="img.isPrimary" @change="setPrimaryImage(i, $event.target.checked)" /> Ảnh chính
              </label>
              <label class="upload-btn">
                <i class="bi bi-upload"></i>
                <input type="file" accept="image/*" @change="onUploadImage(i, $event)" style="display:none" />
              </label>
              <button class="rm" @click="removeImage(i)"><i class="bi bi-trash3"></i></button>
            </div>

            <!-- Khuyến mãi: cố tình nhỏ gọn (~2 dòng), quá 2 dòng thì cuộn riêng bên trong -->
            <div class="sec-head">
              <span>Khuyến mãi đi kèm</span>
              <button class="add-link" @click="addPromotion"><i class="bi bi-plus"></i> Thêm</button>
            </div>
            <div style="max-height: 84px; overflow-y: auto; padding-right: 2px">
              <div v-for="(p, i) in form.promotions" :key="'promo' + i" class="row5">
                <input class="fld" v-model="p.content" placeholder="VD: Tặng chuột không dây" style="flex: 1; min-width: 0" />
                <button class="rm" @click="form.promotions.splice(i, 1)"><i class="bi bi-trash3"></i></button>
              </div>
            </div>

            <!-- Mua kèm: chỉ thiết bị ngoại vi -->
            <div class="sec-head">
              <span>Gợi ý mua kèm (thiết bị ngoại vi)</span>
            </div>
            <div style="display: flex; gap: 6px; overflow-x: auto; padding: 4px 2px 8px">
              <div
                v-for="p in peripheralProducts"
                :key="p.id"
                @click="toggleBundle(p.id)"
                style="flex: none; width: 64px; cursor: pointer; position: relative; border-radius: 8px; border: 1px solid var(--line2); background: var(--card); padding: 4px; text-align: center"
              >
                <span
                  :style="{ background: form.bundleProductIds.includes(p.id) ? 'var(--acc)' : 'var(--bg)' }"
                  style="position: absolute; top: 4px; right: 4px; width: 14px; height: 14px; border-radius: 4px; border: 1px solid var(--line2); display: flex; align-items: center; justify-content: center; z-index: 1"
                >
                  <i v-if="form.bundleProductIds.includes(p.id)" class="bi bi-check-lg" style="font-size: 9px; color: var(--acc-ink)"></i>
                </span>
                <div style="width: 100%; aspect-ratio: 1/1; border-radius: 6px; overflow: hidden; background: linear-gradient(140deg, hsl(200 40% 18%), hsl(200 50% 10%)); margin-bottom: 4px">
                  <img v-if="p.imageUrl" :src="resolveImageUrl(p.imageUrl)" :alt="p.name" style="width: 100%; height: 100%; object-fit: cover" />
                </div>
                <div style="font-size: 9px; color: var(--text); line-height: 1.2; height: 21px; overflow: hidden">{{ p.name }}</div>
                <div style="font-size: 8.5px; color: var(--muted2); margin-top: 1px">{{ p.priceFmt }}</div>
              </div>
              <div v-if="!peripheralProducts.length" style="font-size: 12px; color: var(--muted); padding: 10px">
                Chưa có sản phẩm thiết bị ngoại vi nào.
              </div>
            </div>
            <input class="fld" v-model="bundleSearch" placeholder="Tìm sản phẩm ngoại vi để thêm..." />
            <div v-if="bundleSearchResults.length" style="border: 1px solid var(--line2); border-radius: 8px; margin-top: 6px; overflow: hidden">
              <div
                v-for="p in bundleSearchResults"
                :key="'s' + p.id"
                @click="toggleBundle(p.id); bundleSearch = ''"
                style="display: flex; align-items: center; justify-content: space-between; padding: 8px 10px; cursor: pointer; border-bottom: 1px solid var(--line)"
              >
                <span style="font-size: 12.5px; color: var(--text)">{{ p.name }}</span>
                <i v-if="form.bundleProductIds.includes(p.id)" class="bi bi-check-lg" style="color: var(--acc)"></i>
              </div>
            </div>
            <div v-if="form.bundleProductIds.length" style="font-size: 11px; color: var(--muted); margin-top: 6px">
              Đã chọn {{ form.bundleProductIds.length }} sản phẩm mua kèm.
            </div>
          </div>
        </div>
      </div>

      <div
        style="
          display: flex; justify-content: flex-end; gap: 10px;
          padding: 16px 22px; border-top: 1px solid var(--line); flex: none;
        "
      >
        <button @click="$emit('close')" class="btn-ghost">Hủy</button>
        <button
          @click="save"
          :disabled="saving"
          :style="{ opacity: saving ? 0.6 : 1 }"
          style="height: 42px; padding: 0 22px; border-radius: 10px; border: none; background: var(--acc); color: var(--acc-ink); font-weight: 700; font-size: 13px; cursor: pointer"
        >
          {{ saving ? 'Đang lưu...' : 'Lưu sản phẩm' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { PRODUCTS, money, fmtMoneyInput, parseMoneyInput } from '../data/adminData';
import { typeInfo } from '../data/kitComponentTypes';
import { resolveImageUrl } from '../api/http';
import {
  getAdminProductDetail, createAdminProduct, updateAdminProduct,
  uploadProductImage, getAdminBrands, getCategories, generateAdminVariants,
  getKitTemplates, getKitTemplateDetail,
} from '../api/admin';

const props = defineProps({ productId: { type: Number, default: null } });
const emit = defineEmits(['close', 'saved']);

const loading = ref(false);
const saving = ref(false);
const generating = ref(false);
const error = ref('');
const categories = ref([]);
const brands = ref([]);
const bundleSearch = ref('');

const form = reactive({
  name: '', slug: '', description: '',
  categoryId: null, brandId: null, isActive: true, warrantyMonths: 36,
  images: [], specs: [], promotions: [], options: [], variants: [], bundleProductIds: [],
  _slugTouched: false,
});

// Thương hiệu phụ thuộc danh mục: không có bảng liên kết brand<->category riêng, nên suy ra
// từ chính các sản phẩm hiện có (thương hiệu nào đã từng dùng cho danh mục này). Nếu danh mục
// chưa có sản phẩm/thương hiệu nào (mới tạo) thì hiện đủ danh sách để không bị bí lối chọn.
const brandsForCategory = computed(() => {
  if (!form.categoryId) return brands.value;
  const cat = categories.value.find((c) => c.id === form.categoryId);
  if (!cat) return brands.value;
  const namesInCategory = new Set(
    PRODUCTS.filter((p) => p.catSlug === cat.slug).map((p) => p.brand),
  );
  const filtered = brands.value.filter((b) => namesInCategory.has(b.name));
  return filtered.length ? filtered : brands.value;
});

const otherProducts = computed(() => PRODUCTS.filter((p) => p.id !== props.productId));
const peripheralProducts = computed(() => otherProducts.value.filter((p) => p.catSlug === 'ngoai-vi'));
const bundleSearchResults = computed(() => {
  const q = bundleSearch.value.trim().toLowerCase();
  if (!q) return [];
  return peripheralProducts.value.filter((p) => p.name.toLowerCase().includes(q)).slice(0, 8);
});
function toggleBundle(id) {
  const idx = form.bundleProductIds.indexOf(id);
  if (idx === -1) form.bundleProductIds.push(id);
  else form.bundleProductIds.splice(idx, 1);
}

// "Thêm bộ đã cấu hình sẵn": chọn 1 mẫu cấu hình có sẵn (Quản lý mẫu cấu hình) rồi lấy
// nguyên danh sách linh kiện thật của mẫu đó đổ vào Cấu hình, thay vì gõ tay từng dòng.
const showTemplatePicker = ref(false);
const templateSearch = ref('');
const kitTemplates = ref([]);
const kitTemplatesLoaded = ref(false);
const kitTemplatesLoading = ref(false);

async function openTemplatePicker() {
  showTemplatePicker.value = true;
  if (kitTemplatesLoaded.value) return;
  kitTemplatesLoading.value = true;
  try {
    kitTemplates.value = await getKitTemplates();
    kitTemplatesLoaded.value = true;
  } finally {
    kitTemplatesLoading.value = false;
  }
}
const filteredKitTemplates = computed(() => {
  const q = templateSearch.value.trim().toLowerCase();
  if (!q) return kitTemplates.value;
  return kitTemplates.value.filter((t) => t.name.toLowerCase().includes(q));
});
async function applyKitTemplate(id) {
  if (
    form.specs.length &&
    !window.confirm('Áp dụng mẫu cấu hình này sẽ thay thế toàn bộ Cấu hình hiện tại. Tiếp tục?')
  ) {
    return;
  }
  const d = await getKitTemplateDetail(id);
  form.specs = (d.items || []).map((it, i) => ({
    id: null,
    specKey: typeInfo(it.componentType).label,
    specValue: it.displayName,
    sortOrder: i,
  }));
  showTemplatePicker.value = false;
  templateSearch.value = '';
}

function newClientKey() {
  return 'v' + Math.random().toString(36).slice(2, 10);
}
function blankValue() {
  return { id: null, clientKey: newClientKey(), value: '', priceExtra: 0, isDefault: false, active: true, sortOrder: 0 };
}
function addVariant() {
  form.variants.push({ id: null, sku: '', price: null, originalPrice: null, stock: 0, isDefault: form.variants.length === 0, optionValueKeys: [] });
}
function addImage() {
  form.images.push({ id: null, url: '', isPrimary: form.images.length === 0, sortOrder: form.images.length });
}
function setPrimaryImage(i, checked) {
  if (checked) form.images.forEach((img, j) => { img.isPrimary = j === i; });
  else form.images[i].isPrimary = false;
}
function removeImage(i) {
  const wasPrimary = form.images[i].isPrimary;
  form.images.splice(i, 1);
  if (wasPrimary && form.images.length) form.images[0].isPrimary = true;
}
function addSpec() {
  form.specs.push({ id: null, specKey: '', specValue: '', sortOrder: form.specs.length });
}
function addPromotion() {
  form.promotions.push({ id: null, content: '', sortOrder: form.promotions.length });
}
function addOption() {
  form.options.push({ id: null, optionName: '', selectionType: 'single', minSelect: 0, maxSelect: 1, description: null, required: false, visible: true, sortOrder: form.options.length, linkedGroup: null, values: [blankValue()] });
}

function otherOptionsFor(oi) {
  return form.options.map((o, oj) => ({ o, oj })).filter((x) => x.oj !== oi);
}
function linkedPartnerIdx(oi) {
  const g = form.options[oi].linkedGroup;
  if (!g) return '';
  const idx = form.options.findIndex((o, oj) => oj !== oi && o.linkedGroup === g);
  return idx === -1 ? '' : idx;
}
function setLinkedGroup(oi, otherIdxRaw) {
  if (otherIdxRaw === '' || otherIdxRaw == null) {
    form.options[oi].linkedGroup = null;
    return;
  }
  const oj = Number(otherIdxRaw);
  const token = form.options[oj].linkedGroup || form.options[oi].linkedGroup || ('lg' + Math.random().toString(36).slice(2, 8));
  form.options[oi].linkedGroup = token;
  form.options[oj].linkedGroup = token;
}

function buildOptionsPayload() {
  return form.options
    .filter((o) => o.optionName && o.optionName.trim())
    .map((o) => ({
      ...o,
      values: o.values.filter((v) => v.value && v.value.trim()),
    }));
}

async function generateVariants() {
  generating.value = true;
  error.value = '';
  try {
    const additions = await generateAdminVariants(buildOptionsPayload(), form.variants);
    if (!additions.length) {
      error.value = 'Không có tổ hợp mới nào để sinh thêm (có thể do nhóm bị khoá cặp chưa có tổ hợp nào, hoặc mọi tổ hợp đã tồn tại).';
    } else {
      form.variants.push(...additions);
    }
  } catch (e) {
    error.value = 'Lỗi khi sinh biến thể';
  } finally {
    generating.value = false;
  }
}

function onNameInput() {
  if (!props.productId && !form._slugTouched) {
    form.slug = form.name.trim().toLowerCase()
      .normalize('NFD').replace(/[̀-ͯ]/g, '')
      .replace(/đ/g, 'd')
      .replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
  }
}

async function onUploadImage(i, ev) {
  const file = ev.target.files[0];
  if (!file) return;
  try {
    form.images[i].url = await uploadProductImage(file);
  } catch (e) {
    error.value = 'Lỗi tải ảnh lên';
  }
}

onMounted(async () => {
  try {
    const [cats, brs] = await Promise.all([getCategories(), getAdminBrands()]);
    categories.value = cats;
    brands.value = brs;
  } catch (e) {
    error.value = 'Không tải được danh mục / thương hiệu';
  }

  if (props.productId) {
    loading.value = true;
    try {
      const d = await getAdminProductDetail(props.productId);
      form.name = d.name;
      form.slug = d.slug;
      form._slugTouched = true;
      form.description = d.description || '';
      form.categoryId = d.categoryId;
      form.brandId = d.brandId;
      form.isActive = d.isActive;
      form.warrantyMonths = d.warrantyMonths ?? 36;
      form.images = d.images || [];
      form.specs = d.specs || [];
      form.promotions = d.promotions || [];
      form.options = (d.options || []).map((o) => ({
        ...o,
        values: (o.values || []).map((v) => ({ ...v, clientKey: v.clientKey || newClientKey() })),
      }));
      form.variants = d.variants || [];
      form.bundleProductIds = d.bundleProductIds || [];
    } catch (e) {
      error.value = 'Không tải được dữ liệu sản phẩm';
    } finally {
      loading.value = false;
    }
  } else {
    addVariant();
  }
});

async function save() {
  error.value = '';
  if (!form.name.trim()) { error.value = 'Vui lòng nhập tên sản phẩm'; return; }
  if (!form.categoryId) { error.value = 'Vui lòng chọn danh mục'; return; }
  if (!form.variants.length) { error.value = 'Cần ít nhất 1 biến thể (giá / kho)'; return; }

  const payload = {
    name: form.name.trim(),
    slug: form.slug.trim() || null,
    description: form.description,
    categoryId: form.categoryId,
    brandId: form.brandId,
    isActive: form.isActive,
    warrantyMonths: form.warrantyMonths || 36,
    images: form.images.filter((i) => i.url && i.url.trim()),
    specs: form.specs.filter((s) => s.specKey && s.specKey.trim()),
    promotions: form.promotions.filter((p) => p.content && p.content.trim()),
    options: buildOptionsPayload(),
    variants: form.variants,
    bundleProductIds: form.bundleProductIds,
  };

  saving.value = true;
  try {
    if (props.productId) {
      await updateAdminProduct(props.productId, payload);
    } else {
      await createAdminProduct(payload);
    }
    emit('saved');
  } catch (e) {
    error.value = e.response?.data?.message || 'Có lỗi khi lưu sản phẩm';
  } finally {
    saving.value = false;
  }
}
</script>

<style scoped>
.lbl {
  display: block;
  font-size: 12px;
  font-weight: 600;
  color: var(--muted2);
  margin: 12px 0 6px;
}
.sec-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin: 16px 0 8px;
  font-size: 12px;
  font-weight: 600;
  color: var(--muted2);
  text-transform: uppercase;
  letter-spacing: 0.4px;
}
.row5 {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}
.rm {
  flex: none;
  width: 34px;
  height: 34px;
  border-radius: 8px;
  border: 1px solid var(--line2);
  background: var(--card);
  color: var(--sale);
  cursor: pointer;
}
.add-link {
  background: none;
  border: none;
  color: var(--acc);
  font-size: 12.5px;
  font-weight: 600;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  text-transform: none;
  letter-spacing: normal;
}
.add-link:disabled {
  color: var(--muted);
  cursor: not-allowed;
}
.upload-btn {
  flex: none;
  width: 34px;
  height: 34px;
  border-radius: 8px;
  border: 1px solid var(--line2);
  background: var(--card);
  color: var(--muted2);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
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
