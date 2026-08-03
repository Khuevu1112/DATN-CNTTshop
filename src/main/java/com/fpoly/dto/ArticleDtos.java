package com.fpoly.dto;

import java.time.LocalDateTime;

public class ArticleDtos {

    /** Thẻ bài ở danh sách — KHÔNG kèm nội dung đầy đủ để list nhẹ. */
    public record ArticleSummaryDto(
            Integer id, String slug, String tieuDe, String thumbnail, String tomTat,
            String maDanhMuc, String tenDanhMuc, String tacGia,
            boolean noiBat, Integer luotXem, LocalDateTime publishedAt
    ) {}

    public record ArticleDetailDto(
            Integer id, String slug, String tieuDe, String thumbnail, String tomTat,
            String noiDung, String maDanhMuc, String tenDanhMuc, String tacGia,
            Integer luotXem, LocalDateTime publishedAt
    ) {}

    public record CategoryDto(Integer id, String ma, String ten) {}

    /** Bản ghi phía admin — kèm trạng thái để soạn nháp/xuất bản. */
    public record AdminArticleDto(
            Integer id, String slug, String tieuDe, String thumbnail, String tomTat,
            String noiDung, Integer categoryId, String tenDanhMuc, String tacGia,
            String trangThai, boolean noiBat, Integer luotXem,
            LocalDateTime publishedAt, LocalDateTime createdAt
    ) {}

    public record LuuArticleRequest(
            String tieuDe, String slug, String thumbnail, Integer categoryId,
            String tomTat, String noiDung, String tacGia, String trangThai, Boolean noiBat
    ) {}
}
