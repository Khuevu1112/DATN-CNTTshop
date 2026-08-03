package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.ArticleCategory;

public interface ArticleCategoryRepository extends JpaRepository<ArticleCategory, Integer> {
    List<ArticleCategory> findByHienThiTrueOrderBySortOrderAsc();
    List<ArticleCategory> findAllByOrderBySortOrderAsc();
    Optional<ArticleCategory> findByMa(String ma);
}
