package com.fpoly.controller.admin;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fpoly.model.Category;
import com.fpoly.service.CategoryService;
import com.fpoly.service.ProductService;

@Controller
@RequestMapping("/admin/categories")
public class AdminCategoryController {

    @Autowired
    private CategoryService categoryService;

    @Autowired
    private ProductService productService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("categories", categoryService.findAll());
        return "admin/category-list";
    }

    @GetMapping("/add")
    public String add(Model model) {
        model.addAttribute("category", new Category());
        return "admin/category-form";
    }

    @GetMapping("/edit/{id}")
    public String edit(@PathVariable Integer id, Model model) {
        model.addAttribute("category", categoryService.findById(id));
        return "admin/category-form";
    }

    @PostMapping("/save")
    public String save(
            @ModelAttribute Category category,
            RedirectAttributes ra
    ) {
        categoryService.save(category);
        ra.addFlashAttribute("success", "Lưu danh mục thành công");
        return "redirect:/admin/categories";
    }

    @GetMapping("/delete/{id}")
    public String delete(
            @PathVariable Integer id,
            RedirectAttributes ra
    ) {
        String error = categoryService.delete(id);

        if (error != null) {
            ra.addFlashAttribute("error", error);
        } else {
            ra.addFlashAttribute("success", "Xóa danh mục thành công");
        }

        return "redirect:/admin/categories";
    }

    @GetMapping("/{id}/products")
    public String productsByCategory(
            @PathVariable Integer id,
            Model model
    ) {
        Category category = categoryService.findById(id);

        model.addAttribute("category", category);
        model.addAttribute("products", productService.findByCategory(category));

        return "admin/category-products";
    }
}