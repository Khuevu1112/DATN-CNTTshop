package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.ProductOption;

public interface ProductOptionRepository extends JpaRepository<ProductOption, Integer> {

    List<ProductOption> findByProductId(Integer productId);

    void deleteByProductId(Integer productId);
}
