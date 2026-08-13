package com.fpoly.service;

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

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fpoly.config.GhnProperties;
import com.fpoly.dto.GhnDtos.GhnOrderDetailRequest;
import com.fpoly.dto.GhnDtos.GhnOrderDetailResponse;
import com.fpoly.dto.GhnDtos.GhnOrderData;

/**
 * Tra cứu chi tiết 1 đơn GHN theo order_code — dùng để hiển thị trạng thái vận chuyển
 * (trang "Theo dõi đơn hàng" của khách, hoặc trang admin/orders).
 *
 * order_code ở đây là mã GHN trả về lúc TẠO đơn vận chuyển với GHN (không có trong docs bạn
 * gửi — chỉ có API lấy chi tiết, chưa có API tạo đơn). Giả định mã này đã được lưu vào
 * Order.maVanDonNgoai lúc admin bàn giao đơn cho GHN (xem ghi chú OrderService_PATCH).
 */
@Service
public class GhnApiService {

    private static final Logger log = LoggerFactory.getLogger(GhnApiService.class);

    @Autowired private GhnProperties props;
    @Autowired private ObjectMapper objectMapper;

    public Optional<GhnOrderData> layChiTietDon(String maVanDonGhn) {
        if (props.getToken() == null || props.getToken().isBlank()) {
            log.warn("[GHN] Chưa cấu hình ghn.token — không tra được tracking");
            return Optional.empty();
        }
        if (maVanDonGhn == null || maVanDonGhn.isBlank()) {
            return Optional.empty();
        }

        try {
            String json = objectMapper.writeValueAsString(new GhnOrderDetailRequest(maVanDonGhn));

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(props.getBaseUrl() + "/shiip/public-api/v2/shipping-order/detail"))
                    .header("Content-Type", "application/json")
                    .header("Token", props.getToken())
                    .timeout(Duration.ofMillis(props.getTimeoutMs()))
                    .POST(HttpRequest.BodyPublishers.ofString(json))
                    .build();

            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofMillis(props.getTimeoutMs()))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                log.warn("[GHN] HTTP {} khi tra đơn {}", response.statusCode(), maVanDonGhn);
                return Optional.empty();
            }

            GhnOrderDetailResponse parsed = objectMapper.readValue(response.body(), GhnOrderDetailResponse.class);

            if (parsed.code() != 200 || parsed.data() == null) {
                log.warn("[GHN] Lỗi tra đơn {}: {}", maVanDonGhn, parsed.message());
                return Optional.empty();
            }

            return Optional.of(parsed.data());

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("[GHN] Bị interrupt khi tra đơn {}", maVanDonGhn, e);
            return Optional.empty();
        } catch (Exception e) {
            log.error("[GHN] Lỗi khi tra đơn {}: {}", maVanDonGhn, e.getMessage());
            return Optional.empty();
        }
    }

    /** Map trạng thái GHN sang trạng thái nội bộ để hiển thị nhất quán với UI hiện có.
     * GHN dùng nhiều trạng thái con hơn hệ thống mình (picking, picked, delivering, delivered,
     * return, cancel...) — chỉ cần rút gọn về các mốc khách cần thấy. */
    public String rutGonTrangThai(String ghnStatus) {
        if (ghnStatus == null) return "unknown";
        return switch (ghnStatus) {
            case "ready_to_pick", "picking" -> "cho_lay_hang";
            case "picked", "storing", "transporting", "sorting" -> "dang_van_chuyen";
            case "delivering" -> "dang_giao";
            case "delivered" -> "da_giao";
            case "delivery_fail", "waiting_to_return", "return", "returned" -> "hoan_tra";
            case "cancel" -> "da_huy";
            default -> ghnStatus;
        };
    }
}
