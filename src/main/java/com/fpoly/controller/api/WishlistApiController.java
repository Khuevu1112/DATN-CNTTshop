package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.WishlistDtos.ToggleResultDto;
import com.fpoly.dto.WishlistDtos.WishlistItemDto;
import com.fpoly.service.WishlistService;

/** Danh sách yêu thích (kiểu Steam wishlist) — yêu cầu đăng nhập (khớp anyRequest().authenticated()
 * mặc định của chain API, không cần khai riêng trong SecurityConfig). */
@RestController
@RequestMapping("/api/wishlist")
public class WishlistApiController {

    @Autowired private WishlistService wishlistService;

    @GetMapping
    public List<WishlistItemDto> danhSach(Authentication auth) {
        return wishlistService.danhSach(auth.getName());
    }

    /** Bật/tắt yêu thích — dùng cho trái tim ở trang chi tiết sản phẩm. */
    @PostMapping("/{productId}/toggle")
    public ToggleResultDto toggle(@PathVariable Integer productId, Authentication auth) {
        return new ToggleResultDto(wishlistService.toggle(auth.getName(), productId));
    }

    @GetMapping("/{productId}/trang-thai")
    public ToggleResultDto trangThai(@PathVariable Integer productId, Authentication auth) {
        return new ToggleResultDto(wishlistService.daYeuThich(auth.getName(), productId));
    }

    /** Bỏ yêu thích — dùng cho nút "Bỏ yêu thích" ở trang danh sách. */
    @DeleteMapping("/{productId}")
    public void xoa(@PathVariable Integer productId, Authentication auth) {
        wishlistService.xoa(auth.getName(), productId);
    }
}
