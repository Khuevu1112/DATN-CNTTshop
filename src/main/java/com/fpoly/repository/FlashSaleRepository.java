package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.FlashSale;

public interface FlashSaleRepository extends JpaRepository<FlashSale, Integer> {

    /** Đợt gần nhất — hệ thống chỉ cho tồn tại 1 đợt còn hiệu lực nên thực tế danh sách rất ngắn
     * (xem FlashSaleService.dangCoDotConHieuLuc). */
    List<FlashSale> findAllByOrderByIdDesc();

    Optional<FlashSale> findFirstByIsActiveTrueOrderByIdDesc();
}
