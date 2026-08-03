package com.fpoly.config;

import java.nio.file.Paths;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/** Phục vụ ảnh sản phẩm do admin tải lên (lưu cục bộ tại uploads/products/). */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String uploadPath = Paths.get("uploads/products").toAbsolutePath().toUri().toString();
        registry.addResourceHandler("/uploads/products/**")
                .addResourceLocations(uploadPath);

        String paymentUploadPath = Paths.get("uploads/payment").toAbsolutePath().toUri().toString();
        registry.addResourceHandler("/uploads/payment/**")
                .addResourceLocations(paymentUploadPath);

        String reviewUploadPath = Paths.get("uploads/review").toAbsolutePath().toUri().toString();
        registry.addResourceHandler("/uploads/review/**")
                .addResourceLocations(reviewUploadPath);

        // Ảnh + video minh chứng đổi trả (video lỗi, video mở hàng, ảnh lỗi).
        String returnUploadPath = Paths.get("uploads/return").toAbsolutePath().toUri().toString();
        registry.addResourceHandler("/uploads/return/**")
                .addResourceLocations(returnUploadPath);
    }
}
