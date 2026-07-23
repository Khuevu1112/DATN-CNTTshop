package com.fpoly.model.enums;

/** 8 loại quyền cố định (không cho thêm/xoá qua UI — khớp bảng PERMISSION_TYPE).
 * FULL luôn thoả mãn mọi action được yêu cầu; LIMITED không tự động thoả mãn VIEW/EDIT —
 * đó là 1 hành vi riêng được code xử lý cụ thể theo từng trang (xem PermissionAspect). */
public enum PermissionType {
    FULL, VIEW, ADD, EDIT, DELETE, PERFORM, LIMITED, NONE;

    public String toKey() {
        return name().toLowerCase();
    }
}
