package com.fpoly.service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.PermissionDtos.FeatureDto;
import com.fpoly.dto.PermissionDtos.MyPermissionsDto;
import com.fpoly.dto.PermissionDtos.PermissionMetaDto;
import com.fpoly.dto.PermissionDtos.PermissionTypeDto;
import com.fpoly.dto.PermissionDtos.RoleGrantDto;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.RolePermission;
import com.fpoly.model.enums.VaiTro;
import com.fpoly.repository.RolePermissionRepository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

/** Quản lý ma trận (phòng ban, trang) -> quyền cho trang Phân quyền — CRUD trên ROLE_PERMISSION;
 * FEATURE/PERMISSION_TYPE là bảng tra cứu cố định, chỉ đọc (không có endpoint thêm/xoá). */
@Service
public class PermissionAdminService {

    public static final List<String> DEPARTMENTS =
            List.of("ke_toan", "kho", "ky_thuat", "cskh", "giao_hang", "kinh_doanh");

    @PersistenceContext
    private EntityManager em;

    @Autowired
    private RolePermissionRepository rolePermissionRepo;

    public PermissionMetaDto getMeta() {
        List<Object[]> featureRows = em.createNativeQuery(
                "SELECT feature_key, label, group_label, sort_order FROM FEATURE ORDER BY sort_order ASC"
        ).getResultList();
        List<FeatureDto> features = new ArrayList<>();
        for (Object[] r : featureRows) {
            features.add(new FeatureDto((String) r[0], (String) r[1], (String) r[2], ((Number) r[3]).intValue()));
        }

        List<Object[]> permRows = em.createNativeQuery(
                "SELECT perm_key, label, color, sort_order FROM PERMISSION_TYPE ORDER BY sort_order ASC"
        ).getResultList();
        List<PermissionTypeDto> permissionTypes = new ArrayList<>();
        for (Object[] r : permRows) {
            permissionTypes.add(new PermissionTypeDto((String) r[0], (String) r[1], (String) r[2], ((Number) r[3]).intValue()));
        }

        return new PermissionMetaDto(features, permissionTypes, DEPARTMENTS);
    }

    public List<RoleGrantDto> getMatrix() {
        Map<String, List<String>> grouped = new LinkedHashMap<>();
        for (RolePermission rp : rolePermissionRepo.findAll()) {
            grouped.computeIfAbsent(rp.getDepartment() + "|" + rp.getFeatureKey(), k -> new ArrayList<>())
                    .add(rp.getPermKey());
        }
        List<RoleGrantDto> out = new ArrayList<>();
        for (Map.Entry<String, List<String>> e : grouped.entrySet()) {
            String[] parts = e.getKey().split("\\|", 2);
            out.add(new RoleGrantDto(parts[0], parts[1], e.getValue()));
        }
        return out;
    }

    @Transactional
    public RoleGrantDto updateCell(String department, String featureKey, List<String> permKeys) {
        if (!DEPARTMENTS.contains(department)) throw new RuntimeException("Phòng ban không hợp lệ");
        rolePermissionRepo.deleteByDepartmentAndFeatureKey(department, featureKey);
        List<String> cleaned = permKeys == null ? List.of() : permKeys.stream()
                .filter(p -> p != null && !p.isBlank() && !"none".equals(p))
                .distinct().toList();
        for (String permKey : cleaned) {
            RolePermission rp = new RolePermission();
            rp.setDepartment(department);
            rp.setFeatureKey(featureKey);
            rp.setPermKey(permKey);
            rolePermissionRepo.save(rp);
        }
        return new RoleGrantDto(department, featureKey, cleaned);
    }

    public MyPermissionsDto getMyPermissions(NguoiDung nguoiDung) {
        if (nguoiDung.getVaiTro() == VaiTro.admin) {
            return new MyPermissionsDto(true, Map.of());
        }
        Map<String, List<String>> grants = new LinkedHashMap<>();
        for (RolePermission rp : rolePermissionRepo.findAll()) {
            if (!rp.getDepartment().equals(nguoiDung.getVaiTro().name())) continue;
            grants.computeIfAbsent(rp.getFeatureKey(), k -> new ArrayList<>()).add(rp.getPermKey());
        }
        return new MyPermissionsDto(false, grants);
    }
}
