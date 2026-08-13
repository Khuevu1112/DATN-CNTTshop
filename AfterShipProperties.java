package com.fpoly.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Cấu hình AfterShip API — dùng để tracking đơn Shopee Express (slug cố định "spx").
 * Lấy API key tại: https://www.aftership.com/ → Settings → API Keys.
 */
@Component
@ConfigurationProperties(prefix = "aftership")
public class AfterShipProperties {

    private String apiKey;
    private String baseUrl = "https://api.aftership.com/tracking/2024-04";
    private int timeoutMs = 5000;

    public String getApiKey()          { return apiKey; }
    public void setApiKey(String v)    { this.apiKey = v; }

    public String getBaseUrl()         { return baseUrl; }
    public void setBaseUrl(String v)   { this.baseUrl = v; }

    public int getTimeoutMs()          { return timeoutMs; }
    public void setTimeoutMs(int v)    { this.timeoutMs = v; }
}
