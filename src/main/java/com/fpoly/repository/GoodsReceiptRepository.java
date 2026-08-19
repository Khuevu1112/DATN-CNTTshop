package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.fpoly.model.GoodsReceipt;

public interface GoodsReceiptRepository extends JpaRepository<GoodsReceipt, Integer> {

    Optional<GoodsReceipt> findByMaPhieu(String maPhieu);

    /** JOIN FETCH nhà cung cấp + người lập vì danh sách nào cũng hiển thị hai cột đó. */
    @Query("SELECT r FROM GoodsReceipt r LEFT JOIN FETCH r.supplier LEFT JOIN FETCH r.nguoiLap "
            + "ORDER BY r.ngayNhap DESC, r.id DESC")
    List<GoodsReceipt> findAllForAdmin();

    /** Số phiếu đã lập trong ngày — dùng để đánh số thứ tự trong mã phiếu PNyyMMdd-####. */
    @Query("SELECT COUNT(r) FROM GoodsReceipt r WHERE r.maPhieu LIKE CONCAT(:tienTo, '%')")
    long demTheoTienTo(@org.springframework.data.repository.query.Param("tienTo") String tienTo);
}
