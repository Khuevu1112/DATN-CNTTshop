package com.fpoly.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Cấu hình Viettel Post API — https://partnerdev.viettelpost.vn (dev) /
 * https://partner.viettelpost.vn (production).
 *
 * Khác GHTK: Viettel Post cần ID Tỉnh/Huyện/Xã theo bảng riêng của họ (không dùng tên text),
 * nên phải map địa chỉ shop sang các ID này một lần và cấu hình cứng — xem sender*.
 */
@Component
@ConfigurationProperties(prefix = "viettelpost")
public class ViettelPostProperties {

    private String token;
    private String baseUrl = "https://partnerdev.viettelpost.vn";

    // ID tỉnh/huyện/xã nơi gửi hàng — tra một lần qua API danh mục của Viettel Post rồi cấu
    // hình cứng ở đây (khớp với kho 118 Cát Bi, Phường Hải An, Hải Phòng).
    private Long senderProvinceId;
    private Long senderDistrictId;
    private Long senderWardId;

    // ORDER_SERVICE mặc định — "VCN" (chuyển phát nhanh) hoặc "VTK" tuỳ gói đã đăng ký với VTP.
    private String defaultService = "VCN";

    private int timeoutMs = 5000;

    public String getToken()             { return token; }
    public void setToken(String v)       { this.token = v; }

    public String getBaseUrl()           { return baseUrl; }
    public void setBaseUrl(String v)     { this.baseUrl = v; }

    public Long getSenderProvinceId()          { return senderProvinceId; }
    public void setSenderProvinceId(Long v)    { this.senderProvinceId = v; }

    public Long getSenderDistrictId()          { return senderDistrictId; }
    public void setSenderDistrictId(Long v)    { this.senderDistrictId = v; }

    public Long getSenderWardId()              { return senderWardId; }
    public void setSenderWardId(Long v)        { this.senderWardId = v; }

    public String getDefaultService()          { return defaultService; }
    public void setDefaultService(String v)    { this.defaultService = v; }

    public int getTimeoutMs()            { return timeoutMs; }
    public void setTimeoutMs(int v)      { this.timeoutMs = v; }
}
