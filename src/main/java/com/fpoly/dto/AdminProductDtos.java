package com.fpoly.dto;

import java.math.BigDecimal;
import java.util.List;

/**
 * DTO cho REST API quản trị sản phẩm (tạo/sửa/xem chi tiết trong admin-vue).
 * Tách khỏi CatalogDtos (DTO công khai) vì admin cần thêm id để cập nhật,
 * cờ ẩn/hiện, và cấu trúc đầy đủ option/value/variant để dựng lại form.
 */
public class AdminProductDtos {

    public record ImageRequest(
            Integer id,
            String url,
            Boolean isPrimary,
            Integer sortOrder
    ) {}

    public record SpecRequest(
            Integer id,
            String specKey,
            String specValue,
            Integer sortOrder
    ) {}

    public record PromotionRequest(
            Integer id,
            String content,
            Integer sortOrder
    ) {}

    /**
     * Một giá trị tuỳ chọn, ví dụ "Cấu hình: i7/16GB".
     * clientKey do Vue sinh ra (vd "0-1") để VariantRequest tham chiếu tới,
     * vì giá trị mới chưa có id thật khi gửi lên cùng lúc với sản phẩm mới.
     */
    public record OptionValueRequest(
            Integer id,
            String clientKey,
            String value,
            BigDecimal priceExtra,
            Boolean isDefault,
            Boolean active,
            Integer sortOrder
    ) {}

    public record OptionRequest(
            Integer id,
            String optionName,
            String selectionType,
            Integer minSelect,
            Integer maxSelect,
            String description,
            Boolean required,
            Boolean visible,
            Integer sortOrder,
            /** NULL = nhóm độc lập; các nhóm cùng giá trị (trong cùng sản phẩm) bị khoá cặp
             * với nhau — chỉ những tổ hợp admin nhập tay mới hợp lệ giữa các nhóm đó. */
            String linkedGroup,
            List<OptionValueRequest> values
    ) {}

    public record VariantRequest(
            Integer id,
            String sku,
            BigDecimal price,
            BigDecimal originalPrice,
            Integer stock,
            Boolean isDefault,
            /** clientKey của các OptionValueRequest tạo nên biến thể này. */
            List<String> optionValueKeys
    ) {}

    public record ProductSaveRequest(
            String name,
            String slug,
            String description,
            Integer categoryId,
            Integer brandId,
            Boolean isActive,
            Integer warrantyMonths,
            List<ImageRequest> images,
            List<SpecRequest> specs,
            List<PromotionRequest> promotions,
            List<OptionRequest> options,
            List<VariantRequest> variants,
            List<Integer> bundleProductIds
    ) {}

    /** Payload cho tính năng "Sinh biến thể": trạng thái options + variants hiện có trên form
     * (kể cả sản phẩm chưa lưu), trả về danh sách biến thể mới cần bổ sung. */
    public record GenerateVariantsRequest(
            List<OptionRequest> options,
            List<VariantRequest> variants
    ) {}

    public record AdminProductDetailDto(
            Integer id,
            String name,
            String slug,
            String description,
            Integer categoryId,
            Integer brandId,
            Boolean isActive,
            Integer warrantyMonths,
            List<ImageRequest> images,
            List<SpecRequest> specs,
            List<PromotionRequest> promotions,
            List<OptionRequest> options,
            List<VariantRequest> variants,
            List<Integer> bundleProductIds
    ) {}
}
