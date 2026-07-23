<template>
  <div
    @click="$emit('close')"
    style="position: fixed; inset: 0; background: rgba(2, 8, 18, 0.6); backdrop-filter: blur(2px); z-index: 70; display: flex; align-items: center; justify-content: center; padding: 24px"
  >
    <div
      @click.stop="closeOnOutsideClick"
      style="width: 100%; max-width: 1180px; max-height: 90vh; background: var(--bg); border: 1px solid var(--line2); border-radius: 16px; display: flex; flex-direction: column; box-shadow: 0 20px 60px rgba(0, 0, 0, 0.45)"
    >
      <div style="display: flex; align-items: center; justify-content: space-between; padding: 18px 22px; border-bottom: 1px solid var(--line); flex: none">
        <div style="font-size: 15px; font-weight: 700; color: var(--text)">Phân quyền theo phòng ban</div>
        <button @click="$emit('close')" style="width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--line2); background: var(--card); color: var(--text); cursor: pointer">
          <i class="bi bi-x-lg" style="font-size: 13px"></i>
        </button>
      </div>

      <div v-if="loading" class="spin" style="margin: 40px auto"></div>
      <div v-else style="flex: 1; overflow-y: auto">
        <div style="padding: 14px 22px; font-size: 12.5px; color: var(--muted)">
          Bấm vào 1 ô để chọn/bỏ quyền cho phòng ban đó ở trang tương ứng. 8 loại quyền là cố định, không thêm/bớt được —
          chỉ gán quyền nào cho phòng ban nào là admin tự chỉnh sửa được.
        </div>

        <div style="overflow-x: auto; padding: 0 22px 20px">
          <table style="border-collapse: collapse; font-size: 12.5px; min-width: 900px; width: 100%">
            <thead>
              <tr style="background: var(--card2)">
                <th style="text-align: left; padding: 10px 14px; font-size: 11px; font-weight: 600; color: var(--muted); text-transform: uppercase; letter-spacing: .4px; position: sticky; left: 0; background: var(--card2); z-index: 1">
                  Trang
                </th>
                <th
                  v-for="d in meta.departments"
                  :key="d"
                  style="text-align: center; padding: 10px 12px; font-size: 11px; font-weight: 600; color: var(--muted); text-transform: uppercase; letter-spacing: .4px; white-space: nowrap"
                >
                  {{ RM[d]?.label || d }}
                </th>
              </tr>
            </thead>
            <tbody>
              <template v-for="grp in groupedFeatures" :key="grp.groupLabel">
                <tr>
                  <td :colspan="meta.departments.length + 1" style="padding: 10px 14px 4px; font-size: 11px; font-weight: 700; color: var(--acc); text-transform: uppercase; letter-spacing: .5px; border-top: 1px solid var(--line)">
                    {{ grp.groupLabel }}
                  </td>
                </tr>
                <tr v-for="f in grp.features" :key="f.key" style="border-top: 1px solid var(--line)">
                  <td style="padding: 9px 14px; color: var(--text); font-weight: 500; white-space: nowrap; position: sticky; left: 0; background: var(--card)">
                    {{ f.label }}
                  </td>
                  <td v-for="d in meta.departments" :key="d" style="padding: 6px 8px; text-align: center; position: relative">
                    <div
                      @click.stop="toggleCell(d, f.key)"
                      style="display: inline-flex; flex-wrap: wrap; gap: 3px; justify-content: center; min-height: 22px; min-width: 60px; padding: 3px 6px; border-radius: 7px; border: 1px solid rgba(var(--line-rgb, 60,64,72), 0.3); cursor: pointer"
                      :style="{ borderColor: openCell === d + '|' + f.key ? 'var(--acc)' : undefined }"
                    >
                      <span
                        v-for="pk in cellPerms(d, f.key)"
                        :key="pk"
                        :style="{ background: permColor(pk) }"
                        :title="permLabel(pk)"
                        style="width: 9px; height: 9px; border-radius: 50%; display: inline-block"
                      ></span>
                      <span v-if="!cellPerms(d, f.key).length" style="color: var(--muted); font-size: 11px">—</span>
                    </div>

                    <div
                      v-if="openCell === d + '|' + f.key"
                      @click.stop
                      style="position: absolute; top: 100%; left: 50%; transform: translateX(-50%); z-index: 20; background: var(--bg); border: 1px solid var(--line2); border-radius: 10px; padding: 8px; box-shadow: 0 14px 34px rgba(0,0,0,.4); min-width: 180px; text-align: left"
                    >
                      <div
                        v-for="pt in meta.permissionTypes"
                        :key="pt.key"
                        @click="togglePerm(d, f.key, pt.key)"
                        style="display: flex; align-items: center; gap: 8px; padding: 5px 6px; border-radius: 6px; cursor: pointer"
                      >
                        <span :style="{ background: pt.color }" style="width: 10px; height: 10px; border-radius: 50%; flex: none"></span>
                        <span style="flex: 1; font-size: 12px; color: var(--text)">{{ pt.label }}</span>
                        <i v-if="cellPerms(d, f.key).includes(pt.key)" class="bi bi-check-lg" style="color: var(--acc); font-size: 12px"></i>
                      </div>
                    </div>
                  </td>
                </tr>
              </template>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { RM } from '../data/adminData';
import { getPermissionMeta, getPermissionMatrix, updatePermissionCell } from '../api/admin';

defineEmits(['close']);

const loading = ref(true);
const meta = ref({ features: [], permissionTypes: [], departments: [] });
const cellMap = ref({}); // "department|featureKey" -> [permKey, ...]
const openCell = ref(null);

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

function cellKey(department, featureKey) {
  return department + '|' + featureKey;
}
function cellPerms(department, featureKey) {
  return cellMap.value[cellKey(department, featureKey)] || [];
}
function permLabel(permKey) {
  return meta.value.permissionTypes.find((p) => p.key === permKey)?.label || permKey;
}
function permColor(permKey) {
  return meta.value.permissionTypes.find((p) => p.key === permKey)?.color || '#7d818a';
}

function toggleCell(department, featureKey) {
  const key = cellKey(department, featureKey);
  openCell.value = openCell.value === key ? null : key;
}

async function togglePerm(department, featureKey, permKey) {
  const key = cellKey(department, featureKey);
  const current = cellMap.value[key] || [];
  const next = current.includes(permKey) ? current.filter((p) => p !== permKey) : [...current, permKey];
  cellMap.value = { ...cellMap.value, [key]: next };
  await updatePermissionCell(department, featureKey, next);
}

// Đóng popover đang mở khi bấm ra chỗ khác TRONG modal (khác với bấm ra nền, việc đó đóng
// cả modal — xử lý ở nền ngoài cùng). Click trên ô/popover đã tự .stop nên không rơi vào đây.
function closeOnOutsideClick() {
  openCell.value = null;
}

onMounted(async () => {
  try {
    const [metaData, matrixData] = await Promise.all([getPermissionMeta(), getPermissionMatrix()]);
    meta.value = metaData;
    const map = {};
    for (const row of matrixData) {
      map[cellKey(row.department, row.featureKey)] = row.permKeys;
    }
    cellMap.value = map;
  } finally {
    loading.value = false;
  }
});
</script>
