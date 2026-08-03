<script setup>
import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue';
import { useRoute } from 'vue-router';
import { actions, accent } from '../store.js';
import { fetchFaq, markFaqViewed } from '../api.js';

const route = useRoute();

const nhom = ref([]);
const dangTai = ref(true);
const tuKhoa = ref('');
const danhMucChon = ref('');
const dangMo = ref(new Set());

async function tai() {
  dangTai.value = true;
  try {
    nhom.value = await fetchFaq(tuKhoa.value.trim() || undefined);
    // Đang tìm kiếm thì bung sẵn mọi câu khớp — bắt khách bấm thêm một lần nữa để đọc thứ họ
    // vừa tìm ra là thừa.
    if (tuKhoa.value.trim()) {
      dangMo.value = new Set(nhom.value.flatMap((n) => n.items.map((i) => i.id)));
    }
  } catch (e) {
    nhom.value = [];
  } finally {
    dangTai.value = false;
  }
}

let timer = null;
watch(tuKhoa, () => {
  clearTimeout(timer);
  timer = setTimeout(tai, 320);
});

const nhomHienThi = computed(() => {
  if (!danhMucChon.value) return nhom.value;
  return nhom.value.filter((n) => n.ma === danhMucChon.value);
});

const tongCau = computed(() => nhom.value.reduce((s, n) => s + n.items.length, 0));

function bung(item) {
  const s = new Set(dangMo.value);
  if (s.has(item.id)) {
    s.delete(item.id);
  } else {
    s.add(item.id);
    // Đếm lượt xem để admin biết câu nào thật sự được đọc — lỗi ở đây không được ảnh hưởng tới
    // việc bung câu trả lời, nên nuốt luôn.
    markFaqViewed(item.id).catch(() => {});
  }
  dangMo.value = s;
}

function moTatCa() {
  dangMo.value = new Set(nhomHienThi.value.flatMap((n) => n.items.map((i) => i.id)));
}
function dongTatCa() {
  dangMo.value = new Set();
}

// Trang chủ hỗ trợ chuyển sang đây kèm từ khoá đã gõ — nhận qua sự kiện thay vì query string để
// không phải xử lý đồng bộ hai chiều giữa URL và ô nhập.
function nhanTuKhoa(e) {
  tuKhoa.value = e.detail || '';
}

// Các mục "Khám phá" trên menu mở FAQ kèm ?cat=<mã danh mục> (VD ky_thuat) hoặc ?q=<từ khoá>.
// Ưu tiên áp ngay khi vào trang, và theo dõi query để bấm lại từ menu vẫn cập nhật.
function apDungQuery() {
  if (route.query.q) tuKhoa.value = String(route.query.q);
  if (route.query.cat) danhMucChon.value = String(route.query.cat);
}
watch(() => [route.query.cat, route.query.q], apDungQuery);

onMounted(() => {
  window.addEventListener('faq:search', nhanTuKhoa);
  apDungQuery();
  tai();
});
onBeforeUnmount(() => window.removeEventListener('faq:search', nhanTuKhoa));
</script>

<template>
  <main style="max-width: 1000px; margin: 0 auto; padding: 24px 24px 72px">
    <button class="sp-back" @click="actions.goSupport()">← Trung tâm hỗ trợ</button>

    <div style="margin-bottom: 26px">
      <div class="sp-eyebrow">HỎI ĐÁP</div>
      <h1 class="sp-h1">
        Câu hỏi <span :style="{ color: accent }">thường gặp</span>
      </h1>
      <p style="font-size: 14.5px; color: var(--muted2); max-width: 600px; line-height: 1.65; margin: 0">
        Tìm nhanh câu trả lời về đơn hàng, thanh toán, giao hàng, đổi trả và bảo hành.
      </p>
    </div>

    <input
      v-model="tuKhoa"
      class="sp-input"
      style="height: 48px; font-size: 14.5px; margin-bottom: 18px"
      placeholder="Tìm câu hỏi, vd: phí ship, trả góp, đổi trả…"
    />

    <!-- Lọc theo danh mục -->
    <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 22px">
      <button class="sp-chip" :class="{ active: !danhMucChon }" @click="danhMucChon = ''">
        Tất cả ({{ tongCau }})
      </button>
      <button
        v-for="n in nhom"
        :key="n.ma"
        class="sp-chip"
        :class="{ active: danhMucChon === n.ma }"
        @click="danhMucChon = n.ma"
      >
        {{ n.icon }} {{ n.ten }} ({{ n.items.length }})
      </button>
    </div>

    <div
      v-if="!dangTai && nhomHienThi.length"
      style="display: flex; gap: 14px; margin-bottom: 14px"
    >
      <button
        @click="moTatCa"
        style="background: transparent; border: none; color: var(--muted); font-size: 12px; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif"
      >
        Mở tất cả
      </button>
      <button
        @click="dongTatCa"
        style="background: transparent; border: none; color: var(--muted); font-size: 12px; cursor: pointer; font-family: 'Plus Jakarta Sans', sans-serif"
      >
        Thu gọn tất cả
      </button>
    </div>

    <div v-if="dangTai" class="sp-card sp-empty">Đang tải…</div>

    <div v-else-if="!nhomHienThi.length" class="sp-card sp-empty">
      Không tìm thấy câu hỏi nào khớp
      <b v-if="tuKhoa" style="color: var(--text)">"{{ tuKhoa }}"</b>.<br />
      Thử từ khoá khác, hoặc
      <a href="#" @click.prevent="actions.goContact()" :style="{ color: accent }">gửi câu hỏi cho CNTTShop</a>.
    </div>

    <!-- Nhóm câu hỏi -->
    <div v-else style="display: flex; flex-direction: column; gap: 26px">
      <section v-for="n in nhomHienThi" :key="n.ma">
        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 12px">
          <span style="font-size: 19px">{{ n.icon }}</span>
          <div>
            <h2 class="sp-h2" style="margin: 0">{{ n.ten }}</h2>
            <div v-if="n.moTa" style="font-size: 12.3px; color: var(--muted); margin-top: 3px">
              {{ n.moTa }}
            </div>
          </div>
        </div>

        <div class="sp-card" style="overflow: hidden">
          <div v-for="item in n.items" :key="item.id" class="fq-item">
            <button class="fq-q" @click="bung(item)">
              <span style="flex: 1">
                {{ item.cauHoi }}
                <span
                  v-if="item.noiBat"
                  class="sp-pill"
                  :style="{ color: accent }"
                  style="margin-left: 8px; font-size: 10px; padding: 2px 8px"
                >
                  Phổ biến
                </span>
              </span>
              <span class="fq-arrow" :class="{ open: dangMo.has(item.id) }">⌄</span>
            </button>
            <div v-if="dangMo.has(item.id)" class="fq-a">{{ item.traLoi }}</div>
          </div>
        </div>
      </section>
    </div>

    <!-- Vẫn chưa có câu trả lời -->
    <div
      style="
        margin-top: 40px;
        border-radius: 16px;
        padding: 28px 30px;
        background: var(--card2);
        border: 1px solid rgba(var(--line-rgb), 0.14);
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 20px;
        flex-wrap: wrap;
      "
    >
      <div>
        <div style="font-size: 15.5px; font-weight: 700; color: var(--text); margin-bottom: 6px">
          Vẫn chưa tìm được câu trả lời?
        </div>
        <div style="font-size: 13px; color: var(--muted2); line-height: 1.6">
          Hotline 0835 344 974 · 8:00–22:00 mỗi ngày, hoặc gửi yêu cầu hỗ trợ để được phản hồi
          trong 24 giờ.
        </div>
      </div>
      <button class="sp-btn-acc" @click="actions.goContact()">Liên hệ hỗ trợ →</button>
    </div>
  </main>
</template>

<style scoped>
.fq-item {
  border-bottom: 1px solid rgba(var(--line-rgb), 0.09);
}
.fq-item:last-child {
  border-bottom: none;
}

.fq-q {
  display: flex;
  align-items: center;
  gap: 14px;
  width: 100%;
  padding: 17px 22px;
  background: transparent;
  border: none;
  cursor: pointer;
  text-align: left;
  font-family: 'Plus Jakarta Sans', sans-serif;
  font-size: 13.6px;
  font-weight: 600;
  color: var(--text);
  line-height: 1.5;
}
.fq-q:hover {
  background: var(--card2);
}

.fq-arrow {
  flex: none;
  color: var(--muted);
  font-size: 15px;
  transition: transform 0.2s;
}
.fq-arrow.open {
  transform: rotate(180deg);
  color: var(--acc, #c6ff4a);
}

.fq-a {
  padding: 0 22px 20px;
  font-size: 13.2px;
  color: var(--muted2);
  line-height: 1.75;
  white-space: pre-line;
}
</style>
