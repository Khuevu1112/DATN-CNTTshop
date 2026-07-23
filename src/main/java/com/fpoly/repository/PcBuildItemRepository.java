package com.fpoly.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.PcBuildItem;

public interface PcBuildItemRepository extends JpaRepository<PcBuildItem, Integer> {

    @Modifying
    @Query("DELETE FROM PcBuildItem i WHERE i.pcBuild.id = :buildId AND i.loaiLinhKien = :loai")
    void deleteByBuildIdAndLoai(@Param("buildId") Integer buildId, @Param("loai") String loai);
}
