<template>
  <div
    @click="$emit('close')"
    style="position: fixed; inset: 0; background: rgba(2, 8, 18, 0.6); backdrop-filter: blur(2px); z-index: 70; display: flex; align-items: center; justify-content: center; padding: 24px"
  >
    <div
      @click.stop
      style="width: 100%; max-width: 620px; max-height: 88vh; background: var(--bg); border: 1px solid var(--line2); border-radius: 16px; display: flex; flex-direction: column; box-shadow: 0 20px 60px rgba(0, 0, 0, 0.45)"
    >
      <div style="display: flex; align-items: center; justify-content: space-between; padding: 18px 22px; border-bottom: 1px solid var(--line); flex: none">
        <div style="font-size: 15px; font-weight: 700; color: var(--text)">Nhập sản phẩm từ Excel</div>
        <button @click="$emit('close')" style="width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--line2); background: var(--card); color: var(--text); cursor: pointer">
          <i class="bi bi-x-lg" style="font-size: 13px"></i>
        </button>
      </div>

      <div style="flex: 1; overflow-y: auto; padding: 20px 22px">
        <!-- Bước 1: tải template -->
        <div style="background: var(--card); border: 1px solid var(--line2); border-radius: 11px; padding: 14px 16px; margin-bottom: 16px">
          <div style="font-size: 13px; font-weight: 600; color: var(--text); margin-bottom: 4px">1. Tải file mẫu</div>
          <div style="font-size: 12px; color: var(--muted); line-height: 1.6; margin-bottom: 10px">
            File mẫu có sẵn cột đúng thứ tự, 1 dòng ví dụ và danh sách tên danh mục hợp lệ (sheet 2) để bạn đối chiếu.
          </div>
          <button class="btn-ghost" :disabled="downloadingTemplate" @click="taiTemplate">
            <i class="bi bi-download" style="margin-right: 6px"></i>
            {{ downloadingTemplate ? 'Đang tải...' : 'Tải file mẫu (.xlsx)' }}
          </button>
        </div>

        <!-- Bước 2: chọn file & nhập -->
        <div style="background: var(--card); border: 1px solid var(--line2); border-radius: 11px; padding: 14px 16px">
          <div style="font-size: 13px; font-weight: 600; color: var(--text); margin-bottom: 10px">2. Chọn file đã điền và nhập</div>

          <label
            style="display: flex; align-items: center; gap: 10px; border: 1px dashed var(--line2); border-radius: 9px; padding: 12px 14px; cursor: pointer; margin-bottom: 12px"
          >
            <i class="bi bi-file-earmark-spreadsheet" style="font-size: 18px; color: var(--muted2)"></i>
            <span style="font-size: 12.5px; color: var(--text); flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap">
              {{ selectedFile ? selectedFile.name : 'Chọn file .xlsx / .xls...' }}
            </span>
            <input type="file" accept=".xlsx,.xls" @change="onFileChange" style="display: none" />
          </label>

          <div v-if="error" class="alert-err" style="margin-bottom: 12px">{{ error }}</div>

          <button class="btn-acc" style="width: 100%; height: 42px" :disabled="!selectedFile || importing" @click="nhap">
            {{ importing ? 'Đang nhập...' : 'Nhập sản phẩm' }}
          </button>
        </div>

        <!-- Kết quả -->
        <div v-if="result" style="margin-top: 18px">
          <div style="display: flex; gap: 10px; margin-bottom: 12px">
            <div class="stat-box" style="color: var(--green)">
              <div style="font-size: 18px; font-weight: 700">{{ result.created }}</div>
              <div style="font-size: 11px">Đã tạo mới</div>
            </div>
            <div class="stat-box" style="color: var(--acc)">
              <div style="font-size: 18px; font-weight: 700">{{ result.updated }}</div>
              <div style="font-size: 11px">Đã cập nhật</div>
            </div>
            <div class="stat-box" style="color: var(--sale)">
              <div style="font-size: 18px; font-weight: 700">{{ result.skipped }}</div>
              <div style="font-size: 11px">Bỏ qua (lỗi)</div>
            </div>
          </div>

          <div v-if="result.errors && result.errors.length" style="border: 1px solid var(--line2); border-radius: 10px; overflow: hidden">
            <div style="background: var(--card2); padding: 8px 12px; font-size: 11.5px; font-weight: 600; color: var(--muted2)">
              Chi tiết dòng bị bỏ qua
            </div>
            <div
              v-for="err in result.errors"
              :key="err.rowNumber"
              style="padding: 9px 12px; font-size: 12px; border-top: 1px solid var(--line); display: flex; gap: 10px"
            >
              <span class="mono" style="color: var(--muted); flex: none">Dòng {{ err.rowNumber }}</span>
              <span style="color: var(--text); flex: none; font-weight: 600">{{ err.productName || '(chưa rõ tên)' }}</span>
              <span style="color: var(--sale)">{{ err.reason }}</span>
            </div>
          </div>
        </div>
      </div>

      <div style="display: flex; justify-content: flex-end; gap: 10px; padding: 16px 22px; border-top: 1px solid var(--line); flex: none">
        <button @click="$emit('close')" class="btn-ghost">Đóng</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { importProductsExcel, downloadProductImportTemplate } from '../api/admin';

const emit = defineEmits(['close', 'imported']);

const selectedFile = ref(null);
const importing = ref(false);
const downloadingTemplate = ref(false);
const error = ref('');
const result = ref(null);

function onFileChange(e) {
  selectedFile.value = e.target.files[0] || null;
  error.value = '';
  result.value = null;
}

async function taiTemplate() {
  downloadingTemplate.value = true;
  try {
    const blob = await downloadProductImportTemplate();
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'mau-nhap-san-pham.xlsx';
    document.body.appendChild(a);
    a.click();
    a.remove();
    window.URL.revokeObjectURL(url);
  } catch (e) {
    error.value = 'Không tải được file mẫu.';
  } finally {
    downloadingTemplate.value = false;
  }
}

async function nhap() {
  if (!selectedFile.value) return;
  importing.value = true;
  error.value = '';
  result.value = null;
  try {
    result.value = await importProductsExcel(selectedFile.value);
    if (result.value.created > 0 || result.value.updated > 0) {
      emit('imported');
    }
  } catch (e) {
    error.value = e.response?.data?.message || 'Nhập file thất bại, kiểm tra lại định dạng file.';
  } finally {
    importing.value = false;
  }
}
</script>

<style scoped>
.btn-ghost {
  height: 38px;
  padding: 0 16px;
  border-radius: 9px;
  border: 1px solid var(--line2);
  background: var(--card);
  color: var(--text);
  font-size: 12.5px;
  font-weight: 600;
  cursor: pointer;
}
.btn-acc {
  border-radius: 10px;
  border: none;
  background: var(--acc);
  color: var(--acc-ink);
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
}
.btn-acc:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}
.alert-err {
  background: color-mix(in srgb, var(--sale) 14%, transparent);
  color: var(--sale);
  border-radius: 9px;
  padding: 10px 12px;
  font-size: 12.5px;
}
.stat-box {
  flex: 1;
  background: var(--card);
  border: 1px solid var(--line2);
  border-radius: 10px;
  padding: 10px 12px;
  text-align: center;
}
</style>
