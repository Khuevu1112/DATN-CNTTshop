/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.fpoly.vnpay;

/**
 *
 * @author Asus
 */
import jakarta.servlet.http.HttpServletRequest;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Map;
import java.util.stream.Collectors;

public class VNPayUtil {

    public static String hmacSHA512(String key, String data) {
        try {
            javax.crypto.Mac hmac512 =
                    javax.crypto.Mac.getInstance("HmacSHA512");

            javax.crypto.spec.SecretKeySpec secretKey =
                    new javax.crypto.spec.SecretKeySpec(
                            key.getBytes(),
                            "HmacSHA512");

            hmac512.init(secretKey);

            byte[] bytes =
                    hmac512.doFinal(data.getBytes());

            StringBuilder hash = new StringBuilder();

            for (byte b : bytes) {
                hash.append(String.format("%02x", b));
            }

            return hash.toString();

        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }

    public static String getPaymentURL(
            Map<String, String> params,
            String hashSecret) {

        String queryUrl = params.entrySet()
                .stream()
                .sorted(Map.Entry.comparingByKey())
                .map(entry ->
                        URLEncoder.encode(
                                entry.getKey(),
                                StandardCharsets.US_ASCII)
                                + "=" +
                                URLEncoder.encode(
                                        entry.getValue(),
                                        StandardCharsets.US_ASCII))
                .collect(Collectors.joining("&"));

        String secureHash =
                hmacSHA512(hashSecret, queryUrl);

        return queryUrl +
                "&vnp_SecureHash=" +
                secureHash;
    }

    public static Map<String, String> getAllRequestParams(
        HttpServletRequest request) {

    return request.getParameterMap()
            .entrySet()
            .stream()

            .filter(e ->
                    !"vnp_SecureHash"
                            .equals(
                                    e.getKey()))

            .collect(
                    Collectors.toMap(

                            Map.Entry::getKey,

                            e -> e.getValue()[0]
                    ));
}

public static boolean verifySignature(

        Map<String, String> fields,

        String secureHash,

        String secretKey
) {

    String queryUrl = fields
            .entrySet()
            .stream()

            .sorted(
                    Map.Entry
                            .comparingByKey())

            .map(entry ->

                    URLEncoder.encode(
                            entry.getKey(),
                            StandardCharsets.US_ASCII)

                            +

                            "="

                            +

                            URLEncoder.encode(
                                    entry.getValue(),
                                    StandardCharsets.US_ASCII))

            .collect(
                    Collectors.joining("&"));

    String hash =
            hmacSHA512(
                    secretKey,
                    queryUrl);

    return hash.equalsIgnoreCase(
            secureHash);
}
}
