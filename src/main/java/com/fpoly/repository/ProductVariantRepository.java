package com.fpoly.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.ProductVariant;

public interface ProductVariantRepository extends JpaRepository<ProductVariant, Integer> {
}