<template>
  <div>
    <!-- ===== Stats ===== -->
    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 16px">
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

    <!-- ===== Table ===== -->
    <div style="background: var(--card); border: 1px solid var(--line); border-radius: 14px; overflow: hidden">
      <div style="display: flex; align-items: center; gap: 8px; padding: 14px 16px; border-bottom: 1px solid var(--line)">
        <i class="bi bi-diagram-3" style="color: var(--acc); font-size: 15px"></i>
        <span style="font-size: 13.5px; font-weight: 600; color: var(--text)">Danh sách mẫu cấu hình</span>
        <span class="mono" style="font-size: 11px; color: var(--muted); padding: 1px 8px; border-radius: 8px; background: var(--card2)">{{ rows.length }}</span>
        <div style="flex: 1"></div>
        <button @click="openCreate"
          style="display: flex; align-items: center; gap: 6px; height: 32px; padding: 0 13px; border-radius: 9px; border: 1px solid var(--line2); background: var(--card); color: var(--acc); font-size: 12.5px; font-weight: 600; cursor: pointer">
          <i class="bi bi-plus-lg"></i> Thêm mẫu
        </button>
      </div>

      <div v-if="loading" style="padding: 46px 20px; text-align: center; color: var(--muted); font-size: 13.5px">Đang tải...</div>

      <DataTable
        v-else-if="rows.length"
        :columns="cols"
        :rows="rows"
        :tim-kiem="ui.search"
        click-duoc
        @row-click="(t) => openDetail(t.id)"
      >
        <template #o-name="{ row: t }">
          <div style="display: flex; align-items: center; gap: 12px">
            <div style="width: 42px; height: 42px; border-radius: 10px; flex: none; display: flex; align-items: center; justify-content: center; font-size: 18px; background: color-mix(in srgb, var(--acc) 13%, transparent); color: var(--acc)">
              <i class="bi bi-pc-display"></i>
            </div>
            <div style="min-width: 0">
              <div style="font-size: 13.5px; font-weight: 600; color: var(--text)">{{ t.name }}</div>
              <div style="display: flex; align-items: center; gap: 5px; margin-top: 5px">
                <i v-for="(c, i) in t.chips" :key="i" class="bi" :class="c"
                  style="font-size: 12px; color: var(--muted2); width: 18px; height: 18px; line-height: 18px; text-align: center; border-radius: 5px; background: var(--card2)"></i>
                <span v-if="t.moreCount" class="mono" style="font-size: 10.5px; color: var(--muted)">+{{ t.moreCount }}</span>
              </div>
            </div>
          </div>
        </template>
        <template #o-itemCount="{ row: t }">
          <span class="mono" style="display: inline-flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 600; color: var(--muted2); padding: 3px 10px; border-radius: 20px; background: var(--card2)">
            <i class="bi bi-puzzle" style="font-size: 12px"></i>{{ t.itemCount }} linh kiện
          </span>
        </template>
        <template #o-totalSuggestedPrice="{ row: t }">
          <span class="mono" style="font-size: 14px; font-weight: 700; color: var(--acc)">{{ money(t.totalSuggestedPrice) }}</span>
        </template>
        <template #o-thaoTac="{ row: t }">
          <span style="white-space: nowrap">
            <button @click.stop="openEdit(t.id)" title="Sửa" class="kt-iconbtn"
              style="width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--line2); background: var(--card); color: var(--muted2); cursor: pointer; margin-left: 6px"><i class="bi bi-pencil"></i></button>
            <button @click.stop="duplicate(t.id)" title="Nhân bản" class="kt-iconbtn"
              style="width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--line2); background: var(--card); color: var(--muted2); cursor: pointer; margin-left: 6px"><i class="bi bi-copy"></i></button>
            <button @click.stop="confirmId = t.id" title="Xóa"
              style="width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--line2); background: var(--card); color: var(--sale); cursor: pointer; margin-left: 6px"><i class="bi bi-trash3"></i></button>
          </span>
        </template>
      </DataTable>

      <div v-else style="padding: 46px 20px; text-align: center; color: var(--muted)">
        <i class="bi bi-inbox" style="font-size: 30px; opacity: .5"></i>
        <div style="font-size: 13.5px; margin-top: 10px">Chưa có mẫu cấu hình nào khớp.</div>
      </div>
    </div>

    <!-- ===== DETAIL SLIDE-OVER ===== -->
    <template v-if="detail">
      <div @click="detail = null" style="position: fixed; inset: 0; background: rgba(2,8,18,.55); backdrop-filter: blur(2px); z-index: 60"></div>
      <div style="position: fixed; top: 0; right: 0; width: 460px; max-width: 94vw; height: 100vh; background: var(--bg); border-left: 1px solid var(--line2); z-index: 61; display: flex; flex-direction: column; box-shadow: -20px 0 60px rgba(0,0,0,.4)">
        <div style="display: flex; align-items: center; justify-content: space-between; padding: 18px 20px; border-bottom: 1px solid var(--line)">
          <div style="font-size: 14px; font-weight: 600; color: var(--text)">Chi tiết mẫu cấu hình</div>
          <button @click="detail = null" style="width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--line2); background: var(--card); color: var(--text); cursor: pointer"><i class="bi bi-x-lg" style="font-size: 13px"></i></button>
        </div>
        <div style="flex: 1; overflow-y: auto; padding: 20px">
          <div style="display: flex; gap: 14px; align-items: flex-start; margin-bottom: 18px">
            <div style="width: 56px; height: 56px; border-radius: 13px; flex: none; display: flex; align-items: center; justify-content: center; font-size: 24px; background: color-mix(in srgb, var(--acc) 14%, transparent); color: var(--acc)"><i class="bi bi-pc-display"></i></div>
            <div style="min-width: 0">
              <div style="font-size: 16px; font-weight: 700; color: var(--text); line-height: 1.3">{{ detail.name }}</div>
              <div style="font-size: 12.5px; color: var(--muted); margin-top: 5px; line-height: 1.5">{{ detail.description || 'Chưa có mô tả' }}</div>
            </div>
          </div>
          <div style="display: flex; gap: 10px; margin-bottom: 18px">
            <div style="flex: 1; background: var(--card); border: 1px solid var(--line); border-radius: 11px; padding: 12px 14px">
              <div style="font-size: 11px; color: var(--muted); margin-bottom: 5px">Tổng giá đề xuất</div>
              <div class="mono" style="font-size: 18px; font-weight: 700; color: var(--acc)">{{ money(detail.totalSuggestedPrice) }}</div>
            </div>
            <div style="flex: 1; background: var(--card); border: 1px solid var(--line); border-radius: 11px; padding: 12px 14px">
              <div style="font-size: 11px; color: var(--muted); margin-bottom: 5px">Số linh kiện</div>
              <div class="mono" style="font-size: 18px; font-weight: 700; color: var(--text)">{{ detail.items.length }}</div>
            </div>
          </div>
          <div style="font-size: 11px; font-weight: 600; color: var(--muted); text-transform: uppercase; letter-spacing: .5px; margin-bottom: 10px">Danh sách linh kiện</div>
          <div style="background: var(--card); border: 1px solid var(--line); border-radius: 12px; overflow: hidden">
            <div v-for="it in detail.items" :key="it.id" style="display: flex; align-items: center; gap: 11px; padding: 11px 13px; border-bottom: 1px solid var(--line)">
              <div style="width: 34px; height: 34px; border-radius: 9px; flex: none; display: flex; align-items: center; justify-content: center; font-size: 15px; background: var(--card2); color: var(--muted2)"><i class="bi" :class="typeInfo(it.componentType).icon"></i></div>
              <div style="flex: 1; min-width: 0">
                <div style="font-size: 10px; font-weight: 600; color: var(--muted); text-transform: uppercase; letter-spacing: .5px">{{ typeInfo(it.componentType).label }}</div>
                <div style="font-size: 13px; font-weight: 500; color: var(--text); margin-top: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis">{{ it.displayName }}</div>
                <div style="display: flex; align-items: center; gap: 8px; margin-top: 3px">
                  <span class="mono" style="font-size: 10.5px; color: var(--muted)">{{ it.sku || 'NGOÀI KHO' }}</span>
                  <span style="font-size: 9.5px; font-weight: 600; padding: 1px 7px; border-radius: 20px"
                    :style="it.source === 'external' ? 'color:var(--amber);background:color-mix(in srgb,var(--amber) 16%,transparent);' : 'color:var(--green);background:color-mix(in srgb,var(--green) 16%,transparent);'">
                    {{ it.source === 'external' ? 'Bên ngoài' : 'Trong kho' }}
                  </span>
                </div>
              </div>
              <span class="mono" style="font-size: 13px; font-weight: 700; color: var(--text); white-space: nowrap">{{ money(it.price) }}</span>
            </div>
          </div>
          <div style="display: flex; gap: 10px; margin-top: 20px">
            <button @click="openEdit(detail.id)" style="flex: 1; height: 42px; border-radius: 10px; border: none; background: var(--acc); color: var(--acc-ink); font-weight: 700; font-size: 13px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 7px"><i class="bi bi-pencil-square"></i> Chỉnh sửa</button>
            <button @click="duplicate(detail.id)" title="Nhân bản" style="width: 42px; height: 42px; border-radius: 10px; border: 1px solid var(--line2); background: var(--card); color: var(--text); font-size: 15px; cursor: pointer"><i class="bi bi-copy"></i></button>
            <button @click="confirmId = detail.id; detail = null" title="Xóa" style="width: 42px; height: 42px; border-radius: 10px; border: 1px solid var(--line2); background: var(--card); color: var(--sale); font-size: 15px; cursor: pointer"><i class="bi bi-trash3"></i></button>
          </div>
        </div>
      </div>
    </template>

    <!-- ===== CREATE / EDIT MODAL ===== -->
    <template v-if="formOpen">
      <div @click="formOpen = false" style="position: fixed; inset: 0; background: rgba(2,8,18,.6); backdrop-filter: blur(2px); z-index: 70; display: flex; align-items: center; justify-content: center; padding: 24px">
        <div @click.stop style="width: 100%; max-width: 780px; max-height: 90vh; background: var(--bg); border: 1px solid var(--line2); border-radius: 16px; display: flex; flex-direction: column; box-shadow: 0 20px 60px rgba(0,0,0,.45)">
          <div style="display: flex; align-items: center; justify-content: space-between; padding: 18px 22px; border-bottom: 1px solid var(--line); flex: none">
            <div style="font-size: 15px; font-weight: 700; color: var(--text)">{{ formMode === 'edit' ? 'Chỉnh sửa mẫu cấu hình' : 'Tạo mẫu cấu hình mới' }}</div>
            <button @click="formOpen = false" style="width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--line2); background: var(--card); color: var(--text); cursor: pointer"><i class="bi bi-x-lg" style="font-size: 13px"></i></button>
          </div>
          <div style="flex: 1; overflow-y: auto; padding: 20px 22px">
            <label style="display: block; font-size: 12px; font-weight: 600; color: var(--muted2); margin: 0 0 6px">Tên mẫu *</label>
            <input v-model="form.name" placeholder="VD: PC Gaming RTX 4060 Tầm trung"
              style="width: 100%; height: 40px; background: var(--card); border: 1px solid var(--line2); border-radius: 9px; color: var(--text); font-size: 13px; padding: 0 13px; outline: none; box-sizing: border-box" />
            <label style="display: block; font-size: 12px; font-weight: 600; color: var(--muted2); margin: 14px 0 6px">Mô tả</label>
            <textarea v-model="form.description" rows="2" placeholder="Mô tả ngắn về mẫu cấu hình này"
              style="width: 100%; background: var(--card); border: 1px solid var(--line2); border-radius: 9px; color: var(--text); font-size: 13px; padding: 10px 13px; outline: none; resize: vertical; box-sizing: border-box"></textarea>

            <div style="display: flex; align-items: center; justify-content: space-between; margin: 18px 0 10px">
              <span style="font-size: 12px; font-weight: 600; color: var(--muted2); text-transform: uppercase; letter-spacing: .4px">Linh kiện trong mẫu</span>
              <button @click="addFormItem" style="background: none; border: none; color: var(--acc); font-size: 12.5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px"><i class="bi bi-plus-lg"></i> Thêm linh kiện</button>
            </div>

            <div v-for="it in form.items" :key="it.uid" style="background: var(--card); border: 1px solid var(--line); border-radius: 11px; padding: 11px; margin-bottom: 9px">
              <div style="display: flex; align-items: center; gap: 9px">
                <div style="width: 32px; height: 32px; border-radius: 8px; flex: none; display: flex; align-items: center; justify-content: center; font-size: 15px; background: color-mix(in srgb, var(--acc) 13%, transparent); color: var(--acc)"><i class="bi" :class="typeInfo(it.type).icon"></i></div>
                <select v-model="it.type" @change="it.variantId = null; it.variantLabel = ''; it._results = []"
                  style="height: 34px; background: var(--card2); border: 1px solid var(--line2); border-radius: 8px; color: var(--text); font-size: 12.5px; padding: 0 10px; outline: none; cursor: pointer; min-width: 140px">
                  <option v-for="o in TYPES" :key="o.key" :value="o.key">{{ o.label }}</option>
                </select>
                <div style="flex: 1"></div>
                <div style="display: flex; border: 1px solid var(--line2); border-radius: 8px; overflow: hidden">
                  <button @click="it.source = 'stock'" :style="segStyle(it.source === 'stock')" style="padding: 6px 13px; border: none; font-size: 11.5px; font-weight: 600; cursor: pointer; white-space: nowrap">Trong kho</button>
                  <button @click="it.source = 'external'" :style="segStyle(it.source === 'external')" style="padding: 6px 13px; border: none; font-size: 11.5px; font-weight: 600; cursor: pointer; white-space: nowrap">Bên ngoài</button>
                </div>
                <button @click="form.items = form.items.filter(x => x.uid !== it.uid)" title="Xóa" style="width: 34px; height: 34px; flex: none; border-radius: 8px; border: 1px solid var(--line2); background: var(--card); color: var(--sale); cursor: pointer"><i class="bi bi-trash3"></i></button>
              </div>

              <div v-if="it.source === 'stock'" style="position: relative; margin-top: 9px">
                <input v-model="it.variantLabel" @input="onStockSearch(it)" @focus="onStockSearch(it)"
                  placeholder="Gõ để tìm sản phẩm trong kho..."
                  style="width: 100%; height: 36px; background: var(--card2); border: 1px solid var(--line2); border-radius: 8px; color: var(--text); font-size: 12.5px; padding: 0 11px; outline: none; box-sizing: border-box" />
                <div v-if="it._results && it._results.length" style="position: absolute; top: 40px; left: 0; right: 0; z-index: 5; background: var(--bg); border: 1px solid var(--line2); border-radius: 9px; max-height: 180px; overflow-y: auto; box-shadow: 0 10px 26px rgba(0,0,0,.35)">
                  <div v-for="p in it._results" :key="p.variantId" @click="pickVariant(it, p)"
                    style="padding: 8px 11px; font-size: 12.5px; color: var(--text); cursor: pointer; border-bottom: 1px solid var(--line)">
                    {{ p.productName }} <span class="mono" style="color: var(--muted)">— {{ money(p.price) }}</span>
                  </div>
                </div>
                <div v-if="it.variantId" style="font-size: 11px; color: var(--green); margin-top: 4px"><i class="bi bi-check-circle"></i> Đã chọn sản phẩm trong kho</div>
              </div>
              <div v-else style="display: flex; gap: 8px; margin-top: 9px">
                <input v-model="it.manualName" placeholder="Tên linh kiện ngoài kho"
                  style="flex: 1; height: 36px; background: var(--card2); border: 1px solid var(--line2); border-radius: 8px; color: var(--text); font-size: 12.5px; padding: 0 11px; outline: none; box-sizing: border-box" />
                <input v-model.number="it.extraPrice" type="number" placeholder="Giá đề xuất"
                  style="width: 150px; height: 36px; background: var(--card2); border: 1px solid var(--line2); border-radius: 8px; color: var(--text); font-size: 12.5px; padding: 0 11px; outline: none; box-sizing: border-box" />
              </div>
            </div>

            <div v-if="!form.items.length" style="text-align: center; color: var(--muted); font-size: 12.5px; padding: 18px; border: 1px dashed var(--line2); border-radius: 10px">Chưa có linh kiện. Nhấn "Thêm linh kiện" để bắt đầu.</div>
            <div v-if="formError" style="margin-top: 10px; font-size: 12.5px; color: var(--sale)">{{ formError }}</div>
          </div>
          <div style="display: flex; align-items: center; gap: 12px; padding: 14px 22px; border-top: 1px solid var(--line); flex: none">
            <div style="flex: 1">
              <div style="font-size: 11px; color: var(--muted)">Tổng giá đề xuất ({{ form.items.length }} linh kiện)</div>
              <div class="mono" style="font-size: 18px; font-weight: 700; color: var(--acc)">{{ money(formTotal) }}</div>
            </div>
            <button @click="formOpen = false" style="height: 42px; padding: 0 18px; border-radius: 10px; border: 1px solid var(--line2); background: var(--card); color: var(--text); font-size: 13px; font-weight: 600; cursor: pointer">Hủy</button>
            <button @click="saveForm" :disabled="saving || !form.name.trim()"
              style="height: 42px; padding: 0 24px; border-radius: 10px; border: none; background: var(--acc); color: var(--acc-ink); font-size: 13px; font-weight: 700; cursor: pointer"
              :style="!form.name.trim() ? 'opacity:.45;pointer-events:none;' : ''">
              {{ saving ? 'Đang lưu...' : 'Lưu mẫu' }}
            </button>
          </div>
        </div>
      </div>
    </template>

    <!-- ===== DELETE CONFIRM ===== -->
    <template v-if="confirmId">
      <div @click="confirmId = null" style="position: fixed; inset: 0; background: rgba(2,8,18,.6); backdrop-filter: blur(2px); z-index: 80; display: flex; align-items: center; justify-content: center; padding: 24px">
        <div @click.stop style="width: 100%; max-width: 380px; background: var(--bg); border: 1px solid var(--line2); border-radius: 15px; padding: 22px; box-shadow: 0 20px 60px rgba(0,0,0,.45)">
          <div style="width: 46px; height: 46px; border-radius: 11px; display: flex; align-items: center; justify-content: center; font-size: 20px; background: color-mix(in srgb, var(--sale) 16%, transparent); color: var(--sale); margin-bottom: 14px"><i class="bi bi-exclamation-triangle"></i></div>
          <div style="font-size: 15.5px; font-weight: 700; color: var(--text)">Xóa mẫu cấu hình?</div>
          <div style="font-size: 13px; color: var(--muted2); margin-top: 8px; line-height: 1.5">Mẫu <b style="color: var(--text)">{{ confirmName }}</b> và toàn bộ linh kiện của nó sẽ bị xóa vĩnh viễn. Hành động này không thể hoàn tác.</div>
          <div style="display: flex; gap: 10px; margin-top: 20px">
            <button @click="confirmId = null" style="flex: 1; height: 40px; border-radius: 10px; border: 1px solid var(--line2); background: var(--card); color: var(--text); font-size: 13px; font-weight: 600; cursor: pointer">Hủy</button>
            <button @click="doDelete" style="flex: 1; height: 40px; border-radius: 10px; border: none; background: var(--sale); color: #fff; font-size: 13px; font-weight: 700; cursor: pointer">Xóa mẫu</button>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { money, short } from '../data/adminData';
import { ui } from '../uiState';
import DataTable from '../components/DataTable.vue';
import { TYPES, typeInfo } from '../data/kitComponentTypes';
import {
  getKitTemplates, getKitTemplateDetail, createKitTemplate,
  updateKitTemplate, deleteKitTemplate, searchKitVariants,
} from '../api/admin';

function segStyle(active) {
  return active ? 'background:var(--acc);color:var(--acc-ink);' : 'background:var(--card);color:var(--muted2);';
}

const loading = ref(true);
const templates = ref([]);
const detail = ref(null);
const formOpen = ref(false);
const formMode = ref('create');
const formError = ref('');
const saving = ref(false);
const confirmId = ref(null);

const form = reactive({ id: null, name: '', description: '', items: [] });
let uidCounter = 9000;
function blankItem(type) {
  return { uid: ++uidCounter, type, source: 'stock', variantId: null, variantLabel: '', manualName: '', extraPrice: null, _results: [] };
}

async function load() {
  loading.value = true;
  try {
    templates.value = await getKitTemplates();
  } finally {
    loading.value = false;
  }
}

// Tìm theo từ khoá đã do DataTable đảm nhận (quét mọi cột, bỏ dấu).
const rows = computed(() =>
  templates.value.map((t) => ({
    ...t,
    chips: (t.componentTypes || []).slice(0, 7).map((k) => typeInfo(k).icon),
    moreCount: (t.componentTypes || []).length > 7 ? t.componentTypes.length - 7 : 0,
  })),
);

// Cột cho DataTable — phễu lọc/sắp xếp kiểu Excel trên từng cột (xem components/DataTable.vue).
const cols = [
  { key: 'name', label: 'Mẫu cấu hình' },
  { key: 'itemCount', label: 'Linh kiện', kieu: 'so', text: (t) => t.itemCount + ' linh kiện' },
  { key: 'totalSuggestedPrice', label: 'Tổng giá đề xuất', align: 'right', kieu: 'so',
    text: (t) => money(t.totalSuggestedPrice) },
  { key: 'thaoTac', label: 'Thao tác', align: 'right', loc: false },
];

const stats = computed(() => {
  const totals = templates.value.map((t) => Number(t.totalSuggestedPrice) || 0);
  const allItems = templates.value.reduce((a, t) => a + (t.itemCount || 0), 0);
  const avg = totals.length ? Math.round(totals.reduce((a, b) => a + b, 0) / totals.length) : 0;
  const max = totals.length ? Math.max(...totals) : 0;
  return [
    { icon: 'bi-collection', label: 'Tổng số mẫu', value: String(templates.value.length), color: 'var(--acc)' },
    { icon: 'bi-cpu', label: 'Tổng linh kiện', value: String(allItems), color: 'var(--acc)' },
    { icon: 'bi-cash-stack', label: 'Giá đề xuất TB', value: short(avg), color: 'var(--green)' },
    { icon: 'bi-graph-up-arrow', label: 'Mẫu cao nhất', value: short(max), color: 'var(--amber)' },
  ];
});

const formTotal = computed(() =>
  form.items.reduce((a, it) => {
    if (it.source === 'external') return a + (Number(it.extraPrice) || 0);
    return a + (it._price || 0);
  }, 0),
);

const confirmName = computed(() => (templates.value.find((t) => t.id === confirmId.value) || {}).name || '');

async function openDetail(id) {
  detail.value = await getKitTemplateDetail(id);
}

function openCreate() {
  formError.value = '';
  formMode.value = 'create';
  form.id = null;
  form.name = '';
  form.description = '';
  form.items = ['CPU', 'Mainboard', 'RAM', 'GPU', 'SSD', 'PSU', 'Case'].map(blankItem);
  formOpen.value = true;
}

async function openEdit(id) {
  formError.value = '';
  const d = await getKitTemplateDetail(id);
  formMode.value = 'edit';
  form.id = d.id;
  form.name = d.name;
  form.description = d.description || '';
  form.items = d.items.map((it) => {
    const item = blankItem(it.componentType);
    item.source = it.source;
    if (it.source === 'stock') {
      item.variantId = it.variantId;
      item.variantLabel = it.displayName + ' — ' + money(it.price);
      item._price = it.price;
    } else {
      item.manualName = it.displayName;
      item.extraPrice = it.price;
    }
    return item;
  });
  detail.value = null;
  formOpen.value = true;
}

async function duplicate(id) {
  const d = await getKitTemplateDetail(id);
  const payload = {
    name: d.name + ' (Sao chép)',
    description: d.description,
    items: d.items.map((it, i) => ({
      componentType: it.componentType,
      source: it.source,
      variantId: it.source === 'stock' ? it.variantId : null,
      manualName: it.source === 'external' ? it.displayName : null,
      extraPrice: it.price,
      sortOrder: i,
    })),
  };
  await createKitTemplate(payload);
  detail.value = null;
  confirmId.value = null;
  await load();
}

function addFormItem() {
  form.items.push(blankItem('CPU'));
}

let searchTimer = null;
function onStockSearch(it) {
  it.variantId = null;
  clearTimeout(searchTimer);
  const keyword = it.variantLabel.trim();
  if (!keyword) {
    it._results = [];
    return;
  }
  searchTimer = setTimeout(async () => {
    it._results = await searchKitVariants(keyword, it.type);
  }, 280);
}
function pickVariant(it, p) {
  it.variantId = p.variantId;
  it.variantLabel = p.productName + ' — ' + money(p.price);
  it._price = p.price;
  it._results = [];
}

async function saveForm() {
  if (!form.name.trim()) return;
  for (const it of form.items) {
    if (it.source === 'stock' && !it.variantId) {
      formError.value = `Linh kiện "${typeInfo(it.type).label}" lấy từ kho phải chọn 1 sản phẩm có sẵn`;
      return;
    }
    if (it.source === 'external' && !it.manualName.trim()) {
      formError.value = `Linh kiện "${typeInfo(it.type).label}" ngoài kho phải nhập tên`;
      return;
    }
  }
  formError.value = '';
  saving.value = true;
  const payload = {
    name: form.name.trim(),
    description: form.description,
    items: form.items.map((it, i) => ({
      componentType: it.type,
      source: it.source,
      variantId: it.source === 'stock' ? it.variantId : null,
      manualName: it.source === 'external' ? it.manualName : null,
      extraPrice: it.source === 'external' ? it.extraPrice : null,
      sortOrder: i,
    })),
  };
  try {
    if (form.id == null) {
      await createKitTemplate(payload);
    } else {
      await updateKitTemplate(form.id, payload);
    }
    formOpen.value = false;
    await load();
  } catch (e) {
    formError.value = e?.response?.data?.message || 'Có lỗi khi lưu mẫu cấu hình';
  } finally {
    saving.value = false;
  }
}

async function doDelete() {
  const id = confirmId.value;
  await deleteKitTemplate(id);
  confirmId.value = null;
  if (detail.value && detail.value.id === id) detail.value = null;
  await load();
}

onMounted(load);
</script>
