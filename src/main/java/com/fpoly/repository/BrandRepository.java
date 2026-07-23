package com.fpoly.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.Brand;

public interface BrandRepository extends JpaRepository<Brand, Integer> {
}
