<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue';
import { state, actions, accent } from '../store.js';
import { fetchServiceSlots, bookServiceAppointment, fetchMyWarranties } from '../api.js';
import { LOAI_THIET_BI, tenLoaiThietBi, isoDate, ngayVN } from '../data/supportMeta.js';

const props = defineProps({ center: { type: Object, required: true } });
const emit = defineEmits(['close']);

// Điền sẵn từ tài khoản khi đã đăng nhập. Tên trường khớp AuthDtos.UserDto (fullName/phone),
// không phải tên cột trong CSDL.
const form = reactive({
  hoTen: state.user?.fullName || '',
  dienThoai: state.user?.phone || '',
  email: state.user?.email || '',
  loaiThietBi: '',
  model: '',
  moTaLoi: '',
  ngayHen: isoDate(new Date()),
  khungGio: '',
  warrantyId: '',
});

const khungGio = ref([]);
const dangTaiGio = ref(false);
const dangGui = ref(false);
const loi = ref('');
const ketQua = ref(null);
const phieuBaoHanh = ref([]);

// Chỉ hiện nhóm thiết bị mà TRUNG TÂM NÀY nhận — backend cũng chặn lần nữa, nhưng để khách chọn
// rồi mới báo lỗi là thiết kế tồi.
const loaiHopLe = computed(() => {
  const nhan = props.center.dichVu || [];
  if (!nhan.length) return LOAI_THIET_BI;
  return LOAI_THIET_BI.filter((l) => nhan.includes(l.ma));
});

const ngayToiThieu = isoDate(new Date());
const ngayToiDa = isoDate(new Date(Date.now() + 30 * 86400000));

async function taiKhungGio() {
  if (!form.ngayHen) return;
  dangTaiGio.value = true;
  form.khungGio = '';
  try {
    khungGio.value = await fetchServiceSlots(props.center.id, form.ngayHen);
  } catch (e) {
    khungGio.value = [];
    loi.value = e?.message || 'Không tải được khung giờ trống.';
  } finally {
    dangTaiGio.value = false;
  }
}

watch(() => form.ngayHen, taiKhungGio);

async function gui() {
  loi.value = '';
  if (!form.hoTen.trim() || !form.dienThoai.trim()) {
    loi.value = 'Nhập họ tên và số điện thoại để kỹ thuật gọi xác nhận.';
    return;
  }
  if (!form.loaiThietBi) {
    loi.value = 'Chọn loại thiết bị.';
    return;
  }
  if (!form.moTaLoi.trim()) {
    loi.value = 'Mô tả tình trạng máy để kỹ thuật chuẩn bị linh kiện trước.';
    return;
  }
  if (!form.khungGio) {
    loi.value = 'Chọn khung giờ hẹn.';
    return;
  }

  dangGui.value = true;
  try {
    ketQua.value = await bookServiceAppointment({
      centerId: props.center.id,
      hoTen: form.hoTen.trim(),
      dienThoai: form.dienThoai.trim(),
      email: form.email.trim() || null,
      loaiThietBi: form.loaiThietBi,
      model: form.model.trim() || null,
      moTaLoi: form.moTaLoi.trim(),
      ngayHen: form.ngayHen,
      khungGio: form.khungGio,
      warrantyId: form.warrantyId || null,
    });
    actions.showToast('Đã đặt lịch hẹn thành công!');
  } catch (e) {
    loi.value = e?.message || 'Đặt lịch thất bại, vui lòng thử lại.';
    // Khung giờ vừa bị người khác chiếm là lỗi hay gặp nhất -> nạp lại ngay để khách chọn giờ
    // khác mà không phải tự bấm lại.
    taiKhungGio();
  } finally {
    dangGui.value = false;
  }
}

function sao(text) {
  navigator.clipboard?.writeText(text);
  actions.showToast('Đã sao chép mã lịch hẹn');
}

onMounted(() => {
  taiKhungGio();
  // Gắn phiếu bảo hành là tuỳ chọn và chỉ có nghĩa khi đã đăng nhập — backend từ chối phiếu
  // không thuộc về người gọi.
  if (state.user) {
    fetchMyWarranties()
      .then((ds) => (phieuBaoHanh.value = ds.filter((w) => w.status === 'active')))
      .catch(() => (phieuBaoHanh.value = []));
  }
});
</script>

<template>
  <div class="am-backdrop" @click.self="emit('close')">
    <div class="am-box sp-card">
      <!-- ===== Đã đặt xong ===== -->
      <template v-if="ketQua">
        <div style="padding: 34px 32px; text-align: center">
          <div style="font-size: 46px; margin-bottom: 14px">✅</div>
          <h2
            style="
              font-family: 'Chakra Petch', sans-serif;
              font-size: 20px;
              font-weight: 700;
              color: var(--text);
              margin: 0 0 8px;
            "
          >
            Đã đặt lịch thành công
          </h2>
          <p style="font-size: 13.5px; color: var(--muted2); line-height: 1.6; margin: 0 0 22px">
            Kỹ thuật sẽ gọi vào số {{ ketQua.dienThoai }} để xác nhận trước giờ hẹn.
          </p>

          <div
            style="
              background: var(--card2);
              border-radius: 12px;
              padding: 18px;
              margin-bottom: 20px;
            "
          >
            <div style="font-size: 11.5px; color: var(--muted); margin-bottom: 6px">
              MÃ LỊCH HẸN — dùng để tra cứu lại
            </div>
            <div
              style="
                font-family: 'Chakra Petch', sans-serif;
                font-weight: 700;
                font-size: 26px;
                letter-spacing: 2px;
              "
              :style="{ color: accent }"
            >
              {{ ketQua.maLich }}
            </div>
            <button class="sp-btn-ghost" style="height: 34px; margin-top: 12px" @click="sao(ketQua.maLich)">
              Sao chép mã
            </button>
          </div>

          <div style="text-align: left; display: flex; flex-direction: column; gap: 9px; margin-bottom: 22px">
            <div class="am-kv"><span>Trung tâm</span><b>{{ ketQua.tenTrungTam }}</b></div>
            <div class="am-kv"><span>Địa chỉ</span><b>{{ ketQua.diaChiTrungTam }}</b></div>
            <div class="am-kv"><span>Thời gian</span><b>{{ ngayVN(ketQua.ngayHen) }} · {{ ketQua.khungGio }}</b></div>
            <div class="am-kv"><span>Thiết bị</span><b>{{ tenLoaiThietBi(ketQua.loaiThietBi) }}</b></div>
            <div class="am-kv"><span>Trạng thái</span><b>{{ ketQua.nhanTrangThai }}</b></div>
          </div>

          <div class="sp-alert info" style="text-align: left">
            Mang theo máy, phụ kiện đi kèm và hoá đơn (nếu còn bảo hành). Tới muộn quá 30 phút,
            lịch có thể được nhả cho khách khác.
          </div>

          <div style="display: flex; gap: 10px">
            <button class="sp-btn-ghost" style="flex: 1; height: 42px" @click="actions.goAppointments()">
              Xem lịch hẹn
            </button>
            <button class="sp-btn-acc" style="flex: 1" @click="emit('close')">Đóng</button>
          </div>
        </div>
      </template>

      <!-- ===== Form đặt lịch ===== -->
      <template v-else>
        <div class="am-head">
          <div>
            <div class="sp-eyebrow" style="margin-bottom: 6px">ĐẶT LỊCH DỊCH VỤ</div>
            <div
              style="
                font-family: 'Chakra Petch', sans-serif;
                font-weight: 700;
                font-size: 16px;
                color: var(--text);
              "
            >
              {{ center.ten }}
            </div>
            <div style="font-size: 12.3px; color: var(--muted); margin-top: 4px">
              {{ center.diaChi }}
            </div>
          </div>
          <button class="am-close" @click="emit('close')">✕</button>
        </div>

        <div class="am-body">
          <div v-if="loi" class="sp-alert err">{{ loi }}</div>

          <div class="am-grid">
            <div>
              <label class="am-label">Họ và tên *</label>
              <input v-model="form.hoTen" class="sp-input" placeholder="Nguyễn Văn A" />
            </div>
            <div>
              <label class="am-label">Số điện thoại *</label>
              <input v-model="form.dienThoai" class="sp-input" placeholder="09xx xxx xxx" />
            </div>
          </div>

          <div>
            <label class="am-label">Email (để nhận nhắc lịch)</label>
            <input v-model="form.email" type="email" class="sp-input" placeholder="ban@email.com" />
          </div>

          <div class="am-grid">
            <div>
              <label class="am-label">Loại thiết bị *</label>
              <select v-model="form.loaiThietBi" class="sp-select">
                <option value="">— Chọn loại —</option>
                <option v-for="l in loaiHopLe" :key="l.ma" :value="l.ma">{{ l.icon }} {{ l.ten }}</option>
              </select>
            </div>
            <div>
              <label class="am-label">Model / cấu hình</label>
              <input v-model="form.model" class="sp-input" placeholder="vd: Dell XPS 15 9520" />
            </div>
          </div>

          <div v-if="phieuBaoHanh.length">
            <label class="am-label">Phiếu bảo hành (nếu máy còn hạn)</label>
            <select v-model="form.warrantyId" class="sp-select">
              <option value="">— Không gắn phiếu / máy mua nơi khác —</option>
              <option v-for="w in phieuBaoHanh" :key="w.id" :value="w.id">
                {{ w.productName }} — hết hạn {{ ngayVN(w.endDate) }}
              </option>
            </select>
            <div style="font-size: 11.5px; color: var(--muted); margin-top: 6px">
              Gắn phiếu để kỹ thuật biết trước đây là ca bảo hành miễn phí.
            </div>
          </div>

          <div>
            <label class="am-label">Mô tả tình trạng máy *</label>
            <textarea
              v-model="form.moTaLoi"
              class="sp-textarea"
              rows="3"
              placeholder="vd: máy sập nguồn đột ngột khi chơi game, quạt kêu to khoảng 2 tuần nay…"
            ></textarea>
          </div>

          <div>
            <label class="am-label">Ngày hẹn *</label>
            <input
              v-model="form.ngayHen"
              type="date"
              class="sp-input"
              :min="ngayToiThieu"
              :max="ngayToiDa"
            />
          </div>

          <div>
            <label class="am-label">Khung giờ *</label>
            <div v-if="dangTaiGio" style="font-size: 13px; color: var(--muted); padding: 8px 0">
              Đang tải khung giờ trống…
            </div>
            <div v-else-if="!khungGio.length" class="sp-alert info" style="margin: 0">
              Không có khung giờ nào cho ngày này.
            </div>
            <div v-else class="am-slots">
              <button
                v-for="k in khungGio"
                :key="k.khungGio"
                class="am-slot"
                :class="{ active: form.khungGio === k.khungGio, het: !k.conTrong }"
                :disabled="!k.conTrong"
                @click="form.khungGio = k.khungGio"
              >
                {{ k.khungGio }}
              </button>
            </div>
            <div style="font-size: 11.5px; color: var(--muted); margin-top: 8px">
              Ô mờ là khung giờ đã có người đặt hoặc đã trôi qua trong hôm nay.
            </div>
          </div>
        </div>

        <div class="am-foot">
          <button class="sp-btn-ghost" style="height: 44px" @click="emit('close')">Huỷ</button>
          <button class="sp-btn-acc" style="height: 44px; flex: 1" :disabled="dangGui" @click="gui">
            {{ dangGui ? 'Đang gửi…' : 'Xác nhận đặt lịch →' }}
          </button>
        </div>
      </template>
    </div>
  </div>
</template>

<style scoped>
.am-backdrop {
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

.am-box {
  width: 100%;
  max-width: 580px;
  max-height: 92vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.am-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 14px;
  padding: 22px 26px 18px;
  border-bottom: 1px solid rgba(var(--line-rgb), 0.12);
}

.am-close {
  background: transparent;
  border: none;
  color: var(--muted);
  font-size: 17px;
  cursor: pointer;
  padding: 4px 8px;
  line-height: 1;
}
.am-close:hover {
  color: var(--text);
}

.am-body {
  padding: 20px 26px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.am-foot {
  display: flex;
  gap: 10px;
  padding: 16px 26px 22px;
  border-top: 1px solid rgba(var(--line-rgb), 0.12);
}

.am-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.am-label {
  display: block;
  font-size: 11.8px;
  color: var(--muted);
  margin-bottom: 6px;
  font-weight: 500;
}

.am-slots {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
  gap: 8px;
}

.am-slot {
  height: 38px;
  background: var(--card2);
  border: 1px solid rgba(var(--line-rgb), 0.18);
  border-radius: 9px;
  color: var(--text);
  font-size: 12.8px;
  font-family: 'Plus Jakarta Sans', sans-serif;
  cursor: pointer;
  transition: all 0.14s;
}
.am-slot:hover:not(:disabled) {
  border-color: var(--acc, #c6ff4a);
}
.am-slot.active {
  background: var(--acc, #c6ff4a);
  border-color: var(--acc, #c6ff4a);
  color: var(--acc-ink);
  font-weight: 700;
}
.am-slot.het {
  opacity: 0.34;
  cursor: not-allowed;
  text-decoration: line-through;
}

.am-kv {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  font-size: 12.8px;
}
.am-kv span {
  color: var(--muted);
  flex: none;
}
.am-kv b {
  color: var(--text);
  font-weight: 600;
  text-align: right;
}

@media (max-width: 560px) {
  .am-grid {
    grid-template-columns: 1fr;
  }
}
</style>
