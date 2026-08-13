// ============================================================
//  PATCH BỔ SUNG cho ShippingService.java
//  (áp dụng SAU patch GHTK đã làm ở lượt trước — ShippingService_PATCH.java)
// ============================================================

// BƯỚC 1: Thêm @Autowired
// ---------------------------------------------------------------
@Autowired private ViettelPostApiService viettelPostApiService;

// BƯỚC 2: SỬA method resolveCarrierFee() đã thêm ở patch trước — thêm nhánh Viettel Post
//          vào TRƯỚC nhánh "Ưu tiên 3: phí tĩnh"
// ---------------------------------------------------------------
//
// VERSION CŨ (trong resolveCarrierFee, sau đoạn xử lý "ghtk"):
//
//         // Fallback xuống phí tĩnh nếu GHTK lỗi/timeout
//     }
//
//     // --- Ưu tiên 3: phí tĩnh admin cấu hình ---
//     return carrier.getFeeLienTinh() != null ? carrier.getFeeLienTinh() : BigDecimal.ZERO;
// }
//
// VERSION MỚI — thêm nhánh Viettel Post NGAY TRƯỚC dòng "Ưu tiên 3":

            // Fallback xuống phí tĩnh nếu GHTK lỗi/timeout
        }

        // --- Ưu tiên 2b: Viettel Post real-time ---
        if ("viettelpost".equalsIgnoreCase(carrier.getCode())) {
            // CẦN: province.getVtpProvinceId()/getVtpWardId() — xem ghi chú trong
            // ViettelPostApiService.java về việc map ID riêng của VTP. Nếu Province/Ward
            // chưa có 2 cột này, Optional sẽ luôn empty và tự fallback về phí tĩnh — an toàn,
            // không crash, nhưng phí sẽ KHÔNG real-time cho tới khi map xong.
            Optional<BigDecimal> cuocVtp = viettelPostApiService.layCuocViettelPost(
                    null, // TODO: province.getVtpProvinceId() — thêm cột sau khi map ID VTP
                    null, // TODO: district id nếu có
                    null, // TODO: province.getVtpWardId()
                    weightGram,
                    orderValue
            );
            if (cuocVtp.isPresent()) {
                return cuocVtp.get();
            }
        }

        // --- Ưu tiên 3: phí tĩnh admin cấu hình ---
        return carrier.getFeeLienTinh() != null ? carrier.getFeeLienTinh() : BigDecimal.ZERO;
    }

// ============================================================
//  GHI CHÚ: Viettel Post CHƯA THỂ real-time ngay được
// ============================================================
// Khác với GHTK (dùng tên tỉnh/phường dạng text, khớp thẳng với dữ liệu Province/Ward hiện
// có), Viettel Post bắt buộc dùng ID theo bảng danh mục riêng của họ. Code trên đã viết sẵn
// đường gọi API + fallback an toàn, nhưng phần map ID cần làm thêm 1 bước:
//
//   1. Gọi API danh mục VTP (không có trong docs bạn gửi — cần đọc thêm phần
//      "Danh mục địa chỉ" trong tài liệu VTP, hoặc liên hệ họ xin endpoint listProvince/
//      listDistrict/listWard).
//   2. Thêm 2 cột vtp_province_id, vtp_ward_id vào bảng PROVINCE/WARD.
//   3. Chạy 1 script map 1 lần (khoảng 63 tỉnh + vài nghìn xã — làm 1 lần, xong thì thôi).
//
// Trước mắt: Viettel Post vẫn hoạt động bình thường trong hệ thống, chỉ là dùng phí tĩnh
// (fee_lien_tinh) thay vì gọi API thật — giống hệt cách các hãng khác đang chạy hiện tại,
// không có gì bị hỏng hay thụt lùi so với trước khi làm phần này.
