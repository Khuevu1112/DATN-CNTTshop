package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.fpoly.model.KitTemplate;

public interface KitTemplateRepository extends JpaRepository<KitTemplate, Integer> {

    List<KitTemplate> findAllByOrderByIdDesc();

    @Query("SELECT DISTINCT k FROM KitTemplate k LEFT JOIN FETCH k.items i LEFT JOIN FETCH i.productVariant v LEFT JOIN FETCH v.product WHERE k.id = :id")
    Optional<KitTemplate> findByIdWithItems(Integer id);
}
