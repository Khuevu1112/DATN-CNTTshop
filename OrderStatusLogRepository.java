package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.Order;
import com.fpoly.model.OrderStatusLog;

public interface OrderStatusLogRepository extends JpaRepository<OrderStatusLog, Integer> {

    List<OrderStatusLog> findByOrderOrderByThoiGianAsc(Order order);
}