package com.fpoly.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * Tách riêng khỏi SecurityConfig để tránh circular dependency: OAuth2SuccessHandler cần
 * PasswordEncoder, còn SecurityConfig lại cần OAuth2SuccessHandler — nếu PasswordEncoder
 * cũng khai báo trong SecurityConfig thì Spring không dựng nổi container (bean tự phụ thuộc
 * chính nó qua vòng SecurityConfig -> OAuth2SuccessHandler -> PasswordEncoder -> SecurityConfig).
 */
@Configuration
public class PasswordEncoderConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
