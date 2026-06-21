package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.Category;
import com.fpoly.model.Product;

public interface ProductRepository extends JpaRepository<Product, Integer> {

    Optional<Product> findBySlug(String slug);

    List<Product> findByIsActiveTrue();

    List<Product> findByCategory(Category category);

    long countByCategory(Category category);

    List<Product> findTop8ByCategoryAndIsActiveTrueOrderByCreatedAtDesc(Category category);

    List<Product> findByNameContainingIgnoreCaseAndIsActiveTrue(String keyword);

    List<Product> findByCategoryAndIsActiveTrue(Category category);

    List<Product> findByCategoryAndNameContainingIgnoreCaseAndIsActiveTrue(
            Category category,
            String keyword
    );
}