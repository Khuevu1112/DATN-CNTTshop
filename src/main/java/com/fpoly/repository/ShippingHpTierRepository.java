package com.fpoly.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.ShippingHpTier;

public interface ShippingHpTierRepository extends JpaRepository<ShippingHpTier, Integer> {
    Optional<ShippingHpTier> findByTierKey(String tierKey);
}
