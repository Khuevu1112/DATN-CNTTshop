package com.fpoly.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.PasswordResetOtp;

public interface PasswordResetOtpRepository extends JpaRepository<PasswordResetOtp, Integer> {

    PasswordResetOtp findTopByEmailAndIsUsedFalseOrderByCreatedAtDesc(String email);
}
