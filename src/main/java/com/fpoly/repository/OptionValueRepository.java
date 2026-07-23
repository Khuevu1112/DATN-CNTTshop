package com.fpoly.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.OptionValue;

public interface OptionValueRepository extends JpaRepository<OptionValue, Integer> {

    void deleteByOptionId(Integer optionId);
}
