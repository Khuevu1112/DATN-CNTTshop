package com.fpoly.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class PcBuildDtos {

    public record ComponentTypeDto(String key, String label, String icon) {}

    public record PcBuildItemDto(
            String componentType,
            String componentLabel,
            String icon,
            Integer variantId,
            Integer productId,
            String productSlug,
            String productName,
            String sku,
            BigDecimal price,
            String imageUrl,
            Integer quantity
    ) {}

    public record PcBuildSummaryDto(
            Integer id, String name, String note, LocalDateTime createdAt,
            BigDecimal totalPrice, Integer itemCount
    ) {}

    public record PcBuildDetailDto(
            Integer id, String name, String note, LocalDateTime createdAt,
            BigDecimal totalPrice, List<PcBuildItemDto> items, List<String> warnings
    ) {}

    public record ProductBrowseItemDto(
            Integer productId, String slug, String name, String imageUrl,
            Integer variantId, BigDecimal price, BigDecimal originalPrice, Integer stock
    ) {}

    public record ProductBrowsePageDto(
            List<ProductBrowseItemDto> items, int page, int totalPages, long totalElements
    ) {}

    public record AddItemRequest(Integer variantId, String componentType) {}
    public record SaveBuildRequest(String name, String note) {}
}
