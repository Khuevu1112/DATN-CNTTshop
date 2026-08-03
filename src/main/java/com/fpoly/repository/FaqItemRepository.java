package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.FaqItem;

public interface FaqItemRepository extends JpaRepository<FaqItem, Integer> {

    @Query("SELECT i FROM FaqItem i JOIN FETCH i.category c "
            + "WHERE i.hienThi = true AND c.hienThi = true ORDER BY c.sortOrder, i.sortOrder")
    List<FaqItem> findPublic();

    @Query("SELECT i FROM FaqItem i JOIN FETCH i.category c "
            + "WHERE i.hienThi = true AND c.hienThi = true AND i.noiBat = true "
            + "ORDER BY c.sortOrder, i.sortOrder")
    List<FaqItem> findNoiBat();

    @Query("SELECT i FROM FaqItem i JOIN FETCH i.category ORDER BY i.category.sortOrder, i.sortOrder")
    List<FaqItem> findAllForAdmin();

    /** Đếm lượt xem bằng UPDATE thẳng thay vì load-sửa-lưu: tránh đụng @PreUpdate làm
     * updated_at nhảy mỗi lần có người bung câu trả lời ra đọc. */
    @Modifying
    @Query("UPDATE FaqItem i SET i.luotXem = i.luotXem + 1 WHERE i.id = :id")
    void tangLuotXem(@Param("id") Integer id);
}
