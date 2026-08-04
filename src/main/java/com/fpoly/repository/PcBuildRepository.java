package com.fpoly.repository;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.PcBuild;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PcBuildRepository extends JpaRepository<PcBuild, Integer> {

    List<PcBuild> findByNguoiDungOrderByCreatedAtDesc(NguoiDung nguoiDung);

    long countByNguoiDung(NguoiDung nguoiDung);

    // Chỉ fetch items + variant + product, KHÔNG fetch images cùng lúc
    // (tránh MultipleBagFetchException khi Product.images cũng là List)
    @Query("SELECT DISTINCT b FROM PcBuild b " +
           "LEFT JOIN FETCH b.items i " +
           "LEFT JOIN FETCH i.productVariant v " +
           "LEFT JOIN FETCH v.product p " +
           "WHERE b.id = :id")
    Optional<PcBuild> findByIdWithItems(@Param("id") Integer id);

    boolean existsByIdAndNguoiDung(Integer id, NguoiDung nguoiDung);
}