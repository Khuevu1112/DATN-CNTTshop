package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.PcBuild;

public interface PcBuildRepository extends JpaRepository<PcBuild, Integer> {

    List<PcBuild> findByNguoiDungOrderByCreatedAtDesc(NguoiDung nguoiDung);

    @Query("SELECT b FROM PcBuild b LEFT JOIN FETCH b.items i LEFT JOIN FETCH i.productVariant WHERE b.id = :id")
    java.util.Optional<PcBuild> findByIdWithItems(@Param("id") Integer id);
}
