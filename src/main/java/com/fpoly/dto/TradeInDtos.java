package com.fpoly.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class TradeInDtos {

    /** Khách gửi yêu cầu — ảnh đi kèm dưới dạng multipart, không nằm trong record này. */
    public record TaoYeuCauRequest(
            String loaiThietBi, String hang, String model,
            String tinhTrangKhai, Integer namMua, String moTa, String serial
    ) {}

    public record LichSuDto(String trangThai, String ghiChu, String nguoiThucHien, LocalDateTime thoiGian) {}

    public record YeuCauDto(
            Integer id, String loaiThietBi, String hang, String model,
            String tinhTrangKhai, Integer namMua, String moTa, String serial,
            List<String> anh,
            BigDecimal giaTamTinh, BigDecimal giaChot,
            String trangThai, String nhanTrangThai, String ghiChuKtv,
            LocalDateTime createdAt, LocalDateTime updatedAt,
            // Chỉ có khi admin xem — khách không cần biết ai định giá máy mình.
            String tenKhach, String soDienThoaiKhach,
            List<LichSuDto> lichSu,
            Integer creditId, BigDecimal creditSoTien, String creditTrangThai
    ) {}

    /** Admin báo giá tạm tính (bước cho_dinh_gia -> da_bao_gia). */
    public record BaoGiaRequest(BigDecimal giaTamTinh, String ghiChu) {}

    /** Admin chốt giá sau khi kiểm máy thật (da_nhan_may -> da_kiem_tra). */
    public record ChotGiaRequest(BigDecimal giaChot, String ghiChu) {}

    /** Dùng chung cho các bước chỉ đổi trạng thái kèm ghi chú. */
    public record DoiTrangThaiRequest(String ghiChu) {}

    /** Tín dụng khách đang có — hiện ở trang cá nhân và ở bước thanh toán. */
    public record CreditDto(
            Integer id, BigDecimal soTien, BigDecimal donToiThieu,
            LocalDateTime hetHan, String trangThai,
            String moTaThietBi, Integer donDaDung, boolean dungDuoc
    ) {}
}
