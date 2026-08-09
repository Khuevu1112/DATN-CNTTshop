package com.fpoly.dto;

import java.time.LocalDateTime;

public class ChatDtos {

    /** Client gửi lên khi lưu 1 tin nhắn (user hoặc bot). */
    public record ChatMessageRequest(
            String role,      // "user" | "bot"
            String content,
            String metadata   // JSON string tuỳ chọn, ví dụ danh sách sản phẩm gợi ý kèm theo
    ) {}

    /** Trả về cho client khi load lịch sử hoặc sau khi lưu. */
    public record ChatMessageResponse(
            Integer id,
            String role,
            String content,
            String metadata,
            LocalDateTime createdAt
    ) {}
}
