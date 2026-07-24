<template>
  <div>
    <div v-if="detail" style="animation: fadeUp 0.3s ease">
      <button
        @click="detail = null"
        style="
          display: inline-flex;
          align-items: center;
          gap: 7px;
          background: none;
          border: none;
          color: var(--muted2);
          font-size: 13px;
          cursor: pointer;
          margin-bottom: 16px;
          font-weight: 500;
        "
      >
        <i class="bi bi-arrow-left"></i> Quay lại danh sách
      </button>
      <div style="display: grid; grid-template-columns: 1.7fr 1fr; gap: 14px">
        <div>
          <div
            style="
              background: var(--card);
              border: 1px solid var(--line);
              border-radius: 14px;
              padding: 20px;
              margin-bottom: 14px;
            "
          >
            <div
              style="
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 18px;
              "
            >
              <div>
                <div
                  class="mono"
                  style="font-size: 20px; font-weight: 700; color: var(--text)"
                >
                  {{ detail.code }}
                </div>
                <div
                  style="
                    font-size: 12.5px;
                    color: var(--muted);
                    margin-top: 3px;
                  "
                >
                  Đặt lúc {{ detail.date }}
                </div>
              </div>
              <span
                style="
                  display: inline-flex;
                  align-items: center;
                  gap: 6px;
                  font-size: 12.5px;
                  font-weight: 600;
                  padding: 6px 13px;
                  border-radius: 20px;
                "
                :style="{ background: detail.stBg, color: detail.stColor }"
                ><span
                  style="width: 7px; height: 7px; border-radius: 50%"
                  :style="{ background: detail.stColor }"
                ></span
                >{{ detail.stLabel }}</span
              >
            </div>
            <div
              v-if="detail.st === 'refunded'"
              style="
                padding: 14px;
                border-radius: 10px;
                background: color-mix(in srgb, var(--sale) 12%, transparent);
                border: 1px solid
                  color-mix(in srgb, var(--sale) 30%, transparent);
                color: var(--sale);
                font-size: 13px;
                display: flex;
                align-items: center;
                gap: 9px;
              "
            >
              <i class="bi bi-arrow-counterclockwise"></i> Đơn hàng đã được hoàn tiền.
            </div>
            <div
              v-else-if="detail.st === 'cancelled'"
              style="
                padding: 14px;
                border-radius: 10px;
                background: color-mix(in srgb, var(--sale) 12%, transparent);
                border: 1px solid
                  color-mix(in srgb, var(--sale) 30%, transparent);
                color: var(--sale);
                font-size: 13px;
              "
            >
              <div style="display: flex; align-items: center; gap: 9px">
                <i class="bi bi-x-octagon-fill"></i> Đơn hàng đã bị huỷ.
              </div>
              <!-- Khách hàng chỉ tự huỷ được đơn CHƯA thanh toán (xem OrderService#huyDon) — nếu
              đơn này đã "paid" mà vẫn về "cancelled" thì chỉ có thể do ADMIN chủ động huỷ đơn đã
              thanh toán, lúc đó mới thật sự cần hoàn tiền. Chưa có trạng thái "trả hàng" riêng
              trong hệ thống — đây là tín hiệu gần đúng nhất hiện có. -->
              <div v-if="detail.paymentStatus === 'paid'" style="margin-top: 6px; font-size: 12px; color: var(--muted2)">
                Đơn đã thanh toán trước khi huỷ — kiểm tra hoàn tiền cho khách nếu cần.
              </div>
            </div>
            <div
              v-else
              style="
                display: flex;
                justify-content: space-between;
                position: relative;
                margin-top: 6px;
              "
            >
              <div
                v-for="t in timeline"
                :key="t.label"
                style="
                  flex: 1;
                  display: flex;
                  flex-direction: column;
                  align-items: center;
                  gap: 8px;
                "
              >
                <div
                  style="
                    width: 38px;
                    height: 38px;
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 15px;
                    background: var(--card2);
                  "
                  :style="{ border: '2px solid ' + t.color, color: t.color }"
                >
                  <i class="bi" :class="t.icon"></i>
                </div>
                <span
                  style="font-size: 11.5px; font-weight: 500"
                  :style="{ color: t.color }"
                  >{{ t.label }}</span
                >
              </div>
            </div>
          </div>
          <div
            style="
              background: var(--card);
              border: 1px solid var(--line);
              border-radius: 14px;
              overflow: hidden;
              margin-bottom: 14px;
            "
          >
            <div
              style="
                padding: 14px 18px;
                font-size: 14px;
                font-weight: 600;
                color: var(--text);
                border-bottom: 1px solid var(--line);
              "
            >
              Lịch sử đơn hàng
            </div>
            <div v-if="loadingExtra" style="padding: 18px; font-size: 12.5px; color: var(--muted)">
              Đang tải...
            </div>
            <div v-else style="padding: 16px 18px; display: flex; flex-direction: column; gap: 0">
              <div
                v-for="(h, hi) in historyEntries"
                :key="hi"
                style="display: flex; gap: 12px"
              >
                <div style="display: flex; flex-direction: column; align-items: center; flex: none">
                  <span
                    style="width: 9px; height: 9px; border-radius: 50%; flex: none"
                    :style="{ background: h.color }"
                  ></span>
                  <span
                    v-if="hi < historyEntries.length - 1"
                    style="width: 1px; flex: 1; min-height: 22px; background: var(--line2)"
                  ></span>
                </div>
                <div :style="{ paddingBottom: hi < historyEntries.length - 1 ? '18px' : '0' }">
                  <div style="font-size: 13px; font-weight: 600; color: var(--text)">{{ h.label }}</div>
                  <div v-if="h.note && h.note !== h.label" style="font-size: 12px; color: var(--muted2); margin-top: 2px">{{ h.note }}</div>
                  <div style="font-size: 11.5px; color: var(--muted); margin-top: 3px">{{ h.at }}</div>
                </div>
              </div>
              <div v-if="!historyEntries.length" style="font-size: 12.5px; color: var(--muted)">
                Chưa có lịch sử.
              </div>
            </div>
          </div>
          <div
            style="
              background: var(--card);
              border: 1px solid var(--line);
              border-radius: 14px;
              overflow: hidden;
            "
          >
            <div
              style="
                padding: 14px 18px;
                font-size: 14px;
                font-weight: 600;
                color: var(--text);
                border-bottom: 1px solid var(--line);
              "
            >
              Sản phẩm
            </div>
            <div v-if="loadingExtra" style="padding: 18px; font-size: 12.5px; color: var(--muted)">
              Đang tải...
            </div>
            <div
              v-for="it in detail.items"
              v-else
              :key="it.id"
              style="
                display: flex;
                align-items: center;
                gap: 12px;
                padding: 14px 18px;
                border-bottom: 1px solid var(--line);
              "
            >
              <div
                style="
                  width: 44px;
                  height: 44px;
                  border-radius: 9px;
                  background: var(--card2);
                  flex: none;
                  overflow: hidden;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                "
              >
                <img v-if="it.imageUrl" :src="resolveImageUrl(it.imageUrl)" :alt="it.productName" style="width: 100%; height: 100%; object-fit: cover" />
                <i v-else class="bi bi-box-seam" style="color: var(--muted); font-size: 16px"></i>
              </div>
              <div style="flex: 1; min-width: 0">
                <div style="font-size: 13px; color: var(--text)">{{ it.productName }}</div>
                <div v-if="it.variantInfo" style="font-size: 11.5px; color: var(--muted); margin-top: 2px">{{ it.variantInfo }}</div>
              </div>
              <div style="display: flex; align-items: center; gap: 18px">
                <span class="mono" style="font-size: 12px; color: var(--muted)"
                  >x{{ it.quantity }}</span
                ><span
                  class="mono"
                  style="font-size: 13px; font-weight: 700; color: var(--text)"
                  >{{ money(it.lineTotal) }}</span
                >
              </div>
            </div>
            <div
              style="
                padding: 14px 18px;
                display: flex;
                flex-direction: column;
                gap: 8px;
              "
            >
              <div
                style="
                  display: flex;
                  justify-content: space-between;
                  font-size: 13px;
                "
              >
                <span style="color: var(--muted)">Tạm tính</span
                ><span class="mono" style="color: var(--text)">{{
                  money(detail.subtotal ?? detail.total)
                }}</span>
              </div>
              <div
                v-if="detail.discountAmount"
                style="
                  display: flex;
                  justify-content: space-between;
                  font-size: 13px;
                "
              >
                <span style="color: var(--muted)">Giảm giá</span
                ><span class="mono" style="color: var(--sale)">-{{
                  money(detail.discountAmount)
                }}</span>
              </div>
              <div
                style="
                  display: flex;
                  justify-content: space-between;
                  font-size: 13px;
                "
              >
                <span style="color: var(--muted)">Phí vận chuyển{{ detail.shippingOptionLabel ? ' (' + detail.shippingOptionLabel + ')' : '' }}</span
                ><span class="mono" style="color: var(--text)">{{
                  money(detail.shippingFee ?? 0)
                }}</span>
              </div>
              <!-- Quãng đường đã dùng để tính phí ship nội thành — có để admin đối chiếu được
                   vì sao đơn này thu ngần đó tiền (xem ShippingService.phiTheoKhoangCach) -->
              <div
                v-if="detail.shippingDistanceKm != null"
                style="display: flex; justify-content: space-between; font-size: 12px"
              >
                <span style="color: var(--muted)">Quãng đường từ kho</span
                ><span class="mono" style="color: var(--muted)">{{ detail.shippingDistanceKm }} km</span>
              </div>
              <div
                style="
                  display: flex;
                  justify-content: space-between;
                  font-size: 15px;
                  font-weight: 700;
                  padding-top: 8px;
                  border-top: 1px solid var(--line);
                "
              >
                <span style="color: var(--text)">Tổng cộng</span
                ><span class="mono" style="color: var(--acc)">{{
                  money(detail.totalAmount ?? detail.total)
                }}</span>
              </div>

              <!-- Điểm giao khách tự cắm trên bản đồ lúc đặt đơn. Chụp lại vào đơn nên không đổi
                   kể cả khi khách sửa/xoá địa chỉ sau đó. Ẩn với đơn đặt trước tính năng này. -->
              <div
                v-if="detail.deliveryLat != null && detail.deliveryLng != null"
                style="
                  margin-top: 10px;
                  padding-top: 10px;
                  border-top: 1px solid var(--line);
                  display: flex;
                  align-items: center;
                  justify-content: space-between;
                  gap: 10px;
                "
              >
                <div style="min-width: 0">
                  <div style="font-size: 12px; color: var(--muted)">Toạ độ điểm giao</div>
                  <div class="mono" style="font-size: 12.5px; color: var(--text); margin-top: 2px">
                    {{ Number(detail.deliveryLat).toFixed(6) }}, {{ Number(detail.deliveryLng).toFixed(6) }}
                  </div>
                </div>
                <a
                  :href="'https://www.google.com/maps/search/?api=1&query=' + detail.deliveryLat + ',' + detail.deliveryLng"
                  target="_blank" rel="noopener"
                  style="
                    flex: none;
                    font-size: 12px;
                    color: var(--acc);
                    text-decoration: none;
                    border: 1px solid var(--line);
                    border-radius: 8px;
                    padding: 6px 12px;
                  "
                >
                  Mở bản đồ ↗
                </a>
              </div>
            </div>
          </div>
        </div>
        <div>
          <div
            style="
              background: var(--card);
              border: 1px solid var(--line);
              border-radius: 14px;
              padding: 18px;
              margin-bottom: 14px;
            "
          >
            <div
              style="
                font-size: 13px;
                font-weight: 600;
                color: var(--text);
                margin-bottom: 14px;
              "
            >
              Khách hàng
            </div>
            <div style="display: flex; align-items: center; gap: 12px">
              <div
                class="mono"
                style="
                  width: 44px;
                  height: 44px;
                  border-radius: 11px;
                  background: linear-gradient(135deg, var(--acc), #1c1d21);
                  color: var(--acc-ink);
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  font-weight: 700;
                  font-size: 15px;
                "
              >
                {{ detail.init }}
              </div>
              <div>
                <div
                  style="font-size: 14px; font-weight: 600; color: var(--text)"
                >
                  {{ detail.customer }}
                </div>
                <div style="font-size: 12px; color: var(--muted)">
                  {{ detail.email }}
                </div>
              </div>
            </div>
          </div>
          <div
            v-if="detail.paymentMethod"
            style="
              background: var(--card);
              border: 1px solid var(--line);
              border-radius: 14px;
              padding: 18px;
              margin-bottom: 14px;
            "
          >
            <div style="font-size: 13px; font-weight: 600; color: var(--text); margin-bottom: 10px">
              Thanh toán
            </div>
            <div style="font-size: 13px; color: var(--text); margin-bottom: 6px">
              {{ PAYMENT_METHOD_LABEL[detail.paymentMethod] || detail.paymentMethod }}
            </div>
            <div style="font-size: 12.5px; margin-bottom: 12px" :style="{ color: detail.paymentStatus === 'paid' ? 'var(--green)' : 'var(--amber)' }">
              {{ PAYMENT_STATUS_LABEL[detail.paymentStatus] || detail.paymentStatus }}
            </div>
            <div v-if="detail.proofImage" style="margin-bottom: 12px">
              <div style="font-size: 11.5px; color: var(--muted); margin-bottom: 6px">Biên lai chuyển khoản</div>
              <a :href="detail.proofImage" target="_blank" rel="noopener">
                <img
                  :src="resolveImageUrl(detail.proofImage)"
                  alt="Biên lai chuyển khoản"
                  style="max-width: 100%; max-height: 260px; border-radius: 10px; border: 1px solid var(--line2); display: block; cursor: zoom-in"
                />
              </a>
            </div>
            <button
              v-if="detail.paymentStatus && detail.paymentStatus !== 'paid'"
              @click="confirmPayment"
              :disabled="confirmingPayment"
              style="width: 100%; height: 38px; border-radius: 9px; border: 1px solid var(--line2); background: var(--card2); color: var(--text); font-weight: 600; font-size: 12.5px; cursor: pointer"
            >
              {{ confirmingPayment ? 'Đang lưu...' : 'Xác nhận đã nhận tiền' }}
            </button>
          </div>
          <div
            style="
              background: var(--card);
              border: 1px solid var(--line);
              border-radius: 14px;
              padding: 18px;
            "
          >
            <div
              style="
                font-size: 13px;
                font-weight: 600;
                color: var(--text);
                margin-bottom: 12px;
              "
            >
              Cập nhật trạng thái
            </div>
            <select
              v-model="statusDraft"
              :disabled="detail.st === 'cancelled' || detail.st === 'delivered'"
              style="
                width: 100%;
                height: 42px;
                padding: 0 12px;
                border-radius: 10px;
                background: var(--card2);
                color: var(--text);
                border: 1px solid var(--line2);
                font-size: 13px;
                margin-bottom: 10px;
                cursor: pointer;
              "
            >
              <option value="pending">Chờ xác nhận</option>
              <option value="confirmed">Đã xác nhận</option>
              <option value="processing">Đang xử lý</option>
              <option value="shipped">Đang giao</option>
              <option value="delivered">Đã giao</option>
              <option value="cancelled">Đã huỷ</option>
              <option value="refunded">Hoàn tiền</option>
            </select>
            <div v-if="detail.st === 'cancelled' || detail.st === 'delivered'" style="font-size: 11.5px; color: var(--muted); margin-bottom: 10px">
              Đơn đã {{ detail.st === 'cancelled' ? 'huỷ' : 'giao' }}, không thể đổi trạng thái.
            </div>
            <button
              @click="saveStatus"
              :disabled="savingStatus || detail.st === 'cancelled' || detail.st === 'delivered'"
              style="
                width: 100%;
                height: 42px;
                border-radius: 10px;
                border: none;
                background: var(--acc);
                color: var(--acc-ink);
                font-weight: 700;
                font-size: 13px;
                cursor: pointer;
              "
            >
              {{ savingStatus ? 'Đang lưu...' : 'Lưu thay đổi' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-else style="animation: fadeUp 0.35s ease">
      <div
        style="
          display: grid;
          grid-template-columns: repeat(4, 1fr);
          gap: 14px;
          margin-bottom: 16px;
        "
      >
        <div
          v-for="s in stats"
          :key="s.label"
          style="
            background: var(--card);
            border: 1px solid var(--line);
            border-radius: 13px;
            padding: 14px 16px;
            display: flex;
            align-items: center;
            gap: 13px;
          "
        >
          <div
            style="
              width: 40px;
              height: 40px;
              border-radius: 10px;
              flex: none;
              display: flex;
              align-items: center;
              justify-content: center;
              font-size: 17px;
            "
            :style="{
              background: 'color-mix(in srgb,' + s.color + ' 16%,transparent)',
              color: s.color,
            }"
          >
            <i class="bi" :class="s.icon"></i>
          </div>
          <div>
            <div
              class="mono"
              style="
                font-size: 21px;
                font-weight: 700;
                color: var(--text);
                line-height: 1;
              "
            >
              {{ s.value }}
            </div>
            <div
              style="font-size: 11.5px; color: var(--muted); margin-top: 4px"
            >
              {{ s.label }}
            </div>
          </div>
        </div>
      </div>
      <div
        style="
          background: var(--card);
          border: 1px solid var(--line);
          border-radius: 14px;
          overflow: hidden;
        "
      >
        <div
          style="
            display: flex;
            align-items: center;
            gap: 2px;
            padding: 4px 12px;
            border-bottom: 1px solid var(--line);
            overflow-x: auto;
          "
        >
          <button
            v-for="t in tabs"
            :key="t.key"
            @click="filter = t.key"
            style="
              display: flex;
              align-items: center;
              gap: 7px;
              padding: 12px 13px;
              border: none;
              background: transparent;
              font-size: 12.5px;
              cursor: pointer;
              white-space: nowrap;
            "
            :style="{
              borderBottom:
                '2px solid ' +
                (filter === t.key ? 'var(--acc)' : 'transparent'),
              color: filter === t.key ? 'var(--text)' : 'var(--muted)',
              fontWeight: filter === t.key ? 600 : 500,
            }"
          >
            {{ t.label }}
            <span
              class="mono"
              style="
                font-size: 10.5px;
                padding: 0 6px;
                border-radius: 8px;
                background: var(--card2);
                color: var(--muted);
              "
              >{{ t.count }}</span
            >
          </button>
        </div>
        <table style="width: 100%; border-collapse: collapse; font-size: 13px">
          <thead>
            <tr style="background: var(--card2)">
              <th
                v-for="h in heads"
                :key="h.t"
                :style="{
                  textAlign: h.a || 'left',
                  padding: '10px 16px',
                  fontSize: '11px',
                  fontWeight: 600,
                  color: 'var(--muted)',
                  textTransform: 'uppercase',
                  letterSpacing: '.4px',
                }"
              >
                {{ h.t }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="o in rows"
              :key="o.code"
              @click="openDetail(o)"
              style="border-top: 1px solid var(--line); cursor: pointer"
            >
              <td
                class="mono"
                style="padding: 12px 16px; color: var(--acc); font-weight: 600"
              >
                {{ o.code }}
              </td>
              <td style="padding: 12px 12px">
                <div style="display: flex; align-items: center; gap: 10px">
                  <div
                    class="mono"
                    style="
                      width: 32px;
                      height: 32px;
                      border-radius: 8px;
                      flex: none;
                      background: var(--card2);
                      color: var(--muted2);
                      display: flex;
                      align-items: center;
                      justify-content: center;
                      font-size: 11px;
                      font-weight: 700;
                    "
                  >
                    {{ o.init }}
                  </div>
                  <div style="min-width: 0">
                    <div
                      style="
                        font-size: 12.5px;
                        color: var(--text);
                        font-weight: 500;
                      "
                    >
                      {{ o.customer }}
                    </div>
                    <div style="font-size: 11px; color: var(--muted)">
                      {{ o.email }}
                    </div>
                  </div>
                </div>
              </td>
              <td
                style="
                  padding: 12px 12px;
                  color: var(--muted2);
                  font-size: 12px;
                  max-width: 200px;
                "
              >
                {{ o.item }}
              </td>
              <td
                style="
                  padding: 12px 12px;
                  color: var(--muted2);
                  font-size: 12px;
                "
              >
                {{ o.date }}
              </td>
              <td
                class="mono"
                style="
                  padding: 12px 12px;
                  text-align: right;
                  color: var(--text);
                  font-weight: 700;
                "
              >
                {{ o.totalFmt }}
              </td>
              <td style="padding: 12px 16px">
                <span
                  style="
                    display: inline-flex;
                    align-items: center;
                    gap: 5px;
                    font-size: 11.5px;
                    font-weight: 600;
                    padding: 3px 9px;
                    border-radius: 20px;
                  "
                  :style="{ background: o.stBg, color: o.stColor }"
                  ><span
                    style="width: 6px; height: 6px; border-radius: 50%"
                    :style="{ background: o.stColor }"
                  ></span
                  >{{ o.stLabel }}</span
                >
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { ORDERS, money, short, refreshAdminOrders } from '../data/adminData';
import { ui } from '../uiState';
import { updateOrderStatus, confirmOrderPayment, getAdminOrderDetail } from '../api/admin';
import { resolveImageUrl } from '../api/http';
const filter = ref('all');
const detail = ref(null);
const statusDraft = ref('pending');
const savingStatus = ref(false);
const confirmingPayment = ref(false);
const loadingExtra = ref(false);

// vnpay/vnpay_card/momo không còn cho chọn khi đặt hàng mới (xem PAYMENT_METHOD.is_active)
// nhưng vẫn giữ nhãn ở đây để hiển thị đúng cho các đơn hàng cũ đã đặt bằng phương thức đó.
const PAYMENT_METHOD_LABEL = {
  cod: 'Thanh toán khi nhận hàng (COD)', banking: 'Chuyển khoản ngân hàng',
  stripe_card: 'Thẻ quốc tế (Stripe)',
  vnpay: 'VNPay', vnpay_card: 'VNPay - Thẻ quốc tế', momo: 'MoMo',
};
const PAYMENT_STATUS_LABEL = {
  pending: 'Chưa thanh toán', paid: 'Đã thanh toán', failed: 'Thất bại',
  waiting_verify: 'Chờ đối soát', refunded: 'Đã hoàn tiền',
};

async function loadDetailExtra(id) {
  loadingExtra.value = true;
  try {
    const extra = await getAdminOrderDetail(id);
    if (detail.value && detail.value.id === id) {
      detail.value = { ...detail.value, ...extra };
    }
  } finally {
    loadingExtra.value = false;
  }
}

function openDetail(o) {
  detail.value = { ...o };
  statusDraft.value = o.st;
  loadDetailExtra(o.id);
}

async function saveStatus() {
  savingStatus.value = true;
  try {
    await updateOrderStatus(detail.value.id, statusDraft.value);
    await refreshAdminOrders();
    const fresh = ORDERS.find((o) => o.id === detail.value.id);
    detail.value = fresh ? { ...fresh } : null;
    if (fresh) loadDetailExtra(fresh.id);
  } catch (e) {
    window.alert(e.response?.data?.message || 'Có lỗi khi cập nhật trạng thái');
  } finally {
    savingStatus.value = false;
  }
}

async function confirmPayment() {
  confirmingPayment.value = true;
  try {
    await confirmOrderPayment(detail.value.id);
    await refreshAdminOrders();
    const fresh = ORDERS.find((o) => o.id === detail.value.id);
    detail.value = fresh ? { ...fresh } : null;
    if (fresh) loadDetailExtra(fresh.id);
  } catch (e) {
    window.alert(e.response?.data?.message || 'Có lỗi khi xác nhận thanh toán');
  } finally {
    confirmingPayment.value = false;
  }
}
const heads = [
  { t: 'Mã đơn' },
  { t: 'Khách hàng' },
  { t: 'Sản phẩm' },
  { t: 'Ngày đặt' },
  { t: 'Tổng tiền', a: 'right' },
  { t: 'Trạng thái' },
];
const stKeys = [
  'all',
  'pending',
  'confirmed',
  'processing',
  'shipped',
  'delivered',
  'cancelled',
  'refunded',
];
const stLabels = {
  all: 'Tất cả',
  pending: 'Chờ xác nhận',
  confirmed: 'Đã xác nhận',
  processing: 'Đang xử lý',
  shipped: 'Đang giao',
  delivered: 'Đã giao',
  cancelled: 'Đã huỷ',
  refunded: 'Hoàn tiền',
};
const tabs = computed(() =>
  stKeys.map((k) => ({
    key: k,
    label: stLabels[k],
    count:
      k === 'all' ? ORDERS.length : ORDERS.filter((o) => o.st === k).length,
  })),
);
const rows = computed(() => {
  const q = ui.search.trim().toLowerCase();
  return ORDERS.filter(
    (o) =>
      (filter.value === 'all' || o.st === filter.value) &&
      (!q ||
        o.code.toLowerCase().includes(q) ||
        o.customer.toLowerCase().includes(q)),
  );
});
const stats = computed(() => [
  {
    label: 'Tổng đơn',
    value: ORDERS.length + '',
    icon: 'bi-receipt',
    color: 'var(--acc)',
  },
  {
    label: 'Chờ xử lý',
    value:
      ORDERS.filter((o) =>
        ['pending', 'confirmed', 'processing'].includes(o.st),
      ).length + '',
    icon: 'bi-hourglass-split',
    color: 'var(--amber)',
  },
  {
    label: 'Đang giao',
    value: ORDERS.filter((o) => o.st === 'shipped').length + '',
    icon: 'bi-truck',
    color: '#a855f7',
  },
  {
    label: 'Doanh thu',
    value: short(
      ORDERS.filter((o) => o.st !== 'cancelled' && o.st !== 'refunded').reduce(
        (a, o) => a + o.total,
        0,
      ),
    ),
    icon: 'bi-cash-stack',
    color: 'var(--green)',
  },
]);
const timeline = computed(() => {
  if (!detail.value) return [];
  const steps = ['pending', 'confirmed', 'processing', 'shipped', 'delivered'];
  const cur = steps.indexOf(detail.value.st);
  return [
    ['Đặt hàng', 'bi-bag-check'],
    ['Xác nhận', 'bi-check-circle'],
    ['Đóng gói', 'bi-box-seam'],
    ['Giao hàng', 'bi-truck'],
    ['Hoàn tất', 'bi-flag'],
  ].map((s, i) => ({
    label: s[0],
    icon: s[1],
    color: i <= cur ? 'var(--acc)' : 'var(--muted)',
  }));
});

// Nhãn cho từng mốc trong log lịch sử — khác với stLabels ở chỗ đây là tên SỰ KIỆN đã xảy ra
// (thì quá khứ), không phải tên TRẠNG THÁI hiện tại (VD "pending" ở đây là "Đặt hàng" vì đó luôn
// là dòng log đầu tiên, thay vì "Chờ xác nhận" như khi dùng làm trạng thái đang chờ).
const HISTORY_EVENT_LABELS = {
  pending: 'Đặt hàng', paid: 'Đã thanh toán', confirmed: 'Đã xác nhận',
  processing: 'Đang xử lý', shipped: 'Bắt đầu giao hàng', delivered: 'Giao hàng thành công',
  cancelled: 'Đã huỷ đơn', refunded: 'Đã hoàn tiền',
};
const HISTORY_EVENT_COLORS = {
  cancelled: 'var(--sale)', refunded: 'var(--muted)', delivered: 'var(--green)',
};
function fmtLogTime(iso) {
  const d = new Date(iso);
  const p = (n) => String(n).padStart(2, '0');
  return `${p(d.getHours())}:${p(d.getMinutes())} - ${p(d.getDate())}/${p(d.getMonth() + 1)}/${d.getFullYear()}`;
}
const historyEntries = computed(() =>
  (detail.value?.statusHistory || []).map((h) => ({
    label: HISTORY_EVENT_LABELS[h.status] || h.status,
    note: h.note,
    at: fmtLogTime(h.changedAt),
    color: HISTORY_EVENT_COLORS[h.status] || 'var(--acc)',
  })),
);
</script>
