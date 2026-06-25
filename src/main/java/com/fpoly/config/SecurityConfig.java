package com.fpoly.config;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import com.fpoly.security.JwtAuthFilter;
import com.fpoly.service.CustomUserDetailsService;

import java.io.IOException;
import jakarta.servlet.http.HttpServletResponse;

@Configuration
public class SecurityConfig {

    private static void writeJsonError(HttpServletResponse res, int status, String message) throws IOException {
        res.setStatus(status);
        res.setContentType("application/json;charset=UTF-8");
        res.getWriter().write("{\"message\":\"" + message + "\"}");
    }

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Autowired
    private JwtAuthFilter jwtAuthFilter;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /** Cho phép Vue dev server (Vite :5173 và :5174) gọi API. */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(List.of("http://localhost:5173", "http://localhost:5174"));
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
                    .requestMatchers("/api/auth/login", "/api/auth/register").permitAll()
                    .requestMatchers("/api/categories/**", "/api/products/**").permitAll()
                    .requestMatchers("/api/admin/**").hasAnyRole("ADMIN", "STAFF")
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
                            "/images/**"
                    ).permitAll()
                    .requestMatchers("/admin/users/**").hasRole("ADMIN")
                    .requestMatchers("/admin/products/**", "/admin/categories/**").hasAnyRole("ADMIN", "STAFF")
                    .requestMatchers("/account/**").hasAnyRole("ADMIN", "STAFF", "CUSTOMER")
                    .requestMatchers("/cart/**", "/orders/**", "/account/addresses/**").hasAnyRole("ADMIN", "STAFF", "CUSTOMER")
                    .requestMatchers("/admin/orders/**", "/admin/gio-hang/**").hasAnyRole("ADMIN", "STAFF")
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
            );

        return http.build();
    }
}
