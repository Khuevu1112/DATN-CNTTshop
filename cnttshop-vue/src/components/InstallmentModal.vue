<script setup>
import { ref, reactive, computed, watch, onMounted } from 'vue';
import { state, actions, accent } from '../store.js';
import { fetchInstallmentConfig, fetchInstallmentQuote, registerInstallment } from '../api.js';
import { fmt } from '../data/products.js';

// Modal "Mua trả góp" ở trang chi tiết sản phẩm — nối vào logic trả góp ĐÃ CÓ sẵn ở backend
// (InstallmentApiController: /config, /quote công khai; đăng ký cần đăng nhập). Component này
// không phát minh nghiệp vụ mới, chỉ là giao diện cho luồng: chọn kỳ hạn -> xem thử khoản trả
// hàng tháng (giá lấy thật từ DB, không tin số client) -> điền hồ sơ -> đăng ký.
const props = defineProps({
  productId: { type: Number, required: true },
  variantId: { type: Number, required: true },
  tenSanPham: { type: String, default: '' },
  // Giá hiện tại của biến thể đang chọn — CHỈ để ước lượng trả trước tối thiểu ban đầu (tránh
  // gọi /quote với trả trước = 0 sẽ luôn bị từ chối "chưa đạt tối thiểu"). Số thật vẫn luôn lấy
  // từ server qua /quote, giá client gửi không được tin dùng cho tính tiền.
  gia: { type: Number, default: 0 },
});
const emit = defineEmits(['close']);

const config = ref(null);
const soThangChon = ref(null);
const traTruoc = ref(0);
const quote = ref(null);
const dangTaiQuote = ref(false);
const dangDangKy = ref(false);
const loi = ref('');
const ketQua = ref(null); // DonCuaToiDto sau khi đăng ký thành công

const form = reactive({
  tenKhach: state.user?.fullName || '',
  soDienThoai: state.user?.phone || '',
  email: state.user?.email || '',
  diaChi: '',
  soCccd: '',
});

async function taiQuote() {
  if (!soThangChon.value) return;
  dangTaiQuote.value = true;
  loi.value = '';
  try {
    quote.value = await fetchInstallmentQuote(props.variantId, soThangChon.value, 1, traTruoc.value);
  } catch (e) {
    loi.value = e?.message || 'Không tính được khoản trả góp.';
    quote.value = null;
  } finally {
    dangTaiQuote.value = false;
  }
}

watch([soThangChon, traTruoc], taiQuote);

function chonKyHan(k) {
  soThangChon.value = k.soThang;
}

async function dangKy() {
  loi.value = '';
  if (!state.user) {
    actions.openLogin();
    return;
  }
  if (!form.tenKhach.trim() || !form.soDienThoai.trim() || !form.diaChi.trim() || !form.soCccd.trim()) {
    loi.value = 'Vui lòng điền đầy đủ họ tên, số điện thoại, địa chỉ và số CCCD/CMND.';
    return;
  }
  dangDangKy.value = true;
  try {
    ketQua.value = await registerInstallment({
      productId: props.productId,
      variantId: props.variantId,
      soLuong: 1,
      soThang: soThangChon.value,
      traTruoc: traTruoc.value,
      tenKhach: form.tenKhach.trim(),
      soDienThoai: form.soDienThoai.trim(),
      email: form.email.trim() || null,
      diaChi: form.diaChi.trim(),
      soCccd: form.soCccd.trim(),
    });
    actions.showToast('Đã gửi hồ sơ đăng ký trả góp!');
  } catch (e) {
    loi.value = e?.message || 'Đăng ký thất bại, vui lòng thử lại.';
  } finally {
    dangDangKy.value = false;
  }
}

onMounted(async () => {
  try {
    config.value = await fetchInstallmentConfig();
    if (config.value.kyHan?.length) {
      soThangChon.value = config.value.kyHan[0].soThang;
    }
    // Trả trước mặc định = giá * tỷ lệ tối thiểu (làm tròn lên) — thiếu bước này thì lần gọi
    // /quote đầu tiên với trả trước = 0 luôn bị backend từ chối "chưa đạt tối thiểu". Server vẫn
    // là nơi tính số thật khi bấm đăng ký, đây chỉ là ước lượng để không hiện lỗi ngay khi mở modal.
    const tyLe = config.value.tyLeTraTruocToiThieu || 0;
    traTruoc.value = Math.ceil((props.gia * tyLe) / 1000) * 1000;
    taiQuote();
  } catch (e) {
    loi.value = 'Không tải được cấu hình trả góp.';
  }
});
</script>

<template>
  <div class="im-backdrop" @click.self="emit('close')">
    <div class="im-box sp-card">
      <template v-if="ketQua">
        <div style="padding: 34px 32px; text-align: center">
          <div style="font-size: 46px; margin-bottom: 14px">✅</div>
          <h2 style="font-family: 'Chakra Petch', sans-serif; font-size: 19px; font-weight: 700; color: var(--text); margin: 0 0 8px">
            Đã gửi hồ sơ trả góp
          </h2>
          <p style="font-size: 13.5px; color: var(--muted2); line-height: 1.6; margin: 0 0 20px">
            CNTTShop sẽ liên hệ xác nhận trong thời gian sớm nhất.
          </p>
          <div style="background: var(--card2); border-radius: 12px; padding: 18px; text-align: left; display: flex; flex-direction: column; gap: 9px">
            <div class="im-kv"><span>Sản phẩm</span><b>{{ ketQua.tenSanPham }}</b></div>
            <div class="im-kv"><span>Kỳ hạn</span><b>{{ ketQua.soThang }} tháng</b></div>
            <div class="im-kv"><span>Trả hàng tháng</span><b :style="{ color: accent }">{{ fmt(ketQua.traHangThang) }}</b></div>
            <div class="im-kv"><span>Trạng thái</span><b>{{ ketQua.nhanTrangThai }}</b></div>
          </div>
          <button class="sp-btn-acc" style="width: 100%; margin-top: 20px" @click="emit('close')">Đóng</button>
        </div>
      </template>

      <template v-else>
        <div class="im-head">
          <div>
            <div class="sp-eyebrow" style="margin-bottom: 6px">MUA TRẢ GÓP</div>
            <div style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 15px; color: var(--text)">
              {{ tenSanPham }}
            </div>
          </div>
          <button class="im-close" @click="emit('close')">✕</button>
        </div>

        <div class="im-body">
          <div v-if="loi" class="sp-alert err">{{ loi }}</div>

          <div>
            <label class="im-label">Kỳ hạn</label>
            <div style="display: flex; gap: 8px; flex-wrap: wrap">
              <button
                v-for="k in config?.kyHan || []"
                :key="k.soThang"
                class="im-plan"
                :class="{ on: soThangChon === k.soThang }"
                @click="chonKyHan(k)"
              >
                {{ k.soThang }} tháng
                <small>{{ Number(k.laiSuat) === 0 ? '0%' : k.laiSuat + '%/năm' }}</small>
              </button>
            </div>
          </div>

          <div v-if="dangTaiQuote" style="font-size: 12.5px; color: var(--muted)">Đang tính…</div>
          <div v-else-if="quote" class="im-quote">
            <div class="im-kv"><span>Giá bán</span><b>{{ fmt(quote.giaBan) }}</b></div>
            <div class="im-kv"><span>Trả trước ({{ Math.round((config?.tyLeTraTruocToiThieu || 0) * 100) }}% tối thiểu)</span><b>{{ fmt(quote.traTruoc) }}</b></div>
            <div class="im-kv"><span>Số tiền vay</span><b>{{ fmt(quote.soTienVay) }}</b></div>
            <div class="im-kv"><span>Trả hàng tháng</span><b :style="{ color: accent }" style="font-size: 15px">{{ fmt(quote.traHangThang) }}</b></div>
            <div class="im-kv"><span>Tổng phải trả</span><b>{{ fmt(quote.tongPhaiTra) }}</b></div>
          </div>

          <template v-if="state.user">
            <div class="im-grid">
              <label><span>Họ và tên *</span><input v-model="form.tenKhach" class="sp-input" /></label>
              <label><span>Số điện thoại *</span><input v-model="form.soDienThoai" class="sp-input" /></label>
            </div>
            <label class="im-fw"><span>Địa chỉ *</span><input v-model="form.diaChi" class="sp-input" /></label>
            <label class="im-fw"><span>Số CCCD/CMND *</span><input v-model="form.soCccd" class="sp-input" /></label>
          </template>
          <div v-else class="sp-alert info" style="margin: 0">
            Đăng nhập để đăng ký hồ sơ trả góp.
            <a href="#" @click.prevent="actions.openLogin()" :style="{ color: accent }">Đăng nhập ngay</a>
          </div>
        </div>

        <div class="im-foot">
          <button class="sp-btn-ghost" style="height: 44px" @click="emit('close')">Huỷ</button>
          <button
            v-if="state.user"
            class="sp-btn-acc"
            style="height: 44px; flex: 1"
            :disabled="dangDangKy || !quote"
            @click="dangKy"
          >
            {{ dangDangKy ? 'Đang gửi…' : 'Đăng ký trả góp →' }}
          </button>
        </div>
      </template>
    </div>
  </div>
</template>

<style scoped>
.im-backdrop {
  position: fixed;
  inset: 0;
  z-index: 3000;
  background: rgba(0, 0, 0, 0.62);
  backdrop-filter: blur(3px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}
.im-box {
  width: 100%;
  max-width: 480px;
  max-height: 92vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.im-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 14px;
  padding: 22px 26px 16px;
  border-bottom: 1px solid rgba(var(--line-rgb), 0.12);
}
.im-close {
  background: transparent;
  border: none;
  color: var(--muted);
  font-size: 17px;
  cursor: pointer;
  padding: 4px 8px;
  line-height: 1;
}
.im-close:hover { color: var(--text); }
.im-body {
  padding: 20px 26px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 15px;
}
.im-foot {
  display: flex;
  gap: 10px;
  padding: 16px 26px 22px;
  border-top: 1px solid rgba(var(--line-rgb), 0.12);
}
.im-label {
  display: block;
  font-size: 11.8px;
  color: var(--muted);
  margin-bottom: 8px;
  font-weight: 500;
}
.im-plan {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3px;
  padding: 9px 16px;
  border-radius: 10px;
  border: 1px solid rgba(var(--line-rgb), 0.2);
  background: var(--card2);
  color: var(--muted2);
  cursor: pointer;
  font-size: 13px;
  font-weight: 600;
  font-family: 'Plus Jakarta Sans', sans-serif;
}
.im-plan small { font-size: 10.5px; font-weight: 500; color: var(--muted); }
.im-plan.on {
  border-color: var(--acc, #c6ff4a);
  background: color-mix(in srgb, var(--acc, #c6ff4a) 12%, transparent);
  color: var(--text);
}
.im-quote {
  background: var(--card2);
  border-radius: 12px;
  padding: 16px 18px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.im-kv {
  display: flex;
  justify-content: space-between;
  gap: 14px;
  font-size: 12.8px;
}
.im-kv span { color: var(--muted); }
.im-kv b { color: var(--text); font-weight: 700; text-align: right; }
.im-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.im-grid label span, .im-fw span {
  display: block;
  font-size: 11.6px;
  color: var(--muted);
  margin-bottom: 6px;
  font-weight: 500;
}
@media (max-width: 480px) {
  .im-grid { grid-template-columns: 1fr; }
}
</style>
