package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.Supplier;

public interface SupplierRepository extends JpaRepository<Supplier, Integer> {

    List<Supplier> findByHienThiTrueOrderByTenAsc();

    List<Supplier> findAllByOrderByTenAsc();
}
