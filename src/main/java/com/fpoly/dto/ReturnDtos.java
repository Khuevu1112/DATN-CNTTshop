package com.fpoly.dto;

import java.time.LocalDateTime;
import java.util.List;

public class ReturnDtos {

    /** Một yêu cầu đổi trả. Trường minh chứng là URL /uploads/return/... (đã tải lên). */
    public record ReturnDto(
            Integer id, String maYeuCau,
            String maDon, String tenSanPham, String kenhMua, String lyDo, String noiDung,
            String videoLoi, String videoMoHang, List<String> anhLoi,
            String trangThai, String nhanTrangThai, String ghiChuCskh,
            String hoTen, String email, String dienThoai,
            LocalDateTime createdAt, LocalDateTime updatedAt
    ) {}

    public record DoiTrangThaiRequest(String trangThai, String ghiChu) {}
}
