package com.fpoly.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class KitTemplateDtos {

    /** Item đã resolve sẵn tên/giá hiển thị — frontend dùng trực tiếp, không cần tính lại. */
    public record KitTemplateItemDto(
            Integer id,
            String componentType,
            String source, // "stock" | "external"
            Integer variantId,
            String productName,
            String sku,
            String manualName,
            String displayName,
            BigDecimal price,
            Integer sortOrder
    ) {}

    public record KitTemplateSummaryDto(
            Integer id, String name, String description, LocalDateTime createdAt,
            Integer itemCount, BigDecimal totalSuggestedPrice, List<String> componentTypes
    ) {}

    public record KitTemplateDetailDto(
            Integer id, String name, String description, LocalDateTime createdAt,
            List<KitTemplateItemDto> items, BigDecimal totalSuggestedPrice
    ) {}

    public record SaveKitTemplateItemRequest(
            String componentType, String source, Integer variantId,
            String manualName, BigDecimal extraPrice, Integer sortOrder
    ) {}

    public record SaveKitTemplateRequest(
            String name, String description, List<SaveKitTemplateItemRequest> items
    ) {}

    /** Dùng cho ô tìm sản phẩm "trong kho" khi thêm linh kiện vào mẫu. */
    public record VariantSearchResultDto(Integer variantId, String productName, String sku, BigDecimal price) {}
}
