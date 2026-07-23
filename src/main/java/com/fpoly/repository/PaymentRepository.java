package com.fpoly.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.Order;
import com.fpoly.model.Payment;

public interface PaymentRepository extends JpaRepository<Payment, Integer> {

    Optional<Payment> findByOrder(Order order);
}
