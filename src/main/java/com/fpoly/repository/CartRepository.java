package com.fpoly.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.Cart;
import com.fpoly.model.NguoiDung;

public interface CartRepository extends JpaRepository<Cart, Integer> {

    Optional<Cart> findByNguoiDung(NguoiDung nguoiDung);
}