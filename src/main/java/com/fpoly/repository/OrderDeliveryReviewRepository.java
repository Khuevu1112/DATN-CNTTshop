package com.fpoly.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.OrderDeliveryReview;

public interface OrderDeliveryReviewRepository extends JpaRepository<OrderDeliveryReview, Integer> {

    boolean existsByOrderId(Integer orderId);
}
