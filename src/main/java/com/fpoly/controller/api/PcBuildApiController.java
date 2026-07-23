package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.PcBuildDtos.AddItemRequest;
import com.fpoly.dto.PcBuildDtos.ComponentTypeDto;
import com.fpoly.dto.PcBuildDtos.PcBuildDetailDto;
import com.fpoly.dto.PcBuildDtos.PcBuildItemDto;
import com.fpoly.dto.PcBuildDtos.PcBuildSummaryDto;
import com.fpoly.dto.PcBuildDtos.ProductBrowseItemDto;
import com.fpoly.dto.PcBuildDtos.ProductBrowsePageDto;
import com.fpoly.dto.PcBuildDtos.SaveBuildRequest;
import com.fpoly.model.PcBuild;
import com.fpoly.model.PcBuildItem;
import com.fpoly.model.Product;
import com.fpoly.model.ProductImage;
import com.fpoly.model.ProductVariant;
import com.fpoly.service.CartService;
import com.fpoly.service.PcBuildService;

/** REST API "Xây dựng cấu hình PC" — yêu cầu đăng nhập. */
@RestController
@RequestMapping("/api/pc-build")
public class PcBuildApiController {

    @Autowired private PcBuildService pcBuildService;
    @Autowired private CartService cartService;

    @GetMapping("/component-types")
    public List<ComponentTypeDto> componentTypes() {
        return pcBuildService.layDanhSachLoaiLinhKien().stream()
                .map(l -> new ComponentTypeDto(l.name(), l.getTenHienThi(), l.getIcon()))
                .toList();
    }

    @GetMapping("/products")
    public ProductBrowsePageDto browseProducts(
            @RequestParam String loai,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "0") int page) {
        Page<Product> result = pcBuildService.timSanPhamTheoLoai(loai, keyword, PageRequest.of(page, 8));
        List<ProductBrowseItemDto> items = result.getContent().stream().map(this::toBrowseItem).toList();
        return new ProductBrowsePageDto(items, result.getNumber(), result.getTotalPages(), result.getTotalElements());
    }

    @GetMapping
    public List<PcBuildSummaryDto> myBuilds(Authentication auth) {
        return pcBuildService.layDanhSachBuild(auth.getName()).stream().map(this::toSummary).toList();
    }

    @PostMapping
    public PcBuildDetailDto createDraft(Authentication auth) {
        PcBuild build = pcBuildService.layHoacTaoBuildNhap(auth.getName());
        return toDetail(build);
    }

    @GetMapping("/{id}")
    public PcBuildDetailDto detail(@PathVariable Integer id, Authentication auth) {
        return toDetail(pcBuildService.layBuildTheoId(id, auth.getName()));
    }

    @PostMapping("/{id}/items")
    public PcBuildDetailDto addItem(@PathVariable Integer id, @RequestBody AddItemRequest req, Authentication auth) {
        PcBuild build = pcBuildService.themLinhKien(id, auth.getName(), req.variantId(), req.componentType());
        return toDetail(build);
    }

    @DeleteMapping("/{id}/items/{loai}")
    public PcBuildDetailDto removeItem(@PathVariable Integer id, @PathVariable String loai, Authentication auth) {
        PcBuild build = pcBuildService.xoaLinhKien(id, auth.getName(), loai);
        return toDetail(build);
    }

    @PutMapping("/{id}")
    public PcBuildDetailDto save(@PathVariable Integer id, @RequestBody SaveBuildRequest req, Authentication auth) {
        PcBuild build = pcBuildService.luuCauHinh(id, auth.getName(), req.name(), req.note());
        return toDetail(build);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Integer id, Authentication auth) {
        pcBuildService.xoaBuild(id, auth.getName());
    }

    @PostMapping("/{id}/add-to-cart")
    public void addToCart(@PathVariable Integer id, Authentication auth) {
        pcBuildService.themToanBoCauHinhVaoGio(id, auth.getName(), cartService);
    }

    private ProductBrowseItemDto toBrowseItem(Product p) {
        ProductVariant v = (p.getVariants() == null || p.getVariants().isEmpty()) ? null
                : p.getVariants().stream().filter(x -> Boolean.TRUE.equals(x.getIsDefault()))
                    .findFirst().orElse(p.getVariants().get(0));
        String img = null;
        if (p.getImages() != null) {
            img = p.getImages().stream().filter(i -> Boolean.TRUE.equals(i.getIsPrimary()))
                    .map(ProductImage::getUrl).findFirst()
                    .orElse(p.getImages().isEmpty() ? null : p.getImages().get(0).getUrl());
        }
        return new ProductBrowseItemDto(
                p.getId(), p.getSlug(), p.getName(), img,
                v != null ? v.getId() : null,
                v != null ? v.getPrice() : null,
                v != null ? v.getOriginalPrice() : null,
                v != null ? v.getStock() : 0);
    }

    private PcBuildSummaryDto toSummary(PcBuild b) {
        return new PcBuildSummaryDto(b.getId(), b.getTenCauHinh(), b.getGhiChu(), b.getCreatedAt(),
                b.getTongGia(), b.getItems() == null ? 0 : b.getItems().size());
    }

    private PcBuildDetailDto toDetail(PcBuild b) {
        List<PcBuildItemDto> items = b.getItems() == null ? List.of() : b.getItems().stream()
                .map(this::toItemDto).toList();
        return new PcBuildDetailDto(b.getId(), b.getTenCauHinh(), b.getGhiChu(), b.getCreatedAt(),
                b.getTongGia(), items, pcBuildService.kiemTraTuongThich(b));
    }

    private PcBuildItemDto toItemDto(PcBuildItem item) {
        ProductVariant v = item.getProductVariant();
        Product p = v.getProduct();
        String img = (p.getImages() != null && !p.getImages().isEmpty()) ? p.getImages().get(0).getUrl() : null;
        return new PcBuildItemDto(
                item.getLoaiLinhKien(), item.getTenLoai(), item.getIconLoai(),
                v.getId(), p.getId(), p.getSlug(), p.getName(), v.getSku(), v.getPrice(), img, item.getSoLuong());
    }
}
