package com.fpoly.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public class WarrantyDtos {

    public record WarrantySummaryDto(
            Integer id,
            String maBaoHanh,
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
            LocalDate ngayHen,
            String hinhThuc,
            Integer centerId,
            String centerName,
            BigDecimal phuPhi,
            Integer warrantyId,
            String maBaoHanh,
            String productName,
            String customerName,
            String customerEmail,
            List<WarrantyHistoryDto> history
    ) {}

    public record WarrantyDetailDto(
            Integer id,
            String maBaoHanh,
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

    /** Body gửi yêu cầu bảo hành từ trang "Quản lý bảo hành cá nhân".
     * hinhThuc: tan_noi | cua_hang; centerId chỉ dùng khi cua_hang; ngayHen = ngày khách hẹn. */
    public record CreateRequestBody(String issue, LocalDate ngayHen, String hinhThuc, Integer centerId) {}
    public record UpdateWarrantyStatusBody(String status) {}
    public record UpdateRequestStatusBody(String status, String note) {}

    /** Admin chỉ được đổi lại NGÀY HẸN khi khách gọi điện xin đổi lịch. Hình thức (mang ra cửa
     * hàng/sửa tận nơi) và cửa hàng nào là lựa chọn của khách khi gửi yêu cầu — admin không có
     * quyền tự đổi thay khách. */
    public record UpdateRequestAppointmentBody(LocalDate ngayHen) {}
}
