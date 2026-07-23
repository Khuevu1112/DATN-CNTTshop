package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.RedemptionItem;

public interface RedemptionItemRepository extends JpaRepository<RedemptionItem, Integer> {
    List<RedemptionItem> findByIsActiveTrueOrderByThuTuAsc();
}
