package com.fpoly.stripe;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import com.stripe.Stripe;

import jakarta.annotation.PostConstruct;

/** Cấu hình Stripe (chế độ test) — secretKey/publishableKey/webhookSecret để trống cho tới
 * khi có tài khoản Stripe thật, lúc đó chỉ cần điền vào application.properties, không cần
 * sửa code. */
@Configuration
public class StripeConfig {

    @Value("${stripe.secretKey:}")
    public String secretKey;

    @Value("${stripe.publishableKey:}")
    public String publishableKey;

    @Value("${stripe.webhookSecret:}")
    public String webhookSecret;

    @Value("${stripe.returnUrl}")
    public String returnUrl;

    @Value("${app.frontendUrl}")
    public String frontendUrl;

    @PostConstruct
    public void init() {
        Stripe.apiKey = secretKey;
    }
}
