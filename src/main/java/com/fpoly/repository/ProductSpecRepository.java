package com.fpoly.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.ProductSpec;

public interface ProductSpecRepository extends JpaRepository<ProductSpec, Integer> {

    void deleteByProductId(Integer productId);
}
