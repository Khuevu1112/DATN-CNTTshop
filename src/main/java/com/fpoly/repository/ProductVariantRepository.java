package com.fpoly.repository;

import java.util.List;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.ProductVariant;

public interface ProductVariantRepository extends JpaRepository<ProductVariant, Integer> {

    List<ProductVariant> findByProductId(Integer productId);

    /** Biến thể mang SKU này nhưng KHÔNG thuộc sản phẩm đang sửa — SKU là duy nhất toàn hệ
     * thống (UNIQUE trên PRODUCT_VARIANT.sku), phải kiểm trước để báo lỗi dễ hiểu thay vì để
     * CSDL ném ra lỗi ràng buộc (xem AdminProductService.saveVariants). */
    @Query("SELECT v FROM ProductVariant v WHERE LOWER(v.sku) = LOWER(:sku) "
            + "AND (:productId IS NULL OR v.product.id <> :productId)")
    List<ProductVariant> findTrungSku(@Param("sku") String sku, @Param("productId") Integer productId);

    @Query("SELECT v FROM ProductVariant v JOIN FETCH v.product p " +
           "WHERE (LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(v.sku) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
           "AND (:categorySlug IS NULL OR p.category.slug = :categorySlug) " +
           "ORDER BY v.id DESC")
    List<ProductVariant> search(@Param("keyword") String keyword, @Param("categorySlug") String categorySlug, Pageable pageable);
}