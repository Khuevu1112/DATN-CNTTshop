package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.Category;
import com.fpoly.model.Product;

public interface ProductRepository extends JpaRepository<Product, Integer> {

    // ── Các method cũ giữ nguyên ──────────────────────────────

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

    List<Product> findByIdIn(List<Integer> ids);

    // ── Method mới cho PcBuild builder ────────────────────────

    // Tìm sản phẩm theo slug của category (dùng cho builder)
    Page<Product> findByCategorySlugAndIsActiveTrue(String slug, Pageable pageable);

    // Tìm sản phẩm theo slug của category + keyword tìm kiếm
    Page<Product> findByCategorySlugAndNameContainingIgnoreCaseAndIsActiveTrue(
            String slug,
            String name,
            Pageable pageable
    );
}