package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.Product;
import com.fpoly.model.Review;

public interface ReviewRepository extends JpaRepository<Review, Integer> {

    boolean existsByProductIdAndNguoiDungIdAndOrderId(Integer productId, Integer userId, Integer orderId);

    @Query("SELECT r FROM Review r JOIN FETCH r.nguoiDung WHERE r.product = :product ORDER BY r.createdAt DESC")
    List<Review> findByProductOrderByCreatedAtDesc(@Param("product") Product product);
}
