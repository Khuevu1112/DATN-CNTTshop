package com.fpoly.repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.CheckinLog;
import com.fpoly.model.NguoiDung;

public interface CheckinLogRepository extends JpaRepository<CheckinLog, Integer> {
    Optional<CheckinLog> findByNguoiDungAndNgayDiemDanh(NguoiDung nguoiDung, LocalDate ngayDiemDanh);

    List<CheckinLog> findByNguoiDungOrderByNgayDiemDanhDesc(NguoiDung nguoiDung);

    Optional<CheckinLog> findTopByNguoiDungOrderByNgayDiemDanhDesc(NguoiDung nguoiDung);
}
