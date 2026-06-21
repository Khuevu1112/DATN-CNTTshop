package com.fpoly.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.fpoly.model.NguoiDung;
import com.fpoly.repository.NguoiDungRepository;

@Service
public class ForgotPasswordService {

    @Autowired
    private NguoiDungRepository repo;

    @Autowired
    private PasswordEncoder encoder;

    public String resetPassword(
            String email,
            String matKhauMoi,
            String nhapLaiMatKhau
    ) {

        if (email == null || email.isBlank()) {
            return "Vui lòng nhập email";
        }

        if (matKhauMoi == null || matKhauMoi.isBlank()) {
            return "Vui lòng nhập mật khẩu mới";
        }

        if (!matKhauMoi.equals(nhapLaiMatKhau)) {
            return "Mật khẩu nhập lại không khớp";
        }

        NguoiDung user = repo.findByEmail(email).orElse(null);

        if (user == null) {
            return "Email không tồn tại";
        }

        user.setMatKhau(encoder.encode(matKhauMoi));

        repo.save(user);

        return null;
    }
}