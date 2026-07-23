package com.fpoly.vnpay;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class VNPayConfig {
    @Value("${vnpay.tmnCode}")
    public String vnp_TmnCode;

    @Value("${vnpay.hashSecret}")
    public String secretKey;

    @Value("${vnpay.payUrl}")
    public String vnp_PayUrl;

    @Value("${vnpay.returnUrl}")
    public String vnp_ReturnUrl;

    @Value("${app.frontendUrl}")
    public String frontendUrl;
}
