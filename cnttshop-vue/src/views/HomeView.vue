<script setup>
import { computed } from 'vue';
import { catMeta, trust } from '../data/products.js';
import { state, actions, accent, themeStyle, products } from '../store.js';
import ProductCard from '../components/ProductCard.vue';

const catTiles = computed(() =>
  Object.keys(catMeta).map((k) => ({
    key: k,
    vn: catMeta[k].vn,
    en: catMeta[k].en,
    hue: catMeta[k].hue,
  })),
);
const featured = computed(() => products.filter((p) => p.featured));
</script>

<template>
  <main style="max-width: 1800px; margin: 0 auto; padding: 0 24px 70px">
    <div
      style="
        display: grid;
        grid-template-columns: 288px minmax(0, 1fr) 288px;
        gap: 20px;
        align-items: start;
        margin-top: 28px;
      "
    >
      <!-- LEFT SIDEBAR — hero -->
      <aside style="position: sticky; top: 120px">
        <div
          style="
            position: relative;
            overflow: hidden;
            border-radius: 20px;
            border: 1px solid rgba(120, 170, 230, 0.16);
            background: linear-gradient(160deg, #0a2440 0%, #061427 72%);
            padding: 30px 26px 28px;
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
                font-size: 38px;
                line-height: 1.05;
                margin: 0 0 16px;
                letter-spacing: -1px;
                color: #fff;
              "
            >
              Sức mạnh<br />không giới hạn.
            </h1>
            <p
              style="
                margin: 0 0 24px;
                font-size: 13.5px;
                line-height: 1.6;
                color: #a9c0dc;
              "
            >
              PC Gaming dựng sẵn, laptop RTX & linh kiện chính hãng. Test kỹ
              trước khi giao, bảo hành tới 36 tháng, trả góp 0%.
            </p>
            <div style="display: flex; flex-direction: column; gap: 11px">
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
                  height: 48px;
                  padding: 0 22px;
                  border: none;
                  border-radius: 12px;
                  color: #04121f;
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
                  height: 48px;
                  padding: 0 22px;
                  border: 1px solid rgba(120, 170, 230, 0.3);
                  border-radius: 12px;
                  background: transparent;
                  color: #e8f1fc;
                  font-family: 'Be Vietnam Pro', sans-serif;
                  font-weight: 600;
                  font-size: 14px;
                  cursor: pointer;
                "
              >
                Xem Laptop
              </button>
            </div>
            <div
              style="
                display: flex;
                gap: 22px;
                margin-top: 28px;
                padding-top: 24px;
                border-top: 1px solid rgba(120, 170, 230, 0.14);
              "
            >
              <div>
                <div
                  style="
                    font-family: 'Chakra Petch', sans-serif;
                    font-weight: 700;
                    font-size: 22px;
                    color: #fff;
                  "
                >
                  12K+
                </div>
                <div style="font-size: 11px; color: #7e98b6">Đơn đã giao</div>
              </div>
              <div>
                <div
                  style="
                    font-family: 'Chakra Petch', sans-serif;
                    font-weight: 700;
                    font-size: 22px;
                    color: #fff;
                  "
                >
                  4.9★
                </div>
                <div style="font-size: 11px; color: #7e98b6">
                  Đánh giá khách
                </div>
              </div>
              <div>
                <div
                  style="
                    font-family: 'Chakra Petch', sans-serif;
                    font-weight: 700;
                    font-size: 22px;
                    color: #fff;
                  "
                >
                  36th
                </div>
                <div style="font-size: 11px; color: #7e98b6">
                  Bảo hành tối đa
                </div>
              </div>
            </div>
          </div>
        </div>
      </aside>

      <!-- CENTER — content -->
      <div>
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
              background: #0a2138;
              border: 1px solid rgba(120, 170, 230, 0.12);
            "
          >
            <div style="font-size: 22px">{{ t.icon }}</div>
            <div>
              <div style="font-weight: 700; font-size: 13.5px; color: #e8f1fc">
                {{ t.title }}
              </div>
              <div style="font-size: 11.5px; color: #7e98b6">{{ t.sub }}</div>
            </div>
          </div>
        </section>

        <!-- category tiles -->
        <section
          style="
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(148px, 1fr));
            gap: 12px;
          "
        >
          <div
            v-for="tile in catTiles"
            :key="tile.key"
            @click="actions.goCat(tile.key)"
            class="cat-tile"
            :style="{ '--ph': tile.hue, '--acc': accent }"
            style="
              cursor: pointer;
              border-radius: 14px;
              padding: 18px 16px;
              background: linear-gradient(
                160deg,
                hsl(var(--ph) 45% 16%),
                hsl(var(--ph) 55% 10%)
              );
              border: 1px solid rgba(120, 170, 230, 0.16);
              transition:
                transform 0.16s,
                border-color 0.16s;
            "
          >
            <div
              style="
                font-family: 'Chakra Petch', sans-serif;
                font-size: 10px;
                letter-spacing: 2px;
                color: hsl(var(--ph) 70% 75%);
                font-weight: 600;
              "
            >
              {{ tile.en }}
            </div>
            <div
              style="
                font-family: 'Be Vietnam Pro', sans-serif;
                font-weight: 700;
                font-size: 15px;
                margin-top: 8px;
                color: #fff;
              "
            >
              {{ tile.vn }}
            </div>
            <div style="font-size: 12px; color: #a9c0dc; margin-top: 4px">
              Xem ngay →
            </div>
          </div>
        </section>

        <!-- featured -->
        <section style="margin-top: 34px">
          <div
            style="
              display: flex;
              align-items: flex-end;
              justify-content: space-between;
              margin-bottom: 18px;
            "
          >
            <div>
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
                :style="{ color: themeStyle.ink }"
                style="
                  font-family: 'Be Vietnam Pro', sans-serif;
                  font-weight: 700;
                  font-size: 24px;
                  margin: 6px 0 0;
                "
              >
                Sản phẩm bán chạy
              </h2>
            </div>
            <button
              @click="actions.goCatAll"
              :style="{
                color: themeStyle.inkSoft,
                borderColor:
                  state.mode === 'dark'
                    ? 'rgba(120,170,230,0.25)'
                    : 'rgba(14,34,54,0.2)',
              }"
              style="
                background: transparent;
                border: 1px solid;
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
          <div
            style="
              display: grid;
              grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
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
        </section>
      </div>

      <!-- RIGHT SIDEBAR — build promos -->
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
          @click="actions.goCatPC"
          style="
            cursor: pointer;
            border-radius: 20px;
            overflow: hidden;
            position: relative;
            padding: 26px 24px;
            background: linear-gradient(150deg, #0b3a6e, #081a2d 78%);
            border: 1px solid rgba(120, 170, 230, 0.18);
          "
        >
          <div
            :style="{ color: accent }"
            style="
              font-family: 'Chakra Petch', sans-serif;
              font-size: 10px;
              letter-spacing: 2.5px;
              font-weight: 600;
            "
          >
            CNTT BUILD SERVICE
          </div>
          <h2
            style="
              font-family: 'Be Vietnam Pro', sans-serif;
              font-weight: 800;
              font-size: 22px;
              line-height: 1.2;
              margin: 10px 0 8px;
              color: #e8f1fc;
            "
          >
            PC dựng sẵn — bật là chiến
          </h2>
          <p
            style="
              margin: 0 0 18px;
              color: #a9c0dc;
              font-size: 13px;
              line-height: 1.55;
            "
          >
            Đi dây gọn gàng, test stress 24h, cài sẵn Windows & driver. Đổi cấu
            hình theo nhu cầu.
          </p>
          <div
            :style="{ background: accent }"
            style="
              display: inline-flex;
              font-family: 'Be Vietnam Pro', sans-serif;
              font-weight: 700;
              font-size: 13.5px;
              color: #04121f;
              padding: 12px 22px;
              border-radius: 11px;
            "
          >
            Khám phá build →
          </div>
        </div>
        <div
          @click="actions.goCatPC"
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
              color: #e8f1fc;
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
              color: #e8f1fc;
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
                ><span style="color: #e8f1fc; font-weight: 600">1900 1903</span>
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
            href="tel:19001903"
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
            "
            >Liên hệ ngay →</a
          >
        </div>
      </aside>
    </div>
  </main>
</template>

<style scoped>
.cat-tile:hover {
  transform: translateY(-3px);
  border-color: var(--acc) !important;
}
</style>
