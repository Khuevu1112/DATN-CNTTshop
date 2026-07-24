package com.fpoly.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class InstallmentDtos {

    public record PlanDto(Integer id, Integer soThang, BigDecimal laiSuat) {}

    /** Bảng tính thử — khách xem trước khi đăng ký, không lưu gì. */
    public record TinhToanDto(
            Integer soThang, BigDecimal laiSuat,
            BigDecimal giaBan, BigDecimal traTruoc,
            BigDecimal soTienVay, BigDecimal tongLai,
            BigDecimal traHangThang, BigDecimal tongPhaiTra
    ) {}

    /** Khách gửi đăng ký. giaBan KHÔNG nhận từ client — backend tự lấy giá thật của biến thể,
     * nếu không khách sửa được số tiền vay (xem InstallmentService.dangKy). */
    public record DangKyRequest(
            Integer productId, Integer variantId, Integer soLuong,
            Integer soThang, BigDecimal traTruoc,
            String tenKhach, String soDienThoai, String email, String diaChi, String soCccd
    ) {}

    /** Bản khách xem: KHÔNG có số CCCD. */
    public record DonCuaToiDto(
            Integer id, String tenSanPham, Integer soLuong,
            Integer soThang, BigDecimal laiSuat,
            BigDecimal giaBan, BigDecimal traTruoc, BigDecimal traHangThang, BigDecimal tongPhaiTra,
            String trangThai, String nhanTrangThai, String ghiChuNhanVien, LocalDateTime createdAt
    ) {}

    /** Bản nhân viên xem: có đủ hồ sơ để thẩm định, gồm cả CCCD. */
    public record DonAdminDto(
            Integer id, Integer productId, Integer variantId,
            String tenSanPham, String tuyChon, Integer soLuong,
            Integer soThang, BigDecimal laiSuat,
            BigDecimal giaBan, BigDecimal traTruoc, BigDecimal soTienVay,
            BigDecimal tongLai, BigDecimal traHangThang, BigDecimal tongPhaiTra,
            String tenKhach, String soDienThoai, String email, String diaChi, String soCccd,
            boolean laKhachDaDangKy,
            String trangThai, String nhanTrangThai, String ghiChuNhanVien,
            LocalDateTime createdAt, LocalDateTime updatedAt
    ) {}

    public record DuyetRequest(String ghiChu) {}

    public record CauHinhDto(List<PlanDto> kyHan, BigDecimal tyLeTraTruocToiThieu) {}
}
