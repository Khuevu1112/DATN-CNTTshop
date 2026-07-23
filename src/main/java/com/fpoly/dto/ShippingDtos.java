package com.fpoly.dto;

import java.math.BigDecimal;
import java.util.List;

public class ShippingDtos {

    // scope: "hai_phong" (chọn hoả tốc/thường) | "carrier" (chọn 1 trong 5 hãng).
    // khoangCachKm: quãng đường thật từ kho tới điểm khách cắm, chỉ có với scope "hai_phong" và
    // khi địa chỉ đã cắm mốc — null nghĩa là phí đang lấy theo bảng phẳng cũ, UI đừng hiện số km.
    public record ShippingOptionsDto(String scope, List<ShippingOptionDto> options, BigDecimal khoangCachKm) {}

    /** fee = phí khách thực trả (đã trừ ưu đãi bậc thành viên), feeGoc = phí niêm yết trước ưu
     * đãi — bằng nhau khi khách chưa có ưu đãi nào, khác nhau thì UI gạch ngang feeGoc. */
    public record ShippingOptionDto(String code, String label, BigDecimal fee, String eta, BigDecimal feeGoc) {}
}
