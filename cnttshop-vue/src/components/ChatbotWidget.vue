<script setup>
/**
 * Chatbot hỗ trợ khách hàng — RULE-BASED, có tra cứu SẢN PHẨM THẬT từ DB.
 *
 * 3 luồng:
 *  (1) FAQ            — khớp từ khóa, trả lời có sẵn.
 *  (2) Tư vấn sản phẩm — hỏi danh mục + ngân sách, lọc trong `products` đã nạp sẵn.
 *  (3) Tra giá sản phẩm — gõ tự nhiên ("giá RAM Corsair 32GB bao nhiêu") hoặc bấm nút
 *      "Tra cứu giá sản phẩm" rồi gõ tên. Bot tự tách từ khóa, gọi thẳng API có sẵn
 *      GET /api/products?keyword=... (CatalogApiController, đã hỗ trợ tìm theo tên,
 *      không cần sửa backend) để lấy giá THẬT từ DB, tối đa 5 kết quả khớp nhất.
 *
 * Cách dùng: <ChatbotWidget /> đặt 1 lần trong App.vue.
 */
import { ref, reactive, computed, nextTick } from "vue";
import { products, catMeta, fmt } from "../data/products.js";
import { accent, actions } from "../store.js";
import { fetchProducts } from "../api.js";

// ---------- trạng thái cửa sổ chat ----------
const open = ref(false);
const inputText = ref("");
const scrollBox = ref(null);
let msgId = 0;

const messages = reactive([]);

function pushBot(payload) {
  const m = { id: ++msgId, from: "bot", ...payload };
  messages.push(m);
  scrollToBottom();
  return m;
}
function pushUser(text) {
  messages.push({ id: ++msgId, from: "user", type: "text", text });
  scrollToBottom();
}
function scrollToBottom() {
  nextTick(() => {
    if (scrollBox.value)
      scrollBox.value.scrollTop = scrollBox.value.scrollHeight;
  });
}

// ---------- luồng hội thoại ----------
// step: 'menu' | 'faq' | 'awaiting_category' | 'awaiting_budget' | 'awaiting_product_search'
const step = ref("menu");
const draft = reactive({ categoryKey: null, categoryLabel: "" });

const MAIN_MENU = [
  { label: "🔎 Tra cứu giá sản phẩm", action: "start_price_search" },
  { label: "🛒 Tư vấn chọn sản phẩm", action: "start_advise" },
  { label: "📦 Câu hỏi thường gặp", action: "faq_menu" },
  { label: "📞 Gặp nhân viên tư vấn", action: "contact" },
];

const FAQ_MENU = [
  { label: "Chính sách bảo hành", key: "baohanh" },
  { label: "Phí & thời gian giao hàng", key: "giaohang" },
  { label: "Đổi trả / hoàn tiền", key: "doitra" },
  { label: "Phương thức thanh toán", key: "thanhtoan" },
  { label: "Trả góp 0%", key: "tragop" },
  { label: "⬅ Quay lại menu chính", key: "back" },
];

// ---------- kho câu trả lời FAQ (rule-based, khớp từ khóa) ----------
const FAQ_DB = {
  baohanh: {
    keywords: ["bảo hành", "bao hanh", "warranty", "lỗi", "hỏng"],
    answer:
      "CNTTshop bảo hành chính hãng từ 12–36 tháng tùy sản phẩm. Trong 7 ngày đầu nếu lỗi do nhà sản xuất, được 1 đổi 1.",
  },
  giaohang: {
    keywords: [
      "giao hàng",
      "vận chuyển",
      "ship",
      "phí ship",
      "bao lâu nhận",
      "giao mấy ngày",
    ],
    answer:
      "Nội thành HN/TP.HCM giao trong 2–24h. Tỉnh thành khác 2–4 ngày. Phí ship tính theo khu vực và khối lượng đơn.",
  },
  doitra: {
    keywords: ["đổi trả", "hoàn tiền", "trả hàng", "không ưng"],
    answer:
      "Đổi trả miễn phí trong 7 ngày nếu sản phẩm lỗi do nhà sản xuất, còn nguyên hộp/tem.",
  },
  thanhtoan: {
    keywords: [
      "thanh toán",
      "cod",
      "chuyển khoản",
      "vnpay",
      "momo",
      "ví điện tử",
    ],
    answer:
      "Hỗ trợ: Thanh toán khi nhận hàng (COD), chuyển khoản ngân hàng, VNPay (QR/thẻ nội địa) và thẻ quốc tế qua Stripe.",
  },
  tragop: {
    keywords: ["trả góp", "góp", "installment", "trả chậm"],
    answer:
      "Trả góp 0% lãi suất qua thẻ tín dụng hoặc công ty tài chính, áp dụng cho đơn từ 3 triệu trở lên.",
  },
  lienhe: {
    keywords: [
      "liên hệ",
      "hotline",
      "số điện thoại",
      "nhân viên",
      "tư vấn viên",
    ],
    answer: "Hotline: 0835 344 974 (8:00–22:00) · Email: cskh@cnttshop.vn.",
  },
};

function matchFaqByText(text) {
  const t = text.toLowerCase();
  for (const key in FAQ_DB) {
    if (FAQ_DB[key].keywords.some((k) => t.includes(k))) return key;
  }
  return null;
}

// ---------- nhận diện câu hỏi giá + tách từ khóa sản phẩm ----------
const PRICE_QUESTION_RE = /giá|bao nhiêu|nhiêu tiền|giá tiền|giá bán/i;

function isPriceQuestion(text) {
  return PRICE_QUESTION_RE.test(text);
}

// Các cụm/hư từ hay đi kèm câu hỏi giá tiếng Việt — loại bỏ để còn lại tên sản phẩm.
const STRIP_PATTERNS = [
  /giá\s+của/gi,
  /giá\s+bán/gi,
  /giá\s+tiền/gi,
  /bao nhiêu tiền/gi,
  /là bao nhiêu/gi,
  /bao nhiêu/gi,
  /giá/gi,
  /nhiêu tiền/gi,
  /^tiền\b/gi,
  /cho mình hỏi/gi,
  /cho mình xin hỏi/gi,
  /mình muốn hỏi/gi,
  /mình muốn biết/gi,
  /cho tôi hỏi/gi,
  /tôi muốn hỏi/gi,
  /xin hỏi/gi,
  /mình hỏi/gi,
  /shop ơi/gi,
  /\bcủa\b/gi,
  /\blà\b/gi,
  /\bvậy ạ\b/gi,
  /\bvậy\b/gi,
  /\bnhé\b/gi,
  /\bạ\b/gi,
  /\bcho\b/gi,
  /\bxem\b/gi,
  /\bcon\b/gi,
  /\?/g,
];

function extractProductKeyword(text) {
  let t = text;
  STRIP_PATTERNS.forEach((p) => {
    t = t.replace(p, " ");
  });
  return t.replace(/\s+/g, " ").trim();
}

// ---------- khởi tạo hội thoại ----------
function greet() {
  messages.length = 0;
  step.value = "menu";
  pushBot({
    type: "text",
    text: 'Chào bạn 👋 Mình là trợ lý CNTTshop. Bạn có thể hỏi thẳng giá sản phẩm (VD: "giá RAM Corsair 32GB") hoặc chọn mục bên dưới.',
  });
  pushBot({ type: "quick-replies", options: MAIN_MENU });
}

function toggleOpen() {
  open.value = !open.value;
  if (open.value && messages.length === 0) greet();
}

// ---------- xử lý bấm nút gợi ý nhanh ----------
function onMainMenuClick(item) {
  pushUser(item.label);
  if (item.action === "faq_menu") {
    step.value = "faq";
    pushBot({ type: "text", text: "Bạn muốn hỏi về mục nào?" });
    pushBot({
      type: "quick-replies",
      options: FAQ_MENU.map((f) => ({ label: f.label, key: f.key })),
    });
  } else if (item.action === "start_advise") {
    startAdvise();
  } else if (item.action === "start_price_search") {
    step.value = "awaiting_product_search";
    pushBot({
      type: "text",
      text: 'Bạn muốn tra giá sản phẩm nào? Gõ tên sản phẩm giúp mình nhé (VD: "RTX 4060").',
    });
  } else if (item.action === "contact") {
    answerFaq("lienhe");
  } else if (item.action && item.action.startsWith("nav_")) {
    // Điều hướng tới trang thật rồi đóng chat (tinh chỉnh: chatbot dẫn sang các trang chính sách
    // / hỗ trợ đã dựng, thay vì chỉ trả lời chữ).
    const fn = NAV_ACTIONS[item.action];
    if (fn) { open.value = false; fn(); }
  }
}

// Mỗi chủ đề FAQ có trang thật -> gợi ý nút mở trang. Dùng store actions đã có.
const NAV_ACTIONS = {
  nav_tragop: actions.goInstallmentPolicy,
  nav_doitra: actions.goReturnPolicy,
  nav_baohanh: actions.goWarrantyInfo,
  nav_lienhe: actions.goContact,
  nav_support: actions.goSupport,
};
const FAQ_NAV = {
  tragop: { label: "📄 Xem chính sách trả góp", action: "nav_tragop" },
  doitra: { label: "↩️ Xem chính sách đổi trả", action: "nav_doitra" },
  baohanh: { label: "🛡️ Tra cứu & chính sách bảo hành", action: "nav_baohanh" },
  lienhe: { label: "📞 Mở trang liên hệ", action: "nav_lienhe" },
};

function onFaqMenuClick(item) {
  pushUser(item.label);
  if (item.key === "back") {
    step.value = "menu";
    pushBot({ type: "text", text: "Bạn cần hỗ trợ gì tiếp không?" });
    pushBot({ type: "quick-replies", options: MAIN_MENU });
    return;
  }
  answerFaq(item.key);
}

function answerFaq(key) {
  const faq = FAQ_DB[key];
  pushBot({
    type: "text",
    text: faq
      ? faq.answer
      : "Mình chưa có thông tin này, bạn gọi hotline 0835 344 974 giúp mình nhé.",
  });
  // Chủ đề nào có trang thật thì kèm nút mở trang, rồi mới tới menu FAQ.
  const nav = FAQ_NAV[key];
  const options = [];
  if (nav) options.push(nav);
  options.push(...FAQ_MENU.map((f) => ({ label: f.label, key: f.key })));
  pushBot({ type: "quick-replies", options });
}

// ---------- luồng tư vấn sản phẩm (theo danh mục + ngân sách, dữ liệu local) ----------
const categoryOptions = computed(() =>
  Object.keys(catMeta).map((key) => ({ label: catMeta[key].vn, key }))
);

const BUDGET_OPTIONS = [
  { label: "Dưới 10 triệu", min: 0, max: 10000000 },
  { label: "10 – 20 triệu", min: 10000000, max: 20000000 },
  { label: "20 – 40 triệu", min: 20000000, max: 40000000 },
  { label: "Trên 40 triệu", min: 40000000, max: Infinity },
];

function startAdvise() {
  step.value = "awaiting_category";
  pushBot({ type: "text", text: "Bạn đang quan tâm nhóm sản phẩm nào?" });
  pushBot({ type: "quick-replies", options: categoryOptions.value });
}

function onCategoryClick(item) {
  pushUser(item.label);
  draft.categoryKey = item.key;
  draft.categoryLabel = item.label;
  step.value = "awaiting_budget";
  pushBot({
    type: "text",
    text: `Ngân sách bạn dự tính cho ${item.label.toLowerCase()} khoảng bao nhiêu?`,
  });
  pushBot({
    type: "quick-replies",
    options: BUDGET_OPTIONS.map((b) => ({
      label: b.label,
      min: b.min,
      max: b.max,
    })),
  });
}

function onBudgetClick(item) {
  pushUser(item.label);
  const list = products
    .filter(
      (p) =>
        p.cat === draft.categoryKey &&
        p.price >= item.min &&
        p.price <= item.max
    )
    .sort((a, b) => a.price - b.price)
    .slice(0, 5);

  if (list.length === 0) {
    pushBot({
      type: "text",
      text: `Hiện chưa có ${draft.categoryLabel.toLowerCase()} nào trong tầm giá này, bạn thử mức khác xem sao nhé.`,
    });
    pushBot({
      type: "quick-replies",
      options: BUDGET_OPTIONS.map((b) => ({
        label: b.label,
        min: b.min,
        max: b.max,
      })),
    });
    return;
  }

  pushBot({
    type: "text",
    text: `Mình gợi ý ${list.length} sản phẩm phù hợp:`,
  });
  pushBot({ type: "products", items: list });
  pushBot({ type: "quick-replies", options: MAIN_MENU });
  step.value = "menu";
}

// ---------- luồng tra giá sản phẩm (gọi thẳng API /api/products, dữ liệu DB thật) ----------
async function searchProductPrice(keyword) {
  const loadingMsg = pushBot({
    type: "text",
    text: `Đang tìm "${keyword}"...`,
  });

  let results = [];
  try {
    results = await fetchProducts({ keyword });
  } catch (e) {
    console.error(e);
  }

  const idx = messages.findIndex((m) => m.id === loadingMsg.id);
  const top5 = (results || []).slice(0, 5);

  if (top5.length === 0) {
    if (idx !== -1)
      messages[idx] = {
        ...loadingMsg,
        text: `Mình không tìm thấy sản phẩm nào khớp với "${keyword}" trong kho. Bạn thử gõ tên ngắn gọn hơn nhé.`,
      };
  } else if (top5.length === 1) {
    const p = top5[0];
    if (idx !== -1)
      messages[idx] = {
        ...loadingMsg,
        text: `${p.name}: ${fmt(p.price)}${
          p.originalPrice ? " (giá gốc " + fmt(p.originalPrice) + ")" : ""
        }`,
      };
    pushBot({ type: "products-api", items: top5 });
  } else {
    if (idx !== -1)
      messages[idx] = {
        ...loadingMsg,
        text: `Mình tìm thấy ${top5.length} sản phẩm khớp với "${keyword}", bạn xem giá bên dưới nhé:`,
      };
    pushBot({ type: "products-api", items: top5 });
  }

  pushBot({ type: "quick-replies", options: MAIN_MENU });
  step.value = "menu";
  scrollToBottom();
}

function openProduct(p) {
  open.value = false;
  actions.goDetail(p.id);
}

// ---------- ô nhập tự do ----------
function sendFreeText() {
  const text = inputText.value.trim();
  if (!text) return;
  pushUser(text);
  inputText.value = "";

  // đang trong luồng "gõ tên sản phẩm cần tra giá" -> dùng nguyên câu làm từ khóa
  if (step.value === "awaiting_product_search") {
    searchProductPrice(text);
    return;
  }

  // câu hỏi dạng "giá ... bao nhiêu" -> tự tách từ khóa rồi tra DB
  if (isPriceQuestion(text)) {
    const keyword = extractProductKeyword(text);
    if (keyword.length >= 2) {
      searchProductPrice(keyword);
      return;
    }
  }

  const key = matchFaqByText(text);
  if (key) {
    answerFaq(key);
  } else {
    pushBot({
      type: "text",
      text: "Mình chưa chắc hiểu ý bạn 🤔 Bạn thử hỏi giá 1 sản phẩm cụ thể, hoặc chọn 1 mục bên dưới nhé:",
    });
    pushBot({ type: "quick-replies", options: MAIN_MENU });
    step.value = "menu";
  }
}
</script>

<template>
  <div class="cbw-root" :style="{ '--acc': accent }">
    <!-- nút nổi -->
    <button
      class="cbw-fab"
      @click="toggleOpen"
      :title="open ? 'Đóng chat' : 'Hỗ trợ trực tuyến'"
    >
      <span v-if="!open">💬</span><span v-else>✕</span>
    </button>

    <!-- cửa sổ chat -->
    <div v-if="open" class="cbw-window">
      <div class="cbw-header">
        <div class="cbw-title">Trợ lý CNTTshop</div>
        <div class="cbw-sub">Tra giá trực tiếp từ kho hàng · phản hồi ngay</div>
      </div>

      <div class="cbw-body" ref="scrollBox">
        <template v-for="m in messages" :key="m.id">
          <!-- tin nhắn văn bản -->
          <div v-if="m.type === 'text'" :class="['cbw-msg', m.from]">
            {{ m.text }}
          </div>

          <!-- nút gợi ý nhanh -->
          <div v-else-if="m.type === 'quick-replies'" class="cbw-replies">
            <button
              v-for="(opt, i) in m.options"
              :key="i"
              class="cbw-reply-btn"
              @click="
                opt.action
                  ? onMainMenuClick(opt)
                  : opt.key !== undefined &&
                    FAQ_MENU.find((f) => f.key === opt.key)
                  ? onFaqMenuClick(opt)
                  : opt.min !== undefined
                  ? onBudgetClick(opt)
                  : onCategoryClick(opt)
              "
            >
              {{ opt.label }}
            </button>
          </div>

          <!-- thẻ sản phẩm gợi ý (dữ liệu local, luồng tư vấn) -->
          <div v-else-if="m.type === 'products'" class="cbw-products">
            <div
              v-for="p in m.items"
              :key="p.id"
              class="cbw-pcard"
              @click="openProduct(p)"
            >
              <div class="cbw-pname">{{ p.name }}</div>
              <div class="cbw-pprice">{{ fmt(p.price) }}</div>
            </div>
          </div>

          <!-- thẻ sản phẩm từ API tra giá (dữ liệu DB thật) -->
          <div v-else-if="m.type === 'products-api'" class="cbw-products">
            <div
              v-for="p in m.items"
              :key="p.id"
              class="cbw-pcard"
              @click="openProduct(p)"
            >
              <div class="cbw-pname">{{ p.name }}</div>
              <div class="cbw-pprice">
                {{ fmt(p.price) }}
                <span v-if="p.originalPrice" class="cbw-pold">{{
                  fmt(p.originalPrice)
                }}</span>
              </div>
              <div v-if="p.brandName || p.categoryName" class="cbw-pmeta">
                {{ p.brandName || p.categoryName }}
              </div>
            </div>
          </div>
        </template>
      </div>

      <form class="cbw-inputbar" @submit.prevent="sendFreeText">
        <input
          v-model="inputText"
          type="text"
          placeholder="Hỏi giá sản phẩm hoặc câu hỏi khác..."
        />
        <button type="submit">Gửi</button>
      </form>
    </div>
  </div>
</template>

<style scoped>
.cbw-root {
  position: fixed;
  right: 22px;
  /* Chừa chỗ cho nút So sánh nằm ngay DƯỚI nút chatbot (xem CompareFab: 56px + 22px đáy
     + 12px khoảng cách). Đổi số ở đây thì đổi cả bên đó. */
  bottom: 90px;
  z-index: 200;
  font-family: "Be Vietnam Pro", sans-serif;
}

.cbw-fab {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  border: none;
  background: var(--acc);
  color: #04121f;
  font-size: 24px;
  cursor: pointer;
  box-shadow: 0 10px 26px rgba(0, 0, 0, 0.4);
}

.cbw-window {
  position: absolute;
  right: 0;
  bottom: 68px;
  width: 340px;
  max-height: 520px;
  background: #0a2138;
  border: 1px solid rgba(120, 170, 230, 0.18);
  border-radius: 16px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5);
}

.cbw-header {
  padding: 14px 16px;
  background: linear-gradient(90deg, #081a2d, #032e5d);
  color: #fff;
}
.cbw-title {
  font-weight: 700;
  font-size: 14.5px;
}
.cbw-sub {
  font-size: 11.5px;
  color: #a9c0dc;
  margin-top: 2px;
}

.cbw-body {
  flex: 1;
  overflow-y: auto;
  padding: 14px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-height: 380px;
}

.cbw-msg {
  max-width: 85%;
  padding: 9px 12px;
  border-radius: 12px;
  font-size: 13px;
  line-height: 1.5;
}
.cbw-msg.bot {
  align-self: flex-start;
  background: #0c2742;
  color: #e8f1fc;
  border-bottom-left-radius: 3px;
}
.cbw-msg.user {
  align-self: flex-end;
  background: var(--acc);
  color: #04121f;
  border-bottom-right-radius: 3px;
  font-weight: 600;
}

.cbw-replies {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}
.cbw-reply-btn {
  border: 1px solid rgba(120, 170, 230, 0.3);
  background: transparent;
  color: #cfdceb;
  padding: 6px 11px;
  border-radius: 20px;
  font-size: 12px;
  cursor: pointer;
}
.cbw-reply-btn:hover {
  border-color: var(--acc);
  color: var(--acc);
}

.cbw-products {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.cbw-pcard {
  cursor: pointer;
  padding: 8px 10px;
  border: 1px solid rgba(120, 170, 230, 0.18);
  border-radius: 10px;
  background: #0c2742;
}
.cbw-pname {
  font-size: 12.5px;
  color: #e8f1fc;
  font-weight: 600;
}
.cbw-pprice {
  font-size: 12px;
  color: var(--acc);
  margin-top: 2px;
  font-weight: 700;
  display: flex;
  gap: 8px;
  align-items: baseline;
}
.cbw-pold {
  font-size: 10.5px;
  color: #6e87a6;
  text-decoration: line-through;
  font-weight: 500;
}
.cbw-pmeta {
  font-size: 10.5px;
  color: #7e98b6;
  margin-top: 2px;
}

.cbw-inputbar {
  display: flex;
  border-top: 1px solid rgba(120, 170, 230, 0.14);
}
.cbw-inputbar input {
  flex: 1;
  background: transparent;
  border: none;
  padding: 12px 14px;
  color: #e8f1fc;
  font-size: 13px;
}
.cbw-inputbar input:focus {
  outline: none;
}
.cbw-inputbar button {
  border: none;
  background: var(--acc);
  color: #04121f;
  font-weight: 700;
  padding: 0 16px;
  cursor: pointer;
}
</style>
