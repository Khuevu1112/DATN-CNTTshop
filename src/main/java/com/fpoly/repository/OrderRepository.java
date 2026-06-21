package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.Order;

public interface OrderRepository extends JpaRepository<Order, Integer> {
    List<Order> findByNguoiDungOrderByCreatedAtDesc(NguoiDung nguoiDung);

    List<Order> findByTrangThaiOrderByCreatedAtDesc(String trangThai);

    List<Order> findAllByOrderByCreatedAtDesc();

    Optional<Order> findByMaDonHang(String maDonHang);
}