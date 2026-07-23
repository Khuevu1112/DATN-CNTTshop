package com.fpoly.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.ProductImage;

public interface ProductImageRepository extends JpaRepository<ProductImage, Integer> {

    void deleteByProductId(Integer productId);
}
