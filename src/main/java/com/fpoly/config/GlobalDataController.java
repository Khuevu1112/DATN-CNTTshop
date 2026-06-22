package com.fpoly.config;

import java.security.Principal;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import java.util.List;

import com.fpoly.model.Category;
import com.fpoly.repository.CategoryRepository;
import com.fpoly.service.CartService;

@ControllerAdvice
public class GlobalDataController {

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private CartService cartService;

    @ModelAttribute("menuCategories")
    public List<Category> menuCategories() {
        return categoryRepository.findAllByOrderBySortOrderAsc();
    }

    @ModelAttribute("cartItemCount")
    public int cartItemCount(Principal principal) {
        if (principal == null) {
            return 0;
        }
        try {
            return cartService.demSoLuongItem(principal.getName());
        } catch (RuntimeException e) {
            return 0;
        }
    }
}