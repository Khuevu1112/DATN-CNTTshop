package com.fpoly.controller.cilent;

import java.util.Comparator;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.fpoly.model.Category;
import com.fpoly.model.Product;
import com.fpoly.repository.CategoryRepository;
import com.fpoly.repository.ProductRepository;

@Controller
public class ClientProductController {

    @Autowired
    private ProductRepository productRepo;

    @Autowired
    private CategoryRepository categoryRepo;

    @GetMapping("/products")
    public String products(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String sort,
            Model model
    ) {

        List<Product> products;

        // Cùng cách lọc với REST API (xem CatalogApiService.getProducts): theo TỪ, bỏ dấu, giãn
        // viết tắt — LIKE nguyên cụm trên cột tên trượt hầu hết câu tìm thật.
        products = new java.util.ArrayList<>(productRepo.findByIsActiveTrue());
        if (keyword != null && !keyword.isBlank()) {
            java.util.List<String> tu = com.fpoly.service.SearchTextUtils.tachTu(keyword);
            products.removeIf(p -> !com.fpoly.service.SearchTextUtils.khopMoiTu(chuoiTimKiem(p), tu));
        }

        sortProducts(products, sort);

        model.addAttribute("products", products);
        model.addAttribute("keyword", keyword);
        model.addAttribute("sort", sort);
        model.addAttribute("content", "product/list");

        return "layout/Base";
    }

    @GetMapping("/category/{slug}")
    public String productsByCategory(
            @PathVariable String slug,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String sort,
            Model model
    ) {

        Category category = categoryRepo.findBySlug(slug)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy danh mục"));

        List<Product> products;

        products = new java.util.ArrayList<>(productRepo.findByCategoryAndIsActiveTrue(category));
        if (keyword != null && !keyword.isBlank()) {
            java.util.List<String> tu = com.fpoly.service.SearchTextUtils.tachTu(keyword);
            products.removeIf(p -> !com.fpoly.service.SearchTextUtils.khopMoiTu(chuoiTimKiem(p), tu));
        }

        sortProducts(products, sort);

        model.addAttribute("category", category);
        model.addAttribute("products", products);
        model.addAttribute("keyword", keyword);
        model.addAttribute("sort", sort);
        model.addAttribute("content", "product/list");

        return "layout/Base";
    }

    @GetMapping("/product/{slug}")
    public String detail(
            @PathVariable String slug,
            Model model
    ) {

        Product product = productRepo.findBySlug(slug)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));

        model.addAttribute("product", product);
        model.addAttribute("content", "product/detail");

        return "layout/Base";
    }

    /** Phần chữ có thể tìm của 1 sản phẩm: tên + hãng + danh mục. */
    private String chuoiTimKiem(Product p) {
        StringBuilder sb = new StringBuilder(p.getName() == null ? "" : p.getName());
        if (p.getBrand() != null) sb.append(' ').append(p.getBrand().getName());
        if (p.getCategory() != null) sb.append(' ').append(p.getCategory().getName());
        return sb.toString();
    }

    private void sortProducts(List<Product> products, String sort) {

        if (sort == null) {
            return;
        }

        if (sort.equals("name_asc")) {
            products.sort(Comparator.comparing(Product::getName));
        }

        if (sort.equals("name_desc")) {
            products.sort(Comparator.comparing(Product::getName).reversed());
        }

        if (sort.equals("newest")) {
            products.sort(Comparator.comparing(Product::getCreatedAt).reversed());
        }
    }
}