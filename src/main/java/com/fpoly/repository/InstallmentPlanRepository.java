package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.InstallmentPlan;

public interface InstallmentPlanRepository extends JpaRepository<InstallmentPlan, Integer> {
    List<InstallmentPlan> findByActiveTrueOrderBySoThangAsc();
    Optional<InstallmentPlan> findBySoThang(Integer soThang);
}
