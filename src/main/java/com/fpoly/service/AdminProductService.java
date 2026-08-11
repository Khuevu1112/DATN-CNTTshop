package com.fpoly.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.text.Normalizer;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.fpoly.dto.AdminProductDtos.AdminProductDetailDto;
import com.fpoly.dto.AdminProductDtos.ImageRequest;
import com.fpoly.dto.AdminProductDtos.OptionRequest;
import com.fpoly.dto.AdminProductDtos.OptionValueRequest;
import com.fpoly.dto.AdminProductDtos.ProductSaveRequest;
import com.fpoly.dto.AdminProductDtos.PromotionRequest;
import com.fpoly.dto.AdminProductDtos.SpecRequest;
import com.fpoly.dto.AdminProductDtos.VariantRequest;
import com.fpoly.model.Brand;
import com.fpoly.model.Category;
import com.fpoly.model.OptionValue;
import com.fpoly.model.Product;
import com.fpoly.model.ProductBundle;
import com.fpoly.model.ProductImage;
import com.fpoly.model.ProductOption;
import com.fpoly.model.ProductPromotion;
import com.fpoly.model.ProductSpec;
import com.fpoly.model.ProductVariant;
import com.fpoly.repository.BrandRepository;
import com.fpoly.repository.CategoryRepository;
import com.fpoly.repository.OptionValueRepository;
import com.fpoly.repository.ProductBundleRepository;
import com.fpoly.repository.ProductImageRepository;
import com.fpoly.repository.ProductOptionRepository;
import com.fpoly.repository.ProductPromotionRepository;
import com.fpoly.repository.ProductRepository;
import com.fpoly.repository.ProductSpecRepository;
import com.fpoly.repository.ProductVariantRepository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

/**
 * Service tạo/sửa/xoá sản phẩm cho admin-vue (REST API), kèm biến thể, ảnh,
 * thông số kỹ thuật, khuyến mãi, tuỳ chọn (option/giá trị) và sản phẩm mua kèm.
 * Tách khỏi {@link ProductService} (dùng cho admin Thymeleaf cũ) để không ảnh hưởng luồng đang chạy.
 */
@Service
public class AdminProductService {

    @Autowired private ProductRepository productRepo;
    @Autowired private CategoryRepository categoryRepo;
    @Autowired private BrandRepository brandRepo;
    @Autowired private ProductVariantRepository variantRepo;
    @Autowired private ProductImageRepository imageRepo;
    @Autowired private ProductSpecRepository specRepo;
    @Autowired private ProductOptionRepository optionRepo;
    @Autowired private OptionValueRepository optionValueRepo;
    @Autowired private ProductPromotionRepository promotionRepo;
    @Autowired private ProductBundleRepository bundleRepo;
    @Autowired private WishlistService wishlistService;

    @PersistenceContext
    private EntityManager em;

    @Transactional
    public Product create(ProductSaveRequest req) {
        if (req.variants() == null || req.variants().isEmpty()) {
            throw new RuntimeException("Sản phẩm cần có ít nhất 1 biến thể (giá / kho hàng)");
        }
        Product product = new Product();
        applyBasicFields(product, req, null);
        product = productRepo.save(product);

        saveImages(product, req.images());
        saveSpecs(product, req.specs());
        savePromotions(product, req.promotions());
        saveBundles(product, req.bundleProductIds());
        Map<String, OptionValue> valueByKey = saveOptions(product, req.options());
        saveVariants(product, req.variants(), valueByKey, List.of());

        return product;
    }

    @Transactional
    public Product update(Integer id, ProductSaveRequest req) {
        if (req.variants() == null || req.variants().isEmpty()) {
            throw new RuntimeException("Sản phẩm cần có ít nhất 1 biến thể (giá / kho hàng)");
        }
        Product product = productRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));
        applyBasicFields(product, req, id);
        product = productRepo.save(product);

        List<ProductVariant> existingVariants = new ArrayList<>(variantRepo.findByProductId(id));

        // Giá đại diện (thấp nhất trong các biến thể) TRƯỚC khi sửa — khách yêu thích cả SẢN
        // PHẨM chứ không phải một biến thể cụ thể, nên so sánh theo giá thấp nhất, giống cách
        // card sản phẩm hiển thị giá. Dùng để báo giảm giá cho wishlist sau khi lưu xong.
        java.math.BigDecimal giaThapNhatTruoc = existingVariants.stream()
                .map(ProductVariant::getPrice)
                .filter(java.util.Objects::nonNull)
                .min(java.math.BigDecimal::compareTo)
                .orElse(null);
        // Gỡ liên kết option-value cũ trước để có thể xoá OPTION_VALUE an toàn.
        for (ProductVariant v : existingVariants) {
            v.setOptionValues(new ArrayList<>());
            variantRepo.save(v);
        }

        imageRepo.deleteByProductId(id);
        specRepo.deleteByProductId(id);
        promotionRepo.deleteByProductId(id);
        bundleRepo.deleteByProductId(id);
        for (ProductOption opt : optionRepo.findByProductId(id)) {
            optionValueRepo.deleteByOptionId(opt.getId());
        }
        optionRepo.deleteByProductId(id);

        saveImages(product, req.images());
        saveSpecs(product, req.specs());
        savePromotions(product, req.promotions());
        saveBundles(product, req.bundleProductIds());
        Map<String, OptionValue> valueByKey = saveOptions(product, req.options());
        saveVariants(product, req.variants(), valueByKey, existingVariants);

        if (giaThapNhatTruoc != null) {
            java.math.BigDecimal giaThapNhatSau = variantRepo.findByProductId(id).stream()
                    .map(ProductVariant::getPrice)
                    .filter(java.util.Objects::nonNull)
                    .min(java.math.BigDecimal::compareTo)
                    .orElse(null);
            if (giaThapNhatSau != null) {
                int cmp = giaThapNhatSau.compareTo(giaThapNhatTruoc);
                if (cmp < 0) {
                    wishlistService.baoGiamGia(product, giaThapNhatTruoc, giaThapNhatSau);
                } else if (cmp > 0) {
                    // Giá tăng lại -> mở khoá để lần giảm tiếp theo vẫn báo được cho khách.
                    wishlistService.moKhoaNhacGiamGia(product);
                }
            }
        }

        return product;
    }

    /**
     * Xoá sản phẩm. Nếu sản phẩm đã có đơn hàng (qua biến thể), không thể xoá cứng
     * vì sẽ vi phạm khoá ngoại / mất lịch sử đơn hàng — chuyển sang ẩn sản phẩm (soft delete).
     * @return true nếu xoá hẳn khỏi DB, false nếu chỉ ẩn đi.
     */
    @Transactional
    public boolean delete(Integer id) {
        Product product = productRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));

        long orderCount = ((Number) em.createNativeQuery(
                "SELECT COUNT(*) FROM ORDER_ITEM oi JOIN PRODUCT_VARIANT v ON oi.variant_id = v.id " +
                "WHERE v.product_id = :id"
        ).setParameter("id", id).getSingleResult()).longValue();

        if (orderCount > 0) {
            product.setIsActive(false);
            productRepo.save(product);
            return false;
        }

        List<ProductVariant> variants = variantRepo.findByProductId(id);
        for (ProductVariant v : variants) {
            v.setOptionValues(new ArrayList<>());
        }
        variantRepo.saveAll(variants);

        imageRepo.deleteByProductId(id);
        specRepo.deleteByProductId(id);
        promotionRepo.deleteByProductId(id);
        bundleRepo.deleteByProductId(id);
        em.createQuery("DELETE FROM ProductBundle b WHERE b.bundleProduct.id = :id")
                .setParameter("id", id).executeUpdate();
        for (ProductOption opt : optionRepo.findByProductId(id)) {
            optionValueRepo.deleteByOptionId(opt.getId());
        }
        optionRepo.deleteByProductId(id);
        variantRepo.deleteAll(variants);
        productRepo.deleteById(id);
        return true;
    }

    @Transactional(readOnly = true)
    public AdminProductDetailDto getDetail(Integer id) {
        Product p = productRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));

        List<ImageRequest> images = p.getImages() == null ? List.of() : p.getImages().stream()
                .map(i -> new ImageRequest(i.getId(), i.getUrl(), i.getIsPrimary(), i.getSortOrder()))
                .toList();

        List<SpecRequest> specs = p.getSpecs() == null ? List.of() : p.getSpecs().stream()
                .map(s -> new SpecRequest(s.getId(), s.getSpecKey(), s.getSpecValue(), s.getSortOrder()))
                .toList();

        List<PromotionRequest> promotions = p.getPromotions() == null ? List.of() : p.getPromotions().stream()
                .map(pr -> new PromotionRequest(pr.getId(), pr.getContent(), pr.getSortOrder()))
                .toList();

        List<OptionRequest> options = p.getOptions() == null ? List.of() : p.getOptions().stream()
                .map(o -> new OptionRequest(
                        o.getId(), o.getOptionName(), o.getSelectionType(), o.getMinSelect(), o.getMaxSelect(),
                        o.getDescription(), o.getRequired(), o.getVisible(), o.getSortOrder(), o.getLinkedGroup(),
                        o.getValues() == null ? List.of() : o.getValues().stream()
                                .map(v -> new OptionValueRequest(
                                        v.getId(), "v" + v.getId(), v.getValue(), v.getPriceExtra(),
                                        v.getIsDefault(), v.getActive(), v.getSortOrder()))
                                .toList()))
                .toList();

        List<VariantRequest> variants = p.getVariants() == null ? List.of() : p.getVariants().stream()
                .map(v -> new VariantRequest(
                        v.getId(), v.getSku(), v.getPrice(), v.getOriginalPrice(), v.getStock(), v.getIsDefault(),
                        v.getOptionValues() == null ? List.of() : v.getOptionValues().stream()
                                .map(ov -> "v" + ov.getId()).toList()))
                .toList();

        List<Integer> bundleIds = bundleRepo.findByProductId(id).stream()
                .map(b -> b.getBundleProduct().getId())
                .toList();

        return new AdminProductDetailDto(
                p.getId(), p.getName(), p.getSlug(), p.getDescription(),
                p.getCategory() != null ? p.getCategory().getId() : null,
                p.getBrand() != null ? p.getBrand().getId() : null,
                p.getIsActive(), p.getWarrantyMonths(), images, specs, promotions, options, variants, bundleIds);
    }

    /**
     * "Sinh biến thể": tính tổ hợp còn thiếu giữa các nhóm tuỳ chọn, dựa trên options + variants
     * hiện có trên form (thuần tính toán, không đụng DB — dùng được cho cả sản phẩm mới chưa lưu).
     * Nhóm độc lập (linkedGroup == null): mỗi giá trị là 1 "trục" tự do phối với mọi trục khác.
     * Nhóm bị khoá cặp (cùng linkedGroup): KHÔNG tự bịa tổ hợp — trục của cả nhóm chỉ gồm đúng những
     * tổ hợp admin đã nhập tay trong variants hiện có; nếu chưa có tổ hợp nào thì nhóm đó chưa đóng
     * góp trục nào cả (admin phải tự thêm ít nhất 1 dòng biến thể cho nhóm bị khoá trước).
     * Chỉ tính các giá trị đang active (is_active = true) — giá trị đã bị tắt không được dùng để
     * sinh tổ hợp mới, tránh sinh biến thể cho lựa chọn admin không còn muốn bán.
     * Trả về danh sách biến thể MỚI (chưa tồn tại trong variants hiện có) để form tự thêm vào; các
     * dòng đã có được giữ nguyên, không đụng tới.
     */
    public List<VariantRequest> generateVariantSkeletons(List<OptionRequest> options, List<VariantRequest> existingVariants) {
        if (options == null) options = List.of();
        if (existingVariants == null) existingVariants = List.of();

        List<List<Set<String>>> axes = new ArrayList<>();

        Map<String, List<OptionRequest>> byLinkedGroup = new java.util.LinkedHashMap<>();
        for (OptionRequest opt : options) {
            if (opt.values() == null || opt.values().isEmpty()) continue;
            if (opt.linkedGroup() == null || opt.linkedGroup().isBlank()) {
                List<Set<String>> axisValues = new ArrayList<>();
                for (OptionValueRequest v : opt.values()) {
                    // Bỏ qua giá trị đã bị tắt (active = false) — không sinh tổ hợp mới cho lựa
                    // chọn admin không còn muốn bán, tránh nhầm lẫn.
                    if (v.active() != null && !v.active()) continue;
                    if (v.clientKey() != null) axisValues.add(Set.of(v.clientKey()));
                }
                if (!axisValues.isEmpty()) axes.add(axisValues);
            } else {
                byLinkedGroup.computeIfAbsent(opt.linkedGroup(), k -> new ArrayList<>()).add(opt);
            }
        }

        for (List<OptionRequest> group : byLinkedGroup.values()) {
            Set<String> groupKeys = new HashSet<>();
            for (OptionRequest o : group) {
                for (OptionValueRequest v : o.values()) {
                    if (v.active() != null && !v.active()) continue;
                    if (v.clientKey() != null) groupKeys.add(v.clientKey());
                }
            }
            java.util.LinkedHashSet<Set<String>> combos = new java.util.LinkedHashSet<>();
            for (VariantRequest v : existingVariants) {
                if (v.optionValueKeys() == null) continue;
                Set<String> combo = new HashSet<>(v.optionValueKeys());
                combo.retainAll(groupKeys);
                if (!combo.isEmpty()) combos.add(combo);
            }
            if (!combos.isEmpty()) axes.add(new ArrayList<>(combos));
        }

        if (axes.isEmpty()) return List.of();

        List<Set<String>> combos = new ArrayList<>();
        combos.add(Set.of());
        for (List<Set<String>> axisValues : axes) {
            List<Set<String>> next = new ArrayList<>();
            for (Set<String> prefix : combos) {
                for (Set<String> axisValue : axisValues) {
                    Set<String> merged = new HashSet<>(prefix);
                    merged.addAll(axisValue);
                    next.add(merged);
                }
            }
            combos = next;
        }

        Set<Set<String>> existingCombos = new HashSet<>();
        for (VariantRequest v : existingVariants) {
            if (v.optionValueKeys() != null) existingCombos.add(new HashSet<>(v.optionValueKeys()));
        }

        List<VariantRequest> result = new ArrayList<>();
        for (Set<String> combo : combos) {
            if (existingCombos.contains(combo)) continue;
            result.add(new VariantRequest(null, "", null, null, 0, false, new ArrayList<>(combo)));
        }
        return result;
    }

    // ===== helpers =====

    private void applyBasicFields(Product product, ProductSaveRequest req, Integer selfId) {
        if (req.name() == null || req.name().isBlank()) {
            throw new RuntimeException("Tên sản phẩm không được để trống");
        }
        if (req.categoryId() == null) {
            throw new RuntimeException("Bạn chưa chọn danh mục sản phẩm");
        }

        Category category = categoryRepo.findById(req.categoryId())
                .orElseThrow(() -> new RuntimeException("Danh mục không tồn tại"));

        String slug = normalizeSlug(
                (req.slug() == null || req.slug().isBlank()) ? req.name() : req.slug());
        productRepo.findBySlug(slug).ifPresent(existing -> {
            if (selfId == null || !existing.getId().equals(selfId)) {
                throw new RuntimeException("Slug \"" + slug + "\" đã được dùng cho sản phẩm khác");
            }
        });

        product.setName(req.name().trim());
        product.setSlug(slug);
        product.setDescription(req.description());
        product.setCategory(category);
        product.setIsActive(req.isActive() == null || req.isActive());
        product.setWarrantyMonths(req.warrantyMonths() != null ? req.warrantyMonths() : 36);
        if (product.getCreatedAt() == null) {
            product.setCreatedAt(LocalDateTime.now());
        }

        if (req.brandId() != null) {
            Brand brand = brandRepo.findById(req.brandId())
                    .orElseThrow(() -> new RuntimeException("Thương hiệu không tồn tại"));
            product.setBrand(brand);
        } else {
            product.setBrand(null);
        }
    }

    private void saveImages(Product product, List<ImageRequest> images) {
        if (images == null) return;
        // Đảm bảo luôn có đúng 1 ảnh đại diện: nếu form gửi lên không có ảnh nào isPrimary=true
        // (vd admin quên tick, hoặc mất cờ khi thêm/xoá ảnh phía client), ép ảnh đầu tiên làm đại diện
        // thay vì để trống — trang chi tiết/card sản phẩm phía USER luôn cần 1 ảnh để hiển thị.
        boolean hasPrimary = images.stream().anyMatch(r -> Boolean.TRUE.equals(r.isPrimary()));
        int i = 0;
        for (ImageRequest req : images) {
            ProductImage img = new ProductImage();
            img.setProduct(product);
            img.setUrl(req.url());
            img.setIsPrimary(!hasPrimary && i == 0 ? Boolean.TRUE : Boolean.TRUE.equals(req.isPrimary()));
            img.setSortOrder(req.sortOrder() != null ? req.sortOrder() : i);
            imageRepo.save(img);
            i++;
        }
    }

    private void saveSpecs(Product product, List<SpecRequest> specs) {
        if (specs == null) return;
        int i = 0;
        for (SpecRequest req : specs) {
            if (req.specKey() == null || req.specKey().isBlank()) continue;
            ProductSpec spec = new ProductSpec();
            spec.setProduct(product);
            spec.setSpecKey(req.specKey());
            spec.setSpecValue(req.specValue());
            spec.setSortOrder(req.sortOrder() != null ? req.sortOrder() : i);
            specRepo.save(spec);
            i++;
        }
    }

    private void savePromotions(Product product, List<PromotionRequest> promotions) {
        if (promotions == null) return;
        int i = 0;
        for (PromotionRequest req : promotions) {
            if (req.content() == null || req.content().isBlank()) continue;
            ProductPromotion promo = new ProductPromotion();
            promo.setProduct(product);
            promo.setContent(req.content());
            promo.setSortOrder(req.sortOrder() != null ? req.sortOrder() : i);
            promotionRepo.save(promo);
            i++;
        }
    }

    private void saveBundles(Product product, List<Integer> bundleProductIds) {
        if (bundleProductIds == null) return;
        for (Integer bundleId : bundleProductIds) {
            if (bundleId == null || bundleId.equals(product.getId())) continue;
            Product bundleProduct = productRepo.findById(bundleId).orElse(null);
            if (bundleProduct == null) continue;
            ProductBundle bundle = new ProductBundle();
            bundle.setProduct(product);
            bundle.setBundleProduct(bundleProduct);
            bundleRepo.save(bundle);
        }
    }

    /** Lưu các nhóm option + giá trị, trả về map clientKey -> OptionValue đã lưu để gắn vào variant. */
    private Map<String, OptionValue> saveOptions(Product product, List<OptionRequest> options) {
        Map<String, OptionValue> valueByKey = new HashMap<>();
        if (options == null) return valueByKey;

        int groupIndex = 0;
        for (OptionRequest req : options) {
            if (req.optionName() == null || req.optionName().isBlank()) {
                groupIndex++;
                continue;
            }
            ProductOption option = new ProductOption();
            option.setProduct(product);
            option.setOptionName(req.optionName());
            option.setSelectionType(req.selectionType() != null ? req.selectionType() : "single");
            option.setMinSelect(req.minSelect() != null ? req.minSelect() : 0);
            option.setMaxSelect(req.maxSelect() != null ? req.maxSelect() : 1);
            option.setDescription(req.description());
            option.setRequired(Boolean.TRUE.equals(req.required()));
            option.setVisible(req.visible() == null || req.visible());
            option.setSortOrder(req.sortOrder() != null ? req.sortOrder() : groupIndex);
            option.setLinkedGroup(req.linkedGroup());
            option = optionRepo.save(option);

            if (req.values() != null) {
                int valueIndex = 0;
                for (OptionValueRequest vr : req.values()) {
                    if (vr.value() == null || vr.value().isBlank()) {
                        valueIndex++;
                        continue;
                    }
                    OptionValue value = new OptionValue();
                    value.setOption(option);
                    value.setValue(vr.value());
                    value.setPriceExtra(vr.priceExtra() != null ? vr.priceExtra() : java.math.BigDecimal.ZERO);
                    value.setIsDefault(Boolean.TRUE.equals(vr.isDefault()));
                    value.setActive(vr.active() == null || vr.active());
                    value.setSortOrder(vr.sortOrder() != null ? vr.sortOrder() : valueIndex);
                    value = optionValueRepo.save(value);

                    if (vr.clientKey() != null) {
                        valueByKey.put(vr.clientKey(), value);
                    }
                    valueIndex++;
                }
            }
            groupIndex++;
        }
        return valueByKey;
    }

    private void saveVariants(
            Product product,
            List<VariantRequest> variants,
            Map<String, OptionValue> valueByKey,
            List<ProductVariant> existingVariants
    ) {
        if (variants == null) variants = List.of();

        // ── Validate trước khi đụng DB: phát hiện sớm dữ liệu bẩn từ client ──────────

        // 1) Trùng tổ hợp option-value giữa các biến thể: 2 dòng cùng chọn đúng 1 tập
        //    option-value sẽ khiến khách hàng/hệ thống không biết map về variant nào.
        Set<Set<String>> seenCombos = new HashSet<>();
        for (VariantRequest req : variants) {
            Set<String> combo = req.optionValueKeys() == null
                    ? Set.of()
                    : new HashSet<>(req.optionValueKeys());
            if (!combo.isEmpty() && !seenCombos.add(combo)) {
                throw new RuntimeException(
                        "Có 2 biến thể trùng tổ hợp thuộc tính, vui lòng kiểm tra lại (SKU: \""
                                + (req.sku() == null ? "" : req.sku()) + "\")");
            }
        }

        // 2) Giá / tồn kho hợp lệ.
        for (VariantRequest req : variants) {
            if (req.price() == null || req.price().signum() < 0) {
                throw new RuntimeException(
                        "Giá biến thể \"" + (req.sku() == null ? "" : req.sku()) + "\" không hợp lệ");
            }
            if (req.stock() != null && req.stock() < 0) {
                throw new RuntimeException(
                        "Tồn kho biến thể \"" + (req.sku() == null ? "" : req.sku()) + "\" không được âm");
            }
        }

        Set<Integer> keptIds = new HashSet<>();
        List<ProductVariant> savedVariants = new ArrayList<>();
        int i = 0;
        for (VariantRequest req : variants) {
            ProductVariant variant = null;
            if (req.id() != null) {
                variant = existingVariants.stream()
                        .filter(v -> v.getId().equals(req.id()))
                        .findFirst().orElse(null);
            }
            if (variant == null) {
                variant = new ProductVariant();
                variant.setProduct(product);
            } else {
                keptIds.add(variant.getId());
            }

            variant.setSku((req.sku() == null || req.sku().isBlank())
                    ? "SKU-" + product.getId() + "-" + (i + 1) : req.sku());
            variant.setPrice(req.price());
            variant.setOriginalPrice(req.originalPrice());
            variant.setStock(req.stock() != null ? req.stock() : 0);
            variant.setIsDefault(Boolean.TRUE.equals(req.isDefault()));

            // 3) Ánh xạ clientKey -> OptionValue: nếu số lượng resolve được KHÔNG khớp số
            //    lượng key gửi lên nghĩa là có clientKey không hợp lệ (lệch dữ liệu với
            //    saveOptions ở trên) — chặn lại thay vì âm thầm lưu thiếu thuộc tính.
            List<OptionValue> resolved = new ArrayList<>();
            if (req.optionValueKeys() != null) {
                for (String key : req.optionValueKeys()) {
                    OptionValue v = valueByKey.get(key);
                    if (v != null) resolved.add(v);
                }
                if (resolved.size() != req.optionValueKeys().size()) {
                    throw new RuntimeException(
                            "Biến thể \"" + variant.getSku() + "\" có thuộc tính không hợp lệ, "
                                    + "vui lòng tải lại trang và thử lại.");
                }
            }
            variant.setOptionValues(resolved);

            variant = variantRepo.save(variant);
            savedVariants.add(variant);
            i++;
        }

        for (ProductVariant old : existingVariants) {
            if (keptIds.contains(old.getId())) continue;
            try {
                variantRepo.deleteById(old.getId());
            } catch (DataIntegrityViolationException e) {
                throw new RuntimeException(
                        "Không thể xoá biến thể \"" + old.getSku() + "\" vì đã có đơn hàng sử dụng.");
            }
        }

        // 4) Đảm bảo LUÔN có đúng 1 biến thể mặc định (isDefault = true):
        //    - Nếu admin không tick default cho dòng nào -> tự động gán cho biến thể đầu tiên.
        //    - Nếu admin (hoặc lỗi client) tick default cho nhiều dòng -> chỉ giữ lại dòng đầu
        //      tiên, tắt các dòng còn lại. Trang chi tiết/card sản phẩm luôn cần đúng 1 biến thể
        //      mặc định để lấy giá/tồn kho hiển thị, tránh NoSuchElementException hoặc sai giá.
        if (!savedVariants.isEmpty()) {
            boolean seenDefault = false;
            for (ProductVariant v : savedVariants) {
                if (Boolean.TRUE.equals(v.getIsDefault())) {
                    if (seenDefault) {
                        v.setIsDefault(false);
                        variantRepo.save(v);
                    } else {
                        seenDefault = true;
                    }
                }
            }
            if (!seenDefault) {
                ProductVariant first = savedVariants.get(0);
                first.setIsDefault(true);
                variantRepo.save(first);
            }
        }
    }

    private String normalizeSlug(String raw) {
        String noAccent = Normalizer.normalize(raw, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('đ', 'd').replace('Đ', 'D');
        String slug = noAccent.trim().toLowerCase()
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("(^-+|-+$)", "");
        return slug.isBlank() ? "sp-" + System.currentTimeMillis() : slug;
    }

    /** Lưu file ảnh do admin tải lên đĩa cục bộ, trả về URL phục vụ qua {@code /uploads/products/**}. */
    public String storeImage(MultipartFile file) {
        try {
            String uploadDir = "uploads/products/";
            Files.createDirectories(Paths.get(uploadDir));

            String originalName = file.getOriginalFilename();
            if (originalName == null || originalName.isBlank()) originalName = "image.jpg";
            String safeName = originalName.replaceAll("\\s+", "_").replaceAll("[^a-zA-Z0-9._-]", "");
            String fileName = UUID.randomUUID() + "_" + safeName;

            Path path = Paths.get(uploadDir).resolve(fileName);
            Files.copy(file.getInputStream(), path, StandardCopyOption.REPLACE_EXISTING);

            return "/uploads/products/" + fileName;
        } catch (IOException e) {
            throw new RuntimeException("Lỗi khi lưu ảnh: " + e.getMessage());
        }
    }
}