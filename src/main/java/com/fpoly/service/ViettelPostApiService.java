package com.fpoly.service;

import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import tools.jackson.databind.ObjectMapper;
import com.fpoly.config.ViettelPostProperties;
import com.fpoly.dto.ViettelPostDtos.VtpPriceRequest;
import com.fpoly.dto.ViettelPostDtos.VtpPriceResponse;

/**
 * Gọi Viettel Post POST /v2/order/getPrice để lấy cước real-time.
 *
 * Khác GHTK: VTP cần ID Tỉnh/Huyện/Xã chuẩn hoá theo bảng riêng của VTP (không phải ID trong
 * Ward/Province của hệ thống mình) — receiverProvinceId/receiverWardId phải được map trước
 * (xem ViettelPostAddressMappingService — cần bảng mapping riêng, xem ghi chú cuối file).
 *
 * Trả về Optional.empty() ở mọi lỗi — không throw ra ngoài, để ShippingService tự fallback.
 */
@Service
public class ViettelPostApiService {

    private static final Logger log = LoggerFactory.getLogger(ViettelPostApiService.class);

    @Autowired private ViettelPostProperties props;
    @Autowired private ObjectMapper objectMapper;

    /**
     * @param receiverProvinceId ID tỉnh người nhận THEO BẢNG DANH MỤC CỦA VIETTEL POST
     * @param receiverDistrictId ID huyện người nhận theo VTP (có thể null sau sáp nhập)
     * @param receiverWardId     ID xã/phường người nhận theo VTP
     * @param weightGram         cân nặng đơn hàng (gram)
     * @param orderValue         giá trị đơn hàng (VNĐ)
     */
    public Optional<BigDecimal> layCuocViettelPost(Long receiverProvinceId, Long receiverDistrictId,
                                                    Long receiverWardId, long weightGram, long orderValue) {
        if (props.getToken() == null || props.getToken().isBlank()) {
            log.warn("[ViettelPost] Chưa cấu hình viettelpost.token — bỏ qua, fallback về phí tĩnh");
            return Optional.empty();
        }
        if (receiverProvinceId == null || receiverWardId == null) {
            log.warn("[ViettelPost] Thiếu receiverProvinceId/receiverWardId (chưa map địa chỉ VTP) — bỏ qua");
            return Optional.empty();
        }

        try {
            VtpPriceRequest body = new VtpPriceRequest(
                    weightGram,
                    orderValue,
                    0L, // moneyCollection — không thu hộ khi chỉ xem phí, COD tính riêng ở bước tạo đơn
                    props.getDefaultService(),
                    "",
                    props.getSenderDistrictId(),
                    props.getSenderProvinceId(),
                    props.getSenderWardId(),
                    receiverDistrictId,
                    receiverProvinceId,
                    receiverWardId,
                    0, 0, 0,   // kích thước — không bắt buộc, để 0 nếu chưa thu thập từ sản phẩm
                    "HH",      // hàng hoá
                    1          // bảng giá trong nước
            );

            String json = objectMapper.writeValueAsString(body);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(props.getBaseUrl() + "/v2/order/getPrice"))
                    .header("Token", props.getToken())
                    .header("Content-Type", "application/json")
                    .timeout(Duration.ofMillis(props.getTimeoutMs()))
                    .POST(HttpRequest.BodyPublishers.ofString(json))
                    .build();

            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofMillis(props.getTimeoutMs()))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                log.warn("[ViettelPost] HTTP {} khi tính phí (tỉnh={}, xã={})",
                        response.statusCode(), receiverProvinceId, receiverWardId);
                return Optional.empty();
            }

            VtpPriceResponse parsed = objectMapper.readValue(response.body(), VtpPriceResponse.class);

            if (parsed.error() || parsed.data() == null) {
                log.warn("[ViettelPost] API trả lỗi: {} (tỉnh={}, xã={})",
                        parsed.message(), receiverProvinceId, receiverWardId);
                return Optional.empty();
            }

            BigDecimal cuoc = BigDecimal.valueOf(parsed.data().moneyTotal());
            log.info("[ViettelPost] Cước -> tỉnh={}, xã={}: {}đ", receiverProvinceId, receiverWardId, cuoc);
            return Optional.of(cuoc);

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("[ViettelPost] Bị interrupt khi gọi API", e);
            return Optional.empty();
        } catch (Exception e) {
            log.error("[ViettelPost] Lỗi khi gọi API tính phí (tỉnh={}, xã={}): {}",
                    receiverProvinceId, receiverWardId, e.getMessage());
            return Optional.empty();
        }
    }
}

/*
 * ============================================================
 *  GHI CHÚ QUAN TRỌNG — cần làm thêm trước khi dùng được thật:
 * ============================================================
 * Viettel Post KHÔNG dùng chung ID Tỉnh/Xã với bảng Province/Ward hiện có trong project
 * (bảng đó có thể đang khớp chuẩn hành chính nhà nước, còn VTP có ID nội bộ riêng của họ).
 *
 * Cần 1 trong 2 hướng:
 *   (a) Thêm cột vtp_province_id / vtp_ward_id vào bảng PROVINCE/WARD, tự map 1 lần bằng
 *       cách gọi API danh mục của VTP (GET /v2/categories/listProvinceById, listDistrict,
 *       listWard — không có trong docs bạn gửi, cần xin thêm từ VTP hoặc đọc thêm tài liệu).
 *   (b) Nếu không muốn map toàn bộ, chỉ bật Viettel Post cho các tỉnh đã map thủ công
 *       (map cứng trong 1 bảng nhỏ VTP_PROVINCE_MAPPING), tỉnh chưa map thì tự fallback
 *       về phí tĩnh CARRIER — đúng bản chất Optional.empty() ở trên rồi.
 *
 * Trước mắt code này an toàn: nếu chưa map thì tự fallback, không crash checkout.
 */
