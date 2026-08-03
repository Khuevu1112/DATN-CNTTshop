package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.Article;

public interface ArticleRepository extends JpaRepository<Article, Integer> {

    @Query("SELECT a FROM Article a JOIN FETCH a.category c "
            + "WHERE a.trangThai = 'published' AND c.hienThi = true ORDER BY a.publishedAt DESC")
    List<Article> findPublished();

    @Query("SELECT a FROM Article a JOIN FETCH a.category c "
            + "WHERE a.trangThai = 'published' AND c.hienThi = true AND c.ma = :ma "
            + "ORDER BY a.publishedAt DESC")
    List<Article> findPublishedByCategory(@Param("ma") String ma);

    @Query("SELECT a FROM Article a JOIN FETCH a.category WHERE a.slug = :slug")
    Optional<Article> findBySlugFetch(@Param("slug") String slug);

    boolean existsBySlug(String slug);

    @Query("SELECT a FROM Article a JOIN FETCH a.category ORDER BY a.createdAt DESC")
    List<Article> findAllForAdmin();

    @Modifying
    @Query("UPDATE Article a SET a.luotXem = a.luotXem + 1 WHERE a.id = :id")
    void tangLuotXem(@Param("id") Integer id);
}
