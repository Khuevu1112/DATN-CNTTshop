package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.dto.WarrantyDtos.CreateRequestBody;
import com.fpoly.dto.WarrantyDtos.WarrantyDetailDto;
import com.fpoly.dto.WarrantyDtos.WarrantyHistoryDto;
import com.fpoly.dto.WarrantyDtos.WarrantyRequestDto;
import com.fpoly.dto.WarrantyDtos.WarrantySummaryDto;
import com.fpoly.model.Warranty;
import com.fpoly.model.WarrantyRequest;
import com.fpoly.service.WarrantyService;

/** REST API bảo hành phía khách hàng — yêu cầu đăng nhập (xem JWT trong SecurityConfig). */
@RestController
@RequestMapping("/api/warranty")
public class WarrantyApiController {

    @Autowired
    private WarrantyService warrantyService;

    @GetMapping
    public List<WarrantySummaryDto> myWarranties(Authentication auth) {
        return warrantyService.getWarrantyOfUser(auth.getName()).stream()
                .map(this::toSummary)
                .toList();
    }

    @GetMapping("/{id}")
    public WarrantyDetailDto detail(@PathVariable Integer id, Authentication auth) {
        Warranty w = warrantyService.getById(id);
        if (!w.getNguoiDung().getEmail().equals(auth.getName())) {
            throw new RuntimeException("Bạn không có quyền xem phiếu bảo hành này");
        }
        return toDetail(w);
    }

    @PostMapping("/{id}/requests")
    public WarrantyDetailDto createRequest(
            @PathVariable Integer id, @RequestBody CreateRequestBody body, Authentication auth) {
        warrantyService.createRequest(id, auth.getName(), body.issue(),
                body.ngayHen(), body.hinhThuc(), body.centerId());
        return toDetail(warrantyService.getById(id));
    }

    private WarrantySummaryDto toSummary(Warranty w) {
        return new WarrantySummaryDto(
                w.getId(),
                w.getMaBaoHanh(),
                w.getOrderItem().getTenSanPham(),
                w.getSerialNumber(),
                w.getStartDate(),
                w.getEndDate(),
                w.getStatus(),
                w.getNguoiDung().getHoTen(),
                w.getNguoiDung().getEmail());
    }

    private WarrantyDetailDto toDetail(Warranty w) {
        List<WarrantyRequestDto> requests = warrantyService.getRequests(w.getId()).stream()
                .map(this::toRequestDto)
                .toList();
        return new WarrantyDetailDto(
                w.getId(),
                w.getMaBaoHanh(),
                w.getOrderItem().getTenSanPham(),
                w.getOrderItem().getOrder().getMaDonHang(),
                w.getSerialNumber(),
                w.getStartDate(),
                w.getEndDate(),
                w.getStatus(),
                w.getNguoiDung().getHoTen(),
                w.getNguoiDung().getEmail(),
                requests);
    }

    private WarrantyRequestDto toRequestDto(WarrantyRequest r) {
        List<WarrantyHistoryDto> history = warrantyService.getHistory(r).stream()
                .map(h -> new WarrantyHistoryDto(h.getStatus(), h.getNote(), h.getCreatedAt()))
                .toList();
        return new WarrantyRequestDto(
                r.getId(), r.getIssueDescription(), r.getRequestStatus(), r.getCreatedAt(),
                r.getNgayHen(), r.getHinhThuc(),
                r.getCenter() != null ? r.getCenter().getId() : null,
                r.getCenter() != null ? r.getCenter().getTen() : null,
                r.getPhuPhi(),
                r.getWarranty().getId(), r.getWarranty().getMaBaoHanh(),
                r.getWarranty().getOrderItem().getTenSanPham(),
                r.getWarranty().getNguoiDung().getHoTen(), r.getWarranty().getNguoiDung().getEmail(),
                history);
    }
}
