package com.fpoly.controller.api;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.dto.AuthDtos.AuthResponse;
import com.fpoly.dto.AuthDtos.LoginRequest;
import com.fpoly.dto.AuthDtos.MessageResponse;
import com.fpoly.dto.AuthDtos.RegisterRequest;
import com.fpoly.dto.AuthDtos.UserDto;
import com.fpoly.model.NguoiDung;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.security.JwtService;
import com.fpoly.service.RegisterService;

@RestController
@RequestMapping("/api/auth")
public class AuthApiController {

    @Autowired
    private AuthenticationManager authManager;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private NguoiDungRepository nguoiDungRepo;

    @Autowired
    private RegisterService registerService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest req) {
        if (req == null || req.username() == null || req.password() == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("Thiếu thông tin đăng nhập"));
        }
        try {
            authManager.authenticate(
                    new UsernamePasswordAuthenticationToken(req.username().trim(), req.password()));
        } catch (AuthenticationException e) {
            return ResponseEntity.status(401).body(new MessageResponse("Sai tài khoản hoặc mật khẩu"));
        }

        NguoiDung u = nguoiDungRepo.findByEmail(req.username().trim())
                .or(() -> nguoiDungRepo.findBySoDienThoai(req.username().trim()))
                .orElse(null);
        if (u == null) {
            return ResponseEntity.status(401).body(new MessageResponse("Không tìm thấy tài khoản"));
        }

        String token = jwtService.generateToken(u.getEmail(), u.getVaiTro().name());
        return ResponseEntity.ok(new AuthResponse(token,
                new UserDto(u.getId(), u.getHoTen(), u.getEmail(), u.getVaiTro().name())));
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest req) {
        if (req == null || req.email() == null || req.matKhau() == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("Thiếu thông tin đăng ký"));
        }
        NguoiDung nd = new NguoiDung();
        nd.setHoTen(req.hoTen());
        nd.setEmail(req.email());
        nd.setSoDienThoai(req.soDienThoai());
        nd.setMatKhau(req.matKhau());

        String error = registerService.register(nd, req.reMatKhau());
        if (error != null) {
            return ResponseEntity.badRequest().body(new MessageResponse(error));
        }
        return ResponseEntity.ok(new MessageResponse("Đăng ký thành công"));
    }

    @GetMapping("/me")
    public ResponseEntity<?> me(Authentication auth) {
        if (auth == null || auth.getName() == null) {
            return ResponseEntity.status(401).build();
        }
        NguoiDung u = nguoiDungRepo.findByEmail(auth.getName()).orElse(null);
        if (u == null) {
            return ResponseEntity.status(404).build();
        }
        return ResponseEntity.ok(new UserDto(u.getId(), u.getHoTen(), u.getEmail(), u.getVaiTro().name()));
    }
}
