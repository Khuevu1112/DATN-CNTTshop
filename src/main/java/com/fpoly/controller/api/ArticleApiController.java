package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.ArticleDtos.ArticleDetailDto;
import com.fpoly.dto.ArticleDtos.ArticleSummaryDto;
import com.fpoly.dto.ArticleDtos.CategoryDto;
import com.fpoly.service.ArticleService;

/** Tin tức — API công khai (không cần đăng nhập). */
@RestController
@RequestMapping("/api")
public class ArticleApiController {

    @Autowired private ArticleService articleService;

    @GetMapping("/article-categories")
    public List<CategoryDto> danhMuc() {
        return articleService.danhMuc();
    }

    @GetMapping("/articles")
    public List<ArticleSummaryDto> danhSach(@RequestParam(required = false) String category) {
        return articleService.danhSachCongKhai(category);
    }

    @GetMapping("/articles/{slug}")
    public ArticleDetailDto chiTiet(@PathVariable String slug) {
        return articleService.chiTiet(slug);
    }
}
