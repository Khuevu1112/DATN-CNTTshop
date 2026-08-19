package com.fpoly.service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

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
import com.fpoly.model.ProductPromotion;
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

    /**
     * Danh sách sản phẩm, lọc theo danh mục và/hoặc từ khoá.
     *
     * Từ khoá KHÔNG còn dùng LIKE '%cả cụm%' trên riêng cột tên như trước. Cách cũ trượt gần
     * như mọi truy vấn thật:
     *   - "asus gaming" không khớp "Laptop Gaming ASUS TUF..." vì hai từ không đứng liền nhau;
     *   - "man hinh" không khớp "Màn hình ..." vì đối chiếu nguyên dấu;
     *   - "bh laptop" / "mh 27 inch" không khớp gì vì viết tắt không được giãn.
     * Nay lọc trong bộ nhớ theo TỪ (bỏ dấu + giãn viết tắt, xem SearchTextUtils) trên tên +
     * hãng + danh mục + SKU biến thể, đòi khớp đủ mọi từ nhưng không cần đúng thứ tự. Catalog
     * của shop chỉ vài trăm dòng nên lọc trong bộ nhớ rẻ hơn nhiều so với việc dựng chỉ mục
     * full-text chỉ để phục vụ một ô tìm kiếm.
     */
    public List<ProductSummaryDto> getProducts(String categorySlug, String keyword, String sort) {
        List<String> tuKhoa = (keyword == null || keyword.isBlank())
                ? List.of() : SearchTextUtils.tachTu(keyword);
        List<Product> products;

        if (categorySlug != null && !categorySlug.isBlank()) {
            Category category = categoryRepo.findBySlug(categorySlug)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy danh mục"));
            products = productRepo.findByCategoryAndIsActiveTrue(category);
        } else {
            products = productRepo.findByIsActiveTrue();
        }

        if (!tuKhoa.isEmpty()) {
            products = products.stream()
                    .filter(p -> SearchTextUtils.khopMoiTu(chuoiTimKiem(p), tuKhoa))
                    .collect(Collectors.toCollection(ArrayList::new));
        }

        Map<Integer, double[]> ratingMap = loadRatingMap();
        Map<Integer, Integer> salesMap = loadSalesMap();
        sortProducts(products, sort, salesMap);
        // Không có yêu cầu sắp xếp cụ thể + đang tìm kiếm -> đưa sản phẩm khớp ngay trong TÊN
        // lên trước (khớp nhờ danh mục/SKU là liên quan yếu hơn), rồi mới tới thứ tự mặc định.
        if (!tuKhoa.isEmpty() && (sort == null || sort.isBlank())) {
            products.sort(Comparator.comparingInt(
                    (Product p) -> -SearchTextUtils.demTuKhop(p.getName(), tuKhoa)));
        }
        return products.stream().map(p -> toSummary(p, ratingMap, salesMap)).toList();
    }

    /** Toàn bộ phần chữ của 1 sản phẩm có thể dùng để tìm: tên + hãng + danh mục + SKU biến thể. */
    private String chuoiTimKiem(Product p) {
        StringBuilder sb = new StringBuilder(p.getName() == null ? "" : p.getName());
        if (p.getBrand() != null) sb.append(' ').append(p.getBrand().getName());
        if (p.getCategory() != null) sb.append(' ').append(p.getCategory().getName());
        if (p.getVariants() != null) {
            for (var v : p.getVariants()) {
                if (v.getSku() != null) sb.append(' ').append(v.getSku());
            }
        }
        return sb.toString();
    }

    /** Top sản phẩm bán chạy nhất (theo tổng số lượng đã bán, đơn không huỷ). */
    public List<ProductSummaryDto> getBestSellers(int limit) {
        Map<Integer, Integer> salesMap = loadSalesMap();
        Map<Integer, double[]> ratingMap = loadRatingMap();

        return productRepo.findByIsActiveTrue().stream()
                .filter(p -> salesMap.getOrDefault(p.getId(), 0) > 0)
                .sorted(Comparator.comparing((Product p) -> salesMap.getOrDefault(p.getId(), 0)).reversed())
                .limit(limit)
                .map(p -> toSummary(p, ratingMap, salesMap))
                .toList();
    }

    /** Map danh sách Product (đã có sẵn) sang ProductSummaryDto — dùng cho tính năng so sánh sản phẩm. */
    public List<ProductSummaryDto> toSummaries(List<Product> products) {
        Map<Integer, double[]> ratingMap = loadRatingMap();
        Map<Integer, Integer> salesMap = loadSalesMap();
        return products.stream().map(p -> toSummary(p, ratingMap, salesMap)).toList();
    }

    public ProductDetailDto getProductBySlug(String slug) {
        Product p = productRepo.findBySlug(slug)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));

        List<ImageDto> images = p.getImages() == null ? List.of()
                : p.getImages().stream()
                    .map(i -> new ImageDto(i.getUrl(), i.getIsPrimary()))
                    .toList();

        List<SpecDto> specs = fullSpecs(p);

        List<OptionDto> options = new ArrayList<>();
        if (p.getOptions() != null) {
            for (ProductOption o : p.getOptions()) {
                List<String> vals = new ArrayList<>();
                if (o.getValues() != null) {
                    for (OptionValue ov : o.getValues()) vals.add(ov.getValue());
                }
                options.add(new OptionDto(o.getOptionName(), vals, o.getLinkedGroup()));
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

        List<String> promotions = fullPromotions(p);

        Map<Integer, double[]> ratingMap = loadRatingMap();
        Map<Integer, Integer> salesMap = loadSalesMap();
        List<ProductSummaryDto> bundles = p.getBundles() == null ? List.of()
                : p.getBundles().stream()
                    .map(b -> toSummary(b.getBundleProduct(), ratingMap, salesMap))
                    .toList();

        return new ProductDetailDto(
                p.getId(), p.getName(), p.getSlug(), p.getDescription(),
                p.getCategory() != null ? p.getCategory().getName() : null,
                p.getCategory() != null ? p.getCategory().getSlug() : null,
                images, specs, variants, options, promotions, bundles,
                p.getWarrantyMonths());
    }

    // ===== helpers =====

    /** Toàn bộ thông số của sản phẩm, theo đúng thứ tự sort_order — dùng chung cho cả trang
     * chi tiết (specs) và trang danh sách (chips rút gọn + lọc theo cấu hình). */
    private List<SpecDto> fullSpecs(Product p) {
        if (p.getSpecs() == null) return List.of();
        return p.getSpecs().stream()
                .sorted(Comparator.comparing((ProductSpec s) -> s.getSortOrder() == null ? 0 : s.getSortOrder()))
                .map(s -> new SpecDto(s.getSpecKey(), s.getSpecValue()))
                .toList();
    }

    private List<String> fullPromotions(Product p) {
        if (p.getPromotions() == null) return List.of();
        return p.getPromotions().stream()
                .sorted(Comparator.comparing((ProductPromotion pr) -> pr.getSortOrder() == null ? 0 : pr.getSortOrder()))
                .map(ProductPromotion::getContent)
                .toList();
    }

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

    /** Trả map: productId -> tổng số lượng đã bán (loại đơn 'cancelled'). */
    private Map<Integer, Integer> loadSalesMap() {
        Map<Integer, Integer> map = new HashMap<>();
        List<?> rows = em.createNativeQuery(
            "SELECT v.product_id, SUM(oi.quantity) " +
            "FROM ORDER_ITEM oi " +
            "JOIN PRODUCT_VARIANT v ON oi.variant_id = v.id " +
            "JOIN [ORDER] o ON oi.order_id = o.id " +
            "WHERE o.status != 'cancelled' " +
            "GROUP BY v.product_id"
        ).getResultList();
        for (Object row : rows) {
            Object[] r = (Object[]) row;
            Integer pid = ((Number) r[0]).intValue();
            int qty = r[1] == null ? 0 : ((Number) r[1]).intValue();
            map.put(pid, qty);
        }
        return map;
    }

    private ProductSummaryDto toSummary(Product p, Map<Integer, double[]> ratingMap, Map<Integer, Integer> salesMap) {
        ProductVariant v = pickVariant(p);

        List<SpecDto> specs = fullSpecs(p);
        // 3 thông số nổi bật làm chip trên card
        List<String> chips = specs.stream().limit(3).map(SpecDto::value).toList();

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
                chips, rating, reviewCount,
                salesMap.getOrDefault(p.getId(), 0),
                tonKhoTatCaBienThe(p),
                specs, fullPromotions(p), p.getWarrantyMonths());
    }

    /**
     * Tồn kho của sản phẩm trên thẻ/danh sách = TỔNG mọi biến thể, không phải tồn của riêng
     * biến thể mặc định như trước. Chỉ lấy biến thể mặc định thì một sản phẩm còn đầy hàng ở
     * các phiên bản khác vẫn bị đánh dấu hết hàng (và ngược lại) — sai cả nhãn "Tạm hết hàng"
     * lẫn bộ lọc "Chỉ hàng còn". Tồn của TỪNG biến thể vẫn trả riêng trong VariantDto để trang
     * chi tiết khoá đúng phiên bản khách đang chọn.
     */
    private int tonKhoTatCaBienThe(Product p) {
        if (p.getVariants() == null) return 0;
        int tong = 0;
        for (ProductVariant v : p.getVariants()) {
            if (v.getStock() != null) tong += v.getStock();
        }
        return tong;
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

    private void sortProducts(List<Product> products, String sort, Map<Integer, Integer> salesMap) {
        if (sort == null) return;
        switch (sort) {
            case "name_asc"    -> products.sort(Comparator.comparing(Product::getName));
            case "name_desc"   -> products.sort(Comparator.comparing(Product::getName).reversed());
            case "price_asc"   -> products.sort(Comparator.comparing((Product p) -> priceOf(p)));
            case "price_desc"  -> products.sort(Comparator.comparing((Product p) -> priceOf(p)).reversed());
            case "newest"      -> products.sort(Comparator.comparing(Product::getCreatedAt,
                                     Comparator.nullsLast(Comparator.naturalOrder())).reversed());
            case "bestseller"  -> products.sort(Comparator.comparing(
                                     (Product p) -> salesMap.getOrDefault(p.getId(), 0)).reversed());
            default -> { }
        }
    }
}
