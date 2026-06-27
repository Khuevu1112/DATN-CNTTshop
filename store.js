import { reactive, computed } from "vue";
import {
  accents,
  products,
  productById,
  defaultSel,
  priceWith,
  cfgKey,
  loadCatalog,
  loadDetail,
} from "./data/products.js";
import { login as apiLogin, register as apiRegister } from "./api.js";

// ===== Global reactive store (shared singleton) =====
export const state = reactive({
  route: "home", // home | category | detail | cart
  cat: "all",
  selId: null,
  cfgSel: {},
  cart: [],
  brandFilter: [],
  sort: "pop",
  priceMax: 70000000,
  theme: "cyan",
  mode: "dark",
  q: "",
  toast: "",
  placed: false,
  loading: false,
  loadingMsg: "Đang tải...",
  // ===== Đăng nhập =====
  user: JSON.parse(localStorage.getItem("user") || "null"),
  token: localStorage.getItem("token") || "",
  loginPrev: "home",
});

let _navTimer = null;
let _toastTimer = null;

const scrollTop = () => {
  try {
    window.scrollTo(0, 0);
  } catch (e) {}
};

// Simulated route transition with a loading overlay (mirrors the original UX)
function go(patch, ms = 480, msg = "Đang tải...") {
  state.loading = true;
  state.loadingMsg = msg;
  clearTimeout(_navTimer);
  _navTimer = setTimeout(() => {
    Object.assign(state, patch, { loading: false });
    scrollTop();
  }, ms);
}

export const actions = {
  goHome: () => go({ route: "home" }, 480, "Đang về trang chủ..."),
  goCart: () =>
    go({ route: "cart", placed: false }, 480, "Đang mở giỏ hàng..."),
  goCat: (cat) =>
    go(
      { route: "category", cat, brandFilter: [], q: "" },
      480,
      "Đang tải sản phẩm..."
    ),
  goCatAll: () => actions.goCat("all"),
  goCatPC: () => actions.goCat("pc-may-tinh-ban"),
  goCatLap: () => actions.goCat("laptop"),
  goContact: () => go({ route: "contact" }, 480, "Đang tải trang liên hệ..."),
  // Tải chi tiết thật từ backend (specs + cfg) rồi mới mở trang
  goDetail: (id) => {
    const p = productById(id);
    state.loading = true;
    state.loadingMsg = "Đang tải chi tiết...";
    Promise.resolve(loadDetail(p))
      .catch(() => {})
      .finally(() => {
        Object.assign(state, {
          route: "detail",
          selId: id,
          cfgSel: defaultSel(p),
          loading: false,
        });
        scrollTop();
      });
  },

  // ===== Đăng nhập =====
  openLogin: () => {
    if (state.route !== "login" && state.route !== "register")
      state.loginPrev = state.route;
    state.route = "login";
    scrollTop();
  },
  closeLogin: () => {
    state.route = state.loginPrev || "home";
    scrollTop();
  },
  openRegister: () => {
    if (state.route !== "login" && state.route !== "register")
      state.loginPrev = state.route;
    state.route = "register";
    scrollTop();
  },
  closeRegister: () => {
    state.route = state.loginPrev || "home";
    scrollTop();
  },
  register: async (payload) => {
    await apiRegister(payload);
  },
  login: async (username, password) => {
    const data = await apiLogin({ username, password });
    state.user = data.user || { email: username };
    state.token = data.token || "";
    localStorage.setItem("token", state.token);
    localStorage.setItem("user", JSON.stringify(state.user));
    state.route = state.loginPrev || "home";
    scrollTop();
    actions.showToast("Đăng nhập thành công");
  },
  logout: () => {
    state.user = null;
    state.token = "";
    localStorage.removeItem("token");
    localStorage.removeItem("user");
    actions.showToast("Đã đăng xuất");
  },

  setTheme: (t) => {
    state.theme = t;
  },
  toggleMode: () => {
    state.mode = state.mode === "light" ? "dark" : "light";
  },
  setCfg: (groupKey, idx) => {
    state.cfgSel = { ...state.cfgSel, [groupKey]: idx };
  },

  showToast: (msg) => {
    state.toast = msg;
    clearTimeout(_toastTimer);
    _toastTimer = setTimeout(() => {
      state.toast = "";
    }, 1900);
  },

  addToCart: (id, sel) => {
    const p = productById(id);
    const useSel = sel || defaultSel(p);
    const key = cfgKey(p, useSel);
    const i = state.cart.findIndex((x) => x.key === key);
    if (i >= 0) state.cart[i].qty += 1;
    else state.cart.push({ key, id, qty: 1, sel: useSel });
    actions.showToast('Đã thêm "' + p.name + '" vào giỏ');
  },
  inc: (key) => {
    const l = state.cart.find((x) => x.key === key);
    if (l) l.qty += 1;
  },
  dec: (key) => {
    const l = state.cart.find((x) => x.key === key);
    if (l) l.qty = Math.max(1, l.qty - 1);
  },
  removeLine: (key) => {
    state.cart = state.cart.filter((x) => x.key !== key);
  },

  placeOrder: () => go({ placed: true }, 950, "Đang xử lý đơn hàng..."),
  resetShop: () =>
    go({ cart: [], placed: false, route: "home" }, 480, "Đang về trang chủ..."),

  setQ: (v) => {
    state.q = v;
  },
  onSearchEnter: () => actions.goCat("all"),
  setSort: (v) => {
    state.sort = v;
  },
  setPriceMax: (v) => {
    state.priceMax = Number(v);
  },
  toggleBrand: (b) => {
    state.brandFilter = state.brandFilter.includes(b)
      ? state.brandFilter.filter((x) => x !== b)
      : state.brandFilter.concat(b);
  },
};

// ===== Shared computeds =====
export const accent = computed(() => accents[state.theme] || "#00e5ff");
export const cartCount = computed(() =>
  state.cart.reduce((a, c) => a + c.qty, 0)
);

export const themeStyle = computed(() => ({
  pageBg:
    state.mode === "light"
      ? "#ffffff"
      : "radial-gradient(1200px 600px at 80% -10%, #0c2c52 0%, #081a2d 55%)",
  ink: state.mode === "light" ? "#0e2236" : "#e8f1fc",
  inkSoft: state.mode === "light" ? "#51657c" : "#cfdceb",
}));

export { products, priceWith };

// ===== Nạp catalog từ backend khi khởi động =====
state.loading = true;
state.loadingMsg = "Đang tải dữ liệu...";
loadCatalog()
  .catch(() => {})
  .finally(() => {
    state.loading = false;
  });
