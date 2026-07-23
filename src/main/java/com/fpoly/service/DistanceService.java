package com.fpoly.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

/** Quãng đường đường bộ từ kho tới điểm khách cắm trên bản đồ — nền tảng của cách tính phí giao
 * hàng nội thành Hải Phòng theo km (xem ShippingService.phiTheoKhoangCach).
 *
 * Dùng OSRM public demo server: miễn phí, không cần API key. Đổi lại là KHÔNG có cam kết uptime
 * và có giới hạn tần suất, nên mọi lỗi (mạng, timeout, 429, JSON lạ) đều rơi về đường chim bay
 * nhân hệ số bù đường vòng thay vì ném lỗi — khách đang ở bước thanh toán, không thể vì OSRM sập
 * mà không đặt được hàng. Khi chạy thật nên trỏ về OSRM tự host (đổi OSRM_BASE). */
@Service
public class DistanceService {

    private static final Logger log = LoggerFactory.getLogger(DistanceService.class);

    private static final String OSRM_BASE = "https://router.project-osrm.org/route/v1/driving/";

    /** Đường chim bay nhân hệ số này để ước lượng quãng đường xe chạy khi OSRM không trả lời.
     * 1.4 là mức thường dùng cho đô thị Việt Nam (đường một chiều, sông, ngõ cụt). */
    private static final BigDecimal HE_SO_BU_DUONG_VONG = new BigDecimal("1.4");

    private static final int BAN_KINH_TRAI_DAT_KM = 6371;

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(3))
            .build();
    private final ObjectMapper objectMapper = new ObjectMapper();

    /** Cùng một điểm cắm sẽ được hỏi lại nhiều lần (khách đổi tuỳ chọn giao hàng, xem lại trang
     * thanh toán, rồi đặt đơn — mỗi lượt là 1 lần tính phí). Cache theo toạ độ đã làm tròn ~11m
     * để không bắn lại OSRM cho cùng một chỗ. Không giới hạn kích thước vì key là toạ độ trong
     * phạm vi Hải Phòng, số lượng thực tế rất nhỏ. */
    private final Map<String, BigDecimal> cache = new ConcurrentHashMap<>();

    /** Quãng đường km từ (latA,lngA) tới (latB,lngB), làm tròn 2 chữ số. Không bao giờ ném lỗi. */
    public BigDecimal khoangCachKm(BigDecimal latA, BigDecimal lngA, BigDecimal latB, BigDecimal lngB) {
        if (latA == null || lngA == null || latB == null || lngB == null) return null;

        String key = lam4ChuSo(latA) + "," + lam4ChuSo(lngA) + ";" + lam4ChuSo(latB) + "," + lam4ChuSo(lngB);
        BigDecimal daCo = cache.get(key);
        if (daCo != null) return daCo;

        BigDecimal ketQua = hoiOsrm(latA, lngA, latB, lngB);
        if (ketQua == null) {
            ketQua = duongChimBayKm(latA, lngA, latB, lngB)
                    .multiply(HE_SO_BU_DUONG_VONG)
                    .setScale(2, RoundingMode.HALF_UP);
        }
        cache.put(key, ketQua);
        return ketQua;
    }

    /** null nếu OSRM không trả về được — người gọi tự rơi về đường chim bay. */
    private BigDecimal hoiOsrm(BigDecimal latA, BigDecimal lngA, BigDecimal latB, BigDecimal lngB) {
        try {
            // OSRM nhận toạ độ theo thứ tự kinh độ,vĩ độ (ngược với quy ước lat,lng thường gặp).
            String url = OSRM_BASE
                    + lngA.toPlainString() + "," + latA.toPlainString() + ";"
                    + lngB.toPlainString() + "," + latB.toPlainString()
                    + "?overview=false&alternatives=false&steps=false";

            HttpRequest request = HttpRequest.newBuilder(URI.create(url))
                    .timeout(Duration.ofSeconds(4))
                    .header("User-Agent", "CNTTShop/1.0")
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                log.warn("OSRM trả về HTTP {} — dùng đường chim bay thay thế", response.statusCode());
                return null;
            }

            JsonNode root = objectMapper.readTree(response.body());
            if (!"Ok".equals(root.path("code").asText())) return null;

            JsonNode routes = root.path("routes");
            if (!routes.isArray() || routes.isEmpty()) return null;

            double met = routes.get(0).path("distance").asDouble(-1);
            if (met < 0) return null;

            return BigDecimal.valueOf(met / 1000.0).setScale(2, RoundingMode.HALF_UP);
        } catch (Exception e) {
            log.warn("Không gọi được OSRM ({}) — dùng đường chim bay thay thế", e.getMessage());
            return null;
        }
    }

    /** Haversine — khoảng cách mặt cầu giữa 2 toạ độ, đơn vị km. */
    public BigDecimal duongChimBayKm(BigDecimal latA, BigDecimal lngA, BigDecimal latB, BigDecimal lngB) {
        double lat1 = Math.toRadians(latA.doubleValue());
        double lat2 = Math.toRadians(latB.doubleValue());
        double dLat = lat2 - lat1;
        double dLng = Math.toRadians(lngB.doubleValue() - lngA.doubleValue());

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return BigDecimal.valueOf(BAN_KINH_TRAI_DAT_KM * c).setScale(2, RoundingMode.HALF_UP);
    }

    private String lam4ChuSo(BigDecimal v) {
        return v.setScale(4, RoundingMode.HALF_UP).toPlainString();
    }
}
