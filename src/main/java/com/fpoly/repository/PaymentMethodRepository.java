package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.PaymentMethod;

public interface PaymentMethodRepository extends JpaRepository<PaymentMethod, Integer> {

    Optional<PaymentMethod> findByCode(String code);

    List<PaymentMethod> findByIsActiveTrueOrderByIdAsc();
}
