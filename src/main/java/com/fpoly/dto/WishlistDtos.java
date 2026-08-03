package com.fpoly.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class WishlistDtos {

    /** Một dòng trong trang "Danh sách yêu thích" — kiểu Steam wishlist: STT (do FE tự đánh số
     * theo thứ tự mảng), tên sản phẩm, giá, tồn kho, thao tác (thêm giỏ / bỏ yêu thích). */
    public record WishlistItemDto(
            Integer id, Integer productId, String slug, String tenSanPham, String anh,
            BigDecimal gia, BigDecimal giaGoc, Integer tonKho, Integer variantId,
            LocalDateTime createdAt
    ) {}

    /** Kết quả bấm trái tim — FE dùng để đổi trạng thái nút mà không cần tải lại danh sách. */
    public record ToggleResultDto(boolean daYeuThich) {}
}
