package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.OrderItem;
import com.fpoly.model.Warranty;

public interface WarrantyRepository extends JpaRepository<Warranty, Integer> {

    List<Warranty> findByNguoiDung(NguoiDung nguoiDung);

    boolean existsByOrderItem(OrderItem item);

    Optional<Warranty> findByOrderItem(OrderItem item);

    List<Warranty> findAllByOrderByIdDesc();

    List<Warranty> findByStatusOrderByIdDesc(String status);

    List<Warranty> findByNguoiDungEmailOrderByIdDesc(String email);

    @Query("SELECT w FROM Warranty w JOIN FETCH w.nguoiDung JOIN FETCH w.orderItem WHERE w.id = :id")
    Warranty findDetail(@Param("id") Integer id);
}
