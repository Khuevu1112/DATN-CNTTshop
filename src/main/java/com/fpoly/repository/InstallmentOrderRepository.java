package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.InstallmentOrder;
import com.fpoly.model.NguoiDung;

public interface InstallmentOrderRepository extends JpaRepository<InstallmentOrder, Integer> {
    List<InstallmentOrder> findAllByOrderByCreatedAtDesc();
    List<InstallmentOrder> findByTrangThaiOrderByCreatedAtDesc(String trangThai);
    List<InstallmentOrder> findByNguoiDungOrderByCreatedAtDesc(NguoiDung nguoiDung);
}
