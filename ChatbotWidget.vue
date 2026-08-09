<script setup>
/**
 * Chatbot hỗ trợ khách hàng — RULE-BASED, có tra cứu SẢN PHẨM THẬT từ DB.
 *
 * 3 luồng gốc:
 *  (1) FAQ            — khớp từ khóa, trả lời có sẵn.
 *  (2) Tư vấn sản phẩm — hỏi danh mục + ngân sách, lọc trong `products` đã nạp sẵn.
 *  (3) Tra giá sản phẩm — gõ tự nhiên hoặc bấm nút, gọi GET /api/products?keyword=...
 *
 * Bổ sung mới:
 *  (4) Lịch sử chat đồng bộ server — chỉ áp dụng cho user đã đăng nhập (JWT).
 *      Khi mở chat: nếu đã login, load lịch sử từ GET /api/chat/history.
 *      Mỗi tin nhắn user/bot gửi thêm lên POST /api/chat/messages (không chặn UI).
 *      Guest (chưa đăng nhập) chat bình thường trong phiên, không lưu bền.
 *  (5) So sánh sản phẩm ngay trong chat — bấm nút "So sánh" trên thẻ sản phẩm
 *      (tối đa 3 sản phẩm), hiển thị bảng so sánh nhỏ ngay trong khung chat.
 *
 * Cách dùng: <ChatbotWidget /> đặt 1 lần trong App.vue.
 */
import { ref, reactive, computed, nextTick, watch } from "vue";
import { products, catMeta, fmt } from "../data/products.js";
import { accent, actions, state } from "../store.js";
import {
  fetchProducts,
  getChatHistory,
  saveChatMessage,
  clearChatHistory,
} from "../api.js";

// ---------- trạng thái cửa sổ chat ----------
const open = ref(false);
const inputText = ref("");
const scrollBox = ref(null);
let msgId = 0;

const messages = reactive([]);
const historyLoaded = ref(false); // đã load lịch sử server cho user hiện tại chưa

// Lưu 1 tin nhắn lên server nếu đã đăng nhập (không chặn UI, lỗi thì bỏ qua âm thầm)
function persistMessage(role, content, metadataObj) {
  if (!state.user) return;
  const metadata = metadataObj ? JSON.stringify(metadataObj) : null;
  saveChatMessage(role, content, metadata).catch(() => {
    // im lặng — không làm phiền trải nghiệm chat nếu lưu lịch sử lỗi tạm thời
  });
}

function pushBot(payload, opts = {}) {
  const m = { id: ++msgId, from: "bot", ...payload };
  messages.push(m);
  scrollToBottom();
  if (!opts.skipPersist && payload.type === "text") {
    persistMessage("bot", payload.text);
  }
  return m;
}
function pushUser(text) {
  messages.push({ id: ++msgId, from: "user", type: "text", text });
  scrollToBottom();
  persistMessage("user", text);
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

// ---------- chuẩn hoá text: bỏ dấu tiếng Việt + lowercase ----------
// Nền tảng cho mọi bước nhận diện phía dưới (FAQ, tồn kho, so sánh, fallback).
// Cho phép người dùng gõ không dấu / thiếu dấu vẫn khớp được từ khóa.
const DIACRITIC_MAP = [
  [/[àáạảãâầấậẩẫăằắặẳẵ]/g, "a"],
  [/[đ]/g, "d"],
  [/[èéẹẻẽêềếệểễ]/g, "e"],
  [/[ìíịỉĩ]/g, "i"],
  [/[òóọỏõôồốộổỗơờớợởỡ]/g, "o"],
  [/[ùúụủũưừứựửữ]/g, "u"],
  [/[ỳýỵỷỹ]/g, "y"],
];

function normalizeText(text) {
  let t = (text || "").toLowerCase().trim();
  DIACRITIC_MAP.forEach(([re, ch]) => {
    t = t.replace(re, ch);
  });
  return t.replace(/\s+/g, " ");
}

// ---------- kho câu trả lời FAQ (rule-based, khớp từ khóa) ----------
// keywords viết CÓ dấu — sẽ tự được chuẩn hoá (bỏ dấu) khi so khớp,
// nên không cần liệt kê thêm bản không dấu cho từng từ.
const FAQ_DB = {
  baohanh: {
    keywords: [
      "bảo hành",
      "bao hanh",
      "warranty",
      "lỗi",
      "hỏng",
      "bảo hành mấy tháng",
      "bảo hành bao lâu",
      "hư",
      "bị lỗi",
    ],
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
      "mấy ngày nhận được hàng",
      "ship về",
      "giao tận nơi",
    ],
    answer:
      "Nội thành HN/TP.HCM giao trong 2–24h. Tỉnh thành khác 2–4 ngày. Phí ship tính theo khu vực và khối lượng đơn.",
  },
  doitra: {
    keywords: [
      "đổi trả",
      "hoàn tiền",
      "trả hàng",
      "không ưng",
      "đổi ý",
      "không thích",
      "không muốn mua nữa",
      "trả lại",
      "muốn đổi",
      "muốn trả",
      "hủy đơn",
      "huỷ đơn",
    ],
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
      "trả tiền",
      "quẹt thẻ",
      "thẻ tín dụng",
    ],
    answer:
      "Hỗ trợ: Thanh toán khi nhận hàng (COD), VNPay, MoMo, hoặc chuyển khoản ngân hàng.",
  },
  tragop: {
    keywords: [
      "trả góp",
      "góp",
      "installment",
      "trả chậm",
      "trả dần",
      "mua trước trả sau",
    ],
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
      "gặp ai",
      "sđt",
      "email",
    ],
    answer: "Hotline: 1900 1903 (8:00–22:00) · Email: cskh@cnttshop.vn.",
  },
};

// Danh sách từ khóa đã chuẩn hoá sẵn (tính 1 lần, tránh normalize lại mỗi lần gõ)
const FAQ_DB_NORMALIZED = Object.fromEntries(
  Object.entries(FAQ_DB).map(([key, val]) => [
    key,
    val.keywords.map((k) => normalizeText(k)),
  ])
);

function matchFaqByText(text) {
  const t = normalizeText(text);
  for (const key in FAQ_DB_NORMALIZED) {
    if (FAQ_DB_NORMALIZED[key].some((k) => t.includes(k))) return key;
  }
  return null;
}

// ---------- kiến thức chuyên sâu về linh kiện: hậu tố GPU/CPU, Hz màn hình, RAM ----------
// Giải thích chi tiết + sau đó gợi ý sản phẩm thật trong shop minh hoạ (qua productHint).
const KNOWLEDGE_DB = {
  gpu_suffix_ti_super: {
    keywords: [
      "hau to ti",
      "hau to super",
      "ti la gi",
      "super la gi",
      "ti va super",
      "card duoi ti",
      "card duoi super",
      "gpu ti",
      "gpu super",
      "ti khac super",
      "duoi co chu ti",
      "co chu ti",
      "chu ti thi",
      "chu ti nghia la",
      "cuoi co chu ti",
      "co chu i thi",
      "duoi co chu i",
    ],
    answer:
      "Với card đồ họa NVIDIA, hậu tố cho biết vị trí trong dải hiệu năng của cùng 1 dòng chip:\n" +
      "• \"Ti\" (Titanium): bản nâng cấp của bản thường cùng số, thường tăng nhân CUDA/xung nhịp, hiệu năng cao hơn 10–20%, giá cũng nhỉnh hơn. VD: RTX 4070 → RTX 4070 Ti mạnh hơn.\n" +
      "• \"Super\": bản refresh giữa vòng đời, cải tiến nhẹ (thường tăng VRAM hoặc xung nhịp) so với bản gốc, ra sau để cạnh tranh giá/hiệu năng. VD: RTX 4070 Super mạnh hơn RTX 4070 gốc nhưng thường rẻ hơn 4070 Ti.\n" +
      "• Không hậu tố: bản tiêu chuẩn, cân bằng giá/hiệu năng, phù hợp đa số nhu cầu phổ thông.\n" +
      "Thứ tự hiệu năng thường gặp: bản thường < Super < Ti < Ti Super.",
    tldr: "→ Tóm lại: không hậu tố = phổ thông, Super = nhỉnh hơn 1 chút, Ti = mạnh hơn hẳn.",
    productHint: { keyword: "card do hoa" },
  },
  gpu_suffix_amd: {
    keywords: [
      "hau to xt",
      "xt la gi",
      "card duoi xt",
      "amd xt",
      "gpu xt",
      "con xt",
      "ve xt",
      "chu xt",
    ],
    answer:
      "Với card AMD Radeon, hậu tố \"XT\" là bản hiệu năng cao hơn trong cùng dòng số — tương tự vai trò của \"Ti\" bên NVIDIA, xung nhịp và số nhân xử lý cao hơn bản không hậu tố. VD: RX 7800 XT mạnh hơn RX 7800 (nếu có bản này).",
    tldr: "→ Tóm lại: card AMD có XT thì mạnh hơn bản cùng số không có XT.",
    productHint: { keyword: "card do hoa" },
  },
  gpu_vram: {
    keywords: [
      "vram bao nhieu",
      "bo nho vram",
      "card mấy gb",
      "gb vram",
      "vram la gi",
    ],
    answer:
      "VRAM là bộ nhớ riêng của card đồ họa, càng nhiều thì xử lý được texture/độ phân giải càng cao mà không bị giật khi thiếu bộ nhớ:\n" +
      "• 8GB: đủ chơi game 1080p mượt ở hầu hết tựa game hiện tại, một số game nặng ở 1440p vẫn ổn.\n" +
      "• 12GB: thoải mái cho 1440p, bắt đầu cần thiết nếu chơi 4K hoặc game đời mới có texture nặng.\n" +
      "• 16GB trở lên: dành cho 4K, dựng hình/AI, hoặc để dư dả cho tương lai.\n" +
      "Nhu cầu văn phòng/đồ họa cơ bản thì 4-6GB đã đủ dùng.",
    tldr: "→ Tóm lại: 8GB đủ 1080p, 12GB cho 1440p, 16GB+ cho 4K/dựng hình.",
    productHint: { keyword: "card do hoa" },
  },
  cpu_suffix_intel: {
    keywords: [
      "hau to k",
      "hau to f",
      "hau to kf",
      "chip duoi k",
      "chip duoi f",
      "cpu k la gi",
      "cpu f la gi",
      "kf la gi",
      "chu k la sao",
      "chu f la sao",
      "chu k nghia la",
      "chu f nghia la",
      "cpu chu k",
      "cpu chu f",
    ],
    answer:
      "Với CPU Intel, hậu tố cho biết tính năng đi kèm:\n" +
      "• \"K\": cho phép ép xung (overclock), thường có xung nhịp gốc cao hơn bản thường, đi kèm giá cao hơn — cần mainboard chipset Z và tản nhiệt tốt để phát huy hết.\n" +
      "• \"F\": KHÔNG có card đồ họa tích hợp (iGPU), giá rẻ hơn bản cùng số không có F — chỉ nên chọn nếu chắc chắn sẽ gắn card rời.\n" +
      "• \"KF\": kết hợp cả 2 — ép xung được, nhưng không có iGPU.\n" +
      "• Không hậu tố: bản tiêu chuẩn, có iGPU, không ép xung, ổn định cho nhu cầu phổ thông/văn phòng.",
    tldr: "→ Tóm lại: K = ép xung được, F = không có card đồ họa tích hợp, KF = cả hai.",
    productHint: { keyword: "cpu" },
  },
  cpu_suffix_amd: {
    keywords: [
      "hau to x amd",
      "cpu duoi x",
      "ryzen x la gi",
      "hau to g amd",
      "ryzen g la gi",
    ],
    answer:
      "Với CPU AMD Ryzen, hậu tố phổ biến:\n" +
      "• \"X\": bản xung nhịp cao hơn, hiệu năng mạnh hơn bản cùng số không hậu tố, hầu hết đều ép xung được.\n" +
      "• \"G\": có card đồ họa tích hợp (iGPU) mạnh hơn dòng thường, phù hợp build PC văn phòng/mini không cần card rời — như dòng Ryzen 3200G/5500GT hay dùng trong PC văn phòng.\n" +
      "• Không hậu tố: bản tiêu chuẩn, hiệu năng cân bằng.",
    tldr: "→ Tóm lại: X = xung nhịp cao hơn, G = có card đồ họa tích hợp mạnh.",
    productHint: { keyword: "cpu" },
  },
  cpu_nhan_luong: {
    keywords: [
      "bao nhieu nhan bao nhieu luong",
      "nhan luong la gi",
      "may nhan may luong",
      "core thread la gi",
      "nhan cpu bao nhieu la du",
    ],
    answer:
      "Nhân (core) là số lõi xử lý vật lý, luồng (thread) là số tác vụ CPU xử lý song song được (nhờ công nghệ Hyper-Threading/SMT, 1 nhân thường xử lý được 2 luồng):\n" +
      "• 4 nhân 8 luồng: đủ cho văn phòng, học tập, giải trí cơ bản.\n" +
      "• 6 nhân 12 luồng: chơi game mượt, đa nhiệm tốt, mức phổ biến hiện nay cho gaming.\n" +
      "• 8 nhân 16 luồng trở lên: dựng phim, render 3D, lập trình biên dịch nặng, livestream vừa chơi vừa stream.\n" +
      "Nhân/luồng càng nhiều càng khỏe đa nhiệm, nhưng chơi game nhiều tựa vẫn phụ thuộc xung nhịp đơn nhân nhiều hơn là số nhân.",
    tldr: "→ Tóm lại: 4/8 cho văn phòng, 6/12 cho gaming, 8/16+ cho dựng phim/render.",
    productHint: { keyword: "cpu" },
  },
  monitor_hz: {
    keywords: [
      "man hinh bao nhieu hz",
      "hz la gi",
      "tan so quet",
      "60hz hay 144hz",
      "144hz co can khong",
      "hz man hinh hop",
    ],
    answer:
      "Hz (tần số quét) là số lần màn hình làm mới hình ảnh mỗi giây — càng cao thì chuyển động càng mượt, đỡ mờ khi lia chuột/di chuyển nhanh:\n" +
      "• 60Hz: đủ cho văn phòng, xem phim, làm việc văn bản — không cần cao hơn nếu không chơi game.\n" +
      "• 75-100Hz: cải thiện rõ rệt cảm giác mượt khi lướt web/thao tác thường ngày, chơi game nhẹ ổn.\n" +
      "• 144Hz: mức phổ biến cho game thủ, tạo lợi thế rõ trong game bắn súng/đối kháng, đáng nâng cấp nếu chơi game thường xuyên.\n" +
      "• 165-240Hz trở lên: dành cho game thủ eSports muốn tối đa lợi thế phản xạ, cần GPU đủ mạnh để đạt được khung hình tương ứng thì mới phát huy hết.\n" +
      "Lưu ý: Hz cao chỉ phát huy tác dụng khi GPU kéo đủ FPS tương ứng, không thì cũng phí.",
    tldr: "→ Tóm lại: 60Hz cho văn phòng, 144Hz cho gaming phổ thông, 165Hz+ cho eSports.",
    productHint: { keyword: "man hinh" },
  },
  monitor_panel: {
    keywords: [
      "ips la gi",
      "va la gi",
      "oled la gi",
      "panel man hinh",
      "ips va va",
      "tam nen man hinh",
    ],
    answer:
      "Panel là công nghệ tấm nền màn hình, ảnh hưởng màu sắc/góc nhìn/độ tương phản:\n" +
      "• IPS: màu sắc chính xác, góc nhìn rộng, phù hợp làm đồ họa/thiết kế và chơi game — lựa chọn phổ biến nhất hiện nay.\n" +
      "• VA: độ tương phản cao, đen sâu hơn IPS, hợp xem phim, nhưng góc nhìn hẹp hơn và tốc độ phản hồi thường chậm hơn.\n" +
      "• OLED: đen tuyệt đối (tự phát sáng từng điểm ảnh), màu rực và tương phản cực cao, tốc độ phản hồi cực nhanh — nhưng giá cao và có nguy cơ lưu ảnh (burn-in) nếu để hình tĩnh lâu.\n" +
      "• TN: tốc độ phản hồi nhanh, giá rẻ nhất, nhưng màu sắc và góc nhìn kém nhất — ít còn phổ biến.",
    tldr: "→ Tóm lại: IPS cân bằng nhất, VA hợp xem phim, OLED đẹp nhất nhưng đắt.",
    productHint: { keyword: "man hinh" },
  },
  ram_bus: {
    keywords: [
      "bus ram la gi",
      "ram bao nhieu mhz",
      "bus ram bao nhieu",
      "toc do ram",
      "ram mhz la gi",
    ],
    answer:
      "Bus (tính bằng MHz) là tốc độ truyền dữ liệu của RAM — bus càng cao thì RAM truyền dữ liệu càng nhanh, nhưng phải mainboard/CPU hỗ trợ mới phát huy hết:\n" +
      "• DDR4 phổ biến: 2666-3200MHz (phổ thông), 3600MHz trở lên (hiệu năng cao, hợp gaming/ép xung).\n" +
      "• DDR5 phổ biến: 4800-5600MHz (tiêu chuẩn), 6000MHz trở lên (hiệu năng cao).\n" +
      "Chênh lệch bus ảnh hưởng rõ nhất khi dùng CPU có iGPU mạnh (như dòng G của AMD) hoặc khi chơi game nặng, còn tác vụ văn phòng thì gần như không cảm nhận được khác biệt.",
    tldr: "→ Tóm lại: bus càng cao càng nhanh, nhưng phải mainboard/CPU hỗ trợ mới có tác dụng.",
    productHint: { keyword: "ram" },
  },
  ram_dungluong: {
    keywords: [
      "ram bao nhieu gb la du",
      "nen mua ram bao nhieu",
      "8gb hay 16gb",
      "16gb hay 32gb",
      "ram bao nhieu du dung",
    ],
    answer:
      "Dung lượng RAM nên chọn theo nhu cầu sử dụng:\n" +
      "• 8GB: đủ cho văn phòng cơ bản, lướt web, học tập — hơi chật nếu mở nhiều tab/ứng dụng cùng lúc.\n" +
      "• 16GB: mức khuyến nghị phổ biến hiện nay, thoải mái cho gaming, đa nhiệm, học tập/làm việc nặng hơn.\n" +
      "• 32GB trở lên: dựng phim, làm đồ họa 3D, chạy máy ảo, lập trình dự án lớn, hoặc chơi game kết hợp livestream/ghi hình.\n" +
      "Nên chọn kit 2 thanh (dual-channel) thay vì 1 thanh cùng dung lượng để tăng băng thông, hiệu năng mượt hơn.",
    tldr: "→ Tóm lại: 8GB đủ văn phòng, 16GB khuyến nghị phổ biến, 32GB+ cho công việc nặng.",
    productHint: { keyword: "ram" },
  },
  ram_ddr_version: {
    keywords: [
      "ddr4 hay ddr5",
      "ddr4 va ddr5 khac gi",
      "ddr5 co can khong",
      "nen mua ddr4 hay ddr5",
    ],
    answer:
      "DDR5 là thế hệ mới hơn DDR4, băng thông cao hơn và tiết kiệm điện hơn, nhưng giá cao hơn và chỉ tương thích mainboard/CPU đời mới hỗ trợ DDR5 (không lắp lẫn được với khe DDR4):\n" +
      "• Chọn DDR4 nếu: mainboard/CPU hiện tại chỉ hỗ trợ DDR4, hoặc muốn tiết kiệm chi phí mà vẫn đủ hiệu năng cho đa số nhu cầu.\n" +
      "• Chọn DDR5 nếu: build máy mới hoàn toàn với CPU/mainboard đời mới, cần hiệu năng cao nhất cho gaming/đồ họa nặng, hoặc muốn đầu tư lâu dài.\n" +
      "Lưu ý quan trọng: phải kiểm tra mainboard hỗ trợ DDR4 hay DDR5 trước khi mua, vì 2 loại không lắp chung được.",
    tldr: "→ Tóm lại: DDR4 rẻ và tương thích rộng, DDR5 nhanh hơn nhưng đắt và kén main.",
    productHint: { keyword: "ram" },
  },
};

const KNOWLEDGE_DB_NORMALIZED = Object.fromEntries(
  Object.entries(KNOWLEDGE_DB).map(([key, val]) => [
    key,
    val.keywords.map((k) => normalizeText(k)),
  ])
);

function matchKnowledgeByText(text) {
  const t = normalizeText(text);
  for (const key in KNOWLEDGE_DB_NORMALIZED) {
    if (KNOWLEDGE_DB_NORMALIZED[key].some((k) => t.includes(k))) return key;
  }
  return null;
}

// Trả lời câu hỏi kiến thức: giải thích chi tiết trước, sau đó gợi ý tối đa 3 sản phẩm
// thật minh hoạ — gọi API /api/products theo từ khóa (giống luồng tra giá đã hoạt động
// ổn định), không lọc theo field `cat` vì slug category được sinh động từ tên category
// thật trong DB nên không đoán trước được.
// Nhớ chủ đề kiến thức bot vừa trả lời gần nhất — dùng để hiểu câu hỏi nối tiếp
// ("còn XT thì sao") và câu hỏi làm rõ ("không hiểu lắm", "nói đơn giản hơn đi").
const lastKnowledgeKey = ref(null);

async function answerKnowledge(key, opts = {}) {
  const entry = KNOWLEDGE_DB[key];
  if (!entry) return;

  pushBot({ type: "text", text: entry.answer });
  if (entry.tldr) {
    pushBot({ type: "text", text: entry.tldr });
  }
  lastKnowledgeKey.value = key;

  // Khi trả lời lại vì khách chưa hiểu, không cần lặp lại gợi ý sản phẩm nữa
  if (opts.skipIllustrate) {
    pushBot({ type: "quick-replies", options: MAIN_MENU });
    step.value = "menu";
    scrollToBottom();
    return;
  }

  let illustrate = [];
  if (entry.productHint?.keyword) {
    try {
      const results = await fetchProducts({ keyword: entry.productHint.keyword });
      illustrate = (results || []).slice(0, 3);
    } catch (e) {
      console.error(e);
    }
  }

  if (illustrate.length > 0) {
    pushBot({ type: "text", text: "Một vài sản phẩm thực tế trong shop bạn có thể tham khảo:" });
    pushBot({ type: "products-api", items: illustrate });
  }

  pushBot({ type: "quick-replies", options: MAIN_MENU });
  step.value = "menu";
  scrollToBottom();
}

// ---------- nhận diện câu hỏi "làm rõ / chưa hiểu" câu trả lời trước ----------
const CLARIFY_RE =
  /\b(khong hieu|chua hieu|hieu lam|noi lai|giai thich lai|noi don gian|de hieu hon|ro hon duoc khong|lai duoc khong|y la sao|nghia la sao|la sao)\b/;

function isClarifyQuestion(text) {
  return CLARIFY_RE.test(normalizeText(text));
}

// Bản rút gọn của mỗi câu trả lời kiến thức — dùng khi khách nói chưa hiểu, cần
// diễn đạt lại ngắn gọn, dễ hiểu hơn thay vì lặp nguyên văn câu dài lúc trước.
function simplifyAnswer(key) {
  const entry = KNOWLEDGE_DB[key];
  if (!entry) return null;
  return entry.tldr
    ? entry.tldr.replace(/^→\s*Tóm lại:\s*/i, "Nói đơn giản: ")
    : entry.answer;
}

// ---------- nhận diện câu hỏi giá + tách từ khóa sản phẩm ----------
// Viết không dấu, so trên bản đã normalize để câu không dấu/thiếu dấu vẫn khớp được.
const PRICE_QUESTION_RE = /gia|bao nhieu|nhieu tien|gia tien|gia ban/;

function isPriceQuestion(text) {
  return PRICE_QUESTION_RE.test(normalizeText(text));
}

// Các cụm/hư từ hay đi kèm câu hỏi giá tiếng Việt — loại bỏ để còn lại tên sản phẩm.
// Viết không dấu, áp dụng trên bản text đã normalize (extractProductKeyword tự làm điều này).
const STRIP_PATTERNS = [
  /gia\s+cua/g,
  /gia\s+ban/g,
  /gia\s+tien/g,
  /bao nhieu tien/g,
  /la bao nhieu/g,
  /bao nhieu/g,
  /gia/g,
  /nhieu tien/g,
  /^tien\b/g,
  /cho minh hoi/g,
  /cho minh xin hoi/g,
  /minh muon hoi/g,
  /minh muon biet/g,
  /cho toi hoi/g,
  /toi muon hoi/g,
  /xin hoi/g,
  /minh hoi/g,
  /shop oi/g,
  /\bcua\b/g,
  /\bla\b/g,
  /\bvay a\b/g,
  /\bvay\b/g,
  /\bnhe\b/g,
  /\ba\b/g,
  /\bcho\b/g,
  /\bxem\b/g,
  /\bcon\b/g,
  /\?/g,
];

function extractProductKeyword(text) {
  let t = normalizeText(text);
  STRIP_PATTERNS.forEach((p) => {
    t = t.replace(p, " ");
  });
  return t.replace(/\s+/g, " ").trim();
}

// ---------- nhận diện câu hỏi tồn kho / còn hàng không ----------
// So khớp trên bản đã bỏ dấu để không phụ thuộc dấu câu người dùng gõ.
const STOCK_QUESTION_RE =
  /\b(con hang|het hang|con khong|con k\b|con ko\b|conhang|hang con|tinh trang hang|sl con|so luong con|ton kho)\b/;

function isStockQuestion(text) {
  return STOCK_QUESTION_RE.test(normalizeText(text));
}

// Loại bỏ cụm hỏi tồn kho khỏi câu để lấy phần còn lại làm từ khóa sản phẩm.
// Viết không dấu, áp dụng trên bản text đã normalize.
const STOCK_STRIP_PATTERNS = [
  /con hang khong/g,
  /con hang ko/g,
  /con hang k\b/g,
  /con hang/g,
  /het hang chua/g,
  /het hang/g,
  /con khong/g,
  /con k\b/g,
  /con ko\b/g,
  /tinh trang hang/g,
  /so luong con/g,
  /ton kho/g,
  /\bcon\b/g,
  /\bkhong\b/g,
  /\bko\b/g,
  /\bk\b/g,
  /\bchua\b/g,
  /\bshop oi\b/g,
  /\bcho minh hoi\b/g,
  /\bcho em hoi\b/g,
  /\bxin hoi\b/g,
  /\?/g,
];

function extractStockKeyword(text) {
  let t = normalizeText(text);
  STOCK_STRIP_PATTERNS.forEach((p) => {
    t = t.replace(p, " ");
  });
  return t.replace(/\s+/g, " ").trim();
}

// Gọi API tìm sản phẩm rồi trả lời theo field `stock` có sẵn trong response.
async function answerStockQuestion(keyword) {
  const loadingMsg = pushBot(
    { type: "text", text: `Đang kiểm tra tồn kho "${keyword}"...` },
    { skipPersist: true }
  );

  let results = [];
  try {
    results = await fetchProducts({ keyword });
  } catch (e) {
    console.error(e);
  }

  const idx = messages.findIndex((m) => m.id === loadingMsg.id);
  const top5 = (results || []).slice(0, 5);

  let finalText = "";
  if (top5.length === 0) {
    finalText = `Mình không tìm thấy sản phẩm nào khớp với "${keyword}" trong kho. Bạn thử gõ tên ngắn gọn hơn nhé.`;
  } else if (top5.length === 1) {
    const p = top5[0];
    finalText =
      p.stock > 0
        ? `${p.name}: còn hàng, hiện còn ${p.stock} sản phẩm.`
        : `${p.name}: tạm hết hàng, bạn để lại thông tin để shop báo khi có hàng lại nhé.`;
  } else {
    finalText = `Mình tìm thấy ${top5.length} sản phẩm khớp với "${keyword}", tình trạng kho như sau:`;
  }

  if (idx !== -1) messages[idx] = { ...loadingMsg, text: finalText };
  persistMessage("bot", finalText);

  if (top5.length > 1) {
    const lines = top5
      .map((p) => `• ${p.name}: ${p.stock > 0 ? `còn ${p.stock}` : "hết hàng"}`)
      .join("\n");
    pushBot({ type: "text", text: lines });
  }

  if (top5.length > 0) {
    pushBot({ type: "products-api", items: top5 });
  }

  pushBot({ type: "quick-replies", options: MAIN_MENU });
  step.value = "menu";
  scrollToBottom();
}

// ---------- khởi tạo hội thoại ----------
function greet() {
  messages.length = 0;
  step.value = "menu";
  pushBot(
    {
      type: "text",
      text: 'Chào bạn 👋 Mình là trợ lý CNTTshop. Bạn có thể hỏi thẳng giá sản phẩm (VD: "giá RAM Corsair 32GB") hoặc chọn mục bên dưới.',
    },
    { skipPersist: true }
  );
  pushBot({ type: "quick-replies", options: MAIN_MENU }, { skipPersist: true });
}

// Tải lịch sử chat từ server (chỉ khi đã đăng nhập). Nếu có lịch sử cũ, hiển thị
// lại các tin nhắn text (quick-replies/products không lưu lại dạng tương tác được,
// nên chỉ khôi phục phần hội thoại văn bản), sau đó vẫn thêm menu chính để dùng tiếp.
async function loadHistoryThenGreet() {
  if (!state.user) {
    greet();
    return;
  }
  try {
    const history = await getChatHistory();
    messages.length = 0;
    step.value = "menu";
    if (history && history.length > 0) {
      history.forEach((h) => {
        messages.push({
          id: ++msgId,
          from: h.role === "user" ? "user" : "bot",
          type: "text",
          text: h.content,
        });
      });
      pushBot(
        { type: "text", text: "Bạn cần hỗ trợ gì tiếp không?" },
        { skipPersist: true }
      );
      pushBot(
        { type: "quick-replies", options: MAIN_MENU },
        { skipPersist: true }
      );
      scrollToBottom();
    } else {
      greet();
    }
  } catch (e) {
    console.error("Không tải được lịch sử chat:", e);
    greet();
  }
  historyLoaded.value = true;
}

function toggleOpen() {
  open.value = !open.value;
  if (open.value && messages.length === 0) {
    loadHistoryThenGreet();
  }
}

// Nếu user đăng nhập/đăng xuất trong lúc cửa sổ đang có sẵn tin nhắn của phiên
// trước (guest hoặc user khác), tải lại đúng lịch sử tương ứng lần mở kế tiếp.
watch(
  () => state.user,
  () => {
    historyLoaded.value = false;
    messages.length = 0;
  }
);

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
  }
}

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
      : "Mình chưa có thông tin này, bạn gọi hotline 1900 1903 giúp mình nhé.",
  });
  pushBot({
    type: "quick-replies",
    options: FAQ_MENU.map((f) => ({ label: f.label, key: f.key })),
  });
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
  const loadingMsg = pushBot(
    { type: "text", text: `Đang tìm "${keyword}"...` },
    { skipPersist: true }
  );

  let results = [];
  try {
    results = await fetchProducts({ keyword });
  } catch (e) {
    console.error(e);
  }

  const idx = messages.findIndex((m) => m.id === loadingMsg.id);
  const top5 = (results || []).slice(0, 5);

  let finalText = "";
  if (top5.length === 0) {
    finalText = `Mình không tìm thấy sản phẩm nào khớp với "${keyword}" trong kho. Bạn thử gõ tên ngắn gọn hơn nhé.`;
  } else if (top5.length === 1) {
    const p = top5[0];
    finalText = `${p.name}: ${fmt(p.price)}${
      p.originalPrice ? " (giá gốc " + fmt(p.originalPrice) + ")" : ""
    }`;
  } else {
    finalText = `Mình tìm thấy ${top5.length} sản phẩm khớp với "${keyword}", bạn xem giá bên dưới nhé:`;
  }

  if (idx !== -1) messages[idx] = { ...loadingMsg, text: finalText };
  persistMessage("bot", finalText);

  if (top5.length > 0) {
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

// ---------- so sánh sản phẩm ngay trong chat ----------
const MAX_COMPARE = 3;
const compareList = reactive([]); // các sản phẩm đang được so sánh

function compareKey(p) {
  // sản phẩm từ luồng local (products) dùng id; từ API tra giá cũng có id -> dùng chung
  return p.id;
}

function isInCompare(p) {
  return compareList.some((x) => compareKey(x) === compareKey(p));
}

function toggleCompare(p, evt) {
  if (evt) evt.stopPropagation(); // đừng để bấm "So sánh" mở luôn trang chi tiết
  const already = isInCompare(p);
  if (already) {
    const i = compareList.findIndex((x) => compareKey(x) === compareKey(p));
    if (i !== -1) compareList.splice(i, 1);
    return;
  }
  if (compareList.length >= MAX_COMPARE) {
    pushBot({
      type: "text",
      text: `Bạn chỉ có thể so sánh tối đa ${MAX_COMPARE} sản phẩm cùng lúc. Bỏ bớt 1 sản phẩm trong bảng so sánh rồi thêm sản phẩm mới nhé.`,
    });
    return;
  }
  compareList.push(p);
}

function removeFromCompare(p) {
  const i = compareList.findIndex((x) => compareKey(x) === compareKey(p));
  if (i !== -1) compareList.splice(i, 1);
}

function clearCompare() {
  compareList.splice(0, compareList.length);
}

// ---------- nhận diện câu hỏi so sánh 2 sản phẩm ngay trong text ----------
// vd: "rtx 4060 hay 4070 tốt hơn", "ram 16gb với 32gb cái nào ngon hơn", "so sánh a và b"
// Regex chứa cả 2 dạng có dấu/không dấu vì dùng để tách trên CẢ text gốc (giữ dấu,
// cho extractCompareTerms lấy đúng tên sản phẩm) LẪN bản đã normalize (cho isCompareQuestion).
const COMPARE_SPLIT_RE =
  /\s+(?:hay là|hay la|hoặc|hoac|so với|so voi|với|voi|và|va|vs|hay hơn|hay hon|hay)\s+/i;

const COMPARE_HINT_RE =
  /\b(so sanh|cai nao (tot|ngon|hon)|tot hon|hon (nhau|khong)|nen (mua|chon) (cai|con) nao|khac nhau (cho nao|gi))\b/;

function isCompareQuestion(text) {
  const t = normalizeText(text);
  if (!COMPARE_HINT_RE.test(t)) return false;
  // phải tách được thành 2 vế mới coi là câu so sánh hợp lệ
  return COMPARE_SPLIT_RE.test(t);
}

// Cụm dư thừa hay đi kèm câu so sánh, cắt bỏ để còn lại tên sản phẩm ở mỗi vế.
// Viết không dấu, áp dụng trên bản text đã normalize.
const COMPARE_STRIP_PATTERNS = [
  /so sanh/g,
  /cai nao (tot|ngon|hon)( hon)?/g,
  /tot hon/g,
  /ngon hon/g,
  /hon nhau/g,
  /hon khong/g,
  /nen (mua|chon)/g,
  /(cai|con) nao/g,
  /khac nhau (cho nao|gi)/g,
  /\bshop oi\b/g,
  /\bcho minh hoi\b/g,
  /\?/g,
];

function extractCompareTerms(text) {
  let t = normalizeText(text);
  COMPARE_STRIP_PATTERNS.forEach((p) => {
    t = t.replace(p, " ");
  });
  t = t.replace(/\s+/g, " ").trim();

  const parts = t.split(COMPARE_SPLIT_RE).map((s) => s.trim()).filter(Boolean);
  return parts.slice(0, 2); // chỉ lấy 2 vế đầu
}

async function answerCompareQuestion(text) {
  const terms = extractCompareTerms(text);
  if (terms.length < 2 || terms[0].length < 2 || terms[1].length < 2) {
    pushBot({
      type: "text",
      text: "Bạn cho mình biết cụ thể 2 sản phẩm muốn so sánh nhé, ví dụ: \"RAM 16GB DDR4 với RAM 32GB DDR5\".",
    });
    pushBot({ type: "quick-replies", options: MAIN_MENU });
    step.value = "menu";
    return;
  }

  const loadingMsg = pushBot(
    { type: "text", text: `Đang tìm "${terms[0]}" và "${terms[1]}" để so sánh...` },
    { skipPersist: true }
  );

  let resA = [];
  let resB = [];
  try {
    [resA, resB] = await Promise.all([
      fetchProducts({ keyword: terms[0] }),
      fetchProducts({ keyword: terms[1] }),
    ]);
  } catch (e) {
    console.error(e);
  }

  const idx = messages.findIndex((m) => m.id === loadingMsg.id);
  const pA = (resA || [])[0];
  const pB = (resB || [])[0];

  let finalText = "";
  if (!pA || !pB) {
    const missing = !pA && !pB ? `"${terms[0]}" và "${terms[1]}"` : !pA ? `"${terms[0]}"` : `"${terms[1]}"`;
    finalText = `Mình không tìm thấy đủ dữ liệu cho ${missing}. Bạn thử gõ tên chính xác hơn nhé.`;
  } else {
    clearCompare();
    compareList.push(pA);
    compareList.push(pB);
    finalText = `Mình đã đưa "${pA.name}" và "${pB.name}" vào bảng so sánh bên cạnh, bạn xem chi tiết nhé.`;
  }

  if (idx !== -1) messages[idx] = { ...loadingMsg, text: finalText };
  persistMessage("bot", finalText);

  pushBot({ type: "quick-replies", options: MAIN_MENU });
  step.value = "menu";
  scrollToBottom();
}

// Các dòng thông số hiển thị trong bảng so sánh — chỉ dùng field sẵn có trên
// cả 2 nguồn dữ liệu (local `products` và kết quả `/api/products`).
const compareRows = computed(() => {
  if (compareList.length < 2) return [];
  return [
    {
      label: "Giá",
      values: compareList.map((p) => fmt(p.price)),
    },
    {
      label: "Giá gốc",
      values: compareList.map((p) => (p.originalPrice ? fmt(p.originalPrice) : "—")),
    },
    {
      label: "Thương hiệu / Danh mục",
      values: compareList.map((p) => p.brandName || p.brand || p.categoryName || "—"),
    },
  ];
});

// ---------- ô nhập tự do ----------
// ---------- fallback thông minh: gợi ý sản phẩm liên quan thay vì chỉ nói "chưa hiểu" ----------
// Loại bỏ các từ hỏi/hư từ phổ biến để lấy phần "lõi" của câu làm từ khóa thử tìm sản phẩm.
// Viết không dấu, áp dụng trên bản text đã normalize.
const FALLBACK_STRIP_PATTERNS = [
  /\bshop oi\b/g,
  /\bcho minh hoi\b/g,
  /\bcho em hoi\b/g,
  /\bxin hoi\b/g,
  /\bminh muon\b/g,
  /\bminh can\b/g,
  /\btu van\b/g,
  /\bgiup minh\b/g,
  /\bgiup em\b/g,
  /\bgiup voi\b/g,
  /\bsan pham\b/g,
  /\bmat hang\b/g,
  /\bco\b/g,
  /\bkhong\b/g,
  /\bko\b/g,
  /\bcon\b/g,
  /\bcai\b/g,
  /\bchiec\b/g,
  /\bcua\b/g,
  /\bxem\b/g,
  /\?/g,
];

function extractFallbackKeyword(text) {
  let t = normalizeText(text);
  FALLBACK_STRIP_PATTERNS.forEach((p) => {
    t = t.replace(p, " ");
  });
  return t.replace(/\s+/g, " ").trim();
}

async function tryFallbackSuggest(text) {
  const keyword = extractFallbackKeyword(text);
  if (keyword.length < 2) return false;

  let results = [];
  try {
    results = await fetchProducts({ keyword });
  } catch (e) {
    console.error(e);
  }

  const top3 = (results || []).slice(0, 3);
  if (top3.length === 0) return false;

  pushBot({
    type: "text",
    text: `Mình chưa chắc hiểu ý bạn 🤔 Nhưng có thể bạn đang quan tâm mấy sản phẩm này:`,
  });
  pushBot({ type: "products-api", items: top3 });
  pushBot({ type: "quick-replies", options: MAIN_MENU });
  step.value = "menu";
  return true;
}

async function sendFreeText() {
  const text = inputText.value.trim();
  if (!text) return;
  pushUser(text);
  inputText.value = "";

  // đang trong luồng "gõ tên sản phẩm cần tra giá" -> dùng nguyên câu làm từ khóa
  if (step.value === "awaiting_product_search") {
    searchProductPrice(text);
    return;
  }

  // khách nói chưa hiểu / muốn giải thích lại -> nếu có chủ đề kiến thức vừa nói,
  // trả lời lại bản rút gọn thay vì lặp nguyên văn hoặc rơi vào fallback
  if (isClarifyQuestion(text) && lastKnowledgeKey.value) {
    const simple = simplifyAnswer(lastKnowledgeKey.value);
    pushBot({
      type: "text",
      text: simple || "Mình xin lỗi, bạn hỏi cụ thể hơn giúp mình chỗ nào chưa rõ nhé.",
    });
    pushBot({ type: "quick-replies", options: MAIN_MENU });
    step.value = "menu";
    return;
  }

  // câu hỏi so sánh 2 sản phẩm ngay trong text -> tách 2 vế, tra API, đẩy vào bảng so sánh
  if (isCompareQuestion(text)) {
    answerCompareQuestion(text);
    return;
  }

  // câu hỏi tồn kho/còn hàng -> tách từ khóa rồi tra DB, trả lời theo field stock
  if (isStockQuestion(text)) {
    const keyword = extractStockKeyword(text);
    if (keyword.length >= 2) {
      answerStockQuestion(keyword);
      return;
    }
    // nhận ra đây là câu hỏi tồn kho nhưng thiếu tên sản phẩm cụ thể -> hỏi lại
    pushBot({
      type: "text",
      text: "Bạn muốn kiểm tra tồn kho sản phẩm nào vậy? Gõ tên sản phẩm giúp mình nhé.",
    });
    pushBot({ type: "quick-replies", options: MAIN_MENU });
    step.value = "menu";
    return;
  }

  // câu hỏi kiến thức chuyên sâu (hậu tố GPU/CPU, Hz màn hình, RAM...) -> kiểm tra
  // TRƯỚC câu hỏi giá, vì nhiều câu kiến thức cũng chứa "bao nhiêu" (vd "ram bao
  // nhiêu gb là đủ") nên nếu để câu hỏi giá chạy trước sẽ cướp mất, tra sai từ khóa.
  const knowledgeKey = matchKnowledgeByText(text);
  if (knowledgeKey) {
    answerKnowledge(knowledgeKey);
    return;
  }

  // câu hỏi tiếp nối ngắn dựa vào ngữ cảnh chủ đề kiến thức vừa nói (vd "thế còn XT
  // thì sao" sau khi đang nói về GPU) -> thử match lại nới lỏng hơn: câu ngắn kiểu
  // "còn X thì sao" thường đã có từ khóa riêng (vd "con xt") nằm trong KNOWLEDGE_DB,
  // chỉ cần đảm bảo đang có ngữ cảnh trước đó thì mới chấp nhận match này.
  const FOLLOWUP_RE = /\b(the con|con .* thi sao|con .* thi the nao|vay con)\b/;
  if (lastKnowledgeKey.value && FOLLOWUP_RE.test(normalizeText(text))) {
    const followupKey = matchKnowledgeByText(text);
    if (followupKey) {
      answerKnowledge(followupKey);
      return;
    }
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
    return;
  }

  // không khớp luồng nào -> thử gợi ý sản phẩm liên quan trước khi chịu thua
  const suggested = await tryFallbackSuggest(text);
  if (!suggested) {
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

    <!-- nhóm 2 cửa sổ: panel so sánh + cửa sổ chat, tự xếp ngang/dọc theo bề rộng màn hình -->
    <div v-if="open" class="cbw-panels">
      <!-- panel so sánh sản phẩm, tách riêng -->
      <div v-if="compareList.length >= 1" class="cbw-compare-panel">
        <div class="cbw-compare-head">
          <span>So sánh {{ compareList.length }}/{{ MAX_COMPARE }} sản phẩm</span>
        <button class="cbw-compare-clear" @click="clearCompare">Xoá hết</button>
      </div>

      <div class="cbw-compare-list">
        <div v-for="(p, ci) in compareList" :key="compareKey(p)" class="cbw-compare-item">
          <div class="cbw-compare-item-head">
            <span class="cbw-compare-pname" @click="openProduct(p)">{{ p.name }}</span>
            <button class="cbw-compare-remove" title="Bỏ khỏi so sánh" @click="removeFromCompare(p)">✕</button>
          </div>
          <div v-if="compareList.length >= 2" class="cbw-compare-item-rows">
            <div v-for="row in compareRows" :key="row.label" class="cbw-compare-row">
              <span class="cbw-compare-row-label">{{ row.label }}</span>
              <span class="cbw-compare-row-value">{{ row.values[ci] }}</span>
            </div>
          </div>
        </div>
      </div>

      <div v-if="compareList.length === 1" class="cbw-compare-hint">
        Chọn thêm ít nhất 1 sản phẩm nữa để xem so sánh.
      </div>
      </div>

    <!-- cửa sổ chat -->
    <div class="cbw-window">
      <div class="cbw-header">
        <div class="cbw-title">Trợ lý CNTTshop</div>
        <div class="cbw-sub">
          Tra giá trực tiếp từ kho hàng · phản hồi ngay
          <span v-if="state.user" class="cbw-synced" title="Lịch sử chat đang được lưu">· đã lưu lịch sử</span>
        </div>
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
              <button
                class="cbw-compare-btn"
                :class="{ active: isInCompare(p) }"
                @click="toggleCompare(p, $event)"
              >
                {{ isInCompare(p) ? "✓ Đang so sánh" : "So sánh" }}
              </button>
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
              <button
                class="cbw-compare-btn"
                :class="{ active: isInCompare(p) }"
                @click="toggleCompare(p, $event)"
              >
                {{ isInCompare(p) ? "✓ Đang so sánh" : "So sánh" }}
              </button>
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
  </div>
</template>

<style scoped>
.cbw-root {
  position: fixed;
  right: 22px;
  bottom: 22px;
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

.cbw-panels {
  position: absolute;
  right: 0;
  bottom: 68px;
  display: flex;
  flex-direction: row-reverse;
  align-items: flex-end;
  gap: 12px;
}
@media (max-width: 720px) {
  .cbw-panels {
    flex-direction: column-reverse;
    align-items: flex-end;
    right: 0;
  }
}

.cbw-window {
  width: 340px;
  max-width: calc(100vw - 44px);
  max-height: 600px;
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
.cbw-synced {
  color: #6fe3c0;
}

.cbw-body {
  flex: 1;
  overflow-y: auto;
  padding: 14px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-height: 360px;
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

.cbw-compare-btn {
  margin-top: 7px;
  border: 1px solid rgba(120, 170, 230, 0.3);
  background: transparent;
  color: #9fb6d2;
  padding: 4px 9px;
  border-radius: 8px;
  font-size: 11px;
  cursor: pointer;
}
.cbw-compare-btn:hover {
  border-color: var(--acc);
  color: var(--acc);
}
.cbw-compare-btn.active {
  background: var(--acc);
  border-color: var(--acc);
  color: #04121f;
  font-weight: 700;
}

.cbw-compare-hint {
  margin: 10px 14px;
  padding: 8px 10px;
  font-size: 11.5px;
  color: #9fb6d2;
  background: #0c2742;
  border: 1px dashed rgba(120, 170, 230, 0.25);
  border-radius: 8px;
}

.cbw-compare-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 14px;
  font-size: 12px;
  font-weight: 700;
  color: #e8f1fc;
  background: linear-gradient(90deg, #081a2d, #032e5d);
}
.cbw-compare-clear {
  border: none;
  background: transparent;
  color: #ff8a8a;
  font-size: 11px;
  cursor: pointer;
}
.cbw-compare-panel {
  width: 300px;
  max-width: min(300px, calc(100vw - 44px));
  max-height: 600px;
  background: #0a2138;
  border: 1px solid rgba(120, 170, 230, 0.18);
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5);
  display: flex;
  flex-direction: column;
}

.cbw-compare-list {
  display: flex;
  flex-direction: column;
  overflow-y: auto;
}
.cbw-compare-item {
  border-bottom: 1px solid rgba(120, 170, 230, 0.12);
  padding: 10px 12px;
}
.cbw-compare-item:last-child {
  border-bottom: none;
}
.cbw-compare-item-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 6px;
}
.cbw-compare-pname {
  cursor: pointer;
  font-size: 12.5px;
  font-weight: 700;
  color: #e8f1fc;
  line-height: 1.4;
}
.cbw-compare-pname:hover {
  color: var(--acc);
}
.cbw-compare-remove {
  border: none;
  background: transparent;
  color: #6e87a6;
  font-size: 12px;
  cursor: pointer;
  flex: none;
  line-height: 1;
  padding: 2px;
}
.cbw-compare-remove:hover {
  color: #ff8a8a;
}
.cbw-compare-item-rows {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.cbw-compare-row {
  display: flex;
  justify-content: space-between;
  gap: 10px;
  font-size: 12px;
}
.cbw-compare-row-label {
  color: #7e98b6;
  flex: none;
}
.cbw-compare-row-value {
  color: #cfdceb;
  text-align: right;
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
