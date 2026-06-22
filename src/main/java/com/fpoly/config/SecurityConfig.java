package com.fpoly.config;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import com.fpoly.service.CustomUserDetailsService;

@Configuration
public class SecurityConfig {

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /** Cho phép Vue dev server (Vite :5173 và :5174) gọi API. */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        // Bổ sung thêm cổng 5174 vào danh sách cho phép
        config.setAllowedOrigins(List.of("http://localhost:5173", "http://localhost:5174"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http)
            throws Exception {

        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))

            .csrf(csrf -> csrf.disable())

            .authorizeHttpRequests(auth -> auth

                    // ===== REST API cho Vue (tạm mở; sẽ siết bằng JWT ở bước sau) =====
                    .requestMatchers("/api/**").permitAll()

                    .requestMatchers(
                            "/DustNovel/login",
                            "/DustNovel/register",
                            "/DustNovel/forgot-password",
                            "/css/**",
                            "/js/**",
                            "/images/**"
                    ).permitAll()

                    .requestMatchers("/admin/users/**")
                    .hasRole("ADMIN")

                    .requestMatchers(
                            "/admin/products/**",
                            "/admin/categories/**"
                    )
                    .hasAnyRole("ADMIN", "STAFF")

                    .requestMatchers("/account/**")
                    .hasAnyRole("ADMIN", "STAFF", "CUSTOMER")

                    .requestMatchers("/cart/**", "/orders/**", "/account/addresses/**")
                    .hasAnyRole("ADMIN", "STAFF", "CUSTOMER")

                    .requestMatchers("/admin/orders/**")
                    .hasAnyRole("ADMIN", "STAFF")

                    .requestMatchers("/admin/gio-hang/**")
                    .hasAnyRole("ADMIN", "STAFF")

                    .anyRequest()
                    .authenticated()
            )

            .userDetailsService(userDetailsService)

            .formLogin(form -> form
                .loginPage("/DustNovel/login")
                .loginProcessingUrl("/DustNovel/login")
                .usernameParameter("username")
                .passwordParameter("password")
                .defaultSuccessUrl("/", true)
                .failureUrl("/DustNovel/login?error=true")
                .permitAll()
            )

            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessUrl("/DustNovel/login?logout")
                .permitAll()
            );

        return http.build();
    }
}
