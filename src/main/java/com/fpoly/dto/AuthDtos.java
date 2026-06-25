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

    public record UserDto(Integer id, String fullName, String email, String role) {}

    public record AuthResponse(String token, UserDto user) {}

    public record MessageResponse(String message) {}
}
