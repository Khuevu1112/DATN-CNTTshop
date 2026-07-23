package com.fpoly.dto;

import java.math.BigDecimal;

public class StockMovementDtos {

    public record StockMovementRequest(
            Integer variantId,
            Integer changeQty,
            /** "nhap_hang" (luôn dương) hoặc "dieu_chinh" (có thể âm). */
            String reason,
            BigDecimal unitCost,
            String note
    ) {}

    public record StockMovementDto(
            Integer id,
            Integer variantId,
            String productName,
            String sku,
            Integer changeQty,
            String reason,
            BigDecimal unitCost,
            String note,
            String createdByName,
            String createdAt,
            Integer stockAfter
    ) {}

    /** Kết quả tìm sản phẩm/biến thể để chọn khi tạo phiếu nhập — kèm tồn kho hiện tại. */
    public record VariantPickResultDto(
            Integer variantId,
            String productName,
            String sku,
            Integer stock
    ) {}
}
