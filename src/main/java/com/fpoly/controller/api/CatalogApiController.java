package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.dto.CatalogDtos.CategoryDto;
import com.fpoly.dto.CatalogDtos.ProductDetailDto;
import com.fpoly.dto.CatalogDtos.ProductSummaryDto;
import com.fpoly.service.CatalogApiService;

/**
 * REST API công khai cho frontend Vue (không cần đăng nhập).
 */
@RestController
@RequestMapping("/api")
public class CatalogApiController {

    @Autowired
    private CatalogApiService catalogService;

    @GetMapping("/categories")
    public List<CategoryDto> categories() {
        return catalogService.getCategories();
    }

    @GetMapping("/products")
    public List<ProductSummaryDto> products(
            @RequestParam(required = false) String categorySlug,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String sort) {
        return catalogService.getProducts(categorySlug, keyword, sort);
    }

    @GetMapping("/products/{slug}")
    public ProductDetailDto productDetail(@PathVariable String slug) {
        return catalogService.getProductBySlug(slug);
    }
}
