package com.fpoly.repository;

import java.util.List;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.StockMovement;

public interface StockMovementRepository extends JpaRepository<StockMovement, Integer> {

    @Query("SELECT sm FROM StockMovement sm JOIN FETCH sm.variant v JOIN FETCH v.product " +
           "WHERE v.id = :variantId ORDER BY sm.createdAt DESC")
    List<StockMovement> findByVariantId(@Param("variantId") Integer variantId);

    @Query("SELECT sm FROM StockMovement sm JOIN FETCH sm.variant v JOIN FETCH v.product " +
           "ORDER BY sm.createdAt DESC")
    List<StockMovement> findRecent(Pageable pageable);
}
