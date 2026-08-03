package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.fpoly.model.ServiceCenter;

public interface ServiceCenterRepository extends JpaRepository<ServiceCenter, Integer> {

    /** Danh sách công khai — JOIN FETCH tỉnh vì FE nào cũng hiển thị tên tỉnh kèm điểm. */
    @Query("SELECT c FROM ServiceCenter c LEFT JOIN FETCH c.province "
            + "WHERE c.hienThi = true ORDER BY c.sortOrder, c.ten")
    List<ServiceCenter> findPublic();

    @Query("SELECT c FROM ServiceCenter c LEFT JOIN FETCH c.province ORDER BY c.sortOrder, c.ten")
    List<ServiceCenter> findAllForAdmin();
}
