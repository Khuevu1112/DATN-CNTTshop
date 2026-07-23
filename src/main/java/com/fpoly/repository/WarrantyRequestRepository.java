package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.Warranty;
import com.fpoly.model.WarrantyRequest;

public interface WarrantyRequestRepository extends JpaRepository<WarrantyRequest, Integer> {

    List<WarrantyRequest> findByWarrantyOrderByCreatedAtDesc(Warranty warranty);

    List<WarrantyRequest> findAllByOrderByCreatedAtDesc();
}
