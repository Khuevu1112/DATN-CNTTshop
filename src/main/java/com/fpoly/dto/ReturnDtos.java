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
            LocalDateTime createdAt, LocalDateTime updatedAt,
            Integer soLuong, Boolean daHoanKho, Boolean taoBoiAdmin
    ) {}

    public record DoiTrangThaiRequest(String trangThai, String ghiChu) {}

    /** CSKH tự khởi tạo yêu cầu hộ khách — xem ReturnRequestService.taoYeuCauBoiAdmin. */
    public record TaoYeuCauAdminRequest(
            String maDon, Integer orderItemId, String lyDo, String noiDung, Integer soLuong) {}

    /** Kết quả tra cứu đơn để CSKH chọn dòng sản phẩm cần đổi/trả. */
    public record DonChoDoiTraDto(
            String maDon, String hoTen, String email, String dienThoai,
            String trangThai, List<DongSanPhamDto> sanPham) {}

    public record DongSanPhamDto(
            Integer orderItemId, String tenSanPham, String sku, Integer soLuong) {}
}
