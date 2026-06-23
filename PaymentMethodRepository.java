/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.fpoly.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.PaymentMethod;

public interface PaymentMethodRepository
        extends JpaRepository<PaymentMethod, Integer> {

    Optional<PaymentMethod> findByCode(String code);
}
