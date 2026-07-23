package com.fpoly.config;

import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import com.fpoly.security.PermissionDeniedException;

/**
 * Bắt RuntimeException ném ra từ các service ở tầng REST API (/api/**)
 * và trả về JSON {"message": "..."} thay vì lỗi 500 không có nội dung,
 * để admin-vue / cnttshop-vue hiển thị được thông báo lỗi tiếng Việt cụ thể.
 */
@RestControllerAdvice(basePackages = "com.fpoly.controller.api")
public class RestApiExceptionHandler {

    /** Cố tình KHÔNG dùng 403 — admin-vue/http.js coi mọi 403 là phiên hết hạn và tự logout,
     * trong khi đây chỉ là thiếu 1 quyền cụ thể (xem PermissionDeniedException). */
    @ExceptionHandler(PermissionDeniedException.class)
    public ResponseEntity<Map<String, Object>> handlePermissionDenied(PermissionDeniedException e) {
        return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(Map.of(
                "message", e.getMessage(),
                "code", "PERMISSION_DENIED",
                "feature", e.getFeature(),
                "action", e.getAction().toKey()));
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, String>> handleRuntimeException(RuntimeException e) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", e.getMessage()));
    }
}
