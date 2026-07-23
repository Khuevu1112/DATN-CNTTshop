package com.fpoly.dto;

import java.time.LocalDateTime;

/** DTO cho tính năng Liên hệ (trang User gửi, trang Admin quản lý). */
public class ContactDtos {

    /** Form gửi liên hệ từ trang User. */
    public record ContactSubmitRequest(
            String fullName,
            String email,
            String phone,
            String subject,
            String message
    ) {}

    public record ContactSummaryDto(
            Integer id,
            String fullName,
            String email,
            String phone,
            String subject,
            String status,
            LocalDateTime createdAt
    ) {}

    public record ContactDetailDto(
            Integer id,
            String fullName,
            String email,
            String phone,
            String subject,
            String message,
            String status,
            String adminReply,
            LocalDateTime repliedAt,
            LocalDateTime createdAt
    ) {}

    public record ContactReplyRequest(String reply) {}

    public record ContactStatusRequest(String status) {}
}
