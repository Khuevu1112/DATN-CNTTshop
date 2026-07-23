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

    /** Một thuộc tính tuỳ chọn của sản phẩm, ví dụ "Cấu hình" -> [i5/16GB, i7/32GB].
     * linkedGroup: NULL = tự do phối; các nhóm cùng giá trị bị khoá cặp — chọn 1 giá trị ở nhóm
     * này sẽ lọc nhóm kia chỉ còn giá trị nào từng xuất hiện cùng trong 1 biến thể thật. */
    public record OptionDto(
            String name,
            List<String> values,
            String linkedGroup
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
            String brandName,
            String imageUrl,
            BigDecimal price,
            BigDecimal originalPrice,
            /** 3 thông số nổi bật hiển thị dạng chip trên card. */
            List<String> chips,
            /** điểm đánh giá trung bình (null nếu chưa có đánh giá). */
            Double rating,
            Integer reviewCount,
            /** tổng số lượng đã bán (đơn không bị huỷ) — dùng cho mục Best Seller. */
            Integer soldCount,
            /** tồn kho của biến thể mặc định — dùng cho lọc "Còn hàng". */
            Integer stock,
            /** Toàn bộ thông số (không giới hạn 3 như chips) — dùng để lọc theo cấu hình
             * (CPU/case/mainboard/tản nhiệt...) và hiển thị trong tháp xem trước khi hover. */
            List<SpecDto> specs,
            /** Các dòng khuyến mãi đi kèm — dùng cho tháp xem trước khi hover. */
            List<String> promotions,
            Integer warrantyMonths
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
            List<OptionDto> options,
            /** Các dòng khuyến mãi đi kèm, ví dụ "Tặng chuột không dây". */
            List<String> promotions,
            /** Sản phẩm gợi ý mua kèm. */
            List<ProductSummaryDto> bundles,
            Integer warrantyMonths
    ) {}

    /** Một dòng trong bảng so sánh sản phẩm: tên thông số + giá trị của từng sản phẩm theo thứ tự. */
    public record CompareRowDto(String specKey, List<String> values) {}
}
