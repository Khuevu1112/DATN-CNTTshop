package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.GoodsReceiptItem;

public interface GoodsReceiptItemRepository extends JpaRepository<GoodsReceiptItem, Integer> {

    List<GoodsReceiptItem> findByReceiptId(Integer receiptId);
}
