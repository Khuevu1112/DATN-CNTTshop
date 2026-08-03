package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.ArticleDtos.AdminArticleDto;
import com.fpoly.dto.ArticleDtos.CategoryDto;
import com.fpoly.dto.ArticleDtos.LuuArticleRequest;
import com.fpoly.model.enums.PermissionType;
import com.fpoly.security.RequirePermission;
import com.fpoly.service.ArticleService;

/** Tin tức — biên tập phía nhân viên. Quyền "articles" (nhóm Kinh doanh/Marketing). */
@RestController
@RequestMapping("/api/admin/articles")
public class AdminArticleApiController {

    @Autowired private ArticleService articleService;

    @GetMapping
    @RequirePermission(feature = "articles", action = PermissionType.VIEW)
    public List<AdminArticleDto> danhSach() {
        return articleService.danhSachAdmin();
    }

    @GetMapping("/categories")
    @RequirePermission(feature = "articles", action = PermissionType.VIEW)
    public List<CategoryDto> danhMuc() {
        return articleService.danhMucAdmin();
    }

    @PostMapping
    @RequirePermission(feature = "articles", action = PermissionType.ADD)
    public AdminArticleDto tao(@RequestBody LuuArticleRequest req) {
        return articleService.tao(req);
    }

    @PutMapping("/{id}")
    @RequirePermission(feature = "articles", action = PermissionType.EDIT)
    public AdminArticleDto sua(@PathVariable Integer id, @RequestBody LuuArticleRequest req) {
        return articleService.sua(id, req);
    }

    @DeleteMapping("/{id}")
    @RequirePermission(feature = "articles", action = PermissionType.DELETE)
    public void xoa(@PathVariable Integer id) {
        articleService.xoa(id);
    }
}
