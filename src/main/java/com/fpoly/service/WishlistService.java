package com.fpoly.service;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.WishlistDtos.WishlistItemDto;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.Product;
import com.fpoly.model.ProductImage;
import com.fpoly.model.ProductVariant;
import com.fpoly.model.Wishlist;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.ProductRepository;
import com.fpoly.repository.WishlistRepository;

/** Sản phẩm yêu thích, kiểu Steam wishlist: trái tim bật/tắt ở trang chi tiết, trang danh sách
 * riêng, và báo email khi giá giảm. Mang ý tưởng từ bản Thymeleaf của teammate (nhánh
 * ManhTung-ThongKeAI,Wishlist) nhưng viết lại trên kiến trúc REST API + Vue hiện tại — bản gốc
 * chỉ có schema SQL trần và code Thymeleaf, không áp dụng thẳng được cho SPA. */
@Service
public class WishlistService {

    @Autowired private WishlistRepository wishlistRepo;
    @Autowired private NguoiDungRepository nguoiDungRepo;
    @Autowired private ProductRepository productRepo;
    @Autowired private MailService mailService;
    @Autowired private NotificationService notificationService;

    private NguoiDung layUser(String email) {
        return nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
    }

    public List<WishlistItemDto> danhSach(String email) {
        NguoiDung user = layUser(email);
        return wishlistRepo.findByNguoiDungOrderByCreatedAtDesc(user).stream()
                .map(this::toDto)
                .toList();
    }

    /** Bật/tắt yêu thích, trả về trạng thái MỚI (true = vừa thêm, false = vừa bỏ). */
    @Transactional
    public boolean toggle(String email, Integer productId) {
        NguoiDung user = layUser(email);
        Product product = productRepo.findById(productId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));

        var existing = wishlistRepo.findByNguoiDungAndProduct(user, product);
        if (existing.isPresent()) {
            wishlistRepo.delete(existing.get());
            return false;
        }
        Wishlist w = new Wishlist();
        w.setNguoiDung(user);
        w.setProduct(product);
        wishlistRepo.save(w);
        return true;
    }

    @Transactional
    public void xoa(String email, Integer productId) {
        NguoiDung user = layUser(email);
        Product product = productRepo.findById(productId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));
        wishlistRepo.deleteByNguoiDungAndProduct(user, product);
    }

    public boolean daYeuThich(String email, Integer productId) {
        NguoiDung user = layUser(email);
        Product product = productRepo.findById(productId).orElse(null);
        return product != null && wishlistRepo.existsByNguoiDungAndProduct(user, product);
    }

    /** Giá sản phẩm vừa GIẢM — báo cho từng người đã yêu thích (mail + thông báo trong app), mỗi
     * người chỉ báo 1 lần cho tới khi giá tăng trở lại (xem moKhoaNhacGiamGia). Lỗi gửi mail của
     * một người không được chặn các người còn lại. */
    @Transactional
    public void baoGiamGia(Product product, BigDecimal giaCu, BigDecimal giaMoi) {
        for (Wishlist w : wishlistRepo.findByProduct(product)) {
            if (w.isDiscountNotified()) continue;
            NguoiDung u = w.getNguoiDung();
            try {
                mailService.sendWishlistDiscountEmail(u.getEmail(), u.getHoTen(),
                        product.getName(), product.getSlug(), giaCu, giaMoi);
            } catch (Exception e) {
                // Gửi mail hỏng không được chặn báo cho người tiếp theo, và vẫn đánh dấu đã báo
                // (đã có thông báo trong app bù lại) để không lặp lại lỗi mỗi lần giá đổi.
            }
            notificationService.taoChoUser(u.getId(), "wishlist_discount",
                    "🔥 Sản phẩm yêu thích giảm giá",
                    product.getName() + " vừa giảm còn " + giaMoi.toBigInteger() + "đ.",
                    "/yeu-thich");
            w.setDiscountNotified(true);
            wishlistRepo.save(w);
        }
    }

    /** Giá TĂNG trở lại — mở lại cờ để lần giảm kế tiếp vẫn báo được. */
    @Transactional
    public void moKhoaNhacGiamGia(Product product) {
        wishlistRepo.moKhoaNhacGiamGia(product);
    }

    private WishlistItemDto toDto(Wishlist w) {
        Product p = w.getProduct();
        ProductVariant v = pickVariant(p);
        String anh = pickImageUrl(p);
        return new WishlistItemDto(
                w.getId(), p.getId(), p.getSlug(), p.getName(), anh,
                v != null ? v.getPrice() : null,
                v != null ? v.getOriginalPrice() : null,
                v != null ? v.getStock() : null,
                v != null ? v.getId() : null,
                w.getCreatedAt());
    }

    private ProductVariant pickVariant(Product p) {
        if (p.getVariants() == null || p.getVariants().isEmpty()) return null;
        for (ProductVariant v : p.getVariants()) {
            if (Boolean.TRUE.equals(v.getIsDefault())) return v;
        }
        return p.getVariants().get(0);
    }

    private String pickImageUrl(Product p) {
        if (p.getImages() == null || p.getImages().isEmpty()) return null;
        for (ProductImage img : p.getImages()) {
            if (Boolean.TRUE.equals(img.getIsPrimary())) return img.getUrl();
        }
        return p.getImages().get(0).getUrl();
    }
}
