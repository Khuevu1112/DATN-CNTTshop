<template>
  <div
    @click="handleBackdropClick"
    style="position: fixed; inset: 0; background: rgba(2, 8, 18, 0.6); backdrop-filter: blur(2px); z-index: 70; display: flex; align-items: center; justify-content: center; padding: 24px"
  >
    <div
      @click.stop
      style="width: 100%; max-width: 1180px; max-height: 90vh; background: var(--bg); border: 1px solid var(--line2); border-radius: 16px; display: flex; flex-direction: column; box-shadow: 0 20px 60px rgba(0, 0, 0, 0.45)"
    >
      <div style="display: flex; align-items: center; justify-content: space-between; padding: 18px 22px; border-bottom: 1px solid var(--line); flex: none">
        <div style="font-size: 15px; font-weight: 700; color: var(--text)">Thêm tài khoản nhân viên</div>
        <button @click="$emit('close')" style="width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--line2); background: var(--card); color: var(--text); cursor: pointer">
          <i class="bi bi-x-lg" style="font-size: 13px"></i>
        </button>
      </div>

      <!-- ===== Phase 1: nhập thông tin ===== -->
      <template v-if="phase === 'form'">
        <div style="flex: 1; overflow-y: auto; padding: 6px 22px 20px; display: grid; grid-template-columns: 300px 1fr; gap: 20px; align-items: start">
          <div style="min-width: 0">
            <label class="lbl">Họ tên *</label>
            <input class="fld" v-model="form.hoTen" placeholder="VD: Nguyễn Văn A" />

            <label class="lbl">Email *</label>
            <input class="fld" type="email" v-model="form.email" placeholder="ten@cnttshop.vn" />

            <label class="lbl">Số điện thoại *</label>
            <input class="fld" v-model="form.soDienThoai" placeholder="VD: 0987654321" />

            <label class="lbl">Phòng ban *</label>
            <select class="fld" v-model="form.phongBan">
              <option value="" disabled>-- Chọn phòng ban --</option>
              <option v-for="[key, deptMeta] in departments" :key="key" :value="key">{{ deptMeta.label }}</option>
            </select>

            <label class="lbl">Ghi chú</label>
            <textarea class="fld" v-model="form.ghiChu" rows="3" placeholder="Không bắt buộc — VD: ngày thử việc, ghi chú nội bộ..." style="padding: 10px 14px; resize: vertical"></textarea>

            <div style="font-size: 11px; color: var(--muted); margin-top: 10px; line-height: 1.5">
              <i class="bi bi-info-circle" style="margin-right: 5px"></i>Mật khẩu ban đầu sẽ được hệ thống tự sinh ngẫu nhiên và hiển thị 1 lần sau khi tạo xong.
            </div>

            <div v-if="error" class="alert-err" style="margin-top: 12px">{{ error }}</div>
          </div>

          <!-- Xem trước quyền của phòng ban đã chọn (chỉ xem, không sửa ở đây) -->
          <div style="min-width: 0; background: var(--card); border: 1px solid var(--line); border-radius: 12px; overflow: hidden">
            <div style="padding: 10px 14px; border-bottom: 1px solid var(--line); font-size: 11.5px; color: var(--muted); line-height: 1.5">
              <template v-if="form.phongBan">
                Xem trước quyền của <strong style="color: var(--text)">{{ RM[form.phongBan]?.label }}</strong> — sửa quyền chung cho cả phòng ban tại trang <strong style="color: var(--text)">Phân quyền</strong>.
              </template>
              <template v-else>Chọn phòng ban để xem trước các quyền được cấp.</template>
            </div>

            <div v-if="!form.phongBan" style="padding: 30px; text-align: center; color: var(--muted); font-size: 12.5px">
              <i class="bi bi-shield-lock" style="font-size: 20px; opacity: .5"></i>
            </div>
            <div v-else-if="loadingMeta" class="spin" style="margin: 24px auto"></div>
            <table v-else style="border-collapse: collapse; font-size: 11.5px; width: 100%; table-layout: fixed">
              <colgroup>
                <col style="width: 172px" />
                <col v-for="pt in meta.permissionTypes" :key="pt.key" />
              </colgroup>
              <thead>
                <tr style="background: var(--card2)">
                  <th style="text-align: left; padding: 7px 10px; font-size: 10px; font-weight: 600; color: var(--muted); text-transform: uppercase; letter-spacing: .3px">
                    Trang
                  </th>
                  <th
                    v-for="pt in meta.permissionTypes"
                    :key="pt.key"
                    style="padding: 7px 4px; font-size: 9.5px; font-weight: 600; color: var(--muted); text-align: center; line-height: 1.3; word-break: break-word"
                  >
                    {{ pt.label }}
                  </th>
                </tr>
              </thead>
              <tbody>
                <template v-for="grp in groupedFeatures" :key="grp.groupLabel">
                  <tr>
                    <td :colspan="meta.permissionTypes.length + 1" style="padding: 7px 10px 3px; font-size: 10px; font-weight: 700; color: var(--acc); text-transform: uppercase; letter-spacing: .3px; border-top: 1px solid var(--line)">
                      {{ grp.groupLabel }}
                    </td>
                  </tr>
                  <tr v-for="f in grp.features" :key="f.key" style="border-top: 1px solid var(--line)">
                    <td style="padding: 6px 10px; color: var(--text); word-break: break-word">{{ f.label }}</td>
                    <td v-for="pt in meta.permissionTypes" :key="pt.key" style="text-align: center; padding: 6px 4px">
                      <span
                        v-if="cellHasPerm(f.key, pt.key)"
                        :title="pt.label"
                        :style="{ background: pt.color }"
                        style="display: inline-flex; align-items: center; justify-content: center; width: 20px; height: 20px; border-radius: 6px"
                      >
                        <i class="bi bi-check-lg" style="color: #fff; font-size: 13px; font-weight: 700"></i>
                      </span>
                      <span
                        v-else
                        style="display: inline-block; width: 20px; height: 20px; border-radius: 6px; border: 1px solid var(--line2); background: var(--card2)"
                      ></span>
                    </td>
                  </tr>
                </template>
              </tbody>
            </table>
          </div>
        </div>

        <div style="display: flex; justify-content: flex-end; gap: 10px; padding: 16px 22px; border-top: 1px solid var(--line); flex: none">
          <button @click="$emit('close')" class="btn-ghost">Huỷ</button>
          <button
            @click="submit"
            :disabled="saving"
            :style="{ opacity: saving ? 0.6 : 1 }"
            style="height: 42px; padding: 0 22px; border-radius: 10px; border: none; background: var(--acc); color: var(--acc-ink); font-weight: 700; font-size: 13px; cursor: pointer"
          >
            {{ saving ? 'Đang tạo...' : 'Tạo tài khoản' }}
          </button>
        </div>
      </template>

      <!-- ===== Phase 2: đã tạo xong, hiện mật khẩu 1 lần ===== -->
      <template v-else>
        <div style="padding: 30px 32px; text-align: center">
          <div style="width: 52px; height: 52px; border-radius: 50%; background: color-mix(in srgb, var(--green) 16%, transparent); display: flex; align-items: center; justify-content: center; margin: 0 auto 14px">
            <i class="bi bi-check-lg" style="color: var(--green); font-size: 24px"></i>
          </div>
          <div style="font-size: 15px; font-weight: 700; color: var(--text); margin-bottom: 4px">Đã tạo tài khoản nhân viên</div>
          <div style="font-size: 12.5px; color: var(--muted); margin-bottom: 20px">{{ createdAccount.email }}</div>

          <div style="font-size: 11px; font-weight: 600; color: var(--muted2); text-transform: uppercase; letter-spacing: .4px; margin-bottom: 8px">Mật khẩu ban đầu</div>
          <div style="display: flex; align-items: center; justify-content: center; gap: 10px; margin-bottom: 10px">
            <div class="mono" style="font-size: 20px; font-weight: 700; letter-spacing: 1.5px; color: var(--acc); background: var(--card2); border: 1px solid var(--line2); border-radius: 10px; padding: 10px 18px">
              {{ createdAccount.generatedPassword }}
            </div>
            <button @click="copyPassword" class="btn-ghost" style="height: 44px">
              <i class="bi" :class="copied ? 'bi-check-lg' : 'bi-clipboard'"></i> {{ copied ? 'Đã copy' : 'Copy' }}
            </button>
          </div>
          <div style="font-size: 11.5px; color: var(--sale); max-width: 420px; margin: 0 auto; line-height: 1.5">
            Hãy gửi mật khẩu này cho nhân viên ngay — sẽ không thể xem lại sau khi đóng cửa sổ này.
          </div>
        </div>

        <div style="display: flex; justify-content: center; padding: 16px 22px; border-top: 1px solid var(--line); flex: none">
          <button
            @click="$emit('close')"
            style="height: 42px; padding: 0 32px; border-radius: 10px; border: none; background: var(--acc); color: var(--acc-ink); font-weight: 700; font-size: 13px; cursor: pointer"
          >
            Xong
          </button>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, computed, onMounted } from 'vue';
import { RM } from '../data/adminData';
import { createStaffAccount, getPermissionMeta, getPermissionMatrix } from '../api/admin';

const emit = defineEmits(['close', 'saved']);

const phase = ref('form'); // 'form' | 'success'
const form = reactive({ hoTen: '', email: '', soDienThoai: '', ghiChu: '', phongBan: '' });
const saving = ref(false);
const error = ref('');
const departments = computed(() => Object.entries(RM).filter(([k]) => k !== 'customer' && k !== 'admin'));

const createdAccount = ref(null);
const copied = ref(false);
function copyPassword() {
  navigator.clipboard.writeText(createdAccount.value.generatedPassword);
  copied.value = true;
  setTimeout(() => { copied.value = false; }, 1500);
}

// Chỉ đóng khi bấm nền lúc còn ở form nhập — sang phase thành công thì bắt buộc bấm nút rõ ràng
// (X hoặc Xong) để tránh lỡ tay mất mật khẩu chỉ hiện đúng 1 lần.
function handleBackdropClick() {
  if (phase.value === 'form') emit('close');
}

// Ma trận quyền — chỉ để XEM TRƯỚC theo phòng ban đã chọn, không sửa ở form này (sửa tại trang
// Phân quyền, áp dụng cho cả phòng ban chứ không riêng 1 tài khoản).
const loadingMeta = ref(true);
const meta = ref({ features: [], permissionTypes: [], departments: [] });
const matrix = ref([]);

const groupedFeatures = computed(() => {
  const groups = [];
  const byLabel = new Map();
  for (const f of meta.value.features) {
    if (!byLabel.has(f.groupLabel)) {
      const g = { groupLabel: f.groupLabel, features: [] };
      byLabel.set(f.groupLabel, g);
      groups.push(g);
    }
    byLabel.get(f.groupLabel).features.push(f);
  }
  return groups;
});

const deptCellMap = computed(() => {
  const map = {};
  for (const row of matrix.value) {
    if (row.department === form.phongBan) map[row.featureKey] = row.permKeys;
  }
  return map;
});
function cellHasPerm(featureKey, permKey) {
  return (deptCellMap.value[featureKey] || []).includes(permKey);
}

onMounted(async () => {
  try {
    const [metaData, matrixData] = await Promise.all([getPermissionMeta(), getPermissionMatrix()]);
    meta.value = metaData;
    matrix.value = matrixData;
  } finally {
    loadingMeta.value = false;
  }
});

async function submit() {
  error.value = '';
  if (!form.hoTen.trim() || !form.email.trim() || !form.soDienThoai.trim() || !form.phongBan) {
    error.value = 'Vui lòng nhập đủ họ tên, email, số điện thoại và chọn phòng ban';
    return;
  }
  saving.value = true;
  try {
    const res = await createStaffAccount({
      hoTen: form.hoTen.trim(),
      email: form.email.trim(),
      soDienThoai: form.soDienThoai.trim(),
      ghiChu: form.ghiChu.trim(),
      phongBan: form.phongBan,
    });
    createdAccount.value = { email: res.email, generatedPassword: res.generatedPassword };
    phase.value = 'success';
    emit('saved');
  } catch (e) {
    error.value = e.response?.data?.message || 'Có lỗi khi tạo tài khoản';
  } finally {
    saving.value = false;
  }
}
</script>

<style scoped>
.lbl {
  display: block;
  font-size: 12px;
  font-weight: 600;
  color: var(--muted2);
  margin: 14px 0 6px;
}
.btn-ghost {
  height: 42px;
  padding: 0 18px;
  border-radius: 10px;
  border: 1px solid var(--line2);
  background: var(--card);
  color: var(--text);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
}
</style>
