package com.fpoly.config;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.fpoly.model.Category;
import com.fpoly.repository.CategoryRepository;

@ControllerAdvice
public class GlobalDataController {

    @Autowired
    private CategoryRepository categoryRepository;

    @ModelAttribute("menuCategories")
    public List<Category> menuCategories() {
        return categoryRepository.findAllByOrderBySortOrderAsc();
    }
}