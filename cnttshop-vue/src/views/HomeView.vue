<script setup>
import { computed, reactive, ref, onMounted } from 'vue';
import { catMeta, trust, bestsellers } from '../data/products.js';
import { state, actions, accent, themeStyle, products } from '../store.js';
import { fetchFlashSale } from '../api.js';
import ProductCard from '../components/ProductCard.vue';
import FlashSaleBanner from '../components/FlashSaleBanner.vue';

// Ref tới từng hàng cuộn ngang theo danh mục, dùng cho nút mũi tên trái/phải.
const rowEls = reactive({});
function setRowEl(slug, el) {
  if (el) rowEls[slug] = el;
}
function scrollRow(slug, dir) {
  const el = rowEls[slug];
  if (!el) return;
  el.scrollBy({ left: dir * el.clientWidth * 0.85, behavior: 'smooth' });
}

// Chưa có đơn hàng nào -> bestsellers rỗng, tạm hiện sản phẩm mới nhất để trang chủ không trống.
const featured = computed(() =>
  bestsellers.length ? bestsellers : products.slice().sort((a, b) => b.id - a.id).slice(0, 8),
);

// Mỗi danh mục 1 khối: banner màu + chip hãng + lưới sản phẩm — tăng đa dạng hiển thị trang chủ.
// Ưu tiên sản phẩm mới nhất (id giảm dần) để hàng vừa bổ sung luôn xuất hiện ngay trên trang chủ,
// thay vì luôn kẹt ở 6 sản phẩm đầu tiên theo thứ tự tải về.
const categoryShowcases = computed(() =>
  Object.keys(catMeta)
    .map((slug) => {
      const items = products.filter((p) => p.cat === slug);
      const brands = [...new Set(items.map((p) => p.brand))].slice(0, 4);
      return {
        slug,
        title: catMeta[slug].vn,
        hue: catMeta[slug].hue,
        brands,
        items: items.slice().sort((a, b) => b.id - a.id).slice(0, 12),
      };
    })
    .filter((r) => r.items.length > 0),
);

// Banner flash sale — endpoint cong khai, tra null khi khong co dot nao dang chay.
const flashSale = ref(null);
onMounted(async () => {
  try { flashSale.value = await fetchFlashSale(); } catch (e) { flashSale.value = null; }
});
</script>

<template>
  <main style="max-width: 1800px; margin: 0 auto; padding: 0 24px 70px">
    <!-- FLASH SALE — chỉ hiện khi admin đã đăng một đợt và đang trong khung giờ (xem
         FlashSaleService.dangChay); ngoài ra component tự không vẽ gì. -->
    <div v-if="flashSale" style="margin-bottom: 20px">
      <FlashSaleBanner :sale="flashSale" />
    </div>

    <!-- HERO + BEST SELLERS — hợp nhất thành 1 panel. Nền panel này LUÔN tối (không đổi theo
    chế độ sáng/tối chung của site), nên mọi chữ/viền bên trong dùng màu CỐ ĐỊNH (rgba trắng),
    không dùng var(--text)/var(--muted)/var(--line-rgb) — các biến đó đổi theo state.mode và sẽ
    ra chữ tối trên nền tối (không đọc được) khi site chuyển sang chế độ sáng. -->
    <div
      style="
        position: relative;
        overflow: hidden;
        border-radius: 20px;
        border: 1px solid rgba(255, 255, 255, 0.16);
        background: linear-gradient(160deg, #1e2024 0%, #101114 72%);
        padding: 34px 38px;
        margin-top: 28px;
      "
    >
      <div
        :style="{
          background:
            'radial-gradient(circle, color-mix(in srgb, ' +
            accent +
            ' 38%, transparent), transparent 65%)',
        }"
        style="
          position: absolute;
          top: -90px;
          right: -60px;
          width: 280px;
          height: 280px;
          border-radius: 50%;
          filter: blur(20px);
          animation: floatBlob 9s ease-in-out infinite;
          pointer-events: none;
        "
      ></div>
      <div style="position: relative">
        <div
          style="
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 32px;
            flex-wrap: wrap;
            margin-bottom: 26px;
          "
        >
          <div style="flex: 1; min-width: 280px; max-width: 600px">
            <div
              :style="{ color: accent }"
              style="
                font-family: 'Chakra Petch', sans-serif;
                font-size: 11px;
                letter-spacing: 2.5px;
                font-weight: 600;
                margin-bottom: 14px;
              "
            >
              CNTTSHOP // BUILD YOUR POWER
            </div>
            <h1
              style="
                font-family: 'Be Vietnam Pro', sans-serif;
                font-weight: 800;
                font-size: 32px;
                line-height: 1.1;
                margin: 0 0 14px;
                letter-spacing: -1px;
                color: #fff;
              "
            >
              Tham khảo các sản phẩm bán chạy
            </h1>
            <p
              style="
                margin: 0 0 20px;
                font-size: 13.5px;
                line-height: 1.6;
                color: rgba(255, 255, 255, 0.72);
                max-width: 460px;
              "
            >
              PC Gaming dựng sẵn, laptop RTX & linh kiện chính hãng. Test kỹ
              trước khi giao, bảo hành tới 36 tháng, trả góp 0%.
            </p>
            <div style="display: flex; gap: 12px; flex-wrap: wrap">
              <button
                @click="actions.goCatPC"
                :style="{
                  background: accent,
                  boxShadow:
                    '0 10px 28px color-mix(in srgb, ' +
                    accent +
                    ' 40%, transparent)',
                }"
                style="
                  height: 46px;
                  padding: 0 22px;
                  border: none;
                  border-radius: 12px;
                  color: var(--acc-ink);
                  font-family: 'Be Vietnam Pro', sans-serif;
                  font-weight: 700;
                  font-size: 14px;
                  cursor: pointer;
                "
              >
                Mua PC Gaming →
              </button>
              <button
                @click="actions.goCatLap"
                style="
                  height: 46px;
                  padding: 0 22px;
                  border: 1px solid rgba(255, 255, 255, 0.3);
                  border-radius: 12px;
                  background: transparent;
                  color: #fff;
                  font-family: 'Be Vietnam Pro', sans-serif;
                  font-weight: 600;
                  font-size: 14px;
                  cursor: pointer;
                "
              >
                Xem Laptop
              </button>
            </div>
          </div>
          <div style="flex: none; text-align: right">
            <div
              :style="{ color: accent }"
              style="
                font-family: 'Chakra Petch', sans-serif;
                font-size: 11px;
                letter-spacing: 2.5px;
                font-weight: 600;
              "
            >
              BEST SELLERS
            </div>
            <h2
              style="
                font-family: 'Be Vietnam Pro', sans-serif;
                font-weight: 700;
                font-size: 22px;
                margin: 6px 0 14px;
                color: #fff;
              "
            >
              Sản phẩm bán chạy
            </h2>
            <button
              @click="actions.goCatAll"
              style="
                background: transparent;
                border: 1px solid rgba(255, 255, 255, 0.22);
                color: rgba(255, 255, 255, 0.75);
                padding: 9px 18px;
                border-radius: 10px;
                font-size: 13px;
                font-weight: 600;
                cursor: pointer;
                font-family: 'Be Vietnam Pro', sans-serif;
              "
            >
              Xem tất cả
            </button>
          </div>
        </div>
        <div style="border-top: 1px solid rgba(255, 255, 255, 0.18); padding-top: 24px">
          <div
            style="
              display: grid;
              grid-template-columns: repeat(4, 1fr);
              gap: 16px;
            "
          >
            <ProductCard
              v-for="p in featured"
              :key="p.id"
              :p="p"
              @open="actions.goDetail"
              @add="actions.addToCart"
            />
          </div>
        </div>
      </div>
    </div>

    <!-- SECOND ROW: nội dung + sidebar phải -->
    <div
      style="
        display: grid;
        grid-template-columns: minmax(0, 1fr) 288px;
        gap: 20px;
        align-items: start;
        margin-top: 28px;
      "
    >
      <!-- CENTER -->
      <div style="position: relative">
        <!-- trust -->
        <section
          style="
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 12px;
            margin-bottom: 34px;
          "
        >
          <div
            v-for="(t, i) in trust"
            :key="i"
            style="
              display: flex;
              align-items: center;
              gap: 12px;
              padding: 16px;
              border-radius: 13px;
              background: var(--card);
              border: 1px solid rgba(var(--line-rgb), 0.12);
            "
          >
            <div style="font-size: 22px">{{ t.icon }}</div>
            <div>
              <div style="font-weight: 700; font-size: 13.5px; color: var(--text)">
                {{ t.title }}
              </div>
              <div style="font-size: 11.5px; color: var(--muted)">{{ t.sub }}</div>
            </div>
          </div>
        </section>

        <!-- Khối theo danh mục: banner màu + chip hãng + sản phẩm — tăng đa dạng hiển thị trang chủ -->
        <section
          v-for="row in categoryShowcases"
          :key="row.slug"
          style="margin-top: 34px"
        >
          <div
            style="
              display: flex;
              align-items: center;
              gap: 14px;
              margin-bottom: 16px;
              flex-wrap: wrap;
            "
          >
            <div
              :style="{
                background:
                  'linear-gradient(120deg, hsl(' +
                  row.hue +
                  ' 70% 45%), hsl(' +
                  row.hue +
                  ' 75% 35%))',
              }"
              style="
                font-family: 'Chakra Petch', sans-serif;
                font-weight: 700;
                font-size: 14px;
                letter-spacing: 0.5px;
                color: #fff;
                padding: 9px 18px;
                border-radius: 10px;
                text-transform: uppercase;
                flex: none;
              "
            >
              {{ row.title }}
            </div>
            <div style="display: flex; gap: 8px; flex-wrap: wrap; flex: 1">
              <span
                v-for="b in row.brands"
                :key="b"
                :style="{
                  color: themeStyle.inkSoft,
                  borderColor:
                    state.mode === 'dark'
                      ? 'rgba(var(--line-rgb),0.25)'
                      : 'rgba(14,34,54,0.18)',
                }"
                style="
                  font-size: 12.5px;
                  font-weight: 600;
                  padding: 6px 14px;
                  border-radius: 20px;
                  border: 1px solid;
                  font-family: 'Be Vietnam Pro', sans-serif;
                "
                >{{ b }}</span
              >
            </div>
            <button
              @click="actions.goCat(row.slug)"
              :style="{ color: accent }"
              style="
                background: transparent;
                border: none;
                font-size: 13px;
                font-weight: 600;
                cursor: pointer;
                font-family: 'Be Vietnam Pro', sans-serif;
                flex: none;
              "
            >
              Xem tất cả »
            </button>
          </div>
          <div style="position: relative">
            <button
              class="row-nav row-nav--prev"
              type="button"
              aria-label="Xem sản phẩm trước"
              @click="scrollRow(row.slug, -1)"
            >
              ‹
            </button>
            <div
              :ref="(el) => setRowEl(row.slug, el)"
              class="cat-row-scroll"
              style="display: flex; gap: 16px; overflow-x: auto; padding: 8px 2px 6px; margin: -8px -2px 0"
            >
              <div
                v-for="p in row.items"
                :key="p.id"
                style="flex: none; width: 210px"
              >
                <ProductCard :p="p" @open="actions.goDetail" @add="actions.addToCart" />
              </div>
            </div>
            <button
              class="row-nav row-nav--next"
              type="button"
              aria-label="Xem sản phẩm tiếp theo"
              @click="scrollRow(row.slug, 1)"
            >
              ›
            </button>
          </div>
        </section>
      </div>

      <!-- RIGHT SIDEBAR — build promos. Cả 2 thẻ đều nền màu cố định (tím/xanh lá), không đổi
      theo chế độ sáng/tối -> chữ bên trong cũng dùng màu cố định, không dùng var(--text)/(--muted2). -->
      <aside
        style="
          position: sticky;
          top: 120px;
          display: flex;
          flex-direction: column;
          gap: 16px;
        "
      >
        <div
          @click="actions.goPcBuild"
          style="
            cursor: pointer;
            border-radius: 20px;
            overflow: hidden;
            position: relative;
            padding: 26px 24px;
            background: linear-gradient(
              150deg,
              hsl(265 48% 22%),
              hsl(258 55% 11%) 78%
            );
            border: 1px solid rgba(150, 140, 230, 0.22);
          "
        >
          <div
            style="
              font-family: 'Chakra Petch', sans-serif;
              font-size: 10px;
              letter-spacing: 2.5px;
              color: hsl(280 75% 78%);
              font-weight: 600;
            "
          >
            CUSTOM BUILD
          </div>
          <h2
            style="
              font-family: 'Be Vietnam Pro', sans-serif;
              font-weight: 800;
              font-size: 22px;
              line-height: 1.2;
              margin: 10px 0 8px;
              color: #fff;
            "
          >
            Tự build cấu hình cho bản thân
          </h2>
          <p
            style="
              margin: 0 0 18px;
              color: #cbb8ee;
              font-size: 13px;
              line-height: 1.55;
            "
          >
            Tự chọn CPU, VGA, RAM, tản nhiệt theo ngân sách. Kiểm tra tương
            thích & lên giá tức thì.
          </p>
          <div
            style="
              display: inline-flex;
              font-family: 'Be Vietnam Pro', sans-serif;
              font-weight: 700;
              font-size: 13.5px;
              color: #1a0f2e;
              background: hsl(280 80% 72%);
              padding: 12px 22px;
              border-radius: 11px;
            "
          >
            Khám phá ngay →
          </div>
        </div>

        <!-- support card -->
        <div
          style="
            border-radius: 20px;
            overflow: hidden;
            position: relative;
            padding: 26px 24px;
            background: linear-gradient(150deg, #0a3d2b, #061a11 80%);
            border: 1px solid rgba(0, 197, 126, 0.22);
          "
        >
          <div
            style="
              font-family: 'Chakra Petch', sans-serif;
              font-size: 10px;
              letter-spacing: 2.5px;
              color: #00c57e;
              font-weight: 600;
            "
          >
            HỖ TRỢ &amp; TƯ VẤN
          </div>
          <h2
            style="
              font-family: 'Be Vietnam Pro', sans-serif;
              font-weight: 800;
              font-size: 22px;
              line-height: 1.2;
              margin: 10px 0 8px;
              color: #fff;
            "
          >
            Cần hỗ trợ<br />hoặc tư vấn?
          </h2>
          <p
            style="
              margin: 0 0 16px;
              color: #8ecfb0;
              font-size: 13px;
              line-height: 1.55;
            "
          >
            Chuyên gia CNTTshop sẵn sàng tư vấn cấu hình phù hợp ngân sách —
            hoàn toàn miễn phí.
          </p>
          <div
            style="
              display: flex;
              flex-direction: column;
              gap: 9px;
              margin-bottom: 18px;
            "
          >
            <div
              style="
                display: flex;
                align-items: center;
                gap: 9px;
                font-size: 13px;
                color: #8ecfb0;
              "
            >
              <span style="font-size: 15px">📞</span
              ><span
                ><span style="color: #fff; font-weight: 600">1900 1903</span>
                · Miễn phí</span
              >
            </div>
            <div
              style="
                display: flex;
                align-items: center;
                gap: 9px;
                font-size: 13px;
                color: #8ecfb0;
              "
            >
              <span style="font-size: 15px">💬</span
              ><span>Chat trực tiếp · 8:00 – 22:00</span>
            </div>
          </div>
          <a
            href="#"
            @click.prevent="actions.goContact()"
            style="
              display: inline-flex;
              font-family: 'Be Vietnam Pro', sans-serif;
              font-weight: 700;
              font-size: 13.5px;
              color: #061a11;
              background: #00c57e;
              padding: 12px 22px;
              border-radius: 11px;
              text-decoration: none;
              box-shadow: 0 8px 22px rgba(0, 197, 126, 0.28);
              cursor: pointer;
            "
            >Liên hệ ngay →</a
          >
        </div>
      </aside>
    </div>
  </main>
</template>

<style scoped>

.cat-row-scroll {
  scrollbar-width: none;
}
.cat-row-scroll::-webkit-scrollbar {
  display: none;
}
.row-nav {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 38px;
  height: 38px;
  border-radius: 50%;
  border: 1px solid rgba(var(--line-rgb), 0.22);
  background: var(--card);
  color: var(--text);
  font-size: 19px;
  line-height: 1;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
  z-index: 2;
  transition: transform 0.15s ease, border-color 0.15s ease, color 0.15s ease;
}
.row-nav:hover {
  border-color: var(--acc);
  color: var(--acc);
  transform: translateY(-50%) scale(1.08);
}
.row-nav--prev {
  left: -16px;
}
.row-nav--next {
  right: -16px;
}
</style>
