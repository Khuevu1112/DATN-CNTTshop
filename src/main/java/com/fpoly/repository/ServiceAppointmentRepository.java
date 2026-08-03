package com.fpoly.repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.ServiceAppointment;

public interface ServiceAppointmentRepository extends JpaRepository<ServiceAppointment, Integer> {

    Optional<ServiceAppointment> findByMaLich(String maLich);

    List<ServiceAppointment> findByUserEmailOrderByCreatedAtDesc(String email);

    /** Khung giờ đã bị chiếm của một trung tâm trong một ngày. Lịch đã huỷ / khách không đến
     * phải nhả chỗ ra, khớp với filtered unique index ở tầng CSDL. */
    @Query("SELECT a.khungGio FROM ServiceAppointment a WHERE a.center.id = :centerId "
            + "AND a.ngayHen = :ngay AND a.trangThai NOT IN ('da_huy', 'khach_khong_den')")
    List<String> findKhungGioDaDat(@Param("centerId") Integer centerId, @Param("ngay") LocalDate ngay);

    @Query("SELECT a FROM ServiceAppointment a JOIN FETCH a.center LEFT JOIN FETCH a.user "
            + "ORDER BY a.ngayHen DESC, a.khungGio")
    List<ServiceAppointment> findAllForAdmin();

    @Query("SELECT a FROM ServiceAppointment a JOIN FETCH a.center LEFT JOIN FETCH a.user "
            + "WHERE a.trangThai = :trangThai ORDER BY a.ngayHen DESC, a.khungGio")
    List<ServiceAppointment> findByTrangThaiForAdmin(@Param("trangThai") String trangThai);

    /** Trung tâm đã từng có lịch hẹn nào chưa — quyết định xoá cứng hay chỉ ẩn đi. */
    boolean existsByCenterId(Integer centerId);
}
