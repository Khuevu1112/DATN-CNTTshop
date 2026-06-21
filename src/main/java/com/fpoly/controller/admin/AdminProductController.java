package com.fpoly.controller.admin;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fpoly.model.Product;
import com.fpoly.service.CategoryService;
import com.fpoly.service.ProductService;
import java.math.BigDecimal;

@Controller
@RequestMapping("/admin/products")
public class AdminProductController {

    @Autowired
    private ProductService productService;

    @Autowired
    private CategoryService categoryService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("products", productService.findAll());
        return "admin/product-list";
    }

    @GetMapping("/add")
    public String addForm(Model model) {
        model.addAttribute("product", new Product());
        model.addAttribute("categories", categoryService.findAll());
        return "admin/product-form";
    }

    @PostMapping("/save")
    public String save(
            @ModelAttribute Product product,
            @RequestParam BigDecimal price,
            @RequestParam(required = false) BigDecimal originalPrice,
            @RequestParam Integer stock,
            RedirectAttributes redirectAttributes
    ) {
        productService.saveProductWithPrice(
                product,
                price,
                originalPrice,
                stock
        );

        redirectAttributes.addFlashAttribute(
                "success",
                "Lưu sản phẩm thành công"
        );

        return "redirect:/admin/products";
    }

    @GetMapping("/edit/{id}")
    public String edit(@PathVariable Integer id, Model model) {
        model.addAttribute("product", productService.findById(id));
        model.addAttribute("categories", categoryService.findAll());
        return "admin/product-form";
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Integer id) {
        productService.delete(id);
        return "redirect:/admin/products";
    }
}