package com.fpoly.vnpay;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import jakarta.servlet.http.HttpServletRequest;

/** Ký/xác thực chữ ký VNPay (HMAC-SHA512) — thuật toán chuẩn theo tài liệu tích hợp VNPay:
 * sắp xếp field theo tên, ghép "key=value" (value đã URL-encode) nối bằng "&", rồi băm bằng
 * secret key. */
public final class VNPayUtil {

    private VNPayUtil() {}

    public static String hmacSHA512(String key, String data) {
        try {
            Mac hmac512 = Mac.getInstance("HmacSHA512");
            SecretKeySpec secretKeySpec = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
            hmac512.init(secretKeySpec);
            byte[] bytes = hmac512.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(2 * bytes.length);
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException | InvalidKeyException e) {
            throw new RuntimeException("Không tạo được chữ ký VNPay", e);
        }
    }

    /** Ghép query string đã ký (kèm vnp_SecureHash) từ params — dùng khi tạo URL thanh toán. */
    public static String getPaymentURL(Map<String, String> params, String secretKey) {
        List<String> fieldNames = new ArrayList<>(params.keySet());
        Collections.sort(fieldNames);

        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();
        for (int i = 0; i < fieldNames.size(); i++) {
            String name = fieldNames.get(i);
            String value = params.get(name);
            if (value != null && !value.isEmpty()) {
                hashData.append(name).append('=').append(URLEncoder.encode(value, StandardCharsets.US_ASCII));
                query.append(URLEncoder.encode(name, StandardCharsets.US_ASCII)).append('=')
                        .append(URLEncoder.encode(value, StandardCharsets.US_ASCII));
                if (i < fieldNames.size() - 1) {
                    hashData.append('&');
                    query.append('&');
                }
            }
        }
        String secureHash = hmacSHA512(secretKey, hashData.toString());
        query.append("&vnp_SecureHash=").append(secureHash);
        return query.toString();
    }

    /** Lấy toàn bộ tham số vnp_* từ request callback (đã qua URL-decode chuẩn của servlet). */
    public static Map<String, String> getAllRequestParams(HttpServletRequest request) {
        Map<String, String> fields = new HashMap<>();
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String name = paramNames.nextElement();
            String value = request.getParameter(name);
            if (value != null && !value.isEmpty()) {
                fields.put(name, value);
            }
        }
        return fields;
    }

    /** Xác thực chữ ký callback trả về — tính lại hash từ toàn bộ field (trừ chính
     * vnp_SecureHash/vnp_SecureHashType) rồi so sánh với giá trị VNPay gửi kèm. */
    public static boolean verifySignature(Map<String, String> fields, String secureHash, String secretKey) {
        Map<String, String> toHash = new HashMap<>(fields);
        toHash.remove("vnp_SecureHash");
        toHash.remove("vnp_SecureHashType");

        List<String> fieldNames = new ArrayList<>(toHash.keySet());
        Collections.sort(fieldNames);

        StringBuilder hashData = new StringBuilder();
        for (int i = 0; i < fieldNames.size(); i++) {
            String name = fieldNames.get(i);
            String value = toHash.get(name);
            hashData.append(name).append('=').append(URLEncoder.encode(value, StandardCharsets.US_ASCII));
            if (i < fieldNames.size() - 1) {
                hashData.append('&');
            }
        }
        String computed = hmacSHA512(secretKey, hashData.toString());
        return computed.equalsIgnoreCase(secureHash);
    }
}
