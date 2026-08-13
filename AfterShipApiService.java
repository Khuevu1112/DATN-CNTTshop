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
import com.fpoly.config.AfterShipProperties;
import com.fpoly.dto.AfterShipDtos.*;

/**
 * Tracking đơn Shopee Express qua AfterShip — đầy đủ các thao tác theo docs bạn gửi:
 * tạo, xem, cập nhật, xoá, retrack (đơn hết hạn theo dõi), đánh dấu hoàn thành.
 *
 * Tất cả method trả Optional.empty() khi lỗi thay vì throw — trang tracking của khách không
 * nên vỡ trắng chỉ vì AfterShip tạm thời lỗi; caller tự quyết định hiển thị "đang cập nhật".
 */
@Service
public class AfterShipApiService {

    private static final Logger log = LoggerFactory.getLogger(AfterShipApiService.class);

    @Autowired private AfterShipProperties props;
    @Autowired private ObjectMapper objectMapper;

    private HttpClient client() {
        return HttpClient.newBuilder()
                .connectTimeout(Duration.ofMillis(props.getTimeoutMs()))
                .build();
    }

    private HttpRequest.Builder baseRequest(String path) {
        return HttpRequest.newBuilder()
                .uri(URI.create(props.getBaseUrl() + path))
                .header("Content-Type", "application/json")
                .header("as-api-key", props.getApiKey())
                .timeout(Duration.ofMillis(props.getTimeoutMs()));
    }

    private boolean chuaCauHinh() {
        if (props.getApiKey() == null || props.getApiKey().isBlank()) {
            log.warn("[AfterShip] Chưa cấu hình aftership.api-key");
            return true;
        }
        return false;
    }

    /** Tạo tracking mới cho một mã vận đơn SPX — gọi ngay sau khi admin bàn giao đơn cho
     * Shopee Express (xem OrderService_PATCH — hook ở bước chuyển trạng thái "shipped"). */
    public Optional<Tracking> taoTracking(String trackingNumber, String orderCode) {
        if (chuaCauHinh()) return Optional.empty();

        try {
            TrackingInput input = new TrackingInput(trackingNumber, orderCode, orderCode);
            String json = objectMapper.writeValueAsString(new CreateTrackingBody(input));

            HttpRequest request = baseRequest("/trackings")
                    .POST(HttpRequest.BodyPublishers.ofString(json))
                    .build();

            HttpResponse<String> response = client().send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 201 && response.statusCode() != 200) {
                log.warn("[AfterShip] HTTP {} khi tạo tracking cho {}: {}",
                        response.statusCode(), trackingNumber, response.body());
                return Optional.empty();
            }

            AfterShipResponse parsed = objectMapper.readValue(response.body(), AfterShipResponse.class);
            log.info("[AfterShip] Tạo tracking thành công cho đơn {} (tracking_number={})", orderCode, trackingNumber);
            return Optional.ofNullable(parsed.data()).map(TrackingData::tracking);

        } catch (Exception e) {
            log.error("[AfterShip] Lỗi tạo tracking cho {}: {}", trackingNumber, e.getMessage());
            return Optional.empty();
        }
    }

    /** Xem chi tiết tracking — dùng cho trang "Theo dõi đơn hàng" của khách. */
    public Optional<Tracking> layTracking(String trackingId) {
        if (chuaCauHinh() || trackingId == null || trackingId.isBlank()) return Optional.empty();

        try {
            HttpRequest request = baseRequest("/trackings/" + trackingId).GET().build();
            HttpResponse<String> response = client().send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                log.warn("[AfterShip] HTTP {} khi xem tracking {}", response.statusCode(), trackingId);
                return Optional.empty();
            }

            AfterShipResponse parsed = objectMapper.readValue(response.body(), AfterShipResponse.class);
            return Optional.ofNullable(parsed.data()).map(TrackingData::tracking);

        } catch (Exception e) {
            log.error("[AfterShip] Lỗi xem tracking {}: {}", trackingId, e.getMessage());
            return Optional.empty();
        }
    }

    /** Cập nhật title/note — dùng khi admin muốn ghi chú thêm cho đơn (VD lý do giao chậm). */
    public boolean capNhatTracking(String trackingId, String title, String note) {
        if (chuaCauHinh() || trackingId == null) return false;

        try {
            String json = objectMapper.writeValueAsString(
                    new UpdateTrackingBody(new UpdateFields(title, note)));

            HttpRequest request = baseRequest("/trackings/" + trackingId)
                    .method("PUT", HttpRequest.BodyPublishers.ofString(json))
                    .build();

            HttpResponse<String> response = client().send(request, HttpResponse.BodyHandlers.ofString());

            boolean ok = response.statusCode() == 200;
            if (!ok) log.warn("[AfterShip] HTTP {} khi cập nhật tracking {}", response.statusCode(), trackingId);
            return ok;

        } catch (Exception e) {
            log.error("[AfterShip] Lỗi cập nhật tracking {}: {}", trackingId, e.getMessage());
            return false;
        }
    }

    /** Xoá tracking — dùng khi đơn bị huỷ trước khi giao. */
    public boolean xoaTracking(String trackingId) {
        if (chuaCauHinh() || trackingId == null) return false;

        try {
            HttpRequest request = baseRequest("/trackings/" + trackingId).DELETE().build();
            HttpResponse<String> response = client().send(request, HttpResponse.BodyHandlers.ofString());

            boolean ok = response.statusCode() == 200;
            if (!ok) log.warn("[AfterShip] HTTP {} khi xoá tracking {}", response.statusCode(), trackingId);
            return ok;

        } catch (Exception e) {
            log.error("[AfterShip] Lỗi xoá tracking {}: {}", trackingId, e.getMessage());
            return false;
        }
    }

    /** Retrack đơn đã hết hạn theo dõi (Expired) — AfterShip giới hạn tối đa 3 lần/tracking,
     * nên cân nhắc chỉ cho admin bấm tay, không tự động lặp lại nhiều lần. */
    public boolean retrack(String trackingId) {
        if (chuaCauHinh() || trackingId == null) return false;

        try {
            HttpRequest request = baseRequest("/trackings/" + trackingId + "/retrack")
                    .POST(HttpRequest.BodyPublishers.noBody())
                    .build();

            HttpResponse<String> response = client().send(request, HttpResponse.BodyHandlers.ofString());

            boolean ok = response.statusCode() == 200;
            if (!ok) log.warn("[AfterShip] HTTP {} khi retrack {}", response.statusCode(), trackingId);
            return ok;

        } catch (Exception e) {
            log.error("[AfterShip] Lỗi retrack {}: {}", trackingId, e.getMessage());
            return false;
        }
    }

    /** Đánh dấu tracking hoàn thành thủ công — dùng khi admin xác nhận giao thành công/thất lạc
     * ngoài luồng tự động của AfterShip (VD khách xác nhận qua điện thoại). */
    public boolean danhDauHoanThanh(String trackingId, String reason) {
        if (chuaCauHinh() || trackingId == null) return false;
        if (!reason.equals("DELIVERED") && !reason.equals("LOST") && !reason.equals("RETURNED_TO_SENDER")) {
            log.warn("[AfterShip] reason không hợp lệ: {}", reason);
            return false;
        }

        try {
            String json = objectMapper.writeValueAsString(new MarkCompletedBody(reason));

            HttpRequest request = baseRequest("/trackings/" + trackingId + "/mark-as-completed")
                    .POST(HttpRequest.BodyPublishers.ofString(json))
                    .build();

            HttpResponse<String> response = client().send(request, HttpResponse.BodyHandlers.ofString());

            boolean ok = response.statusCode() == 200;
            if (!ok) log.warn("[AfterShip] HTTP {} khi đánh dấu hoàn thành {}", response.statusCode(), trackingId);
            return ok;

        } catch (Exception e) {
            log.error("[AfterShip] Lỗi đánh dấu hoàn thành {}: {}", trackingId, e.getMessage());
            return false;
        }
    }
}
