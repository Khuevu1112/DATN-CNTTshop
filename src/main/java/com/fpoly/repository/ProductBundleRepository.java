package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.ProductBundle;

public interface ProductBundleRepository extends JpaRepository<ProductBundle, Integer> {

    List<ProductBundle> findByProductId(Integer productId);

    void deleteByProductId(Integer productId);
}
