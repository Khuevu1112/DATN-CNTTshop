package com.fpoly.dto;

import java.util.List;
import java.util.Map;

public class PermissionDtos {

    public record FeatureDto(String key, String label, String groupLabel, Integer sortOrder) {}

    public record PermissionTypeDto(String key, String label, String color, Integer sortOrder) {}

    public record PermissionMetaDto(
            List<FeatureDto> features,
            List<PermissionTypeDto> permissionTypes,
            List<String> departments
    ) {}

    /** 1 ô trong ma trận: 1 phòng ban x 1 trang -> tập quyền được cấp. */
    public record RoleGrantDto(String department, String featureKey, List<String> permKeys) {}

    public record UpdateCellRequest(List<String> permKeys) {}

    /** Quyền của chính người đang đăng nhập — admin bỏ qua bảng, luôn isAdmin=true. */
    public record MyPermissionsDto(boolean isAdmin, Map<String, List<String>> grants) {}
}
