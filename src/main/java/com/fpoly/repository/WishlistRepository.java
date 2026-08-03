package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.Product;
import com.fpoly.model.Wishlist;

public interface WishlistRepository extends JpaRepository<Wishlist, Integer> {

    @Query("SELECT w FROM Wishlist w JOIN FETCH w.product p LEFT JOIN FETCH p.variants "
            + "WHERE w.nguoiDung = :user ORDER BY w.createdAt DESC")
    List<Wishlist> findByNguoiDungOrderByCreatedAtDesc(@Param("user") NguoiDung user);

    Optional<Wishlist> findByNguoiDungAndProduct(NguoiDung nguoiDung, Product product);

    boolean existsByNguoiDungAndProduct(NguoiDung nguoiDung, Product product);

    @Modifying
    @Transactional
    void deleteByNguoiDungAndProduct(NguoiDung nguoiDung, Product product);

    /** Toàn bộ lượt yêu thích một sản phẩm — dùng để báo giảm giá cho từng người. */
    @Query("SELECT w FROM Wishlist w JOIN FETCH w.nguoiDung WHERE w.product = :product")
    List<Wishlist> findByProduct(@Param("product") Product product);

    long countByProduct(Product product);

    /** Mở lại cờ đã báo giảm giá khi giá TĂNG trở lại, để lần giảm tiếp theo vẫn được báo. */
    @Modifying
    @Transactional
    @Query("UPDATE Wishlist w SET w.discountNotified = false WHERE w.product = :product")
    void moKhoaNhacGiamGia(@Param("product") Product product);
}
