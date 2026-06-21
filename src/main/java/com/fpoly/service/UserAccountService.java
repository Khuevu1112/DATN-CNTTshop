package com.fpoly.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.enums.VaiTro;
import com.fpoly.repository.NguoiDungRepository;

@Service
public class UserAccountService {

    @Autowired
    private NguoiDungRepository repo;

    public NguoiDung findByEmail(String email) {
        return repo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản"));
    }

    public List<NguoiDung> findAll() {
        return repo.findAll();
    }

    public NguoiDung findById(Integer id) {
        return repo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
    }

    public void updateProfile(String email, String hoTen, String soDienThoai) {
        NguoiDung user = findByEmail(email);

        user.setHoTen(hoTen);
        user.setSoDienThoai(soDienThoai);

        repo.save(user);
    }

    public void adminUpdateUser(Integer id, String hoTen, String soDienThoai, VaiTro vaiTro, Boolean isActive) {
        NguoiDung user = findById(id);

        user.setHoTen(hoTen);
        user.setSoDienThoai(soDienThoai);
        user.setVaiTro(vaiTro);
        user.setIsActive(isActive);

        repo.save(user);
    }
}