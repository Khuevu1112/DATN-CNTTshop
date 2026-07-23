package com.fpoly.security;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import com.fpoly.model.enums.PermissionType;

/** Gắn lên method controller trong /api/admin/** để khai báo trang (feature) + hành động cần
 * kiểm tra quyền. PermissionAspect sẽ chặn trước khi vào method nếu người dùng không có quyền
 * "full" hoặc đúng "action" cho (phòng ban, feature) đó — admin luôn được bỏ qua kiểm tra. */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface RequirePermission {
    String feature();
    PermissionType action();
}
