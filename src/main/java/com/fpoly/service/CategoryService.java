package com.fpoly.service;

import java.text.Normalizer;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fpoly.model.Category;
import com.fpoly.repository.CategoryRepository;
import com.fpoly.repository.ProductRepository;

@Service
public class CategoryService {

    @Autowired
    private CategoryRepository repo;

    @Autowired
    private ProductRepository productRepo;

    public List<Category> findAll() {
        return repo.findAll();
    }

    public Category findById(Integer id) {
        return repo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy danh mục"));
    }

    public void save(Category category) {

        if (category.getSlug() == null || category.getSlug().isBlank()) {
            category.setSlug(toSlug(category.getName()));
        }

        if (category.getSortOrder() == null) {
            category.setSortOrder(0);
        }

        repo.save(category);
    }

    public String delete(Integer id) {

        Category category = findById(id);

        long count = productRepo.countByCategory(category);

        if (count > 0) {
            return "Không thể xóa danh mục vì đang có sản phẩm";
        }

        repo.deleteById(id);
        return null;
    }

    private String toSlug(String input) {
        String slug = Normalizer.normalize(input, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .toLowerCase()
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("^-|-$", "");

        return slug;
    }
}