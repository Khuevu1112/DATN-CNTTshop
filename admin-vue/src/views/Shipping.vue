<template>
  <div style="animation: fadeUp 0.35s ease; display: flex; flex-direction: column; gap: 14px">
    <!-- Phí nội thành Hải Phòng -->
    <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 18px">
      <div style="font-size: 14.5px; font-weight: 600; color: var(--text); margin-bottom: 4px; display: flex; align-items: center; gap: 8px">
        <i class="bi bi-geo-alt-fill" style="color: var(--acc)"></i> Phí giao nội thành Hải Phòng
      </div>
      <div style="font-size: 12px; color: var(--muted); margin-bottom: 16px; line-height: 1.6">
        Mốc tính: <b style="color: var(--muted2)">118 Cát Bi, Phường Hải An, Hải Phòng</b>. Đơn nội thành tính phí theo
        <b style="color: var(--muted2)">quãng đường thực tế</b> từ kho tới điểm khách cắm trên bản đồ — bảng phí phẳng
        bên dưới chỉ là phương án dự phòng cho địa chỉ chưa có toạ độ.
      </div>

      <!-- A. Cách tính CHÍNH: luỹ tiến theo km (hằng số trong ShippingService, không sửa ở đây) -->
      <div style="background: var(--card2); border-radius: 11px; padding: 15px 16px; margin-bottom: 18px">
        <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 12px">
          <span style="font-size: 13px; font-weight: 600; color: var(--text)">Cách tính chính — luỹ tiến theo quãng đường</span>
          <span style="font-size: 10px; font-weight: 700; color: var(--amber); background: color-mix(in srgb, var(--amber) 16%, transparent); padding: 2px 8px; border-radius: 20px">CHỈ ĐỌC</span>
          <div style="flex: 1"></div>
          <span class="mono" style="font-size: 11px; color: var(--muted)">Sửa trong mã nguồn: ShippingService</span>
        </div>

        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 12px">
          <div v-for="b in KM_BRACKETS" :key="b.range" style="background: var(--card); border: 1px solid var(--line2); border-radius: 9px; padding: 11px 13px">
            <div style="font-size: 11.5px; color: var(--muted)">{{ b.range }}</div>
            <div class="mono" style="font-size: 17px; font-weight: 700; color: var(--text); margin-top: 3px">
              {{ b.price }}<span style="font-size: 11.5px; font-weight: 500; color: var(--muted)">/km</span>
            </div>
          </div>
        </div>

        <div style="font-size: 11.5px; color: var(--muted2); line-height: 1.7">
          Luỹ tiến như bậc thuế — mỗi km chỉ tính theo đơn giá của vòng chứa chính km đó.
          VD 15km = 10km đầu × 250 + 5km sau × 500 = <b style="color: var(--text)">5.000đ</b>, không phải 15 × 500.
        </div>
        <div style="display: flex; gap: 16px; flex-wrap: wrap; margin-top: 9px">
          <span v-for="e in KM_EXAMPLES" :key="e.km" class="mono" style="font-size: 11.5px; color: var(--muted)">
            {{ e.km }} → <b style="color: var(--text)">{{ e.fee }}</b>
          </span>
        </div>
      </div>

      <!-- B. Phí DỰ PHÒNG (đây mới là phần sửa được ở trang này) -->
      <div style="font-size: 13px; font-weight: 600; color: var(--text); margin-bottom: 4px">
        Phí dự phòng — địa chỉ chưa cắm mốc bản đồ
      </div>
      <div style="font-size: 11.5px; color: var(--muted); margin-bottom: 12px; line-height: 1.6">
        Chỉ dùng khi địa chỉ của khách không có toạ độ (địa chỉ cũ tạo trước tính năng bản đồ, hoặc tạo qua
        trang quản trị Thymeleaf cũ). Đơn đã cắm mốc luôn dùng cách tính theo km ở trên, không đụng tới 2 ô này.
      </div>
      <div v-if="hpLoading" class="spin"></div>
      <div v-else style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px">
        <div v-for="t in hpTiers" :key="t.id" style="background: var(--card2); border-radius: 11px; padding: 14px">
          <div style="font-size: 12.5px; color: var(--muted); margin-bottom: 8px">{{ t.label }}</div>
          <div style="display: flex; gap: 8px">
            <input
              v-model.number="t.fee" type="number"
              style="flex: 1; height: 38px; padding: 0 12px; border-radius: 8px; background: var(--card); border: 1px solid var(--line2); color: var(--text); font-size: 13px"
            />
            <button
              @click="saveHpTier(t)" :disabled="savingHpTierId === t.id"
              style="height: 38px; padding: 0 14px; border-radius: 8px; border: none; background: var(--acc); color: var(--acc-ink); font-weight: 700; font-size: 12.5px; cursor: pointer"
            >
              {{ savingHpTierId === t.id ? '...' : 'Lưu' }}
            </button>
          </div>
        </div>
      </div>

      <!-- Những thứ tác động lên phí cuối cùng mà trang này không quyết định -->
      <div style="margin-top: 16px; padding-top: 13px; border-top: 1px solid var(--line); font-size: 11.5px; color: var(--muted); line-height: 1.8">
        <div><b style="color: var(--muted2)">Hoả tốc</b> = phí thường × 1.3 (làm tròn) — áp cho cả hai cách tính trên.</div>
        <div>
          <b style="color: var(--muted2)">Ưu đãi có thể đưa phí về 0đ:</b>
          hạng thành viên từ Bạc trở lên miễn phí nội thành; gói CNTT Care miễn phí ship nội thành (mọi gói)
          và miễn phí cả hoả tốc (Plus / Pro).
        </div>
      </div>
    </div>

    <!-- Đơn vị vận chuyển ngoài Hải Phòng -->
    <div style="display: grid; grid-template-columns: 340px 1fr; gap: 14px; align-items: start">
      <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 18px">
        <div style="font-size: 14.5px; font-weight: 600; color: var(--text); margin-bottom: 16px; display: flex; align-items: center; gap: 8px">
          <i class="bi bi-truck" style="color: var(--acc)"></i> Thêm đơn vị vận chuyển
        </div>
        <label class="lbl2">Mã (vd: spx)</label>
        <input v-model="form.code" class="fld2 block" />
        <label class="lbl2">Tên hãng</label>
        <input v-model="form.name" class="fld2 block" />
        <label class="lbl2">Phí liên tỉnh/liên miền</label>
        <input v-model.number="form.feeLienTinh" type="number" class="fld2 block" />
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 14px">
          <div>
            <label class="lbl2">Thời gian cùng miền</label>
            <input v-model="form.timeCungMien" placeholder="VD: 1-2 ngày" class="fld2 block" />
          </div>
          <div>
            <label class="lbl2">Thời gian khác miền</label>
            <input v-model="form.timeKhacMien" placeholder="VD: 3-4 ngày" class="fld2 block" />
          </div>
        </div>
        <div v-if="error" style="color: var(--sale); font-size: 12px; margin-bottom: 10px">{{ error }}</div>
        <button
          @click="addCarrierRow" :disabled="saving"
          style="width: 100%; height: 42px; border-radius: 10px; border: none; background: var(--acc); color: var(--acc-ink); font-weight: 700; font-size: 13px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 7px"
        >
          <i class="bi bi-plus-circle"></i> {{ saving ? 'Đang thêm...' : 'Thêm đơn vị' }}
        </button>
      </div>

      <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; overflow: hidden">
        <div style="padding: 14px 18px; font-size: 14.5px; font-weight: 600; color: var(--text); border-bottom: 1px solid var(--line)">
          Danh sách đơn vị vận chuyển ({{ carriers.length }})
        </div>
        <div v-if="carriersLoading" class="spin"></div>
        <DataTable v-else :columns="cols" :rows="carriers" :tim-kiem="ui.search" trong="Chưa có đơn vị vận chuyển nào.">
          <template #o-name="{ row: c }">
            <div class="mono" style="color: var(--acc); font-weight: 700; font-size: 12px">{{ c.code }}</div>
            <div style="color: var(--text); margin-top: 2px">{{ c.name }}</div>
          </template>
          <template #o-feeLienTinh="{ row: c }">
            <input v-model.number="c.feeLienTinh" type="number" class="fld2" style="width: 100px" />
          </template>
          <template #o-timeCungMien="{ row: c }">
            <input v-model="c.timeCungMien" class="fld2" style="width: 90px" />
          </template>
          <template #o-timeKhacMien="{ row: c }">
            <input v-model="c.timeKhacMien" class="fld2" style="width: 90px" />
          </template>
          <template #o-isActive="{ row: c }">
            <input type="checkbox" v-model="c.isActive" style="cursor: pointer" />
          </template>
          <template #o-thaoTac="{ row: c }">
            <span style="white-space: nowrap">
              <button
                @click="saveCarrierRow(c)" :disabled="savingCarrierId === c.id"
                style="height: 30px; padding: 0 10px; border-radius: 8px; border: 1px solid var(--line2); background: var(--card2); color: var(--acc); cursor: pointer; font-size: 11.5px; margin-right: 6px"
              >{{ savingCarrierId === c.id ? '...' : 'Lưu' }}</button>
              <button
                @click="removeCarrier(c)"
                style="width: 30px; height: 30px; border-radius: 8px; border: 1px solid var(--line2); background: var(--card); color: var(--sale); cursor: pointer"
              >
                <i class="bi bi-trash3" style="font-size: 12px"></i>
              </button>
            </span>
          </template>
        </DataTable>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import {
  getHpTiers, updateHpTier, getCarriers, createCarrier, updateCarrier, deleteCarrier,
} from '../api/admin';
import { ui } from '../uiState';
import DataTable from '../components/DataTable.vue';

// Chép lại hằng số bên ShippingService (GIA_VONG_1/2/3, MOC_VONG_1/2_KM) để admin thấy phí nội
// thành thực sự được tính thế nào — phần này CHỈ HIỂN THỊ, không phải nguồn sự thật. Đổi đơn giá
// hay mốc km bên backend thì phải sửa cả ở đây, nếu không trang sẽ mô tả sai giống lần trước.
const KM_BRACKETS = [
  { range: '0 → 10 km', price: '250đ' },
  { range: '10 → 20 km', price: '500đ' },
  { range: 'Trên 20 km', price: '1.000đ' },
];
const KM_EXAMPLES = [
  { km: '5km', fee: '1.250đ' },
  { km: '10km', fee: '2.500đ' },
  { km: '15km', fee: '5.000đ' },
  { km: '20km', fee: '7.500đ' },
  { km: '30km', fee: '17.500đ' },
];

const hpTiers = ref([]);
const hpLoading = ref(true);
const savingHpTierId = ref(null);

const carriers = ref([]);
const carriersLoading = ref(true);
const savingCarrierId = ref(null);
const saving = ref(false);
const error = ref('');

// Cột cho DataTable — phễu lọc/sắp xếp kiểu Excel trên từng cột (xem components/DataTable.vue).
const cols = [
  { key: 'name', label: 'Đơn vị', text: (c) => c.code + ' · ' + c.name },
  { key: 'feeLienTinh', label: 'Phí liên tỉnh', kieu: 'so' },
  { key: 'timeCungMien', label: 'TG cùng miền' },
  { key: 'timeKhacMien', label: 'TG khác miền' },
  { key: 'isActive', label: 'Bật', align: 'center', text: (c) => (c.isActive ? 'Đang bật' : 'Đang tắt') },
  { key: 'thaoTac', label: '', align: 'right', loc: false },
];

const form = ref({ code: '', name: '', feeLienTinh: 20000, timeCungMien: '', timeKhacMien: '' });

async function loadHpTiers() {
  hpLoading.value = true;
  try {
    hpTiers.value = await getHpTiers();
  } finally {
    hpLoading.value = false;
  }
}

async function saveHpTier(t) {
  savingHpTierId.value = t.id;
  try {
    await updateHpTier(t.id, { fee: t.fee });
  } finally {
    savingHpTierId.value = null;
  }
}

async function loadCarriers() {
  carriersLoading.value = true;
  try {
    carriers.value = await getCarriers();
  } finally {
    carriersLoading.value = false;
  }
}

async function addCarrierRow() {
  error.value = '';
  if (!form.value.code.trim() || !form.value.name.trim()) {
    error.value = 'Vui lòng nhập mã và tên hãng';
    return;
  }
  saving.value = true;
  try {
    await createCarrier({ ...form.value });
    await loadCarriers();
    form.value = { code: '', name: '', feeLienTinh: 20000, timeCungMien: '', timeKhacMien: '' };
  } catch (e) {
    error.value = e.response?.data?.message || 'Có lỗi khi thêm đơn vị vận chuyển';
  } finally {
    saving.value = false;
  }
}

async function saveCarrierRow(c) {
  savingCarrierId.value = c.id;
  try {
    await updateCarrier(c.id, {
      name: c.name, feeLienTinh: c.feeLienTinh, timeCungMien: c.timeCungMien,
      timeKhacMien: c.timeKhacMien, isActive: c.isActive,
    });
  } finally {
    savingCarrierId.value = null;
  }
}

async function removeCarrier(c) {
  if (!window.confirm(`Xoá đơn vị "${c.name}"?`)) return;
  await deleteCarrier(c.id);
  await loadCarriers();
}

onMounted(() => {
  loadHpTiers();
  loadCarriers();
});
</script>

<style scoped>
.fld2 {
  height: 36px;
  padding: 0 10px;
  border-radius: 8px;
  background: var(--card2);
  border: 1px solid var(--line2);
  color: var(--text);
  font-size: 12.5px;
}
.block {
  width: 100%;
  display: block;
  margin-bottom: 14px;
}
.lbl2 {
  font-size: 11px;
  font-weight: 600;
  color: var(--muted);
  text-transform: uppercase;
  display: block;
  margin-bottom: 6px;
}
</style>
