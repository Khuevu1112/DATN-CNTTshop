<script setup>
import { computed } from 'vue';
import { resolveImageUrl } from '../api/http';
import { CATS, NGUONG_SAP_HET } from '../data/adminData';

/**
 * Thẻ xem nhanh sản phẩm khi rê chuột ở bảng Quản lý sản phẩm.
 *
 * Vì sao cần: bảng chỉ có tên + giá + TỔNG tồn, nên muốn biết một sản phẩm gồm linh kiện gì, có
 * mấy biến thể và biến thể NÀO sắp hết thì phải mở modal chi tiết cho từng dòng một. Thẻ này trả
 * lời đúng những câu đó ngay tại chỗ, không rời khỏi bảng.
 *
 * Dùng lại API /admin/products/{id} sẵn có (đã trả description + specs + options + variants),
 * không thêm endpoint mới. Việc nạp + nhớ đệm theo id nằm ở Products.vue.
 */
const props = defineProps({
  data: { type: Object, default: null },    // AdminProductDetailDto; null = đang tải
  row: { type: Object, required: true },    // dòng trong bảng (tên/hãng/danh mục đã có sẵn)
  anchor: { type: Object, required: true }, // { x, y } vị trí con trỏ lúc rê vào
});

const RONG = 460;
const CAO_TOI_DA = 560;

// Bám theo con trỏ nhưng luôn nằm trọn trong màn hình: hết chỗ bên phải thì lật sang trái, hết
// chỗ bên dưới thì đẩy lên. Không làm vậy thì các dòng cuối bảng luôn hiện thẻ bị cắt mất đuôi.
const viTri = computed(() => {
  const { x, y } = props.anchor;
  const vw = window.innerWidth;
  const vh = window.innerHeight;
  const left = x + 24 + RONG > vw ? Math.max(12, x - 24 - RONG) : x + 24;
  const top = Math.min(Math.max(12, y - 40), Math.max(12, vh - CAO_TOI_DA - 12));
  return { left: left + 'px', top: top + 'px', width: RONG + 'px', maxHeight: CAO_TOI_DA + 'px' };
});

function money(n) {
  return (Number(n) || 0).toLocaleString('vi-VN') + '₫';
}

/** clientKey -> giá trị tuỳ chọn, để mỗi biến thể đọc được là phiên bản nào chứ không chỉ SKU. */
const nhanTheoKhoa = computed(() => {
  const m = {};
  for (const o of props.data?.options || []) {
    for (const v of o.values || []) {
      if (v.clientKey) m[v.clientKey] = v.value;
    }
  }
  return m;
});

function nhanBienThe(v) {
  const nhan = (v.optionValueKeys || []).map((k) => nhanTheoKhoa.value[k]).filter(Boolean);
  return nhan.length ? nhan.join(' · ') : null;
}

// Ba mức tồn kho, dùng chung ngưỡng với phía khách (NGUONG_SAP_HET).
function tinhTrang(stock) {
  const n = Number(stock) || 0;
  if (n <= 0) return { nhan: 'Hết hàng', mau: '#ff3b5c' };
  if (n <= NGUONG_SAP_HET) return { nhan: 'Sắp hết', mau: '#f59e0b' };
  return { nhan: 'Còn hàng', mau: '#22d39a' };
}

// Biến thể mặc định lên đầu — đó là bản khách nhìn thấy giá/tồn trên thẻ sản phẩm.
const variants = computed(() =>
  (props.data?.variants || []).slice().sort((a, b) => (b.isDefault ? 1 : 0) - (a.isDefault ? 1 : 0)),
);
const tongTon = computed(() => variants.value.reduce((a, v) => a + (Number(v.stock) || 0), 0));
const soHetHang = computed(() => variants.value.filter((v) => (Number(v.stock) || 0) <= 0).length);
const soSapHet = computed(
  () =>
    variants.value.filter((v) => {
      const n = Number(v.stock) || 0;
      return n > 0 && n <= NGUONG_SAP_HET;
    }).length,
);

const khoangGia = computed(() => {
  const gia = variants.value.map((v) => Number(v.price) || 0);
  if (!gia.length) return '—';
  const min = Math.min(...gia);
  const max = Math.max(...gia);
  return min === max ? money(min) : money(min) + ' – ' + money(max);
});

const anhChinh = computed(() => {
  const imgs = props.data?.images || [];
  const img = imgs.find((i) => i.isPrimary) || imgs[0];
  return img ? resolveImageUrl(img.url) : '';
});

const tenDanhMuc = computed(() => CATS[props.row.catSlug]?.label || props.row.cat || '');

// Mô tả chỉ để liếc nhanh -> cắt gọn; xem đầy đủ thì bấm mở modal chi tiết.
const moTaNgan = computed(() => {
  const t = (props.data?.description || '').replace(/\s+/g, ' ').trim();
  if (!t) return '';
  return t.length > 260 ? t.slice(0, 260).trimEnd() + '…' : t;
});
</script>

<template>
  <Teleport to="body">
    <div class="phc" :style="viTri">
      <!-- Đầu thẻ: ảnh + tên + danh mục/hãng + cờ đang ẩn -->
      <div class="phc-head">
        <div class="phc-thumb">
          <img v-if="anhChinh" :src="anhChinh" alt="" />
          <span v-else class="mono">{{ row.tag }}</span>
        </div>
        <div style="min-width: 0; flex: 1">
          <div class="phc-name">{{ row.name }}</div>
          <div class="phc-sub">{{ tenDanhMuc }} · {{ row.brand }}</div>
        </div>
        <span
          v-if="data && !data.isActive"
          class="phc-pill"
          style="color: #ff3b5c; border-color: #ff3b5c"
          >Đang ẩn</span
        >
      </div>

      <div v-if="!data" class="phc-loading">Đang tải chi tiết…</div>

      <template v-else>
        <!-- Tóm tắt: khoảng giá + tổng tồn -->
        <div class="phc-sum">
          <div>
            <div class="phc-label" style="margin: 0 0 3px">Giá bán</div>
            <div class="mono phc-price">{{ khoangGia }}</div>
          </div>
          <div style="text-align: right">
            <div class="phc-label" style="margin: 0 0 3px">Tổng kho</div>
            <div class="mono phc-price" :style="{ color: tinhTrang(tongTon).mau }">{{ tongTon }}</div>
          </div>
        </div>
        <div v-if="soHetHang || soSapHet" class="phc-warn">
          <template v-if="soHetHang">{{ soHetHang }} biến thể đã hết hàng</template>
          <template v-if="soHetHang && soSapHet"> · </template>
          <template v-if="soSapHet">{{ soSapHet }} biến thể sắp hết (còn ≤ {{ NGUONG_SAP_HET }})</template>
        </div>

        <div class="phc-body">
          <template v-if="moTaNgan">
            <div class="phc-label">Mô tả</div>
            <div class="phc-desc">{{ moTaNgan }}</div>
          </template>

          <!-- Linh kiện chi tiết (PRODUCT_SPEC) -->
          <template v-if="data.specs && data.specs.length">
            <div class="phc-label">Linh kiện chi tiết</div>
            <div class="phc-specs">
              <div v-for="(s, i) in data.specs" :key="s.id || i" class="phc-spec">
                <span class="phc-spec-k">{{ s.specKey }}</span>
                <span class="phc-spec-v">{{ s.specValue }}</span>
              </div>
            </div>
          </template>

          <!-- Từng biến thể kèm tình trạng kho riêng -->
          <div class="phc-label">Biến thể &amp; tồn kho ({{ variants.length }})</div>
          <div v-if="!variants.length" class="phc-desc">Sản phẩm chưa có biến thể nào.</div>
          <div v-else class="phc-vars">
            <div v-for="(v, i) in variants" :key="v.id || i" class="phc-var">
              <div style="min-width: 0; flex: 1">
                <div class="phc-var-name">
                  {{ nhanBienThe(v) || v.sku }}
                  <span v-if="v.isDefault" class="phc-default">mặc định</span>
                </div>
                <div v-if="nhanBienThe(v)" class="mono phc-var-sku">{{ v.sku }}</div>
              </div>
              <span class="mono phc-var-price">{{ money(v.price) }}</span>
              <span class="phc-var-stock" :style="{ color: tinhTrang(v.stock).mau }">
                {{ tinhTrang(v.stock).nhan }}
                <b class="mono">{{ Number(v.stock) || 0 }}</b>
              </span>
            </div>
          </div>
        </div>

        <div class="phc-foot">Bấm vào dòng để mở chi tiết đầy đủ</div>
      </template>
    </div>
  </Teleport>
</template>

<style scoped>
.phc {
  position: fixed;
  z-index: 300;
  background: var(--card2);
  border: 1px solid var(--line2);
  border-radius: 14px;
  box-shadow: 0 24px 60px rgba(0, 0, 0, 0.45);
  overflow: hidden;
  display: flex;
  flex-direction: column;
  /* Thẻ chỉ để XEM: bỏ qua chuột hoàn toàn. Nếu không, nó nằm ngay dưới con trỏ và cướp mất
     sự kiện mouseleave của dòng đang rê -> thẻ nhấp nháy bật/tắt liên tục. */
  pointer-events: none;
  animation: phcIn 0.13s ease-out;
}
@keyframes phcIn {
  from {
    opacity: 0;
    transform: translateY(4px);
  }
  to {
    opacity: 1;
    transform: none;
  }
}

.phc-head {
  display: flex;
  align-items: center;
  gap: 11px;
  padding: 13px 15px;
  border-bottom: 1px solid var(--line);
  flex: none;
}
.phc-thumb {
  width: 46px;
  height: 46px;
  border-radius: 10px;
  flex: none;
  background: var(--card);
  border: 1px solid var(--line);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  font-size: 11px;
  color: var(--muted);
}
.phc-thumb img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}
.phc-name {
  font-size: 13.5px;
  font-weight: 600;
  color: var(--text);
  line-height: 1.35;
}
.phc-sub {
  font-size: 11.5px;
  color: var(--muted);
  margin-top: 2px;
}
.phc-pill {
  flex: none;
  font-size: 10.5px;
  font-weight: 700;
  padding: 2px 8px;
  border-radius: 20px;
  border: 1px solid currentColor;
}

.phc-loading {
  padding: 26px 15px;
  text-align: center;
  font-size: 12.5px;
  color: var(--muted);
}

.phc-sum {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  padding: 11px 15px;
  background: var(--card);
  flex: none;
}
.phc-price {
  font-size: 15px;
  font-weight: 700;
  color: var(--acc);
}
.phc-warn {
  padding: 7px 15px;
  background: color-mix(in srgb, #f59e0b 12%, transparent);
  border-top: 1px solid color-mix(in srgb, #f59e0b 28%, transparent);
  font-size: 11.5px;
  font-weight: 600;
  color: #f59e0b;
  flex: none;
}

.phc-body {
  padding: 12px 15px;
  overflow-y: auto;
}
.phc-label {
  font-size: 10px;
  font-weight: 600;
  color: var(--muted);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin: 13px 0 6px;
}
.phc-body .phc-label:first-child {
  margin-top: 0;
}
.phc-desc {
  font-size: 12px;
  color: var(--muted2);
  line-height: 1.55;
}

.phc-specs {
  display: flex;
  flex-direction: column;
  gap: 3px;
}
.phc-spec {
  display: flex;
  gap: 10px;
  font-size: 12px;
  line-height: 1.45;
}
.phc-spec-k {
  flex: none;
  width: 108px;
  color: var(--muted);
}
.phc-spec-v {
  flex: 1;
  color: var(--text);
  min-width: 0;
}

.phc-vars {
  border: 1px solid var(--line);
  border-radius: 9px;
  overflow: hidden;
}
.phc-var {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 7px 10px;
  font-size: 12px;
  background: var(--card);
}
.phc-var + .phc-var {
  border-top: 1px solid var(--line);
}
.phc-var-name {
  color: var(--text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.phc-default {
  font-size: 9.5px;
  font-weight: 700;
  color: var(--acc);
  border: 1px solid var(--acc);
  border-radius: 20px;
  padding: 0 5px;
  margin-left: 5px;
}
.phc-var-sku {
  font-size: 10.5px;
  color: var(--muted);
  margin-top: 1px;
}
.phc-var-price {
  flex: none;
  color: var(--muted2);
  font-size: 11.5px;
}
.phc-var-stock {
  flex: none;
  width: 96px;
  text-align: right;
  font-size: 11px;
  font-weight: 600;
}
.phc-var-stock b {
  margin-left: 4px;
  font-size: 12px;
}

.phc-foot {
  padding: 8px 15px;
  border-top: 1px solid var(--line);
  font-size: 10.5px;
  color: var(--muted);
  text-align: center;
  flex: none;
}
</style>
