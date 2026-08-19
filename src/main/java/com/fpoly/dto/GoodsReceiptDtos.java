package com.fpoly.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/** DTO cho nghiệp vụ NHẬP KHO (nhà cung cấp + phiếu nhập nhiều dòng). */
public class GoodsReceiptDtos {

    public record SupplierDto(
            Integer id, String ten, String maSoThue, String dienThoai, String email,
            String diaChi, String nguoiLienHe, String ghiChu, Boolean hienThi
    ) {}

    public record LuuSupplierRequest(
            String ten, String maSoThue, String dienThoai, String email,
            String diaChi, String nguoiLienHe, String ghiChu, Boolean hienThi
    ) {}

    /** Một dòng hàng khi LẬP phiếu. donGia = giá vốn nhập vào, không phải giá bán. */
    public record DongNhapRequest(Integer variantId, Integer soLuong, BigDecimal donGia, String ghiChu) {}

    /**
     * Lập phiếu nhập kho. vatPercent để 0 nếu hàng không có hoá đơn GTGT.
     * soHoaDon/ngayHoaDon để trống khi nhà cung cấp chưa xuất hoá đơn — vẫn nhập kho được,
     * kế toán bổ sung sau bằng cách sửa phiếu.
     */
    public record LuuPhieuNhapRequest(
            Integer supplierId, String soHoaDon, LocalDate ngayHoaDon,
            BigDecimal vatPercent, String ghiChu,
            List<DongNhapRequest> dongHang
    ) {}

    public record DongNhapDto(
            Integer id, Integer variantId, String tenSanPham, String sku,
            Integer soLuong, BigDecimal donGia, BigDecimal thanhTien, String ghiChu,
            /** Tồn kho của biến thể NGAY SAU khi dòng này được nhập — đọc từ sổ kho. */
            Integer tonSauNhap
    ) {}

    /** Dùng cho cả danh sách (chiTiet = null) lẫn xem chi tiết một phiếu. */
    public record PhieuNhapDto(
            Integer id, String maPhieu,
            Integer supplierId, String tenNhaCungCap, String maSoThueNcc,
            String dienThoaiNcc, String diaChiNcc,
            String soHoaDon, LocalDate ngayHoaDon, LocalDateTime ngayNhap,
            BigDecimal vatPercent, BigDecimal tienHang, BigDecimal tienVat, BigDecimal tongTien,
            String ghiChu, String nguoiLap,
            int soDongHang, int tongSoLuong,
            List<DongNhapDto> chiTiet
    ) {}
}
