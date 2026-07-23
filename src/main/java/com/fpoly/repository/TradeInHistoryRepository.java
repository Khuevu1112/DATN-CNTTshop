package com.fpoly.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.TradeInHistory;

public interface TradeInHistoryRepository extends JpaRepository<TradeInHistory, Integer> {
}
