package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.Wallet;
import com.fpoly.model.WalletTransaction;

public interface WalletTransactionRepository extends JpaRepository<WalletTransaction, Integer> {
    List<WalletTransaction> findByWalletOrderByCreatedAtDesc(Wallet wallet);

    /** Tổng xu đã KIẾM được từ trước tới nay (mua hàng + điểm danh) — dùng để xét bậc thành
     * viên (xem MembershipService), khác với silver_balance là số dư còn lại sau khi tiêu.
     * Chỉ lấy loai_giao_dich = 'earn' nên hoàn xu ('adjust') không bị tính thành tích luỹ ảo. */
    @Query("select coalesce(sum(t.soLuong), 0) from WalletTransaction t "
            + "where t.wallet = :wallet and t.loaiGiaoDich = 'earn'")
    int tongXuDaKiem(@Param("wallet") Wallet wallet);
}
