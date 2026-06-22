package com.fpoly.dto;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * DTO trả về cho REST API (Vue tiêu thụ).
 * Tách khỏi entity để tránh lộ quan hệ 2 chiều / lazy-loading khi serialize JSON.
 */
public class CatalogDtos {

    public record CategoryDto(
            Integer id,
            String name,
            String slug,
            String imageUrl,
            Integer sortOrder
    ) {}

    public record ImageDto(
            String url,
            Boolean isPrimary
    ) {}

    public record SpecDto(
            String key,
            String value
    ) {}

    /** Một thuộc tính tuỳ chọn của sản phẩm, ví dụ "Cấu hình" -> [i5/16GB, i7/32GB]. */
    public record OptionDto(
            String name,
            List<String> values
    ) {}

    public record VariantDto(
            Integer id,
            String sku,
            BigDecimal price,
            BigDecimal originalPrice,
            Integer stock,
            Boolean isDefault,
            /** map tên-option -> giá-trị, để Vue khớp tổ hợp đã chọn với variant. */
            Map<String, String> options
    ) {}

    /** Dùng cho thẻ sản phẩm ở trang chủ / danh sách. */
    public record ProductSummaryDto(
            Integer id,
            String name,
            String slug,
            String categoryName,
            String imageUrl,
            BigDecimal price,
            BigDecimal originalPrice
    ) {}

    /** Dùng cho trang chi tiết sản phẩm. */
    public record ProductDetailDto(
            Integer id,
            String name,
            String slug,
            String description,
            String categoryName,
            String categorySlug,
            List<ImageDto> images,
            List<SpecDto> specs,
            List<VariantDto> variants,
            List<OptionDto> options
    ) {}
}
