package com.fpoly.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Cấu hình GHN API — dùng cho tra cứu chi tiết đơn hàng (tracking), KHÔNG dùng để tính phí
 * (docs bạn cung cấp cho GHN chỉ có API "Get chi tiết đơn hàng", không có API tính phí).
 *
 * Test:       https://dev-online-gateway.ghn.vn
 * Production: https://online-gateway.ghn.vn
 */
@Component
@ConfigurationProperties(prefix = "ghn")
public class GhnProperties {

    private String token;
    private String baseUrl = "https://dev-online-gateway.ghn.vn";
    private int timeoutMs = 5000;

    public String getToken()         { return token; }
    public void setToken(String v)   { this.token = v; }

    public String getBaseUrl()       { return baseUrl; }
    public void setBaseUrl(String v) { this.baseUrl = v; }

    public int getTimeoutMs()        { return timeoutMs; }
    public void setTimeoutMs(int v)  { this.timeoutMs = v; }
}
