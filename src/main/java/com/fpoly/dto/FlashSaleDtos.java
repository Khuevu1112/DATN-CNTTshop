package com.fpoly.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class FlashSaleDtos {

    /** 1 sản phẩm trong đợt sale, đã ghép dữ liệu sống của sản phẩm (tên/ảnh/giá gốc) để client
     * không phải gọi thêm API nào. */
    public record FlashSaleItemDto(
            Integer variantId, Integer productId, String productSlug, String productName,
            String imageUrl, String sku,
            BigDecimal giaGoc, BigDecimal giaSale, Integer phanTramGiam,
            Integer stock, Integer thuTu
    ) {}

    /** Bản khách hàng nhìn thấy. Chỉ trả về khi đợt sale đang thực sự chạy (bật + trong khung
     * giờ + đã public), ngoài ra trả null để client tự ẩn banner. */
    public record FlashSaleCongKhaiDto(
            Integer id, String tieuDe, String moTa,
            String mauBatDau, String mauKetThuc,
            LocalDateTime batDauLuc, LocalDateTime ketThucLuc,
            List<FlashSaleItemDto> sanPham
    ) {}

    /** Bản admin sửa (bản nháp) — kèm cờ cho biết còn thay đổi chưa đăng hay không. */
    public record FlashSaleAdminDto(
            Integer id, String tieuDe, String moTa,
            String mauBatDau, String mauKetThuc,
            LocalDateTime batDauLuc, LocalDateTime ketThucLuc,
            Boolean isActive,
            Boolean dangChay, Boolean coThayDoiChuaPublic,
            LocalDateTime publicLuc, LocalDateTime updatedAt,
            List<FlashSaleItemDto> sanPham
    ) {}

    public record LuuFlashSaleItemRequest(Integer variantId, BigDecimal giaSale) {}

    /** Dùng cho cả tạo mới lẫn sửa — sanPham null nghĩa là không đụng tới danh sách sản phẩm. */
    public record LuuFlashSaleRequest(
            String tieuDe, String moTa,
            String mauBatDau, String mauKetThuc,
            LocalDateTime batDauLuc, LocalDateTime ketThucLuc,
            Boolean isActive,
            List<LuuFlashSaleItemRequest> sanPham
    ) {}
}
