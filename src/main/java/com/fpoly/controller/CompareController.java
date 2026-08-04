package com.fpoly.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.fpoly.model.Product;
import com.fpoly.model.dto.CompareRow;
import com.fpoly.service.CompareService;

@Controller
public class CompareController {

    @Autowired
    private CompareService compareService;

    @GetMapping("/compare")
    public String soSanh(@RequestParam(name = "ids", required = false) List<Integer> ids,
                          Model model) {

        List<Product> products = compareService.layDanhSachSanPham(ids);
        List<CompareRow> rows = compareService.xayDungBangSoSanhModel(products);

        model.addAttribute("products", products);
        model.addAttribute("rows", rows);
        model.addAttribute("maxCompare", compareService.getMaxCompare());
        model.addAttribute("title", "So sánh sản phẩm");

        return "compare/index";
    }
}