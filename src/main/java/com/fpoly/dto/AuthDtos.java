package com.fpoly.dto;

public class AuthDtos {

    public record LoginRequest(String username, String password) {}

    public record RegisterRequest(
            String hoTen,
            String email,
            String soDienThoai,
            String matKhau,
            String reMatKhau
    ) {}

    public record UserDto(Integer id, String fullName, String email, String role, String phone, String authProvider) {}

    public record AuthResponse(String token, UserDto user) {}

    public record MessageResponse(String message) {}

    public record UpdateProfileRequest(String hoTen, String soDienThoai) {}

    public record ChangePasswordRequest(String matKhauHienTai, String matKhauMoi, String nhapLaiMatKhauMoi) {}

    public record ForgotPasswordSendOtpRequest(String email) {}
    public record ForgotPasswordVerifyOtpRequest(String email, String otp) {}
    public record ForgotPasswordResetRequest(String email, String otp, String matKhauMoi, String nhapLaiMatKhau) {}
}
