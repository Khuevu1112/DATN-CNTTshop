package com.fpoly.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.KitTemplateItem;

public interface KitTemplateItemRepository extends JpaRepository<KitTemplateItem, Integer> {
}
