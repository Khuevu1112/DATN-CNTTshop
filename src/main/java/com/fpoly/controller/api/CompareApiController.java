package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.dto.CatalogDtos.CompareRowDto;
import com.fpoly.dto.CatalogDtos.ProductSummaryDto;
import com.fpoly.model.Product;
import com.fpoly.service.CatalogApiService;
import com.fpoly.service.CompareService;

/** REST API "So sánh sản phẩm" — công khai, không cần đăng nhập. */
@RestController
@RequestMapping("/api/compare")
public class CompareApiController {

    @Autowired private CompareService compareService;
    @Autowired private CatalogApiService catalogApiService;

    public record CompareResultDto(List<ProductSummaryDto> products, List<CompareRowDto> rows, int maxCompare) {}

    @GetMapping
    public CompareResultDto compare(@RequestParam List<Integer> ids) {
        List<Product> products = compareService.layDanhSachSanPham(ids);
        List<CompareRowDto> rows = compareService.xayDungBangSoSanh(products);
        List<ProductSummaryDto> summaries = catalogApiService.toSummaries(products);
        return new CompareResultDto(summaries, rows, compareService.getMaxCompare());
    }
}
