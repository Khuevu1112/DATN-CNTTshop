<template>
  <div style="animation: fadeUp 0.35s ease">
    <div v-if="detail" style="animation: fadeUp 0.3s ease">
      <button
        @click="detail = null"
        style="
          display: inline-flex; align-items: center; gap: 7px;
          background: none; border: none; color: var(--muted2);
          font-size: 13px; cursor: pointer; margin-bottom: 16px; font-weight: 500;
        "
      >
        <i class="bi bi-arrow-left"></i> Quay lại danh sách
      </button>

      <div style="display: grid; grid-template-columns: 1.7fr 1fr; gap: 14px">
        <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 20px">
          <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px">
            <div>
              <div style="font-size: 16px; font-weight: 700; color: var(--text)">{{ detail.fullName }}</div>
              <div style="font-size: 12px; color: var(--muted); margin-top: 3px">{{ fmtDateTime(detail.createdAt) }}</div>
            </div>
            <span class="badge" :style="statusStyle(detail.status)">{{ statusLabel(detail.status) }}</span>
          </div>
          <div style="font-size: 13px; color: var(--muted2); margin-bottom: 4px">
            <i class="bi bi-envelope" style="margin-right: 6px"></i>{{ detail.email }}
            <span v-if="detail.phone" style="margin-left: 14px"><i class="bi bi-telephone" style="margin-right: 6px"></i>{{ detail.phone }}</span>
          </div>
          <div v-if="detail.subject" style="font-size: 13px; font-weight: 600; color: var(--text); margin-top: 14px">
            {{ detail.subject }}
          </div>
          <div style="margin-top: 8px; padding: 14px; background: var(--card2); border-radius: 10px; font-size: 13.5px; color: var(--text); line-height: 1.6; white-space: pre-wrap">
            {{ detail.message }}
          </div>

          <div v-if="detail.adminReply" style="margin-top: 16px">
            <div style="font-size: 12px; font-weight: 600; color: var(--muted2); margin-bottom: 6px">Đã phản hồi · {{ fmtDateTime(detail.repliedAt) }}</div>
            <div style="padding: 14px; background: color-mix(in srgb, var(--acc) 8%, transparent); border-radius: 10px; font-size: 13.5px; color: var(--text); line-height: 1.6; white-space: pre-wrap">
              {{ detail.adminReply }}
            </div>
          </div>
        </div>

        <div>
          <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 18px; margin-bottom: 14px">
            <div style="font-size: 13px; font-weight: 600; color: var(--text); margin-bottom: 12px">Cập nhật trạng thái</div>
            <select class="fld" v-model="statusDraft" style="margin-bottom: 10px">
              <option value="new">Mới</option>
              <option value="processing">Đang xử lý</option>
              <option value="resolved">Đã xử lý</option>
            </select>
            <button class="btn-acc" style="height: 42px" :disabled="savingStatus" @click="saveStatus">
              {{ savingStatus ? 'Đang lưu...' : 'Lưu trạng thái' }}
            </button>
          </div>

          <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 18px">
            <div style="font-size: 13px; font-weight: 600; color: var(--text); margin-bottom: 12px">Phản hồi khách hàng</div>
            <textarea class="fld" v-model="replyDraft" rows="5" style="padding: 10px 14px; resize: vertical; margin-bottom: 10px"
              placeholder="Nhập nội dung phản hồi..."></textarea>
            <button class="btn-acc" style="height: 42px" :disabled="sendingReply" @click="sendReply">
              {{ sendingReply ? 'Đang gửi...' : 'Gửi phản hồi' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-else>
      <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; margin-bottom: 16px">
        <div v-for="s in stats" :key="s.label"
             style="background: var(--card); border: 1px solid var(--line); border-radius: 13px; padding: 14px 16px; display: flex; align-items: center; gap: 13px">
          <div style="width: 40px; height: 40px; border-radius: 10px; flex: none; display: flex; align-items: center; justify-content: center; font-size: 17px"
               :style="{ background: 'color-mix(in srgb,' + s.color + ' 16%,transparent)', color: s.color }">
            <i class="bi" :class="s.icon"></i>
          </div>
          <div>
            <div class="mono" style="font-size: 21px; font-weight: 700; color: var(--text); line-height: 1">{{ s.value }}</div>
            <div style="font-size: 11.5px; color: var(--muted); margin-top: 4px">{{ s.label }}</div>
          </div>
        </div>
      </div>

      <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; overflow: hidden">
        <div style="display: flex; align-items: center; gap: 2px; padding: 4px 12px; border-bottom: 1px solid var(--line); overflow-x: auto">
          <button v-for="t in tabs" :key="t.key" @click="filter = t.key"
            style="display: flex; align-items: center; gap: 7px; padding: 12px 13px; border: none; background: transparent; font-size: 12.5px; cursor: pointer; white-space: nowrap"
            :style="{
              borderBottom: '2px solid ' + (filter === t.key ? 'var(--acc)' : 'transparent'),
              color: filter === t.key ? 'var(--text)' : 'var(--muted)',
              fontWeight: filter === t.key ? 600 : 500,
            }"
          >
            {{ t.label }}
            <span class="mono" style="font-size: 10.5px; padding: 0 6px; border-radius: 8px; background: var(--card2); color: var(--muted)">{{ t.count }}</span>
          </button>
        </div>

        <div v-if="loading" class="spin"></div>
        <div v-else-if="!rows.length" style="padding: 40px; text-align: center; color: var(--muted); font-size: 13px">
          Chưa có liên hệ nào.
        </div>
        <table v-else style="width: 100%; border-collapse: collapse; font-size: 13px">
          <thead>
            <tr style="background: var(--card2)">
              <th v-for="h in heads" :key="h.t" :style="{ textAlign: h.a || 'left', padding: '10px 16px', fontSize: '11px', fontWeight: 600, color: 'var(--muted)', textTransform: 'uppercase', letterSpacing: '.4px' }">
                {{ h.t }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="c in rows" :key="c.id" @click="openDetail(c)" style="border-top: 1px solid var(--line); cursor: pointer">
              <td style="padding: 12px 16px">
                <div style="font-size: 12.5px; color: var(--text); font-weight: 600">{{ c.fullName }}</div>
                <div style="font-size: 11px; color: var(--muted)">{{ c.email }}</div>
              </td>
              <td style="padding: 12px 12px; color: var(--muted2); font-size: 12px; max-width: 260px">{{ c.subject || '—' }}</td>
              <td style="padding: 12px 12px; color: var(--muted2); font-size: 12px">{{ fmtDateTime(c.createdAt) }}</td>
              <td style="padding: 12px 16px">
                <span class="badge" :style="statusStyle(c.status)">{{ statusLabel(c.status) }}</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { ui } from '../uiState';
import { getAdminContacts, getAdminContactDetail, updateContactStatus, replyContact } from '../api/admin';

const loading = ref(true);
const list = ref([]);
const detail = ref(null);
const filter = ref('all');
const statusDraft = ref('new');
const replyDraft = ref('');
const savingStatus = ref(false);
const sendingReply = ref(false);

const heads = [{ t: 'Khách hàng' }, { t: 'Chủ đề' }, { t: 'Thời gian' }, { t: 'Trạng thái' }];
const stKeys = ['all', 'new', 'processing', 'resolved'];
const stLabels = { all: 'Tất cả', new: 'Mới', processing: 'Đang xử lý', resolved: 'Đã xử lý' };

const tabs = computed(() => stKeys.map((k) => ({
  key: k, label: stLabels[k],
  count: k === 'all' ? list.value.length : list.value.filter((c) => c.status === k).length,
})));

const rows = computed(() => {
  const q = ui.search.trim().toLowerCase();
  return list.value.filter((c) =>
    (filter.value === 'all' || c.status === filter.value) &&
    (!q || c.fullName.toLowerCase().includes(q) || c.email.toLowerCase().includes(q)));
});

const stats = computed(() => [
  { label: 'Tổng liên hệ', value: list.value.length + '', icon: 'bi-envelope-paper', color: 'var(--acc)' },
  { label: 'Mới', value: list.value.filter((c) => c.status === 'new').length + '', icon: 'bi-asterisk', color: 'var(--amber)' },
  { label: 'Đã xử lý', value: list.value.filter((c) => c.status === 'resolved').length + '', icon: 'bi-check-circle', color: 'var(--green)' },
]);

function statusLabel(s) { return stLabels[s] || s; }
function statusStyle(s) {
  const color = s === 'resolved' ? 'var(--green)' : s === 'processing' ? 'var(--acc)' : 'var(--amber)';
  return { background: 'color-mix(in srgb,' + color + ' 16%, transparent)', color };
}
function fmtDateTime(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  const p = (n) => String(n).padStart(2, '0');
  return `${p(d.getDate())}/${p(d.getMonth() + 1)}/${d.getFullYear()} ${p(d.getHours())}:${p(d.getMinutes())}`;
}

async function load() {
  loading.value = true;
  try {
    list.value = await getAdminContacts();
  } finally {
    loading.value = false;
  }
}

async function openDetail(row) {
  const d = await getAdminContactDetail(row.id);
  detail.value = d;
  statusDraft.value = d.status;
  replyDraft.value = d.adminReply || '';
}

async function saveStatus() {
  savingStatus.value = true;
  try {
    detail.value = await updateContactStatus(detail.value.id, statusDraft.value);
    await load();
  } finally {
    savingStatus.value = false;
  }
}

async function sendReply() {
  if (!replyDraft.value.trim()) return;
  sendingReply.value = true;
  try {
    detail.value = await replyContact(detail.value.id, replyDraft.value.trim());
    statusDraft.value = detail.value.status;
    await load();
  } finally {
    sendingReply.value = false;
  }
}

onMounted(load);
</script>

<style scoped>
.badge {
  display: inline-flex;
  align-items: center;
  font-size: 11.5px;
  font-weight: 600;
  padding: 3px 10px;
  border-radius: 20px;
}
</style>
