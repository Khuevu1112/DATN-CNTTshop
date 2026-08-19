<template>
  <div style="animation: fadeUp 0.35s ease">
    <div style="display: flex; align-items: center; justify-content: space-between; gap: 14px; margin-bottom: 16px; flex-wrap: wrap">
      <div style="display: flex; gap: 8px; flex-wrap: wrap">
        <button class="tab-chip" :class="{ active: loc === '' }" @click="loc = ''">Tất cả ({{ list.length }})</button>
        <button class="tab-chip" :class="{ active: loc === 'published' }" @click="loc = 'published'">Đã xuất bản ({{ dem('published') }})</button>
        <button class="tab-chip" :class="{ active: loc === 'draft' }" @click="loc = 'draft'">Nháp ({{ dem('draft') }})</button>
      </div>
      <button v-if="coQuyen('add')" class="btn-acc" style="height: 40px; width: auto; padding: 0 18px" @click="moForm()">
        <i class="bi bi-plus-lg"></i> Viết bài mới
      </button>
    </div>

    <div v-if="loading" class="spin"></div>

    <div v-else class="tbl-wrap">
      <DataTable :columns="cols" :rows="danhSachLoc" :tim-kiem="ui.search" trong="Chưa có bài viết nào.">
        <template #o-anh="{ row: a }">
          <div class="thumb" :style="a.thumbnail ? { backgroundImage: `url(${resolveImageUrl(a.thumbnail)})` } : {}"></div>
        </template>
        <template #o-tieuDe="{ row: a }">
          <div style="font-weight: 600; color: var(--text)">{{ a.tieuDe }}</div>
          <div style="font-size: 11.5px; color: var(--muted); margin-top: 3px">/{{ a.slug }}</div>
        </template>
        <template #o-tenDanhMuc="{ row: a }">
          <span class="mini-tag">{{ a.tenDanhMuc }}</span>
        </template>
        <template #o-trangThai="{ row: a }">
          <div style="display: flex; flex-direction: column; align-items: flex-start; gap: 5px">
            <span class="badge" :style="a.trangThai === 'published' ? okStyle : draftStyle">
              {{ a.trangThai === 'published' ? 'Đã xuất bản' : 'Nháp' }}
            </span>
            <span v-if="a.noiBat" class="badge" :style="accStyle">Nổi bật</span>
          </div>
        </template>
        <template #o-luotXem="{ row: a }">
          <span class="mono" style="color: var(--muted2)">{{ a.luotXem }}</span>
        </template>
        <template #o-publishedAt="{ row: a }">
          <span style="color: var(--muted2); font-size: 12px">{{ a.publishedAt ? fmtDate(a.publishedAt) : '—' }}</span>
        </template>
        <template #o-thaoTac="{ row: a }">
          <div style="display: flex; gap: 6px; justify-content: flex-end">
            <button v-if="coQuyen('edit')" class="ico-btn" @click="moForm(a)"><i class="bi bi-pencil"></i></button>
            <button v-if="coQuyen('delete')" class="ico-btn danger" @click="xoa(a)"><i class="bi bi-trash"></i></button>
          </div>
        </template>
      </DataTable>
    </div>

    <!-- Form -->
    <div v-if="form" class="modal-bd" @click.self="form = null">
      <div class="modal-bx">
        <div class="modal-hd">
          <div style="font-size: 15px; font-weight: 700; color: var(--text)">{{ form.id ? 'Sửa bài viết' : 'Viết bài mới' }}</div>
          <button class="ico-btn" @click="form = null"><i class="bi bi-x-lg"></i></button>
        </div>
        <div class="modal-bd-in">
          <div v-if="loiForm" class="alert-err">{{ loiForm }}</div>

          <label class="fw"><span>Tiêu đề *</span><input v-model="form.tieuDe" class="fld" /></label>
          <div class="fgrid">
            <label><span>Danh mục *</span>
              <select v-model="form.categoryId" class="fld">
                <option :value="null">— Chọn —</option>
                <option v-for="c in cats" :key="c.id" :value="c.id">{{ c.ten }}</option>
              </select>
            </label>
            <label><span>Tác giả</span><input v-model="form.tacGia" class="fld" placeholder="CNTTShop" /></label>
          </div>
          <label class="fw"><span>Slug (để trống = tự sinh từ tiêu đề)</span><input v-model="form.slug" class="fld" placeholder="vd: review-rtx-5070" /></label>

          <div class="fw">
            <span class="lbl">Ảnh đại diện</span>
            <div style="display: flex; gap: 12px; align-items: center">
              <div class="thumb thumb-lg" :style="form.thumbnail ? { backgroundImage: `url(${resolveImageUrl(form.thumbnail)})` } : {}"></div>
              <div style="flex: 1">
                <input type="file" accept="image/*" class="fld" @change="onThumb" :disabled="uploading" />
                <div style="font-size: 11px; color: var(--muted); margin-top: 5px">
                  {{ uploading ? 'Đang tải ảnh…' : 'Hoặc dán URL vào ô dưới' }}
                </div>
                <input v-model="form.thumbnail" class="fld" style="margin-top: 6px" placeholder="https://... hoặc /uploads/..." />
              </div>
            </div>
          </div>

          <label class="fw"><span>Tóm tắt (hiện ở danh sách)</span>
            <textarea v-model="form.tomTat" class="fld" rows="2" style="padding: 10px 14px; resize: vertical"></textarea>
          </label>
          <label class="fw"><span>Nội dung * (HTML: &lt;p&gt;, &lt;h3&gt;, &lt;strong&gt;, &lt;ul&gt;&lt;li&gt;, &lt;img&gt;…)</span>
            <textarea v-model="form.noiDung" class="fld" rows="10" style="padding: 10px 14px; resize: vertical; font-family: monospace; font-size: 12.5px"></textarea>
          </label>

          <div class="fgrid">
            <label><span>Trạng thái</span>
              <select v-model="form.trangThai" class="fld">
                <option value="draft">Nháp</option>
                <option value="published">Xuất bản</option>
              </select>
            </label>
            <label class="chk" style="align-self: end; height: 42px"><input type="checkbox" v-model="form.noiBat" /> <span>Bài nổi bật</span></label>
          </div>
        </div>
        <div class="modal-ft">
          <button class="btn-ghost" @click="form = null">Huỷ</button>
          <button class="btn-acc" style="height: 42px; width: auto; padding: 0 22px" :disabled="saving" @click="luu">
            {{ saving ? 'Đang lưu…' : 'Lưu' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { usePermissionsStore } from '../stores/permissions'
import { getArticles, getArticleCategories, createArticle, updateArticle, deleteArticle, uploadProductImage } from '../api/admin'
import { resolveImageUrl } from '../api/http'
import { ui } from '../uiState'
import DataTable from '../components/DataTable.vue'

const permissions = usePermissionsStore()
const coQuyen = (p) => permissions.hasPerm('articles', p)

const list = ref([])
const cats = ref([])
const loading = ref(true)
const loc = ref('')
const form = ref(null)
const loiForm = ref('')
const saving = ref(false)
const uploading = ref(false)

const okStyle = { background: 'color-mix(in srgb, var(--ok, #2bd47e) 14%, transparent)', color: 'var(--ok, #2bd47e)' }
const draftStyle = { background: 'color-mix(in srgb, var(--muted2) 14%, transparent)', color: 'var(--muted2)' }
const accStyle = { background: 'color-mix(in srgb, var(--acc) 14%, transparent)', color: 'var(--acc)' }

const danhSachLoc = computed(() => (loc.value ? list.value.filter((a) => a.trangThai === loc.value) : list.value))

// Cột cho DataTable — phễu lọc/sắp xếp kiểu Excel trên từng cột (xem components/DataTable.vue).
const cols = [
  { key: 'anh', label: '', width: '64px', loc: false },
  { key: 'tieuDe', label: 'Tiêu đề', width: '260px' },
  { key: 'tenDanhMuc', label: 'Danh mục', width: '130px' },
  { key: 'trangThai', label: 'Trạng thái', width: '110px',
    text: (a) => (a.trangThai === 'published' ? 'Đã xuất bản' : 'Nháp') + (a.noiBat ? ' · Nổi bật' : '') },
  { key: 'luotXem', label: 'Lượt xem', width: '90px', align: 'center', kieu: 'so' },
  { key: 'publishedAt', label: 'Xuất bản', width: '120px', kieu: 'ngay',
    text: (a) => (a.publishedAt ? fmtDate(a.publishedAt) : '—') },
  { key: 'thaoTac', label: '', width: '110px', align: 'right', loc: false },
]
const dem = (tt) => list.value.filter((a) => a.trangThai === tt).length
const fmtDate = (iso) => { const d = new Date(iso); return `${String(d.getDate()).padStart(2, '0')}/${String(d.getMonth() + 1).padStart(2, '0')}/${d.getFullYear()}` }

async function tai() {
  loading.value = true
  try {
    const [a, c] = await Promise.all([getArticles(), getArticleCategories()])
    list.value = a
    cats.value = c
  } catch (e) {
    list.value = []
  } finally {
    loading.value = false
  }
}

function moForm(a) {
  loiForm.value = ''
  form.value = a
    ? { id: a.id, tieuDe: a.tieuDe, slug: a.slug, thumbnail: a.thumbnail, categoryId: a.categoryId,
        tomTat: a.tomTat, noiDung: a.noiDung, tacGia: a.tacGia, trangThai: a.trangThai, noiBat: a.noiBat }
    : { id: null, tieuDe: '', slug: '', thumbnail: '', categoryId: null, tomTat: '', noiDung: '', tacGia: 'CNTTShop', trangThai: 'draft', noiBat: false }
}

async function onThumb(e) {
  const file = e.target.files?.[0]
  if (!file) return
  uploading.value = true
  try {
    form.value.thumbnail = await uploadProductImage(file) // tái dùng endpoint upload ảnh sẵn có
  } catch (err) {
    loiForm.value = 'Tải ảnh thất bại.'
  } finally {
    uploading.value = false
  }
}

async function luu() {
  loiForm.value = ''
  saving.value = true
  const f = form.value
  const body = {
    tieuDe: f.tieuDe, slug: f.slug || null, thumbnail: f.thumbnail || null, categoryId: f.categoryId,
    tomTat: f.tomTat || null, noiDung: f.noiDung, tacGia: f.tacGia || null, trangThai: f.trangThai, noiBat: f.noiBat,
  }
  try {
    f.id ? await updateArticle(f.id, body) : await createArticle(body)
    form.value = null
    await tai()
  } catch (e) {
    loiForm.value = e?.response?.data?.message || 'Lưu thất bại, kiểm tra lại dữ liệu.'
  } finally {
    saving.value = false
  }
}

async function xoa(a) {
  if (!confirm(`Xoá bài "${a.tieuDe}"?`)) return
  try {
    await deleteArticle(a.id)
    await tai()
  } catch (e) {
    alert(e?.response?.data?.message || 'Không xoá được.')
  }
}

onMounted(tai)
</script>

<style scoped>
.tbl-wrap { background: var(--card); border: 1px solid var(--line); border-radius: 14px; overflow: hidden; }
.tbl { width: 100%; border-collapse: collapse; font-size: 13px; }
.tbl th { text-align: left; padding: 12px 14px; font-size: 11.3px; letter-spacing: 0.4px; color: var(--muted); font-weight: 600; background: var(--card2); border-bottom: 1px solid var(--line); white-space: nowrap; }
.tbl td { padding: 12px 14px; border-bottom: 1px solid var(--line); vertical-align: middle; }
.tbl tbody tr:last-child td { border-bottom: none; }
.tbl tbody tr:hover { background: var(--card2); }
.empty { text-align: center; padding: 44px 20px; color: var(--muted); }
.thumb { width: 52px; height: 36px; border-radius: 6px; background: var(--card2); background-size: cover; background-position: center; }
.thumb-lg { width: 120px; height: 74px; flex: none; }
.mini-tag { display: inline-block; font-size: 11px; color: var(--muted2); background: var(--card2); border-radius: 6px; padding: 3px 8px; }
.tab-chip { display: inline-flex; align-items: center; gap: 7px; background: var(--card); border: 1px solid var(--line); color: var(--muted2); border-radius: 999px; padding: 8px 16px; font-size: 12.8px; cursor: pointer; transition: all 0.15s; }
.tab-chip:hover { border-color: var(--acc); color: var(--text); }
.tab-chip.active { background: color-mix(in srgb, var(--acc) 14%, transparent); border-color: var(--acc); color: var(--acc); font-weight: 600; }
.ico-btn { width: 30px; height: 30px; border-radius: 8px; background: transparent; border: 1px solid var(--line); color: var(--muted2); cursor: pointer; font-size: 12px; transition: all 0.15s; }
.ico-btn:hover { border-color: var(--acc); color: var(--acc); }
.ico-btn.danger:hover { border-color: var(--danger, #ff5d7a); color: var(--danger, #ff5d7a); }
.btn-ghost { background: transparent; border: 1px solid var(--line); color: var(--muted2); border-radius: 10px; height: 42px; padding: 0 20px; font-size: 13px; cursor: pointer; }
.btn-ghost:hover { border-color: var(--acc); color: var(--acc); }
.modal-bd { position: fixed; inset: 0; z-index: 2000; background: rgba(0, 0, 0, 0.6); display: flex; align-items: center; justify-content: center; padding: 20px; }
.modal-bx { background: var(--card); border: 1px solid var(--line); border-radius: 16px; width: 100%; max-width: 680px; max-height: 92vh; display: flex; flex-direction: column; overflow: hidden; }
.modal-hd { display: flex; align-items: center; justify-content: space-between; padding: 18px 22px; border-bottom: 1px solid var(--line); }
.modal-bd-in { padding: 20px 22px; overflow-y: auto; display: flex; flex-direction: column; gap: 14px; }
.modal-ft { display: flex; gap: 10px; justify-content: flex-end; padding: 16px 22px; border-top: 1px solid var(--line); }
.fgrid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.fw { grid-column: 1 / -1; }
label span, .lbl { display: block; font-size: 11.6px; color: var(--muted); margin-bottom: 6px; font-weight: 500; }
.chk { display: flex !important; align-items: center; gap: 8px; font-size: 13px; color: var(--text); cursor: pointer; }
.chk span { margin: 0; color: var(--text); font-size: 13px; }
.alert-err { background: color-mix(in srgb, var(--danger, #ff5d7a) 12%, transparent); border: 1px solid color-mix(in srgb, var(--danger, #ff5d7a) 30%, transparent); color: var(--danger, #ff5d7a); border-radius: 10px; padding: 11px 14px; font-size: 12.8px; }
</style>
