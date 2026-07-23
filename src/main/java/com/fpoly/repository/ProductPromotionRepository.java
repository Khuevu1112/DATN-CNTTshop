package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.ProductPromotion;

public interface ProductPromotionRepository extends JpaRepository<ProductPromotion, Integer> {

    List<ProductPromotion> findByProductIdOrderBySortOrderAsc(Integer productId);

    void deleteByProductId(Integer productId);
}
