package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.SubscriptionUsage;
import com.fpoly.model.UserSubscription;

public interface SubscriptionUsageRepository extends JpaRepository<SubscriptionUsage, Integer> {

    /** Số lượt ĐÃ tiêu (đã trừ phần hoàn) của 1 quyền lợi trên 1 gói = SUM(delta). Còn lại =
     * hạn mức gói - giá trị này (xem SubscriptionService.soLuotConLai). */
    @Query("select coalesce(sum(u.delta), 0) from SubscriptionUsage u "
            + "where u.subscription = :sub and u.benefitKey = :key")
    int daTieu(@Param("sub") UserSubscription sub, @Param("key") String benefitKey);

    List<SubscriptionUsage> findByOrderIdAndDeltaGreaterThan(Integer orderId, int delta);
    List<SubscriptionUsage> findByOrderIdAndDeltaLessThan(Integer orderId, int delta);
}
