package com.fpoly.dto;

import java.util.List;

/** DTO cho tính năng "Nhập sản phẩm từ Excel" (admin-vue). */
public class ProductImportDtos {

    /** Một dòng trong file bị bỏ qua kèm lý do, để admin sửa lại và nhập lại đúng dòng đó. */
    public record ImportRowError(
            int rowNumber,
            String productName,
            String reason
    ) {}

    public record ImportResultDto(
            int totalRows,
            int created,
            int updated,
            int skipped,
            List<ImportRowError> errors
    ) {}
}
