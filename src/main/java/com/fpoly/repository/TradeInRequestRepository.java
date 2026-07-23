package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.TradeInRequest;

public interface TradeInRequestRepository extends JpaRepository<TradeInRequest, Integer> {
    List<TradeInRequest> findByNguoiDungOrderByCreatedAtDesc(NguoiDung nguoiDung);
    List<TradeInRequest> findAllByOrderByCreatedAtDesc();
    List<TradeInRequest> findByTrangThaiOrderByCreatedAtDesc(String trangThai);
}
