package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.WarrantyHistory;
import com.fpoly.model.WarrantyRequest;

public interface WarrantyHistoryRepository extends JpaRepository<WarrantyHistory, Integer> {

    List<WarrantyHistory> findByRequestOrderByCreatedAtAsc(WarrantyRequest request);
}
