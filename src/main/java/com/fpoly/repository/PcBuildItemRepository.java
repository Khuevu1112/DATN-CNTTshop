package com.fpoly.repository;

import com.fpoly.model.PcBuildItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PcBuildItemRepository extends JpaRepository<PcBuildItem, Integer> {

    // Tìm linh kiện theo loại trong 1 build
    Optional<PcBuildItem> findByPcBuildIdAndLoaiLinhKien(Integer buildId, String loaiLinhKien);

    // Xóa linh kiện theo loại khỏi build
    @Modifying
    @Query("DELETE FROM PcBuildItem i WHERE i.pcBuild.id = :buildId AND i.loaiLinhKien = :loai")
    void deleteByBuildIdAndLoai(@Param("buildId") Integer buildId, @Param("loai") String loai);

    // Kiểm tra slot linh kiện đã có chưa
    boolean existsByPcBuildIdAndLoaiLinhKien(Integer buildId, String loaiLinhKien);
}