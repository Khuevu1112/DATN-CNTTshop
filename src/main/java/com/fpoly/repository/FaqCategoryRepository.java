package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.FaqCategory;

public interface FaqCategoryRepository extends JpaRepository<FaqCategory, Integer> {

    List<FaqCategory> findByHienThiTrueOrderBySortOrderAsc();

    List<FaqCategory> findAllByOrderBySortOrderAsc();

    Optional<FaqCategory> findByMa(String ma);
}
