<script setup>
/**
 * Chatbot hỗ trợ khách hàng — RULE-BASED (không gọi AI/API ngoài).
 * 2 luồng: (1) FAQ khớp từ khóa  (2) Tư vấn sản phẩm theo danh mục + ngân sách,
 * dùng lại dữ liệu `products` / `catMeta` đã nạp sẵn trong store.js — không gọi thêm API.
 *
 * Cách dùng: import và đặt <ChatbotWidget /> một lần trong App.vue (ví dụ cạnh
 * <ToastMessage /> / <LoadingOverlay />), nó tự nổi cố định góc phải màn hình.
 */
import { ref, reactive, computed, nextTick } from 'vue'
import { products, catMeta, fmt } from '../data/products.js'
import { accent, actions } from '../store.js'

// ---------- trạng thái cửa sổ chat ----------
const open = ref(false)
const inputText = ref('')
const scrollBox = ref(null)
let msgId = 0

const messages = reactive([])

function pushBot(payload) {
  messages.push({ id: ++msgId, from: 'bot', ...payload })
  scrollToBottom()
}
function pushUser(text) {
  messages.push({ id: ++msgId, from: 'user', type: 'text', text })
  scrollToBottom()
}
function scrollToBottom() {
  nextTick(() => {
    if (scrollBox.value) scrollBox.value.scrollTop = scrollBox.value.scrollHeight
  })
}

// ---------- luồng hội thoại (state machine đơn giản) ----------
// step: 'menu' | 'awaiting_category' | 'awaiting_budget' | 'idle'
const step = ref('menu')
const draft = reactive({ categoryKey: null, categoryLabel: '' })

const MAIN_MENU = [
  { label: '📦 Câu hỏi thường gặp', action: 'faq_menu' },
  { label: '🛒 Tư vấn chọn sản phẩm', action: 'start_advise' },
  { label: '📞 Gặp nhân viên tư vấn', action: 'contact' }
]

const FAQ_MENU = [
  { label: 'Chính sách bảo hành', key: 'baohanh' },
  { label: 'Phí & thời gian giao hàng', key: 'giaohang' },
  { label: 'Đổi trả / hoàn tiền', key: 'doitra' },
  { label: 'Phương thức thanh toán', key: 'thanhtoan' },
  { label: 'Trả góp 0%', key: 'tragop' },
  { label: '⬅ Quay lại menu chính', key: 'back' }
]

// ---------- kho câu trả lời FAQ (rule-based, khớp từ khóa) ----------
const FAQ_DB = {
  baohanh: {
    keywords: ['bảo hành', 'bao hanh', 'warranty', 'lỗi', 'hỏng'],
    answer: 'CNTTshop bảo hành chính hãng từ 12–36 tháng tùy sản phẩm. Trong 7 ngày đầu nếu lỗi do nhà sản xuất, được 1 đổi 1. Bạn có thể vào mục "Tra cứu bảo hành" trong tài khoản để xem chi tiết.'
  },
  giaohang: {
    keywords: ['giao hàng', 'vận chuyển', 'ship', 'phí ship', 'bao lâu nhận', 'giao mấy ngày'],
    answer: 'Nội thành HN/TP.HCM giao trong 2–24h. Tỉnh thành khác 2–4 ngày. Phí ship tính theo khu vực và khối lượng đơn — miễn phí khi đơn đạt mức tối thiểu của từng khu vực.'
  },
  doitra: {
    keywords: ['đổi trả', 'hoàn tiền', 'trả hàng', 'không ưng'],
    answer: 'Đổi trả miễn phí trong 7 ngày nếu sản phẩm lỗi do nhà sản xuất, còn nguyên hộp/tem. Với đơn đổi ý không do lỗi, vui lòng liên hệ hotline để được hỗ trợ theo từng trường hợp.'
  },
  thanhtoan: {
    keywords: ['thanh toán', 'cod', 'chuyển khoản', 'vnpay', 'momo', 'ví điện tử'],
    answer: 'Hỗ trợ: Thanh toán khi nhận hàng (COD), VNPay, MoMo, hoặc chuyển khoản ngân hàng. Chọn phương thức ngay ở bước đặt hàng.'
  },
  tragop: {
    keywords: ['trả góp', 'góp', 'installment', 'trả chậm'],
    answer: 'Trả góp 0% lãi suất qua thẻ tín dụng hoặc công ty tài chính, áp dụng cho đơn từ 3 triệu trở lên. Liên hệ hotline 1900 1903 để được tư vấn hồ sơ nhanh.'
  },
  lienhe: {
    keywords: ['liên hệ', 'hotline', 'số điện thoại', 'nhân viên', 'tư vấn viên'],
    answer: 'Hotline: 1900 1903 (8:00–22:00) · Email: cskh@cnttshop.vn. Bạn cũng có thể để lại câu hỏi ở đây, mình sẽ cố gắng hỗ trợ trước!'
  }
}

function matchFaqByText(text) {
  const t = text.toLowerCase()
  for (const key in FAQ_DB) {
    if (FAQ_DB[key].keywords.some(k => t.includes(k))) return key
  }
  return null
}

// ---------- khởi tạo hội thoại ----------
function greet() {
  messages.length = 0
  step.value = 'menu'
  pushBot({
    type: 'text',
    text: 'Chào bạn 👋 Mình là trợ lý CNTTshop. Mình có thể giúp gì cho bạn?'
  })
  pushBot({ type: 'quick-replies', options: MAIN_MENU })
}

function toggleOpen() {
  open.value = !open.value
  if (open.value && messages.length === 0) greet()
}

// ---------- xử lý khi bấm nút gợi ý nhanh ----------
function onMainMenuClick(item) {
  pushUser(item.label)
  if (item.action === 'faq_menu') {
    step.value = 'faq'
    pushBot({ type: 'text', text: 'Bạn muốn hỏi về mục nào?' })
    pushBot({ type: 'quick-replies', options: FAQ_MENU.map(f => ({ label: f.label, key: f.key })) })
  } else if (item.action === 'start_advise') {
    startAdvise()
  } else if (item.action === 'contact') {
    answerFaq('lienhe')
  }
}

function onFaqMenuClick(item) {
  pushUser(item.label)
  if (item.key === 'back') {
    step.value = 'menu'
    pushBot({ type: 'text', text: 'Bạn cần hỗ trợ gì tiếp không?' })
    pushBot({ type: 'quick-replies', options: MAIN_MENU })
    return
  }
  answerFaq(item.key)
}

function answerFaq(key) {
  const faq = FAQ_DB[key]
  pushBot({ type: 'text', text: faq ? faq.answer : 'Mình chưa có thông tin này, bạn gọi hotline 1900 1903 giúp mình nhé.' })
  pushBot({ type: 'quick-replies', options: FAQ_MENU.map(f => ({ label: f.label, key: f.key })) })
}

// ---------- luồng tư vấn sản phẩm ----------
const categoryOptions = computed(() =>
  Object.keys(catMeta).map(key => ({ label: catMeta[key].vn, key }))
)

const BUDGET_OPTIONS = [
  { label: 'Dưới 10 triệu', min: 0, max: 10000000 },
  { label: '10 – 20 triệu', min: 10000000, max: 20000000 },
  { label: '20 – 40 triệu', min: 20000000, max: 40000000 },
  { label: 'Trên 40 triệu', min: 40000000, max: Infinity }
]

function startAdvise() {
  step.value = 'awaiting_category'
  pushBot({ type: 'text', text: 'Bạn đang quan tâm nhóm sản phẩm nào?' })
  pushBot({ type: 'quick-replies', options: categoryOptions.value })
}

function onCategoryClick(item) {
  pushUser(item.label)
  draft.categoryKey = item.key
  draft.categoryLabel = item.label
  step.value = 'awaiting_budget'
  pushBot({ type: 'text', text: `Ngân sách bạn dự tính cho ${item.label.toLowerCase()} khoảng bao nhiêu?` })
  pushBot({ type: 'quick-replies', options: BUDGET_OPTIONS.map(b => ({ label: b.label, min: b.min, max: b.max })) })
}

function onBudgetClick(item) {
  pushUser(item.label)
  const list = products
    .filter(p => p.cat === draft.categoryKey && p.price >= item.min && p.price <= item.max)
    .sort((a, b) => a.price - b.price)
    .slice(0, 5)

  if (list.length === 0) {
    pushBot({ type: 'text', text: `Hiện chưa có ${draft.categoryLabel.toLowerCase()} nào trong tầm giá này, bạn thử mức khác xem sao nhé.` })
    pushBot({ type: 'quick-replies', options: BUDGET_OPTIONS.map(b => ({ label: b.label, min: b.min, max: b.max })) })
    return
  }

  pushBot({ type: 'text', text: `Mình gợi ý ${list.length} sản phẩm phù hợp:` })
  pushBot({ type: 'products', items: list })
  pushBot({ type: 'quick-replies', options: MAIN_MENU })
  step.value = 'menu'
}

function openProduct(p) {
  open.value = false
  actions.goDetail(p.id)
}

// ---------- ô nhập tự do ----------
function sendFreeText() {
  const text = inputText.value.trim()
  if (!text) return
  pushUser(text)
  inputText.value = ''
  const key = matchFaqByText(text)
  if (key) {
    answerFaq(key)
  } else {
    pushBot({ type: 'text', text: 'Mình chưa chắc hiểu ý bạn 🤔 Bạn thử chọn 1 mục bên dưới nhé:' })
    pushBot({ type: 'quick-replies', options: MAIN_MENU })
    step.value = 'menu'
  }
}
</script>

<template>
  <div class="cbw-root" :style="{ '--acc': accent }">
    <!-- nút nổi -->
    <button class="cbw-fab" @click="toggleOpen" :title="open ? 'Đóng chat' : 'Hỗ trợ trực tuyến'">
      <span v-if="!open">💬</span><span v-else>✕</span>
    </button>

    <!-- cửa sổ chat -->
    <div v-if="open" class="cbw-window">
      <div class="cbw-header">
        <div class="cbw-title">Trợ lý CNTTshop</div>
        <div class="cbw-sub">Trả lời tự động · phản hồi ngay</div>
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
                m.options === MAIN_MENU || opt.action
                  ? onMainMenuClick(opt)
                  : opt.key !== undefined && FAQ_MENU.find(f => f.key === opt.key)
                    ? onFaqMenuClick(opt)
                    : opt.min !== undefined
                      ? onBudgetClick(opt)
                      : onCategoryClick(opt)
              "
            >
              {{ opt.label }}
            </button>
          </div>

          <!-- thẻ sản phẩm gợi ý -->
          <div v-else-if="m.type === 'products'" class="cbw-products">
            <div v-for="p in m.items" :key="p.id" class="cbw-pcard" @click="openProduct(p)">
              <div class="cbw-pname">{{ p.name }}</div>
              <div class="cbw-pprice">{{ fmt(p.price) }}</div>
            </div>
          </div>
        </template>
      </div>

      <form class="cbw-inputbar" @submit.prevent="sendFreeText">
        <input v-model="inputText" type="text" placeholder="Nhập câu hỏi của bạn..." />
        <button type="submit">Gửi</button>
      </form>
    </div>
  </div>
</template>

<style scoped>
.cbw-root { position: fixed; right: 22px; bottom: 22px; z-index: 200; font-family: 'Be Vietnam Pro', sans-serif; }

.cbw-fab {
  width: 56px; height: 56px; border-radius: 50%; border: none;
  background: var(--acc); color: #04121f; font-size: 24px; cursor: pointer;
  box-shadow: 0 10px 26px rgba(0,0,0,.4);
}

.cbw-window {
  position: absolute; right: 0; bottom: 68px; width: 340px; max-height: 500px;
  background: #0a2138; border: 1px solid rgba(120,170,230,0.18); border-radius: 16px;
  display: flex; flex-direction: column; overflow: hidden;
  box-shadow: 0 20px 50px rgba(0,0,0,.5);
}

.cbw-header {
  padding: 14px 16px; background: linear-gradient(90deg, #081a2d, #032e5d); color: #fff;
}
.cbw-title { font-weight: 700; font-size: 14.5px; }
.cbw-sub { font-size: 11.5px; color: #a9c0dc; margin-top: 2px; }

.cbw-body {
  flex: 1; overflow-y: auto; padding: 14px; display: flex; flex-direction: column; gap: 10px;
  max-height: 360px;
}

.cbw-msg {
  max-width: 85%; padding: 9px 12px; border-radius: 12px; font-size: 13px; line-height: 1.5;
}
.cbw-msg.bot { align-self: flex-start; background: #0c2742; color: #e8f1fc; border-bottom-left-radius: 3px; }
.cbw-msg.user { align-self: flex-end; background: var(--acc); color: #04121f; border-bottom-right-radius: 3px; font-weight: 600; }

.cbw-replies { display: flex; flex-wrap: wrap; gap: 6px; }
.cbw-reply-btn {
  border: 1px solid rgba(120,170,230,0.3); background: transparent; color: #cfdceb;
  padding: 6px 11px; border-radius: 20px; font-size: 12px; cursor: pointer;
}
.cbw-reply-btn:hover { border-color: var(--acc); color: var(--acc); }

.cbw-products { display: flex; flex-direction: column; gap: 6px; }
.cbw-pcard {
  cursor: pointer; padding: 8px 10px; border: 1px solid rgba(120,170,230,0.18);
  border-radius: 10px; background: #0c2742;
}
.cbw-pname { font-size: 12.5px; color: #e8f1fc; font-weight: 600; }
.cbw-pprice { font-size: 12px; color: var(--acc); margin-top: 2px; font-weight: 700; }

.cbw-inputbar { display: flex; border-top: 1px solid rgba(120,170,230,0.14); }
.cbw-inputbar input {
  flex: 1; background: transparent; border: none; padding: 12px 14px; color: #e8f1fc; font-size: 13px;
}
.cbw-inputbar input:focus { outline: none; }
.cbw-inputbar button {
  border: none; background: var(--acc); color: #04121f; font-weight: 700; padding: 0 16px; cursor: pointer;
}
</style>
