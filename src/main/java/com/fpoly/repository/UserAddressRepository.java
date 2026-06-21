package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.UserAddress;

public interface UserAddressRepository extends JpaRepository<UserAddress, Integer> {

    List<UserAddress> findByNguoiDung(NguoiDung nguoiDung);

    Optional<UserAddress> findByNguoiDungAndIsDefaultTrue(NguoiDung nguoiDung);
}