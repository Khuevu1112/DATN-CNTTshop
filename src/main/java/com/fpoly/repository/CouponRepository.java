package com.fpoly.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.Coupon;

public interface CouponRepository extends JpaRepository<Coupon, Integer> {
    boolean existsByMa(String ma);

    Optional<Coupon> findByMa(String ma);

    // Coupon do admin bật đổi bằng xu (xu_cost khác null), còn hạn dùng và chưa hết lượt —
    // nguồn cho catalog "Đổi mã giảm giá" ở trang khuyến mãi (xem RedemptionService.layDanhMuc).
    @Query("SELECT c FROM Coupon c WHERE c.giaXu IS NOT NULL AND c.isActive = true " +
           "AND (c.hetHanLuc IS NULL OR c.hetHanLuc > :now) " +
           "AND (c.soLuotToiDa IS NULL OR c.soLuotDaDung < c.soLuotToiDa) " +
           "ORDER BY c.giaXu ASC")
    List<Coupon> timCouponDoiDuocBangXu(@Param("now") LocalDateTime now);
}
