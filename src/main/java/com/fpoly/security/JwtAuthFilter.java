package com.fpoly.security;

import java.io.IOException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.fpoly.repository.NguoiDungRepository;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    @Autowired
    private JwtService jwtService;

    @Autowired
    private NguoiDungRepository nguoiDungRepo;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String header = request.getHeader("Authorization");

        if (header != null && header.startsWith("Bearer ")
                && SecurityContextHolder.getContext().getAuthentication() == null) {
            String token = header.substring(7);
            try {
                io.jsonwebtoken.Claims claims = jwtService.parse(token);
                String email = claims.getSubject();

                // Tra lại DB mỗi request thay vì tin thẳng role/trạng thái nhúng trong token — token
                // cũ cấp trước khi tài khoản bị khoá (hoặc đổi phòng ban) sẽ mất hiệu lực ngay lập
                // tức thay vì phải đợi hết hạn (JWT không có cơ chế thu hồi token đang lưu hành).
                if (email != null) {
                    nguoiDungRepo.findByEmail(email).ifPresent(u -> {
                        if (Boolean.TRUE.equals(u.getIsActive())) {
                            var authorities = List.of(new SimpleGrantedAuthority("ROLE_" + u.getVaiTro().name().toUpperCase()));
                            var authentication = new UsernamePasswordAuthenticationToken(email, null, authorities);
                            authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                            SecurityContextHolder.getContext().setAuthentication(authentication);
                        }
                    });
                }
            } catch (Exception ignored) {
                // token sai / hết hạn -> để request là anonymous, không chặn ở filter
            }
        }

        filterChain.doFilter(request, response);
    }
}
