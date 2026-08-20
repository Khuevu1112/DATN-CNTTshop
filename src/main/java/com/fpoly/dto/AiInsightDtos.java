package com.fpoly.dto;

import java.util.List;

/** DTO cho tính năng "Cảnh báo hệ thống" (trước gọi là "AI Phân tích") ở admin-vue. */
public class AiInsightDtos {

    /** 1 cảnh báo bất thường do quy tắc số liệu phát hiện (không dùng AI). */
    public record AiAlertDto(
            String severity, // "warning" | "danger"
            String title,
            String message
    ) {}

    public record AiAlertsDto(List<AiAlertDto> alerts, String generatedAt) {}
}
