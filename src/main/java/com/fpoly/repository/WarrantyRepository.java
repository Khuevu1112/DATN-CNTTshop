package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.OrderItem;
import com.fpoly.model.Warranty;

public interface WarrantyRepository extends JpaRepository<Warranty, Integer> {

    List<Warranty> findByNguoiDung(NguoiDung nguoiDung);

    boolean existsByOrderItem(OrderItem item);

    Optional<Warranty> findByOrderItem(OrderItem item);

    List<Warranty> findAllByOrderByIdDesc();

    List<Warranty> findByStatusOrderByIdDesc(String status);

    List<Warranty> findByNguoiDungEmailOrderByIdDesc(String email);

    @Query("SELECT w FROM Warranty w JOIN FETCH w.nguoiDung JOIN FETCH w.orderItem WHERE w.id = :id")
    Warranty findDetail(@Param("id") Integer id);

    /** Tra cứu công khai theo serial (trang "Thông tin bảo hành"). LOWER + TRIM ở tầng CSDL vì
     * serial nhập tay từ tem máy hay lẫn khoảng trắng và khác hoa/thường. Trả về List thay vì
     * Optional để dữ liệu bẩn (hai phiếu trùng serial do nhập nhầm) không ném exception vào
     * mặt khách — service tự lấy bản ghi đầu. */
    @Query("SELECT w FROM Warranty w LEFT JOIN FETCH w.orderItem "
            + "WHERE LOWER(TRIM(w.serialNumber)) = LOWER(TRIM(:serial)) ORDER BY w.id DESC")
    List<Warranty> findBySerial(@Param("serial") String serial);

    /** Tra cứu công khai theo mã bảo hành (BHCNTT****) HOẶC serial — khách nhập mã nào cũng ra.
     * Mã bảo hành là khoá chính thức, serial giữ lại cho ai chỉ có tem máy. */
    @Query("SELECT w FROM Warranty w LEFT JOIN FETCH w.orderItem "
            + "WHERE UPPER(TRIM(w.maBaoHanh)) = UPPER(TRIM(:ma)) "
            + "OR LOWER(TRIM(w.serialNumber)) = LOWER(TRIM(:ma)) ORDER BY w.id DESC")
    List<Warranty> findByMaBaoHanhOrSerial(@Param("ma") String ma);

    boolean existsByMaBaoHanh(String maBaoHanh);
}
