package com.fpoly.controller.api;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.OrderDtos.AddCartItemRequest;
import com.fpoly.dto.OrderDtos.CartDto;
import com.fpoly.dto.OrderDtos.CartItemDto;
import com.fpoly.dto.OrderDtos.UpdateCartItemRequest;
import com.fpoly.model.CartItem;
import com.fpoly.model.OptionValue;
import com.fpoly.model.Product;
import com.fpoly.model.ProductImage;
import com.fpoly.model.ProductVariant;
import com.fpoly.service.CartService;

/** Giỏ hàng thật (lưu DB theo user) — dùng cho cnttshop-vue. */
@RestController
@RequestMapping("/api/cart")
public class CartApiController {

    @Autowired private CartService cartService;

    @GetMapping
    public CartDto get(Authentication auth) {
        return toCartDto(auth.getName());
    }

    @PostMapping("/items")
    public CartDto addItem(@RequestBody AddCartItemRequest req, Authentication auth) {
        cartService.themVaoGio(auth.getName(), req.variantId(), req.quantity() == null ? 1 : req.quantity());
        return toCartDto(auth.getName());
    }

    @PutMapping("/items/{itemId}")
    public CartDto updateItem(@PathVariable Integer itemId, @RequestBody UpdateCartItemRequest req, Authentication auth) {
        cartService.capNhatSoLuong(auth.getName(), itemId, req.quantity());
        return toCartDto(auth.getName());
    }

    @DeleteMapping("/items/{itemId}")
    public CartDto removeItem(@PathVariable Integer itemId, Authentication auth) {
        cartService.xoaItem(auth.getName(), itemId);
        return toCartDto(auth.getName());
    }

    private CartDto toCartDto(String email) {
        List<CartItem> items = cartService.layDanhSachItem(email);
        List<CartItemDto> dtos = items.stream().map(this::toItemDto).toList();
        BigDecimal subtotal = items.stream().map(CartItem::getThanhTien).reduce(BigDecimal.ZERO, BigDecimal::add);
        return new CartDto(dtos, subtotal, dtos.size());
    }

    private CartItemDto toItemDto(CartItem ci) {
        ProductVariant v = ci.getVariant();
        Product p = v.getProduct();
        String optionsText = v.getOptionValues() == null ? "" : v.getOptionValues().stream()
                .map(OptionValue::getValue).reduce((a, b) -> a + " · " + b).orElse("");
        String img = (p.getImages() != null && !p.getImages().isEmpty())
                ? p.getImages().stream().filter(i -> Boolean.TRUE.equals(i.getIsPrimary()))
                    .map(ProductImage::getUrl).findFirst().orElse(p.getImages().get(0).getUrl())
                : null;
        return new CartItemDto(
                ci.getId(), v.getId(), p.getId(), p.getSlug(), p.getName(), optionsText,
                v.getSku(), img, v.getPrice(), ci.getSoLuong(), ci.getThanhTien(), v.getStock());
    }
}
