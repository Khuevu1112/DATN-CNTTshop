package com.fpoly.service;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.math.BigDecimal;
import java.text.Normalizer;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.fpoly.dto.ProductImportDtos.ImportResultDto;
import com.fpoly.dto.ProductImportDtos.ImportRowError;
import com.fpoly.model.Brand;
import com.fpoly.model.Category;
import com.fpoly.model.Product;
import com.fpoly.model.ProductImage;
import com.fpoly.model.ProductVariant;
import com.fpoly.repository.BrandRepository;
import com.fpoly.repository.CategoryRepository;
import com.fpoly.repository.ProductImageRepository;
import com.fpoly.repository.ProductRepository;
import com.fpoly.repository.ProductVariantRepository;

/**
 * Nhập sản phẩm hàng loạt từ file Excel (.xlsx/.xls) cho admin-vue.
 *
 * QUY ƯỚC (đã thống nhất với người dùng):
 *  - Mỗi dòng Excel = 1 sản phẩm với đúng 1 biến thể (giá/kho). Sản phẩm cần nhiều biến thể
 *    (màu, cấu hình...) thì tạo qua form quản trị sẵn có sau khi import xong dòng nền tảng này.
 *  - SKU đã tồn tại trong hệ thống -> CẬP NHẬT sản phẩm/biến thể đó (đồng bộ giá & tồn kho hàng
 *    loạt là mục đích chính của tính năng), không tạo bản ghi trùng.
 *  - Tên danh mục trong file không khớp danh mục có sẵn -> báo lỗi dòng đó và bỏ qua, KHÔNG tự
 *    tạo danh mục mới (tránh phá cấu trúc menu/category do lỗi chính tả trong file).
 *  - Ảnh chỉ nhận URL có sẵn (không tải file lên), nhiều ảnh cách nhau bởi dấu ";".
 *
 * Một dòng lỗi không chặn các dòng còn lại — đọc/validate xong mới ghi DB, lỗi được gom lại trả
 * về cho admin sửa và nhập lại đúng dòng đó.
 */
@Service
public class ProductImportService {

    @Autowired private ProductRepository productRepo;
    @Autowired private CategoryRepository categoryRepo;
    @Autowired private BrandRepository brandRepo;
    @Autowired private ProductVariantRepository variantRepo;
    @Autowired private ProductImageRepository imageRepo;

    private static final DataFormatter FORMATTER = new DataFormatter();

    // Thứ tự cột trong template — xem buildTemplate().
    private static final int COL_NAME = 0;
    private static final int COL_CATEGORY = 1;
    private static final int COL_BRAND = 2;
    private static final int COL_SKU = 3;
    private static final int COL_PRICE = 4;
    private static final int COL_ORIGINAL_PRICE = 5;
    private static final int COL_STOCK = 6;
    private static final int COL_WARRANTY = 7;
    private static final int COL_DESCRIPTION = 8;
    private static final int COL_IMAGES = 9;
    private static final int COL_ACTIVE = 10;
    private static final int COL_COUNT = 11;

    @Transactional
    public ImportResultDto importExcel(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("Vui lòng chọn file Excel cần nhập");
        }

        Workbook wb;
        try (InputStream is = file.getInputStream()) {
            wb = WorkbookFactory.create(is);
        } catch (Exception e) {
            throw new RuntimeException("Không đọc được file Excel (.xlsx/.xls): " + e.getMessage());
        }

        try {
            Sheet sheet = wb.getSheetAt(0);

            // Nạp trước danh mục/thương hiệu hiện có để so khớp không phân biệt hoa-thường/dấu.
            Map<String, Category> categoryByKey = new LinkedHashMap<>();
            for (Category c : categoryRepo.findAll()) categoryByKey.put(normalize(c.getName()), c);
            Map<String, Brand> brandByKey = new LinkedHashMap<>();
            for (Brand b : brandRepo.findAll()) brandByKey.put(normalize(b.getName()), b);

            int created = 0, updated = 0, skipped = 0, totalRows = 0;
            List<ImportRowError> errors = new ArrayList<>();

            int lastRow = sheet.getLastRowNum();
            for (int r = 1; r <= lastRow; r++) { // dòng 0 = header
                Row row = sheet.getRow(r);
                if (row == null || isRowEmpty(row)) continue;
                totalRows++;
                int excelRowNumber = r + 1; // 1-based, tính cả header, để khớp số dòng admin thấy trong Excel

                String name = cellString(row, COL_NAME);
                try {
                    if (name == null || name.isBlank()) {
                        throw new RuntimeException("Thiếu tên sản phẩm");
                    }

                    String categoryRaw = cellString(row, COL_CATEGORY);
                    if (categoryRaw == null || categoryRaw.isBlank()) {
                        throw new RuntimeException("Thiếu danh mục");
                    }
                    Category category = categoryByKey.get(normalize(categoryRaw));
                    if (category == null) {
                        throw new RuntimeException("Danh mục \"" + categoryRaw + "\" không tồn tại trong hệ thống");
                    }

                    BigDecimal price = cellDecimal(row, COL_PRICE);
                    if (price == null || price.signum() < 0) {
                        throw new RuntimeException("Thiếu hoặc sai định dạng giá bán");
                    }
                    BigDecimal originalPrice = cellDecimal(row, COL_ORIGINAL_PRICE);

                    Integer stock = cellInt(row, COL_STOCK);
                    if (stock == null || stock < 0) {
                        throw new RuntimeException("Thiếu hoặc sai định dạng tồn kho");
                    }

                    Integer warrantyMonths = cellInt(row, COL_WARRANTY);
                    if (warrantyMonths == null) warrantyMonths = 36;

                    String description = cellString(row, COL_DESCRIPTION);
                    String skuRaw = cellString(row, COL_SKU);
                    String activeRaw = cellString(row, COL_ACTIVE);
                    boolean isActive = activeRaw == null || !normalize(activeRaw).equals("khong");

                    String brandRaw = cellString(row, COL_BRAND);
                    Brand brand = null;
                    if (brandRaw != null && !brandRaw.isBlank()) {
                        brand = brandByKey.get(normalize(brandRaw));
                        if (brand == null) {
                            brand = new Brand();
                            brand.setName(brandRaw.trim());
                            brand = brandRepo.save(brand);
                            brandByKey.put(normalize(brandRaw), brand);
                        }
                    }

                    String imagesRaw = cellString(row, COL_IMAGES);

                    ProductVariant existingVariant = (skuRaw != null && !skuRaw.isBlank())
                            ? variantRepo.findBySku(skuRaw.trim()).orElse(null)
                            : null;

                    if (existingVariant != null) {
                        Product p = existingVariant.getProduct();
                        p.setName(name.trim());
                        p.setCategory(category);
                        p.setBrand(brand);
                        if (description != null && !description.isBlank()) p.setDescription(description.trim());
                        p.setWarrantyMonths(warrantyMonths);
                        p.setIsActive(isActive);
                        productRepo.save(p);

                        existingVariant.setPrice(price);
                        existingVariant.setOriginalPrice(originalPrice);
                        existingVariant.setStock(stock);
                        variantRepo.save(existingVariant);

                        updated++;
                    } else {
                        Product p = new Product();
                        p.setName(name.trim());
                        p.setSlug(uniqueSlug(name.trim()));
                        p.setDescription(description);
                        p.setCategory(category);
                        p.setBrand(brand);
                        p.setIsActive(isActive);
                        p.setWarrantyMonths(warrantyMonths);
                        p.setCreatedAt(LocalDateTime.now());
                        p = productRepo.save(p);

                        ProductVariant v = new ProductVariant();
                        v.setProduct(p);
                        v.setSku((skuRaw == null || skuRaw.isBlank()) ? "SKU-" + p.getId() : skuRaw.trim());
                        v.setPrice(price);
                        v.setOriginalPrice(originalPrice);
                        v.setStock(stock);
                        v.setIsDefault(true);
                        variantRepo.save(v);

                        if (imagesRaw != null && !imagesRaw.isBlank()) {
                            saveImagesFromUrls(p, imagesRaw);
                        }

                        created++;
                    }
                } catch (Exception e) {
                    skipped++;
                    errors.add(new ImportRowError(excelRowNumber, name, e.getMessage()));
                }
            }

            return new ImportResultDto(totalRows, created, updated, skipped, errors);
        } finally {
            try { wb.close(); } catch (Exception ignored) { /* best effort */ }
        }
    }

    /** Sinh file Excel mẫu: sheet 1 = header + 1 dòng ví dụ, sheet 2 = danh sách tên danh mục
     * hợp lệ hiện có (để admin đối chiếu, tránh gõ sai chính tả bị báo lỗi khi nhập). */
    public byte[] buildTemplate() {
        try (Workbook wb = new XSSFWorkbook()) {
            Sheet sheet = wb.createSheet("San pham");
            String[] headers = {
                    "Ten san pham", "Danh muc", "Thuong hieu", "SKU (de trong se tu sinh)",
                    "Gia ban", "Gia goc", "Ton kho", "Bao hanh (thang)", "Mo ta",
                    "Anh (URL, cach nhau boi ;)", "Kich hoat (Co/Khong)"
            };
            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < headers.length; i++) {
                headerRow.createCell(i).setCellValue(headers[i]);
            }

            String[] sample = {
                    "Laptop Dell XPS 13", "Laptop", "Dell", "",
                    "25000000", "27000000", "10", "36",
                    "Laptop mong nhe, man hinh 13 inch", "", "Co"
            };
            Row sampleRow = sheet.createRow(1);
            for (int i = 0; i < sample.length; i++) {
                sampleRow.createCell(i).setCellValue(sample[i]);
            }

            Sheet catSheet = wb.createSheet("Danh muc hop le");
            catSheet.createRow(0).createCell(0).setCellValue("Ten danh muc (go dung chinh ta khi nhap)");
            int r = 1;
            for (Category c : categoryRepo.findAllByOrderBySortOrderAsc()) {
                catSheet.createRow(r++).createCell(0).setCellValue(c.getName());
            }

            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            wb.write(bos);
            return bos.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Không tạo được file mẫu: " + e.getMessage());
        }
    }

    // ===== helpers =====

    private boolean isRowEmpty(Row row) {
        for (int c = 0; c < COL_COUNT; c++) {
            if (cellString(row, c) != null) return false;
        }
        return true;
    }

    private String cellString(Row row, int col) {
        Cell cell = row.getCell(col);
        if (cell == null) return null;
        String v = FORMATTER.formatCellValue(cell).trim();
        return v.isEmpty() ? null : v;
    }

    private BigDecimal cellDecimal(Row row, int col) {
        Cell cell = row.getCell(col);
        if (cell == null) return null;
        try {
            if (cell.getCellType() == CellType.NUMERIC) {
                return BigDecimal.valueOf(cell.getNumericCellValue());
            }
            String raw = FORMATTER.formatCellValue(cell).trim();
            if (raw.isEmpty()) return null;
            raw = raw.replaceAll("[^0-9.,-]", "").replace(",", "");
            return raw.isEmpty() ? null : new BigDecimal(raw);
        } catch (Exception e) {
            return null;
        }
    }

    private Integer cellInt(Row row, int col) {
        BigDecimal d = cellDecimal(row, col);
        return d == null ? null : d.intValue();
    }

    /** Bỏ dấu, thường hoá, gộp khoảng trắng thừa — so khớp tên danh mục/thương hiệu không phân
     * biệt hoa-thường/dấu (VD: "Laptop " và "laptop" khớp nhau). */
    private String normalize(String raw) {
        if (raw == null) return "";
        String noAccent = Normalizer.normalize(raw, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('đ', 'd').replace('Đ', 'D');
        return noAccent.trim().toLowerCase().replaceAll("\\s+", " ");
    }

    private String uniqueSlug(String name) {
        String base = Normalizer.normalize(name, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('đ', 'd').replace('Đ', 'D')
                .trim().toLowerCase()
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("(^-+|-+$)", "");
        if (base.isBlank()) base = "sp";
        String slug = base;
        int suffix = 1;
        while (productRepo.findBySlug(slug).isPresent()) {
            suffix++;
            slug = base + "-" + suffix;
        }
        return slug;
    }

    private void saveImagesFromUrls(Product product, String imagesRaw) {
        String[] urls = imagesRaw.split(";");
        int i = 0;
        for (String url : urls) {
            String u = url.trim();
            if (u.isEmpty()) continue;
            ProductImage img = new ProductImage();
            img.setProduct(product);
            img.setUrl(u);
            img.setIsPrimary(i == 0);
            img.setSortOrder(i);
            imageRepo.save(img);
            i++;
        }
    }
}
    