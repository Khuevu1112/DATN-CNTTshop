package com.fpoly.service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.CatalogDtos.CategoryDto;
import com.fpoly.dto.CatalogDtos.ImageDto;
import com.fpoly.dto.CatalogDtos.OptionDto;
import com.fpoly.dto.CatalogDtos.ProductDetailDto;
import com.fpoly.dto.CatalogDtos.ProductSummaryDto;
import com.fpoly.dto.CatalogDtos.SpecDto;
import com.fpoly.dto.CatalogDtos.VariantDto;
import com.fpoly.model.Category;
import com.fpoly.model.OptionValue;
import com.fpoly.model.Product;
import com.fpoly.model.ProductImage;
import com.fpoly.model.ProductOption;
import com.fpoly.model.ProductSpec;
import com.fpoly.model.ProductVariant;
import com.fpoly.repository.CategoryRepository;
import com.fpoly.repository.ProductRepository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

/**
 * Service phục vụ REST API catalog cho frontend Vue.
 * readOnly transaction để map lazy collections (images/specs/variants/options) an toàn.
 */
@Service
@Transactional(readOnly = true)
public class CatalogApiService {

    @Autowired
    private ProductRepository productRepo;

    @Autowired
    private CategoryRepository categoryRepo;

    @PersistenceContext
    private EntityManager em;

    public List<CategoryDto> getCategories() {
        return categoryRepo.findAllByOrderBySortOrderAsc().stream()
                .map(c -> new CategoryDto(
                        c.getId(), c.getName(), c.getSlug(),
                        c.getImageUrl(), c.getSortOrder()))
                .toList();
    }

    public List<ProductSummaryDto> getProducts(String categorySlug, String keyword, String sort) {
        boolean hasKeyword = keyword != null && !keyword.isBlank();
        List<Product> products;

        if (categorySlug != null && !categorySlug.isBlank()) {
            Category category = categoryRepo.findBySlug(categorySlug)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy danh mục"));
            products = hasKeyword
                    ? productRepo.findByCategoryAndNameContainingIgnoreCaseAndIsActiveTrue(category, keyword)
                    : productRepo.findByCategoryAndIsActiveTrue(category);
        } else {
            products = hasKeyword
                    ? productRepo.findByNameContainingIgnoreCaseAndIsActiveTrue(keyword)
                    : productRepo.findByIsActiveTrue();
        }

        sortProducts(products, sort);
        Map<Integer, double[]> ratingMap = loadRatingMap();
        return products.stream().map(p -> toSummary(p, ratingMap)).toList();
    }

    public ProductDetailDto getProductBySlug(String slug) {
        Product p = productRepo.findBySlug(slug)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));

        List<ImageDto> images = p.getImages() == null ? List.of()
                : p.getImages().stream()
                    .map(i -> new ImageDto(i.getUrl(), i.getIsPrimary()))
                    .toList();

        List<SpecDto> specs = p.getSpecs() == null ? List.of()
                : p.getSpecs().stream()
                    .map(s -> new SpecDto(s.getSpecKey(), s.getSpecValue()))
                    .toList();

        List<OptionDto> options = new ArrayList<>();
        if (p.getOptions() != null) {
            for (ProductOption o : p.getOptions()) {
                List<String> vals = new ArrayList<>();
                if (o.getValues() != null) {
                    for (OptionValue ov : o.getValues()) vals.add(ov.getValue());
                }
                options.add(new OptionDto(o.getOptionName(), vals));
            }
        }

        List<VariantDto> variants = new ArrayList<>();
        if (p.getVariants() != null) {
            for (ProductVariant v : p.getVariants()) {
                Map<String, String> opts = new LinkedHashMap<>();
                if (v.getOptionValues() != null) {
                    for (OptionValue ov : v.getOptionValues()) {
                        if (ov.getOption() != null) {
                            opts.put(ov.getOption().getOptionName(), ov.getValue());
                        }
                    }
                }
                variants.add(new VariantDto(
                        v.getId(), v.getSku(), v.getPrice(),
                        v.getOriginalPrice(), v.getStock(), v.getIsDefault(), opts));
            }
        }

        return new ProductDetailDto(
                p.getId(), p.getName(), p.getSlug(), p.getDescription(),
                p.getCategory() != null ? p.getCategory().getName() : null,
                p.getCategory() != null ? p.getCategory().getSlug() : null,
                images, specs, variants, options);
    }

    // ===== helpers =====

    /** Trả map: productId -> [điểm trung bình, số lượt đánh giá] từ bảng REVIEW. */
    private Map<Integer, double[]> loadRatingMap() {
        Map<Integer, double[]> map = new HashMap<>();
        try {
            List<?> rows = em.createNativeQuery(
                "SELECT product_id, AVG(CAST(rating AS FLOAT)), COUNT(*) FROM REVIEW GROUP BY product_id"
            ).getResultList();
            for (Object row : rows) {
                Object[] r = (Object[]) row;
                Integer pid = ((Number) r[0]).intValue();
                double avg = r[1] == null ? 0 : ((Number) r[1]).doubleValue();
                double cnt = r[2] == null ? 0 : ((Number) r[2]).doubleValue();
                map.put(pid, new double[]{ avg, cnt });
            }
        } catch (Exception ignored) {
            // bảng REVIEW có thể chưa có dữ liệu — bỏ qua, card sẽ không hiện rating
        }
        return map;
    }

    private ProductSummaryDto toSummary(Product p, Map<Integer, double[]> ratingMap) {
        ProductVariant v = pickVariant(p);

        // 3 thông số nổi bật làm chip
        List<String> chips = new ArrayList<>();
        if (p.getSpecs() != null) {
            p.getSpecs().stream()
                    .sorted(Comparator.comparing((ProductSpec s) -> s.getSortOrder() == null ? 0 : s.getSortOrder()))
                    .limit(3)
                    .forEach(s -> chips.add(s.getSpecValue()));
        }

        double[] r = ratingMap.get(p.getId());
        Double rating = (r != null) ? Math.round(r[0] * 10) / 10.0 : null;
        Integer reviewCount = (r != null) ? (int) r[1] : 0;

        return new ProductSummaryDto(
                p.getId(), p.getName(), p.getSlug(),
                p.getCategory() != null ? p.getCategory().getName() : null,
                p.getBrand() != null ? p.getBrand().getName() : null,
                pickImageUrl(p),
                v != null ? v.getPrice() : null,
                v != null ? v.getOriginalPrice() : null,
                chips, rating, reviewCount);
    }

    private String pickImageUrl(Product p) {
        if (p.getImages() == null || p.getImages().isEmpty()) return null;
        for (ProductImage img : p.getImages()) {
            if (Boolean.TRUE.equals(img.getIsPrimary())) return img.getUrl();
        }
        return p.getImages().get(0).getUrl();
    }

    private ProductVariant pickVariant(Product p) {
        if (p.getVariants() == null || p.getVariants().isEmpty()) return null;
        for (ProductVariant v : p.getVariants()) {
            if (Boolean.TRUE.equals(v.getIsDefault())) return v;
        }
        return p.getVariants().get(0);
    }

    private BigDecimal priceOf(Product p) {
        ProductVariant v = pickVariant(p);
        return (v != null && v.getPrice() != null) ? v.getPrice() : BigDecimal.ZERO;
    }

    private void sortProducts(List<Product> products, String sort) {
        if (sort == null) return;
        switch (sort) {
            case "name_asc"   -> products.sort(Comparator.comparing(Product::getName));
            case "name_desc"  -> products.sort(Comparator.comparing(Product::getName).reversed());
            case "price_asc"  -> products.sort(Comparator.comparing((Product p) -> priceOf(p)));
            case "price_desc" -> products.sort(Comparator.comparing((Product p) -> priceOf(p)).reversed());
            case "newest"     -> products.sort(Comparator.comparing(Product::getCreatedAt,
                                    Comparator.nullsLast(Comparator.naturalOrder())).reversed());
            default -> { }
        }
    }
}
