package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.Province;
import com.fpoly.model.Ward;

public interface WardRepository extends JpaRepository<Ward, Integer> {
    List<Ward> findByProvinceOrderByNameAsc(Province province);

    List<Ward> findByProvince_IdOrderByNameAsc(Integer provinceId);
}
