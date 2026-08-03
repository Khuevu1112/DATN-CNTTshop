package com.fpoly.service;

import java.text.Normalizer;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.ArticleDtos.AdminArticleDto;
import com.fpoly.dto.ArticleDtos.ArticleDetailDto;
import com.fpoly.dto.ArticleDtos.ArticleSummaryDto;
import com.fpoly.dto.ArticleDtos.CategoryDto;
import com.fpoly.dto.ArticleDtos.LuuArticleRequest;
import com.fpoly.model.Article;
import com.fpoly.model.ArticleCategory;
import com.fpoly.repository.ArticleCategoryRepository;
import com.fpoly.repository.ArticleRepository;

/** Tin tức / blog. Phần ĐỌC (danh sách + chi tiết + danh mục) công khai; phần biên tập đi qua
 * AdminArticleApiController với quyền "articles". */
@Service
public class ArticleService {

    @Autowired private ArticleRepository articleRepo;
    @Autowired private ArticleCategoryRepository categoryRepo;

    // ===================== Công khai =====================

    /** ma = mã danh mục để lọc (null/blank = tất cả). */
    public List<ArticleSummaryDto> danhSachCongKhai(String ma) {
        List<Article> rows = (ma == null || ma.isBlank())
                ? articleRepo.findPublished()
                : articleRepo.findPublishedByCategory(ma);
        return rows.stream().map(this::toSummary).toList();
    }

    public List<CategoryDto> danhMuc() {
        return categoryRepo.findByHienThiTrueOrderBySortOrderAsc().stream()
                .map(c -> new CategoryDto(c.getId(), c.getMa(), c.getTen()))
                .toList();
    }

    @Transactional
    public ArticleDetailDto chiTiet(String slug) {
        Article a = articleRepo.findBySlugFetch(slug)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy bài viết"));
        if (!"published".equals(a.getTrangThai())) {
            throw new RuntimeException("Bài viết chưa được xuất bản");
        }
        articleRepo.tangLuotXem(a.getId());
        return new ArticleDetailDto(
                a.getId(), a.getSlug(), a.getTieuDe(), a.getThumbnail(), a.getTomTat(),
                a.getNoiDung(), a.getCategory().getMa(), a.getCategory().getTen(), a.getTacGia(),
                a.getLuotXem() + 1, a.getPublishedAt());
    }

    private ArticleSummaryDto toSummary(Article a) {
        return new ArticleSummaryDto(
                a.getId(), a.getSlug(), a.getTieuDe(), a.getThumbnail(), a.getTomTat(),
                a.getCategory().getMa(), a.getCategory().getTen(), a.getTacGia(),
                a.isNoiBat(), a.getLuotXem(), a.getPublishedAt());
    }

    // ===================== Admin =====================

    public List<AdminArticleDto> danhSachAdmin() {
        return articleRepo.findAllForAdmin().stream().map(this::toAdmin).toList();
    }

    public List<CategoryDto> danhMucAdmin() {
        return categoryRepo.findAllByOrderBySortOrderAsc().stream()
                .map(c -> new CategoryDto(c.getId(), c.getMa(), c.getTen()))
                .toList();
    }

    @Transactional
    public AdminArticleDto tao(LuuArticleRequest req) {
        Article a = new Article();
        apDung(a, req, true);
        articleRepo.save(a);
        return toAdmin(a);
    }

    @Transactional
    public AdminArticleDto sua(Integer id, LuuArticleRequest req) {
        Article a = articleRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy bài viết"));
        apDung(a, req, false);
        a.setUpdatedAt(LocalDateTime.now());
        articleRepo.save(a);
        return toAdmin(a);
    }

    @Transactional
    public void xoa(Integer id) {
        articleRepo.deleteById(id);
    }

    private void apDung(Article a, LuuArticleRequest req, boolean moi) {
        if (req.tieuDe() == null || req.tieuDe().isBlank())
            throw new RuntimeException("Nhập tiêu đề bài viết.");
        if (req.categoryId() == null)
            throw new RuntimeException("Chọn danh mục.");
        if (req.noiDung() == null || req.noiDung().isBlank())
            throw new RuntimeException("Nhập nội dung bài viết.");

        ArticleCategory cat = categoryRepo.findById(req.categoryId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy danh mục"));
        a.setCategory(cat);
        a.setTieuDe(req.tieuDe().trim());
        a.setThumbnail(req.thumbnail());
        a.setTomTat(req.tomTat());
        a.setNoiDung(req.noiDung());
        a.setTacGia(req.tacGia() != null && !req.tacGia().isBlank() ? req.tacGia() : "CNTTShop");
        a.setNoiBat(req.noiBat() != null && req.noiBat());

        // Slug: dùng slug admin nhập, nếu trống thì tự sinh từ tiêu đề. Đảm bảo duy nhất.
        String slug = req.slug() != null && !req.slug().isBlank() ? req.slug() : req.tieuDe();
        a.setSlug(slugDuyNhat(slugify(slug), a.getId()));

        // Xuất bản: đặt published_at lần đầu chuyển sang published.
        String tt = "published".equals(req.trangThai()) ? "published" : "draft";
        if ("published".equals(tt) && a.getPublishedAt() == null) {
            a.setPublishedAt(LocalDateTime.now());
        }
        a.setTrangThai(tt);
    }

    private String slugify(String s) {
        String noAccent = Normalizer.normalize(s == null ? "" : s, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('đ', 'd').replace('Đ', 'D');
        String slug = noAccent.trim().toLowerCase()
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("(^-+|-+$)", "");
        return slug.isBlank() ? "bai-viet" : slug;
    }

    /** Thêm hậu tố -2, -3... nếu trùng slug bài khác. */
    private String slugDuyNhat(String base, Integer selfId) {
        String slug = base;
        int i = 2;
        while (true) {
            var existing = articleRepo.findBySlugFetch(slug);
            if (existing.isEmpty() || existing.get().getId().equals(selfId)) return slug;
            slug = base + "-" + (i++);
        }
    }

    private AdminArticleDto toAdmin(Article a) {
        return new AdminArticleDto(
                a.getId(), a.getSlug(), a.getTieuDe(), a.getThumbnail(), a.getTomTat(),
                a.getNoiDung(), a.getCategory().getId(), a.getCategory().getTen(), a.getTacGia(),
                a.getTrangThai(), a.isNoiBat(), a.getLuotXem(),
                a.getPublishedAt(), a.getCreatedAt());
    }
}
