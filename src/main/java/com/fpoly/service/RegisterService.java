package com.fpoly.service;

import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.enums.VaiTro;
import com.fpoly.repository.NguoiDungRepository;

@Service
public class RegisterService {

    @Autowired
    private NguoiDungRepository repo;

    @Autowired
    private PasswordEncoder encoder;

    public String register(NguoiDung nd, String reMatKhau) {

        if (repo.existsByEmail(nd.getEmail())) {
            return "Email đã tồn tại";
        }

        if (!nd.getMatKhau().equals(reMatKhau)) {
            return "Mật khẩu không khớp";
        }

        nd.setMatKhau(encoder.encode(nd.getMatKhau()));
        nd.setVaiTro(VaiTro.customer);
        nd.setIsActive(true);

        // FIX LỖI created_at NULL
        nd.setCreatedAt(LocalDateTime.now());

        repo.save(nd);

        return null;
    }
}