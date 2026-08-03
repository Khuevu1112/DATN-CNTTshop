<template>
  <div style="animation: fadeUp 0.35s ease">
    <!-- Tab -->
    <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 18px">
      <button
        v-for="t in TABS"
        :key="t.ma"
        class="tab-chip"
        :class="{ active: tab === t.ma }"
        @click="tab = t.ma"
      >
        <i class="bi" :class="t.icon"></i>
        {{ t.ten }}
      </button>
    </div>

    <div v-if="loading" class="spin"></div>

    <template v-else>
      <!-- ============ TRUNG TÂM BẢO HÀNH ============ -->
      <section v-if="tab === 'trung-tam'">
        <div class="sec-head">
          <div>
            <div class="sec-title">Trung tâm bảo hành</div>
            <div class="sec-sub">
              Điểm dịch vụ hiển thị cho khách ở trang "Trung tâm bảo hành". Điểm chưa cắm toạ độ
              sẽ không lọt vào kết quả tìm "gần tôi nhất".
            </div>
          </div>
          <button v-if="coQuyen('add')" class="btn-acc" style="height: 40px; width: auto; padding: 0 18px" @click="moForm('center')">
            <i class="bi bi-plus-lg"></i> Thêm trung tâm
          </button>
        </div>

        <div class="tbl-wrap">
          <table class="tbl">
            <thead>
              <tr>
                <th style="min-width: 200px">Tên</th>
                <th style="min-width: 220px">Địa chỉ</th>
                <th style="width: 130px">Liên hệ</th>
                <th style="width: 150px">Nhận sửa</th>
                <th style="width: 100px">Trạng thái</th>
                <th style="width: 110px"></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="c in centers" :key="c.id">
                <td>
                  <div style="font-weight: 600; color: var(--text)">{{ c.ten }}</div>
                  <div style="font-size: 11.5px; color: var(--muted); margin-top: 3px">
                    {{ c.loai === 'uy_quyen' ? 'Uỷ quyền' : 'Chi nhánh' }}
                    <span v-if="!c.hienThi" style="color: var(--danger, #ff5d7a)"> · đang ẩn</span>
                    <span v-if="c.lat == null" style="color: var(--warn, #f5a524)"> · chưa cắm toạ độ</span>
                  </div>
                </td>
                <td style="color: var(--muted2)">
                  {{ c.diaChi }}
                  <div v-if="c.tenTinh" style="font-size: 11.5px; color: var(--muted); margin-top: 3px">
                    {{ c.tenTinh }}
                  </div>
                </td>
                <td style="color: var(--muted2); font-size: 12.3px">
                  <div v-if="c.dienThoai">{{ c.dienThoai }}</div>
                  <div v-if="c.gioMoCua" style="font-size: 11.3px; color: var(--muted); margin-top: 3px">
                    {{ c.gioMoCua }}
                  </div>
                </td>
                <td>
                  <div style="display: flex; gap: 4px; flex-wrap: wrap">
                    <span v-for="d in c.dichVu" :key="d" class="mini-tag">{{ tenLoai(d) }}</span>
                  </div>
                </td>
                <td>
                  <span class="badge" :style="c.nhanDatLich ? okStyle : offStyle">
                    {{ c.nhanDatLich ? 'Nhận lịch' : 'Không nhận' }}
                  </span>
                </td>
                <td>
                  <div style="display: flex; gap: 6px; justify-content: flex-end">
                    <button v-if="coQuyen('edit')" class="ico-btn" @click="moForm('center', c)">
                      <i class="bi bi-pencil"></i>
                    </button>
                    <button v-if="coQuyen('delete')" class="ico-btn danger" @click="xoa('center', c)">
                      <i class="bi bi-trash"></i>
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="!centers.length">
                <td colspan="6" class="empty">Chưa có trung tâm nào.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <!-- ============ BẢNG GIÁ SỬA CHỮA ============ -->
      <section v-if="tab === 'bang-gia'">
        <div class="sec-head">
          <div>
            <div class="sec-title">Bảng giá sửa chữa</div>
            <div class="sec-sub">
              Giá công bố cho khách tham khảo. Tổng dự kiến = giá linh kiện + tiền công; điền
              "giá đến" khi cần báo một khoảng thay vì một con số.
            </div>
          </div>
          <button v-if="coQuyen('add')" class="btn-acc" style="height: 40px; width: auto; padding: 0 18px" @click="moForm('price')">
            <i class="bi bi-plus-lg"></i> Thêm hạng mục
          </button>
        </div>

        <div class="tbl-wrap">
          <table class="tbl">
            <thead>
              <tr>
                <th style="width: 120px">Thiết bị</th>
                <th style="min-width: 200px">Hạng mục</th>
                <th style="width: 110px; text-align: right">Linh kiện</th>
                <th style="width: 100px; text-align: right">Tiền công</th>
                <th style="width: 110px; text-align: right">Giá đến</th>
                <th style="width: 100px">Thời gian</th>
                <th style="width: 70px; text-align: center">BH</th>
                <th style="width: 90px; text-align: center">Hiện</th>
                <th style="width: 110px"></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="g in prices" :key="g.id">
                <td><span class="mini-tag">{{ tenLoai(g.loaiThietBi) }}</span></td>
                <td>
                  <div style="font-weight: 600; color: var(--text)">{{ g.tenLoi }}</div>
                  <div v-if="g.ghiChu" style="font-size: 11.5px; color: var(--muted); margin-top: 3px">
                    {{ g.ghiChu }}
                  </div>
                </td>
                <td style="text-align: right; color: var(--muted2)">{{ fmt(g.giaLinhKien) }}</td>
                <td style="text-align: right; color: var(--muted2)">{{ fmt(g.tienCong) }}</td>
                <td style="text-align: right; color: var(--text); font-weight: 600">
                  {{ g.giaDen != null ? fmt(g.giaDen) : '—' }}
                </td>
                <td style="color: var(--muted2); font-size: 12.3px">{{ g.thoiGianDuKien || '—' }}</td>
                <td style="text-align: center; color: var(--muted2); font-size: 12.3px">
                  {{ g.baoHanhThang }}t
                </td>
                <td style="text-align: center">
                  <span class="badge" :style="g.hienThi ? okStyle : offStyle">
                    {{ g.hienThi ? 'Đang hiện' : 'Đang ẩn' }}
                  </span>
                </td>
                <td>
                  <div style="display: flex; gap: 6px; justify-content: flex-end">
                    <button v-if="coQuyen('edit')" class="ico-btn" @click="moForm('price', g)">
                      <i class="bi bi-pencil"></i>
                    </button>
                    <button v-if="coQuyen('delete')" class="ico-btn danger" @click="xoa('price', g)">
                      <i class="bi bi-trash"></i>
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="!prices.length">
                <td colspan="9" class="empty">Chưa có hạng mục sửa chữa nào.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <!-- ============ CHÍNH SÁCH BẢO HÀNH ============ -->
      <section v-if="tab === 'chinh-sach'">
        <div class="sec-head">
          <div>
            <div class="sec-title">Thời hạn bảo hành theo nhóm hàng</div>
            <div class="sec-sub">
              Công bố ở trang "Thông tin bảo hành". Đây là chính sách theo NHÓM — thời hạn của
              từng sản phẩm cụ thể vẫn lấy từ trường "Bảo hành (tháng)" trong màn hình Sản phẩm.
            </div>
          </div>
          <button v-if="coQuyen('add')" class="btn-acc" style="height: 40px; width: auto; padding: 0 18px" @click="moForm('policy')">
            <i class="bi bi-plus-lg"></i> Thêm nhóm hàng
          </button>
        </div>

        <div class="tbl-wrap">
          <table class="tbl">
            <thead>
              <tr>
                <th style="min-width: 200px">Nhóm hàng</th>
                <th style="width: 100px; text-align: center">Thời hạn</th>
                <th style="width: 160px">Tính từ</th>
                <th style="min-width: 240px">Ghi chú</th>
                <th style="width: 110px"></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="p in policies" :key="p.id">
                <td style="font-weight: 600; color: var(--text)">{{ p.nhomHang }}</td>
                <td style="text-align: center">
                  <span class="badge" :style="accStyle">{{ p.soThang }} tháng</span>
                </td>
                <td style="color: var(--muted2); font-size: 12.5px">{{ p.tinhTu }}</td>
                <td style="color: var(--muted2); font-size: 12.5px; line-height: 1.55">{{ p.moTa }}</td>
                <td>
                  <div style="display: flex; gap: 6px; justify-content: flex-end">
                    <button v-if="coQuyen('edit')" class="ico-btn" @click="moForm('policy', p)">
                      <i class="bi bi-pencil"></i>
                    </button>
                    <button v-if="coQuyen('delete')" class="ico-btn danger" @click="xoa('policy', p)">
                      <i class="bi bi-trash"></i>
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="!policies.length">
                <td colspan="5" class="empty">Chưa có chính sách nào.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <!-- ============ FAQ ============ -->
      <section v-if="tab === 'faq'">
        <div class="sec-head">
          <div>
            <div class="sec-title">Câu hỏi thường gặp</div>
            <div class="sec-sub">
              Lượt xem đếm mỗi lần khách bung câu trả lời — dùng để biết câu nào thật sự hữu ích.
            </div>
          </div>
          <button v-if="coQuyen('add')" class="btn-acc" style="height: 40px; width: auto; padding: 0 18px" @click="moForm('faq')">
            <i class="bi bi-plus-lg"></i> Thêm câu hỏi
          </button>
        </div>

        <div class="tbl-wrap">
          <table class="tbl">
            <thead>
              <tr>
                <th style="width: 170px">Danh mục</th>
                <th style="min-width: 300px">Câu hỏi</th>
                <th style="width: 90px; text-align: center">Nổi bật</th>
                <th style="width: 90px; text-align: center">Lượt xem</th>
                <th style="width: 110px"></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="f in faqs" :key="f.id">
                <td><span class="mini-tag">{{ f.tenDanhMuc }}</span></td>
                <td>
                  <div style="font-weight: 600; color: var(--text)">{{ f.cauHoi }}</div>
                  <div
                    style="
                      font-size: 11.8px;
                      color: var(--muted);
                      margin-top: 4px;
                      display: -webkit-box;
                      -webkit-line-clamp: 2;
                      -webkit-box-orient: vertical;
                      overflow: hidden;
                    "
                  >
                    {{ f.traLoi }}
                  </div>
                </td>
                <td style="text-align: center">
                  <span v-if="f.noiBat" class="badge" :style="accStyle">Nổi bật</span>
                  <span v-else style="color: var(--muted)">—</span>
                </td>
                <td class="mono" style="text-align: center; color: var(--muted2)">{{ f.luotXem }}</td>
                <td>
                  <div style="display: flex; gap: 6px; justify-content: flex-end">
                    <button v-if="coQuyen('edit')" class="ico-btn" @click="moForm('faq', f)">
                      <i class="bi bi-pencil"></i>
                    </button>
                    <button v-if="coQuyen('delete')" class="ico-btn danger" @click="xoa('faq', f)">
                      <i class="bi bi-trash"></i>
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="!faqs.length">
                <td colspan="5" class="empty">Chưa có câu hỏi nào.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
    </template>

    <!-- ============ FORM ============ -->
    <div v-if="form" class="modal-bd" @click.self="form = null">
      <div class="modal-bx">
        <div class="modal-hd">
          <div style="font-size: 15px; font-weight: 700; color: var(--text)">{{ tieuDeForm }}</div>
          <button class="ico-btn" @click="form = null"><i class="bi bi-x-lg"></i></button>
        </div>

        <div class="modal-bd-in">
          <div v-if="loiForm" class="alert-err">{{ loiForm }}</div>

          <!-- Trung tâm -->
          <template v-if="form.kind === 'center'">
            <div class="fgrid">
              <label class="fw"><span>Tên trung tâm *</span><input v-model="form.ten" class="fld" /></label>
              <label><span>Loại</span>
                <select v-model="form.loai" class="fld">
                  <option value="chi_nhanh">Chi nhánh CNTTShop</option>
                  <option value="uy_quyen">Trung tâm uỷ quyền</option>
                </select>
              </label>
            </div>
            <label class="fw"><span>Địa chỉ *</span><input v-model="form.diaChi" class="fld" /></label>
            <div class="fgrid">
              <label><span>Tỉnh / Thành phố</span>
                <select v-model="form.provinceId" class="fld">
                  <option :value="null">— Chọn —</option>
                  <option v-for="p in provinces" :key="p.id" :value="p.id">{{ p.name }}</option>
                </select>
              </label>
              <label><span>Giờ mở cửa</span>
                <input v-model="form.gioMoCua" class="fld" placeholder="T2-T7: 8:00-18:00" />
              </label>
            </div>
            <div class="fgrid">
              <label><span>Vĩ độ (lat)</span><input v-model="form.lat" class="fld" placeholder="20.8248" /></label>
              <label><span>Kinh độ (lng)</span><input v-model="form.lng" class="fld" placeholder="106.7169" /></label>
            </div>
            <div style="font-size: 11.5px; color: var(--muted); margin-top: -6px">
              Không có toạ độ thì điểm này vẫn hiện trong danh sách nhưng không bao giờ lọt vào
              kết quả "gần tôi nhất" và không có ghim trên bản đồ.
            </div>
            <div class="fgrid">
              <label><span>Điện thoại</span><input v-model="form.dienThoai" class="fld" /></label>
              <label><span>Email</span><input v-model="form.email" class="fld" /></label>
            </div>
            <div>
              <span class="lbl">Nhóm thiết bị nhận sửa</span>
              <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-top: 8px">
                <button
                  v-for="l in LOAI_LIST"
                  :key="l.ma"
                  type="button"
                  class="pick"
                  :class="{ on: form.dichVu.includes(l.ma) }"
                  @click="toggleDichVu(l.ma)"
                >
                  {{ l.ten }}
                </button>
              </div>
            </div>
            <label class="fw"><span>Ghi chú</span><input v-model="form.ghiChu" class="fld" /></label>
            <div class="fgrid">
              <label class="chk">
                <input type="checkbox" v-model="form.nhanDatLich" /> <span>Nhận đặt lịch</span>
              </label>
              <label class="chk">
                <input type="checkbox" v-model="form.hienThi" /> <span>Hiển thị với khách</span>
              </label>
            </div>
          </template>

          <!-- Bảng giá -->
          <template v-else-if="form.kind === 'price'">
            <div class="fgrid">
              <label><span>Loại thiết bị *</span>
                <select v-model="form.loaiThietBi" class="fld">
                  <option value="">— Chọn —</option>
                  <option v-for="l in LOAI_LIST" :key="l.ma" :value="l.ma">{{ l.ten }}</option>
                </select>
              </label>
              <label><span>Hãng (để trống = mọi hãng)</span><input v-model="form.hang" class="fld" /></label>
            </div>
            <label class="fw"><span>Tên hạng mục *</span>
              <input v-model="form.tenLoi" class="fld" placeholder="vd: Thay màn hình vỡ / sọc" />
            </label>
            <div class="fgrid">
              <label><span>Giá linh kiện (đ)</span><input v-model="form.giaLinhKien" type="number" class="fld" /></label>
              <label><span>Tiền công (đ)</span><input v-model="form.tienCong" type="number" class="fld" /></label>
            </div>
            <label class="fw"><span>Giá đến (đ) — để trống nếu báo một con số</span>
              <input v-model="form.giaDen" type="number" class="fld" />
            </label>
            <div style="font-size: 11.5px; color: var(--muted); margin-top: -6px">
              Phải lớn hơn hoặc bằng (giá linh kiện + tiền công), nếu không khách sẽ thấy khoảng
              giá ngược kiểu "5tr – 2tr".
            </div>
            <div class="fgrid">
              <label><span>Thời gian dự kiến</span><input v-model="form.thoiGianDuKien" class="fld" placeholder="2-4 giờ" /></label>
              <label><span>Bảo hành lần sửa (tháng)</span><input v-model="form.baoHanhThang" type="number" class="fld" /></label>
            </div>
            <label class="fw"><span>Ghi chú</span><input v-model="form.ghiChu" class="fld" /></label>
            <label class="chk"><input type="checkbox" v-model="form.hienThi" /> <span>Hiển thị với khách</span></label>
          </template>

          <!-- Chính sách -->
          <template v-else-if="form.kind === 'policy'">
            <label class="fw"><span>Nhóm hàng *</span><input v-model="form.nhomHang" class="fld" /></label>
            <div class="fgrid">
              <label><span>Số tháng bảo hành *</span><input v-model="form.soThang" type="number" class="fld" /></label>
              <label><span>Tính từ</span><input v-model="form.tinhTu" class="fld" placeholder="Ngày xuất hoá đơn" /></label>
            </div>
            <label class="fw"><span>Ghi chú / điều kiện</span>
              <textarea v-model="form.moTa" class="fld" rows="3" style="padding: 10px 14px; resize: vertical"></textarea>
            </label>
            <label class="chk"><input type="checkbox" v-model="form.hienThi" /> <span>Hiển thị với khách</span></label>
          </template>

          <!-- FAQ -->
          <template v-else-if="form.kind === 'faq'">
            <label class="fw"><span>Danh mục *</span>
              <select v-model="form.categoryId" class="fld">
                <option :value="null">— Chọn —</option>
                <option v-for="c in faqCategories" :key="c.id" :value="c.id">{{ c.ten }}</option>
              </select>
            </label>
            <label class="fw"><span>Câu hỏi *</span><input v-model="form.cauHoi" class="fld" /></label>
            <label class="fw"><span>Câu trả lời *</span>
              <textarea v-model="form.traLoi" class="fld" rows="6" style="padding: 10px 14px; resize: vertical"></textarea>
            </label>
            <label class="fw"><span>Từ khoá phụ (cách nhau bằng dấu phẩy)</span>
              <input v-model="form.tuKhoa" class="fld" placeholder="ship, van chuyen, giao hang" />
            </label>
            <div style="font-size: 11.5px; color: var(--muted); margin-top: -6px">
              Dùng khi khách gõ từ khác với chữ trong câu trả lời — vd khách gõ "ship" nhưng bài
              viết "vận chuyển".
            </div>
            <div class="fgrid">
              <label class="chk"><input type="checkbox" v-model="form.noiBat" /> <span>Câu hỏi nổi bật</span></label>
              <label class="chk"><input type="checkbox" v-model="form.hienThi" /> <span>Hiển thị với khách</span></label>
            </div>
          </template>
        </div>

        <div class="modal-ft">
          <button class="btn-ghost" @click="form = null">Huỷ</button>
          <button class="btn-acc" style="height: 42px; width: auto; padding: 0 22px" :disabled="dangLuu" @click="luu">
            {{ dangLuu ? 'Đang lưu...' : 'Lưu' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { usePermissionsStore } from '../stores/permissions';
import {
  getSupportCenters, createSupportCenter, updateSupportCenter, deleteSupportCenter,
  getRepairPrices, createRepairPrice, updateRepairPrice, deleteRepairPrice,
  getWarrantyPolicies, createWarrantyPolicy, updateWarrantyPolicy, deleteWarrantyPolicy,
  getFaqItems, getFaqCategories, createFaqItem, updateFaqItem, deleteFaqItem,
  getProvinces,
} from '../api/admin';

const permissions = usePermissionsStore();
const coQuyen = (p) => permissions.hasPerm('support_content', p);

const TABS = [
  { ma: 'trung-tam', ten: 'Trung tâm bảo hành', icon: 'bi-geo-alt' },
  { ma: 'bang-gia', ten: 'Bảng giá sửa chữa', icon: 'bi-receipt' },
  { ma: 'chinh-sach', ten: 'Chính sách bảo hành', icon: 'bi-shield-check' },
  { ma: 'faq', ten: 'Câu hỏi thường gặp', icon: 'bi-chat-dots' },
];

// Mã phải khớp CSDL (xem 66_support_center.sql) — đổi ở đây mà không migration thì bộ lọc trung
// tâm phía khách im lặng trả về rỗng.
const LOAI_LIST = [
  { ma: 'laptop', ten: 'Laptop' },
  { ma: 'pc', ten: 'PC / Máy bàn' },
  { ma: 'man_hinh', ten: 'Màn hình' },
  { ma: 'linh_kien', ten: 'Linh kiện lẻ' },
  { ma: 'ngoai_vi', ten: 'Thiết bị ngoại vi' },
];
const tenLoai = (m) => LOAI_LIST.find((l) => l.ma === m)?.ten || m;

const tab = ref('trung-tam');
const loading = ref(true);
const centers = ref([]);
const prices = ref([]);
const policies = ref([]);
const faqs = ref([]);
const faqCategories = ref([]);
const provinces = ref([]);

const form = ref(null);
const loiForm = ref('');
const dangLuu = ref(false);

const okStyle = { background: 'color-mix(in srgb, var(--ok, #2bd47e) 14%, transparent)', color: 'var(--ok, #2bd47e)' };
const offStyle = { background: 'color-mix(in srgb, var(--muted2) 14%, transparent)', color: 'var(--muted2)' };
const accStyle = { background: 'color-mix(in srgb, var(--acc) 14%, transparent)', color: 'var(--acc)' };

const fmt = (n) => (n == null ? '—' : Number(n).toLocaleString('vi-VN') + 'đ');

const tieuDeForm = computed(() => {
  if (!form.value) return '';
  const ten = {
    center: 'trung tâm bảo hành',
    price: 'hạng mục sửa chữa',
    policy: 'chính sách bảo hành',
    faq: 'câu hỏi thường gặp',
  }[form.value.kind];
  return (form.value.id ? 'Sửa ' : 'Thêm ') + ten;
});

async function tai() {
  loading.value = true;
  try {
    const [c, p, ch, f, dm, tinh] = await Promise.all([
      getSupportCenters(), getRepairPrices(), getWarrantyPolicies(),
      getFaqItems(), getFaqCategories(), getProvinces(),
    ]);
    centers.value = c;
    prices.value = p;
    policies.value = ch;
    faqs.value = f;
    faqCategories.value = dm;
    provinces.value = tinh;
  } catch (e) {
    // Phòng ban chỉ có quyền "view" một phần vẫn phải vào được trang — để rỗng thay vì chặn.
  } finally {
    loading.value = false;
  }
}

function moForm(kind, row) {
  loiForm.value = '';
  if (kind === 'center') {
    form.value = row
      ? {
          kind, id: row.id, ten: row.ten, diaChi: row.diaChi, provinceId: row.provinceId,
          lat: row.lat, lng: row.lng, dienThoai: row.dienThoai, email: row.email,
          gioMoCua: row.gioMoCua, dichVu: [...(row.dichVu || [])], loai: row.loai,
          nhanDatLich: row.nhanDatLich, ghiChu: row.ghiChu,
          hienThi: row.hienThi, sortOrder: row.sortOrder,
        }
      : {
          kind, id: null, ten: '', diaChi: '', provinceId: null, lat: '', lng: '',
          dienThoai: '', email: '', gioMoCua: '', dichVu: [], loai: 'chi_nhanh',
          nhanDatLich: true, ghiChu: '', hienThi: true, sortOrder: 100,
        };
  } else if (kind === 'price') {
    form.value = row
      ? {
          kind, id: row.id, loaiThietBi: row.loaiThietBi, hang: row.hang, dongMay: row.dongMay,
          maLoi: row.maLoi, tenLoi: row.tenLoi, giaLinhKien: row.giaLinhKien,
          tienCong: row.tienCong, giaDen: row.giaDen, thoiGianDuKien: row.thoiGianDuKien,
          baoHanhThang: row.baoHanhThang, ghiChu: row.ghiChu,
          hienThi: row.hienThi, sortOrder: row.sortOrder,
        }
      : {
          kind, id: null, loaiThietBi: '', hang: '', dongMay: '', maLoi: '', tenLoi: '',
          giaLinhKien: 0, tienCong: 0, giaDen: null, thoiGianDuKien: '', baoHanhThang: 3,
          ghiChu: '', hienThi: true, sortOrder: 100,
        };
  } else if (kind === 'policy') {
    form.value = row
      ? { kind, id: row.id, nhomHang: row.nhomHang, soThang: row.soThang, moTa: row.moTa,
          tinhTu: row.tinhTu, hienThi: row.hienThi, sortOrder: row.sortOrder }
      : { kind, id: null, nhomHang: '', soThang: 12, moTa: '', tinhTu: 'Ngày xuất hoá đơn',
          hienThi: true, sortOrder: 100 };
  } else {
    form.value = row
      ? { kind, id: row.id, categoryId: row.categoryId, cauHoi: row.cauHoi, traLoi: row.traLoi,
          tuKhoa: row.tuKhoa || '', noiBat: row.noiBat, hienThi: row.hienThi, sortOrder: row.sortOrder }
      : { kind, id: null, categoryId: null, cauHoi: '', traLoi: '', tuKhoa: '', noiBat: false,
          hienThi: true, sortOrder: 100 };
  }
}

function toggleDichVu(ma) {
  const i = form.value.dichVu.indexOf(ma);
  if (i >= 0) form.value.dichVu.splice(i, 1);
  else form.value.dichVu.push(ma);
}

/** Ô số để trống trả về chuỗi rỗng — gửi thẳng lên sẽ thành 0 hoặc lỗi ép kiểu, nên chuẩn hoá
 * về null ở đây. */
function so(v) {
  if (v === '' || v === null || v === undefined) return null;
  const n = Number(v);
  return Number.isNaN(n) ? null : n;
}

async function luu() {
  loiForm.value = '';
  dangLuu.value = true;
  const f = form.value;
  try {
    if (f.kind === 'center') {
      const body = {
        ten: f.ten, diaChi: f.diaChi, provinceId: f.provinceId, wardId: null,
        lat: so(f.lat), lng: so(f.lng), dienThoai: f.dienThoai, email: f.email,
        gioMoCua: f.gioMoCua, dichVu: f.dichVu, loai: f.loai,
        nhanDatLich: f.nhanDatLich, ghiChu: f.ghiChu, hienThi: f.hienThi, sortOrder: f.sortOrder,
      };
      f.id ? await updateSupportCenter(f.id, body) : await createSupportCenter(body);
    } else if (f.kind === 'price') {
      const body = {
        loaiThietBi: f.loaiThietBi, hang: f.hang || null, dongMay: f.dongMay || null,
        maLoi: f.maLoi || null, tenLoi: f.tenLoi,
        giaLinhKien: so(f.giaLinhKien) ?? 0, tienCong: so(f.tienCong) ?? 0, giaDen: so(f.giaDen),
        thoiGianDuKien: f.thoiGianDuKien || null, baoHanhThang: so(f.baoHanhThang) ?? 3,
        ghiChu: f.ghiChu || null, hienThi: f.hienThi, sortOrder: f.sortOrder,
      };
      f.id ? await updateRepairPrice(f.id, body) : await createRepairPrice(body);
    } else if (f.kind === 'policy') {
      const body = {
        nhomHang: f.nhomHang, soThang: so(f.soThang), moTa: f.moTa || null,
        tinhTu: f.tinhTu, hienThi: f.hienThi, sortOrder: f.sortOrder,
      };
      f.id ? await updateWarrantyPolicy(f.id, body) : await createWarrantyPolicy(body);
    } else {
      const body = {
        categoryId: f.categoryId, cauHoi: f.cauHoi, traLoi: f.traLoi,
        tuKhoa: f.tuKhoa || null, noiBat: f.noiBat, hienThi: f.hienThi, sortOrder: f.sortOrder,
      };
      f.id ? await updateFaqItem(f.id, body) : await createFaqItem(body);
    }
    form.value = null;
    await tai();
  } catch (e) {
    loiForm.value = e?.response?.data?.message || 'Lưu thất bại, kiểm tra lại dữ liệu đã nhập.';
  } finally {
    dangLuu.value = false;
  }
}

async function xoa(kind, row) {
  const nhan = { center: row.ten, price: row.tenLoi, policy: row.nhomHang, faq: row.cauHoi }[kind];
  if (!confirm(`Xoá "${nhan}"?`)) return;
  try {
    if (kind === 'center') await deleteSupportCenter(row.id);
    else if (kind === 'price') await deleteRepairPrice(row.id);
    else if (kind === 'policy') await deleteWarrantyPolicy(row.id);
    else await deleteFaqItem(row.id);
    await tai();
  } catch (e) {
    alert(e?.response?.data?.message || 'Không xoá được.');
  }
}

onMounted(tai);
</script>

<style scoped>
.sec-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 18px;
  margin-bottom: 16px;
  flex-wrap: wrap;
}
.sec-title {
  font-size: 15px;
  font-weight: 700;
  color: var(--text);
}
.sec-sub {
  font-size: 12.3px;
  color: var(--muted);
  margin-top: 5px;
  max-width: 640px;
  line-height: 1.55;
}

.tbl-wrap {
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 14px;
  overflow: hidden;
}
.tbl {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.tbl th {
  text-align: left;
  padding: 12px 14px;
  font-size: 11.3px;
  letter-spacing: 0.4px;
  color: var(--muted);
  font-weight: 600;
  background: var(--card2);
  border-bottom: 1px solid var(--line);
  white-space: nowrap;
}
.tbl td {
  padding: 13px 14px;
  border-bottom: 1px solid var(--line);
  vertical-align: top;
}
.tbl tbody tr:last-child td {
  border-bottom: none;
}
.tbl tbody tr:hover {
  background: var(--card2);
}
.empty {
  text-align: center;
  padding: 44px 20px;
  color: var(--muted);
}

.mini-tag {
  display: inline-block;
  font-size: 11px;
  color: var(--muted2);
  background: var(--card2);
  border-radius: 6px;
  padding: 3px 8px;
}

.tab-chip {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  background: var(--card);
  border: 1px solid var(--line);
  color: var(--muted2);
  border-radius: 999px;
  padding: 8px 16px;
  font-size: 12.8px;
  cursor: pointer;
  transition: all 0.15s;
}
.tab-chip:hover {
  border-color: var(--acc);
  color: var(--text);
}
.tab-chip.active {
  background: color-mix(in srgb, var(--acc) 14%, transparent);
  border-color: var(--acc);
  color: var(--acc);
  font-weight: 600;
}

.ico-btn {
  width: 30px;
  height: 30px;
  border-radius: 8px;
  background: transparent;
  border: 1px solid var(--line);
  color: var(--muted2);
  cursor: pointer;
  font-size: 12px;
  transition: all 0.15s;
}
.ico-btn:hover {
  border-color: var(--acc);
  color: var(--acc);
}
.ico-btn.danger:hover {
  border-color: var(--danger, #ff5d7a);
  color: var(--danger, #ff5d7a);
}

.btn-ghost {
  background: transparent;
  border: 1px solid var(--line);
  color: var(--muted2);
  border-radius: 10px;
  height: 42px;
  padding: 0 20px;
  font-size: 13px;
  cursor: pointer;
}
.btn-ghost:hover {
  border-color: var(--acc);
  color: var(--acc);
}

.modal-bd {
  position: fixed;
  inset: 0;
  z-index: 2000;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}
.modal-bx {
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 16px;
  width: 100%;
  max-width: 620px;
  max-height: 92vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.modal-hd {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 18px 22px;
  border-bottom: 1px solid var(--line);
}
.modal-bd-in {
  padding: 20px 22px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 14px;
}
.modal-ft {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
  padding: 16px 22px;
  border-top: 1px solid var(--line);
}

.fgrid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}
.fw {
  grid-column: 1 / -1;
}
label span,
.lbl {
  display: block;
  font-size: 11.6px;
  color: var(--muted);
  margin-bottom: 6px;
  font-weight: 500;
}
.chk {
  display: flex !important;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: var(--text);
  cursor: pointer;
}
.chk span {
  margin: 0;
  color: var(--text);
  font-size: 13px;
}

.pick {
  background: var(--card2);
  border: 1px solid var(--line);
  color: var(--muted2);
  border-radius: 8px;
  padding: 7px 13px;
  font-size: 12.3px;
  cursor: pointer;
  transition: all 0.15s;
}
.pick.on {
  background: color-mix(in srgb, var(--acc) 16%, transparent);
  border-color: var(--acc);
  color: var(--acc);
  font-weight: 600;
}

.alert-err {
  background: color-mix(in srgb, var(--danger, #ff5d7a) 12%, transparent);
  border: 1px solid color-mix(in srgb, var(--danger, #ff5d7a) 30%, transparent);
  color: var(--danger, #ff5d7a);
  border-radius: 10px;
  padding: 11px 14px;
  font-size: 12.8px;
}
</style>
