package com.fpoly.security;

import com.fpoly.model.enums.PermissionType;

/** Ném ra khi phòng ban của người dùng không có quyền cần thiết cho 1 endpoint. Cố tình KHÔNG
 * kế thừa Spring Security AccessDeniedException (sẽ tự bị trả về 403) — 403 hiện đang bị
 * admin-vue/src/api/http.js coi là phiên hết hạn và tự logout, trong khi đây chỉ là thiếu 1
 * quyền cụ thể, không phải mất phiên đăng nhập. Xem RestApiExceptionHandler: exception này được
 * trả về HTTP 422 kèm code PERMISSION_DENIED để phía FE phân biệt được 2 trường hợp. */
public class PermissionDeniedException extends RuntimeException {
    private final String feature;
    private final PermissionType action;

    public PermissionDeniedException(String feature, PermissionType action) {
        super("Bạn không có quyền thực hiện thao tác này");
        this.feature = feature;
        this.action = action;
    }

    public String getFeature() { return feature; }
    public PermissionType getAction() { return action; }
}
