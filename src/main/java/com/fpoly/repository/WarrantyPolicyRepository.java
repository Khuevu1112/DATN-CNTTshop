package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.WarrantyPolicy;

public interface WarrantyPolicyRepository extends JpaRepository<WarrantyPolicy, Integer> {

    List<WarrantyPolicy> findByHienThiTrueOrderBySortOrderAsc();

    List<WarrantyPolicy> findAllByOrderBySortOrderAsc();
}
