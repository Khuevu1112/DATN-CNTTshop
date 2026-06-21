package com.fpoly.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.enums.VaiTro;
import com.fpoly.repository.NguoiDungRepository;

@Service
public class AdminUserService {

    @Autowired
    private NguoiDungRepository repo;

    public List<NguoiDung> findAll() {
        return repo.findAll();
    }

    public NguoiDung findById(Integer id) {
        return repo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản"));
    }

    public void updateUser(
            Integer id,
            String hoTen,
            String soDienThoai,
            VaiTro vaiTro,
            Boolean isActive
    ) {
        NguoiDung user = findById(id);

        user.setHoTen(hoTen);
        user.setSoDienThoai(soDienThoai);
        user.setVaiTro(vaiTro);
        user.setIsActive(isActive);

        repo.save(user);
    }

    public String deleteUser(Integer id) {
        NguoiDung user = findById(id);

        if (user.getVaiTro() != null
                && user.getVaiTro().name().equalsIgnoreCase("admin")) {
            return "Không được xóa tài khoản ADMIN";
        }

        try {
            repo.deleteById(id);
            return null;
        } catch (Exception e) {
            return "Không thể xóa tài khoản vì có dữ liệu liên quan";
        }
    }
}