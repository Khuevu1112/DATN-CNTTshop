package com.fpoly.repository;

import java.util.Collection;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.RolePermission;

public interface RolePermissionRepository extends JpaRepository<RolePermission, Integer> {

    boolean existsByDepartmentAndFeatureKeyAndPermKeyIn(
            String department, String featureKey, Collection<String> permKeys);

    boolean existsByDepartmentAndFeatureKey(String department, String featureKey);

    List<RolePermission> findAll();

    List<RolePermission> findByDepartmentAndFeatureKey(String department, String featureKey);

    void deleteByDepartmentAndFeatureKey(String department, String featureKey);
}
