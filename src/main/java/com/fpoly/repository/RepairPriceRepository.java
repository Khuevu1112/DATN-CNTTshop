package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.RepairPrice;

public interface RepairPriceRepository extends JpaRepository<RepairPrice, Integer> {

    List<RepairPrice> findByHienThiTrueOrderBySortOrderAsc();

    List<RepairPrice> findByHienThiTrueAndLoaiThietBiOrderBySortOrderAsc(String loaiThietBi);

    List<RepairPrice> findAllByOrderByLoaiThietBiAscSortOrderAsc();
}
