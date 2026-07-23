package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.Province;

public interface ProvinceRepository extends JpaRepository<Province, Integer> {
    List<Province> findAllByOrderByNameAsc();
}
