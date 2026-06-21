package com.fpoly.controller.cilent;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.fpoly.model.Category;
import com.fpoly.model.Product;
import com.fpoly.repository.CategoryRepository;
import com.fpoly.repository.ProductRepository;

@Controller
public class HomeController {

    @Autowired
    private CategoryRepository categoryRepo;

    @Autowired
    private ProductRepository productRepo;

    @GetMapping("/")
    public String home(Model model) {

        List<Category> categories = categoryRepo.findAll();

        Map<Category, List<Product>> productByCategory = new LinkedHashMap<>();

        for (Category category : categories) {
            List<Product> products =
                    productRepo.findTop8ByCategoryAndIsActiveTrueOrderByCreatedAtDesc(category);

            if (!products.isEmpty()) {
                productByCategory.put(category, products);
            }
        }

        model.addAttribute("title", "CNTTShop");
        model.addAttribute("productByCategory", productByCategory);
        model.addAttribute("content", "home/index");

        return "layout/Base";
    }
}