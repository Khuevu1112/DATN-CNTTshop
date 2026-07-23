<template>
  <div
    @click="$emit('close')"
    style="position: fixed; inset: 0; background: rgba(2, 8, 18, 0.6); backdrop-filter: blur(2px); z-index: 80; display: flex; align-items: center; justify-content: center; padding: 24px"
  >
    <div
      @click.stop
      style="width: 100%; max-width: 480px; max-height: 90vh; background: var(--bg); border: 1px solid var(--line2); border-radius: 16px; display: flex; flex-direction: column; box-shadow: 0 20px 60px rgba(0, 0, 0, 0.45)"
    >
      <div style="display: flex; align-items: center; justify-content: space-between; padding: 18px 22px; border-bottom: 1px solid var(--line); flex: none">
        <div style="font-size: 15px; font-weight: 700; color: var(--text)">
          <i class="bi bi-lock" style="color: var(--sale); margin-right: 8px"></i>Khoá tài khoản
        </div>
        <button @click="$emit('close')" style="width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--line2); background: var(--card); color: var(--text); cursor: pointer">
          <i class="bi bi-x-lg" style="font-size: 13px"></i>
        </button>
      </div>

      <div style="flex: 1; overflow-y: auto; padding: 6px 22px 20px">
        <label class="lbl">Lý do khoá *</label>
        <textarea class="fld" v-model="form.reason" rows="3" placeholder="VD: Vi phạm điều khoản sử dụng, nghi ngờ gian lận đơn hàng..." style="padding: 10px 14px; resize: vertical"></textarea>

        <label class="lbl">Hạn khoá</label>
        <input class="fld" type="date" v-model="form.lockUntil" :disabled="form.permanent" :min="today" />
        <label style="display: flex; align-items: center; gap: 7px; margin-top: 8px; font-size: 12.5px; color: var(--muted2); cursor: pointer">
          <input type="checkbox" v-model="form.permanent" />
          Khoá vĩnh viễn (không thời hạn)
        </label>

        <label class="lbl">Hình ảnh chứng minh</label>
        <div v-if="evidencePreview" style="position: relative; display: inline-block">
          <img :src="evidencePreview" style="max-width: 100%; max-height: 180px; border-radius: 10px; border: 1px solid var(--line2); display: block" />
          <button
            @click="clearEvidence"
            title="Xoá ảnh"
            style="position: absolute; top: 6px; right: 6px; width: 26px; height: 26px; border-radius: 7px; border: none; background: rgba(2,8,18,.7); color: #fff; cursor: pointer"
          >
            <i class="bi bi-trash3" style="font-size: 12px"></i>
          </button>
        </div>
        <label v-else style="display: flex; align-items: center; justify-content: center; gap: 8px; height: 72px; border: 1px dashed var(--line2); border-radius: 10px; color: var(--muted2); font-size: 12.5px; cursor: pointer">
          <i class="bi bi-upload"></i> Chọn ảnh (không bắt buộc)
          <input type="file" accept="image/*" @change="onPickEvidence" style="display: none" />
        </label>

        <div v-if="error" class="alert-err" style="margin-top: 12px">{{ error }}</div>
      </div>

      <div style="display: flex; justify-content: flex-end; gap: 10px; padding: 16px 22px; border-top: 1px solid var(--line); flex: none">
        <button @click="$emit('close')" class="btn-ghost">Huỷ</button>
        <button
          @click="submit"
          :disabled="saving"
          :style="{ opacity: saving ? 0.6 : 1 }"
          style="height: 42px; padding: 0 22px; border-radius: 10px; border: none; background: var(--sale); color: #fff; font-weight: 700; font-size: 13px; cursor: pointer"
        >
          {{ saving ? 'Đang khoá...' : 'Khoá tài khoản' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, computed } from 'vue';
import { lockCustomer } from '../api/admin';

const props = defineProps({ userId: { type: [Number, String], required: true } });
const emit = defineEmits(['close', 'locked']);

const today = new Date().toISOString().slice(0, 10);
const form = reactive({ reason: '', lockUntil: '', permanent: false });
const evidenceFile = ref(null);
const evidencePreview = ref('');
const saving = ref(false);
const error = ref('');

function onPickEvidence(e) {
  const file = e.target.files[0];
  if (!file) return;
  evidenceFile.value = file;
  evidencePreview.value = URL.createObjectURL(file);
}
function clearEvidence() {
  evidenceFile.value = null;
  evidencePreview.value = '';
}

async function submit() {
  error.value = '';
  if (!form.reason.trim()) {
    error.value = 'Vui lòng nhập lý do khoá';
    return;
  }
  saving.value = true;
  try {
    await lockCustomer(props.userId, {
      reason: form.reason.trim(),
      lockUntil: form.permanent ? '' : form.lockUntil,
      evidence: evidenceFile.value,
    });
    emit('locked');
  } catch (e) {
    error.value = e.response?.data?.message || 'Có lỗi khi khoá tài khoản';
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
