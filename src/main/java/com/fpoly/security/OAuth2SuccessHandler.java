package com.fpoly.security;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.enums.VaiTro;
import com.fpoly.repository.NguoiDungRepository;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Xử lý sau khi đăng nhập Google/Facebook thành công: tìm hoặc tự tạo tài khoản theo email,
 * phát JWT giống hệt flow đăng nhập thường, rồi chuyển hướng thẳng về Vue SPA kèm token.
 * Tài khoản tự tạo có mật khẩu ngẫu nhiên (không dùng được) — chủ tài khoản có thể đặt mật
 * khẩu thật qua "Quên mật khẩu" nếu muốn đăng nhập bằng email/mật khẩu sau này.
 */
@Component
public class OAuth2SuccessHandler implements AuthenticationSuccessHandler {

    @Autowired
    private NguoiDungRepository nguoiDungRepo;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Value("${app.frontendUrl}")
    private String frontendUrl;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                         Authentication authentication) throws IOException {
        OAuth2AuthenticationToken oauthToken = (OAuth2AuthenticationToken) authentication;
        OAuth2User oAuth2User = oauthToken.getPrincipal();
        String email = oAuth2User.getAttribute("email");
        String name = oAuth2User.getAttribute("name");
        String provider = oauthToken.getAuthorizedClientRegistrationId();

        if (email == null || email.isBlank()) {
            response.sendRedirect(frontendUrl + "/?oauthError=" + URLEncoder.encode(
                    "Tài khoản mạng xã hội không chia sẻ email, không thể đăng nhập", StandardCharsets.UTF_8));
            return;
        }

        NguoiDung user = nguoiDungRepo.findByEmail(email).orElseGet(() -> {
            NguoiDung nd = new NguoiDung();
            nd.setHoTen(name != null && !name.isBlank() ? name : email);
            nd.setEmail(email);
            nd.setMatKhau(passwordEncoder.encode(UUID.randomUUID().toString()));
            nd.setAuthProvider(provider);
            nd.setVaiTro(VaiTro.customer);
            nd.setIsActive(true);
            nd.setCreatedAt(LocalDateTime.now());
            return nguoiDungRepo.save(nd);
        });

        String token = jwtService.generateToken(user.getEmail(), user.getVaiTro().name());
        response.sendRedirect(frontendUrl + "/?oauthToken=" + URLEncoder.encode(token, StandardCharsets.UTF_8));
    }
}
