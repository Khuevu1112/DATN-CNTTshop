<script setup>
/**
 * Trợ lý chat CNTTshop — RULE-BASED (không gọi LLM), nhưng kiến thức trải rộng qua TOÀN BỘ
 * dữ liệu công khai của web thay vì chỉ tra giá + vài câu FAQ tĩnh như bản cũ:
 *
 *   - Sản phẩm: toàn bộ catalog đã nạp sẵn ở app boot (data/products.js `products`, xem
 *     loadCatalog) — tra giá, tư vấn theo ngân sách, tìm theo tên/thông số.
 *   - So sánh & Tài chính: TÍCH HỢP THẲNG hệ so sánh hiện có — dùng chung compareRank.js
 *     (chamDiem/diemSanPham/phanLoaiHuong) với CompareDrawer.vue, và thêm/mở trực tiếp
 *     state.compareItems + CompareDrawer thay vì tự vẽ lại 1 bảng so sánh riêng.
 *   - FAQ thật từ backend (32 câu, 10 danh mục, có từ khoá) thay vì 6 câu tĩnh hard-code.
 *   - Khuyến mãi (flash sale + sản phẩm đang giảm giá), Tin tức (tìm theo từ khoá), Trung tâm
 *     bảo hành, Bảng giá sửa chữa, Gói hội viên CNTT Care — đều là API công khai có sẵn
 *     (xem api.js), trước đây chatbot hoàn toàn không đụng tới.
 *
 * Giao diện: sidebar LỚN trượt từ phải (cùng khung nhìn với CompareDrawer — mask + aside +
 * cùng 1 bộ token màu xám trung tính DARK/LIGHT) thay vì cửa sổ nhỏ góc màn hình, để có đủ
 * chỗ cho card sản phẩm dạng lưới, bảng so sánh tài chính mini, danh sách trung tâm/bài viết...
 * Bên trái là rail chủ đề LUÔN HIỂN THỊ (khác quick-reply chỉ hiện tạm trong hội thoại) để
 * khách vào thẳng chủ đề cần mà không phải gõ.
 */
import { ref, reactive, computed, nextTick, watch } from 'vue';
import { state, actions, accent } from '../store.js';
import { products, catMeta, fmt } from '../data/products.js';
import {
  fetchProducts, fetchFaq, fetchFlashSale, fetchArticles, fetchServiceCenters,
  fetchRepairPrices, fetchSubscriptionPlans, fetchInstallmentConfig, resolveImageUrl,
} from '../api.js';
import { diemSanPham, phanLoaiHuong } from '../data/compareRank.js';
import { LOAI_THIET_BI } from '../data/supportMeta.js';

// ===== Bảng màu — cùng token với CompareDrawer (xem đó để biết lý do chọn xám trung tính). =====
const DARK = {
  '--bot-aside': 'radial-gradient(1200px 600px at 80% -10%, rgb(28, 30, 34) 0%, rgb(16, 17, 20) 55%)',
  '--bot-card': 'rgb(28, 30, 34)',
  '--bot-card2': 'rgb(36, 38, 42)',
  '--bot-card-alt': 'rgb(22, 24, 28)',
  '--bot-border': 'rgba(255,255,255,0.1)',
  '--bot-divider': 'rgba(255,255,255,0.06)',
  '--bot-text': '#eef3f8',
  '--bot-muted': '#8b95a0',
  '--bot-muted2': '#c3c9d1',
  '--bot-stripe': 'repeating-linear-gradient(135deg, rgb(36,38,42), rgb(36,38,42) 6px, rgb(44,46,50) 6px, rgb(44,46,50) 12px)',
  '--bot-overlay': 'rgba(0,0,0,0.55)',
};
const LIGHT = {
  '--bot-aside': 'radial-gradient(1200px 600px at 80% -10%, #ffffff 0%, #f2f3f5 55%)',
  '--bot-card': '#ffffff',
  '--bot-card2': '#f2f3f5',
  '--bot-card-alt': '#f7f8f9',
  '--bot-border': 'rgba(0,0,0,0.1)',
  '--bot-divider': 'rgba(0,0,0,0.07)',
  '--bot-text': '#1a1d21',
  '--bot-muted': '#767b81',
  '--bot-muted2': '#3d4247',
  '--bot-stripe': 'repeating-linear-gradient(135deg, #eef0f2, #eef0f2 6px, #e3e5e8 6px, #e3e5e8 12px)',
  '--bot-overlay': 'rgba(0,0,0,0.3)',
};
const bienMau = computed(() => (state.mode === 'light' ? LIGHT : DARK));

// ===== Hội thoại =====
const messages = reactive([]);
const inputText = ref('');
const scrollBox = ref(null);
let msgId = 0;

function pushBot(payload) {
  const m = { id: ++msgId, from: 'bot', ...payload };
  messages.push(m);
  scrollToBottom();
  return m;
}
function pushUser(text) {
  messages.push({ id: ++msgId, from: 'user', type: 'text', text });
  scrollToBottom();
}
function updateMsg(msg, patch) {
  const idx = messages.findIndex((m) => m.id === msg.id);
  if (idx !== -1) messages[idx] = { ...messages[idx], ...patch };
}
function scrollToBottom() {
  nextTick(() => {
    if (scrollBox.value) scrollBox.value.scrollTop = scrollBox.value.scrollHeight;
  });
}
function quickReplies(options) {
  return { type: 'quick-replies', options };
}
const BACK_OPTION = { label: '⬅ Về menu chính', run: () => { step.value = 'menu'; pushBot({ type: 'text', text: 'Bạn cần hỗ trợ gì tiếp không?' }); pushBot(quickReplies(mainMenuOptions())); } };

// step: menu | awaiting_category | awaiting_budget | awaiting_product_search
//     | awaiting_compare_names | awaiting_finance_names | awaiting_news_keyword
const step = ref('menu');
const draft = reactive({ categoryKey: null, categoryLabel: '' });

// Số hotline dùng chung cho mọi lối "gặp người thật" trong chatbot.
const HOTLINE = '0835344974';

/** Gặp nhân viên tư vấn. Trước đây chỉ in ra số hotline rồi để khách tự xoay xở — giờ mỗi kênh
 * là một hành động bấm được: quay số thẳng (tel:), mở Zalo, hoặc về trang liên hệ để gửi yêu
 * cầu gọi lại nếu đang ngoài giờ trực. */
function contactHuman() {
  answerFaqText(
    `Giờ trực 8:00–22:00 mỗi ngày. Bạn chọn cách liên hệ nhé:
· Hotline 0835 344 974
· Zalo 0835 344 974
· Email cskh@cnttshop.vn`,
    [
      { label: '📞 Gọi ngay 0835 344 974', run: () => { window.location.href = 'tel:' + HOTLINE; } },
      { label: '💬 Nhắn Zalo tư vấn', run: () => { window.open('https://zalo.me/' + HOTLINE, '_blank', 'noopener'); } },
      { label: '✉️ Gửi yêu cầu gọi lại', run: () => { actions.closeChat(); actions.goContact(); } },
    ],
  );
}
function mainMenuOptions() {
  return [
    { label: '🔎 Tra cứu giá sản phẩm', run: startPriceSearch },
    { label: '🛒 Tư vấn theo nhu cầu', run: startAdvise },
    { label: '⇄ So sánh cấu hình', run: startCompare },
    { label: '💰 So sánh tài chính (đáng tiền hơn)', run: startFinance },
    { label: '📦 Câu hỏi thường gặp', run: startFaqMenu },
    { label: '🏷️ Khuyến mãi hôm nay', run: showPromotions },
    { label: '📰 Tin tức & bài viết', run: startNews },
    { label: '📞 Gặp nhân viên tư vấn', run: contactHuman },
  ];
}

function greet() {
  messages.length = 0;
  step.value = 'menu';
  pushBot({
    type: 'text',
    text: 'Chào bạn 👋 Mình là trợ lý CNTTshop. Hỏi mình bất cứ điều gì công khai trên web — giá sản phẩm, so sánh cấu hình, khuyến mãi, chính sách bảo hành/đổi trả, trung tâm bảo hành, bảng giá sửa chữa, gói hội viên... hoặc chọn chủ đề bên trái.',
  });
  pushBot(quickReplies(mainMenuOptions()));
}
watch(() => state.chatOpen, (open) => {
  if (open && messages.length === 0) greet();
});

// ===== Thẻ dùng chung cho nhiều loại nội dung (sản phẩm/bài viết/trung tâm/sửa chữa/gói) =====
function cardsMsg(variant, items) {
  return { type: 'cards', variant, items };
}

// ===== 1) TRA GIÁ SẢN PHẨM (API DB thật — giữ hành vi cũ: freshness quan trọng hơn tốc độ) =====
function startPriceSearch() {
  step.value = 'awaiting_product_search';
  pushBot({ type: 'text', text: 'Bạn muốn tra giá sản phẩm nào? Gõ tên sản phẩm giúp mình nhé (VD: "RTX 4060").' });
}

function productCard(p, { compare = true } = {}) {
  return {
    key: 'p' + p.id,
    image: p.imageUrl ? resolveImageUrl(p.imageUrl) : (p.image ? resolveImageUrl(p.image) : null),
    title: p.name,
    // brandName/categoryName: DTO từ API tra giá; brand: shape catalog local (data/products.js)
    // — 2 nguồn dữ liệu khác field name cho cùng 1 ý nghĩa.
    subtitle: p.brandName || p.categoryName || p.brand || null,
    priceText: fmt(p.price),
    oldPriceText: p.originalPrice > p.price ? fmt(p.originalPrice) : (p.oldPrice > p.price ? fmt(p.oldPrice) : null),
    onClick: () => { actions.closeChat(); actions.goDetail(p.id); },
    onCompareClick: compare ? () => addToCompareFromChat(p) : null,
  };
}

async function searchProductPrice(keyword) {
  const loading = pushBot({ type: 'text', text: `Đang tìm "${keyword}"...` });
  let results = [];
  try { results = await fetchProducts({ keyword }); } catch (e) { /* mạng lỗi -> coi như rỗng */ }
  const top = (results || []).slice(0, 6);

  if (!top.length) {
    updateMsg(loading, { text: `Mình không tìm thấy sản phẩm nào khớp với "${keyword}" trong kho. Bạn thử gõ tên ngắn gọn hơn nhé.` });
  } else if (top.length === 1) {
    const p = top[0];
    updateMsg(loading, { text: `${p.name}: ${fmt(p.price)}${p.originalPrice ? ' (giá gốc ' + fmt(p.originalPrice) + ')' : ''}` });
    pushBot(cardsMsg('product', [productCard(p)]));
  } else {
    updateMsg(loading, { text: `Mình tìm thấy ${top.length} sản phẩm khớp với "${keyword}", bạn xem giá bên dưới nhé:` });
    pushBot(cardsMsg('product', top.map((p) => productCard(p))));
  }
  pushBot(quickReplies(mainMenuOptions()));
  step.value = 'menu';
}

// ===== 2) TƯ VẤN THEO NHU CẦU (danh mục + ngân sách, dùng catalog đã nạp sẵn) =====
const BUDGET_OPTIONS = [
  { label: 'Dưới 10 triệu', min: 0, max: 10000000 },
  { label: '10 – 20 triệu', min: 10000000, max: 20000000 },
  { label: '20 – 40 triệu', min: 20000000, max: 40000000 },
  { label: 'Trên 40 triệu', min: 40000000, max: Infinity },
];

function startAdvise() {
  step.value = 'awaiting_category';
  pushBot({ type: 'text', text: 'Bạn đang quan tâm nhóm sản phẩm nào?' });
  pushBot(quickReplies(Object.keys(catMeta).map((key) => ({
    label: catMeta[key].vn,
    run: () => onCategoryPick(key, catMeta[key].vn),
  }))));
}
function onCategoryPick(key, label) {
  pushUser(label);
  draft.categoryKey = key;
  draft.categoryLabel = label;
  step.value = 'awaiting_budget';
  pushBot({ type: 'text', text: `Ngân sách bạn dự tính cho ${label.toLowerCase()} khoảng bao nhiêu?` });
  pushBot(quickReplies(BUDGET_OPTIONS.map((b) => ({ label: b.label, run: () => onBudgetPick(b) }))));
}
function onBudgetPick(b) {
  pushUser(b.label);
  const list = products
    .filter((p) => p.cat === draft.categoryKey && p.price >= b.min && p.price <= b.max)
    .sort((x, y) => x.price - y.price)
    .slice(0, 6);

  if (!list.length) {
    pushBot({ type: 'text', text: `Hiện chưa có ${draft.categoryLabel.toLowerCase()} nào trong tầm giá này, bạn thử mức khác xem sao nhé.` });
    pushBot(quickReplies(BUDGET_OPTIONS.map((x) => ({ label: x.label, run: () => onBudgetPick(x) }))));
    return;
  }
  pushBot({ type: 'text', text: `Mình gợi ý ${list.length} sản phẩm phù hợp:` });
  pushBot(cardsMsg('product', list.map((p) => productCard(p))));
  pushBot(quickReplies(mainMenuOptions()));
  step.value = 'menu';
}

// ===== Tìm sản phẩm trong catalog local theo từ khoá — nền tảng cho So sánh/Tài chính và
// fallback khi khách gõ thẳng tên sản phẩm không kèm "giá". Chấm điểm thô theo số từ khớp
// trong TÊN — đủ dùng cho 1 bộ định tuyến rule-based, không cần phức tạp hơn. =====
// Danh sách rộng có chủ đích: dùng cho CẢ tìm sản phẩm lẫn suy luận FAQ khi không khớp từ khoá
// (matchFaqRealtime). Thiếu các hư từ/từ đệm phổ biến ("được", "không", "thì"...) từng khiến
// những câu hỏi khác hẳn chủ đề khớp nhầm vào nhau chỉ vì cùng chia sẻ vài từ chung chung —
// tự kiểm chứng bằng dữ liệu FAQ thật (VD "mua xong đổi ý trả lại được không" từng khớp nhầm
// sang câu "đăng nhập bằng Google được không?" chỉ vì chung từ "được"/"không").
const STOPWORDS = new Set([
  'và', 'va', 'với', 'voi', 'cho', 'của', 'cua', 'là', 'la', 'nên', 'nen', 'mua', 'cái', 'cai',
  'nào', 'nao', 'hay', 'so', 'sánh', 'sanh', 'vs', 'giữa', 'giua', 'sản', 'san', 'phẩm', 'pham',
  'mình', 'minh', 'bạn', 'ban', 'tư', 'tu', 'vấn', 'van', 'hơn', 'hon', 'đáng', 'dang', 'tiền',
  'tien', 'tài', 'tai', 'chính', 'chinh', 'giá', 'gia', 'trị', 'tri', 'cần', 'can', 'muốn', 'muon',
  'được', 'duoc', 'không', 'khong', 'có', 'co', 'thì', 'thi', 'làm', 'lam', 'sao', 'gì', 'gi',
  'đâu', 'dau', 'khi', 'này', 'nay', 'đó', 'do', 'về', 've', 'nếu', 'neu', 'hoặc', 'hoac', 'vậy',
  'vay', 'à', 'a', 'ừ', 'u', 'dạ', 'da', 'xin', 'tôi', 'toi', 'shop', 'ơi', 'oi', 'nhé', 'nhe',
  'ạ', 'đang', 'sẽ', 'se', 'đã', 'rồi', 'roi', 'chưa', 'chua', 'còn', 'con',
  'lại', 'lai', 'thế', 'the', 'như', 'nhu', 'mấy', 'may', 'bao', 'lâu', 'lau', 'nhiêu', 'nhieu',
  'ra', 'vào', 'vao', 'lên', 'len', 'xuống', 'xuong', 'khác', 'khac',
]);
/** Bỏ dấu tiếng Việt + hạ chữ thường. Phần rất lớn khách gõ chat KHÔNG bỏ dấu ("bao hanh bao
 * lau", "khuyen mai gi khong") — trước đây mỗi biểu thức nhận dạng ý định phải tự liệt kê cả
 * hai biến thể ("khuyến mãi|khuyen mai") nên chỗ nào quên là chỗ đó câm. Chuẩn hoá một lần ở
 * cửa vào rồi so khớp trên bản không dấu thì cả hai cách gõ đều trúng. */
const DAU_THANH_RE = new RegExp('[\u0300-\u036f]', 'g');
function boDau(s) {
  return String(s).toLowerCase().normalize('NFD').replace(DAU_THANH_RE, '').replace(/đ/g, 'd');
}

// ===== Từ điển VIẾT TẮT / TIẾNG LÓNG CHAT -> cụm đầy đủ =====
// Khách gõ chat gần như luôn viết tắt ("bh con bao lau a", "sp nay con hang ko", "cho e hoi km").
// Bộ định tuyến chỉ nhận ra cụm đầy đủ nên phải giãn ra TRƯỚC khi so khớp. Chỉ thay NGUYÊN từ
// (token), không thay chuỗi con — "km" trong "10km" hay "sp" trong "spec" giữ nguyên.
// Khoá viết dạng KHÔNG DẤU vì bảng này chỉ được tra sau khi đã boDau().
// Chỉ đưa vào đây những tắt CHẮC NGHĨA trong ngữ cảnh shop máy tính; các tắt đa nghĩa
// ("hd" = hoá đơn hay hướng dẫn?, "card" = card màn hình hay card wifi?) cố tình bỏ ra ngoài
// vì đoán sai còn hại hơn không đoán.
const VIET_TAT = {
  // Nghiệp vụ shop
  bh: 'bao hanh', km: 'khuyen mai', kmai: 'khuyen mai', sp: 'san pham',
  dh: 'don hang', dhang: 'don hang', tk: 'tai khoan', mk: 'mat khau',
  tt: 'thanh toan', ttoan: 'thanh toan', ck: 'chuyen khoan',
  gh: 'giao hang', vc: 'van chuyen', doitra: 'doi tra', tragop: 'tra gop',
  hv: 'hoi vien', ttbh: 'trung tam bao hanh', cskh: 'cham soc khach hang',
  sdt: 'so dien thoai', dchi: 'dia chi', kh: 'khach hang',
  // Hàng hoá
  lap: 'laptop', lt: 'laptop', mtinh: 'may tinh', mh: 'man hinh', mhinh: 'man hinh',
  bp: 'ban phim', pk: 'phu kien', lk: 'linh kien', vga: 'card man hinh',
  main: 'mainboard', ocung: 'o cung', tannhiet: 'tan nhiet',
  // Tiếng lóng chat
  ko: 'khong', k: 'khong', hok: 'khong', khong: 'khong', khg: 'khong',
  dc: 'duoc', j: 'gi', z: 'vay', dz: 'vay', r: 'roi',
  bn: 'bao nhieu', bnhieu: 'bao nhieu', nhiu: 'nhieu', ntn: 'nhu the nao',
  bit: 'biet', bik: 'biet', ad: 'admin',
};

/** Giãn viết tắt theo TỪ trên chuỗi đã bỏ dấu. Đây là dạng dùng cho MỌI phép nhận dạng ý định
 * và so khớp FAQ/sản phẩm; câu gốc của khách vẫn giữ nguyên để hiển thị trong bong bóng chat. */
function chuanHoaCauHoi(text) {
  return boDau(text)
    .replace(/[?!.,;:()"']/g, ' ')
    .split(/\s+/)
    .map((w) => VIET_TAT[w] || w)
    .join(' ')
    .replace(/\s+/g, ' ')
    .trim();
}

// STOPWORDS ở trên liệt kê cả bản có dấu lẫn không dấu cho dễ đọc; quy về một bản không dấu vì
// tokenize luôn chạy trên chuỗi đã chuẩn hoá.
const STOPWORDS_KD = new Set([...STOPWORDS].map(boDau));

function tokenize(text) {
  return chuanHoaCauHoi(text)
    .split(/\s+/)
    .filter((w) => w.length >= 2 && !STOPWORDS_KD.has(w));
}
function findProductCandidates(query, limit = 5) {
  const toks = tokenize(query);
  if (!toks.length) return [];
  const scored = products
    .map((p) => {
      // So khớp trên tên đã bỏ dấu để "man hinh gaming" cũng trúng "Màn hình Gaming ...".
      const nameLower = boDau(p.name);
      let score = 0;
      for (const t of toks) if (nameLower.includes(t)) score++;
      return { p, score };
    })
    .filter((x) => x.score > 0)
    .sort((a, b) => b.score - a.score || a.p.price - b.p.price);
  return scored.slice(0, limit).map((x) => x.p);
}
/** Tách 1 câu chứa 2 tên linh kiện/sản phẩm cần so sánh, phân cách bởi và/vs/với/dấu phẩy. */
function splitTwoNames(text) {
  return text.split(/\s+(?:và|va|vs\.?|với|voi|so với|so voi)\s+|,/i).map((s) => s.trim()).filter(Boolean);
}
/** Quy sản phẩm (dù lấy từ catalog local hay kết quả API) về đúng shape state.compareItems cần
 * — dùng chung cho mọi lối vào bảng so sánh từ chat, tránh lặp lại object literal 3 chỗ. */
function toCompareItem(p) {
  return {
    key: 'product-' + p.id, kind: 'product', id: p.id, slug: p.slug,
    name: p.name, price: p.price, image: p.imageUrl || p.image,
  };
}

// ===== 3) SO SÁNH CẤU HÌNH — tích hợp thẳng CompareDrawer thay vì tự vẽ bảng riêng =====
function addToCompareFromChat(p) {
  const ok = actions.addCompare(toCompareItem(p));
  pushBot({
    type: 'text',
    text: ok
      ? `Đã thêm "${p.name}" vào bảng so sánh (${state.compareItems.length}/5).`
      : 'Bảng so sánh đã đủ 5 cấu hình — bỏ bớt 1 cái trong bảng để thêm cái khác nhé.',
  });
  pushBot(quickReplies([
    { label: '⇄ Mở bảng so sánh', run: () => { actions.openCompare(); } },
    { label: 'Tiếp tục hỏi', run: () => { step.value = 'menu'; pushBot(quickReplies(mainMenuOptions())); } },
  ]));
}

function startCompare() {
  step.value = 'awaiting_compare_names';
  pushBot({ type: 'text', text: 'Bạn muốn so sánh sản phẩm/cấu hình nào? Gõ 2 tên cách nhau bằng "và" hoặc "vs" — ví dụ: "RTX 4060 và RTX 4070".' });
}
function handleCompareInput(text) {
  const parts = splitTwoNames(text);
  const candA = findProductCandidates(parts[0] || text, 1)[0];
  const candB = parts[1] ? findProductCandidates(parts[1], 1)[0] : null;

  if (!candA || !candB) {
    const goiY = findProductCandidates(text, 4);
    if (goiY.length) {
      pushBot({ type: 'text', text: 'Mình chưa tách được đủ 2 sản phẩm từ câu đó. Có phải bạn muốn nói tới 1 trong các sản phẩm sau? Bấm để thêm vào so sánh, rồi tìm thêm sản phẩm thứ hai.' });
      pushBot(cardsMsg('product', goiY.map((p) => productCard(p, { compare: true }))));
    } else {
      pushBot({ type: 'text', text: 'Mình không tìm thấy sản phẩm nào khớp cả. Bạn gõ lại tên chính xác hơn giúp mình nhé (VD: "RTX 4060 và RTX 4070").' });
    }
    // Vẫn ở lại bước này để khách gõ tiếp tên thứ 2 — nhưng luôn để lối thoát, tránh kẹt khách
    // trong bước "chờ 2 tên" nếu họ thật ra muốn hỏi chuyện khác.
    pushBot(quickReplies([BACK_OPTION]));
    return;
  }

  [candA, candB].forEach((p) => actions.addCompare(toCompareItem(p)));
  pushBot({ type: 'text', text: `Đã thêm "${candA.name}" và "${candB.name}" vào bảng so sánh, mở bảng chi tiết cho bạn nhé.` });
  step.value = 'menu';
  actions.openCompare();
}

// ===== 4) SO SÁNH TÀI CHÍNH — cùng công thức chấm điểm với CompareDrawer (compareRank.js),
// thêm lớp "điểm / triệu đồng" để trả lời đúng câu hỏi tiền nào đáng hơn. =====
function startFinance() {
  step.value = 'awaiting_finance_names';
  pushBot({ type: 'text', text: 'Bạn muốn so sánh TÀI CHÍNH giữa 2 sản phẩm nào — cái nào đáng đồng tiền hơn? Gõ 2 tên cách nhau bằng "và", ví dụ: "RTX 4060 và RTX 4060 Ti".' });
}
function handleFinanceInput(text) {
  const parts = splitTwoNames(text);
  const candA = findProductCandidates(parts[0] || text, 1)[0];
  const candB = parts[1] ? findProductCandidates(parts[1], 1)[0] : null;

  if (!candA || !candB) {
    pushBot({ type: 'text', text: 'Mình chưa tách được đủ 2 sản phẩm. Gõ lại theo dạng "Tên A và Tên B" giúp mình nhé.' });
    pushBot(quickReplies([BACK_OPTION]));
    return;
  }
  if (candA.id === candB.id) {
    pushBot({ type: 'text', text: 'Hai tên bạn gõ trỏ về cùng 1 sản phẩm — thử sản phẩm khác xem sao.' });
    pushBot(quickReplies([BACK_OPTION]));
    return;
  }

  const specsOf = (p) => (p.specs || []).map((s) => ({ label: s.k, value: s.v }));
  const dA = diemSanPham(specsOf(candA), candA.name, candA.cat);
  const dB = diemSanPham(specsOf(candB), candB.name, candB.cat);

  if (dA == null || dB == null) {
    pushBot({ type: 'text', text: 'Mình chưa đủ dữ liệu kỹ thuật để chấm điểm hiệu năng cho 1 trong 2 sản phẩm này, nên chỉ so được giá:' });
    pushBot(cardsMsg('product', [productCard(candA), productCard(candB)]));
    pushBot(quickReplies([{ label: '⇄ Mở bảng so sánh chi tiết', run: () => openCompareWith([candA, candB]) }, BACK_OPTION]));
    step.value = 'menu';
    return;
  }

  const perTrieuA = dA / (candA.price / 1_000_000);
  const perTrieuB = dB / (candB.price / 1_000_000);
  const nhan = phanLoaiHuong([
    { key: 'a', tongDiem: dA, totalPrice: candA.price },
    { key: 'b', tongDiem: dB, totalPrice: candB.price },
  ]);
  const manh = dA >= dB ? candA : candB;
  const manhKey = dA >= dB ? 'a' : 'b';
  const dangTienKey = perTrieuA >= perTrieuB ? 'a' : 'b';
  const dangTien = dangTienKey === 'a' ? candA : candB;
  const yeu = dangTienKey === 'a' ? candB : candA;
  const perTrieuManh = Math.max(perTrieuA, perTrieuB);
  const perTrieuYeu = Math.min(perTrieuA, perTrieuB);
  const chenhLech = perTrieuYeu > 0 ? Math.round(((perTrieuManh - perTrieuYeu) / perTrieuYeu) * 100) : null;

  let ketLuan;
  if (dangTienKey === manhKey) {
    ketLuan = `${manh.name} vừa mạnh hơn về hiệu năng, vừa đáng đồng tiền hơn — gần như không có lý do chọn cái còn lại trừ khi ngân sách không đủ.`;
  } else {
    ketLuan = `${manh.name} mạnh hơn về hiệu năng, nhưng ${dangTien.name} đáng đồng tiền hơn`
      + (chenhLech ? ` (nhiều điểm/triệu hơn khoảng ${chenhLech}%)` : '')
      + ` — chọn ${dangTien.name} nếu ưu tiên tiết kiệm, chọn ${manh.name} nếu ưu tiên sức mạnh tối đa.`;
  }

  pushBot({
    type: 'finance',
    a: {
      name: candA.name, priceText: fmt(candA.price), diem: Math.round(dA),
      tag: nhan.a?.text || null, tagColor: nhan.a?.mau || null,
    },
    b: {
      name: candB.name, priceText: fmt(candB.price), diem: Math.round(dB),
      tag: nhan.b?.text || null, tagColor: nhan.b?.mau || null,
    },
    text: ketLuan,
  });
  pushBot(quickReplies([{ label: '⇄ Mở bảng so sánh chi tiết', run: () => openCompareWith([candA, candB]) }, BACK_OPTION]));
  step.value = 'menu';
}
function openCompareWith(prods) {
  prods.forEach((p) => actions.addCompare(toCompareItem(p)));
  actions.openCompare();
}

// ===== 5) FAQ THẬT TỪ BACKEND (32 câu, 10 danh mục — thay cho 6 câu hard-code trước đây) =====
const faqCategories = ref([]);
let faqLoaded = false;
async function ensureFaqLoaded() {
  if (faqLoaded) return;
  try { faqCategories.value = await fetchFaq(); faqLoaded = true; } catch (e) { faqCategories.value = []; }
}
const faqFlat = computed(() =>
  faqCategories.value.flatMap((c) => (c.items || []).map((i) => ({ ...i, tenDanhMuc: c.ten, maDanhMuc: c.ma }))),
);
/** Điều hướng theo danh mục FAQ có trang chính sách riêng — không phải danh mục nào cũng có. */
const FAQ_NAV = {
  thanh_toan: { label: '📄 Xem chính sách trả góp', run: () => { actions.closeChat(); actions.goInstallmentPolicy(); } },
  doi_tra: { label: '↩️ Xem chính sách đổi trả', run: () => { actions.closeChat(); actions.goReturnPolicy(); } },
  bao_hanh: { label: '🛡️ Tra cứu & chính sách bảo hành', run: () => { actions.closeChat(); actions.goWarrantyInfo(); } },
  ho_tro: { label: '📞 Mở trang liên hệ', run: () => { actions.closeChat(); actions.goContact(); } },
};

async function startFaqMenu() {
  await ensureFaqLoaded();
  step.value = 'faq';
  pushBot({ type: 'text', text: 'Bạn muốn hỏi về mục nào?' });
  pushBot(quickReplies([
    ...faqCategories.value.map((c) => ({ label: `${c.icon || '📌'} ${c.ten}`, run: () => showFaqCategory(c) })),
    BACK_OPTION,
  ]));
}
function showFaqCategory(cat) {
  pushUser(cat.ten);
  pushBot(quickReplies([
    ...(cat.items || []).map((it) => ({ label: it.cauHoi, run: () => answerFaqItem(it) })),
    { label: '⬅ Chọn mục khác', run: startFaqMenu },
  ]));
}
function answerFaqItem(item) {
  pushUser(item.cauHoi);
  const nav = FAQ_NAV[item.maDanhMuc];
  answerFaqText(item.traLoi, nav ? [nav] : []);
}
function answerFaqText(text, extraOptions) {
  pushBot({ type: 'text', text });
  pushBot(quickReplies([...(extraOptions || []), BACK_OPTION]));
  step.value = 'menu';
}
/** Khớp câu hỏi tự do với FAQ thật — chấm theo số từ khoá (tuKhoa, phân cách dấu phẩy) hoặc từ
 * trong câu hỏi gốc xuất hiện trong câu khách gõ. */
function matchFaqRealtime(text) {
  // Cả câu khách gõ lẫn từ khoá admin gắn đều quy về dạng không dấu + đã giãn viết tắt, nên
  // "bh dt bao lau" khớp được câu "Bảo hành điện thoại bao lâu?" dù không trùng ký tự nào.
  const t = chuanHoaCauHoi(text);
  const queryToks = new Set(tokenize(text));
  let best = null;
  let bestScore = 0;
  for (const item of faqFlat.value) {
    // Khớp theo TỪ KHOÁ admin đã gắn sẵn (tuKhoa) — đáng tin cậy nhất vì đó là cụm từ đặc
    // trưng được chọn lọc riêng cho câu hỏi này, không phải suy luận. Nhân 100 để luôn thắng
    // điểm suy luận ở nhánh dưới dù chỉ khớp 1 cụm.
    const tuKhoaList = (item.tuKhoa || '').split(',').map((k) => chuanHoaCauHoi(k)).filter(Boolean);
    const tuKhoaScore = tuKhoaList.filter((k) => k.length >= 3 && t.includes(k)).length;
    if (tuKhoaScore > 0) {
      if (tuKhoaScore * 100 > bestScore) { bestScore = tuKhoaScore * 100; best = item; }
      continue;
    }
    // Không câu nào có từ khoá khớp -> thử suy luận từ chính câu hỏi gốc trong FAQ, nhưng đòi
    // hỏi khắt khe (>=3 từ nội dung trùng VÀ chiếm ít nhất nửa số từ khách gõ) — ngưỡng lỏng
    // hơn từng khiến các câu hỏi hoàn toàn khác chủ đề khớp nhầm chỉ vì chia sẻ vài từ đệm
    // chung chung như "được"/"không"/"thì" (đã tự kiểm chứng bằng dữ liệu FAQ thật, xem lịch
    // sử sửa đổi), nên STOPWORDS ở trên đã liệt kê rộng để loại chúng khỏi phép so khớp.
    const cauHoiToks = tokenize(item.cauHoi);
    const trung = cauHoiToks.filter((w) => queryToks.has(w)).length;
    if (trung >= 3 && trung / queryToks.size >= 0.5 && trung > bestScore) {
      bestScore = trung;
      best = item;
    }
  }
  return bestScore > 0 ? best : null;
}

// ===== 6) KHUYẾN MÃI (flash sale + sản phẩm đang giảm giá) =====
function fmtDateTimeVN(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  const p = (n) => String(n).padStart(2, '0');
  return `${p(d.getHours())}:${p(d.getMinutes())} ${p(d.getDate())}/${p(d.getMonth() + 1)}`;
}
async function showPromotions() {
  const loading = pushBot({ type: 'text', text: 'Đang kiểm tra chương trình khuyến mãi...' });
  let sale = null;
  try { sale = await fetchFlashSale(); } catch (e) { /* không có đợt nào đang chạy hoặc lỗi mạng */ }

  updateMsg(loading, {
    text: sale
      ? `⚡ ${sale.tieuDe || 'Flash Sale'} đang diễn ra${sale.ketThucLuc ? ', kết thúc lúc ' + fmtDateTimeVN(sale.ketThucLuc) : ''}.`
      : 'Hiện không có đợt Flash Sale nào đang chạy.',
  });
  if (sale?.sanPham?.length) {
    pushBot(cardsMsg('product', sale.sanPham.slice(0, 6).map((it) => ({
      key: 'fs' + it.productId,
      image: it.imageUrl ? resolveImageUrl(it.imageUrl) : null,
      title: it.productName,
      priceText: fmt(it.giaSale),
      oldPriceText: fmt(it.giaGoc),
      badge: it.phanTramGiam ? `-${it.phanTramGiam}%` : null,
      onClick: () => { actions.closeChat(); actions.goDetail(it.productId); },
    }))));
  }

  const giamGia = products.filter((p) => p.oldPrice > p.price).sort((a, b) => (b.oldPrice - b.price) - (a.oldPrice - a.price)).slice(0, 6);
  if (giamGia.length) {
    pushBot({ type: 'text', text: `Ngoài ra, ${giamGia.length} sản phẩm sau đang giảm giá sâu nhất:` });
    pushBot(cardsMsg('product', giamGia.map((p) => productCard(p))));
  }
  pushBot(quickReplies([{ label: '🎁 Xem trang Khuyến mãi', run: () => { actions.closeChat(); actions.goPromotions(); } }, BACK_OPTION]));
  step.value = 'menu';
}

// ===== 7) TIN TỨC & BÀI VIẾT =====
let articlesCache = null;
async function loadArticlesOnce() {
  if (articlesCache) return articlesCache;
  try { articlesCache = await fetchArticles(); } catch (e) { articlesCache = []; }
  return articlesCache;
}
function articleCard(a) {
  return {
    key: 'a' + a.id,
    image: a.thumbnail ? resolveImageUrl(a.thumbnail) : null,
    title: a.tieuDe,
    subtitle: a.tomTat,
    meta: `${a.tenDanhMuc} · ${a.luotXem ?? 0} lượt xem`,
    onClick: () => { actions.closeChat(); actions.goArticle(a.slug); },
  };
}
function startNews() {
  step.value = 'awaiting_news_keyword';
  pushBot({ type: 'text', text: 'Bạn muốn tìm bài viết về chủ đề gì? Gõ từ khoá (VD: "RTX 4060", "trả góp"), hoặc bấm nút bên dưới để xem tin mới nhất.' });
  pushBot(quickReplies([{ label: '🗞️ Xem tin mới nhất', run: () => searchNews('') }]));
}
async function searchNews(keyword) {
  const all = await loadArticlesOnce();
  const q = keyword.trim().toLowerCase();
  let list = q ? all.filter((a) => a.tieuDe.toLowerCase().includes(q) || (a.tomTat || '').toLowerCase().includes(q)) : all;
  list = [...list].sort((x, y) => new Date(y.publishedAt || 0) - new Date(x.publishedAt || 0)).slice(0, 6);

  if (!list.length) {
    pushBot({ type: 'text', text: `Không tìm thấy bài viết nào khớp với "${keyword}". Bạn xem toàn bộ tin tức tại trang Tin tức nhé.` });
  } else {
    pushBot({ type: 'text', text: q ? `Tìm thấy ${list.length} bài viết về "${keyword}":` : 'Các bài viết mới nhất:' });
    pushBot(cardsMsg('article', list.map(articleCard)));
  }
  pushBot(quickReplies([{ label: '📰 Xem tất cả tin tức', run: () => { actions.closeChat(); actions.goNews(); } }, BACK_OPTION]));
  step.value = 'menu';
}

// ===== 8) TRUNG TÂM BẢO HÀNH =====
async function showCenters() {
  const loading = pushBot({ type: 'text', text: 'Đang tải danh sách trung tâm bảo hành...' });
  let centers = [];
  try { centers = await fetchServiceCenters(); } catch (e) { /* rỗng nếu lỗi mạng */ }

  if (!centers.length) {
    updateMsg(loading, { text: 'Mình chưa tải được danh sách trung tâm — bạn xem tại trang Trung tâm bảo hành nhé.' });
  } else {
    updateMsg(loading, { text: `CNTTshop có ${centers.length} trung tâm bảo hành / sửa chữa:` });
    pushBot(cardsMsg('center', centers.slice(0, 5).map((c) => ({
      key: 'c' + c.id,
      title: c.ten,
      subtitle: c.diaChi,
      meta: `${c.gioMoCua || ''}${c.gioMoCua && c.dienThoai ? ' · ' : ''}${c.dienThoai || ''}`,
      onClick: () => { actions.closeChat(); actions.goServiceCenters(); },
    }))));
  }
  pushBot(quickReplies([{ label: '🏬 Xem tất cả trung tâm', run: () => { actions.closeChat(); actions.goServiceCenters(); } }, BACK_OPTION]));
  step.value = 'menu';
}

// ===== 9) BẢNG GIÁ SỬA CHỮA =====
function startRepairPrice() {
  pushBot({ type: 'text', text: 'Bạn cần báo giá sửa chữa cho loại thiết bị nào?' });
  pushBot(quickReplies(LOAI_THIET_BI.map((l) => ({ label: `${l.icon} ${l.ten}`, run: () => showRepairPrices(l.ma, l.ten) }))));
}
async function showRepairPrices(ma, ten) {
  pushUser(ten);
  const loading = pushBot({ type: 'text', text: 'Đang tải bảng giá...' });
  let list = [];
  try { list = await fetchRepairPrices(ma); } catch (e) { /* rỗng nếu lỗi mạng */ }

  if (!list.length) {
    updateMsg(loading, { text: `Chưa có bảng giá cho nhóm ${ten}. Bạn xem toàn bộ bảng giá sửa chữa tại trang riêng nhé.` });
  } else {
    updateMsg(loading, { text: `Bảng giá sửa chữa nhóm ${ten} — ${list.length} hạng mục, vài mục tiêu biểu:` });
    pushBot(cardsMsg('repair', list.slice(0, 6).map((r) => ({
      key: 'r' + r.id,
      title: r.tenLoi,
      subtitle: r.giaTu != null ? `${fmt(r.giaTu)} – ${fmt(r.giaDen)}` : null,
      meta: `Thời gian dự kiến: ${r.thoiGianDuKien || '—'} · Bảo hành ${r.baoHanhThang || 0} tháng`,
    }))));
  }
  pushBot(quickReplies([{ label: '🔧 Xem toàn bộ bảng giá sửa chữa', run: () => { actions.closeChat(); actions.goRepairPrice(); } }, BACK_OPTION]));
  step.value = 'menu';
}

// ===== 10) GÓI HỘI VIÊN CNTT CARE =====
function planBenefits(p) {
  const b = [];
  if (p.freeInnerShipping) b.push('Free ship nội thành');
  if (p.freeExpressInner) b.push('Free ship hoả tốc');
  if (p.interprovinceQuota) b.push(`${p.interprovinceQuota} lượt free ship liên tỉnh`);
  if (p.cleaningQuota) b.push(`${p.cleaningQuota} lượt vệ sinh máy`);
  if (p.thermalPaste) b.push('Tặng keo tản nhiệt');
  if (p.warrantyPriority) b.push('Ưu tiên xử lý bảo hành');
  if (p.onsiteWarrantyQuota) b.push(`${p.onsiteWarrantyQuota} lượt bảo hành tận nơi`);
  if (p.pcBuildConsult) b.push('Tư vấn build PC riêng');
  return b.join(' · ') || null;
}
async function showMembership() {
  const loading = pushBot({ type: 'text', text: 'Đang tải danh sách gói hội viên...' });
  let plans = [];
  try { plans = await fetchSubscriptionPlans(); } catch (e) { /* rỗng nếu lỗi mạng */ }

  if (!plans.length) {
    updateMsg(loading, { text: 'Mình chưa tải được danh sách gói — bạn xem tại trang Tài khoản > Gói hội viên nhé.' });
  } else {
    updateMsg(loading, { text: 'CNTTshop có các gói hội viên trả phí CNTT Care sau:' });
    pushBot(cardsMsg('plan', plans.map((p) => ({
      key: p.code,
      title: p.name,
      priceText: `${fmt(p.price)} / ${p.durationMonths} tháng`,
      subtitle: planBenefits(p),
    }))));
  }
  pushBot(quickReplies([{ label: '⭐ Xem & đăng ký gói hội viên', run: () => { actions.closeChat(); actions.goAccount('membership'); } }, BACK_OPTION]));
  step.value = 'menu';
}

// ===== 11) TRẢ GÓP — số liệu THẬT (kỳ hạn/lãi suất/trả trước tối thiểu) thay vì mô tả chung
// chung. FAQ tĩnh trước đây chỉ có 1 câu "áp dụng cho sản phẩm nào", không trả lời được câu cụ
// thể như "trả trước bao nhiêu %" — trong khi dữ liệu đó vốn đã công khai qua API. =====
let installmentCache = null;
async function showInstallmentInfo() {
  const loading = pushBot({ type: 'text', text: 'Đang tải cấu hình trả góp...' });
  if (!installmentCache) {
    try { installmentCache = await fetchInstallmentConfig(); } catch (e) { installmentCache = null; }
  }
  if (!installmentCache) {
    updateMsg(loading, { text: 'Mình chưa tải được cấu hình trả góp — bạn xem chi tiết tại trang Chính sách trả góp nhé.' });
  } else {
    const ky = (installmentCache.kyHan || []).map((k) => `${k.soThang} tháng${k.laiSuat > 0 ? ` (lãi ${k.laiSuat}%)` : ' (0% lãi suất)'}`).join(', ');
    const traTruoc = installmentCache.tyLeTraTruocToiThieu != null ? Math.round(installmentCache.tyLeTraTruocToiThieu * 100) : null;
    updateMsg(loading, {
      text: `CNTTshop hỗ trợ trả góp các kỳ hạn: ${ky || 'đang cập nhật'}.`
        + (traTruoc != null ? ` Trả trước tối thiểu ${traTruoc}% giá trị đơn hàng.` : ''),
    });
  }
  pushBot(quickReplies([{ label: '📄 Xem chính sách trả góp đầy đủ', run: () => { actions.closeChat(); actions.goInstallmentPolicy(); } }, BACK_OPTION]));
  step.value = 'menu';
}

// ===== Rail chủ đề (luôn hiển thị bên trái) =====
const RAIL_SECTIONS = [
  {
    title: 'Mua sắm',
    items: [
      { icon: '🔎', label: 'Tra cứu giá sản phẩm', run: () => { pushUser('Tra cứu giá sản phẩm'); startPriceSearch(); } },
      { icon: '🛒', label: 'Tư vấn theo nhu cầu', run: () => { pushUser('Tư vấn theo nhu cầu'); startAdvise(); } },
      { icon: '⇄', label: 'So sánh cấu hình', run: () => { pushUser('So sánh cấu hình'); startCompare(); } },
      { icon: '💰', label: 'So sánh tài chính', run: () => { pushUser('So sánh tài chính'); startFinance(); } },
      { icon: '🏷️', label: 'Khuyến mãi hôm nay', run: () => { pushUser('Khuyến mãi hôm nay'); showPromotions(); } },
    ],
  },
  {
    title: 'Chính sách',
    items: [
      { icon: '📦', label: 'Câu hỏi thường gặp', run: () => { pushUser('Câu hỏi thường gặp'); startFaqMenu(); } },
      { icon: '🛡️', label: 'Bảo hành & dịch vụ', run: () => showFaqCategoryByCode('bao_hanh', 'Bảo hành & Dịch vụ') },
      { icon: '↩️', label: 'Đổi trả & huỷ đơn', run: () => showFaqCategoryByCode('doi_tra', 'Đổi trả & Huỷ đơn') },
      { icon: '💳', label: 'Thanh toán & trả góp', run: () => showFaqCategoryByCode('thanh_toan', 'Thanh toán & Trả góp') },
      { icon: '🗓️', label: 'Kỳ hạn & lãi suất trả góp', run: () => { pushUser('Kỳ hạn & lãi suất trả góp'); showInstallmentInfo(); } },
    ],
  },
  {
    title: 'Hỗ trợ',
    items: [
      { icon: '🏬', label: 'Trung tâm bảo hành', run: () => { pushUser('Trung tâm bảo hành'); showCenters(); } },
      { icon: '🔧', label: 'Bảng giá sửa chữa', run: () => { pushUser('Bảng giá sửa chữa'); startRepairPrice(); } },
      { icon: '⭐', label: 'Gói hội viên CNTT Care', run: () => { pushUser('Gói hội viên CNTT Care'); showMembership(); } },
      { icon: '📰', label: 'Tin tức & bài viết', run: () => { pushUser('Tin tức & bài viết'); startNews(); } },
      { icon: '📞', label: 'Gặp nhân viên tư vấn', run: () => { pushUser('Gặp nhân viên tư vấn'); contactHuman(); } },
    ],
  },
];
/** hienCauHoi=false khi gọi từ bộ định tuyến câu tự do — câu của khách đã được đẩy lên khung
 * chat rồi, đẩy thêm nhãn danh mục nữa sẽ thành 2 bong bóng "của khách" liên tiếp. */
async function showFaqCategoryByCode(ma, tenMacDinh, hienCauHoi = true) {
  if (hienCauHoi) pushUser(tenMacDinh);
  await ensureFaqLoaded();
  const cat = faqCategories.value.find((c) => c.ma === ma) || { ten: tenMacDinh, items: [] };
  if (!cat.items?.length) {
    answerFaqText('Mình chưa có câu hỏi nào cho mục này, bạn gọi hotline 0835 344 974 giúp mình nhé.', []);
    return;
  }
  pushBot({ type: 'text', text: `Bạn muốn hỏi cụ thể điều gì trong mục "${cat.ten}"?` });
  pushBot(quickReplies([
    ...cat.items.map((it) => ({ label: it.cauHoi, run: () => answerFaqItem(it) })),
    BACK_OPTION,
  ]));
}

// ===== Bộ định tuyến câu hỏi tự do =====
// MỌI biểu thức dưới đây so khớp trên chuỗi ĐÃ CHUẨN HOÁ (bỏ dấu + giãn viết tắt, xem
// chuanHoaCauHoi) chứ không phải câu gốc — nên chỉ cần viết một biến thể không dấu, và những
// câu kiểu "cho e hoi km hnay" / "bh sp nay bao lau" cũng vào đúng nhánh.
const PRICE_QUESTION_RE = /\bgia\b|bao nhieu|nhieu tien|gia tien|gia ban|dat khong|re khong/;
const SO_SANH_RE = /so sanh|so voi|doi dau|\bvs\b|cai nao (tot|manh|ngon) hon|nen chon cai nao|khac nhau (gi|the nao)/;
const TAI_CHINH_RE = /dang tien|dang dong tien|tai chinh|gia tri|dang mua hon|hoi hon|nen mua cai nao|loi hon|hieu nang tren gia/;
const KHUYEN_MAI_RE = /khuyen mai|flash sale|giam gia|uu dai|\bsale\b|\bdeal\b|ma giam|voucher/;
const TIN_TUC_RE = /tin tuc|bai viet|doc them|review\b|danh gia chi tiet/;
const TRUNG_TAM_RE = /trung tam bao hanh|cua hang o dau|dia chi cua hang|showroom|chi nhanh|shop o dau/;
const SUA_CHUA_RE = /gia sua|sua chua|thay pin|thay man hinh|ve sinh may|bao gia sua/;
const HOI_VIEN_RE = /hoi vien|cntt care|goi.*care|thanh vien tra phi/;
const TRA_GOP_RE = /tra gop|installment|tra cham|ky han.*(lai|gop)/;
// Ba chủ đề dưới trước đây không có nhánh nào: câu hỏi rất hay gặp mà nếu FAQ không khớp thì
// bot chỉ trả lời "chưa chắc hiểu ý bạn".
const BAO_HANH_RE = /bao hanh|het han bao hanh|con bao hanh|chinh sach bao hanh/;
const DOI_TRA_RE = /doi tra|tra hang|hoan tien|doi san pham|1 doi 1|huy don/;
const VAN_CHUYEN_RE = /giao hang|van chuyen|phi ship|\bship\b|bao lau (thi )?nhan|freeship|mien phi giao/;

const STRIP_PATTERNS = [
  /gia\s+cua/g, /gia\s+ban/g, /gia\s+tien/g, /bao nhieu tien/g, /la bao nhieu/g,
  /bao nhieu/g, /\bgia\b/g, /nhieu tien/g, /^tien\b/g, /cho minh hoi/g, /cho minh xin hoi/g,
  /minh muon hoi/g, /minh muon biet/g, /cho toi hoi/g, /toi muon hoi/g, /xin hoi/g,
  /minh hoi/g, /shop oi/g, /\bcua\b/g, /\bla\b/g, /\bvay a\b/g, /\bvay\b/g, /\bnhe\b/g,
  /\ba\b/g, /\bcho\b/g, /\bxem\b/g, /\bcon\b/g, /\bem\b/g, /\banh\b/g, /\bchi\b/g, /\?/g,
];
/** Bóc phần tên sản phẩm ra khỏi câu hỏi giá. Nhận vào chuỗi ĐÃ chuẩn hoá. */
function extractProductKeyword(text) {
  let t = text;
  STRIP_PATTERNS.forEach((p) => { t = t.replace(p, ' '); });
  return t.replace(/\s+/g, ' ').trim();
}

function sendFreeText() {
  const text = inputText.value.trim();
  if (!text) return;
  pushUser(text);
  inputText.value = '';

  // Đang trong 1 luồng cụ thể -> ưu tiên xử lý theo đúng luồng đó trước.
  if (step.value === 'awaiting_product_search') return searchProductPrice(text);
  if (step.value === 'awaiting_compare_names') return handleCompareInput(text);
  if (step.value === 'awaiting_finance_names') return handleFinanceInput(text);
  if (step.value === 'awaiting_news_keyword') return searchNews(text);

  // Chuẩn hoá 1 lần rồi mọi phép nhận dạng bên dưới đều chạy trên bản này (bỏ dấu + đã giãn
  // viết tắt) — câu gốc chỉ dùng để hiển thị lại cho khách.
  const cau = chuanHoaCauHoi(text);

  // Đoán ý định từ câu tự do, theo thứ tự ưu tiên. So sánh/tài chính vẫn nhận câu GỐC vì hai
  // luồng đó phải tách tên sản phẩm đúng như khách gõ để tra cứu.
  if (SO_SANH_RE.test(cau)) { step.value = 'awaiting_compare_names'; return handleCompareInput(text); }
  if (TAI_CHINH_RE.test(cau)) { step.value = 'awaiting_finance_names'; return handleFinanceInput(text); }
  if (KHUYEN_MAI_RE.test(cau)) return showPromotions();
  if (TIN_TUC_RE.test(cau)) return searchNews(extractProductKeyword(cau).replace(TIN_TUC_RE, '').trim());
  if (TRUNG_TAM_RE.test(cau)) return showCenters();
  if (SUA_CHUA_RE.test(cau)) return startRepairPrice();
  if (HOI_VIEN_RE.test(cau)) return showMembership();
  if (TRA_GOP_RE.test(cau)) return showInstallmentInfo();
  if (PRICE_QUESTION_RE.test(cau)) {
    const keyword = extractProductKeyword(cau);
    if (keyword.length >= 2) return searchProductPrice(keyword);
  }

  // FAQ đứng TRƯỚC ba nhánh chủ đề bên dưới: nếu admin đã soạn sẵn câu trả lời đúng ý thì trả
  // lời thẳng, chỉ khi không có mới lùi về mục FAQ chung của chủ đề.
  const faqItem = matchFaqRealtime(text);
  if (faqItem) return answerFaqItem(faqItem);

  // Ba chủ đề hỏi nhiều nhất mà trước đây rơi thẳng vào câu "chưa chắc hiểu ý bạn" khi FAQ
  // không khớp — ít nhất phải mở đúng mục hỏi đáp tương ứng cho khách.
  if (BAO_HANH_RE.test(cau)) return showFaqCategoryByCode('bao_hanh', 'Bảo hành & Dịch vụ', false);
  if (DOI_TRA_RE.test(cau)) return showFaqCategoryByCode('doi_tra', 'Đổi trả & Huỷ đơn', false);
  if (VAN_CHUYEN_RE.test(cau)) return showFaqCategoryByCode('giao_hang', 'Giao hàng & Lắp đặt', false);

  const cand = findProductCandidates(text, 5);
  if (cand.length) {
    pushBot({ type: 'text', text: `Mình tìm thấy ${cand.length} sản phẩm có thể liên quan tới "${text}":` });
    pushBot(cardsMsg('product', cand.map((p) => productCard(p))));
    pushBot(quickReplies(mainMenuOptions()));
    step.value = 'menu';
    return;
  }

  // Bí thật sự -> nói rõ mình hiểu được những gì, kèm lối gặp người thật, thay vì chỉ đẩy
  // khách quay về menu.
  pushBot({
    type: 'text',
    text: 'Mình chưa chắc hiểu ý bạn 🤔 Bạn thử hỏi cụ thể hơn nhé, ví dụ: "giá RTX 4060", "bh sp nay bao lau", "phi ship ve Hai Phong" — hoặc chọn 1 chủ đề bên trái.',
  });
  pushBot(quickReplies([
    { label: '📞 Gặp nhân viên tư vấn', run: contactHuman },
    ...mainMenuOptions(),
  ]));
  step.value = 'menu';
}
</script>

<template>
  <div v-if="state.chatOpen" class="bot-mask" :style="bienMau" @click.self="actions.closeChat()">
    <aside class="bot-drawer">
      <header class="bot-head">
        <div>
          <div class="bot-title">Trợ lý CNTTshop</div>
          <div class="bot-sub">Tra giá, so sánh, khuyến mãi, chính sách... hỏi gì cũng có</div>
        </div>
        <div class="bot-head-tools">
          <button class="bot-btn" @click="greet">Cuộc trò chuyện mới</button>
          <button class="bot-btn bot-btn-x" @click="actions.closeChat()">✕</button>
        </div>
      </header>

      <div class="bot-body">
        <!-- Rail chủ đề — luôn hiển thị, khác quick-reply chỉ hiện tạm trong hội thoại -->
        <nav class="bot-rail">
          <section v-for="sec in RAIL_SECTIONS" :key="sec.title" class="bot-rail-sec">
            <div class="bot-rail-title">{{ sec.title }}</div>
            <button v-for="it in sec.items" :key="it.label" class="bot-rail-item" @click="it.run()">
              <span class="bot-rail-icon">{{ it.icon }}</span>{{ it.label }}
            </button>
          </section>
        </nav>

        <!-- Hội thoại -->
        <div class="bot-chat">
          <div class="bot-msgs" ref="scrollBox">
            <template v-for="m in messages" :key="m.id">
              <div v-if="m.type === 'text'" :class="['bot-msg', m.from]">{{ m.text }}</div>

              <div v-else-if="m.type === 'quick-replies'" class="bot-replies">
                <button v-for="(opt, i) in m.options" :key="i" class="bot-reply-btn" @click="opt.run()">{{ opt.label }}</button>
              </div>

              <div v-else-if="m.type === 'cards'" class="bot-cards" :class="'v-' + m.variant">
                <button v-for="it in m.items" :key="it.key" class="bot-card" @click="it.onClick && it.onClick()">
                  <div v-if="(m.variant === 'product' || m.variant === 'article') && it.image" class="bot-card-img" :style="{ backgroundImage: `url(${it.image})` }"></div>
                  <button v-if="it.onCompareClick" class="bot-card-cmp" title="Thêm vào so sánh" @click.stop="it.onCompareClick()">⇄</button>
                  <div class="bot-card-body">
                    <span v-if="it.badge" class="bot-card-badge">{{ it.badge }}</span>
                    <div class="bot-card-title">{{ it.title }}</div>
                    <div v-if="it.subtitle" class="bot-card-sub">{{ it.subtitle }}</div>
                    <div v-if="it.priceText" class="bot-card-price">
                      {{ it.priceText }}
                      <span v-if="it.oldPriceText" class="bot-card-old">{{ it.oldPriceText }}</span>
                    </div>
                    <div v-if="it.meta" class="bot-card-meta">{{ it.meta }}</div>
                  </div>
                </button>
              </div>

              <!-- Kết quả so sánh tài chính: 2 cột điểm/giá cạnh nhau -->
              <div v-else-if="m.type === 'finance'" class="bot-finance">
                <div class="bot-finance-cols">
                  <div v-for="side in [m.a, m.b]" :key="side.name" class="bot-finance-col">
                    <div class="bot-finance-name">{{ side.name }}</div>
                    <div class="bot-finance-price" :style="{ color: accent }">{{ side.priceText }}</div>
                    <div class="bot-finance-score">{{ side.diem }} điểm</div>
                    <span v-if="side.tag" class="bot-finance-tag" :style="{ color: side.tagColor, borderColor: side.tagColor }">{{ side.tag }}</span>
                  </div>
                </div>
                <div class="bot-finance-text">{{ m.text }}</div>
              </div>
            </template>
          </div>

          <form class="bot-inputbar" @submit.prevent="sendFreeText">
            <input v-model="inputText" type="text" placeholder="Hỏi bất cứ điều gì: giá, so sánh, bảo hành, khuyến mãi..." />
            <button type="submit">Gửi</button>
          </form>
        </div>
      </div>
    </aside>
  </div>
</template>

<style scoped>
.bot-mask {
  position: fixed;
  inset: 0;
  background: var(--bot-overlay);
  z-index: 300;
  display: flex;
  justify-content: flex-end;
}
.bot-drawer {
  width: min(1040px, 96%);
  height: 100%;
  background: var(--bot-aside);
  border-left: 1px solid var(--bot-border);
  display: flex;
  flex-direction: column;
  font-family: 'Plus Jakarta Sans', sans-serif;
  animation: botIn 0.22s ease;
}
@keyframes botIn { from { transform: translateX(30px); opacity: 0.4 } to { transform: none; opacity: 1 } }

.bot-head {
  flex: none;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 18px 24px;
  border-bottom: 1px solid var(--bot-border);
}
.bot-title { font-size: 17px; font-weight: 800; color: var(--bot-text); }
.bot-sub { font-size: 12px; color: var(--bot-muted); margin-top: 3px; }
.bot-head-tools { display: flex; gap: 10px; }
.bot-btn {
  height: 34px;
  padding: 0 14px;
  border-radius: 9px;
  border: 1px solid var(--bot-border);
  background: transparent;
  color: var(--bot-muted2);
  font-size: 12.5px;
  font-family: inherit;
  cursor: pointer;
}
.bot-btn:hover { border-color: var(--acc, #c6ff4a); color: var(--bot-text); }
.bot-btn-x { width: 34px; padding: 0; font-size: 13px; }

.bot-body { flex: 1; min-height: 0; display: flex; }

/* --- Rail chủ đề --- */
.bot-rail {
  flex: none;
  width: 236px;
  overflow-y: auto;
  padding: 16px;
  border-right: 1px solid var(--bot-border);
  display: flex;
  flex-direction: column;
  gap: 18px;
}
.bot-rail-sec { display: flex; flex-direction: column; gap: 3px; }
.bot-rail-title {
  font-family: 'Chakra Petch', sans-serif;
  font-size: 10.8px;
  letter-spacing: 1.1px;
  font-weight: 700;
  color: var(--bot-muted);
  text-transform: uppercase;
  padding: 0 8px 6px;
}
.bot-rail-item {
  display: flex;
  align-items: center;
  gap: 9px;
  width: 100%;
  text-align: left;
  padding: 8px 8px;
  border: none;
  border-radius: 9px;
  background: transparent;
  color: var(--bot-muted2);
  font-size: 12.6px;
  font-family: inherit;
  cursor: pointer;
  transition: background 0.14s, color 0.14s;
}
.bot-rail-item:hover { background: var(--bot-card2); color: var(--bot-text); }
.bot-rail-icon { flex: none; font-size: 14px; width: 18px; text-align: center; }

/* --- Khu hội thoại --- */
.bot-chat { flex: 1; min-width: 0; display: flex; flex-direction: column; }
.bot-msgs {
  flex: 1;
  overflow-y: auto;
  padding: 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.bot-msg {
  max-width: 78%;
  padding: 10px 14px;
  border-radius: 13px;
  font-size: 13.3px;
  line-height: 1.55;
  /* Giữ xuống dòng trong các câu trả lời nhiều ý (vd danh sách kênh liên hệ ở contactHuman) */
  white-space: pre-wrap;
}
.bot-msg.bot { align-self: flex-start; background: var(--bot-card2); color: var(--bot-text); border-bottom-left-radius: 3px; }
.bot-msg.user { align-self: flex-end; background: var(--acc, #c6ff4a); color: var(--acc-ink, #04121f); border-bottom-right-radius: 3px; font-weight: 600; }

.bot-replies { display: flex; flex-wrap: wrap; gap: 7px; }
.bot-reply-btn {
  border: 1px solid var(--bot-border);
  background: transparent;
  color: var(--bot-muted2);
  padding: 7px 13px;
  border-radius: 20px;
  font-size: 12.3px;
  font-family: inherit;
  cursor: pointer;
}
.bot-reply-btn:hover { border-color: var(--acc, #c6ff4a); color: var(--acc, #c6ff4a); }

/* --- Thẻ nội dung (sản phẩm/bài viết dạng lưới; trung tâm/sửa chữa/gói dạng danh sách) --- */
.bot-cards { display: grid; gap: 10px; }
.bot-cards.v-product, .bot-cards.v-article { grid-template-columns: repeat(auto-fill, minmax(210px, 1fr)); }
.bot-cards.v-center, .bot-cards.v-repair, .bot-cards.v-plan { grid-template-columns: 1fr; }

.bot-card {
  position: relative;
  display: flex;
  flex-direction: column;
  text-align: left;
  padding: 0;
  border: 1px solid var(--bot-border);
  border-radius: 12px;
  background: var(--bot-card);
  cursor: pointer;
  font-family: inherit;
  overflow: hidden;
  transition: border-color 0.15s;
}
.bot-card:hover { border-color: var(--acc, #c6ff4a); }
.bot-card-img { height: 108px; background-size: cover; background-position: center; background-color: var(--bot-card2); }
.bot-card-cmp {
  position: absolute;
  top: 8px;
  right: 8px;
  width: 26px;
  height: 26px;
  border-radius: 50%;
  border: none;
  background: rgba(0, 0, 0, 0.5);
  color: #fff;
  font-size: 12px;
  cursor: pointer;
}
.bot-card-cmp:hover { background: var(--acc, #c6ff4a); color: var(--acc-ink, #04121f); }
.bot-card-body { padding: 10px 12px 12px; display: flex; flex-direction: column; gap: 4px; }
.bot-card-badge {
  align-self: flex-start;
  font-size: 10px;
  font-weight: 800;
  padding: 2px 7px;
  border-radius: 20px;
  background: var(--sale, #ff5d7a);
  color: #fff;
}
.bot-card-title { font-size: 12.8px; font-weight: 700; color: var(--bot-text); line-height: 1.4; }
.bot-card-sub {
  font-size: 11.6px;
  color: var(--bot-muted);
  line-height: 1.45;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}
.bot-card-price { font-size: 12.6px; font-weight: 700; color: var(--acc, #c6ff4a); display: flex; gap: 7px; align-items: baseline; }
.bot-card-old { font-size: 10.5px; color: var(--bot-muted); text-decoration: line-through; font-weight: 500; }
.bot-card-meta { font-size: 10.8px; color: var(--bot-muted); }

/* --- Kết quả so sánh tài chính --- */
.bot-finance { border: 1px solid var(--bot-border); border-radius: 13px; padding: 16px; background: var(--bot-card); max-width: 560px; }
.bot-finance-cols { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 12px; }
.bot-finance-col { display: flex; flex-direction: column; gap: 4px; padding: 12px; border-radius: 10px; background: var(--bot-card2); }
.bot-finance-name { font-size: 12.4px; font-weight: 700; color: var(--bot-text); line-height: 1.35; }
.bot-finance-price { font-size: 13.5px; font-weight: 800; }
.bot-finance-score { font-size: 11.3px; color: var(--bot-muted); }
.bot-finance-tag { align-self: flex-start; margin-top: 2px; font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 20px; border: 1px solid; }
.bot-finance-text { font-size: 12.8px; color: var(--bot-muted2); line-height: 1.6; }

.bot-inputbar { display: flex; border-top: 1px solid var(--bot-border); flex: none; }
.bot-inputbar input {
  flex: 1;
  background: transparent;
  border: none;
  padding: 14px 18px;
  color: var(--bot-text);
  font-size: 13.5px;
  font-family: inherit;
}
.bot-inputbar input:focus { outline: none; }
.bot-inputbar button {
  border: none;
  background: var(--acc, #c6ff4a);
  color: var(--acc-ink, #04121f);
  font-weight: 700;
  padding: 0 22px;
  cursor: pointer;
  font-family: inherit;
}

@media (max-width: 760px) {
  .bot-rail { display: none; }
}
</style>
