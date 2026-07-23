package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.Carrier;

public interface CarrierRepository extends JpaRepository<Carrier, Integer> {
    Optional<Carrier> findByCode(String code);

    List<Carrier> findByIsActiveTrueOrderByThuTuAsc();

    List<Carrier> findAllByOrderByThuTuAsc();
}
