package com.fpoly.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
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
}