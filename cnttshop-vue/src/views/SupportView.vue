<script setup>
import { ref, onMounted, nextTick } from 'vue';
import { useRoute } from 'vue-router';
import { actions, accent } from '../store.js';
import { fetchSupportOverview, fetchFaq } from '../api.js';

const route = useRoute();
const chatEl = ref(null);

// Kênh chat trực tuyến — mở Zalo/Messenger ở tab mới (không có hạ tầng chat nội bộ nên dùng kênh
// sẵn có, giống trang Liên hệ). Hai luồng tách bạch: tư vấn viên (mua hàng) và kỹ thuật viên
// (sự cố kỹ thuật/bảo hành) để định tuyến đúng người ngay từ đầu.
const HOTLINE = '0835344974';
const CHAT = [
  {
    icon: '💬',
    ten: 'Chat với tư vấn viên',
    mo: 'Tư vấn chọn máy, cấu hình, giá và khuyến mãi. Trực 8:00–22:00 mỗi ngày.',
    nut: 'Nhắn Zalo tư vấn',
    href: 'https://zalo.me/' + HOTLINE,
  },
  {
    icon: '🔧',
    ten: 'Chat với kỹ thuật viên',
    mo: 'Hỏi về sự cố máy, tương thích linh kiện, tình trạng bảo hành và sửa chữa.',
    nut: 'Nhắn Zalo kỹ thuật',
    href: 'https://zalo.me/' + HOTLINE,
  },
  {
    icon: '📞',
    ten: 'Gọi tổng đài',
    mo: 'Cần trả lời ngay thì gọi thẳng 0835 344 974, không phải chờ tin nhắn.',
    nut: 'Gọi 0835 344 974',
    href: 'tel:' + HOTLINE,
  },
];

/** tel: phải điều hướng CÙNG tab — window.open('tel:...') mở tab trắng rồi tự đóng trên phần
 * lớn trình duyệt, khách tưởng nút hỏng. Link zalo/messenger thì vẫn mở tab mới như cũ. */
function moChat(href) {
  if (href.startsWith('tel:')) window.location.href = href;
  else window.open(href, '_blank', 'noopener');
}

// Trang chủ hỗ trợ: ô tìm kiếm dẫn thẳng sang FAQ + các ô dịch vụ lớn + câu hỏi nổi bật.
const tongQuan = ref(null);
const dangTai = ref(true);
const tuKhoa = ref('');
const goiY = ref([]);
const dangGoiY = ref(false);

// Gợi ý ngay khi gõ: gọi FAQ với từ khoá và lấy 5 câu đầu. Chống dội bằng debounce 300ms —
// không có thì mỗi ký tự là một request, ô tìm kiếm này nằm ngay đầu trang nên rất hay bị gõ.
let timer = null;
function onSearch() {
  clearTimeout(timer);
  const q = tuKhoa.value.trim();
  if (q.length < 2) {
    goiY.value = [];
    return;
  }
  dangGoiY.value = true;
  timer = setTimeout(async () => {
    try {
      const nhom = await fetchFaq(q);
      goiY.value = nhom.flatMap((n) => n.items).slice(0, 5);
    } catch (e) {
      goiY.value = [];
    } finally {
      dangGoiY.value = false;
    }
  }, 300);
}

function timKiem() {
  const q = tuKhoa.value.trim();
  actions.goFaq();
  if (q) setTimeout(() => window.dispatchEvent(new CustomEvent('faq:search', { detail: q })), 60);
}

const O_DICH_VU = [
  {
    icon: '📍',
    ten: 'Trung tâm bảo hành',
    mo: 'Tìm điểm bảo hành gần bạn nhất, xem giờ mở cửa và đặt lịch trước.',
    di: () => actions.goServiceCenters(),
  },
  {
    icon: '🛡️',
    ten: 'Thông tin bảo hành',
    mo: 'Tra cứu thời hạn bằng số serial và xem chính sách theo từng nhóm hàng.',
    di: () => actions.goWarrantyInfo(),
  },
  {
    icon: '🧾',
    ten: 'Bảng giá sửa chữa',
    mo: 'Ước tính chi phí thay linh kiện và tiền công trước khi mang máy tới.',
    di: () => actions.goRepairPrice(),
  },
  {
    icon: '🗓️',
    ten: 'Lịch hẹn dịch vụ',
    mo: 'Xem lại lịch đã đặt hoặc tra cứu nhanh bằng mã lịch hẹn.',
    di: () => actions.goAppointments(),
  },
  {
    icon: '↩️',
    ten: 'Đổi trả hàng',
    mo: '1 đổi 1 trong 7 ngày. Gửi yêu cầu kèm video mở hàng và ảnh lỗi.',
    di: () => actions.goReturnPolicy(),
  },
  {
    icon: '💬',
    ten: 'Hỏi đáp (FAQ)',
    mo: 'Câu trả lời sẵn cho thanh toán, giao hàng, đổi trả và bảo hành.',
    di: () => actions.goFaq(),
  },
  {
    icon: '📞',
    ten: 'Liên hệ CNTTShop',
    mo: 'Hotline, Zalo, Messenger và form gửi yêu cầu hỗ trợ trực tiếp.',
    di: () => actions.goContact(),
  },
];

onMounted(async () => {
  try {
    tongQuan.value = await fetchSupportOverview();
  } catch (e) {
    tongQuan.value = null;
  } finally {
    dangTai.value = false;
  }
  // "Tư vấn cấu hình miễn phí" / "Tư vấn nâng cấp máy" trên menu mở trang này kèm ?chat=1 —
  // cuộn tới khối chat để khách bắt đầu ngay.
  if (route.query.chat) nextTick(() => chatEl.value?.scrollIntoView({ behavior: 'smooth', block: 'start' }));
});

const cardStyle =
  'background:var(--card); border:1px solid rgba(var(--line-rgb),0.14); border-radius:16px;';
</script>

<template>
  <main style="max-width: 1180px; margin: 0 auto; padding: 24px 24px 72px">
    <button class="sp-back" @click="actions.goHome()">← Quay lại trang chủ</button>

    <!-- Hero + tìm kiếm -->
    <section
      style="
        border-radius: 22px;
        padding: 46px 34px 40px;
        margin-bottom: 34px;
        background: linear-gradient(135deg, color-mix(in srgb, var(--acc, #c6ff4a) 45%, #06110a), #06110a 72%);
        border: 1px solid color-mix(in srgb, var(--acc, #c6ff4a) 30%, transparent);
        text-align: center;
      "
    >
      <div class="sp-eyebrow" style="color: rgba(255, 255, 255, 0.82)">TRUNG TÂM HỖ TRỢ</div>
      <h1 class="sp-h1" style="max-width: 660px; margin: 0 auto 14px; color: #fff">
        Chúng tôi có thể giúp gì<br />cho <span :style="{ color: accent }">bạn</span>?
      </h1>
      <p
        style="
          font-size: 14.5px;
          color: rgba(255, 255, 255, 0.72);
          max-width: 540px;
          margin: 0 auto 26px;
          line-height: 1.65;
        "
      >
        Tra cứu bảo hành, tìm trung tâm dịch vụ, xem giá sửa chữa hoặc đặt lịch mang máy tới —
        tất cả ở một nơi.
      </p>

      <div style="position: relative; max-width: 560px; margin: 0 auto">
        <form
          @submit.prevent="timKiem"
          style="display: flex; gap: 10px"
        >
          <input
            v-model="tuKhoa"
            @input="onSearch"
            class="sp-input"
            style="flex: 1; height: 50px; font-size: 14.5px"
            placeholder="Nhập câu hỏi, vd: phí giao hàng, tra cứu bảo hành…"
          />
          <button type="submit" class="sp-btn-acc" style="height: 50px; padding: 0 24px">
            Tìm
          </button>
        </form>

        <!-- Gợi ý tức thời -->
        <div
          v-if="goiY.length"
          :style="cardStyle"
          style="
            position: absolute;
            top: 58px;
            left: 0;
            right: 0;
            z-index: 20;
            overflow: hidden;
            text-align: left;
            box-shadow: 0 16px 40px rgba(0, 0, 0, 0.28);
          "
        >
          <button
            v-for="g in goiY"
            :key="g.id"
            @click="timKiem()"
            class="sp-suggest"
          >
            <span style="font-size: 13.5px; color: var(--text)">{{ g.cauHoi }}</span>
            <span style="font-size: 11.5px; color: var(--muted)">{{ g.tenDanhMuc }}</span>
          </button>
        </div>
        <div
          v-else-if="dangGoiY"
          style="position: absolute; top: 60px; left: 4px; font-size: 12px; color: var(--muted)"
        >
          Đang tìm…
        </div>
      </div>

      <!-- Số liệu -->
      <div
        v-if="tongQuan"
        style="
          display: flex;
          justify-content: center;
          gap: 34px;
          flex-wrap: wrap;
          margin-top: 30px;
        "
      >
        <div v-for="s in [
            { n: tongQuan.soTrungTam, l: 'Trung tâm dịch vụ' },
            { n: tongQuan.soTinhCoTrungTam, l: 'Tỉnh / thành phủ sóng' },
            { n: tongQuan.soHangMucSuaChua, l: 'Hạng mục sửa chữa' },
            { n: tongQuan.soCauHoi, l: 'Câu hỏi thường gặp' },
          ]" :key="s.l" style="text-align: center">
          <div
            style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 26px"
            :style="{ color: accent }"
          >
            {{ s.n }}
          </div>
          <div style="font-size: 11.5px; color: rgba(255, 255, 255, 0.6); margin-top: 2px">{{ s.l }}</div>
        </div>
      </div>
    </section>

    <!-- Ô dịch vụ -->
    <section style="margin-bottom: 40px">
      <h2 class="sp-h2">Dịch vụ hỗ trợ</h2>
      <div
        style="
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
          gap: 16px;
        "
      >
        <button v-for="o in O_DICH_VU" :key="o.ten" @click="o.di()" class="sp-tile">
          <div style="font-size: 30px; margin-bottom: 12px">{{ o.icon }}</div>
          <div
            style="
              font-family: 'Chakra Petch', sans-serif;
              font-weight: 700;
              font-size: 15px;
              color: var(--text);
              margin-bottom: 7px;
            "
          >
            {{ o.ten }}
          </div>
          <div style="font-size: 12.8px; color: var(--muted2); line-height: 1.6; flex: 1">
            {{ o.mo }}
          </div>
          <div
            :style="{ color: accent }"
            style="font-size: 12.5px; font-weight: 700; margin-top: 14px"
          >
            Bắt đầu →
          </div>
        </button>
      </div>
    </section>

    <!-- Chat trực tuyến với kỹ thuật viên / tư vấn viên -->
    <section ref="chatEl" style="margin-bottom: 40px; scroll-margin-top: 100px">
      <h2 class="sp-h2">Chat trực tuyến</h2>
      <p style="font-size: 13px; color: var(--muted2); margin: 0 0 18px; max-width: 620px; line-height: 1.6">
        Cần tư vấn cấu hình hay nâng cấp máy? Nhắn trực tiếp — phản hồi trong vài phút, giờ trực
        8:00–22:00 mỗi ngày.
      </p>
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px">
        <div v-for="c in CHAT" :key="c.ten" :style="cardStyle" style="padding: 24px 22px; display: flex; flex-direction: column">
          <div style="font-size: 30px; margin-bottom: 12px">{{ c.icon }}</div>
          <div style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 15.5px; color: var(--text); margin-bottom: 8px">
            {{ c.ten }}
          </div>
          <div style="font-size: 12.8px; color: var(--muted2); line-height: 1.6; flex: 1; margin-bottom: 16px">
            {{ c.mo }}
          </div>
          <button class="sp-btn-acc" style="align-self: flex-start" @click="moChat(c.href)">{{ c.nut }} →</button>
        </div>
      </div>
    </section>

    <!-- Câu hỏi nổi bật + trung tâm nổi bật -->
    <section
      v-if="tongQuan"
      style="display: grid; grid-template-columns: 1.35fr 1fr; gap: 22px; align-items: start"
      class="sp-two-col"
    >
      <div>
        <h2 class="sp-h2">Câu hỏi được xem nhiều</h2>
        <div :style="cardStyle" style="padding: 6px 4px">
          <button
            v-for="c in tongQuan.cauHoiNoiBat"
            :key="c.id"
            @click="actions.goFaq()"
            class="sp-row"
          >
            <span style="font-size: 13.5px; color: var(--text); line-height: 1.5">{{ c.cauHoi }}</span>
            <span style="font-size: 11px; color: var(--muted); white-space: nowrap">
              {{ c.tenDanhMuc }}
            </span>
          </button>
        </div>
      </div>

      <div>
        <h2 class="sp-h2">Trung tâm dịch vụ</h2>
        <div :style="cardStyle" style="padding: 18px 20px">
          <div
            v-for="t in tongQuan.trungTamNoiBat"
            :key="t.id"
            style="
              padding: 12px 0;
              border-bottom: 1px solid rgba(var(--line-rgb), 0.1);
            "
          >
            <div style="font-size: 13.5px; font-weight: 700; color: var(--text)">{{ t.ten }}</div>
            <div style="font-size: 12.3px; color: var(--muted2); margin-top: 4px; line-height: 1.5">
              {{ t.diaChi }}
            </div>
            <div style="font-size: 12px; color: var(--muted); margin-top: 4px">
              {{ t.gioMoCua }}
            </div>
          </div>
          <button
            @click="actions.goServiceCenters()"
            class="sp-btn-ghost"
            style="width: 100%; margin-top: 16px"
          >
            Xem tất cả trung tâm →
          </button>
        </div>
      </div>
    </section>

    <!-- Dải liên hệ -->
    <section
      style="
        margin-top: 40px;
        border-radius: 18px;
        padding: 30px 34px;
        background: linear-gradient(135deg, #0a2c1e, #061a0e);
        border: 1px solid rgba(0, 197, 126, 0.2);
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 24px;
        flex-wrap: wrap;
      "
    >
      <div>
        <div
          style="
            font-family: 'Chakra Petch', sans-serif;
            font-size: 11px;
            letter-spacing: 2px;
            color: var(--green);
            font-weight: 600;
            margin-bottom: 10px;
          "
        >
          KHÔNG TÌM THẤY CÂU TRẢ LỜI?
        </div>
        <div style="font-size: 19px; font-weight: 800; color: #fff; margin-bottom: 6px">
          Gọi 0835 344 974 — miễn phí, 8:00 đến 22:00 mỗi ngày
        </div>
        <div style="font-size: 13px; color: rgba(255, 255, 255, 0.6)">
          Hoặc nhắn Zalo / Messenger, phản hồi trong vòng 5 phút.
        </div>
      </div>
      <button @click="actions.goContact()" class="sp-btn-acc" style="height: 46px; padding: 0 28px">
        Liên hệ ngay →
      </button>
    </section>
  </main>
</template>

<style scoped>
.sp-suggest {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  width: 100%;
  padding: 12px 16px;
  background: transparent;
  border: none;
  border-bottom: 1px solid rgba(var(--line-rgb), 0.1);
  cursor: pointer;
  text-align: left;
  font-family: 'Plus Jakarta Sans', sans-serif;
}
.sp-suggest:last-child {
  border-bottom: none;
}
.sp-suggest:hover {
  background: var(--card2);
}

.sp-tile {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  text-align: left;
  background: var(--card);
  border: 1px solid rgba(var(--line-rgb), 0.14);
  border-radius: 16px;
  padding: 24px 22px;
  cursor: pointer;
  font-family: 'Plus Jakarta Sans', sans-serif;
  transition: border-color 0.16s, transform 0.16s;
  min-height: 178px;
}
.sp-tile:hover {
  border-color: var(--acc, #c6ff4a);
  transform: translateY(-2px);
}

.sp-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  width: 100%;
  padding: 13px 18px;
  background: transparent;
  border: none;
  border-bottom: 1px solid rgba(var(--line-rgb), 0.1);
  cursor: pointer;
  text-align: left;
  font-family: 'Plus Jakarta Sans', sans-serif;
}
.sp-row:last-child {
  border-bottom: none;
}
.sp-row:hover {
  background: var(--card2);
}

@media (max-width: 860px) {
  .sp-two-col {
    grid-template-columns: 1fr !important;
  }
}
</style>
