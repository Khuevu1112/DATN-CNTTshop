package com.fpoly.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public class WarrantyDtos {

    public record WarrantySummaryDto(
            Integer id,
            String productName,
            String serialNumber,
            LocalDate startDate,
            LocalDate endDate,
            String status,
            String customerName,
            String customerEmail
    ) {}

    public record WarrantyHistoryDto(String status, String note, LocalDateTime createdAt) {}

    public record WarrantyRequestDto(
            Integer id,
            String issueDescription,
            String requestStatus,
            LocalDateTime createdAt,
            Integer warrantyId,
            String productName,
            String customerName,
            String customerEmail,
            List<WarrantyHistoryDto> history
    ) {}

    public record WarrantyDetailDto(
            Integer id,
            String productName,
            String orderCode,
            String serialNumber,
            LocalDate startDate,
            LocalDate endDate,
            String status,
            String customerName,
            String customerEmail,
            List<WarrantyRequestDto> requests
    ) {}

    public record CreateRequestBody(String issue) {}
    public record UpdateWarrantyStatusBody(String status) {}
    public record UpdateRequestStatusBody(String status, String note) {}
}
