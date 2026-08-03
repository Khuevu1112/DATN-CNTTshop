<script setup>
import { ref, onMounted } from 'vue';
import { state, actions, accent } from '../store.js';
import { fetchMyAppointments, lookupAppointment, cancelAppointment } from '../api.js';
import { tenLoaiThietBi, ngayVN, nhanTrangThaiLich } from '../data/supportMeta.js';

// Hai đường vào: đã đăng nhập -> danh sách lịch của tài khoản; chưa đăng nhập -> tra bằng mã.
// Khách vãng lai ĐẶT được lịch nên cũng phải XEM lại được, nếu không mã lịch thành vô nghĩa.
const danhSach = ref([]);
const dangTai = ref(false);
const maTra = ref('');
const ketQuaTra = ref(null);
const dangTraCuu = ref(false);
const loi = ref('');
const dangHuy = ref(null);

async function tai() {
  if (!state.user) return;
  dangTai.value = true;
  try {
    danhSach.value = await fetchMyAppointments();
  } catch (e) {
    danhSach.value = [];
  } finally {
    dangTai.value = false;
  }
}

async function traCuu() {
  loi.value = '';
  ketQuaTra.value = null;
  if (!maTra.value.trim()) {
    loi.value = 'Nhập mã lịch hẹn (dạng SVxxxxxxxxxx).';
    return;
  }
  dangTraCuu.value = true;
  try {
    ketQuaTra.value = await lookupAppointment(maTra.value.trim());
  } catch (e) {
    loi.value = e?.message || 'Không tìm thấy lịch hẹn với mã này.';
  } finally {
    dangTraCuu.value = false;
  }
}

async function huy(l) {
  if (!confirm(`Huỷ lịch hẹn ${l.maLich} ngày ${ngayVN(l.ngayHen)} lúc ${l.khungGio}?`)) return;
  dangHuy.value = l.id;
  try {
    await cancelAppointment(l.id);
    actions.showToast('Đã huỷ lịch hẹn');
    tai();
  } catch (e) {
    actions.showToast(e?.message || 'Không huỷ được lịch hẹn');
  } finally {
    dangHuy.value = null;
  }
}

const coTheHuy = (l) => ['cho_xac_nhan', 'da_xac_nhan'].includes(l.trangThai);
const meta = (tt) => nhanTrangThaiLich[tt] || { nhan: tt, mau: 'var(--muted2)' };

onMounted(tai);
</script>

<template>
  <main style="max-width: 940px; margin: 0 auto; padding: 24px 24px 72px">
    <button class="sp-back" @click="actions.goSupport()">← Trung tâm hỗ trợ</button>

    <div style="margin-bottom: 28px">
      <div class="sp-eyebrow">LỊCH HẸN DỊCH VỤ</div>
      <h1 class="sp-h1">Lịch hẹn <span :style="{ color: accent }">của bạn</span></h1>
      <p style="font-size: 14.5px; color: var(--muted2); max-width: 600px; line-height: 1.65; margin: 0">
        Theo dõi trạng thái lịch đã đặt, hoặc tra cứu nhanh bằng mã lịch hẹn.
      </p>
    </div>

    <!-- Tra cứu bằng mã -->
    <section class="sp-card" style="padding: 24px 26px; margin-bottom: 28px">
      <h2 class="sp-h2">Tra cứu bằng mã lịch hẹn</h2>
      <form @submit.prevent="traCuu" style="display: flex; gap: 11px; flex-wrap: wrap">
        <input
          v-model="maTra"
          class="sp-input"
          style="flex: 1; min-width: 220px; height: 44px; text-transform: uppercase"
          placeholder="vd: SV250724ABCD"
        />
        <button type="submit" class="sp-btn-acc" style="height: 44px; padding: 0 26px" :disabled="dangTraCuu">
          {{ dangTraCuu ? 'Đang tra…' : 'Tra cứu' }}
        </button>
      </form>
      <div v-if="loi" class="sp-alert err" style="margin: 14px 0 0">{{ loi }}</div>

      <div
        v-if="ketQuaTra"
        style="
          margin-top: 18px;
          background: var(--card2);
          border-radius: 12px;
          padding: 20px 22px;
          border: 1px solid rgba(var(--line-rgb), 0.12);
        "
      >
        <div
          style="
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 14px;
          "
        >
          <div
            style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 16px"
            :style="{ color: accent }"
          >
            {{ ketQuaTra.maLich }}
          </div>
          <span class="sp-pill" :style="{ color: meta(ketQuaTra.trangThai).mau }">
            {{ ketQuaTra.nhanTrangThai }}
          </span>
        </div>
        <div class="ap-kv"><span>Trung tâm</span><b>{{ ketQuaTra.tenTrungTam }}</b></div>
        <div class="ap-kv"><span>Địa chỉ</span><b>{{ ketQuaTra.diaChiTrungTam }}</b></div>
        <div class="ap-kv">
          <span>Thời gian</span><b>{{ ngayVN(ketQuaTra.ngayHen) }} · {{ ketQuaTra.khungGio }}</b>
        </div>
        <div class="ap-kv"><span>Người hẹn</span><b>{{ ketQuaTra.hoTen }} · {{ ketQuaTra.dienThoai }}</b></div>
        <div class="ap-kv"><span>Thiết bị</span><b>{{ tenLoaiThietBi(ketQuaTra.loaiThietBi) }}</b></div>
        <div v-if="ketQuaTra.ghiChuKtv" class="ap-kv"><span>Ghi chú</span><b>{{ ketQuaTra.ghiChuKtv }}</b></div>
        <div style="font-size: 11.5px; color: var(--muted); margin-top: 12px; line-height: 1.55">
          Số điện thoại được che bớt khi tra bằng mã. Đăng nhập bằng tài khoản đã đặt lịch để xem
          đầy đủ và huỷ lịch.
        </div>
      </div>
    </section>

    <!-- Danh sách của tài khoản -->
    <section>
      <h2 class="sp-h2">Lịch hẹn trong tài khoản</h2>

      <div v-if="!state.user" class="sp-card sp-empty">
        Đăng nhập để xem toàn bộ lịch hẹn đã đặt bằng tài khoản của bạn.<br />
        <button class="sp-btn-acc" style="margin-top: 16px" @click="actions.openLogin()">
          Đăng nhập
        </button>
      </div>

      <div v-else-if="dangTai" class="sp-card sp-empty">Đang tải…</div>

      <div v-else-if="!danhSach.length" class="sp-card sp-empty">
        Bạn chưa đặt lịch hẹn dịch vụ nào.<br />
        <button class="sp-btn-acc" style="margin-top: 16px" @click="actions.goServiceCenters()">
          Tìm trung tâm & đặt lịch
        </button>
      </div>

      <div v-else style="display: flex; flex-direction: column; gap: 13px">
        <div v-for="l in danhSach" :key="l.id" class="sp-card" style="padding: 20px 22px">
          <div
            style="
              display: flex;
              align-items: flex-start;
              justify-content: space-between;
              gap: 14px;
              flex-wrap: wrap;
              margin-bottom: 14px;
            "
          >
            <div>
              <div
                style="font-family: 'Chakra Petch', sans-serif; font-weight: 700; font-size: 15px"
                :style="{ color: accent }"
              >
                {{ l.maLich }}
              </div>
              <div style="font-size: 12.3px; color: var(--muted); margin-top: 4px">
                Đặt lúc {{ new Date(l.createdAt).toLocaleString('vi-VN') }}
              </div>
            </div>
            <span class="sp-pill" :style="{ color: meta(l.trangThai).mau }">{{ l.nhanTrangThai }}</span>
          </div>

          <div class="ap-kv"><span>Trung tâm</span><b>{{ l.tenTrungTam }}</b></div>
          <div class="ap-kv"><span>Địa chỉ</span><b>{{ l.diaChiTrungTam }}</b></div>
          <div class="ap-kv"><span>Thời gian</span><b>{{ ngayVN(l.ngayHen) }} · {{ l.khungGio }}</b></div>
          <div class="ap-kv">
            <span>Thiết bị</span>
            <b>{{ tenLoaiThietBi(l.loaiThietBi) }}<template v-if="l.model"> · {{ l.model }}</template></b>
          </div>
          <div class="ap-kv"><span>Tình trạng</span><b>{{ l.moTaLoi }}</b></div>
          <div v-if="l.warrantyId" class="ap-kv">
            <span>Bảo hành</span><b style="color: var(--green)">Có gắn phiếu bảo hành</b>
          </div>
          <div v-if="l.ghiChuKtv" class="ap-kv"><span>Ghi chú KTV</span><b>{{ l.ghiChuKtv }}</b></div>

          <div style="display: flex; gap: 10px; margin-top: 16px; flex-wrap: wrap">
            <button
              v-if="coTheHuy(l)"
              class="sp-btn-ghost"
              :disabled="dangHuy === l.id"
              @click="huy(l)"
            >
              {{ dangHuy === l.id ? 'Đang huỷ…' : 'Huỷ lịch hẹn' }}
            </button>
            <button class="sp-btn-ghost" @click="actions.goServiceCenters()">Đặt lịch mới</button>
          </div>
        </div>
      </div>
    </section>

    <!-- Lịch sử bảo hành đã chuyển sang trang "Quản lý bảo hành cá nhân". -->
    <div v-if="state.user" style="margin-top: 22px; font-size: 12.8px; color: var(--muted)">
      Tìm lịch sử các lần sửa chữa/bảo hành đã hoàn thành tại
      <a href="#" @click.prevent="actions.goWarranty()" :style="{ color: accent }">Quản lý bảo hành cá nhân →</a>
    </div>
  </main>
</template>

<style scoped>
.ap-kv {
  display: flex;
  gap: 16px;
  font-size: 12.9px;
  padding: 6px 0;
  align-items: flex-start;
}
.ap-kv span {
  color: var(--muted);
  flex: none;
  width: 108px;
}
.ap-kv b {
  color: var(--text);
  font-weight: 600;
  flex: 1;
  line-height: 1.5;
}
</style>
