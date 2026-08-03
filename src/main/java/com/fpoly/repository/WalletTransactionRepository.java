package com.fpoly.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.Wallet;
import com.fpoly.model.WalletTransaction;

public interface WalletTransactionRepository extends JpaRepository<WalletTransaction, Integer> {
    List<WalletTransaction> findByWalletOrderByCreatedAtDesc(Wallet wallet);

    /** Các lượt đổi coupon có mã sắp hết hạn (trong khoảng [now, soon]) mà chưa gửi nhắc. JOIN
     * FETCH coupon + ví + người dùng để job gửi nhắc không phải nạp lười từng bản ghi. */
    @Query("select t from WalletTransaction t "
            + "join fetch t.couponLienQuan c join fetch t.wallet w join fetch w.nguoiDung "
            + "where t.loaiGiaoDich = 'redeem' and t.couponReminderSent = false "
            + "and c.hetHanLuc is not null and c.hetHanLuc between :now and :soon")
    List<WalletTransaction> findCouponRemindersDue(@Param("now") LocalDateTime now,
                                                   @Param("soon") LocalDateTime soon);

    /** Tổng xu đã KIẾM được từ trước tới nay (mua hàng + điểm danh) — dùng để xét bậc thành
     * viên (xem MembershipService), khác với silver_balance là số dư còn lại sau khi tiêu.
     * Chỉ lấy loai_giao_dich = 'earn' nên hoàn xu ('adjust') không bị tính thành tích luỹ ảo. */
    @Query("select coalesce(sum(t.soLuong), 0) from WalletTransaction t "
            + "where t.wallet = :wallet and t.loaiGiaoDich = 'earn'")
    int tongXuDaKiem(@Param("wallet") Wallet wallet);
}
