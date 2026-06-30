package com.fpoly.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import com.fpoly.model.Category;
import com.fpoly.model.Product;
import com.fpoly.model.ProductVariant;
import com.fpoly.repository.ProductRepository;
import com.fpoly.repository.ProductVariantRepository;

@Service
public class ProductService {

    @Autowired
    private ProductRepository productRepo;

    @Autowired
    private ProductVariantRepository variantRepo;

    // ── Các method cũ giữ nguyên ──────────────────────────────

    public List<Product> findAll() {
        return productRepo.findAll();
    }

    public List<Product> findByCategory(Category category) {
        return productRepo.findByCategory(category);
    }

    public Product findById(Integer id) {
        return productRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));
    }

    public void saveProductWithPrice(
            Product product,
            BigDecimal price,
            BigDecimal originalPrice,
            Integer stock
    ) {
        if (product.getIsActive() == null) {
            product.setIsActive(true);
        }
        if (product.getCreatedAt() == null) {
            product.setCreatedAt(LocalDateTime.now());
        }
        Product savedProduct = productRepo.save(product);

        ProductVariant variant = new ProductVariant();
        variant.setProduct(savedProduct);
        variant.setSku("SKU-" + savedProduct.getId());
        variant.setPrice(price);
        variant.setOriginalPrice(originalPrice);
        variant.setStock(stock);
        variant.setIsDefault(true);
        variantRepo.save(variant);
    }

    public void delete(Integer id) {
        productRepo.deleteById(id);
    }

    // ── Method cho PcBuild builder ────────────────────────────

    /**
     * Map từng loại linh kiện sang slug danh mục con đúng trong DB.
     * Slug này khớp với bảng CATEGORY sau khi đã chạy SQL thêm danh mục con.
     */
    public Page<Product> timSanPhamTheoLoai(String loaiLinhKien, String keyword, Pageable pageable) {

        Map<String, String> loaiToSlug = Map.ofEntries(
            Map.entry("CPU",        "cpu"),
            Map.entry("MAINBOARD",  "mainboard"),
            Map.entry("RAM",        "ram"),
            Map.entry("GPU",        "gpu"),
            Map.entry("SSD",        "ssd"),
            Map.entry("HDD",        "hdd"),
            Map.entry("PSU",        "psu"),
            Map.entry("CASE",       "case-may-tinh"),
            Map.entry("CPU_COOLER", "tan-nhiet-cpu"),
            Map.entry("MONITOR",    "man-hinh")   // danh mục cha màn hình
        );

        String slug = loaiToSlug.getOrDefault(loaiLinhKien, "linh-kien");

        if (keyword != null && !keyword.isBlank()) {
            return productRepo.findByCategorySlugAndNameContainingIgnoreCaseAndIsActiveTrue(
                    slug, keyword, pageable);
        }

        return productRepo.findByCategorySlugAndIsActiveTrue(slug, pageable);
    }
}