package com.fpoly.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.Wallet;

public interface WalletRepository extends JpaRepository<Wallet, Integer> {
    Optional<Wallet> findByNguoiDung(NguoiDung nguoiDung);
}
