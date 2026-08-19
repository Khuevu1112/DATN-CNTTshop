<template>
  <div style="animation: fadeUp 0.35s ease">
    <div
      style="
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 14px;
        margin-bottom: 16px;
      "
    >
      <div
        v-for="s in stats"
        :key="s.label"
        style="
          background: var(--card);
          border: 1px solid var(--line);
          border-radius: 13px;
          padding: 14px 16px;
          display: flex;
          align-items: center;
          gap: 13px;
        "
      >
        <div
          style="
            width: 40px;
            height: 40px;
            border-radius: 10px;
            flex: none;
            display: flex;
            align-items: center;
            justify-content: center;
            background: color-mix(in srgb, var(--acc) 14%, transparent);
            color: var(--acc);
            font-size: 17px;
          "
        >
          <i class="bi" :class="s.icon"></i>
        </div>
        <div>
          <div
            class="mono"
            style="
              font-size: 21px;
              font-weight: 700;
              color: var(--text);
              line-height: 1;
            "
          >
            {{ s.value }}
          </div>
          <div style="font-size: 11.5px; color: var(--muted); margin-top: 4px">
            {{ s.label }}
          </div>
        </div>
      </div>
    </div>
    <!-- Danh mục (gộp từ Quản lý danh mục): bấm 1 thẻ để lọc danh sách sản phẩm bên dưới -->
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px">
      <div style="font-size: 13.5px; color: var(--muted)">{{ categoryCards.length }} danh mục đang hoạt động</div>
      <button
        @click="showAddCategory = !showAddCategory"
        style="display: flex; align-items: center; gap: 7px; height: 36px; padding: 0 15px; border-radius: 9px; border: none; background: var(--acc); color: var(--acc-ink); font-size: 12.5px; font-weight: 700; cursor: pointer"
      >
        <i class="bi bi-plus-lg"></i> Thêm danh mục
      </button>
    </div>
    <div
      v-if="showAddCategory"
      style="display: flex; gap: 8px; align-items: center; background: var(--card); border: 1px solid var(--line); border-radius: 12px; padding: 12px; margin-bottom: 14px"
    >
      <input
        v-model="newCategoryName"
        @keyup.enter="addCategory"
        placeholder="Tên danh mục mới, VD: Điện thoại"
        style="flex: 1; height: 36px; padding: 0 12px; border-radius: 8px; background: var(--card2); border: 1px solid var(--line2); color: var(--text); font-size: 13px"
      />
      <button
        @click="addCategory"
        :disabled="savingCategory"
        style="height: 36px; padding: 0 16px; border-radius: 8px; border: none; background: var(--acc); color: var(--acc-ink); font-weight: 700; font-size: 12.5px; cursor: pointer"
      >
        {{ savingCategory ? 'Đang thêm...' : 'Lưu' }}
      </button>
    </div>
    <div v-if="categoryError" style="color: var(--sale); font-size: 12.5px; margin-bottom: 12px">{{ categoryError }}</div>

    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 20px">
      <div
        @click="cat = 'all'"
        :style="{ boxShadow: cat === 'all' ? '0 0 0 2px var(--acc)' : 'none' }"
        style="background: var(--card); border: 1px solid var(--line); border-radius: 15px; overflow: hidden; cursor: pointer"
      >
        <div style="height: 78px; position: relative; display: flex; align-items: flex-end; padding: 12px 14px; overflow: hidden; background: linear-gradient(135deg, hsl(220 14% 30%), hsl(220 18% 14%))">
          <div style="position: absolute; inset: 0; background: repeating-linear-gradient(125deg, rgba(255,255,255,.05) 0 2px, transparent 2px 13px)"></div>
          <div style="position: relative; font-size: 15.5px; font-weight: 700; color: #fff">Tất cả</div>
        </div>
        <div style="padding: 12px 14px; display: grid; grid-template-columns: repeat(3, 1fr); gap: 6px">
          <div>
            <div class="mono" style="font-size: 15px; font-weight: 700; color: var(--text)">{{ PRODUCTS.length }}</div>
            <div style="font-size: 10px; color: var(--muted); margin-top: 2px">Sản phẩm</div>
          </div>
          <div>
            <div class="mono" style="font-size: 15px; font-weight: 700; color: var(--text)">{{ PRODUCTS.reduce((a, p) => a + p.stock, 0) }}</div>
            <div style="font-size: 10px; color: var(--muted); margin-top: 2px">Tồn kho</div>
          </div>
          <div>
            <div class="mono" style="font-size: 15px; font-weight: 700; color: var(--acc)">{{ short(PRODUCTS.reduce((a, p) => a + p.price * p.stock, 0)) }}</div>
            <div style="font-size: 10px; color: var(--muted); margin-top: 2px">Giá trị</div>
          </div>
        </div>
      </div>
      <div
        v-for="c in categoryCards"
        :key="c.key"
        @click="cat = c.key"
        :style="{ boxShadow: cat === c.key ? '0 0 0 2px var(--acc)' : 'none' }"
        style="background: var(--card); border: 1px solid var(--line); border-radius: 15px; overflow: hidden; cursor: pointer"
      >
        <div style="height: 78px; position: relative; display: flex; align-items: flex-end; padding: 12px 14px; overflow: hidden" :style="{ background: c.bg }">
          <div style="position: absolute; inset: 0; background: repeating-linear-gradient(125deg, rgba(255,255,255,.05) 0 2px, transparent 2px 13px)"></div>
          <div style="position: relative; font-size: 15.5px; font-weight: 700; color: #fff">{{ c.name }}</div>
        </div>
        <div style="padding: 12px 14px; display: grid; grid-template-columns: repeat(3, 1fr); gap: 6px">
          <div>
            <div class="mono" style="font-size: 15px; font-weight: 700; color: var(--text)">{{ c.count }}</div>
            <div style="font-size: 10px; color: var(--muted); margin-top: 2px">Sản phẩm</div>
          </div>
          <div>
            <div class="mono" style="font-size: 15px; font-weight: 700; color: var(--text)">{{ c.stock }}</div>
            <div style="font-size: 10px; color: var(--muted); margin-top: 2px">Tồn kho</div>
          </div>
          <div>
            <div class="mono" style="font-size: 15px; font-weight: 700" :style="{ color: c.color }">{{ c.value }}</div>
            <div style="font-size: 10px; color: var(--muted); margin-top: 2px">Giá trị</div>
          </div>
        </div>
      </div>
    </div>

    <div
      style="
        background: var(--card);
        border: 1px solid var(--line);
        border-radius: 14px;
        overflow: hidden;
      "
    >
      <div
        style="
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 12px 16px;
          border-bottom: 1px solid var(--line);
          flex-wrap: wrap;
        "
      >
        <!-- Ba ô lọc cũ (hãng / trạng thái / tồn kho) đã bỏ: DataTable có phễu ngay trên
             mỗi cột, lọc được theo mọi cột chứ không chỉ ba cột này. -->
        <div style="flex: 1"></div>
        <span class="mono" style="font-size: 11.5px; color: var(--muted)">{{ rows.length }} sản phẩm</span>
        <button
          @click="stockModalOpen = true"
          style="
            display: flex;
            align-items: center;
            gap: 7px;
            height: 34px;
            padding: 0 14px;
            border-radius: 9px;
            border: 1px solid var(--line2);
            background: var(--card);
            color: var(--text);
            font-size: 12.5px;
            font-weight: 700;
            cursor: pointer;
          "
        >
          <i class="bi bi-sliders"></i> Điều chỉnh kho
        </button>
        <!-- Nhập hàng THẬT (có nhà cung cấp, hoá đơn, nhiều dòng, in được chứng từ) nằm ở trang
             riêng; nút bên cạnh chỉ dành cho sửa tồn lẻ khi kiểm kê lệch. -->
        <button
          @click="$router.push('/goods-receipts')"
          style="
            display: flex;
            align-items: center;
            gap: 7px;
            height: 34px;
            padding: 0 14px;
            border-radius: 9px;
            border: 1px solid var(--line2);
            background: var(--card);
            color: var(--text);
            font-size: 12.5px;
            font-weight: 700;
            cursor: pointer;
          "
        >
          <i class="bi bi-box-arrow-in-down"></i> Nhập kho
        </button>
        <button
          @click="openCreate"
          style="
            display: flex;
            align-items: center;
            gap: 7px;
            height: 34px;
            padding: 0 14px;
            border-radius: 9px;
            border: none;
            background: var(--acc);
            color: var(--acc-ink);
            font-size: 12.5px;
            font-weight: 700;
            cursor: pointer;
          "
        >
          <i class="bi bi-plus-lg"></i> Thêm sản phẩm
        </button>
      </div>
      <DataTable
        :columns="cols"
        :rows="rows"
        :tim-kiem="ui.search"
        click-duoc
        trong="Chưa có sản phẩm nào."
        @row-click="(p) => (detailProductId = p.id)"
      >
        <template #o-name="{ row: p }">
          <!-- Rê vào ô tên = mở thẻ xem nhanh (mô tả, linh kiện, biến thể + tồn từng biến thể).
               Gắn ở ô thay vì cả dòng để rê qua phễu lọc ở đầu cột không bật thẻ. -->
          <div
            style="display: flex; align-items: center; gap: 11px"
            @mouseenter="onRowEnter(p, $event)"
            @mousemove="onRowMove($event)"
            @mouseleave="onRowLeave"
          >
            <div
              class="mono"
              style="width: 40px; height: 40px; border-radius: 9px; flex: none; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 700"
              :style="{ background: grad(p.hue), color: gradText(p.hue) }"
            >
              {{ p.tag }}
            </div>
            <div style="min-width: 0">
              <div style="font-size: 13px; font-weight: 500; color: var(--text)">{{ p.name }}</div>
              <div class="mono" style="font-size: 11px; color: var(--muted); margin-top: 2px">
                {{ p.sku }} · {{ p.spec }}
              </div>
            </div>
          </div>
        </template>
        <template #o-cat="{ row: p }">
          <span style="font-size: 12px; color: var(--muted2)">{{ p.cat }}</span>
        </template>
        <template #o-brand="{ row: p }">
          <span style="font-size: 12.5px">{{ p.brand }}</span>
        </template>
        <template #o-price="{ row: p }">
          <div class="mono" style="font-size: 13.5px; font-weight: 700; color: var(--text)">{{ p.priceFmt }}</div>
          <div v-if="p.oldp" style="display: flex; align-items: center; justify-content: flex-end; gap: 6px; margin-top: 2px">
            <span class="mono" style="font-size: 10.5px; color: var(--muted); text-decoration: line-through">{{ p.oldFmt }}</span>
            <span class="mono" style="font-size: 10px; font-weight: 700; color: var(--sale)">-{{ p.disc }}%</span>
          </div>
        </template>
        <template #o-stock="{ row: p }">
          <div style="display: flex; align-items: center; gap: 8px">
            <span class="mono" style="font-size: 13px; font-weight: 700; width: 24px" :style="{ color: stockColor(p.stock) }">{{ p.stock }}</span>
            <div style="flex: 1; height: 5px; border-radius: 4px; background: var(--card2); overflow: hidden">
              <div
                style="height: 100%; border-radius: 4px"
                :style="{ width: Math.min(100, Math.round((p.stock / 50) * 100)) + '%', background: stockColor(p.stock) }"
              ></div>
            </div>
          </div>
        </template>
        <template #o-active="{ row: p }">
          <span
            style="display: inline-flex; align-items: center; gap: 5px; font-size: 11.5px; font-weight: 600; padding: 3px 9px; border-radius: 20px"
            :style="{
              background: p.active ? 'color-mix(in srgb,var(--green) 16%,transparent)' : 'var(--card2)',
              color: p.active ? 'var(--green)' : 'var(--muted)',
            }"
          >
            <span style="width: 6px; height: 6px; border-radius: 50%" :style="{ background: p.active ? 'var(--green)' : 'var(--muted)' }"></span>
            {{ p.active ? 'Hiển thị' : 'Ẩn' }}
          </span>
        </template>
        <template #o-thaoTac>
          <i class="bi bi-three-dots-vertical" style="color: var(--muted); font-size: 15px"></i>
        </template>
      </DataTable>
    </div>

    <!-- Thẻ xem nhanh khi rê chuột: mô tả + linh kiện + từng biến thể kèm tình trạng kho.
         Ẩn khi đang mở modal để hai lớp không chồng lên nhau. -->
    <ProductHoverCard
      v-if="hoverRow && !detailProductId && !formOpen"
      :row="hoverRow"
      :data="hoverData"
      :anchor="hoverPos"
    />

    <ProductDetailModal
      v-if="detailProductId"
      :product-id="detailProductId"
      @close="detailProductId = null"
      @edit="onEditFromDetail"
      @deleted="onDeletedFromDetail"
    />

    <ProductFormModal
      v-if="formOpen"
      :product-id="formProductId"
      @close="formOpen = false"
      @saved="onSaved"
    />

    <StockMovementModal
      v-if="stockModalOpen"
      @close="stockModalOpen = false"
      @saved="onStockChanged"
    />
  </div>
</template>

<script setup>
import { ref, computed, onBeforeUnmount } from 'vue';
import { PRODUCTS, CATS, short, grad, gradText, gradCat, refreshAdminProducts, refreshAdminCategories } from '../data/adminData';
import { ui } from '../uiState';
import { createCategory, getAdminProductDetail } from '../api/admin';
import ProductFormModal from '../components/ProductFormModal.vue';
import ProductDetailModal from '../components/ProductDetailModal.vue';
import ProductHoverCard from '../components/ProductHoverCard.vue';
import DataTable from '../components/DataTable.vue';
import StockMovementModal from '../components/StockMovementModal.vue';

const cat = ref('all');
const detailProductId = ref(null);
const formOpen = ref(false);
const formProductId = ref(null);
const stockModalOpen = ref(false);

// ===== Thẻ xem nhanh khi rê chuột =====
// Rê ngang bảng là lướt qua hàng chục dòng, nên KHÔNG gọi API ngay: chờ TRE_HIEN ms xem chuột
// có dừng lại thật không. Kết quả nhớ đệm theo id để rê qua rê lại cùng một dòng chỉ tốn đúng
// một request cho cả phiên.
const TRE_HIEN = 260;
const hoverRow = ref(null);
const hoverData = ref(null);
const hoverPos = ref({ x: 0, y: 0 });
const boNhoDem = new Map();
let hoverTimer = null;

function onRowEnter(p, e) {
  clearTimeout(hoverTimer);
  hoverPos.value = { x: e.clientX, y: e.clientY };
  hoverTimer = setTimeout(() => {
    hoverRow.value = p;
    hoverData.value = boNhoDem.get(p.id) || null;
    if (!hoverData.value) taiChiTiet(p.id);
  }, TRE_HIEN);
}

async function taiChiTiet(id) {
  try {
    const d = await getAdminProductDetail(id);
    boNhoDem.set(id, d);
    // Chuột có thể đã rời sang dòng khác trong lúc chờ mạng -> chỉ gán nếu vẫn đúng dòng đó.
    if (hoverRow.value?.id === id) hoverData.value = d;
  } catch (e) {
    if (hoverRow.value?.id === id) hoverRow.value = null; // lỗi mạng -> ẩn thẻ, không báo ồn ào
  }
}

function onRowMove(e) {
  if (!hoverRow.value) hoverPos.value = { x: e.clientX, y: e.clientY };
}
function onRowLeave() {
  clearTimeout(hoverTimer);
  hoverRow.value = null;
  hoverData.value = null;
}
// Sửa/thêm sản phẩm xong thì dữ liệu đã đệm là cũ -> bỏ hết, lần rê sau nạp lại.
function xoaBoNhoDem() {
  boNhoDem.clear();
}
async function onStockChanged() {
  xoaBoNhoDem(); // vừa nhập/điều chỉnh kho -> tồn trong thẻ xem nhanh đã cũ
  await refreshAdminProducts();
}
onBeforeUnmount(() => clearTimeout(hoverTimer));

function openCreate() {
  formProductId.value = null;
  formOpen.value = true;
}
function onEditFromDetail(id) {
  detailProductId.value = null;
  formProductId.value = id;
  formOpen.value = true;
}
async function onSaved() {
  formOpen.value = false;
  xoaBoNhoDem();
  await refreshAdminProducts();
}
async function onDeletedFromDetail() {
  detailProductId.value = null;
  xoaBoNhoDem();
  await refreshAdminProducts();
}
// Cột cho DataTable — mỗi cột có phễu lọc/sắp xếp kiểu Excel (xem components/DataTable.vue).
// Ba ô select cũ (hãng / trạng thái / tồn kho) đã bỏ: phễu ngay trên đầu cột làm được nhiều hơn.
const cols = [
  { key: 'name', label: 'Sản phẩm', text: (p) => p.name + ' · ' + p.sku },
  { key: 'cat', label: 'Danh mục' },
  { key: 'brand', label: 'Hãng' },
  { key: 'price', label: 'Giá bán', align: 'right', kieu: 'so', value: (p) => p.price, text: (p) => p.priceFmt },
  { key: 'stock', label: 'Tồn kho', kieu: 'so' },
  { key: 'active', label: 'Trạng thái', text: (p) => (p.active ? 'Hiển thị' : 'Ẩn') },
  { key: 'thaoTac', label: '', align: 'center', loc: false },
];
// Danh mục (gộp từ Quản lý danh mục cũ) — click 1 thẻ = lọc bảng sản phẩm bên dưới theo cat.value
const showAddCategory = ref(false);
const newCategoryName = ref('');
const savingCategory = ref(false);
const categoryError = ref('');

const categoryCards = computed(() =>
  Object.keys(CATS).map((k) => {
    const ps = PRODUCTS.filter((p) => p.catSlug === k);
    return {
      key: k,
      name: CATS[k].label,
      bg: gradCat(CATS[k].hue),
      color: gradText(CATS[k].hue),
      count: ps.length + '',
      stock: ps.reduce((a, p) => a + p.stock, 0) + '',
      value: short(ps.reduce((a, p) => a + p.price * p.stock, 0)),
    };
  }),
);

async function addCategory() {
  if (!newCategoryName.value.trim()) {
    categoryError.value = 'Vui lòng nhập tên danh mục';
    return;
  }
  categoryError.value = '';
  savingCategory.value = true;
  try {
    await createCategory(newCategoryName.value.trim());
    await refreshAdminCategories();
    newCategoryName.value = '';
    showAddCategory.value = false;
  } catch (e) {
    categoryError.value = e.response?.data?.message || 'Có lỗi khi thêm danh mục';
  } finally {
    savingCategory.value = false;
  }
}
// Lọc theo hãng / trạng thái / tồn kho và tìm theo từ khoá đã chuyển hết vào phễu từng cột của
// DataTable — ở đây chỉ còn lọc theo DANH MỤC, vì đó là các thẻ danh mục bấm được phía trên
// bảng (một lối vào riêng, không phải bộ lọc cột).
const rows = computed(() =>
  PRODUCTS.filter((p) => cat.value === 'all' || p.catSlug === cat.value),
);
const stockColor = (s) =>
  s <= 5 ? 'var(--sale)' : s <= 12 ? 'var(--amber)' : 'var(--green)';
const stats = computed(() => [
  { label: 'Tổng sản phẩm', value: PRODUCTS.length + '', icon: 'bi-box-seam' },
  {
    label: 'Đang hiển thị',
    value: PRODUCTS.filter((p) => p.active).length + '',
    icon: 'bi-eye',
  },
  {
    label: 'Sắp hết hàng',
    value: PRODUCTS.filter((p) => p.stock <= 5).length + '',
    icon: 'bi-exclamation-triangle',
  },
  {
    label: 'Giá trị tồn kho',
    value: short(PRODUCTS.reduce((a, p) => a + p.price * p.stock, 0)),
    icon: 'bi-cash-stack',
  },
]);
</script>
