package com.fpoly.config;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import com.fpoly.security.JwtAuthFilter;
import com.fpoly.security.OAuth2SuccessHandler;
import com.fpoly.service.CustomUserDetailsService;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import jakarta.servlet.http.HttpServletResponse;

@Configuration
public class SecurityConfig {

    /** 6 phòng ban thay cho "STAFF" chung chung trước đây — quyền chi tiết theo từng trang
     * được PermissionAspect kiểm tra riêng, các matcher này chỉ cần loại "customer" ra. */
    private static final String[] STAFF_ROLES =
            { "ADMIN", "KE_TOAN", "KHO", "KY_THUAT", "CSKH", "GIAO_HANG", "KINH_DOANH" };
    private static final String[] STAFF_AND_CUSTOMER_ROLES =
            { "ADMIN", "KE_TOAN", "KHO", "KY_THUAT", "CSKH", "GIAO_HANG", "KINH_DOANH", "CUSTOMER" };

    private static void writeJsonError(HttpServletResponse res, int status, String message) throws IOException {
        res.setStatus(status);
        res.setContentType("application/json;charset=UTF-8");
        res.getWriter().write("{\"message\":\"" + message + "\"}");
    }

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Autowired
    private JwtAuthFilter jwtAuthFilter;

    @Autowired
    private OAuth2SuccessHandler oAuth2SuccessHandler;

    @org.springframework.beans.factory.annotation.Value("${app.frontendUrl}")
    private String frontendUrl;

    /** Cho phép 3 Vue dev server gọi API: :5173 khách, :5174 admin, :5175 POS showroom. */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(List.of(
                "http://localhost:5173", "http://localhost:5174", "http://localhost:5175"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration cfg) throws Exception {
        return cfg.getAuthenticationManager();
    }

    // ============================================================
    //  Chain 1: REST API (/api/**) — stateless, xác thực bằng JWT
    // ============================================================
    @Bean
    @Order(1)
    public SecurityFilterChain apiSecurityChain(HttpSecurity http) throws Exception {
        http
            .securityMatcher("/api/**")
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                    .requestMatchers("/api/auth/login", "/api/auth/register", "/api/auth/forgot-password/**").permitAll()
                    .requestMatchers("/api/categories/**", "/api/products/**").permitAll()
                    .requestMatchers("/api/contact").permitAll()
                    .requestMatchers("/api/compare").permitAll()
                    .requestMatchers("/api/provinces/**").permitAll()
                    .requestMatchers("/api/shipping/**").permitAll()
                    .requestMatchers("/api/membership/tiers").permitAll()
                    .requestMatchers("/api/subscription/plans").permitAll()
                    .requestMatchers("/api/geocoding/**").permitAll()
                    // Trung tâm hỗ trợ: tra trung tâm bảo hành, giá sửa chữa, FAQ và ĐẶT lịch
                    // dịch vụ đều công khai — khách cần xem được trước khi có tài khoản, và shop
                    // nhận sửa dịch vụ cho cả máy mua nơi khác. Hai đường liên quan tới lịch của
                    // CHÍNH MÌNH phải khai TRƯỚC vì matcher xét theo thứ tự, /api/support/**
                    // đứng trên sẽ nuốt mất chúng.
                    .requestMatchers("/api/support/lich-hen/cua-toi", "/api/support/lich-hen/*/huy").authenticated()
                    .requestMatchers("/api/support/**").permitAll()
                    // Tin tức công khai (đọc). Biên tập nằm ở /api/admin/articles (quyền articles).
                    .requestMatchers(HttpMethod.GET, "/api/articles/**", "/api/article-categories").permitAll()
                    // Xem kỳ hạn + tính thử khoản trả hàng tháng là công khai (hiện ngay ở trang
                    // sản phẩm); ĐĂNG KÝ hồ sơ vẫn phải đăng nhập.
                    .requestMatchers(HttpMethod.GET, "/api/installment/config", "/api/installment/quote").permitAll()
                    // Chỉ ĐỌC banner đang chạy là công khai; /api/flash-sale/admin/** rơi xuống
                    // anyRequest().authenticated() rồi qua @RequirePermission("coupons").
                    .requestMatchers(HttpMethod.GET, "/api/flash-sale").permitAll()
                    .requestMatchers("/api/admin/**").hasAnyRole(STAFF_ROLES)
                    .anyRequest().authenticated()
            )
            // API JSON không bao giờ redirect sang trang đăng nhập Thymeleaf.
            // Lưu ý: dùng response.sendError() sẽ kích hoạt ERROR dispatch sang "/error",
            // request đó lại bị webSecurityChain (anyRequest().authenticated()) xử lý lại và
            // redirect sang /DustNovel/login. Vì vậy phải ghi thẳng JSON, không sendError().
            .exceptionHandling(eh -> eh
                    .authenticationEntryPoint((req, res, e) -> writeJsonError(res, 401, "Chưa đăng nhập hoặc token không hợp lệ"))
                    .accessDeniedHandler((req, res, e) -> writeJsonError(res, 403, "Không có quyền truy cập"))
            )
            .userDetailsService(userDetailsService)
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    // ============================================================
    //  Chain 1b: Callback cổng thanh toán (Stripe redirect + webhook) — browser
    //  quay lại đây sau khi thanh toán trên trang Stripe (hoặc Stripe gọi server-to-
    //  server), không kèm JWT nên phải permitAll riêng, tách khỏi chain 2 (anyRequest
    //  authenticated()). Không cần nới lỏng iframe như VNPay trước đây vì Stripe
    //  Checkout dùng redirect toàn trang, không nhúng iframe.
    // ============================================================
    @Bean
    @Order(0)
    public SecurityFilterChain paymentGatewaySecurityChain(HttpSecurity http) throws Exception {
        http
            .securityMatcher("/payment/**")
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
        return http.build();
    }

    // ============================================================
    //  Chain 2: Web Thymeleaf (admin, ...) — form login + session
    //  (giữ nguyên như cũ, không ảnh hưởng admin)
    // ============================================================
    @Bean
    @Order(2)
    public SecurityFilterChain webSecurityChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                    .requestMatchers(
                            "/DustNovel/login",
                            "/DustNovel/register",
                            "/DustNovel/forgot-password",
                            "/css/**",
                            "/js/**",
                            "/images/**",
                            "/uploads/**",
                            "/oauth2/**",
                            "/login/oauth2/**"
                    ).permitAll()
                    .requestMatchers("/admin/users/**").hasRole("ADMIN")
                    .requestMatchers("/admin/products/**", "/admin/categories/**").hasAnyRole(STAFF_ROLES)
                    .requestMatchers("/account/**").hasAnyRole(STAFF_AND_CUSTOMER_ROLES)
                    .requestMatchers("/cart/**", "/orders/**", "/account/addresses/**").hasAnyRole(STAFF_AND_CUSTOMER_ROLES)
                    .requestMatchers("/admin/orders/**", "/admin/gio-hang/**").hasAnyRole(STAFF_ROLES)
                    .anyRequest().authenticated()
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
            )
            // Đăng nhập Google / Facebook — thành công thì phát JWT và chuyển thẳng về Vue SPA
            // (xem OAuth2SuccessHandler), thất bại (vd chưa cấu hình Client ID/Secret thật) thì
            // quay lại trang đăng nhập kèm thông báo lỗi thay vì trang lỗi trắng mặc định.
            .oauth2Login(oauth2 -> oauth2
                .successHandler(oAuth2SuccessHandler)
                .failureHandler((req, res, ex) -> res.sendRedirect(
                        frontendUrl + "/?oauthError=" + URLEncoder.encode(
                                "Đăng nhập mạng xã hội thất bại: " + ex.getMessage(), StandardCharsets.UTF_8)))
            );

        return http.build();
    }
}
