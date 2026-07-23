package com.fpoly.service;

import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;


import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

/** Tra ngược toạ độ -> địa chỉ chữ, cho chế độ "chỉ cắm mốc" ở form địa chỉ. CHỈ trả về phần
 * địa chỉ cấp đường (số nhà + tên đường).
 *
 * KHÔNG suy ra Tỉnh/Phường từ đây, dù Nominatim có trả về. Lý do: Việt Nam đã sáp nhập đơn vị
 * hành chính từ 1/7/2025 (63 -> 34 tỉnh, bỏ cấp huyện), còn Nominatim là dữ liệu cộng đồng nên
 * phần lớn vẫn mang tên hành chính CŨ. Cách làm trước đây là khớp tên OSM với bảng
 * PROVINCE/WARD của dự án (đã chuẩn hoá theo mốc mới, xem database/40_province_ward.sql) —
 * cách đó nguy hiểm hơn là không khớp gì: một cái tên cũ trùng lặp với đơn vị mới sẽ tự chọn
 * SAI phường mà khách không hề hay biết, kéo theo sai phí giao hàng (phí nội thành Hải Phòng
 * tính theo phường/toạ độ) và sai địa chỉ trên đơn.
 *
 * Vì vậy Tỉnh/Phường LUÔN do khách tự chọn từ dropdown lấy trực tiếp từ bảng của dự án — nguồn
 * duy nhất được coi là đúng. Toạ độ ghim vẫn là thứ quyết định phí ship theo khoảng cách, nên
 * việc bỏ tự điền này không làm mất độ chính xác của phí.
 *
 * Nominatim miễn phí, không cần key, nhưng giới hạn 1 request/giây và bắt buộc gửi User-Agent
 * định danh ứng dụng. */
@Service
public class GeocodingService {

    private static final Logger log = LoggerFactory.getLogger(GeocodingService.class);

    private static final String NOMINATIM_REVERSE = "https://nominatim.openstreetmap.org/reverse";


    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(3))
            .build();
    private final ObjectMapper objectMapper = new ObjectMapper();

    /** provinceId/wardId/tenTinh/tenPhuong LUÔN null — giữ lại trong record để không phá vỡ
     * client cũ đang đọc, nhưng không bao giờ được điền (xem javadoc lớp). Khách tự chọn
     * Tỉnh/Phường từ dropdown lấy từ bảng chuẩn hoá của dự án. */
    public record KetQuaTraNguoc(
            String diaChiDayDu, String diaChiCuThe,
            Integer provinceId, String tenTinh,
            Integer wardId, String tenPhuong
    ) {}

    public KetQuaTraNguoc traNguoc(BigDecimal lat, BigDecimal lng) {
        JsonNode addr = goiNominatim(lat, lng);
        if (addr == null) {
            return new KetQuaTraNguoc(null, null, null, null, null, null);
        }

        String diaChiDayDu = addr.path("display_name").asText(null);
        JsonNode chiTiet = addr.path("address");

        // Nominatim trả tên đường/số nhà rời — ghép lại thành ô "số nhà, đường" của form.
        String soNha = chiTiet.path("house_number").asText("");
        String duong = chiTiet.path("road").asText("");
        String diaChiCuThe = (soNha + " " + duong).trim();

        // Ở Việt Nam Nominatim rất hay THIẾU house_number, nhiều nơi thiếu cả road -> diaChiCuThe
        // rỗng. Với chế độ "chỉ cắm mốc" (khách không gõ gì, xem MapPicker), rỗng nghĩa là ô địa
        // chỉ trống và form chặn không cho lưu — đúng cái lỗi khách gặp. Fallback: lấy hai thành
        // phần cấp thấp nhất của display_name (thứ tự Nominatim là cụ thể -> tổng quát) để có mô
        // tả vị trí thay vì bỏ trống. Đây là ô địa chỉ mô tả tự do, không phải dropdown chuẩn
        // hoá, nên tên khu vực cũ ở đây không gây sai lệch gì — điểm giao vẫn chốt bằng toạ độ.
        if (diaChiCuThe.isBlank() && diaChiDayDu != null) {
            String[] phan = diaChiDayDu.split(",");
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < Math.min(2, phan.length); i++) {
                if (!sb.isEmpty()) sb.append(", ");
                sb.append(phan[i].trim());
            }
            diaChiCuThe = sb.toString();
        }

        // CỐ Ý KHÔNG suy ra Tỉnh/Phường từ dữ liệu Nominatim nữa — xem javadoc của lớp.
        return new KetQuaTraNguoc(
                diaChiDayDu,
                diaChiCuThe.isBlank() ? null : diaChiCuThe,
                null, null, null, null
        );
    }

    private JsonNode goiNominatim(BigDecimal lat, BigDecimal lng) {
        try {
            String url = NOMINATIM_REVERSE + "?format=jsonv2&zoom=18&addressdetails=1"
                    + "&lat=" + lat.toPlainString() + "&lon=" + lng.toPlainString();

            HttpRequest request = HttpRequest.newBuilder(URI.create(url))
                    .timeout(Duration.ofSeconds(5))
                    // Nominatim từ chối request không có User-Agent định danh ứng dụng.
                    .header("User-Agent", "CNTTShop/1.0 (lien he: cnttshop@example.com)")
                    .header("Accept-Language", "vi")
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                log.warn("Nominatim trả về HTTP {}", response.statusCode());
                return null;
            }
            return objectMapper.readTree(response.body());
        } catch (Exception e) {
            log.warn("Không gọi được Nominatim ({})", e.getMessage());
            return null;
        }
    }

}

