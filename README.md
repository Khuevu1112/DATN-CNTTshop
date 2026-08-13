# Mở rộng: GHN + Viettel Post + Shopee Express

Nối tiếp phần GHTK đã làm trước đó. Tổng hợp những gì mỗi hãng làm được (đúng theo docs bạn gửi):

| Hãng | Tính phí real-time | Tracking |
|------|:---:|:---:|
| GHTK | ✅ Đã xong (lượt trước) | ❌ Không có trong docs |
| Viettel Post | ⚠️ Code sẵn, cần map ID địa chỉ trước | ❌ Không có trong docs |
| GHN | ❌ Không có trong docs | ✅ Xong |
| Shopee Express | ❌ Không có trong docs (chỉ có tracking) | ✅ Xong (qua AfterShip) |

---

## File mới cần thêm vào project

```
config/
  GhnProperties.java
  ViettelPostProperties.java
  AfterShipProperties.java
dto/
  GhnDtos.java
  ViettelPostDtos.java
  AfterShipDtos.java
  TrackingDtos.java
service/
  GhnApiService.java
  ViettelPostApiService.java
  AfterShipApiService.java
  TrackingService.java          ← lớp trung gian, tự chọn GHN/AfterShip theo carrier đơn
controller/api/
  TrackingApiController.java    ← GET /api/orders/{id}/tracking
```

## File cần sửa

| File | Thay đổi |
|------|----------|
| `Order.java` | +2 field: `maVanDonNgoai`, `afterShipTrackingId` (xem `Order_PATCH.java`) |
| `ShippingService.java` | +Viettel Post vào `resolveCarrierFee()` (xem `ShippingService_PATCH2_viettelpost.java`) |
| `OrderService.java` | +method `banGiaoVanChuyen()` (xem `OrderService_PATCH.java`) |
| `SecurityConfig.java` | Không bắt buộc sửa — `/api/orders/**` đã rơi vào `authenticated()` sẵn |
| `application.properties` | +config `ghn.*`, `viettelpost.*`, `aftership.*` |

## SQL

Chạy `sql/V2_add_tracking_columns.sql` — thêm 2 cột vào `[ORDER]`.

---

## Luồng hoạt động

### Tính phí (Checkout)
Không đổi so với lượt trước — vẫn gọi `/api/shipping/options`. Viettel Post hiện tại **chưa** gọi API thật (thiếu bước map ID địa chỉ riêng của VTP), tự động dùng phí tĩnh — không ảnh hưởng gì tới checkout hiện tại.

### Tracking (sau khi đặt đơn)
```
Admin bàn giao đơn cho hãng
         │
         ▼
  Gọi OrderService.banGiaoVanChuyen(orderId, maVanDon)
         │
    ┌────┴─────┐
   GHN         SPX (Shopee Express)
    │            │
  Lưu mã      Lưu mã + gọi AfterShip
  order_code   tạo tracking, lưu id
         │            │
         └─────┬──────┘
               ▼
   Khách/Admin gọi GET /api/orders/{id}/tracking
               │
      TrackingService tự chọn đúng hãng
      → trả về format thống nhất (TrackingStatusDto)
```

---

## Việc còn thiếu để Viettel Post tính phí real-time

VTP dùng ID Tỉnh/Huyện/Xã riêng, không khớp với ID trong bảng `PROVINCE`/`WARD` hiện tại của bạn. Cần:

1. Xin/tìm API danh mục địa chỉ của VTP (không có trong docs đã gửi)
2. Thêm cột `vtp_province_id`, `vtp_ward_id` vào `PROVINCE`/`WARD`
3. Map 1 lần (script chạy 1 lần, ~63 tỉnh)

Trước khi làm xong, Viettel Post vẫn chạy bình thường bằng phí tĩnh — không có gì hỏng.

---

## Test nhanh không cần key thật

Để trống toàn bộ `ghn.token`, `viettelpost.token`, `aftership.api-key` trong properties — mọi service tự fallback về rỗng/phí tĩnh, không exception nào văng ra ngoài, checkout và các luồng khác chạy bình thường.
