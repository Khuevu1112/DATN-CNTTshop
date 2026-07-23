package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.TradeInCredit;

public interface TradeInCreditRepository extends JpaRepository<TradeInCredit, Integer> {
    /** Tín dụng của MỘT khách — luôn lọc theo user, không bao giờ tra theo id trần, để người
     * khác biết id cũng không tiêu được. */
    List<TradeInCredit> findByNguoiDungOrderByCreatedAtDesc(NguoiDung nguoiDung);
    List<TradeInCredit> findByNguoiDungAndTrangThai(NguoiDung nguoiDung, String trangThai);
}
