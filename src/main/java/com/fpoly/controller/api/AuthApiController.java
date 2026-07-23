package com.fpoly.controller.api;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.dto.AuthDtos.AuthResponse;
import com.fpoly.dto.AuthDtos.ChangePasswordRequest;
import com.fpoly.dto.AuthDtos.ForgotPasswordResetRequest;
import com.fpoly.dto.AuthDtos.ForgotPasswordSendOtpRequest;
import com.fpoly.dto.AuthDtos.ForgotPasswordVerifyOtpRequest;
import com.fpoly.dto.AuthDtos.LoginRequest;
import com.fpoly.dto.AuthDtos.MessageResponse;
import com.fpoly.dto.AuthDtos.RegisterRequest;
import com.fpoly.dto.AuthDtos.UpdateProfileRequest;
import com.fpoly.dto.AuthDtos.UserDto;
import com.fpoly.model.NguoiDung;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.security.JwtService;
import com.fpoly.service.AccountLogService;
import com.fpoly.service.ForgotPasswordService;
import com.fpoly.service.RegisterService;

import jakarta.servlet.http.HttpServletRequest;

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

    @Autowired
    private ForgotPasswordService forgotPasswordService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AccountLogService accountLogService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest req, HttpServletRequest request) {
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

        try {
            accountLogService.logLogin(u, request.getRemoteAddr());
        } catch (Exception e) {
            // Không chặn luồng đăng nhập nếu ghi log thất bại
        }

        String token = jwtService.generateToken(u.getEmail(), u.getVaiTro().name());
        return ResponseEntity.ok(new AuthResponse(token, toUserDto(u)));
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

    @PostMapping("/forgot-password/send-otp")
    public ResponseEntity<?> sendOtp(@RequestBody ForgotPasswordSendOtpRequest req) {
        String error = forgotPasswordService.guiOtp(req.email());
        if (error != null) {
            return ResponseEntity.badRequest().body(new MessageResponse(error));
        }
        return ResponseEntity.ok(new MessageResponse("Đã gửi mã xác nhận tới email"));
    }

    @PostMapping("/forgot-password/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestBody ForgotPasswordVerifyOtpRequest req) {
        String error = forgotPasswordService.xacThucOtp(req.email(), req.otp());
        if (error != null) {
            return ResponseEntity.badRequest().body(new MessageResponse(error));
        }
        return ResponseEntity.ok(new MessageResponse("Mã xác nhận hợp lệ"));
    }

    @PostMapping("/forgot-password/reset")
    public ResponseEntity<?> resetPassword(@RequestBody ForgotPasswordResetRequest req) {
        String error = forgotPasswordService.datLaiMatKhau(
                req.email(), req.otp(), req.matKhauMoi(), req.nhapLaiMatKhau());
        if (error != null) {
            return ResponseEntity.badRequest().body(new MessageResponse(error));
        }
        return ResponseEntity.ok(new MessageResponse("Đổi mật khẩu thành công"));
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
        return ResponseEntity.ok(toUserDto(u));
    }

    @PutMapping("/me")
    public ResponseEntity<?> updateMe(@RequestBody UpdateProfileRequest req, Authentication auth) {
        if (auth == null || auth.getName() == null) {
            return ResponseEntity.status(401).build();
        }
        NguoiDung u = nguoiDungRepo.findByEmail(auth.getName()).orElse(null);
        if (u == null) {
            return ResponseEntity.status(404).build();
        }
        if (req.hoTen() == null || req.hoTen().isBlank()) {
            return ResponseEntity.badRequest().body(new MessageResponse("Họ tên không được để trống"));
        }
        u.setHoTen(req.hoTen().trim());
        u.setSoDienThoai(req.soDienThoai() != null ? req.soDienThoai().trim() : null);
        nguoiDungRepo.save(u);
        return ResponseEntity.ok(toUserDto(u));
    }

    @PutMapping("/me/password")
    public ResponseEntity<?> changePassword(@RequestBody ChangePasswordRequest req, Authentication auth) {
        if (auth == null || auth.getName() == null) {
            return ResponseEntity.status(401).build();
        }
        NguoiDung u = nguoiDungRepo.findByEmail(auth.getName()).orElse(null);
        if (u == null) {
            return ResponseEntity.status(404).build();
        }
        if (!"local".equals(u.getAuthProvider())) {
            return ResponseEntity.badRequest().body(new MessageResponse(
                    "Tài khoản đăng nhập qua mạng xã hội không thể đổi mật khẩu ở đây"));
        }
        if (req.matKhauHienTai() == null || !passwordEncoder.matches(req.matKhauHienTai(), u.getMatKhau())) {
            return ResponseEntity.badRequest().body(new MessageResponse("Mật khẩu hiện tại không đúng"));
        }
        if (req.matKhauMoi() == null || req.matKhauMoi().length() < 6) {
            return ResponseEntity.badRequest().body(new MessageResponse("Mật khẩu mới phải có ít nhất 6 ký tự"));
        }
        if (!req.matKhauMoi().equals(req.nhapLaiMatKhauMoi())) {
            return ResponseEntity.badRequest().body(new MessageResponse("Mật khẩu nhập lại không khớp"));
        }
        u.setMatKhau(passwordEncoder.encode(req.matKhauMoi()));
        nguoiDungRepo.save(u);
        return ResponseEntity.ok(new MessageResponse("Đổi mật khẩu thành công"));
    }

    private UserDto toUserDto(NguoiDung u) {
        return new UserDto(u.getId(), u.getHoTen(), u.getEmail(), u.getVaiTro().name(),
                u.getSoDienThoai(), u.getAuthProvider());
    }
}
