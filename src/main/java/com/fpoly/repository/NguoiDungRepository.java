package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.enums.VaiTro;

public interface NguoiDungRepository extends JpaRepository<NguoiDung, Integer> {

    List<NguoiDung> findByVaiTro(VaiTro vaiTro);

    Optional<NguoiDung> findByEmail(String email);

    Optional<NguoiDung> findBySoDienThoai(String soDienThoai);

    boolean existsByEmail(String email);

    boolean existsBySoDienThoai(String soDienThoai);
}