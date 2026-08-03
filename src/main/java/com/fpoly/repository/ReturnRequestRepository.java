package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.ReturnRequest;

public interface ReturnRequestRepository extends JpaRepository<ReturnRequest, Integer> {

    List<ReturnRequest> findByUserEmailOrderByCreatedAtDesc(String email);

    Optional<ReturnRequest> findByMaYeuCau(String maYeuCau);

    @Query("SELECT r FROM ReturnRequest r JOIN FETCH r.user ORDER BY r.createdAt DESC")
    List<ReturnRequest> findAllForAdmin();

    @Query("SELECT r FROM ReturnRequest r JOIN FETCH r.user WHERE r.trangThai = :tt ORDER BY r.createdAt DESC")
    List<ReturnRequest> findByTrangThaiForAdmin(@Param("tt") String trangThai);
}
